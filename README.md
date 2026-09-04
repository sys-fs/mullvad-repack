# mullvad-repack

This script replaces the systemd units included in the original Mullvad VPN
packages with sysvinit and runit scripts so that the Mullvad app can be used
on Devuan. The sysvinit scripts can be used on openrc systems.

## Usage

### Using apt (recommended)

The latest version of Mullvad VPN is available in an apt repository hosted on
GitHub Pages.

```sh
sudo curl -fsSLo /usr/share/keyrings/mullvad-repack.asc \
  https://sys-fs.github.io/mullvad-repack/KEY.asc

echo "deb [signed-by=/usr/share/keyrings/mullvad-repack.asc] https://sys-fs.github.io/mullvad-repack stable main" \
  | sudo tee /etc/apt/sources.list.d/mullvad-repack.list

sudo apt update && sudo apt install mullvad-vpn
```

### Manually patching locally

If you want an older version of Mullvad VPN you can build the package locally.

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
