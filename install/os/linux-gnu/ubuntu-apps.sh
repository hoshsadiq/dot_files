sudo apt-get install -y \
    git \
    zsh \
    vim \
    meld \
    xclip \
    geary \
    clamav \
    clamtk-gnome \
    docker-ce \
    net-tools \
    python-pip \
    source-highlight \
    golang-$GOLANG_VERSION \
    gnome-tweak-tool \
    chrome-gnome-shell \
    network-manager-openvpn network-manager-openvpn-gnome \
    oracle-java9-installer oracle-java9-set-default oracle-java9-unlimited-jce-policy \
    # allow mounting exfat filesystems
    exfat-fuse exfat-utils


kubectlDownloadUri="https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
typeset -A binApps
binApps=(\
    kubectl ${kubectlDownloadUri}\
    minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64\
    jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64\
    diff-so-fancy https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy\
)
for app downloadUrl in ${(kv)binApps}; do
    curl -fsSL "$downloadUrl" -o "$HOME/bin/$app"
    chmod +x "$HOME/bin/$app"
done

sourceCodeUrl="$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | jq -r '.assets[] | select( .name == "SourceCodePro.zip" ) | .browser_download_url')"
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

#https://dl.google.com/android/repository/platform-tools-latest-linux.zip
sudo apt remove --purge thunderbird
sudo apt autoremove --purge

sudo apt clean
