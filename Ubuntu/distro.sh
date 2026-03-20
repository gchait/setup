BOOTSTRAP_APT_PKGS="ca-certificates curl git gnupg"

APT_PKGS="
  adwaita-icon-theme bat build-essential cmatrix dnsutils docker-buildx docker-compose-v2
  docker.io eza fd-find figlet golang-go gron helm htop hugo iproute2 iptables jq just
  libasound2-dev libasound2t64 libatk1.0-0 libcups2t64 libgbm1 libgdk-pixbuf2.0-dev
  libgtk-3-0t64 libgtk-3-dev libncurses6 libnss3-dev libpango-1.0-0 libxcomposite1
  libxcursor1 libxdamage1 libxext6 libxi6 libxrandr2 libxss-dev libxss1 libxtst6 lolcat
  make maven moreutils ncat openssh-client openssl packer python3-dev python3-pip
  qemu-user-static ripgrep shfmt symlinks tar terraform tree vim wget zip zsh
"

# shellcheck disable=SC2034
DISTRO_NAME="Ubuntu"
ARCH=$(dpkg --print-architecture)
export DEBIAN_FRONTEND="noninteractive"

set -eux

system_setup() {
  sudo apt-get update -q
  # shellcheck disable=SC2086
  sudo apt-get install -yq ${BOOTSTRAP_APT_PKGS} 2> /dev/null

  __configure_etc
  local codename
  codename=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)

  [ -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ] ||
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${codename} main" |
    sudo tee /etc/apt/sources.list.d/hashicorp.list

  [ -f /usr/share/keyrings/helm.gpg ] ||
    curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/helm.gpg
  echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" |
    sudo tee /etc/apt/sources.list.d/helm.list

  sudo apt-get update -q
  sudo apt-get upgrade -yq 2> /dev/null
}

# shellcheck disable=SC2001
packages_setup() {
  local java="openjdk-${JAVA_VER}-jdk"
  local alt_java="openjdk-${ALT_JAVA_VER}-jdk"
  local arch_ff arch_ssm

  arch_ff=$(echo "${ARCH}" | sed 's/arm64/aarch64/')
  arch_ssm=$(echo "${ARCH}" | sed 's/amd64/64bit/')

  # shellcheck disable=SC2086
  sudo apt-get install -yq "${java}" "${alt_java}" ${APT_PKGS} 2> /dev/null

  command -v fastfetch || {
    curl -fsSL "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-${arch_ff}.deb" -o /tmp/fastfetch.deb
    sudo apt-get install -yq /tmp/fastfetch.deb
    rm /tmp/fastfetch.deb
  }

  command -v cw || {
    curl -fsSL "https://github.com/lucagrulla/cw/releases/latest/download/cw_${ARCH}.deb" -o /tmp/cw.deb
    sudo apt-get install -yq /tmp/cw.deb
    rm /tmp/cw.deb
  }

  command -v session-manager-plugin || {
    curl -fsSL "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${arch_ssm}/session-manager-plugin.deb" -o /tmp/ssm.deb
    sudo apt-get install -yq /tmp/ssm.deb
    rm /tmp/ssm.deb
  }

  command -v yq || {
    curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH}" -o /tmp/yq
    sudo install -m 0755 /tmp/yq /usr/local/bin/yq
    rm /tmp/yq
  }

  sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
  sudo apt-get autoremove -yq 2> /dev/null
  # shellcheck disable=SC2086
  pip install -U --user --break-system-packages --no-warn-script-location ${USER_PIP_PKGS}
  __set_default_shell
}

{
  system_setup
  packages_setup
  home_setup
  docker_setup
} > /dev/null
