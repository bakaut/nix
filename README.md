# MacOs example to use nix package manager:

## Install:

```bash
curl -L https://nixos.org/nix/install | sh -s -- --daemon
mkdir ~/.config/ || true
cd ~/.config/
git clone git@github.com:bakaut/nix.git .
mkdir -p /nix/bin
sudo chown -r _nixbld1:staff /nix/bin # nix user, main user group
echo export PATH=$PATH:/nix/bin >> ~/.bashrc
echo export PATH=$PATH:/nix/bin >> ~/.zshrc
```

Tested on MacOs _version_

List of software intalled:
