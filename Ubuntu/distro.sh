BOOTSTRAP_APT_PKGS=(ca-certificates curl git gnupg)

APT_PKGS=(
  adwaita-icon-theme asciinema bat build-essential cmatrix docker.io docker-buildx docker-compose-v2
  dnsutils eza fd-find figlet golang-go gron helm htop hugo iproute2 iptables jq just libasound2-dev
  libasound2t64 libatk1.0-0 libcups2t64 libgbm1 libgdk-pixbuf2.0-dev libgtk-3-0t64 libgtk-3-dev
  libncurses6 libnss3-dev libpango-1.0-0 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxi6
  libxrandr2 libxss-dev libxss1 libxtst6 lolcat make maven moreutils ncat openssl packer python3-pip
  qemu-user-static openssh-client python3-dev ripgrep shfmt symlinks tar terraform tree vim wget zip zsh
)

DISTRO_NAME="Ubuntu"
ARCH=$(dpkg --print-architecture)
export DEBIAN_FRONTEND=noninteractive

system_setup() {
  sudo apt-get update -y
  sudo apt-get install -y "${BOOTSTRAP_APT_PKGS[@]}" 2> /dev/null

  __get_gh_repo "${SETUP_DIR}" gchait/setup
  sudo cp -r "${SETUP_DIR}/Shared/Etc/"* /etc
  sudo cp -r "${SETUP_DIR}/${DISTRO_NAME}/Etc/"* /etc

  local codename
  codename=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)

  sudo install -m 0755 -d /etc/apt/keyrings

  curl -fsSL https://apt.releases.hashicorp.com/gpg |
    sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${codename} main" |
    sudo tee /etc/apt/sources.list.d/hashicorp.list

  curl -fsSL https://baltocdn.com/helm/signing.asc |
    sudo gpg --dearmor -o /usr/share/keyrings/helm.gpg
  echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" |
    sudo tee /etc/apt/sources.list.d/helm.list

  sudo apt-get update -y
}

# shellcheck disable=SC2001
packages_setup() {
  local java="openjdk-${JAVA_VER}-jdk"
  local alt_java="openjdk-${ALT_JAVA_VER}-jdk"
  local arch_ff arch_ssm

  arch_ff=$(echo "${ARCH}" | sed 's/arm64/aarch64/')
  arch_ssm=$(echo "${ARCH}" | sed 's/amd64/64bit/')

  sudo apt-get install -y "${java}" "${alt_java}" "${APT_PKGS[@]}" 2> /dev/null

  curl -fsSL "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-${arch_ff}.deb" -o /tmp/fastfetch.deb
  sudo apt-get install -y /tmp/fastfetch.deb
  rm /tmp/fastfetch.deb

  curl -fsSL "https://github.com/lucagrulla/cw/releases/latest/download/cw_${ARCH}.deb" -o /tmp/cw.deb
  sudo apt-get install -y /tmp/cw.deb
  rm /tmp/cw.deb

  curl -fsSL "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${arch_ssm}/session-manager-plugin.deb" -o /tmp/ssm.deb
  sudo apt-get install -y /tmp/ssm.deb
  rm /tmp/ssm.deb

  curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH}" -o /tmp/yq
  sudo install -m 0755 /tmp/yq /usr/local/bin/yq
  rm /tmp/yq

  pip install -U --user --no-warn-script-location "${USER_PIP_PKGS[@]}"
  __set_default_shell
}

{
  system_setup
  packages_setup
  home_setup
  docker_setup
} > /dev/null
