\* Tested on Debian 13 (WSL2).

## Setup

- Open the Debian app and complete the installation.

- ```shell
  sudo visudo
  ```

- ```shell
  sudo apt-get update && sudo apt-get install -y curl
  ```

- ```shell
  sh <(curl -sL guyc.at/debian.sh)
  ```

- ```shell
  wsl.exe --shutdown
  ```

- Open Windows Terminal.
