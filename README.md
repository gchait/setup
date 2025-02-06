## My Windows + WSL setup

### Windows side

##### Get Scoop

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm https://get.scoop.sh | iex
```

##### Bootstrap

```powershell
irm https://guyc.at/windows.ps1 | iex
```

##### Get Fedora

```powershell
wsl --install --no-distribution
wsl --update
winget install 9NPCP8DRCHSN
```

### Fedora side

##### Bootstrap

```shell
curl -sL guyc.at/fedora.sh | bash -eux
```

##### Shutdown to migrate to Systemd

```shell
wsl.exe --shutdown
```
