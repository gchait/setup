\* Tested on Windows 10/11 with Fedora 41.

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

- Install the [font](./Assets/JuliaMono/).

### Debloat (as administrator)

```powershell
irm https://christitus.com/win | iex
```

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

- Open the Fedora App to complete the installation.

- ```shell
  sudo visudo
  ```

- ```shell
  curl -sL guyc.at/fedora.sh | sh
  ```

- ```shell
  wsl.exe --shutdown
  ```

- Open Windows Terminal.

### Optional: Support GUI apps

- Start an X server, e.g. [X410](https://x410.dev/download/).
- Enable a listener in the WSL network.
