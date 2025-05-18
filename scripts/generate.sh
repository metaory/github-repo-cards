#!/bin/bash
set -euo pipefail

# ───────────────[ DEFAULTS ]───────────────
DEV=false
OWNER="${GITHUB_ACTOR:-$(git config user.name)}"
OUTPUT_DIR=cards
OVERRIDES=
LOGO='style=glass radius=28 backgroundType=gradientLinear'
FONTS='head=bungee:700@https://cdn.jsdelivr.net/fontsource/fonts/bungee-shade@latest/latin-400-normal.ttf body=baloo-bold:800@https://cdn.jsdelivr.net/fontsource/fonts/baloo-2@latest/latin-700-normal.ttf stat=baloo-norm:400@https://cdn.jsdelivr.net/fontsource/fonts/baloo-2@latest/latin-400-normal.ttf'
REPOS=

# ───────────────[ TRAP ]───────────────
function on_error {
  local exit_code=$?
  local line_no=$1
  local cmd=$2
  printf '[%s] ❌ ERROR at line %s: %s (exit %s)\n' "$(date '+%H:%M:%S')" "$line_no" "$cmd" "$exit_code" >&2
}

function cleanup {
  log "Cleaning up temporary files..."
  [[ -d "$TMP" ]] && rm -rf "$TMP"
}

trap 'on_error $LINENO "$BASH_COMMAND"' ERR
trap cleanup EXIT
trap 'log "Interrupted"; cleanup; exit 1' INT

# ───────────────[ HELP ]───────────────
function usage {
  cat <<EOF
Usage:
  --repos NAME...    Space separated repositories (required)
  --overrides EXT    Space separated overrides
  --fonts EXT        Space separated fonts
  --logo EXT         Logo dicebear options
  --output DIR       Output directory (default: cards)
  --dev              Use mock data (no GitHub API)
  -h, --help         Show this help
EOF
  exit 0
}

# ───────────────[ DEBUG ]───────────────
function log {
  tput setaf 5
  printf ' [%03d:' "${BASH_LINENO[0]}"
  printf '%.4s]' "${FUNCNAME[1]:-main}"
  tput setaf 6
  printf ' %s\n' "$*"
  tput sgr0
}
function logheader {
  printf '\n\033[1;36m╭─[ SETUP ]────────────────╴───╶╴──╶╴╴\033[0m\n'
  for var; do
    printf '\033[1;36m│\033[0m %-10s : \033[1m%s\033[0m\n' "$var" "${!var}"
  done
  printf '\033[1;36m╰─────────────────────────────────╴─╴─╴╴╴╴\033[0m\n'
}

# ───────────────[ OPTIONS ]───────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
  --repos)
    REPOS="$2"
    shift 2
    ;;
  --overrides)
    OVERRIDES="$2"
    shift 2
    ;;
  --logo)
    LOGO="$2"
    shift 2
    ;;
  --fonts)
    FONTS="$2"
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

# ───────────────[ SETUP ]───────────────
TMP=$(mktemp -d)
mkdir -p "${OUTPUT_DIR}" &>/dev/null || :

# ───────────────────────────────────────
# ───────────────[ FONTS ]───────────────
function load_font {
  log "Loading fonts..."
  mkdir -p ~/.local/share/fonts/TTF

  H_FONT="sans-serif" H_WEIGHT="700"
  B_FONT="sans-serif" B_WEIGHT="400"
  S_FONT="sans-serif" S_WEIGHT="400"

  for font_def in $FONTS; do
    [[ "$font_def" == *=*:*@* ]] || {
      log "Invalid font format: $font_def"
      continue
    }

    section="${font_def%%=*}"
    rest="${font_def#*=}"
    alias="${rest%%:*}"
    rest="${rest#*:}"
    weight="${rest%%@*}"
    url="${rest#*@}"

    [[ -z "$section" || -z "$alias" || -z "$weight" || -z "$url" ]] && {
      log "Missing component in font definition: $font_def"
      continue
    }

    [[ ! "$section" =~ ^(head|body|stat)$ ]] && {
      log "Invalid section '$section' (must be head, body, or stat)"
      continue
    }

    [[ ! "$url" =~ \.ttf$ ]] && {
      log "URL must end with .ttf: $url"
      continue
    }

    filename="${section}_$(basename "$url")"
    font_path=~/.local/share/fonts/TTF/"$filename"

    if [[ ! -f "$font_path" ]]; then
      log "Downloading font: $url"
      curl -f -o "$font_path" "$url" || {
        log "❌ Failed to download font: $url"
        continue
      }
    else
      log "Font already exists: $filename"
    fi

    font_family=$(fc-scan --format='%{family}\n' "$font_path" | head -n1)
    font_family=${font_family:-$alias}

    case "$section" in
    head) H_FONT="$font_family" H_WEIGHT="$weight" ;;
    body) B_FONT="$font_family" B_WEIGHT="$weight" ;;
    stat) S_FONT="$font_family" S_WEIGHT="$weight" ;;
    esac
  done

  fc-cache -f
  export H_FONT H_WEIGHT B_FONT B_WEIGHT S_FONT S_WEIGHT
}

# ───────────────[ LOGO ]───────────────
function load_logo {
  local style="" args=()

  for pair in $LOGO; do
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

  printf '<image x="0" y="0" width="96" height="96" href="data:image/svg+xml;base64,%s"/>' "$(base64 -w0 <"$svg")"
}

# ───────────────[ THEME ]───────────────
function load_theme {
  local scheme="${1:?BAD}"
  set -a
  # shellcheck disable=SC1090
  source <(
    {
      cat templates/default.env
      tr ' ' '\n' <<<"$OVERRIDES"
    } | sed "/^$/d;s/${scheme^^}_//g"
  )
  set +a
}

# ───────────────[ POS ]───────────────
function trunc {
  local text="$1" max_width=$2 font_size=${3:-24} ellipsis="…"
  local avg_char_width=$((font_size / 2))
  local max_chars=$((max_width / avg_char_width))

  [[ ${#text} -le max_chars ]] && {
    echo "$text"
    return
  }

  local cut="${text:0:max_chars}"
  cut="${cut% *}"
  [[ -z $cut ]] && cut="${text:0:max_chars}"

  echo "$cut$ellipsis"
}

# function svg_text_width {
#   local text="$1" font="$2" size="$3"
#   local svg="/tmp/text.svg"
#   echo "<svg xmlns='http://www.w3.org/2000/svg'><text font-family='$font' font-size='${size}px' x='0' y='14'>$text</text></svg>" >"$svg"
#   inkscape --query-id=svg2 --query-width "$svg" 2>/dev/null
# }

function svg_text_width {
  local text="$1" font="$2" size="$3"
  local avg_width=14
  echo $((${#text} * avg_width))
}

function pill_metrics {
  local prefix="$1" text="$2" font="$3" size="$4" padding="$5"
  local width center
  width=$(svg_text_width "$text" "$font" "$size")
  width=$((${width%.*} + 2 * padding))
  center=$((width / 2))
  export "${prefix}_RW"="$width" "${prefix}_RX"=0 "${prefix}_TX"="$center"
}

# ───────────────[ REPO ]───────────────
function fetch_repo {
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
}

# ──────────────────────────────────────
# ───────────────[ MAIN ]───────────────
function generate {
  IFS=$'\t' read -r name desc lang star fork < <(jq -r '[.name, .desc, .lang, .star, .fork] | @tsv' <<<"$1")

  load_font
  pill_metrics LANG "$lang" "$S_FONT" 24 16

  repo="${name}"
  name=$(trunc "$name" 400 44)
  desc=$(trunc "$desc" 1400 26)

  export name desc lang star fork logo

  logo="$(load_logo "${repo}")"

  export name desc lang star fork logo

  for scheme in light dark; do
    log "loading $scheme $repo"
    load_theme "$scheme"
    filename="card_${repo}_${scheme}"

    envsubst <templates/default.svg >"${TMP}/${filename}.svg"

    inkscape "${TMP}/${filename}.svg" \
      --export-dpi=300 \
      --export-type=png \
      --export-filename="./${OUTPUT_DIR}/${filename}.png"

    log "Generated ${filename}.png"
  done
}

# ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶ ╴╶
logheader TMP DEV OWNER REPOS OVERRIDES FONTS OUTPUT_DIR

# ───────────────[ DRIVER ]───────────────
for repo in $REPOS; do
  log "processing $repo ..."
  generate "$(fetch_repo "$repo")"
done
