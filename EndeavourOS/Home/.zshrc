source "${HOME}/.common.zsh"

alias ff="fastfetch"
alias pkmn="krabby random 1,3 --no-title --no-regional --no-gmax"

up() {
  yay -Syu --noconfirm
}

upp() {
  sh "${HOME}/Projects/setup/EndeavourOS/prepare.sh"
}

ij() {
  if [ -x /usr/bin/idea ]; then
    (/usr/bin/idea "${1:-${HOME}/Projects}" &> /dev/null &)
  else
    >&2 echo "IntelliJ not found."
    return 2
  fi
}

autoload -Uz compinit && compinit
zstyle ":completion:*" matcher-list "m:{a-z}={A-Za-z}"

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source "${HOME}/.zsh/p10k/powerlevel10k.zsh-theme"
source "${HOME}/.p10k.zsh"
pkmn
