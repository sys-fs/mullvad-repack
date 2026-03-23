# mullvad-repack
This script replaces the systemd units included in the original Mullvad VPN
packages with sysvinit and runit scripts so that the Mullvad app can be used
on Devuan. The sysvinit scripts can be used on openrc systems.

## Usage
```sh
# Fetch 2026.1 from GitHub and patch it.
./repack.sh 2026.1

# Patch a local file.
./repack.sh MullvadVPN-2026.1_amd64.deb

# Fetch 2026.1 for a different arch (e.g. arm64 if you're on amd64).
./repack.sh 2026.1 arm64
```

## Known issues
When installing the package on a runit system it says that mullvad-daemon fails
to start. Despite this message, the daemon is actually started and running
fine.

After upgrading the package you may need to reconnect to mullvad using `mullvad
reconnect`.
