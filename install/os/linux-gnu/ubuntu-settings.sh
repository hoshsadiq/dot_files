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

mkdir -p $HOME/.IntelliJIdea2017.3/config $HOME/.local/share/JetBrains/consentOptions
ln -s $HOME/dot_files/config/jetbrains/intellij-idea-ultimate/config/disabled_plugins.txt $HOME/.IntelliJIdea2017.3/config/disabled_plugins.txt
ln -s $HOME/dot_files/config/jetbrains/consentOptions/accepted $HOME/.local/share/JetBrains/consentOptions/accepted

mkdir -p "$HOME/.config/terminator"
ln -s "$DOT_FILES/config/terminator/config" "$HOME/.config/terminator/config"

echo "export JAVA_HOME='$(jrunscript -e 'java.lang.System.out.println(java.lang.System.getProperty("java.home"));')'" >> ~/.zshrc_local

# system tweaks
sudo sed -i -E '/^GRUB_TIMEOUT/s/=[0-9]+$/=3/' /etc/default/grub

echo vm.swappiness=10 | sudo tee /etc/sysctl.d/10-swappiness.conf

# disable annoying notification when extract files in the GUI
sudo mv /usr/bin/file-roller /usr/bin/file-roller_orig
sudo ln -s $HOME/dot_files/app_override/usr/bin/file-roller /usr/bin/file-roller
