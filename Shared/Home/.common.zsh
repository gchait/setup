# shellcheck disable=SC1072,SC1073
() {
  local pkip="${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  [ -r "${pkip}" ] && source "${pkip}"
}

zle_highlight=("paste:none")

export EDITOR="vim"
export PAGER="less"
export HISTSIZE="5000"
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
alias cat="bat --paging=never --style=plain"

precmd() {
  echo -ne "\033]0;${PWD##*/}\007"
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
