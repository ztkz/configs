#
# ~/.bashrc
#

########################
# exec fish
########################


# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
alias subl='subl3'

# TODO DELETE
XDG_CONFIG_HOME=$HOME/.config
XDG_CACHE_HOME=$HOME/.cache
XDG_DATA_HOME=$HOME/.local/share

source /usr/share/bash-completion/bash_completion
source /usr/share/doc/pkgfile/command-not-found.bash
export HISTCONTROL=ignoredups

HISTSIZE=-1
HISTFILESIZE=-1

# powerline-daemon -q
# POWERLINE_BASH_CONTINUATION=1
# POWERLINE_BASH_SELECT=1
# . /usr/lib/python3.6/site-packages/powerline/bindings/bash/powerline.sh

# Colors
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ls='ls --color=auto'
# export PATH=/usr/lib/cw:$PATH

# Confirmation
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Other
alias reboot='systemctl reboot'

# fer
export FBFONT=/usr/share/kbd/consolefonts/ter-216n.psf.gz

# Base16
# BASE16_SHELL=$HOME/.config/base16-shell/
# [ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"

alias vi='vim'
alias sudo='sudo '
