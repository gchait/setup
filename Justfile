shared := "Shared/common.sh"
wsl := "Shared/wsl-common.sh"

build:
    cat {{ shared }} EndeavourOS/distro.sh > EndeavourOS/prepare.sh
    cat {{ shared }} {{ wsl }} Fedora/distro.sh > Fedora/prepare.sh
    cat {{ shared }} {{ wsl }} Ubuntu/distro.sh > Ubuntu/prepare.sh
