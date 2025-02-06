### Launch Linux GUI apps from Windows

- Start an X server, [X410](https://x410.dev/download/) is the best in my opinion.
- Enable a listener in the WSL network.
- Example shortcut for IntelliJ IDEA: `C:\Windows\System32\wsl.exe zsh -ic ij`.

### De-bloat Windows

```powershell
# As Admin
irm https://christitus.com/win | iex
# Tweaks --> Standard
# Without `Disable Homegroup`
# Run Tweaks
```
