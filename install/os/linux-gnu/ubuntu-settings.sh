#!/usr/bin/env zsh

set -ex

mkdir $HOME/.local/bin

# maybe?
#echo "export JAVA_HOME='$(jrunscript -e 'java.lang.System.out.println(java.lang.System.getProperty("java.home"));')'" >> "$HOME/.zshrc"

# system tweaks
sudo sed -i -E '/^GRUB_TIMEOUT/s/=[0-9]+$/=3/' /etc/default/grub

echo vm.swappiness=10 | sudo tee /etc/sysctl.d/60-swappiness.conf
echo fs.inotify.max_user_watches=524288 | sudo tee /etc/sysctl.d/60-intellij-inotify.conf

podman system migrate

sudo sysctl -p --system

sudo update-alternatives --install /usr/bin/python python "$(which python3)" 370 \
    --slave /usr/bin/pip pip "$(command -v pip3)"

# todo
#{
#  sudo sed -i -r '/^Checks/s/ [^$]+$/ 6/' /etc/clamav/freshclam.conf
#}

gsettings set org.gnome.desktop.default-applications.terminal exec 'alacritty'

gsettings set org.gnome.desktop.screensaver lock-enabled true
gsettings set org.gnome.desktop.screensaver lock-delay "uint32 0"

gsettings set org.gnome.desktop.interface scaling-factor "uint32 2"
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend true true
gsettings set org.gnome.desktop.notifications show-in-lock-screen false

gsettings set org.gnome.desktop.interface clock-format '24h'
gsettings set org.gtk.Settings.FileChooser clock-format '24h'


gsettings set org.gnome.desktop.wm.keybindings unmaximize "[]"
gsettings set org.gnome.desktop.wm.keybindings toggle-maximized "['<Super>m']"
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Super>f']"

gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click false
gsettings set org.gnome.desktop.peripherals.touchpad speed 0.75
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click false
gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true

gsettings set org.gnome.desktop.session idle-delay uint32 300
gsettings set org.gnome.desktop.screensaver lock-delay uint32 0

gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

gsettings set org.gnome.settings-daemon.plugins.power sleep-display-ac 1800
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend'

gsettings set org.gnome.settings-daemon.plugins.power sleep-display-battery 600
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 900
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'suspend'




# sudo ufw status
# sudo ufw default deny incomings
# sudo ufw default deny outgoing
#
# sudo ufw allow out http
# sudo ufw allow out https
# sudo ufw allow out 53

# todo
# - individual applets/extensions etc
#   see ~/.cinnamon/configs
# - spotify: sed -E -e '/^Exec/s/( %U)?$/ --force-device-scale-factor=2\1/g' -e 's#(/snap/spotify/)[0-9]+#\1current#' /var/lib/snapd/desktop/applications/spotify_spotify.desktop > ~/.local/share/applications/spotify.desktop

ln -s /usr/share/applications/org.gnome.Calendar.desktop /home/hosh/.config/autostart/org.gnome.Calendar.desktop
ln -s /usr/share/applications/org.gnome.Geary.desktop /home/hosh/.config/autostart/org.gnome.Geary.desktop
