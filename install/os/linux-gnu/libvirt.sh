#!/usr/bin/env bash

setIniVar() {
  local section="$1"
  local key="$2"
  local value="$3"
  local file="$4"

  newIniConf="$(awk -v section="$section" -v key="$key" -v value="$value" \
    'BEGIN {
      section_start_pat = "^\\["section"\\]";
      any_section_start_pat = " *\\[\\w+\\]"
      key_path = "^ *"key
    }
    $0 ~ section_start_pat {in_section=1; print; next}
    $0 ~ !section_start_pat && $0 ~ any_section_start_pat {in_section=0; print; next}

    in_section==1 && found==0 && $0 ~ key_path {print key"="value; found=1; next}
    $0 ~ any_section_start_pat && in_section==1 && found==0 {print key"="value"\n\n"$0; found=1; next}

    {print} ' "$file")"

    echo "$newIniConf" > "$file"
}

disableSystemdResolved() {
  sudo systemctl disable systemd-resolved.service
  sudo systemctl stop systemd-resolved
  setIniVar main dns default /etc/NetworkManager/NetworkManager.conf
  sudo rm /etc/resolv.conf
  sudo service network-manager restart
}

installVagrantLibvirt() {
  exec > >(sed 's/^/rust-apps (stdout): /')
  exec 2> >(sed 's/^/rust-apps (stderr): /' >&2)

  mkdir /tmp/vagrant_build
  trap 'rm -rf /tmp/vagrant_build' SIGQUIT SIGHUP

  sudo apt install qemu libvirt-daemon-system libvirt-clients ebtables dnsmasq-base nfs-common nfs-kernel-server &
  podman run -i --rm -v /tmp/vagrant_build:/build -w /build ubuntu bash <<'EOF' &
    apt install -y curl

    {
      version="$(curl -fsSL "https://releases.hashicorp.com/vagrant/" | awk -F/ '/href="\/[^"]+"/{print $3; exit}')"
      curl -fsSL https://releases.hashicorp.com/vagrant/${version}/vagrant_${version}_x86_64.deb -o /tmp/vagrant.deb
    } &

    {
      sed -i '/^# deb-src/s/# //' /etc/apt/sources.list
      apt update -y
      apt install -y build-essential libssl-dev pkg-config \
        qemu libvirt-daemon-system libvirt-clients ebtables dnsmasq-base \
        libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev
      apt-get build-dep vagrant ruby-libvirt
    } &

    wait

    dpkg -i /tmp/vagrant.deb

    vagrant plugin install vagrant-libvirt
    mv ~/.gem ~/.vagrant.d /build
EOF

  rm -rf ~/.gem ~/.vagrant.d &

  cat <<'EOF' | sudo tee /etc/sudoers.d/nfs-exports &
Cmnd_Alias VAGRANT_EXPORTS_CHOWN = /bin/chown 0\:0 /tmp/*
Cmnd_Alias VAGRANT_EXPORTS_MV = /bin/mv -f /tmp/* /etc/exports
Cmnd_Alias VAGRANT_NFSD_CHECK = /etc/init.d/nfs-kernel-server status
Cmnd_Alias VAGRANT_NFSD_START = /etc/init.d/nfs-kernel-server start
Cmnd_Alias VAGRANT_NFSD_APPLY = /usr/sbin/exportfs -ar
%sudo ALL=(root) NOPASSWD: VAGRANT_EXPORTS_CHOWN, VAGRANT_EXPORTS_MV, VAGRANT_NFSD_CHECK, VAGRANT_NFSD_START, VAGRANT_NFSD_APPLY
EOF

  wait

  mv /tmp/vagrant_build/* "$HOME"
}

# more info https://community.linuxmint.com/tutorial/view/1727
sudo modprobe kvm-intel
sudo apt-get install --assume-yes \
    libvirt-clients \
    libvirt-daemon-system \
    virtinst \
    virt-manager \
    virt-viewer \
    qemu \
    qemu-kvm \
    bridge-utils \
    ebtables \
    dnsmasq

sudo adduser "$USER" libvirt
newgrp libvirt

disableSystemdResolved

sudo service libvirtd restart

#curl -L https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2 -o $HOME/bin/docker-machine-driver-kvm2 && chmod +x $HOME/bin/docker-machine-driver-kvm2
#
#minikube start --vm-driver kvm2
