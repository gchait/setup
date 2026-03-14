source "${HOME}/.common.zsh"

alias ff="fastfetch"

up() {
  yay -Syu
}

upp() {
  sh "${HOME}/Projects/setup/EndeavourOS/prepare.sh"
}

ij() {
  if [ -x /usr/bin/idea ]; then
    (/usr/bin/idea "${1:-$HOME/Projects}" &> /dev/null &)
  else
    >&2 echo "IntelliJ not found."
    return 2
  fi
}

autoload -Uz compinit && compinit
zstyle ":completion:*" matcher-list "m:{a-z}={A-Za-z}"
setopt hist_ignore_all_dups

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source "${HOME}/.zsh/p10k/powerlevel10k.zsh-theme"
source "${HOME}/.p10k.zsh"
