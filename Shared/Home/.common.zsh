# shellcheck disable=SC1072,SC1073
() {
  local pkip="${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  [ -r "${pkip}" ] && source "${pkip}"
}

zle_highlight=("paste:none")
JAVA_HOME=$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")

export JAVA_HOME
export EDITOR="vim"
export PAGER="less"
export HISTSIZE="5000"
export SAVEHIST="${HISTSIZE}"
export HISTFILE="${HOME}/.zsh_history"

alias g="git"
alias j="just"
alias d="docker"

alias ls="eza -a --group-directories-first"
alias ll="ls -l"
alias lt="ls -T --git-ignore"

alias df="df -hT"
alias du="du -sh"

alias cat="bat --paging=never --style=plain"
alias grep="grep --color=auto"

precmd() {
  echo -ne "\033]0;${PWD##*/}\007"
}

jwtd() {
  if [ ! -t 0 ]; then
    local input
    input=$(cat /dev/stdin)
  else
    >&2 echo "Missing piped input."
    return 2
  fi

  echo "${input}" | jq -Rrce 'split(".")[1] | gsub("-";"+") | gsub("_";"/") | . + "=" * (. | (4 - length % 4) % 4)' |
    openssl base64 -d -A | jq
}

bassh() {
  local host="${1}"
  shift
  ssh -to LogLevel=QUIET "${host}" "bash -ic ${(q)${(j: :)@}}"
}

whoisip() {
  local ip="${1:-$(curl -s ifconfig.me)}"
  whois -L "${ip}" | awk -F': *' '
    function ip2int(ip,    a) {
      split(ip, a, ".")
      return a[1] * 16777216 + a[2] * 65536 + a[3] * 256 + a[4]
    }
    function cidr_of(startip, endip,    s, e, size, len) {
      s = ip2int(startip); e = ip2int(endip)
      size = e - s + 1
      len = 32
      while (size > 1) { size /= 2; len-- }
      return startip "/" len
    }
    BEGIN { n = 0 }
    /^inetnum:/ { split($2, r, " - "); cur = cidr_of(r[1], r[2]) }
    /^netname:/ && cur != "" { name[cur] = $2; cur = "" }
    /^org-name:/ { org = $2 }
    /^route:/ { route = $2 }
    /^origin:/ { asn = $2 }
    /^created:/ && route != "" {
      split($2, d, "T")
      routes[n] = route; asns[n] = asn; dates[n] = d[1]
      n++
      route = ""
    }
    END {
      print "Owner: " org
      print ""
      for (i = 0; i < n; i++) {
        label = (routes[i] in name) ? name[routes[i]] : "-"
        printf "%-18s %-24s %-8s %s\n", routes[i], label, asns[i], dates[i]
      }
    }
  '
}

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY

bindkey -e
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[[3~" delete-char
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search
