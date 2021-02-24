#!/usr/bin/env bash

## manual: install firmware-realtek_*_all.deb https://packages.debian.org/buster/all/firmware-realtek/download
## connect to internet then: apt update && apt install -y wpasupplicant
## setup wpasupplicant:
## - https://unix.stackexchange.com/questions/537235/getting-wpa-supplicant-to-work-on-boot-in-debian-10

# as root:
echo 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev' > /etc/wpa_supplicant/wpa_supplicant.conf
wpa_passphrase $SSID_NAME $SSID_PASS >> /etc/wpa_supplicant/wpa_supplicant.conf

cat <<EOF >> /etc/network/interfaces.d/wlp2s5.conf
allow-hotplug wlp2s5
iface wlp2s5 inet dhcp
        wpa-ssid $(awk -F\" '/ssid/{print $2}' /etc/wpa_supplicant/wpa_supplicant.conf)
        wpa-psk $(awk -F= '/psk/{print $2}' /etc/wpa_supplicant/wpa_supplicant.conf)
EOF

ifup wlp2s5
systemctl reenable wpa_supplicant.service
systemctl restart wpa_supplicant.service

sed -i -e '/^#PermitRootLogin/s/^#//' -e '/^PermitRootLogin/s/ .*$/ yes/' /etc/ssh/sshd_config
systemctl restart sshd.service

# that's it! Rest you can do over ssh:

sed -i -e '/^#HandleLidSwitch/s/^#//' -e '/^HandleLidSwitch/s/=.*/=lock/' /etc/systemd/logind.conf

apt-get install --no-install-recommends \
    iw libwrap0 openssh-server powertop shared-mime-info wireless-regdb xdg-user-dirs htop

apt-get autoremove --assume-yes --purge \
    bind9-host \
    debian-faq \
    doc-debian \
    ispell \
    laptop-detect \
    manpages \
    nano \
    tasksel \
    bluetooth \
    bluez

# todo what else do we need?

# things to consider:
# - https://www.omgubuntu.co.uk/improve-battery-life-linux
# - https://fosspost.org/7-tips-to-reduce-battery-usage-on-linux/

