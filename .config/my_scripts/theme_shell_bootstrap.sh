if [[ -f "$HOME/.config/my_scripts/theme_lib.sh" ]]; then
  # shellcheck disable=SC1090
  source "$HOME/.config/my_scripts/theme_lib.sh"
fi

theme_apply_current_tty_flavor() {
  local shell_theme_script="$HOME/.config/my_scripts/catppuccin_shell_theme.sh"
  local flavor
  local cached_flavor

  [[ -f "$shell_theme_script" && -r "$theme_file" ]] || return 0

  flavor="$(theme_read_current_flavor)"

  if [[ "${THEME_TTY_APPLIED_FLAVOR-}" == "$flavor" ]]; then
    return 0
  fi

  if cached_flavor="$(theme_read_terminal_flavor 2>/dev/null)"; then
    if [[ "${cached_flavor}" == "${flavor}" ]]; then
      export THEME_TTY_APPLIED_FLAVOR="${flavor}"
      return 0
    fi
  fi

  sh "$shell_theme_script" "$flavor" >/dev/null 2>&1 || return 0
  theme_record_terminal_flavor "${flavor}" >/dev/null 2>&1 || true
  export THEME_TTY_APPLIED_FLAVOR="${flavor}"
}

theme_sync_auto_state() {
  local set_theme_script="$HOME/.config/my_scripts/set_theme.sh"
  local target_flavor
  local current_flavor

  [[ -x "$set_theme_script" ]] || return 0

  target_flavor="$(theme_resolve_auto_flavor)" || return 0
  current_flavor="$(theme_read_current_flavor)"

  if [[ ! -r "${theme_file}" || "${target_flavor}" != "${current_flavor}" ]]; then
    THEME_SKIP_SHELL_APPLY=1 "$set_theme_script" "${target_flavor}" >/dev/null 2>&1 || true
  fi
}

theme_auto_bootstrap() {
  local daemon_script="$HOME/.config/my_scripts/theme_auto_daemon.sh"

  theme_sync_auto_state

  theme_apply_current_tty_flavor

  if [[ ! -x "$daemon_script" ]]; then
    return 0
  fi

  if command -v pgrep >/dev/null 2>&1 && pgrep -u "$USER" -f "$daemon_script" >/dev/null 2>&1; then
    return 0
  fi

  nohup "$daemon_script" >/dev/null 2>&1 </dev/null &
}
