## Windows side

#### Setup

- ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  irm https://get.scoop.sh | iex
  ```

- ```powershell
  irm https://guyc.at/windows.ps1 | iex
  ```

#### De-bloat

```powershell
# As administrator
irm https://christitus.com/win | iex
```

#### Get Fedora

- ```powershell
  wsl --install --no-distribution
  ```
- Reboot.
- Install [this](https://apps.microsoft.com/detail/9npcp8drchsn).

## Fedora side

#### Setup

- Open the Fedora App to complete the installation.
- ```shell
  # Easy sudo
  sudo visudo
  ```
- ```shell
  curl -sL guyc.at/fedora.sh | bash -eux
  ```
- ```shell
  # To migrate to Systemd
  wsl.exe --shutdown
  ```

#### Optional: Support GUI apps

- Start an X server, e.g. [X410](https://x410.dev/download/).
- Enable a listener in the WSL network.
