SETUP_DIR="${HOME}/setup"
# shellcheck disable=SC2034
ALT_JAVA_VER="17"
# shellcheck disable=SC2034
USER_PIP_PKGS=(black boto3 construct dep-logic docker-squash pandas pdm pdm-bump pyyaml)

docker_setup() {
  docker ps 2> /dev/null || {
    echo '{"default-address-pools":[{"base":"10.2.0.0/16","size":24}]}' |
      sudo tee /etc/docker/daemon.json

    sudo systemctl enable docker
    sudo systemctl start docker 2> /dev/null || true
    sudo usermod -aG docker "${USER}"
  }
}

home_setup() {
  __get_gh_repo "${HOME}/.zsh/complete" zsh-users/zsh-completions &
  __get_gh_repo "${HOME}/.zsh/highlight" zsh-users/zsh-syntax-highlighting &
  __get_gh_repo "${HOME}/.zsh/suggest" zsh-users/zsh-autosuggestions &
  __get_gh_repo "${HOME}/.zsh/p10k" romkatv/powerlevel10k &
  wait

  cp -r "${SETUP_DIR}/Shared/Home/".* "${HOME}"
  mkdir -p "${HOME}/Projects" "${HOME}/.local/share/fonts"

  __install_fonts "${SETUP_DIR}"
  __setup_git_config \
    "${SETUP_DIR}/.user.csv" \
    "${SETUP_DIR}/Shared/.gitconfig.tpl" \
    "${HOME}/.gitconfig"
}
