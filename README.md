# SSH keypack

## Overview

Effortlessly generate SSH keys with a streamlined BASH script. This script creates neatly organized archives with standardized
file names, public/private key pairs, and a matching checksum—perfect for secure and hassle-free storage.

## Dependencies

This script requires OpenSSH. For Debian-based distributions, you can install OpenSSH with:

```ssh
sudo apt install --yes openssh-client
```
## Usage

Create a symlink to your current user local binary folder to call `ssh-keypack` from shell.

```shell
chmod +x ssh-keypack.sh
ln -s ssh-keygen ~/.local/bin/ssh-keypack
```

You can then generate keys as follows:

```shell
ssh-keypack <algorithm> <user> <host> <optional:git-username> <optional:git-repository>
```

## Naming scheme

The fields marked with `<optional>` are meant for SSH keys to access specific repositories and may be omitted.

* Comment schema for generic SSH key: `<algorithm>-key-<unix-seconds-timestamp>-<user>@<host>`
* Comment schema for Git repository SSH key: `<algorithm>-key-<unix-seconds-timestamp>-<user>@<host>`

Filenames follow a scheme analogous to the SSH keys comment, but in the case of Git repository paths replace the character `/` with `+` to comply with filesystem naming restrictions.

The following extensions are used:

* `.ospubk`: public key in OpenSSH format
* `.ospk`: private key in OpenSSH format
* `.sha256`: SHA256 checkum of the private key