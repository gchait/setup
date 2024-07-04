- ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
  ```

- ```powershell
  Invoke-RestMethod -Uri https://guyc.at/windows.ps1 | Invoke-Expression
  ```

- ```powershell
  wsl --install --no-distribution
  wsl --update
  winget install 9NPCP8DRCHSN
  ```
