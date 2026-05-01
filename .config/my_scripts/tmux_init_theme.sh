#!/usr/bin/env bash

set -euo pipefail

source "${HOME}/.config/my_scripts/theme_lib.sh"

daemon_script="${HOME}/.config/my_scripts/theme_auto_daemon.sh"
flavor="$(theme_resolve_auto_flavor)"

theme_persist_flavor "${flavor}"
tmux set -gq @catppuccin_flavor "${flavor}"

if [[ -x "${daemon_script}" ]] && command -v pgrep >/dev/null 2>&1; then
  if ! pgrep -u "$USER" -f "${daemon_script}" >/dev/null 2>&1; then
    nohup "${daemon_script}" >/dev/null 2>&1 </dev/null &
  fi
fi
