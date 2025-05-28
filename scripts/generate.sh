#!/bin/bash
set -euo pipefail
set -E

# ───────────────[ DEFAULTS ]
AVATAR='style=glass radius=28 backgroundType=gradientLinear'
OWNER="${GITHUB_ACTOR:-$(git config user.name)}"
OUTPUT_DIR=cards
THEME=default
THEME_PATH=""
DEV=false
REPOS=
FONT_DEST="$HOME/.local/share/fonts/TTF"
FORMAT=svg

# ───────────────[ OS DETECT ]
[[ "$(uname)" == "Darwin" ]] &&
  FONT_DEST="/Library/Fonts" &&
  function date { gdate "$@" 2>/dev/null || /bin/date "$@"; }
# sed -i ''

# ───────────────[ TRAP ]
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

# ───────────────[ HELP ]
function usage {
  cat <<EOF
Usage:
  --repos NAME...      Space separated repository names (required)
  --avatar OPTIONS     DiceBear avatar style options
  --output DIR         Output directory (default: cards)
  --theme NAME|PATH    Theme name (from themes/) or path to SVG file (default: default)
  --format TYPE        Format: svg (default, text as paths) or raster (e.g. png, jpg)
  --dev                Use mock data instead of GitHub API
  -h, --help           Show this help
EOF
  exit 0
}

# ───────────────[ DEBUG ]
function log {
  printf '\033[35m [%03d:%.4s]\033[36m %s\033[0m\n' \
    "${BASH_LINENO[0]}" "${FUNCNAME[1]:-main}" "$*"
}
function logheader {
  printf '\n\033[1;36m╭─[ SETUP ]────────────────╴───╶╴──╶╴╴\033[0m\n'
  for var; do
    printf '\033[1;36m│\033[0m %-12s : \033[1m%s\033[0m\n' "$var" "${!var}"
  done
  printf '\033[1;36m╰─────────────────────────────────╴─╴─╴╴╴╴\033[0m\n'
}

# ───────────────[ TRACE ]
TRACE_START=0
function trace_enter {
  TRACE_START=$(date +%s%3N)
  printf '\033[32m[%s] ▶ %s\033[0m\n' "$(date '+%H:%M:%S')" "$1" >&2
}
function trace_exit {
  printf '\033[31m[%s] ◀ %s (%d ms)\033[0m\n' \
    "$(date '+%H:%M:%S')" "$1" "$(($(date +%s%3N) - TRACE_START))" >&2
}

# ───────────────[ OPTIONS ]
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
  --format)
    FORMAT="$2"
    shift 2
    ;;
  -h | --help) usage ;;
  *)
    log "unknown arg: $1"
    usage
    ;;
  esac
done

# ───────────────[ ASSERTS ]
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

# ───────────────[ SETUP ]
TMP=$(mktemp -d)
mkdir -p "${OUTPUT_DIR}" &>/dev/null || :

if [[ -f "${THEME}" ]]; then
  THEME_PATH="${THEME}"
elif [[ -f "themes/${THEME}.svg" ]]; then
  THEME_PATH="themes/${THEME}.svg"
else
  THEME_PATH="themes/default.svg"
fi


# ────────────────────────
# ───────────────[ FONTS ]
function load_font {
  trace_enter load_font
  log "Loading fonts from theme..."
  mkdir -p "$FONT_DEST"

  local theme_svg="$THEME_PATH"

  while read -r url; do
    [ -z "$url" ] && continue
    filename="$(md5sum <<<$url | awk '{print $1}').ttf"
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
  done < <(sed -En 's/<!-- FONT::(.*) -->/\1/p' "$theme_svg")

  fc-cache -f

  trace_exit load_font
}

# ───────────────[ AVATAR ]
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

  avatar="$(base64 -w0 <"$svg")"
  export avatar
  trace_exit load_avatar
}

# ───────────────[ TEXT ]
function make_tspans {
  local text="$1" max_chars="$2" x="$3" line_height="$4" max_lines="${5:-0}"
  local first=true out="" line_count=0

  while IFS= read -r line; do
    line_count=$((line_count + 1))
    if [[ $max_lines -gt 0 && $line_count -gt $max_lines ]]; then
      break
    fi
    if $first; then
      out+='<tspan x="'$x'" dy="0">'$line'</tspan>'
      first=false
    else
      out+='<tspan x="'$x'" dy="'$line_height'">'$line'</tspan>'
    fi
  done < <(echo "$text" | fold -s -w "$max_chars")

  local total_lines
  total_lines=$(echo "$text" | fold -s -w "$max_chars" | wc -l | tr -d ' ')
  if [[ $max_lines -gt 0 && $total_lines -gt $max_lines ]]; then
    out=$(echo "$out" | sed -E '$s|</tspan>$|...<\/tspan>|')
  fi

  echo "$out"
}

# ───────────────[ WIDTH CALC ]
function text_width {
  local text="$1" font_size="$2"
  echo $((${#text} * font_size * 6 / 10))
}

# ───────────────[ REPO ]
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

# ───────────────────────
# ───────────────[ MAIN ]
function generate {
  trace_enter generate
  IFS=$'\t' read -r name desc lang star fork < \
    <(jq -r '[.name, .desc, .lang, .star, .fork] | @tsv' <<<"$1")

  repo="${name}"
  name_tspans=$(make_tspans "$name" 12 80 32 2)
  desc_tspans=$(make_tspans "$desc" 34 0 26 4)

  lang_width=$(text_width "$lang" 24)
  lang_width=$((lang_width + 24))
  [ "$lang_width" -lt 80 ] && lang_width=80
  lang_x=$((lang_width / 2))
  stat_x=260

  load_avatar "${repo}"

  export name_tspans desc_tspans lang star fork avatar lang_width lang_x stat_x

  for scheme in light dark; do
    log "loading $scheme $repo"
    filename="card_${repo}_${scheme}"

    scripts/flatten_css.sh <"$THEME_PATH" |
      scripts/inline_vars.sh |
      sed "s/__THEME__/${scheme}/" |
      envsubst >"${TMP}/${filename}.svg"

    if grep -q 'var(--' "${TMP}/${filename}.svg"; then
      log "❌ CSS variable inlining failed: var(--...) found in ${filename}.svg" >&2
      exit 99
    fi

    case "$FORMAT" in
    svg)
      inkscape "${TMP}/${filename}.svg" \
        --export-filename="./${OUTPUT_DIR}/${filename}.svg" \
        --export-type=svg \
        --export-text-to-path
      sed -i -e '/<!--.*-->/d' -e '/^\s*$/d' "./${OUTPUT_DIR}/${filename}.svg"
      # Pretty-print SVG if xmllint is available
      if command -v xmllint >/dev/null; then
        xmllint --format "./${OUTPUT_DIR}/${filename}.svg" >"./${OUTPUT_DIR}/${filename}.svg.pretty" &&
          mv "./${OUTPUT_DIR}/${filename}.svg.pretty" "./${OUTPUT_DIR}/${filename}.svg"
      fi
      log "Generated ${filename}.svg"
      ;;
    *)
      inkscape "${TMP}/${filename}.svg" \
        --export-dpi=300 \
        --export-type="$FORMAT" \
        --export-filename="./${OUTPUT_DIR}/${filename}.${FORMAT}"
      log "Generated ${filename}.${FORMAT}"
      ;;
    esac
  done
  trace_exit generate
}

# ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶
logheader TMP FORMAT AVATAR DEV OWNER REPOS THEME THEME_PATH OUTPUT_DIR

# ───────────────[ DRIVER ]
load_font

for repo in $REPOS; do
  log "processing $repo ..."
  generate "$(fetch_repo "$repo")"
done
