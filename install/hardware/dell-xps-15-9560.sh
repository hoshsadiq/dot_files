#!/usr/bin/env bash

# dell xps 15 setup
sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/s/"$/ acpi_rev_override=5"/' /etc/default/grub
sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/s/"$/ nouveau.modeset=0"/' /etc/default/grub
sudo update-grub2

# install and configure TLP and PowerTOP
sudo add-apt-repository -y ppa:linrunner/tlp
sudo apt-get update

sudo apt-get install tlp tlp-rdw powertop
sudo tlp start
sudo ln -fs $DOT_FILES/config/tlp/tlp /etc/default/tlp

# todo need to install latest version of nvidia
# $ apt-cache search nvidia| grep nvidia-utils
# nvidia-utils-390 - NVIDIA driver support binaries

sudo apt-get install nvidia-prime
sudo prime-select intel

for service in gpuoff powertop; do
    # sudo cp $DOT_FILES/systemd/gpuoff.service /lib/systemd/system/gpuoff.service
    sudo ln -s $DOT_FILES/systemd/$service.service /lib/systemd/system/$service.service
    sudo systemctl enable $service
    sudo systemctl start $service
done
