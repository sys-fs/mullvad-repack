This script replaces the systemd units included in the original Mullvad VPN
packages with sysvinit or OpenRC scripts (depending on which is in use) so
that the Mullvad app can be used on Devuan.

I've found that after upgrading the package I need to reconnect to Mullvad, so
you may need to run `mullvad reconnect` after upgrading.
