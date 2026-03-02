# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export HISTCONTROL=ignoredups
HISTSIZE=-1
HISTFILESIZE=-1

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias vi='vim'
