BOOTSTRAP_APT_PKGS="ca-certificates curl git gnupg"

APT_PKGS="
  adwaita-icon-theme asciinema awscli bat bind9-dnsutils build-essential claude-code
  cmatrix docker-buildx docker-compose docker.io eza fd-find figlet gh glab golang-go gron
  helm htop hugo iproute2 iptables jq just kubectl less libasound2-dev libasound2t64
  libatk1.0-0t64 libcups2t64 libgbm1 libgdk-pixbuf-2.0-dev libgtk-3-0t64 libgtk-3-dev
  libncurses6 libnss3-dev libpango-1.0-0 libxcomposite1 libxcursor1 libxdamage1 libxext6
  libxi6 libxrandr2 libxss-dev libxss1 libxtst6 lolcat make man-db maven mongodb-mongosh
  moreutils nano ncat nodejs npm openssh-client openssl packer postgresql-client
  python-is-python3 python3-dev python3-pip python3-setuptools ripgrep shellcheck shfmt
  symlinks tar tcpdump terraform tokei tree tshark unzip vim wget x11-xserver-utils zip zsh
"

# shellcheck disable=SC2034
DISTRO_NAME="Debian"
ARCH=$(dpkg --print-architecture)
export DEBIAN_FRONTEND="noninteractive"

set -eux

__add_apt_repo() {
  local name="${1}" key_url="${2}" deb_suite="${3}" extra_opts="${4:-}"
  local keyring="/usr/share/keyrings/${name}.gpg"

  [ -f "${keyring}" ] || curl -fsSL "${key_url}" | sudo gpg --dearmor -o "${keyring}"
  echo "deb [${extra_opts}signed-by=${keyring}] ${deb_suite}" |
    sudo tee "/etc/apt/sources.list.d/${name}.list"
}

__install_from_url() {
  command -v "${1}" || {
    local tmp
    case "${2}" in *.deb) tmp=$(mktemp --suffix=.deb) ;; *) tmp=$(mktemp) ;; esac
    curl -fsSL "${2}" -o "${tmp}"
    case "${2}" in
    *.deb) sudo apt-get install -yq "${tmp}" ;;
    *) sudo install -m 0755 "${tmp}" "/usr/local/bin/${1}" ;;
    esac
    rm -f "${tmp}"
  }
}

system_setup() {
  local codename

  sudo apt-get update -q
  # shellcheck disable=SC2086
  sudo apt-get install -yq ${BOOTSTRAP_APT_PKGS} 2> /dev/null

  __configure_etc
  codename=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)

  __add_apt_repo adoptium https://packages.adoptium.net/artifactory/api/gpg/key/public \
    "https://packages.adoptium.net/artifactory/deb ${codename} main"

  __add_apt_repo hashicorp https://apt.releases.hashicorp.com/gpg \
    "https://apt.releases.hashicorp.com ${codename} main" "arch=${ARCH} "

  __add_apt_repo helm https://packages.buildkite.com/helm-linux/helm-debian/gpgkey \
    "https://packages.buildkite.com/helm-linux/helm-debian/any/ any main"

  __add_apt_repo kubernetes "https://pkgs.k8s.io/core:/stable:/v${KUBECTL_VER}/deb/Release.key" \
    "https://pkgs.k8s.io/core:/stable:/v${KUBECTL_VER}/deb/ /"

  __add_apt_repo mongodb https://pgp.mongodb.com/server-8.0.asc \
    "https://repo.mongodb.org/apt/debian ${codename}/mongodb-org/8.0 main"

  __add_apt_repo claude-code https://downloads.claude.ai/keys/claude-code.asc \
    "https://downloads.claude.ai/claude-code/apt/stable stable main"

  sudo apt-get update -q
  sudo -E apt-get upgrade -yq 2> /dev/null
}

# shellcheck disable=SC2001
packages_setup() {
  local java="temurin-${JAVA_VER}-jdk"
  local alt_java="temurin-${ALT_JAVA_VER}-jdk"
  local arch_ff arch_ssm qemu_pkg

  arch_ff=$(echo "${ARCH}" | sed 's/arm64/aarch64/')
  arch_ssm=$(echo "${ARCH}" | sed 's/amd64/64bit/')
  qemu_pkg=$(apt-cache policy qemu-user-static | grep -q "Candidate: [^(]" && echo qemu-user-static || echo qemu-user-binfmt)

  # shellcheck disable=SC2086
  sudo -E apt-get install -yq "${java}" "${alt_java}" "${qemu_pkg}" ${APT_PKGS} 2> /dev/null

  __install_from_url yq "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH}"
  __install_from_url cw "https://github.com/lucagrulla/cw/releases/latest/download/cw_${ARCH}.deb"
  __install_from_url k3d "https://github.com/k3d-io/k3d/releases/latest/download/k3d-linux-${ARCH}"

  __install_from_url argocd \
    "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-${ARCH}"

  __install_from_url fastfetch \
    "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-${arch_ff}.deb"

  __install_from_url session-manager-plugin \
    "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${arch_ssm}/session-manager-plugin.deb"

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
