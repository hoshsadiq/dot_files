sudo apt-get upgrade -y

sudo apt-get install -y \
    git \
    zsh \
    vim \
    tmux \
    meld \
    tree \
    snapd \
    xclip \
    geary \
    albert \
    kubectl \
    clamav \
    clamtk-gnome \
    redshift \
    docker-ce \
    net-tools \
    terminator \
    python-pip \
    golang-go \
    golang-$GOLANG_VERSION \
    source-highlight \
    network-manager-openvpn network-manager-openvpn-gnome \
    exfat-fuse exfat-utils \ # allow mounting exfat filesystems
    # oracle-java9-installer oracle-java9-set-default oracle-java9-unlimited-jce-policy # todo fix java

typeset -A binApps
binApps=(\
    minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64\
    jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64\
    diff-so-fancy https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy\
)
for app downloadUrl in ${(kv)binApps}; do
    curl -fsSL "$downloadUrl" -o "$HOME/bin/$app"
    chmod +x "$HOME/bin/$app"
done

sourceCodeUrl="$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | $HOME/bin/jq -r '.assets[] | select( .name == "SourceCodePro.zip" ) | .browser_download_url')"
curl -fsSL "$sourceCodeUrl" -o /tmp/sourceCodePro.zip
mkdir -p "$HOME/.local/share/fonts/"
unzip /tmp/sourceCodePro.zip -d "$HOME/.local/share/fonts/"
fc-cache -f -v

sudo snap install spotify
sudo snap install vlc
sudo snap install bitwarden
sudo snap install atom --classic
sudo snap install skype --classic
sudo snap install intellij-idea-ultimate --classic

hugoUrl="$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | jq -r '.assets[] | select( .name|endswith("Linux-64bit.deb") ) | .browser_download_url')"
curl -fsSL https://github.com/gohugoio/hugo/releases/download/v0.42.2/hugo_0.42.2_Linux-64bit.deb -o /tmp/hugo.deb
sudo dpkg -i /tmp/hugo.deb

curl -o /tmp/keybase.deb -s https://prerelease.keybase.io/keybase_amd64.deb
sudo dpkg -i /tmp/keybase.deb
sudo apt-get install -f
run_keybase

#https://dl.google.com/android/repository/platform-tools-latest-linux.zip
sudo apt remove --purge thunderbird transmission-common pix hexchat gnome-terminal gnome-terminal-data rhythmbox rhythmbox-data xplayer tomboy xserver-xorg-input-wacom
sudo apt autoremove --purge

sudo apt clean
