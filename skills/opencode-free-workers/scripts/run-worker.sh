#!/bin/sh
set -eu

usage() {
  printf 'usage: %s <review|coding> <model-id> <repository-root> <prompt> [session-id]\n' "$0" >&2
  exit 2
}

[ "$#" -eq 4 ] || [ "$#" -eq 5 ] || usage

mode=$1
model_id=$2
repository_root=$3
prompt=$4
session_id=${5-}
variant=${OPENCODE_WORKER_VARIANT-}

[ -d "$repository_root" ] || {
  printf 'repository root does not exist: %s\n' "$repository_root" >&2
  exit 2
}

command -v opencode >/dev/null 2>&1 || {
  printf 'opencode is not installed or not on PATH\n' >&2
  exit 127
}

case "$variant" in
  ''|minimal|low|medium|high|xhigh)
    ;;
  *)
    printf 'unsupported OpenCode worker variant: %s\n' "$variant" >&2
    exit 2
    ;;
esac

if [ "$variant" = xhigh ] && [ "$model_id" != opencode/muse-spark-1.3-contributor-free ]; then
  printf 'xhigh is verified only for OpenCode Muse Spark 1.3: %s\n' "$model_id" >&2
  exit 2
fi

if [ -n "$variant" ]; then
  set -- --variant "$variant"
else
  set --
fi

if [ -n "${OPENCODE_WORKER_AUTO-}" ]; then
  printf 'OPENCODE_WORKER_AUTO is unsupported; stage external inputs inside the repository root instead\n' >&2
  exit 2
fi

case "$mode" in
  review)
    agent=plan
    ;;
  coding)
    agent=build
    ;;
  *)
    usage
    ;;
esac

export OPENCODE_AUTO_SHARE=false

if [ -n "$session_id" ]; then
  exec opencode run --format json \
    --agent "$agent" \
    --model "$model_id" \
    --dir "$repository_root" \
    --session "$session_id" \
    "$@" \
    -- \
    "$prompt"
fi

exec opencode run --format json \
  --agent "$agent" \
  --model "$model_id" \
  --dir "$repository_root" \
  "$@" \
  -- \
  "$prompt"
