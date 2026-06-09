# dev configuration

a setup abstraction over installation managers and configs.

## usage

```bash
# install if not already installed and configure
bash ./setup.sh powershell ohmyposh # or any other thing in install/

# or run the install script directly
bash ./src/setup/ohmyposh.sh <install_dir>

# or just configure it (hopefully it's installed!)
bash ./configs/ohmyposh/config.sh
```

### ...but i'm on Windows!

two options to get bash on windows:

- Git for Windows installs bash (uses MinGW)
- Install MSYS2

to quickly use this repo on windows:

- download
  [win_bootstrap.ps1](https://raw.githubusercontent.com/gord0nf/software/refs/heads/main/win_bootstrap.ps1)
- run it to install Git for Windows
- clone this repo and use Git Bash

## organization

this repo automates the install and configuration of `thing`s. a `thing` is a
software or some other tool.

each thing has:

- `install/{MANAGER}/{THING}.sh`: script to install that thing with the chosen
  manager (e.g. apt).
  - individual usage like `{THING}.sh [<install_dir>]`
  - to force install, `FORCE=true {THING}.sh ...`

- (optional) `config/{THING}/` & `config/{THING}.sh`: the directory contains any
  config stuffs and the script is required to setup/link all the configuration
  to the current installation.
  - individual usage like `{THING}.sh`
  - to force install, `FORCE=true {THING}.sh`

things can be installed with several supported managers. if not passed into
`setup.sh`, it chooses the first available. install scripts for all things
supported by the manager are in `install/{MANAGER}`. each manager also defines
itself and any meta functions in `managers/{MANAGER}.sh`.

### yaml config

a yaml config can be supplied (see `examples/`), which is useful because a thing's config script
can look at the yaml config and hook things up differently.

if no yaml config is supplied as an arg, `setup.sh` looks for:

- `$SOFTWARE/.software.yml`
- `~/.software.yml`
