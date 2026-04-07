BOOTSTRAP_DNF_PKGS=(dnf-plugins-core dnf-utils git python3-dnf)

DNF_PKGS=(
  adwaita-cursor-theme alsa-lib alsa-lib-devel asciinema asciiquarium atk awscli2 bat
  clean-rpm-gpg-pubkey cmatrix containerd.io cups-libs dnsutils docker-buildx-plugin
  docker-ce docker-ce-cli docker-compose-plugin eza fastfetch fd-find figlet findutils
  gdk-pixbuf2-devel golang gron gtk3 gtk3-devel gzip helm htop hugo iproute iptables-legacy
  iptables-utils iputils jq just kubernetes-client libXScrnSaver libXScrnSaver-devel
  libXcomposite libXcursor libXdamage libXext libXi libXrandr libXtst lolcat make maven
  mesa-libgbm moreutils-parallel ncurses nmap-ncat nss-devel openssl packer pango
  python-unversioned-command python3-pip qemu-user-static remove-retired-packages ripgrep
  rpmconf shfmt symlinks tar terraform tokei tree vim wget xrandr yq zip zsh
)

ALT_PY_VER="3.9"
# shellcheck disable=SC2034
DISTRO_NAME="Fedora"

set -eux

system_setup() {
  sudo rm -rf /etc/yum.repos.d/*testing*
  sudo dnf install -yq "${BOOTSTRAP_DNF_PKGS[@]}" 2> /dev/null

  __configure_etc
  sudo dnf update -yq
  sudo sed -i -e "/VARIANT/d" -e "s/ (Container Image)//g" /etc/os-release

  [ -f /etc/yum.repos.d/hashicorp.repo ] ||
    sudo dnf4 config-manager -q --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
  [ -f /etc/yum.repos.d/docker-ce.repo ] ||
    sudo dnf4 config-manager -q --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
}

packages_setup() {
  local java="java-${JAVA_VER}-openjdk-devel"
  local alt_java="java-${ALT_JAVA_VER}-openjdk-devel"
  local alt_py="python${ALT_PY_VER}"

  local arch
  arch=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')

  sudo dnf install -yq \
    "${java}" "${alt_java}" "${alt_py}" \
    "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_${arch/amd64/64bit}/session-manager-plugin.rpm" \
    "https://github.com/lucagrulla/cw/releases/latest/download/cw_${arch}.rpm" \
    "${DNF_PKGS[@]}" 2> /dev/null

  sudo dnf autoremove -yq 2> /dev/null
  # shellcheck disable=SC2086
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
