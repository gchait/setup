instant_prompt="${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
[[ -r "${instant_prompt}" ]] && source "${instant_prompt}"

precmd() {
  echo -ne "\033]0;${PWD##*/}\007"
}

awsp() {
  if [ -z "${1}" ]; then
    echo "${AWS_PROFILE}"
  else
    export AWS_PROFILE="${1}"
  fi
}

fpath=("${HOME}/.zsh/complete/src" "${fpath[@]}")
zle_highlight=("paste:none")

export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE="4000"
export SAVEHIST="${HISTSIZE}"

export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0
export XCURSOR_SIZE=56
export BROWSER="/mnt/c/Program Files/Mozilla Firefox/firefox.exe"
export EDITOR="vim"
export PAGER="less"

alias ls="eza -a --group-directories-first"
alias lt="ls -T --git-ignore"
alias ll="ls -l"
alias df="df -hT"
alias du="du -sh"

alias j="just"
alias d="docker"
alias k="kubectl"
alias c="code"
alias g="git"

alias up="sudo dnf update -y && scoop update -a"
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

[[ -r "${HOME}/.hidden_zshrc" ]] && source "${HOME}/.hidden_zshrc"
[[ -r "${HOME}/.p10k.zsh" ]] && source "${HOME}/.p10k.zsh"
