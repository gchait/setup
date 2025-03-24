FONT="JuliaMono"
JAVA_VER="21"
ALT_PY_VER="3.9"

__get_repo() {
  # shellcheck disable=SC2015
  cd "${1}" && git pull || git clone --depth=1 "${2}" "${1}"
}

system_setup() {
  sudo sed -i "/VARIANT/d" /etc/os-release
  sudo sed -i "s/ (Container Image)//g" /etc/os-release

  sudo rm -rf /etc/yum.repos.d/*testing*
  sudo dnf install -yq python3-dnf dnf-plugins-core dnf-utils git

  __get_repo "${HOME}/setup" https://github.com/gchait/setup.git
  sudo cp -r "${HOME}/setup/Fedora/Etc/"* /etc
  sudo dnf update -yq

  sudo dnf4 config-manager -q \
    --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo \
    --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
}

packages_setup() {
  local java="java-${JAVA_VER}-openjdk-devel"
  local alt_py="python${ALT_PY_VER}"

  sudo dnf install -yq "${java}" "${alt_py}" libXcursor adwaita-cursor-theme \
    asciinema asciiquarium awscli2 bat cmatrix containerd.io dnsutils \
    docker-buildx-plugin docker-ce docker-ce-cli docker-compose-plugin \
    eza fastfetch figlet findutils gron gzip htop iproute iputils jq just \
    kubernetes-client lolcat make moreutils-parallel ncurses nmap-ncat openssl \
    packer python3-pip tar terraform tree vim wget yq zip zsh

  pip install -U --user --no-warn-script-location pdm pdm-bump
  sudo "${alt_py}" -m ensurepip --altinstall
  sudo chsh -s "$(which zsh)" "${USER}"
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
  docker ps || {
    echo '{"default-address-pools":[{"base":"10.2.0.0/16","size":24}]}' | \
      sudo tee /etc/docker/daemon.json

    sudo systemctl enable docker
    sudo systemctl start docker || true
    sudo usermod -aG docker "${USER}"
  }
}

{
  system_setup
  packages_setup
  home_setup
  docker_setup
} &> /dev/null
