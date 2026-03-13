set shell := ["bash", "-O", "globstar", "-c"]

shared := "Shared/header.sh Shared/common.sh"
wsl := "Shared/wsl-common.sh"

build:
    cat {{ shared }} EndeavourOS/distro.sh > EndeavourOS/prepare.sh
    cat {{ shared }} {{ wsl }} Fedora/distro.sh > Fedora/prepare.sh
    cat {{ shared }} {{ wsl }} Ubuntu/distro.sh > Ubuntu/prepare.sh

lint: build
    shfmt -l -w -i 2 -sr .
    shellcheck -s bash **/prepare.sh

deploy MSG: build
    git add -A
    git commit -m "{{ MSG }}"
    git push origin
