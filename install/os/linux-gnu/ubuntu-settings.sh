#!/usr/bin/env zsh

set -ex

getent group docker || sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker # todo this takes over the shell
sudo systemctl enable docker

sudo usermod -a -G vboxusers "$USER"

gsettings set org.gnome.settings-daemon.plugins.media-keys terminal ''

# gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.gnome.Geary.desktop', 'org.gnome.Calendar.desktop', 'firefox.desktop', 'spotify_spotify.desktop', 'intellij-idea-ultimate_intellij-idea-ultimate.desktop', 'atom_atom.desktop', 'whatsappdesktop.desktop']"

# add go binaries to path
gobin="$(dirname "$(dpkg -L "golang-$GOLANG_VERSION-go" | grep 'bin/go$')")"

echo "export JAVA_HOME='$(jrunscript -e 'java.lang.System.out.println(java.lang.System.getProperty("java.home"));')'" >> "$HOME/.zshrc"

echo "addpath $gobin after" >> "$HOME/.zshrc"
echo 'addpath "$HOME/.local/bin" after # pip install --user' >> "$HOME/.zshrc"

# system tweaks
sudo sed -i -E '/^GRUB_TIMEOUT/s/=[0-9]+$/=3/' /etc/default/grub

echo vm.swappiness=10 | sudo tee /etc/sysctl.d/60-swappiness.conf
echo fs.inotify.max_user_watches=524288 | sudo tee /etc/sysctl.d/60-intellij-inotify.conf

sudo sysctl -p --system

# fix spotify HiDPI scaling
sudo sed -i -E '/^Exec/s/$/ --force-device-scale-factor=2/g' /var/lib/snapd/desktop/applications/spotify_spotify.desktop

# nemo
gsettings set org.nemo.preferences show-open-in-terminal-toolbar true

gsettings set org.cinnamon.desktop.wm.preferences button-layout 'close,maximize,minimize:menu'
gsettings set org.cinnamon.desktop.wm.preferences mouse-button-modifier '<Alt>'
gsettings set org.cinnamon.desktop.wm.preferences theme 'Mint-Y-Dark'
gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Darker'

gsettings set org.cinnamon.desktop.notifications bottom-notifications true

gsettings set org.cinnamon.desktop.default-applications.terminal exec 'alacritty'

gsettings set org.cinnamon.desktop.screensaver lock-enabled true
gsettings set org.cinnamon.desktop.screensaver lock-delay "uint32 0"
gsettings set org.cinnamon.desktop.screensaver show-album-art false

gsettings set org.nemo.desktop trash-icon-visible true
gsettings set org.gnome.desktop.interface scaling-factor "uint32 2"
gsettings set org.cinnamon enable-indicators true
gsettings set org.cinnamon.settings-daemon.plugins.power lock-on-suspend true
gsettings set org.cinnamon alttab-switcher-style 'icons+thumbnails'

gsettings set org.cinnamon.desktop.keybindings looking-glass-keybinding "['<Shift><Super>l']"
gsettings set org.cinnamon.desktop.keybindings.wm unmaximize "[]"
gsettings set org.cinnamon.desktop.keybindings.wm toggle-maximized "[]"
gsettings set org.cinnamon.desktop.keybindings.wm toggle-fullscreen "['<Super>f']"
gsettings set org.cinnamon.desktop.keybindings.wm begin-resize "['<Super>r']"
gsettings set org.cinnamon.desktop.keybindings.wm begin-move "['<Super>m']"
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-left "['<Primary><Alt><Super>Left']"
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-right "['<Primary><Alt><Super>Right']"
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-up: "['<Primary><Alt><Super>Up']"
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-down: "['<Primary><Alt><Super>Down']"
gsettings set org.cinnamon.desktop.keybindings.wm move-to-workspace-left "['<Primary><Shift><Alt><Super>Left']"
gsettings set org.cinnamon.desktop.keybindings.wm move-to-workspace-right "['<Primary><Shift><Alt><Super>Right']"

gsettings set org.cinnamon.desktop.keybindings.media-keys terminal "[]"
gsettings set org.cinnamon.desktop.keybindings.media-keys volume-mute "[]"
gsettings set org.cinnamon.desktop.keybindings.media-keys volume-down "[]"
gsettings set org.cinnamon.desktop.keybindings.media-keys volume-up "[]"
gsettings set org.cinnamon.desktop.keybindings.media-keys mute-quiet "['AudioMute']"
gsettings set org.cinnamon.desktop.keybindings.media-keys volume-down-quiet "['AudioLowerVolume']"
gsettings set org.cinnamon.desktop.keybindings.media-keys volume-up-quiet "['AudioRaiseVolume']"
gsettings set org.cinnamon.desktop.keybindings.media-keys screensaver "['<Super>l']"

gsettings set org.cinnamon.settings-daemon.peripherals.touchpad tap-to-click false
gsettings set org.cinnamon.settings-daemon.peripherals.touchpad clickpad-click 2
gsettings set org.cinnamon.settings-daemon.peripherals.touchpad horizontal-scrolling true

gsettings set org.cinnamon.desktop.session idle-delay 600
gsettings set org.cinnamon.desktop.screensaver lock-delay 0

gsettings set org.cinnamon.settings-daemon.plugins.power idle-dim-time 300

gsettings set org.cinnamon.settings-daemon.plugins.power sleep-display-ac 1800
gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600
gsettings set org.cinnamon.settings-daemon.plugins.power lid-close-ac-action 'suspend'

gsettings set org.cinnamon.settings-daemon.plugins.power sleep-display-battery 600
gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-battery-timeout 900
gsettings set org.cinnamon.settings-daemon.plugins.power lid-close-battery-action 'suspend'

gsettings set org.cinnamon.sounds switch-enabled false

# ==> org.cinnamon <==
# next-applet-id: 20
# enabled-applets: ['panel1:right:3:systray@cinnamon.org:0', 'panel1:left:1:show-desktop@cinnamon.org:2', 'panel1:left:2:panel-launchers@cinnamon.org:3', 'panel1:left:3:window-list@cinnamon.org:4', 'panel1:right:5:keyboard@cinnamon.org:5', 'panel1:right:6:notifications@cinnamon.org:6', 'panel1:right:4:removable-drives@cinnamon.org:7', 'panel1:right:11:user@cinnamon.org:8', 'panel1:right:9:network@cinnamon.org:9', 'panel1:right:7:power@cinnamon.org:11', 'panel1:right:12:calendar@cinnamon.org:12', 'panel1:right:8:sound@cinnamon.org:13', 'panel1:right:2:inhibit@cinnamon.org:15', 'panel1:left:0:Cinnamenu@json:17', 'panel1:right:1:weather@mockturtl:18', 'panel1:right:0:stevedore@centurix:19']

# jq '."use-custom-format".value = true | ."custom-format".value = "%H:%M %a %d %b %Y"' ~/.cinnamon/configs/calendar@cinnamon.org/11.json | sponge ~/.cinnamon/configs/calendar@cinnamon.org/11.json
# jq '."peek-at-desktop".value = true' ~/.cinnamon/configs/show-desktop@cinnamon.org/20.json | sponge ~/.cinnamon/configs/show-desktop@cinnamon.org/20.json



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
# -

ln -s /usr/share/applications/org.gnome.Calendar.desktop /home/hosh/.config/autostart/org.gnome.Calendar.desktop
ln -s /usr/share/applications/org.gnome.Geary.desktop /home/hosh/.config/autostart/org.gnome.Geary.desktop
