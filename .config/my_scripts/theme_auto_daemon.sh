#!/usr/bin/env bash

set -euo pipefail

theme_auto_config="${HOME}/.config/my_scripts/theme_auto.conf"
theme_auto_helper="${HOME}/.config/my_scripts/theme_by_sun.py"
set_theme_script="${HOME}/.config/my_scripts/set_theme.sh"

load_theme_auto_env() {
  local env_lat="${THEME_LATITUDE-}"
  local env_lon="${THEME_LONGITUDE-}"

  if [[ -r "${theme_auto_config}" ]]; then
    # shellcheck disable=SC1090
    source "${theme_auto_config}"
  fi

  export THEME_LATITUDE="${THEME_LATITUDE:-${env_lat}}"
  export THEME_LONGITUDE="${THEME_LONGITUDE:-${env_lon}}"
}

next_sleep_seconds() {
  if [[ -z "${THEME_LATITUDE-}" || -z "${THEME_LONGITUDE-}" ]]; then
    printf '3600\n'
    return 0
  fi

  local seconds
  seconds="$("${theme_auto_helper}" --next-check-seconds 2>/dev/null || true)"
  if [[ "${seconds}" =~ ^[0-9]+$ ]] && (( seconds >= 60 )); then
    printf '%s\n' "${seconds}"
    return 0
  fi

  printf '300\n'
}

while true; do
  load_theme_auto_env
  THEME_SKIP_SHELL_APPLY=1 "${set_theme_script}" auto >/dev/null 2>&1 || true
  sleep "$(next_sleep_seconds)"
done
