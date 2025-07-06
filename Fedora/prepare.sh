CORE_DNF_PKGS=(dnf-plugins-core dnf-utils git python3-dnf)
USER_PIP_PKGS=(black boto3 construct dep-logic docker-squash pandas pdm pdm-bump pyyaml)

MORE_DNF_PKGS=(
  adwaita-cursor-theme alsa-lib alsa-lib-devel asciinema asciiquarium atk awscli2 bat
  clean-rpm-gpg-pubkey cmatrix containerd.io cups-libs dnsutils docker-buildx-plugin
  docker-ce docker-ce-cli docker-compose-plugin eza fastfetch figlet findutils
  gdk-pixbuf2-devel gron gtk3 gtk3-devel gzip helm htop hugo iproute iptables-legacy
  iptables-utils iputils jq just kubernetes-client libXScrnSaver libXScrnSaver-devel
  libXcomposite libXcursor libXdamage libXext libXi libXrandr libXtst lolcat make maven
  mesa-libgbm moreutils-parallel ncurses nmap-ncat nss-devel openssl packer pango
  python3-pip qemu-user-static remove-retired-packages rpmconf symlinks tar terraform
  tree vim wget xrandr yq zip zsh
)

JAVA_VER="21"
ALT_JAVA_VER="17"
ALT_PY_VER="3.9"
FONT="JuliaMono"

set -eux

__get_gh_repo() {
  git -C "${1}" pull || git clone --depth=1 "https://github.com/${2}.git" "${1}"
}

system_setup() {
  sudo rm -rf /etc/yum.repos.d/*testing*
  sudo dnf install -yq "${CORE_DNF_PKGS[@]}" 2> /dev/null

  __get_gh_repo "${HOME}/setup" gchait/setup
  sudo cp -r "${HOME}/setup/Fedora/Etc/"* /etc
  sudo dnf update -yq

  sudo sed -i "/VARIANT/d" /etc/os-release
  sudo sed -i "s/ (Container Image)//g" /etc/os-release

  sudo dnf4 config-manager -q \
    --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo \
    --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
}

packages_setup() {
  local java="java-${JAVA_VER}-openjdk-devel"
  local alt_java="java-${ALT_JAVA_VER}-openjdk-devel"
  local alt_py="python${ALT_PY_VER}"

  sudo dnf install -yq \
    "${java}" "${alt_java}" "${alt_py}" \
    https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm \
    https://github.com/lucagrulla/cw/releases/latest/download/cw_amd64.rpm \
    "${MORE_DNF_PKGS[@]}" 2> /dev/null

  pip install -U --user --no-warn-script-location "${USER_PIP_PKGS[@]}"
  sudo "${alt_py}" -m ensurepip --altinstall 2> /dev/null
  sudo chsh -s "$(which zsh)" "${USER}" 2> /dev/null
}

home_setup() {
  local user_csv="${HOME}/setup/.user.csv"
  local gitconfig_path="${HOME}/.gitconfig"
  local gitconfig_tpl_path="${HOME}/setup/Fedora/.gitconfig.tpl"

  __get_gh_repo "${HOME}/.zsh/complete" zsh-users/zsh-completions &
  __get_gh_repo "${HOME}/.zsh/highlight" zsh-users/zsh-syntax-highlighting &
  __get_gh_repo "${HOME}/.zsh/suggest" zsh-users/zsh-autosuggestions &
  __get_gh_repo "${HOME}/.zsh/p10k" romkatv/powerlevel10k &
  wait

  cp -r "${HOME}/setup/Fedora/Home/".* "${HOME}"
  mkdir -p "${HOME}/Projects" "${HOME}/.local/share/fonts"

  fc-list | grep -q "/${FONT}-" || {
    cp "${HOME}/setup/Assets/${FONT}/"*.ttf "${HOME}/.local/share/fonts/"
    fc-cache -f
  }

  if [ ! -f "${user_csv}" ]; then
    read -rp "Enter your Git user name: " git_user_name
    read -rp "Enter your Git user email: " git_user_email
    echo "${git_user_name},${git_user_email}" > "${user_csv}"
  else
    IFS="," read -r git_user_name git_user_email < "${user_csv}"
  fi

  sed -e "s/{{GIT_USER_NAME}}/${git_user_name}/" \
    -e "s/{{GIT_USER_EMAIL}}/${git_user_email}/" \
    "${gitconfig_tpl_path}" > "${gitconfig_path}"
}

docker_setup() {
  docker ps 2> /dev/null || {
    echo '{"default-address-pools":[{"base":"10.2.0.0/16","size":24}]}' | \
      sudo tee /etc/docker/daemon.json

    sudo systemctl enable docker
    sudo systemctl start docker 2> /dev/null || true
    sudo usermod -aG docker "${USER}"
  }
}

{
  system_setup
  packages_setup
  home_setup
  docker_setup
} > /dev/null
