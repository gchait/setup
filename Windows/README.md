```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

```powershell
iwr -useb guyc.at/windows.ps1 | iex
```

```powershell
wsl --install --no-distribution
wsl --update
winget install 9NPCP8DRCHSN
```
