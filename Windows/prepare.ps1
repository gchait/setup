scoop install git *> ${null}
scoop bucket add extras *> ${null}
scoop update -a

scoop install `
    wget grep fastfetch spotify vscode `
    windows-terminal ccleaner draw.io

reg import "${HOME}\scoop\apps\vscode\current\install-context.reg" 2>&1
reg import "${HOME}\scoop\apps\vscode\current\install-associations.reg" 2>&1

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

if (Test-Path "${HOME}\setup") {
    git -C "${HOME}\setup" pull
} else {
    git clone https://github.com/gchait/setup.git "${HOME}\setup"
}

Copy-Item -Recurse -Force `
    -Path "${HOME}\setup\Windows\Home\*" `
    -Destination "${HOME}"
