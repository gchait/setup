# My personal setup

### Windows side

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

```powershell
iwr -useb https://guyc.at/windows.ps1 | iex
```

```powershell
wsl --install --no-distribution
wsl --update
winget install 9NPCP8DRCHSN
```

### Fedora side

```shell
curl -sL guyc.at/fedora.sh | bash -ex
```

```shell
wsl.exe --shutdown
```
