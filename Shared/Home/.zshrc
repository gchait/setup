source "${HOME}/.common.zsh"

fpath=("${HOME}/.zsh/complete/src" "${fpath[@]}")

IS_WSL=$(uname -r | grep -qi wsl && echo 1 || echo 0)
__scoop_update_expr() { :; }
[ "${IS_WSL}" = "1" ] && source "${HOME}/.wsl.zsh"

alias k="kubectl"
alias c="code"
alias ff="fastfetch -c paleofetch.jsonc"

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
  local pkg_cmd
  if command -v dnf &> /dev/null; then
    pkg_cmd="sudo dnf update -yq"
  else
    pkg_cmd="sudo apt-get update -q && sudo apt-get upgrade -yq"
  fi
  __dual_run "$(__scoop_update_expr)" "${pkg_cmd}"
}

upp() {
  local distro
  distro=$(grep "^ID=" /etc/os-release | cut -d= -f2)
  __dual_run \
    "${HOME}/setup/Windows/prepare.ps1" \
    "${HOME}/setup/${(C)distro}/prepare.sh"
}

ij() {
  if [ "${IS_WSL}" = "1" ] && [ -z "${DISPLAY}" ]; then
    __set_wsl_display || return "${?}"
  fi

  if [ -x /opt/idea/bin/idea ]; then
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
  >&2 echo
  aws ec2 describe-instances --output text \
    --filters "Name=tag:Name,Values=*${1:-*}*" "Name=instance-state-name,Values=running" \
    --query 'Reservations[].Instances[].{id:InstanceId,ip:PrivateIpAddress,name:Tags[?Key==`Name`]|[0].Value}'
}

autoload -Uz compinit && compinit
zstyle ":completion:*" matcher-list "m:{a-z}={A-Za-z}"
setopt hist_ignore_all_dups

source "${HOME}/.zsh/highlight/zsh-syntax-highlighting.zsh"
source "${HOME}/.zsh/suggest/zsh-autosuggestions.zsh"
source "${HOME}/.zsh/p10k/powerlevel10k.zsh-theme"
source "${HOME}/.p10k.zsh"
