#!/bin/bash
set -eo pipefail

if [ -z "$1" ]; then
	echo "usage: repack.sh version"
	exit 1
fi
set -u

version="$1"
init_system="sysvinit"

if [ -x /sbin/openrc-run ]; then
	init_system="openrc"
elif [ -x /usr/bin/sv ]; then
	init_system="runit"
fi

rm -rf repack

wget -nc "https://github.com/mullvad/mullvadvpn-app/releases/download/${version}/MullvadVPN-${version}_amd64.deb"

dpkg-deb -x "MullvadVPN-${version}_amd64.deb" repack
dpkg-deb -e "MullvadVPN-${version}_amd64.deb" repack/DEBIAN

# The only things in here are systemd units.
rm -rf repack/usr/lib

# Add init scripts.
if [ $init_system = "runit" ]; then
	mkdir -p repack/etc/sv
	cp -r "${init_system}/mullvad-daemon" repack/etc/sv
else
	mkdir -p repack/etc/init.d
	cp "${init_system}/mullvad-daemon" repack/etc/init.d
fi

mkdir -p repack/etc/cron.d
cp mullvad-early-boot-blocking repack/etc/cron.d

# Patch the packaging scripts.
patch -l repack/DEBIAN/preinst < "${init_system}/preinst.patch"
patch -l repack/DEBIAN/postinst < "${init_system}/postinst.patch"
patch -l repack/DEBIAN/prerm < "${init_system}/prerm.patch"

dpkg-deb -b repack "mullvad-${version}-repack.deb"
