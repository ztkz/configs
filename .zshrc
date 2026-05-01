if [[ -f "/usr/facebook/ops/rc/master.zshrc" ]]; then
  source /usr/facebook/ops/rc/master.zshrc
fi
if [[ -f "/etc/zprofile" ]]; then
  source /etc/zprofile
fi
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
source ~/.zshrc.omz
source ~/.zshrc.my
if [[ -f "~/.zshrc.my.meta-devs" ]]; then
  source ~/.zshrc.my.meta-devs
fi
if [[ -f "~/.zshrc.my.mac" ]]; then
  source ~/.zshrc.my.mac
fi
