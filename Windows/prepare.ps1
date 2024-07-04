scoop install git
git clone https://github.com/setup/gchait.git "${HOME}\setup"

scoop update -a
scoop bucket add extras *> ${null}

scoop install `
    wget grep fastfetch spotify vscode `
    windows-terminal ccleaner draw.io

reg import "${HOME}\scoop\apps\vscode\current\install-context.reg" *> ${null}
reg import "${HOME}\scoop\apps\vscode\current\install-associations.reg" *> ${null}

code `
    --install-extension ms-vscode-remote.remote-wsl `
    --install-extension catppuccin.catppuccin-vsc-icons `
    --install-extension eamodio.gitlens `
    --install-extension ecmel.vscode-html-css `
    --install-extension esbenp.prettier-vscode `
    --install-extension hashicorp.terraform `
    --install-extension kokakiwi.vscode-just `
    --install-extension ms-azuretools.vscode-docker `
    --install-extension ms-kubernetes-tools.vscode-kubernetes-tools `
    --install-extension ms-pyright.pyright `
    --install-extension pkief.material-product-icons `
    --install-extension redhat.vscode-yaml `
    --install-extension samuelcolvin.jinjahtml `
    --install-extension tamasfe.even-better-toml `
    --install-extension tinkertrain.theme-panda `
    | Select-String -NotMatch -Pattern "already installed" | % { $_.Line }

Copy-Item -Recurse -Force `
    -Path "${HOME}\setup\Windows\Home\*" `
    -Destination "${HOME}"
