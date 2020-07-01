#!/usr/bin/env bash

# dell xps 15 setup

# grub
#sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/s/"$/ acpi_rev_override=5"/' /etc/default/grub
#sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/s/"$/ nouveau.modeset=0"/' /etc/default/grub
#sudo update-grub2

# todo look for entries in /efi, /boot, and /boot/efi
# systemd-boot
sudo sed -i '/^options/s/$/ acpi_rev_override=5/' /boot/efi/loader/entries/Pop_OS-current.conf
sudo sed -i '/^options/s/$/ nouveau.modeset=0/' /boot/efi/loader/entries/Pop_OS-current.conf
bootctl update

# install and configure TLP and PowerTOP
sudo add-apt-repository -y ppa:linrunner/tlp
sudo apt-get update

sudo apt-get install tlp tlp-rdw powertop
sudo tlp start
sudo ln -fs $DOT_FILES/config/tlp/tlp /etc/default/tlp

sudo add-apt-repository --yes ppa:graphics-drivers
sudo apt-get update
latest_version="$(apt-cache search nvidia| awk '/^nvidia-driver-[0-9]+/{print $1}' | sort -r -h | head -n 1)"
sudo apt-get install "$latest_version"

#gsettings_disabler=gsettings-app-autodisable-global-shorts
#git clone git@github.com:hoshsadiq/$gsettings_disabler.git "$HOME/Workspace/$gsettings_disabler"
#ln -fs "$HOME/Workspace/$gsettings_disabler/citrix-key-fixer.service" "$HOME/.local/share/systemd/user/citrix-key-fixer.service"
#systemctl --user enable citrix-key-fixer.service
#systemctl --user start citrix-key-fixer.service

# gnome now supports something similar to prime-select so we don't need the gpuoff service any more.
# in addition, this has similar functionality to bumblebee where you can run individual apps using the secondary gpu
# gpuoff
for service in powertop; do
  # sudo cp $DOT_FILES/systemd/gpuoff.service /lib/systemd/system/gpuoff.service
  sudo ln -fs $DOT_FILES/config/systemd/$service.service /lib/systemd/system/$service.service
  sudo systemctl enable $service
  sudo systemctl start $service
done
