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

trap 'on_error $LINENO "$BASH_COMMAND"' ERR

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
for cmd in jq gh curl base64 envsubst inkscape; do
  command -v "$cmd" >/dev/null || {
    log "missing: $cmd" >&2
    exit 127
  }
done

# ───────────────[ SETUP ]───────────────
TMP=$(mktemp -d)
function cleanup { rm -rf "$TMP"; }
trap cleanup EXIT
mkdir -p "${OUTPUT_DIR}" &>/dev/null || :

# ───────────────────────────────────────
# ───────────────[ FONTS ]───────────────
function load_font {
  log "Loading fonts..."
  mkdir -p ~/.local/share/fonts/TTF "${TMP}/fonts"

  # Default values
  HEAD_FONT_NAME="bungee" HEAD_FONT_WEIGHT="700"
  BODY_FONT_NAME="baloo-bold" BODY_FONT_WEIGHT="800"
  STAT_FONT_NAME="baloo-norm" STAT_FONT_WEIGHT="400"

  for font_def in $FONTS; do
    IFS="=:@" read -r section alias weight url <<<"${font_def/=/:/@/}"

    [[ ! "$section" =~ ^(head|body|stat)$ || -z "$url" || ! "$url" =~ \.ttf$ ]] && continue

    filename="${section}_$(basename "$url")"
    if curl -s -f -o ~/.local/share/fonts/TTF/"$filename" "$url"; then
      cp ~/.local/share/fonts/TTF/"$filename" "${TMP}/fonts/"

      font_family=$(fc-scan --format='%{family}\n' ~/.local/share/fonts/TTF/"$filename" | head -n1)

      case "$section" in
      head) HEAD_FONT_NAME="${font_family:-$alias}" HEAD_FONT_WEIGHT="$weight" ;;
      body) BODY_FONT_NAME="${font_family:-$alias}" BODY_FONT_WEIGHT="$weight" ;;
      stat) STAT_FONT_NAME="${font_family:-$alias}" STAT_FONT_WEIGHT="$weight" ;;
      esac
    fi
  done

  fc-cache -f
  export HEAD_FONT_NAME HEAD_FONT_WEIGHT BODY_FONT_NAME BODY_FONT_WEIGHT STAT_FONT_NAME STAT_FONT_WEIGHT
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

# ───────────────[ REPO ]───────────────
function fetch_repo {
  local repo="$1"

  if $DEV; then
    jq -n --arg repo "$repo" '{
      name: $repo,
      desc: "Everyone has the right to freedom of thought, opinion, conscience and expression religion; this right includes freedom to change his religion or belief, and freedom, either alone or in community with others and in public or private, to manifest his religion or belief in teaching, practice, worship and observance",
      lang: "Lua",
      star: 42,
      fork: 7
    }'
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

  logo="$(load_logo "${name}")"
  export name desc lang star fork logo
  load_font

  for scheme in light dark; do
    log "scheme $scheme"
    load_theme "$scheme"
    filename="card_${name}_${scheme}"

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
