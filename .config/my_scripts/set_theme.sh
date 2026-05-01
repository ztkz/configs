#!/usr/bin/env bash

set -euo pipefail

source "${HOME}/.config/my_scripts/theme_lib.sh"

usage() {
  echo "Usage: $0 [light|dark|auto]" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

flavor="$(theme_resolve_flavor "$1")" || {
  usage
  exit 1
}

theme_persist_flavor "${flavor}"

if [[ -z "${THEME_SKIP_SHELL_APPLY-}" ]]; then
  sh "${HOME}/.config/my_scripts/catppuccin_shell_theme.sh" "${flavor}"
  theme_record_terminal_flavor "${flavor}" >/dev/null 2>&1 || true
fi

if command -v tmux >/dev/null 2>&1; then
  bash "${HOME}/.tmux/catppuccin-reset.sh" >/dev/null 2>&1 || true
  tmux set -g @catppuccin_flavor "${flavor}" >/dev/null 2>&1 || true
  tmux source-file "${HOME}/.tmux/catppuccin-options.conf" >/dev/null 2>&1 || true
  bash "${HOME}/.tmux/plugins/tmux/catppuccin.tmux" >/dev/null 2>&1 || true
fi
