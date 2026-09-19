SETUP_DIR="${HOME}/setup"
ALT_JAVA_VER="17"
# shellcheck disable=SC2034
KUBECTL_VER="1.34"
USER_PIP_PKGS="aws-sam-cli black boto3 construct dep-logic docker-squash pandas pdm pdm-bump pyyaml"

# shellcheck disable=SC2154
__configure_etc() {
  __get_gh_repo "${SETUP_DIR}" gchait/setup
  sudo cp -r "${SETUP_DIR}/Shared/Etc/"* /etc
  sudo cp -r "${SETUP_DIR}/${DISTRO_NAME}/Etc/"* /etc
}

# shellcheck disable=SC2312
__add_apt_repo() {
  local name="${1}" key_url="${2}" deb_suite="${3}" extra_opts="${4:-}"
  local keyring="/usr/share/keyrings/${name}.gpg"

  curl -fsSL "${key_url}" | sudo gpg --batch --yes --dearmor -o "${keyring}"
  echo "deb [${extra_opts}signed-by=${keyring}] ${deb_suite}" |
    sudo tee "/etc/apt/sources.list.d/${name}.list"
}

# shellcheck disable=SC2001,SC2086,SC2154,SC2312
__packages_setup_common() {
  local java="${1}-${JAVA_VER}-jdk"
  local alt_java="${1}-${ALT_JAVA_VER}-jdk"
  local arch_ff arch_ssm qemu_pkg

  arch_ff=$(echo "${ARCH}" | sed 's/arm64/aarch64/')
  arch_ssm=$(echo "${ARCH}" | sed 's/amd64/64bit/')
  qemu_pkg=$(apt-cache policy qemu-user-static | grep -q "Candidate: [^(]" &&
    echo qemu-user-static || echo qemu-user-binfmt)

  sudo -E apt-get install -yq "${java}" "${alt_java}" "${qemu_pkg}" ${APT_PKGS} 2> /dev/null

  __install_from_url yq "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH}"
  __install_from_url cw "https://github.com/lucagrulla/cw/releases/latest/download/cw_${ARCH}.deb"
  __install_from_url k3d "https://github.com/k3d-io/k3d/releases/latest/download/k3d-linux-${ARCH}"

  __install_from_url argocd \
    "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-${ARCH}"

  __install_from_url fastfetch \
    "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-${arch_ff}.deb"

  __install_from_url session-manager-plugin \
    "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${arch_ssm}/session-manager-plugin.deb"

  sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
  sudo apt-get autoremove -yq 2> /dev/null

  pip install -U --user --break-system-packages --no-warn-script-location --use-pep517 ${USER_PIP_PKGS}
  __set_default_shell
}

__install_from_url() {
  command -v "${1}" || {
    local tmp
    case "${2}" in *.deb) tmp=$(mktemp --suffix=.deb) ;; *) tmp=$(mktemp) ;; esac
    curl -fsSL "${2}" -o "${tmp}"
    case "${2}" in
    *.deb) sudo apt-get install -yq "${tmp}" ;;
    *) sudo install -m 0755 "${tmp}" "/usr/local/bin/${1}" ;;
    esac
    rm -f "${tmp}"
  }
}

home_setup() {
  local zsh_dir="${HOME}/.zsh"

  __get_gh_repo "${zsh_dir}/complete" zsh-users/zsh-completions &
  __get_gh_repo "${zsh_dir}/highlight" zsh-users/zsh-syntax-highlighting &
  __get_gh_repo "${zsh_dir}/suggest" zsh-users/zsh-autosuggestions &
  __get_gh_repo "${zsh_dir}/p10k" romkatv/powerlevel10k &
  wait

  cp -r "${SETUP_DIR}/Shared/Home/".[!.]* "${HOME}"
  mkdir -p "${HOME}/Projects" "${HOME}/.local/share/fonts"

  __install_fonts "${SETUP_DIR}"
  __setup_git_config \
    "${SETUP_DIR}/.user.csv" \
    "${SETUP_DIR}/Shared/.gitconfig.tpl" \
    "${HOME}/.gitconfig"
}

docker_setup() {
  docker ps 2> /dev/null || {
    echo '{"default-address-pools":[{"base":"10.2.0.0/16","size":24}]}' |
      sudo tee /etc/docker/daemon.json

    sudo systemctl enable --now docker
    sudo usermod -aG docker "${USER}"
  }
}
