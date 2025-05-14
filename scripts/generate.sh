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

TMP=$(mktemp -d)
function cleanup { rm -rf "$TMP"; }
trap cleanup EXIT

mkdir "${OUTPUT_DIR}" &>/dev/null || :

echo "tmp        : $TMP"
echo "DEV        : $DEV"
echo "OWNER      : $OWNER"
echo "REPOS      : $REPOS"
echo "OVERRIDES  : $OVERRIDES"
echo "OUTPUT_DIR : $OUTPUT_DIR"

function fetch_repo {
  local repo="$1"

  if $DEV; then
    jq -n --arg repo "$repo" '{name:$repo,desc:"Mock description",lang:"JavaScript",star:42,fork:7}'
    return
  fi

  gh repo view "$OWNER/$repo" --json name,description,primaryLanguage,stargazerCount,forkCount \
    --jq '{
            name: .name,
            desc: (.description // "—"),
            lang: (.primaryLanguage.name // "n/a"),
            star: .stargazerCount,
            fork: .forkCount
          }'
}

function printlogo {
  read -r img < <(curl -s "https://api.dicebear.com/9.x/glass/svg?backgroundType=gradientLinear&radius=20&seed=$1" | base64 -w0)
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

for repo in $REPOS; do
  echo "processing $repo ..."
  generate "$(fetch_repo "$repo")"
done
