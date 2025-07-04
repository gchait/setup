\* Tested on Windows 10/11 (LTSC, Pro, Business) with Fedora 41.

## Windows side

### Setup

- ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

- ```powershell
  irm https://get.scoop.sh | iex
  ```

- ```powershell
  irm https://guyc.at/windows.ps1 | iex
  ```

### Debloat (as administrator)

- ```powershell
  irm https://christitus.com/win | iex
  ```

- Go over all Tweaks and tick the desired ones, then Run Tweaks.

### Get Fedora

- ```powershell
  wsl --install --no-distribution
  ```

- Reboot.

- Install Fedora (pick one):
  - [Microsoft Store](https://apps.microsoft.com/detail/9npcp8drchsn)
  - [MSIX](https://github.com/VSWSL/Fedora-WSL/releases/tag/v41.0.1.0)

## Fedora side

### Setup

- Open the Fedora App and complete the installation.

- ```shell
  sudo visudo
  ```

- ```shell
  sh <(curl -sL guyc.at/fedora.sh)
  ```

- ```shell
  wsl.exe --shutdown
  ```

- Open Windows Terminal.

### Optional: Support GUI apps

- Start an X server, e.g. [X410](https://x410.dev/download/).
- Enable a listener in the WSL network.
