## My personal setup

### Windows side

##### Get Scoop

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

##### Bootstrap

```powershell
iwr -useb https://guyc.at/windows.ps1 | iex
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
curl -sL guyc.at/fedora.sh | bash -ex
```

##### Shutdown to migrate to Systemd

```shell
wsl.exe --shutdown
```
