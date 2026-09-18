#!/bin/sh
set -eu

usage() {
  printf 'usage: %s <review|coding> <model-id> <repository-root> <low|default|high> <prompt> [session-id]\n' "$0" >&2
  exit 2
}

[ "$#" -eq 5 ] || [ "$#" -eq 6 ] || usage

mode=$1
model_id=$2
repository_root=$3
effort=$4
prompt=$5
session_id=${6-}

[ -d "$repository_root" ] || {
  printf 'repository root does not exist: %s\n' "$repository_root" >&2
  exit 2
}

command -v cline >/dev/null 2>&1 || {
  printf 'cline is not installed or not on PATH\n' >&2
  exit 127
}

case "$model_id" in
  cline-free/deepseek-v4.1-flash|cline-free/muse-spark-1.3-contributor|z-ai/glm-5.3-flash)
    ;;
  *)
    printf 'model is not allowed by this skill: %s\n' "$model_id" >&2
    exit 2
    ;;
esac

case "$effort" in
  low|high)
    set -- --thinking "$effort"
    ;;
  default)
    set --
    ;;
  *)
    usage
    ;;
esac

case "$mode" in
  review)
    timeout=${CLINE_WORKER_TIMEOUT:-300}
    system_prompt='You are a bounded read-only code reviewer. Use only material in the user prompt, do not call tools, follow the requested output format, and distinguish evidence from uncertainty.'
    mode_args='--plan --auto-approve false'
    export CLINE_COMMAND_PERMISSIONS='{"allow":[],"deny":["*"]}'
    ;;
  coding)
    timeout=${CLINE_WORKER_TIMEOUT:-900}
    system_prompt='You are a bounded coding worker in a disposable checkout. Change only authorized files, run only relevant local checks, do not use network or browser tools, do not alter Git history, and do not commit or publish.'
    mode_args='--auto-approve true'
    export CLINE_COMMAND_PERMISSIONS='{"deny":["git*","gh*","curl*","wget*","ssh*","scp*","rsync*","sudo*","rm -rf*","open*"]}'
    ;;
  *)
    usage
    ;;
esac

export CLINE_SESSION_BACKEND_MODE=local

# The mode arguments are fixed strings controlled above.
# shellcheck disable=SC2086
if [ -n "$session_id" ]; then
  exec cline "$prompt" $mode_args --json \
    --cwd "$repository_root" \
    --provider cline \
    --model "$model_id" \
    --system "$system_prompt" \
    --retries 1 \
    --timeout "$timeout" \
    --id "$session_id" \
    "$@"
fi

# shellcheck disable=SC2086
exec cline "$prompt" $mode_args --json \
  --cwd "$repository_root" \
  --provider cline \
  --model "$model_id" \
  --system "$system_prompt" \
  --retries 1 \
  --timeout "$timeout" \
  "$@"
