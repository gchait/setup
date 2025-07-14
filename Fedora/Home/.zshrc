(){
  local pkip="${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  [ -r "${pkip}" ] && source "${pkip}"
}

fpath=("${HOME}/.zsh/complete/src" "${fpath[@]}")
zle_highlight=("paste:none")

IS_WSL=$(uname -r | grep -qi wsl && echo 1 || echo 0)
[ "${IS_WSL}" = "1" ] && source "${HOME}/.wsl.zsh"

export EDITOR="vim"
export PAGER="less"
export HISTSIZE="4000"
export SAVEHIST="${HISTSIZE}"
export HISTFILE="${HOME}/.zsh_history"
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))

alias j="just"
alias d="docker"
alias k="kubectl"
alias c="code"
alias g="git"

alias ls="eza -a --group-directories-first"
alias lt="ls -T --git-ignore"
alias ll="ls -l"
alias df="df -hT"
alias du="du -sh"
alias ff="fastfetch -c paleofetch.jsonc"
alias cat="bat --paging=never --style=plain"

precmd() {
  echo -ne "\033]0;${PWD##*/}\007"
}

__dual_run() {
  if [ "${IS_WSL}" = "1" ]; then
    if [ -r "${1}" ]; then
      pwsh -c - < "${1}" &
    else
      pwsh -c "${1}" &
    fi
  fi

  if [ -r "${2}" ]; then
    sh < "${2}" &
  else
    sh -c "${2}" &
  fi

  wait
}

up() {
  __dual_run \
    "scoop update -a" \
    "sudo dnf update -yq"
}

upp() {
  __dual_run \
    "${HOME}/setup/Windows/prepare.ps1" \
    "${HOME}/setup/Fedora/prepare.sh"
}

ij() {
  if [ "${IS_WSL}" = "1" ] && [ -z "${DISPLAY}" ]; then
    __set_wsl_display || return "${?}"
  fi

  if [ -r /opt/idea/bin/idea ]; then
    (/opt/idea/bin/idea "${1:-$HOME/Projects}" &> /dev/null &)
  else
    >&2 echo "IntelliJ not found."
    return 2
  fi
}

awsp() {
  if [ -z "${1}" ]; then
    echo "${AWS_PROFILE}"
  else
    export AWS_PROFILE="${1}"
  fi
}

asso() {
  aws sso login | grep -E --color=never '^[A-Z]{4}-[A-Z]{4}$'
}

ec2() {
  echo
  aws ec2 describe-instances --output text \
    --filters "Name=tag:Name,Values=*${1:-*}*" "Name=instance-state-name,Values=running" \
    --query 'Reservations[].Instances[].{id:InstanceId,ip:PrivateIpAddress,name:Tags[?Key==`Name`]|[0].Value}'
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

source "${HOME}/.zsh/highlight/zsh-syntax-highlighting.zsh"
source "${HOME}/.zsh/suggest/zsh-autosuggestions.zsh"
source "${HOME}/.zsh/p10k/powerlevel10k.zsh-theme"
source "${HOME}/.p10k.zsh"
