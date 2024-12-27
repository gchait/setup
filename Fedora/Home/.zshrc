instant_prompt="${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
[ -r "${instant_prompt}" ] && source "${instant_prompt}"

fpath=("${HOME}/.zsh/complete/src" "${fpath[@]}")
zle_highlight=("paste:none")

export EDITOR="vim"
export PAGER="less"
export HISTSIZE="4000"
export SAVEHIST="${HISTSIZE}"
export HISTFILE="${HOME}/.zsh_history"
export IS_WSL="$(uname -r | grep -qi wsl && echo 1 || echo 0)"

if [ "${IS_WSL}" = "1" ]; then
  export BROWSER="/mnt/c/Program Files/Mozilla Firefox/firefox.exe"
  
  export PATH=$(echo "${HOME}/.local/bin:${PATH}" | \
    sed -E "s|:[^:]+/games||g" | sed -E "s|:[^:]+/WindowsApps||" | \
    sed -E "s|:[^:]+/System32/OpenSSH/||" | sed -E "s|:[^:]+/System32/Wbem||")
fi

precmd() {
  echo -ne "\033]0;${PWD##*/}\007"
}

up() {
  sudo dnf update -y
  [ "${IS_WSL}" = "0" ] || scoop update -a
}

upp() {
  curl -sL guyc.at/fedora.sh | bash -ex
  [ "${IS_WSL}" = "0" ] || powershell.exe "irm https://guyc.at/windows.ps1 | iex"
}

__set_wsl_display() {
  host=$(ip r | grep "/20 dev eth0" | cut -d"/" -f1 | sed "s/.0$/.1/")
  if nc -zw1 "${host}" 6000; then
    export DISPLAY="${host}:0.0"
    export XCURSOR_SIZE="$(( $(xrandr | grep '0\.00\*' | awk '{print $1}' | cut -d'x' -f2) / 27 ))"
  else
    >&2 echo "X server is not running."
    return 1
  fi
}

ij() {
  [ "${IS_WSL}" = "1" ] && [ -z "${DISPLAY}" ] && __set_wsl_display
  (/opt/idea/bin/idea "${HOME}/Projects" &> /dev/null &)
}

explorer() {
  if [ "${IS_WSL}" = "1" ] && command -v explorer.exe &> /dev/null; then
    (cd "${1:-$HOME}" && explorer.exe .)
  fi
}

awsp() {
  if [ -z "${1}" ]; then
    echo "${AWS_PROFILE}"
  else
    export AWS_PROFILE="${1}"
  fi
}

ec2-ls() {
  echo
  aws ec2 describe-instances --output text \
    --filters "Name=tag:Name,Values=*${1:-*}*" "Name=instance-state-name,Values=running" \
    --query 'Reservations[].Instances[].{id:InstanceId,ip:PrivateIpAddress,name:Tags[?Key==`Name`]|[0].Value}'
}

alias j="just"
alias d="docker"
alias k="kubectl"
alias c="code"
alias g="git"

alias cat="bat --paging=never --style=plain"
alias ls="eza -a --group-directories-first"
alias lt="ls -T --git-ignore"
alias ll="ls -l"
alias df="df -hT"
alias du="du -sh"

alias ff="fastfetch -c paleofetch.jsonc"
alias asso="aws sso login > /dev/null"

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

[ -r "${HOME}/.hidden_zshrc" ] && source "${HOME}/.hidden_zshrc"
source "${HOME}/.p10k.zsh"
