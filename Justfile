shared := "Shared/common.sh"
wsl := "Shared/wsl-common.sh"
join := "awk 'FNR==1 && NR>1{print \"\"}1'"

build:
    {{ join }} {{ shared }} EndeavourOS/distro.sh > EndeavourOS/prepare.sh
    {{ join }} {{ shared }} {{ wsl }} Fedora/distro.sh > Fedora/prepare.sh
    {{ join }} {{ shared }} {{ wsl }} Ubuntu/distro.sh > Ubuntu/prepare.sh
