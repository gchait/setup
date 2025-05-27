set -eux

FONT="JuliaMono"
JAVA_VER="21"
ALT_PY_VER="3.9"

__get_repo() {
  git -C "${1}" pull || git clone --depth=1 "${2}" "${1}"
}

__get_pkg() {
  sudo dnf install -yq "${@}" 2> /dev/null
}

system_setup() {
  sudo rm -rf /etc/yum.repos.d/*testing*
  __get_pkg python3-dnf dnf-plugins-core dnf-utils git

  __get_repo "${HOME}/setup" https://github.com/gchait/setup.git
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
  local alt_py="python${ALT_PY_VER}"

  __get_pkg "${java}" "${alt_py}" adwaita-cursor-theme alsa-lib asciinema \
    asciiquarium atk awscli2 bat cmatrix containerd.io cups-libs dnsutils \
    docker-buildx-plugin docker-ce docker-ce-cli docker-compose-plugin eza \
    fastfetch figlet findutils gron gtk3 gzip htop hugo iproute iputils jq \
    just kubernetes-client libXScrnSaver libXcomposite libXcursor libXdamage \
    libXext libXi libXrandr libXtst lolcat make mesa-libgbm moreutils-parallel \
    ncurses nmap-ncat openssl packer pango python3-pip qemu-user-static tar \
    terraform tree vim wget yq zip zsh

  pip install -U --user --no-warn-script-location pdm pdm-bump dep-logic boto3 black
  sudo "${alt_py}" -m ensurepip --altinstall 2> /dev/null
  sudo chsh -s "$(which zsh)" "${USER}" 2> /dev/null
}

home_setup() {
  __get_repo "${HOME}/.zsh/complete" https://github.com/zsh-users/zsh-completions.git
  __get_repo "${HOME}/.zsh/highlight" https://github.com/zsh-users/zsh-syntax-highlighting.git
  __get_repo "${HOME}/.zsh/suggest" https://github.com/zsh-users/zsh-autosuggestions.git
  __get_repo "${HOME}/.zsh/p10k" https://github.com/romkatv/powerlevel10k.git

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
