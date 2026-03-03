#!/bin/sh
# Apply Catppuccin iTerm colors (ANSI 0-15 + iTerm extra colors) via escape sequences.
# Usage: source this file, then run: catppuccin_apply [latte|frappe|macchiato|mocha]
# You can also auto-apply on SSH by adding the last block to your shell rc.

catppuccin_apply() {
  flavor="${1:-mocha}"

  [ -t 1 ] || return 0
  case "${TERM-}" in
    dumb) return 0 ;;
  esac

  osc() {
	if [ -n "${TMUX-}" ]; then
	  printf '\033Ptmux;\033\033]%s\007\033\\' "$1"
	else
	  printf '\033]%s\007' "$1"
	fi
  }

  hex_to_rgb() {
    h="${1#\#}"
    rr="${h%????}"
    gg="${h#??}"; gg="${gg%??}"
    bb="${h#????}"
    printf 'rgb:%s/%s/%s' "$rr" "$gg" "$bb"
  }

  black= red= green= yellow= blue= magenta= cyan= white=
  br_black= br_red= br_green= br_yellow= br_blue= br_magenta= br_cyan= br_white=
  fg= bg= bold= link= selbg= selfg= curbg= curfg=

  case "$flavor" in
  latte)
    black='#5c5f77'
    red='#d20f39'
    green='#40a02b'
    yellow='#df8e1d'
    blue='#1e66f5'
    magenta='#ea76cb'
    cyan='#179299'
    white='#acb0be'
    br_black='#6c6f85'
    br_red='#de293e'
    br_green='#49af3d'
    br_yellow='#eea02d'
    br_blue='#456eff'
    br_magenta='#fe85d8'
    br_cyan='#2d9fa8'
    br_white='#bcc0cc'
    fg='#4c4f69'
    bg='#eff1f5'
    bold='#4c4f69'
    link='#04a5e5'
    selbg='#acb0be'
    selfg='#4c4f69'
    curbg='#dc8a78'
    curfg='#eff1f5'
    ;;
  frappe)
    black='#51576d'
    red='#e78284'
    green='#a6d189'
    yellow='#e5c890'
    blue='#8caaee'
    magenta='#f4b8e4'
    cyan='#81c8be'
    white='#a5adce'
    br_black='#626880'
    br_red='#e16f72'
    br_green='#8ec772'
    br_yellow='#d9ba73'
    br_blue='#7b9ef0'
    br_magenta='#f2a0dd'
    br_cyan='#5ac0aa'
    br_white='#b5bfe2'
    fg='#c6d0f5'
    bg='#303446'
    bold='#c6d0f5'
    link='#99d1db'
    selbg='#626880'
    selfg='#c6d0f5'
    curbg='#f2d5cf'
    curfg='#303446'
    ;;
  macchiato)
    black='#494d64'
    red='#ed8796'
    green='#a6da95'
    yellow='#eed49f'
    blue='#8aadf4'
    magenta='#f5bde6'
    cyan='#8bd5ca'
    white='#a5adcb'
    br_black='#5b6078'
    br_red='#ec7486'
    br_green='#8cd88a'
    br_yellow='#e1c07d'
    br_blue='#78a1f6'
    br_magenta='#f2a6df'
    br_cyan='#63cbc0'
    br_white='#b8c0e0'
    fg='#cad3f5'
    bg='#24273a'
    bold='#cad3f5'
    link='#91d7e3'
    selbg='#5b6078'
    selfg='#cad3f5'
    curbg='#f4dbd6'
    curfg='#24273a'
    ;;
  mocha)
    black='#45475a'
    red='#f38ba8'
    green='#a6e3a1'
    yellow='#f9e2af'
    blue='#89b4fa'
    magenta='#f5c2e7'
    cyan='#94e2d5'
    white='#a6adc8'
    br_black='#585b70'
    br_red='#f37799'
    br_green='#89d88b'
    br_yellow='#ebd391'
    br_blue='#74a8fc'
    br_magenta='#f2aede'
    br_cyan='#6bd7ca'
    br_white='#bac2de'
    fg='#cdd6f4'
    bg='#1e1e2e'
    bold='#cdd6f4'
    link='#89dceb'
    selbg='#585b70'
    selfg='#cdd6f4'
    curbg='#f5e0dc'
    curfg='#1e1e2e'
    ;;
    *)
      echo "Unknown flavor: ${flavor}"
      return 1
      ;;
  esac

  # --- Standard-ish xterm OSC sequences (widest compatibility) ---
  osc "10;$(hex_to_rgb "$fg")"
  osc "11;$(hex_to_rgb "$bg")"
  osc "12;$(hex_to_rgb "$curbg")"
  osc "17;$(hex_to_rgb "$selbg")"
  osc "19;$(hex_to_rgb "$selfg")"

  # Set palette indices 0-15 (ANSI colors) via OSC 4.
  osc "4;0;$(hex_to_rgb "$black")"
  osc "4;1;$(hex_to_rgb "$red")"
  osc "4;2;$(hex_to_rgb "$green")"
  osc "4;3;$(hex_to_rgb "$yellow")"
  osc "4;4;$(hex_to_rgb "$blue")"
  osc "4;5;$(hex_to_rgb "$magenta")"
  osc "4;6;$(hex_to_rgb "$cyan")"
  osc "4;7;$(hex_to_rgb "$white")"
  osc "4;8;$(hex_to_rgb "$br_black")"
  osc "4;9;$(hex_to_rgb "$br_red")"
  osc "4;10;$(hex_to_rgb "$br_green")"
  osc "4;11;$(hex_to_rgb "$br_yellow")"
  osc "4;12;$(hex_to_rgb "$br_blue")"
  osc "4;13;$(hex_to_rgb "$br_magenta")"
  osc "4;14;$(hex_to_rgb "$br_cyan")"
  osc "4;15;$(hex_to_rgb "$br_white")"

  strip_hash() { printf '%s' "${1#\#}"; }

  # --- iTerm2 "SetColors" (OSC 1337) for the extra fields ---
  osc "1337;SetColors=fg=$(strip_hash "$fg")"
  osc "1337;SetColors=bg=$(strip_hash "$bg")"
  osc "1337;SetColors=bold=$(strip_hash "$bold")"
  osc "1337;SetColors=link=$(strip_hash "$link")"
  osc "1337;SetColors=selbg=$(strip_hash "$selbg")"
  osc "1337;SetColors=selfg=$(strip_hash "$selfg")"
  osc "1337;SetColors=curbg=$(strip_hash "$curbg")"
  osc "1337;SetColors=curfg=$(strip_hash "$curfg")"

  osc "1337;SetColors=black=$(strip_hash "$black")"
  osc "1337;SetColors=red=$(strip_hash "$red")"
  osc "1337;SetColors=green=$(strip_hash "$green")"
  osc "1337;SetColors=yellow=$(strip_hash "$yellow")"
  osc "1337;SetColors=blue=$(strip_hash "$blue")"
  osc "1337;SetColors=magenta=$(strip_hash "$magenta")"
  osc "1337;SetColors=cyan=$(strip_hash "$cyan")"
  osc "1337;SetColors=white=$(strip_hash "$white")"
  osc "1337;SetColors=br_black=$(strip_hash "$br_black")"
  osc "1337;SetColors=br_red=$(strip_hash "$br_red")"
  osc "1337;SetColors=br_green=$(strip_hash "$br_green")"
  osc "1337;SetColors=br_yellow=$(strip_hash "$br_yellow")"
  osc "1337;SetColors=br_blue=$(strip_hash "$br_blue")"
  osc "1337;SetColors=br_magenta=$(strip_hash "$br_magenta")"
  osc "1337;SetColors=br_cyan=$(strip_hash "$br_cyan")"
  osc "1337;SetColors=br_white=$(strip_hash "$br_white")"
}

catppuccin_apply $1
