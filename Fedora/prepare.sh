__get_repo() {
  # shellcheck disable=SC2015
  cd "${1}" && git pull || git clone --depth=1 "${2}" "${1}"
}

system_setup() {
  sudo rm -rf /etc/yum.repos.d/*testing*

  sudo dnf install -y dnf-plugins-core dnf-utils git
  __get_repo "${HOME}/setup" https://github.com/gchait/setup.git

  sudo cp "${HOME}/setup/Fedora/dnf.conf" /etc/dnf/
  sudo dnf update -y

  sudo dnf config-manager \
    --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo \
    --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
}

wsl_specific_setup() {
  sudo dnf remove -y "*pulseaudio*" "*pipewire*" "*wayland*" "*gstreamer*" > /dev/null
  sudo dnf install -y libXcursor adwaita-cursor-theme
  sudo cp "${HOME}/setup/Fedora/wsl.conf" /etc/
  sudo sed -i "/VARIANT/d" /etc/os-release
}

packages_setup() {
  sudo dnf install -y \
    tree zsh java-21-openjdk-devel awscli2 zip make openssl gron python3.9 \
    kubernetes-client vim tar figlet nmap-ncat htop bat jq yq python3-pip \
    asciinema lolcat gzip wget cmatrix just dnsutils ncurses findutils \
    fastfetch eza iproute iputils asciiquarium terraform packer docker-ce \
    docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  pip install -U --no-warn-script-location pdm pdm-bump
  sudo python3.9 -m ensurepip --altinstall 2> /dev/null
  sudo chsh -s "$(which zsh)" "${USER}"
}

home_setup() {
  __get_repo "${HOME}/.zsh/complete" https://github.com/zsh-users/zsh-completions.git
  __get_repo "${HOME}/.zsh/highlight" https://github.com/zsh-users/zsh-syntax-highlighting.git
  __get_repo "${HOME}/.zsh/suggest" https://github.com/zsh-users/zsh-autosuggestions.git
  __get_repo "${HOME}/.zsh/p10k" https://github.com/romkatv/powerlevel10k.git

  cp -r "${HOME}"/setup/Fedora/Home/.* "${HOME}"
  mkdir -p "${HOME}/.zsh" "${HOME}/Projects" "${HOME}/.local/share/fonts"

  fc-list | grep -q /JuliaMono- || { cp "${HOME}"/setup/Assets/JuliaMono/*.ttf \
    "${HOME}/.local/share/fonts/"; fc-cache -f; }
}

docker_setup() {
  local json='{"default-address-pools":[{"base":"10.2.0.0/16","size":24}]}'
  echo "${json}" | sudo tee /etc/docker/daemon.json

  sudo systemctl enable docker
  sudo systemctl start docker &> /dev/null || true
  sudo usermod -aG docker "${USER}"
}

{
  system_setup
  uname -r | grep -qi wsl && wsl_specific_setup
  packages_setup
  home_setup
  docker ps &> /dev/null || docker_setup
} | grep -Ev "already (installed|satisfied)"
