BOOTSTRAP_DNF_PKGS=(adoptium-temurin-java-repository dnf-plugins-core dnf-utils git python3-dnf)

DNF_PKGS=(
  ShellCheck adwaita-cursor-theme alsa-lib alsa-lib-devel asciinema asciiquarium
  atk awscli2 bat bind-utils clean-rpm-gpg-pubkey cmatrix containerd.io cups-libs
  docker-buildx-plugin docker-ce docker-ce-cli docker-compose-plugin eza fastfetch
  fd-find figlet findutils gdk-pixbuf2-devel gh glab golang gtk3 gtk3-devel gzip
  helm htop hugo iproute iptables-legacy iptables-utils iputils jq just less
  libXScrnSaver libXScrnSaver-devel libXcomposite libXcursor libXdamage libXext
  libXi libXrandr libXtst lolcat make man-db maven-unbound mesa-libgbm
  moreutils-parallel nano ncurses nmap-ncat nodejs22 nodejs22-npm nss-devel openssl
  packer pango postgresql python-unversioned-command python3-pip qemu-user-static
  remove-retired-packages ripgrep rpmconf shfmt symlinks tar tcpdump terraform
  tokei tree unzip vim-enhanced wget2 wireshark-cli xrandr yq zip zsh
)

ALT_PY_VER="3.9"
# shellcheck disable=SC2034
DISTRO_NAME="Fedora"
ARCH=$(uname -m)
ARCH=${ARCH/x86_64/amd64}
ARCH=${ARCH/aarch64/arm64}

set -eux

__add_dnf_repo() {
  [[ -f "/etc/yum.repos.d/${1}.repo" ]] ||
    sudo dnf4 config-manager -q --add-repo "${2}"
}

system_setup() {
  sudo rm -rf /etc/yum.repos.d/*testing*
  sudo dnf install -yq "${BOOTSTRAP_DNF_PKGS[@]}" 2> /dev/null

  __configure_etc
  sudo dnf update -yq

  sudo sed -i -e "/VARIANT/d" -e "s/ (Container Image)//g" /etc/os-release
  sudo dnf4 config-manager -q --enable adoptium-temurin-java-repository

  __add_dnf_repo hashicorp https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
  __add_dnf_repo docker-ce https://download.docker.com/linux/fedora/docker-ce.repo
}

# shellcheck disable=SC2086,SC2154
packages_setup() {
  local java="java-${JAVA_VER}-openjdk-devel"
  local alt_java="java-${ALT_JAVA_VER}-openjdk-devel"
  local alt_py="python${ALT_PY_VER}"
  local kubectl="kubernetes${KUBECTL_VER}-client"

  sudo dnf install -yq \
    "${java}" "${alt_java}" "${alt_py}" "${kubectl}" \
    "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_${ARCH/amd64/64bit}/session-manager-plugin.rpm" \
    "https://github.com/lucagrulla/cw/releases/latest/download/cw_${ARCH}.rpm" \
    "${DNF_PKGS[@]}" 2> /dev/null

  sudo dnf autoremove -yq 2> /dev/null
  pip install -U --user --no-warn-script-location ${USER_PIP_PKGS}
  sudo "${alt_py}" -m ensurepip --altinstall 2> /dev/null
  __set_default_shell
}

{
  system_setup
  packages_setup
  home_setup
  docker_setup
} > /dev/null
