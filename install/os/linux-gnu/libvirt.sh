# more info https://community.linuxmint.com/tutorial/view/1727
sudo modprobe kvm-intel
sudo apt-get install \
    virtinst \
    virt-manager \
    python-libvirt \
    libvirt-bin \
    qemu \
    qemu-kvm \
    virt-viewer \
    bridge-utils \
    ebtables \
    dnsmasq

sudo adduser $USER libvirt
newgrp libvirt

sudo service libvirtd restart

curl -L https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2 -o $HOME/bin/docker-machine-driver-kvm2 && chmod +x $HOME/bin/docker-machine-driver-kvm2

minikube start --vm-driver kvm2
