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

# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/artem/.mujoco/mjpro150/bin
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/artem/.mujoco/mujoco200/bin

alias vi='vim'
alias sudo='sudo '

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/artem/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/artem/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/artem/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/artem/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

