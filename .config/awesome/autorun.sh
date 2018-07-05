#!/usr/bin/env bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

setxkbmap -layout "us,ru" -option "grp:win_space_toggle"
setxkbmap -layout "us,ru" -option "grp:alt_shift_toggle"
xmodmap -e 'clear Lock' #ensures you're not stuck in CAPS on mode
xmodmap -e 'keycode 0x42=Escape' #remaps the keyboard so CAPS LOCK=ESC

if [[ $(hostname) == "PC0" ]]; then
  run /home/artem/Applications/Telegram/Telegram -startintray
  run /usr/bin/dropbox
  run mailru-cloud
  run caffeine
  run transmission-qt
fi
