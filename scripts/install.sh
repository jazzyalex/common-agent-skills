#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
skills_root="$repo_root/skills"
user_home=${HOME:?HOME must be set}

install_link() {
  source_path=$1
  target_path=$2
  target_parent=$(dirname -- "$target_path")

  mkdir -p "$target_parent"

  if [ -L "$target_path" ]; then
    current_target=$(readlink "$target_path")
    if [ "$current_target" = "$source_path" ]; then
      printf 'already linked: %s\n' "$target_path"
      return
    fi
    printf 'refusing to replace different symlink: %s -> %s\n' "$target_path" "$current_target" >&2
    return 1
  fi

  if [ -e "$target_path" ]; then
    printf 'refusing to replace existing path: %s\n' "$target_path" >&2
    return 1
  fi

  ln -s "$source_path" "$target_path"
  printf 'linked: %s -> %s\n' "$target_path" "$source_path"
}

for skill_path in "$skills_root"/*; do
  [ -d "$skill_path" ] || continue
  [ -f "$skill_path/SKILL.md" ] || continue
  skill_name=$(basename -- "$skill_path")

  install_link "$skill_path" "$user_home/.codex/skills/$skill_name"
  install_link "$skill_path" "$user_home/.claude/skills/$skill_name"
  install_link "$skill_path" "$user_home/.agents/skills/$skill_name"
done
