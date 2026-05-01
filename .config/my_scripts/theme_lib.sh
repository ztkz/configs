#!/usr/bin/env bash

theme_file="${HOME}/.config/shell_theme"
theme_auto_config="${HOME}/.config/my_scripts/theme_auto.conf"
theme_auto_helper="${HOME}/.config/my_scripts/theme_by_sun.py"
theme_tty_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/theme_tty_state"

theme_read_current_flavor() {
  if [[ -r "${theme_file}" ]]; then
    local stored
    stored="$(tr -d '[:space:]' < "${theme_file}")"
    case "${stored}" in
      latte|frappe|macchiato|mocha)
        printf '%s\n' "${stored}"
        return 0
        ;;
      light)
        printf 'latte\n'
        return 0
        ;;
      dark)
        printf 'frappe\n'
        return 0
        ;;
    esac
  fi

  printf 'frappe\n'
}

theme_mode_to_flavor() {
  case "$1" in
    light)
      printf 'latte\n'
      ;;
    dark)
      printf 'frappe\n'
      ;;
    latte|frappe|macchiato|mocha)
      printf '%s\n' "$1"
      ;;
    *)
      return 1
      ;;
  esac
}

theme_load_auto_env() {
  local env_lat="${THEME_LATITUDE-}"
  local env_lon="${THEME_LONGITUDE-}"

  if [[ -r "${theme_auto_config}" ]]; then
    # shellcheck disable=SC1090
    source "${theme_auto_config}"
  fi

  export THEME_LATITUDE="${THEME_LATITUDE:-${env_lat}}"
  export THEME_LONGITUDE="${THEME_LONGITUDE:-${env_lon}}"
}

theme_resolve_auto_flavor() {
  theme_load_auto_env

  if [[ -z "${THEME_LATITUDE}" || -z "${THEME_LONGITUDE}" ]]; then
    theme_read_current_flavor
    return 0
  fi

  local mode
  mode="$("${theme_auto_helper}" 2>/dev/null || true)"
  theme_mode_to_flavor "${mode}" || theme_read_current_flavor
}

theme_resolve_flavor() {
  case "$1" in
    auto)
      theme_resolve_auto_flavor
      ;;
    *)
      theme_mode_to_flavor "$1"
      ;;
  esac
}

theme_persist_flavor() {
  mkdir -p "$(dirname "${theme_file}")"
  printf '%s\n' "$1" > "${theme_file}"
}

theme_terminal_key() {
  local key=""

  if [[ -n "${TMUX-}" ]] && command -v tmux >/dev/null 2>&1; then
    key="$(tmux display-message -p '#{client_tty}' 2>/dev/null || true)"
  fi

  if [[ -z "${key}" && -n "${SSH_TTY-}" ]]; then
    key="${SSH_TTY}"
  fi

  if [[ -z "${key}" ]]; then
    key="$(tty 2>/dev/null || true)"
  fi

  case "${key}" in
    ""|"not a tty")
      return 1
      ;;
  esac

  printf '%s\n' "${key}"
}

theme_tty_cache_file() {
  local key="$1"
  local checksum

  checksum="$(printf '%s' "${key}" | cksum | awk '{print $1}')"
  mkdir -p "${theme_tty_cache_dir}"
  printf '%s/%s\n' "${theme_tty_cache_dir}" "${checksum}"
}

theme_read_terminal_flavor() {
  local key
  local cache_file

  key="$(theme_terminal_key)" || return 1
  cache_file="$(theme_tty_cache_file "${key}")"
  [[ -r "${cache_file}" ]] || return 1
  tr -d '[:space:]' < "${cache_file}"
}

theme_record_terminal_flavor() {
  local key
  local cache_file

  key="$(theme_terminal_key)" || return 1
  cache_file="$(theme_tty_cache_file "${key}")"
  printf '%s\n' "$1" > "${cache_file}"
}
