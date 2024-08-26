# My personal setup

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

##### De-bloat Windows
```powershell
# As Admin
irm https://christitus.com/win | iex
# Tweaks --> Standard
# Without `Disable Homegroup`
# Run Tweaks
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

### Launch Linux GUI apps from Windows
- Start an X server, [X410](https://x410.dev/download/) is the best in my opinion.
- Enable a listener in the WSL network.
- `export DISPLAY=...`. My `ij` (IntelliJ IDEA) alias in `.zshrc` is set to do this.
- You can also make a Windows shortcut for `C:\Windows\System32\wsl.exe zsh -ic ij`.
