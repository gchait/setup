FONT="JuliaMono"
# shellcheck disable=SC2034
JAVA_VER="21"

__get_gh_repo() {
  git -C "${1}" pull || git clone --depth=1 "https://github.com/${2}.git" "${1}"
}

__install_fonts() {
  local setup_dir="${1}"
  fc-list | grep -q "/${FONT}-" || {
    cp "${setup_dir}/Assets/${FONT}/"*.ttf "${HOME}/.local/share/fonts/"
    fc-cache -f
  }
}

__set_default_shell() {
  local zsh_path
  zsh_path=$(which zsh)
  [ "$(getent passwd "${USER}" | cut -d: -f7)" = "${zsh_path}" ] || sudo chsh -s "${zsh_path}" "${USER}"
}

__setup_git_config() {
  local user_csv="${1}"
  local tpl_path="${2}"
  local out_path="${3}"
  local git_user_name git_user_email

  if [ ! -f "${user_csv}" ]; then
    read -rp "Enter your Git user name: " git_user_name
    read -rp "Enter your Git user email: " git_user_email
    echo "${git_user_name},${git_user_email}" > "${user_csv}"
  else
    IFS="," read -r git_user_name git_user_email < "${user_csv}"
  fi

  sed -e "s/{{GIT_USER_NAME}}/${git_user_name}/" \
    -e "s/{{GIT_USER_EMAIL}}/${git_user_email}/" \
    "${tpl_path}" > "${out_path}"
}
