#!/bin/bash
set -euo pipefail

function on_error {
  local exit_code=$?
  local line_no=$1
  local cmd=$2
  printf '[%s] ❌ ERROR at line %s: %s (exit %s)\n' "$(date '+%H:%M:%S')" "$line_no" "$cmd" "$exit_code" >&2
}

trap 'on_error $LINENO "$BASH_COMMAND"' ERR

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

function log { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }

DEV=false
OWNER="${GITHUB_ACTOR:-$(git config user.name)}"
OUTPUT_DIR=cards
OVERRIDES=
LOGO='glass/svg?backgroundType=gradientLinear&radius=20'
FONTS=
REPOS=

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

[[ -z $REPOS ]] && {
  log "❌ --repos required"
  usage
}

for cmd in jq gh curl base64 envsubst inkscape; do
  command -v "$cmd" >/dev/null || {
    echo "missing: $cmd" >&2
    exit 127
  }
done

TMP=$(mktemp -d)
function cleanup { rm -rf "$TMP"; }
trap cleanup EXIT

mkdir -p "${OUTPUT_DIR}" &>/dev/null || :

function logheader {
  printf '\n\033[1;36m╭─[ SETUP ]────────────────╴───╶╴──╶╴╴\033[0m\n'
  for var; do
    printf '\033[1;36m│\033[0m %-10s : \033[1m%s\033[0m\n' "$var" "${!var}"
  done
  printf '\033[1;36m╰─────────────────────────────────╴─╴─╴╴╴╴\033[0m\n'
}

function setup_fonts {
# TODO: ...
  mkdir -p ~/.fonts
  wget -O ~/.fonts/BungeeShade.ttf https://cdn.jsdelivr.net/fontsource/fonts/bungee-shade@latest/latin-400-normal.ttf
  wget -O ~/.fonts/Baloo2-Regular.ttf https://cdn.jsdelivr.net/fontsource/fonts/baloo-2@latest/latin-400-normal.ttf
  wget -O ~/.fonts/Baloo2-Bold.ttf https://cdn.jsdelivr.net/fontsource/fonts/baloo-2@latest/latin-700-normal.ttf
  fc-cache -f -v
}

function fetch_repo {
  local repo="$1"

  if $DEV; then
    jq -n --arg repo "$repo" \
      '{
         name:$repo,
         desc:"Everyone has the right to freedom of thought, opinion, conscience and expression religion; this right includes freedom to change his religion or belief, and freedom, either alone or in community with others and in public or private, to manifest his religion or belief in teaching, practice, worship and observance",
         lang:"Lua",
         star:42,
         fork:7
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

function printlogo {
  read -r img < <(curl -s "https://api.dicebear.com/9.x/${LOGO}&seed=$1" | base64 -w0)
  printf '<image x="0" y="0" width="96" height="96" href="data:image/svg+xml;base64,%s"/>\n' "$img"
}

function loadtheme {
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

function generate {
  IFS=$'\t' read -r name desc lang star fork < <(jq -r '[.name, .desc, .lang, .star, .fork] | @tsv' <<<"$1")

  logo="$(printlogo "${name}")"

  export name desc lang star fork logo

  for scheme in light dark; do
    echo "scheme $scheme"
    loadtheme "$scheme"
    filename="card_${name}_${scheme}"

    envsubst <templates/default.svg >"${TMP}/${filename}.svg"

    inkscape "${TMP}/${filename}.svg" \
      --export-dpi=300 \
      --export-type=png \
      --export-filename="./${OUTPUT_DIR}/${filename}.png"
  done
}

logheader TMP DEV OWNER REPOS OVERRIDES FONTS OUTPUT_DIR

for repo in $REPOS; do
  echo "processing $repo ..."
  generate "$(fetch_repo "$repo")"
done
