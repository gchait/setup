$WINGET_PKGS = @(
  "7zip.7zip",
  "VideoLAN.VLC",
  "Telegram.TelegramDesktop"
)

$SCOOP_PKGS = @(
  "cacert",
  "fastfetch",
  "grep",
  "vscode",
  "wget",
  "windows-terminal"
)

$VSCODE_EXTENSIONS = @(
  "antfu.icons-carbon",
  "bierner.markdown-mermaid",
  "eamodio.gitlens",
  "ecmel.vscode-html-css",
  "esbenp.prettier-vscode",
  "formulahendry.code-runner",
  "hashicorp.terraform",
  "jonathanharty.gruvbox-material-icon-theme",
  "kokakiwi.vscode-just",
  "ms-azuretools.vscode-containers",
  "ms-azuretools.vscode-docker",
  "ms-kubernetes-tools.vscode-kubernetes-tools",
  "ms-pyright.pyright",
  "ms-vscode-remote.remote-wsl",
  "mvllow.rose-pine",
  "redhat.java",
  "redhat.vscode-yaml",
  "samuelcolvin.jinjahtml",
  "saoudrizwan.claude-dev",
  "sztheory.vscode-packer-powertools",
  "tamasfe.even-better-toml",
  "timonwong.shellcheck",
  "visualstudioexptteam.intellicode-api-usage-examples",
  "visualstudioexptteam.vscodeintellicode",
  "vmware.vscode-boot-dev-pack",
  "vmware.vscode-spring-boot",
  "vscjava.vscode-gradle",
  "vscjava.vscode-java-debug",
  "vscjava.vscode-java-dependency",
  "vscjava.vscode-java-pack",
  "vscjava.vscode-java-test",
  "vscjava.vscode-maven",
  "vscjava.vscode-spring-boot-dashboard",
  "vscjava.vscode-spring-initializr"
)

$FONTS_DIR = "${env:LOCALAPPDATA}\Microsoft\Windows\Fonts"
$FONT = "JuliaMono"

$WSL_MEMORY = "$([math]::Floor([math]::Ceiling((Get-CimInstance `
  -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB) * 0.625))GB"

Set-StrictMode -Version Latest

function WinGet-Setup {
  foreach (${pkg} in ${WINGET_PKGS}) {
    winget install --silent --exact `
      --accept-package-agreements `
      --accept-source-agreements `
      --id ${pkg} *> ${null}
  }
}

function Scoop-Setup {
  & {
    $env:PATH = "C:\Program Files\7-Zip;${env:PATH}"
    scoop config use_external_7zip true *> ${null}
    scoop install git *> ${null}
    scoop bucket add extras *> ${null}
    scoop update -a
    scoop install @SCOOP_PKGS
  }
}

function VSCode-Setup {
  reg import "${HOME}\scoop\apps\vscode\current\install-context.reg" *> ${null}
  reg import "${HOME}\scoop\apps\vscode\current\install-associations.reg" *> ${null}
  code @(${VSCODE_EXTENSIONS} | ForEach-Object { '--install-extension', ${_} }) *> ${null}
}

function Home-Setup {
  if (Test-Path "${HOME}\setup") {
    git -C "${HOME}\setup" reset --hard
    git -C "${HOME}\setup" pull
  } else {
    git clone https://github.com/gchait/setup.git "${HOME}\setup"
  }

  Copy-Item -Recurse -Force `
    -Path "${HOME}\setup\Windows\Home\*" `
    -Destination "${HOME}"

  Set-Content -Force -Path "${HOME}\.wslconfig" `
    -Value ((Get-Content -Path "${HOME}\setup\Windows\.wslconfig.tpl" -Raw) `
    -replace "{{WSL_MEMORY}}", "${WSL_MEMORY}").TrimEnd()
}

function Font-Setup {
  New-Item -ItemType Directory -Force -Path "${FONTS_DIR}" *> ${null}

  Get-ChildItem -Path "${HOME}\setup\Assets\${FONT}" -Filter "*.ttf" | ForEach-Object {
    if (-not (Test-Path "${FONTS_DIR}\$($_.Name)")) {
      Copy-Item -Force -Path $($_.FullName) -Destination "${FONTS_DIR}\$($_.Name)"
    }

    if (Test-Path "${FONTS_DIR}\$($_.Name)") {
      Set-ItemProperty -Force `
        -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" `
        -Name "$([System.IO.Path]::GetFileNameWithoutExtension($_.Name) -replace '-', ' ') (TrueType)" `
        -Value "${FONTS_DIR}\$($_.Name)"
    }
  }
}

WinGet-Setup
Scoop-Setup
VSCode-Setup
Home-Setup
Font-Setup
