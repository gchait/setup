BOOTSTRAP_APT_PKGS="ca-certificates git gnupg"

# shellcheck disable=SC2034
APT_PKGS="
  adwaita-icon-theme asciinema awscli bat bind9-dnsutils build-essential claude-code cmatrix
  docker-buildx docker-cli docker-compose docker.io eza fd-find figlet gh glab golang-go
  gron helm htop hugo iproute2 iptables jq just kubectl less libasound2-dev libasound2t64
  libatk1.0-0t64 libcups2t64 libgbm1 libgdk-pixbuf-2.0-dev libgtk-3-0t64 libgtk-3-dev
  libncurses6 libnss3-dev libpango-1.0-0 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxi6
  libxrandr2 libxss-dev libxss1 libxtst6 lolcat make man-db maven mongodb-mongosh moreutils
  nano ncat nodejs npm openssh-client openssl packer postgresql-client python-is-python3
  python3-dev python3-pip python3-setuptools ripgrep shellcheck shfmt symlinks tar
  tcpdump terraform tokei tree tshark unzip vim wget whois x11-xserver-utils zip zsh
"

# shellcheck disable=SC2034
DISTRO_NAME="Debian"
ARCH=$(dpkg --print-architecture)
export DEBIAN_FRONTEND="noninteractive"

set -eux

# shellcheck disable=SC2086,SC2154
system_setup() {
  local codename

  sudo apt-get update -q
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

packages_setup() {
  __packages_setup_common temurin
}

{
  system_setup
  packages_setup
  home_setup
  docker_setup
} > /dev/null
