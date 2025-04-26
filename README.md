### Windows side

#### Setup

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

#### Debloat (as administrator)

```powershell
irm https://christitus.com/win | iex
```

#### Get Fedora

- ```powershell
  wsl --install --no-distribution
  ```

- Reboot.

- Install [this](https://apps.microsoft.com/detail/9npcp8drchsn).

### Fedora side

#### Setup

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

#### Optional: Support GUI apps

- Start an X server, e.g. [X410](https://x410.dev/download/).
- Enable a listener in the WSL network.
