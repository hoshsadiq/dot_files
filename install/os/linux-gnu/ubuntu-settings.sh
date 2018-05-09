sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl enable docker

gsettings set org.gnome.settings-daemon.plugins.media-keys terminal ''

CUSTOM_KEYBINDING_NAME="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$CUSTOM_KEYBINDING_NAME name 'Terminator'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$CUSTOM_KEYBINDING_NAME command 'terminator'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$CUSTOM_KEYBINDING_NAME binding '<Primary><Alt>t'
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$CUSTOM_KEYBINDING_NAME']"

gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.gnome.Geary.desktop', 'org.gnome.Calendar.desktop', 'firefox.desktop', 'terminator.desktop', 'spotify_spotify.desktop', 'intellij-idea-ultimate_intellij-idea-ultimate.desktop', 'atom_atom.desktop', 'whatsappdesktop.desktop']"

mkdir -p "$HOME/.config/terminator"
ln -s "$DOT_FILES/config/terminator/config" "$HOME/.config/terminator/config"

echo "export JAVA_HOME='$(jrunscript -e 'java.lang.System.out.println(java.lang.System.getProperty("java.home"));')'" >> $HOME/.zshrc_local
echo 'export PATH=$PATH:$HOME/.local/bin # pip install --user' >> $HOME/.zshrc_local

# system tweaks
sudo sed -i -E '/^GRUB_TIMEOUT/s/=[0-9]+$/=3/' /etc/default/grub

echo vm.swappiness=10 | sudo tee /etc/sysctl.d/60-swappiness.conf

# fix spotify HiDPI scaling
sudo sed -i -E '/^Exec/s/$/ --force-device-scale-factor=2/g' /var/lib/snapd/desktop/applications/spotify_spotify.desktop
