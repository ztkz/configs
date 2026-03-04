#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 [light|dark]" >&2
  exit 1
fi

case "$1" in
  light)
    flavor="latte"
    ;;
  dark)
    flavor="frappe"
    ;;
  *)
    echo "Invalid theme: $1 (expected: light or dark)" >&2
    exit 1
    ;;
esac

sh "$HOME/.config/my_scripts/catppuccin_shell_theme.sh" "${flavor}"

if command -v tmux >/dev/null 2>&1; then
  bash "$HOME/.tmux/catppuccin-reset.sh" >/dev/null 2>&1 || true
  tmux set -g @catppuccin_flavor "${flavor}" >/dev/null 2>&1 || true
  tmux source-file "$HOME/.tmux/catppuccin-options.conf" >/dev/null 2>&1 || true
  bash "$HOME/.tmux/plugins/tmux/catppuccin.tmux" >/dev/null 2>&1 || true
fi

printf '%s\n' "${flavor}" > "${HOME}/.config/shell_theme"
