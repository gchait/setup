alias ff="fastfetch"
ff
source "${HOME}/.common.zsh"

upp() {
  sh "${HOME}/Projects/setup/EndeavourOS/prepare.sh"
}

claudec() {
  local alt="${HOME}/.claude/settings.json.alt"
  local local_cfg="${HOME}/.claude/settings.json.local"
  local lockdir="${HOME}/.claude/.claudec_locks"

  if [ ! -f "${alt}" ]; then
    >&2 echo "settings.json.alt not found."
    return 1
  fi
  mkdir -p "${lockdir}"

  (
    lockfile=$(mktemp "${lockdir}/lock.XXXXXX")
    trap "rm -f ${lockfile}; remaining=\$(ls -A ${lockdir} 2>/dev/null); [ -z \"\$remaining\" ] && ln -sf ${local_cfg} ${HOME}/.claude/settings.json" EXIT
    ln -sf "${alt}" "${HOME}/.claude/settings.json"
    claude "$@"
  )
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

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source "${HOME}/.zsh/p10k/powerlevel10k.zsh-theme"
source "${HOME}/.p10k.zsh"
