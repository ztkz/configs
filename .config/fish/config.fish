set -g theme_nerd_fonts yes
# set -g theme_color_scheme solarized-dark  # Use theme_dark instead.
# set -g theme_title_display_process yes
set -g theme_show_exit_status yes
# set -g theme_git_worktree_support yes
set -g fish_prompt_pwd_dir_length 1

# set -g fish_term24bit 1

set -U EDITOR vim
# set -U TERM xterm-256color

alias hr 'history --merge'  # read and merge history from disk

# set fish_plugins
#
# TODO vi-mode tmux-zen fzf cd bang-bang weather z
# TODO updates
# TODO tacklebox

# omf install virtualfish sublime python pbcopy lucky colorman extract grc

set -gx PATH /home/artem/.local/bin $PATH

eval (python -m virtualfish)
# set -x WORKON_HOME ~/.virtualenvs
# bash /usr/bin/virtualenvwrapper.sh

# Base16 Shell
# if status --is-interactive
#   source $HOME/.config/base16-shell/profile_helper.fish
# end
source $HOME/.config/base16-shell/profile_helper.fish

# Verbose
alias rm "rm -vi"
alias chmod "chmod -v"
alias chown "chown -v"
alias mount "mount -v"
alias umount "umount -v"
alias mv 'mv -vi'
alias cp 'cp -vi'
alias mkdir 'mkdir -v'

alias sctlr 'systemctl reboot'
alias sctlp 'systemctl poweroff'
alias sctls 'systemctl suspend'
alias sctlh 'systemctl hibernate'

umask 027

source ~/.config/fish/current_theme.fish

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /home/artem/anaconda3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<

