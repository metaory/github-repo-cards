#!/bin/bash
set -euo pipefail

# ───────────────[ DEFAULTS ]───────────────
AVATAR='style=glass radius=28 backgroundType=gradientLinear'
OWNER="${GITHUB_ACTOR:-$(git config user.name)}"
OUTPUT_DIR=cards
THEME=default
DEV=false
REPOS=
FONT_DEST="$HOME/.local/share/fonts/TTF"

# ───────────────[ OS DETECT ]───────────────
[[ "$(uname)" == "Darwin" ]] &&
  FONT_DEST="/Library/Fonts" &&
  function date { gdate "$@" 2>/dev/null || /bin/date "$@"; }

# ───────────────[ TRAP ]───────────────
function on_error {
  local exit_code=$?
  local line_no=$1
  local cmd=$2
  printf '[%s] ❌ ERROR at line %s: %s (exit %s)\n' \
    "$(date '+%H:%M:%S')" "$line_no" "$cmd" "$exit_code" >&2
}

function cleanup {
  log "Cleaning up temporary files..."
  [ $DEV = true ] || rm -rf "$TMP"
}

trap 'on_error $LINENO "$BASH_COMMAND"' ERR
trap cleanup EXIT
trap 'log "Interrupted"; cleanup; exit 1' INT

# ───────────────[ HELP ]───────────────
function usage {
  cat <<EOF
Usage:
  --repos NAME...      Space separated repository names (required)
  --avatar OPTIONS     DiceBear avatar style options
  --output DIR         Output directory (default: cards)
  --theme NAME         Theme name (default: default)
  --dev                Use mock data instead of GitHub API
  -h, --help           Show this help
EOF
  exit 0
}

# ───────────────[ DEBUG ]───────────────
function log {
  printf '\033[35m [%03d:%.4s]\033[36m %s\033[0m\n' \
    "${BASH_LINENO[0]}" "${FUNCNAME[1]:-main}" "$*"
}
function logheader {
  printf '\n\033[1;36m╭─[ SETUP ]────────────────╴───╶╴──╶╴╴\033[0m\n'
  for var; do
    printf '\033[1;36m│\033[0m %-10s : \033[1m%s\033[0m\n' "$var" "${!var}"
  done
  printf '\033[1;36m╰─────────────────────────────────╴─╴─╴╴╴╴\033[0m\n'
}

# ───────────────[ TRACE ]───────────────
TRACE_START=0
function trace_enter {
  TRACE_START=$(date +%s%3N)
  printf '\033[32m[%s] ▶ %s\033[0m\n' "$(date '+%H:%M:%S')" "$1" >&2
}
function trace_exit {
  printf '\033[31m[%s] ◀ %s (%d ms)\033[0m\n' \
    "$(date '+%H:%M:%S')" "$1" "$(($(date +%s%3N) - TRACE_START))" >&2
}

# ───────────────[ OPTIONS ]───────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
  --repos)
    REPOS="$2"
    shift 2
    ;;
  --avatar)
    AVATAR="$2"
    shift 2
    ;;
  --output)
    OUTPUT_DIR="$2"
    shift 2
    ;;
  --dev)
    DEV=true
    shift
    ;;
  --theme)
    THEME="$2"
    shift 2
    ;;
  -h | --help) usage ;;
  *)
    log "unknown arg: $1"
    usage
    ;;
  esac
done

# ───────────────[ ASSERTS ]───────────────
[[ -z $REPOS ]] && {
  log "❌ --repos required"
  usage
}
for cmd in jq gh curl base64 envsubst inkscape dicebear; do
  command -v "$cmd" >/dev/null || {
    log "❌ missing: $cmd" >&2
    exit 127
  }
done

[[ -f "themes/${THEME}.svg" ]] || {
  log "❌ Theme file not found: $THEME"
  exit 2
}

# ───────────────[ SETUP ]───────────────
TMP=$(mktemp -d)
mkdir -p "${OUTPUT_DIR}" &>/dev/null || :

# ──────────────────────────────────────
# ───────────────[ FONTS ]───────────────
function load_font {
  trace_enter load_font
  log "Loading fonts from theme..."
  mkdir -p "$FONT_DEST"

  local theme_svg="themes/${THEME}.svg"

  while read -r url; do
    [ -z "$url" ] && continue
    filename="$(md5 <<<"$url").ttf"
    font_path="$FONT_DEST/$filename"
    if [ ! -f "$font_path" ]; then
      log "Downloading font: $url"
      log "Font path: $font_path"
      curl -f -L -o "$font_path" "$url" || {
        log "❌ Failed to download font: $url"
        continue
      }
    else
      log "Font already exists: $filename"
    fi
  done < <(sed -n 's/<!-- FONT::\(.*\) -->/\1/p' "$theme_svg")

  fc-cache -f

  trace_exit load_font
}

# ───────────────[ AVATAR ]───────────────
function load_avatar {
  trace_enter load_avatar
  local style="" args=()

  for pair in $AVATAR; do
    k=${pair%%=*}
    v=${pair#*=}
    # shellcheck disable=SC2206
    [[ "$k" = style ]] && style=$v || args+=(--$k "$v")
  done

  dicebear "$style" "${args[@]}" --seed "$1" "${TMP}/${1}" >&2
  local svg="${TMP}/${1}/${style}-0.svg"

  [[ -f "$svg" ]] || {
    echo ":x: dicebear did not generate $svg" >&2
    exit 1
  }

  printf '<image x="0" y="0" width="64" height="64" 
    href="data:image/svg+xml;base64,%s"/>' "$(base64 -w0 <"$svg")"
  trace_exit load_avatar
}

# ───────────────[ POS ]───────────────
function trunc {
  local text="$1" max_width=$2 font_size=${3:-24} ellipsis="..."
  local avg_char_width=$((font_size / 2))
  local max_chars=$((max_width / avg_char_width))

  [[ ${#text} -le max_chars ]] && {
    echo "$text"
    return
  }

  local cut="${text:0:max_chars}"
  cut="${cut% *}"
  [[ -z $cut ]] && cut="${text:0:max_chars}"

  echo "${cut}${ellipsis}"
}

# ───────────────[ REPO ]───────────────
function fetch_repo {
  trace_enter fetch_repo
  local repo="$1"

  if $DEV; then
    jq -n --arg repo "$repo" '{
      name: $repo,
      desc: "Everyone has the right to freedom of thought, opinion, conscience and expression religion; this right includes freedom to change his religion or belief, and freedom, either alone or in community with others and in public or private, to manifest his religion or belief in teaching, practice, worship and observance",
      lang: "JavaScript",
      star: 42,
      fork: 7
    }'
    # lang: "Lua",
    # lang: "Haskell",
    # lang: "JavaScript",
    # lang: "Vim Help File",
    # lang: "Git Revision List",
    # lang: "OpenAPI Specification",
    return
  fi

  gh repo view "$OWNER/$repo" \
    --json name,description,primaryLanguage,stargazerCount,forkCount \
    --jq '{
      name: .name,
      desc: (.description // "—"),
      lang: (.primaryLanguage.name // "n/a"),
      star: .stargazerCount,
      fork: .forkCount
    }'
  trace_exit fetch_repo
}

# ──────────────────────────────────────
# ───────────────[ MAIN ]───────────────
function generate {
  trace_enter generate
  IFS=$'\t' read -r name desc lang star fork < <(jq -r '[.name, .desc, .lang, .star, .fork] | @tsv' <<<"$1")

  load_font
  lang="&#32;${lang}&#32;"

  repo="${name}"
  name=$(trunc "$name" 390 32)
  desc=$(trunc "$desc" 1800 26)

  export name desc lang star fork avatar

  avatar="$(load_avatar "${repo}")"

  export name desc lang star fork avatar

  for scheme in light dark; do
    log "loading $scheme $repo"
    filename="card_${repo}_${scheme}"

    sed "s/__THEME__/theme-${scheme}/" "themes/${THEME}.svg" | envsubst >"${TMP}/${filename}.svg"

    inkscape "${TMP}/${filename}.svg" \
      --export-dpi=300 \
      --export-type=png \
      --export-filename="./${OUTPUT_DIR}/${filename}.png"

    log "Generated ${filename}.png"
  done
  trace_exit generate
}

# ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶
logheader TMP DEV OWNER REPOS THEME OUTPUT_DIR

# ───────────────[ DRIVER ]───────────────
for repo in $REPOS; do
  log "processing $repo ..."
  generate "$(fetch_repo "$repo")"
done
