#!/bin/bash
set -eo pipefail

if [ -z "$1" ]; then
    echo "usage: repack.sh version"
    exit 1
fi
set -u

version="$1"

rm -rf repack

case "$version" in
    *".deb")
	file="$version"
	;;
    *)
	file="MullvadVPN-${version}_$(dpkg --print-architecture).deb"
	wget -nc "https://github.com/mullvad/mullvadvpn-app/releases/download/${version}/${file}"
	;;
esac

dpkg-deb -x "$file" repack
dpkg-deb -e "$file" repack/DEBIAN

# The only things in here are systemd units.
rm -rf repack/usr/lib

# Add init scripts.
mkdir -p repack/etc/{cron.d,init.d,sv}
cp -r mullvad-daemon-runit repack/etc/sv/mullvad-daemon
cp mullvad-daemon repack/etc/init.d
cp mullvad-early-boot-blocking repack/etc/cron.d
chmod go-w repack/etc/cron.d/mullvad-early-boot-blocking

# Patch the packaging scripts.
patch -l repack/DEBIAN/preinst preinst.patch
patch -l repack/DEBIAN/postinst postinst.patch
patch -l repack/DEBIAN/prerm prerm.patch

dpkg-deb --root-owner-group --build repack "${file%".deb"}_repack.deb"
