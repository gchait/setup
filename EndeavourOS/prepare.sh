FONT="JuliaMono"
JAVA_VER="21"

PKGS=(
  asciinema asciiquarium bat bibata-cursor-theme bind claude-code cmake
  discord docker docker-compose eza fastfetch figlet ghostty github-cli
  go-yq gron htop hugo intellij-idea-community-edition "jdk${JAVA_VER}-openjdk"
  jq just lolcat meson moreutils ninja openbsd-netcat perl-image-exiftool
  python-pdm python-pip sbctl shellcheck shfmt steam strace telegram-desktop
  tmux tree ttf-fira-code ttf-jetbrains-mono ttf-ms-fonts ttf-tahoma
  wireshark-cli wl-clipboard zsh zsh-autosuggestions zsh-completions
  zsh-syntax-highlighting
)

set -eux

__get_gh_repo() {
  git -C "${1}" pull || git clone --depth=1 "https://github.com/${2}.git" "${1}"
}

system_setup() {
  mkdir -p "${HOME}/Projects"
  __get_gh_repo "${HOME}/Projects/setup" gchait/setup
  sudo cp -r "${HOME}/Projects/setup/EndeavourOS/Etc/"* /etc

  locale -a | grep -q "en_IL" || {
    sudo sed -i "s/^#\(en_IL UTF-8\)/\1/;s/^#\(en_US\.UTF-8 UTF-8\)/\1/" /etc/locale.gen
    sudo locale-gen
  }

  localectl status | grep -q "LANG=en_IL" || sudo localectl set-locale \
    LANG=en_IL LC_ADDRESS=en_IL LC_IDENTIFICATION=en_IL LC_MEASUREMENT=en_IL \
    LC_MONETARY=en_IL LC_NAME=en_IL LC_NUMERIC=en_IL LC_PAPER=en_IL \
    LC_TELEPHONE=en_IL LC_TIME=en_IL

  localectl status | grep -q "VC Keymap: il" || sudo localectl set-keymap il
  localectl status | grep -q "X11 Layout: us,il" || sudo localectl set-x11-keymap us,il "" "" grp:alt_shift_toggle

  yay -Syu --noconfirm
}

packages_setup() {
  yay -Rns --noconfirm \
    amdvlk dialog dmraid endeavouros-konsole-colors haveged iwd \
    kdeconnect konsole lib32-amdvlk nano nano-syntax-highlighting nilfs-utils \
    ntp partitionmanager plasma-x11-session print-manager usb_modeswitch \
    welcome xterm \
    2> /dev/null || true

  # shellcheck disable=SC2046
  yay -Rns --noconfirm $(yay -Qdtq) 2> /dev/null || true
  yay -S --needed --noconfirm "${PKGS[@]}"
}

home_setup() {
  local user_csv="${HOME}/Projects/setup/.user.csv"
  local gitconfig_path="${HOME}/.gitconfig"
  local gitconfig_tpl_path="${HOME}/Projects/setup/EndeavourOS/.gitconfig.tpl"

  __get_gh_repo "${HOME}/.zsh/p10k" romkatv/powerlevel10k

  cp -r "${HOME}/Projects/setup/EndeavourOS/Home/".* "${HOME}"
  mkdir -p "${HOME}/Projects" "${HOME}/.local/share/fonts"

  fc-list | grep -q "/${FONT}-" || {
    cp "${HOME}/Projects/setup/Assets/${FONT}/"*.ttf "${HOME}/.local/share/fonts/"
    fc-cache -f
  }

  if [ ! -f "${user_csv}" ]; then
    read -rp "Enter your Git user name: " git_user_name
    read -rp "Enter your Git user email: " git_user_email
    echo "${git_user_name},${git_user_email}" > "${user_csv}"
  else
    IFS="," read -r git_user_name git_user_email < "${user_csv}"
  fi

  sed -e "s/{{GIT_USER_NAME}}/${git_user_name}/" \
    -e "s/{{GIT_USER_EMAIL}}/${git_user_email}/" \
    "${gitconfig_tpl_path}" > "${gitconfig_path}"
}

services_setup() {
  docker ps 2> /dev/null || {
    sudo systemctl enable --now docker
    sudo usermod -aG docker "${USER}"
  }

  sudo systemctl disable --now NetworkManager-wait-online.service
  sudo systemctl disable --now avahi-daemon.service avahi-daemon.socket

  [ -f /efi/loader/loader.conf ] && sudo sed -i "s/^timeout.*/timeout 1/" /efi/loader/loader.conf

  printf "[Icon Theme]\nInherits=Bibata-Modern-Classic\n" |
    sudo tee /usr/share/icons/default/index.theme

  sudo rm -rf \
    /usr/share/kstyle/themes/qtplastique.themerc \
    /usr/share/kstyle/themes/qtwindows.themerc \
    /usr/share/kwin/decorations/kwin4_decoration_qml_plastik \
    /usr/share/sddm/themes/elarun \
    /usr/share/sddm/themes/maldives \
    /usr/share/sddm/themes/maya \
    /usr/share/themes/Emacs

  [ "$(getent passwd "${USER}" | cut -d: -f7)" = "$(which zsh)" ] || sudo chsh -s "$(which zsh)" "${USER}"
}

kde_setup() {
  kwriteconfig6 --file kwinrc --group Effect-overview --key BorderActivate 9
  kwriteconfig6 --file kwinrc --group NightColor --key Active --type bool true
  kwriteconfig6 --file kwinrc --group NightColor --key NightTemperature 2800
  kwriteconfig6 --file kwinrc --group Plugins --key shakecursorEnabled --type bool false
  kwriteconfig6 --file kwinrc --group Plugins --key wobblywindowsEnabled --type bool true
  kwriteconfig6 --file kwinrc --group Xwayland --key Scale 2
  kwriteconfig6 --file kwinrc --group "org.kde.kdecoration2" --key ButtonsOnLeft ""
  kwriteconfig6 --file kwinrc --group "org.kde.kdecoration2" --key ButtonsOnRight IAX
  kwriteconfig6 --file kwinrc --group "org.kde.kdecoration2" --key ShowToolTips --type bool false

  kwriteconfig6 --file kscreenlockerrc --group Daemon --key Timeout 45

  kwriteconfig6 --file ksmserverrc --group General --key confirmLogout --type bool false

  kwriteconfig6 --file ksplashrc --group KSplash --key Engine none
  kwriteconfig6 --file ksplashrc --group KSplash --key Theme None

  kwriteconfig6 --file bluedevilglobalrc --group General --key bluetoothBlocked --type bool true

  kwriteconfig6 --file kxkbrc --group Layout --key DisplayNames ","
  kwriteconfig6 --file kxkbrc --group Layout --key LayoutList "us,il"
  kwriteconfig6 --file kxkbrc --group Layout --key Use --type bool true
  kwriteconfig6 --file kxkbrc --group Layout --key VariantList ","

  kwriteconfig6 --file powerdevilrc --group AC --group Display --key DimDisplayIdleTimeoutSec -- -1
  kwriteconfig6 --file powerdevilrc --group AC --group Display --key DimDisplayWhenIdle --type bool false
  kwriteconfig6 --file powerdevilrc --group AC --group Display --key TurnOffDisplayIdleTimeoutSec 1800
  kwriteconfig6 --file powerdevilrc --group AC --group SuspendAndShutdown --key AutoSuspendIdleTimeoutSec 3600
  kwriteconfig6 --file powerdevilrc --group AC --group SuspendAndShutdown --key PowerButtonAction 8
}

{
  system_setup
  packages_setup
  home_setup
  services_setup
  kde_setup
} > /dev/null
