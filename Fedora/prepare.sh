IS_WSL="$(uname -r | grep -qi wsl && echo 1 || echo 0)"
DOCKER_JSON='{"default-address-pools":[{"base":"10.2.0.0/16","size":24}]}'

__get_repo() {
    cd "${1}" && git pull || git clone --depth=1 "${2}" "${1}"
}

system_setup() {
    sudo dnf install -y dnf-plugins-core dnf-utils git
    __get_repo "${HOME}/setup" https://github.com/gchait/setup.git
    
    sudo cp "${HOME}/setup/Fedora/dnf.conf" /etc/dnf/
    sudo rm -rf /etc/yum.repos.d/*testing*
    sudo dnf update -y
    
    sudo dnf config-manager \
        --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo \
        --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
}

wsl_specific_setup() {
    sudo dnf remove -y "*pulseaudio*" "*pipewire*" "*wayland*" "*gstreamer*" > /dev/null
    sudo dnf install -y libXcursor adwaita-cursor-theme python3.8
    sudo python3.8 -m ensurepip --altinstall 2> /dev/null
    sudo cp "${HOME}/setup/Fedora/wsl.conf" /etc/
    sudo sed -i "/VARIANT/d" /etc/os-release
}

workstation_specific_setup() {
    echo "Not implemented"
}

packages_setup() {
    sudo dnf install -y \
        tree zsh java-21-openjdk-devel awscli2 zip make poetry openssl cargo \
        kubernetes-client just eza vim cronie figlet nc htop jq yq python3-pip \
        asciinema lolcat gzip wget cmatrix dnsutils ncurses tar findutils \
        fastfetch iproute iputils asciiquarium terraform packer docker-ce \
        docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo chsh -s $(which zsh) "${USER}"
}

home_setup() {
    __get_repo "${HOME}/.zsh/complete" https://github.com/zsh-users/zsh-completions.git
    __get_repo "${HOME}/.zsh/highlight" https://github.com/zsh-users/zsh-syntax-highlighting.git
    __get_repo "${HOME}/.zsh/suggest" https://github.com/zsh-users/zsh-autosuggestions.git
    __get_repo "${HOME}/.zsh/p10k" https://github.com/romkatv/powerlevel10k.git
    
    cp -r ${HOME}/setup/Fedora/Home/.* "${HOME}"
    mkdir -p "${HOME}/.zsh" "${HOME}/Projects" "${HOME}/.local/share/fonts"
}

docker_setup() {
    echo "${DOCKER_JSON}" | sudo tee /etc/docker/daemon.json
    sudo systemctl enable docker
    sudo systemctl start docker &> /dev/null || true
    sudo usermod -aG docker "${USER}"
}

system_setup
[ "${IS_WSL}" = "1" ] && wsl_specific_setup
[ "${IS_WSL}" = "0" ] && workstation_specific_setup
packages_setup
home_setup
docker ps &> /dev/null || docker_setup
