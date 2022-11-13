#!/bin/bash
set -eo pipefail

if [ -z "$1" ]; then
    echo "usage: repack.sh version"
    exit 1
fi
set -u

version="$1"

wget -nc "https://github.com/mullvad/mullvadvpn-app/releases/download/${version}/MullvadVPN-${version}_amd64.deb"

dpkg-deb -x "MullvadVPN-${version}_amd64.deb" repack
dpkg-deb -e "MullvadVPN-${version}_amd64.deb" repack/DEBIAN

# The only things in here are systemd units.
rm -rf repack/usr/lib

# Add OpenRC init scripts.
mkdir -p repack/etc/init.d
cp mullvad-daemon repack/etc/init.d
cp mullvad-early-boot-blocking repack/etc/init.d

# Patch the packaging scripts.
patch repack/DEBIAN/preinst < preinst.patch
patch repack/DEBIAN/postinst < postinst.patch
patch repack/DEBIAN/prerm < prerm.patch

dpkg-deb -b repack "mullvad-${version}-repack.deb"
