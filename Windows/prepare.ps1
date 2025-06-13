scoop install git *> ${null}
scoop bucket add extras *> ${null}
scoop update -a

scoop install `
  wget grep fastfetch vscode telegram `
  windows-terminal ccleaner vlc bruno

reg import "${HOME}\scoop\apps\vscode\current\install-context.reg" *> ${null}
reg import "${HOME}\scoop\apps\vscode\current\install-associations.reg" *> ${null}

code `
  --install-extension antfu.icons-carbon `
  --install-extension bierner.markdown-mermaid `
  --install-extension eamodio.gitlens
  --install-extension ecmel.vscode-html-css `
  --install-extension esbenp.prettier-vscode `
  --install-extension formulahendry.code-runner `
  --install-extension hashicorp.terraform `
  --install-extension jonathanharty.gruvbox-material-icon-theme `
  --install-extension kokakiwi.vscode-just `
  --install-extension ms-azuretools.vscode-containers `
  --install-extension ms-azuretools.vscode-docker `
  --install-extension ms-kubernetes-tools.vscode-kubernetes-tools `
  --install-extension ms-pyright.pyright `
  --install-extension ms-vscode-remote.remote-wsl `
  --install-extension mvllow.rose-pine
  --install-extension redhat.java
  --install-extension redhat.vscode-yaml `
  --install-extension samuelcolvin.jinjahtml `
  --install-extension saoudrizwan.claude-dev `
  --install-extension sztheory.vscode-packer-powertools `
  --install-extension tamasfe.even-better-toml `
  --install-extension timonwong.shellcheck `
  --install-extension visualstudioexptteam.intellicode-api-usage-examples `
  --install-extension visualstudioexptteam.vscodeintellicode `
  --install-extension vmware.vscode-boot-dev-pack `
  --install-extension vmware.vscode-spring-boot `
  --install-extension vscjava.vscode-gradle `
  --install-extension vscjava.vscode-java-debug `
  --install-extension vscjava.vscode-java-dependency `
  --install-extension vscjava.vscode-java-pack `
  --install-extension vscjava.vscode-java-test `
  --install-extension vscjava.vscode-maven `
  --install-extension vscjava.vscode-spring-boot-dashboard `
  --install-extension vscjava.vscode-spring-initializr `
  *> ${null}

if (Test-Path "${HOME}\setup") {
  git -C "${HOME}\setup" reset --hard
  git -C "${HOME}\setup" pull
} else {
  git clone https://github.com/gchait/setup.git "${HOME}\setup"
}

Copy-Item -Recurse -Force `
  -Path "${HOME}\setup\Windows\Home\*" `
  -Destination "${HOME}"

Set-Content -Force -Path "${HOME}\.wslconfig" -Value $(@"
[wsl2]
guiApplications=false
memory=$([math]::Floor([math]::Ceiling((Get-CimInstance `
  -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB) * 0.625))GB
"@)
