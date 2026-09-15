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

[ -d "$repository_root" ] || {
  printf 'repository root does not exist: %s\n' "$repository_root" >&2
  exit 2
}

command -v opencode >/dev/null 2>&1 || {
  printf 'opencode is not installed or not on PATH\n' >&2
  exit 127
}

case "$mode" in
  review)
    agent=plan
    guard='{"share":"disabled","lsp":false,"formatter":false,"agent":{"plan":{"tools":{"*":false,"read":true,"grep":true,"glob":true},"permission":{"*":"deny","read":{"*":"allow","*.env":"deny","*.env.*":"deny","*.pem":"deny","*.key":"deny"},"grep":"allow","glob":"allow"}}}}'
    ;;
  coding)
    agent=build
    guard='{"share":"disabled","lsp":false,"formatter":false,"agent":{"build":{"tools":{"*":false,"read":true,"grep":true,"glob":true,"edit":true,"bash":true},"permission":{"*":"deny","read":{"*":"allow","*.env":"deny","*.env.*":"deny","*.pem":"deny","*.key":"deny"},"grep":"allow","glob":"allow","edit":"allow","bash":"allow"}}}}'
    ;;
  *)
    usage
    ;;
esac

export OPENCODE_AUTO_SHARE=false
export OPENCODE_CONFIG_CONTENT=$guard

if [ -n "$session_id" ]; then
  exec opencode run --pure --format json \
    --agent "$agent" \
    --model "$model_id" \
    --dir "$repository_root" \
    --session "$session_id" \
    -- \
    "$prompt"
fi

exec opencode run --pure --format json \
  --agent "$agent" \
  --model "$model_id" \
  --dir "$repository_root" \
  -- \
  "$prompt"
