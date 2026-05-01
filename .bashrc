[[ $- != *i* ]] && return

if [[ -f "/etc/bashrc" ]]; then
  source /etc/bashrc
fi
if [[ -f "/usr/facebook/ops/rc/master.bashrc" ]]; then
  source /usr/facebook/ops/rc/master.bashrc
fi

HISTSIZE=-1
HISTFILESIZE=-1
HISTCONTROL=erasedups

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias vi='vim'

if [[ -f "$HOME/.config/my_scripts/theme_shell_bootstrap.sh" ]]; then
    source "$HOME/.config/my_scripts/theme_shell_bootstrap.sh"
    if [[ "${PROMPT_COMMAND-}" != *theme_apply_current_tty_flavor* ]]; then
        PROMPT_COMMAND="theme_apply_current_tty_flavor${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
    fi
    theme_auto_bootstrap
fi
