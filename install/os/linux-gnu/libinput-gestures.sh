git clone http://github.com/bulletmark/libinput-gestures /tmp/libinput-gestures
(cd /tmp/libinput-gestures && sudo make install)

sudo apt-get install -y libinput-tools xdotool

sudo gpasswd -a $USER input

libinput-gestures-setup autostart

ln -s $DOT_FILES/config/libinput/libinput-gestures.conf ~/.config/libinput-gestures.conf
