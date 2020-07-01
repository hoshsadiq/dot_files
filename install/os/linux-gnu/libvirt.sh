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
