\* Tested on Windows 10/11 (LTSC, Pro, Business).

## Setup

- ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

- ```powershell
  irm https://get.scoop.sh | iex
  ```

- ```powershell
  irm https://guyc.at/windows.ps1 | iex
  ```

## Debloat (as administrator)

- ```powershell
  irm https://christitus.com/win | iex
  ```

- Go over all Tweaks and tick the desired ones, then Run Tweaks.

## Get a WSL distro

- ```powershell
  wsl --install --no-distribution
  ```

- Reboot.

- Install your distro of choice and see its README.

## Optional: Support GUI apps

- Start an X server, e.g. [X410](https://x410.dev/download/).
- Enable a listener in the WSL network.
