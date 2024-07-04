sudo rm -rf /etc/yum.repos.d/*testing*
sudo dnf update -y

sudo dnf install -y \
    tree vim python3-pip jq yq awscli2 iproute iputils \
    kubernetes-client just eza cronie figlet nc htop zsh \
    asciinema lolcat zip gzip tar curl wget dnsutils sudo \
    fastfetch ncurses dnf-plugins-core dnf-utils git findutils

sudo chsh -s $(which zsh) "${USER}"
mkdir -p "${HOME}/.zsh"

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
sudo sed -i '/VARIANT/d' /etc/os-release

cp -r ${HOME}/setup/Fedora/Home/.* "${HOME}"
mkdir -p "${HOME}/Projects"

sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo usermod -aG docker "${USER}"

sudo rpm --import https://yum.corretto.aws/corretto.key
sudo curl -sLo /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
sudo dnf install -y java-17-amazon-corretto-devel
