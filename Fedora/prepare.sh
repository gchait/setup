sudo rm -rf /etc/yum.repos.d/*testing*
sudo dnf update -y
sudo dnf remove -y "*pulseaudio*" "*pipewire*" "*wayland*" "*gstreamer*"

sudo dnf install -y \
    tree java-21-openjdk-devel awscli2 libXcursor adwaita-cursor-theme zip \
    kubernetes-client just eza cronie figlet nc htop zsh jq yq python3-pip \
    asciinema lolcat gzip wget cmatrix dnsutils ncurses git tar findutils \
    fastfetch dnf-plugins-core dnf-utils vim iproute iputils python3.8

sudo python3.8 -m ensurepip --altinstall 2> /dev/null
sudo chsh -s $(which zsh) "${USER}"
mkdir -p "${HOME}/.zsh" "${HOME}/Projects" "${HOME}/.local/share/fonts"

get_repo() {
    cd "${1}" && git pull || git clone --depth=1 "${2}" "${1}"
}

get_repo "${HOME}/.zsh/complete" https://github.com/zsh-users/zsh-completions.git
get_repo "${HOME}/.zsh/highlight" https://github.com/zsh-users/zsh-syntax-highlighting.git
get_repo "${HOME}/.zsh/suggest" https://github.com/zsh-users/zsh-autosuggestions.git
get_repo "${HOME}/.zsh/p10k" https://github.com/romkatv/powerlevel10k.git
get_repo "${HOME}/setup" https://github.com/gchait/setup.git

sudo cp "${HOME}/setup/Fedora/wsl.conf" /etc/
sudo cp "${HOME}/setup/Fedora/dnf.conf" /etc/dnf/
sudo sed -i "/VARIANT/d" /etc/os-release
cp -r ${HOME}/setup/Fedora/Home/.* "${HOME}"

sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
echo '{"default-address-pools":[{"base":"10.2.0.0/16","size":24}]}' | sudo tee /etc/docker/daemon.json
sudo systemctl enable docker
sudo usermod -aG docker "${USER}"

sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
sudo dnf install -y terraform packer
