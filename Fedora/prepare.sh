set -eux

FONT="JuliaMono"
JAVA_VER="21"
ALT_JAVA_VER="17"
ALT_PY_VER="3.9"

__get_gh_repo() {
  git -C "${1}" pull || git clone --depth=1 "https://github.com/${2}.git" "${1}"
}

__get_pkg() {
  sudo dnf install -yq "${@}" 2> /dev/null
}

system_setup() {
  sudo rm -rf /etc/yum.repos.d/*testing*
  __get_pkg python3-dnf dnf-plugins-core dnf-utils git

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

  __get_pkg "${java}" "${alt_java}" "${alt_py}" \
    https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm \
    https://github.com/lucagrulla/cw/releases/latest/download/cw_amd64.rpm \
    adwaita-cursor-theme alsa-lib alsa-lib-devel asciinema asciiquarium atk awscli2 bat \
    clean-rpm-gpg-pubkey cmatrix containerd.io cups-libs dnsutils docker-buildx-plugin \
    docker-ce docker-ce-cli docker-compose-plugin eza fastfetch figlet findutils \
    gdk-pixbuf2-devel gron gtk3 gtk3-devel gzip htop hugo iproute iptables-legacy \
    iptables-utils iputils jq just kubernetes-client libXScrnSaver libXScrnSaver-devel \
    libXcomposite libXcursor libXdamage libXext libXi libXrandr libXtst lolcat make maven \
    mesa-libgbm moreutils-parallel ncurses nmap-ncat nss-devel openssl packer pango \
    python3-pip qemu-user-static remove-retired-packages rpmconf symlinks tar terraform \
    tree vim wget xrandr yq zip zsh

  pip install -U --user --no-warn-script-location \
    pdm pdm-bump dep-logic boto3 black docker-squash

  sudo "${alt_py}" -m ensurepip --altinstall 2> /dev/null
  sudo chsh -s "$(which zsh)" "${USER}" 2> /dev/null
}

home_setup() {
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
