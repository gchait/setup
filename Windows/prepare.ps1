scoop install git *> ${null}
scoop bucket add extras *> ${null}
scoop update -a

scoop install `
  wget grep fastfetch vscode telegram `
  windows-terminal ccleaner vlc bruno

reg import "${HOME}\scoop\apps\vscode\current\install-context.reg" *> ${null}
reg import "${HOME}\scoop\apps\vscode\current\install-associations.reg" *> ${null}

code `
  --install-extension ms-vscode-remote.remote-wsl `
  --install-extension JonathanHarty.gruvbox-material-icon-theme `
  --install-extension antfu.icons-carbon `
  --install-extension mvllow.rose-pine `
  --install-extension eamodio.gitlens `
  --install-extension ecmel.vscode-html-css `
  --install-extension esbenp.prettier-vscode `
  --install-extension hashicorp.terraform `
  --install-extension kokakiwi.vscode-just `
  --install-extension ms-azuretools.vscode-docker `
  --install-extension ms-kubernetes-tools.vscode-kubernetes-tools `
  --install-extension timonwong.shellcheck `
  --install-extension ms-pyright.pyright `
  --install-extension redhat.vscode-yaml `
  --install-extension samuelcolvin.jinjahtml `
  --install-extension tamasfe.even-better-toml `
  --install-extension bierner.markdown-mermaid `
  --install-extension formulahendry.code-runner `
  --install-extension szTheory.vscode-packer-powertools `
  *> ${null}

if (Test-Path "${HOME}\setup") {
  git -C "${HOME}\setup" pull
} else {
  git clone https://github.com/gchait/setup.git "${HOME}\setup"
}

Copy-Item -Recurse -Force `
  -Path "${HOME}\setup\Windows\Home\*" `
  -Destination "${HOME}"
