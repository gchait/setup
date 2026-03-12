(){
  local pkip="${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  [ -r "${pkip}" ] && source "${pkip}"
}

zle_highlight=("paste:none")

export EDITOR="vim"
export PAGER="less"
export HISTSIZE="4000"
export SAVEHIST="${HISTSIZE}"
export HISTFILE="${HOME}/.zsh_history"
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))

alias j="just"
alias d="docker"
alias g="git"

alias ls="eza -a --group-directories-first"
alias lt="ls -T --git-ignore"
alias ll="ls -l"
alias df="df -hT"
alias du="du -sh"
alias ff="fastfetch"
alias cat="bat --paging=never --style=plain"

precmd() {
  echo -ne "\033]0;${PWD##*/}\007"
}

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

jwtd() {
  if [ ! -t 0 ]; then
    local input=$(cat /dev/stdin)
  else
    >&2 echo "Missing piped input."
    return 2
  fi

  echo "${input}" | jq -Rrce 'split(".")[1] | . + "=" * (. | 4 - length % 4)' | \
    openssl base64 -d -A | jq
}

bindkey -e
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[[3~" delete-char

autoload -Uz compinit && compinit
zstyle ":completion:*" matcher-list "m:{a-z}={A-Za-z}"
setopt hist_ignore_all_dups

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source "${HOME}/.zsh/p10k/powerlevel10k.zsh-theme"
source "${HOME}/.p10k.zsh"
