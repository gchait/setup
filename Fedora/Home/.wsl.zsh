export BROWSER="/c/Program Files/Mozilla Firefox/firefox.exe"

export PATH=$(echo "${HOME}/.local/bin:${PATH}" | sed "s|/:|:|g" | \
  sed -E "s|:[^:]+/games||g" | sed -E "s|:[^:]+/WindowsApps||" | \
  sed -E "s|:[^:]+/System32/OpenSSH||" | sed -E "s|:[^:]+/System32/Wbem||")

alias wsl="wsl.exe"
alias pwsh="powershell.exe"
alias ipco="ipconfig.exe"
alias wff="fastfetch.exe -c paleofetch.jsonc"

__set_wsl_display() {
  local host=$(ip r | grep "/20 dev eth0" | \
    cut -d"/" -f1 | sed "s/.0$/.1/")

  if nc -zw1 "${host}" 6000; then
    export DISPLAY="${host}:0.0"
    export XCURSOR_SIZE=$(( $(xrandr | grep "0\.00\*" | \
      awk '{print $1}' | cut -d"x" -f2) / 27 ))

  else
    >&2 echo "X server is not running."
    return 1
  fi
}

expl() {
  (cd "${1:-$HOME}" && { explorer.exe . || true; })
}
