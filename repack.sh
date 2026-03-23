#!/bin/bash
set -eo pipefail

if [ -z "$1" ]; then
    echo "usage: repack.sh version [arch]"
    exit 1
fi

version="$1"

if [ -z "$2" ]; then
    arch=$(dpkg --print-architecture)
else
    arch="$2"
fi

set -u

rm -rf repack

case "$version" in
    *".deb")
	file="$version"
	;;
    *)
	file="MullvadVPN-${version}_${arch}.deb"
	wget -nc "https://github.com/mullvad/mullvadvpn-app/releases/download/${version}/${file}"
	;;
esac

dpkg-deb -x "$file" repack
dpkg-deb -e "$file" repack/DEBIAN

# The only things in here are systemd units.
rm -rf repack/usr/lib

# Add init scripts.
mkdir -p repack/etc/{init.d,sv}
cp -r runit/mullvad-daemon repack/etc/sv/mullvad-daemon
cp sysv/mullvad-daemon repack/etc/init.d
cp sysv/mullvad-early-boot-blocking repack/etc/init.d

# Patch the packaging scripts.
patch -l repack/DEBIAN/preinst preinst.patch
patch -l repack/DEBIAN/postinst postinst.patch
patch -l repack/DEBIAN/prerm prerm.patch

dpkg-deb --root-owner-group --build repack "${file%".deb"}_repack.deb"
