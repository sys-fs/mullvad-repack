#!/bin/bash
set -eo pipefail

if [ -z "$1" ]; then
    echo "usage: repack.sh version [init-system]"
    exit 1
fi
set -u

version="$1"

if [ -n "$2" ]; then
    init_system="$2"
else
    init_system="sysvinit"

    if [ -x /sbin/openrc-run ]; then
	init_system="openrc"
    elif [ -x /usr/bin/sv ]; then
	init_system="runit"
    fi
fi

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
if [ $init_system = "runit" ]; then
    mkdir -p repack/etc/sv
    cp -r "runit/mullvad-daemon" repack/etc/sv
else
    mkdir -p repack/etc/init.d
    cp "${init_system}/mullvad-daemon" repack/etc/init.d
fi

mkdir -p repack/etc/cron.d
cp mullvad-early-boot-blocking repack/etc/cron.d
chmod go-w repack/etc/cron.d/mullvad-early-boot-blocking

# Patch the packaging scripts.
patch -l repack/DEBIAN/preinst < "${init_system}/preinst.patch"
patch -l repack/DEBIAN/postinst < "${init_system}/postinst.patch"
patch -l repack/DEBIAN/prerm < "${init_system}/prerm.patch"

dpkg-deb --root-owner-group --build repack "${file%".deb"}-${init_system}.deb"
