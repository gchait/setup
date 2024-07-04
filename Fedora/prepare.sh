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

sudo cp "${HOME}/setup/Fedora/dnf.conf" /etc/dnf/
cp -r ${HOME}/setup/Fedora/Home/.* "${HOME}"
mkdir -p "${HOME}/Projects"
