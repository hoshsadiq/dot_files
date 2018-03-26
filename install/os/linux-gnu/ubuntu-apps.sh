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
    python-pip \
    source-highlight \
    golang-$GOLANG_VERSION \
    gnome-tweak-tool \
    chrome-gnome-shell \
    oracle-java9-installer oracle-java9-set-default oracle-java9-unlimited-jce-policy \
    # allow mounting exfat filesystems
    exfat-fuse exfat-utils

echo "Installing kubectl"
kubectlLatest="$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
kubectlUrl="https://storage.googleapis.com/kubernetes-release/release/$kubectlLatest/bin/linux/amd64/kubectl"
curl -fsSL "$kubectlUrl" -s -o $HOME/bin/kubectl
chmod +x $HOME/bin/kubectl

curl -fsSL https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -s -o $HOME/bin/minikube
chmod +x $HOME/bin/minikube

curl -fsSL https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -s -o $HOME/bin/jq
chmod +x $HOME/bin/jq

sourceCodeUrl="$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | jq -r '.assets[] | select( .name == "SourceCodePro.zip" ) | .browser_download_url')"
curl -fsSL "$sourceCodeUrl" -o /tmp/sourceCodePro.zip
mkdir -p "$HOME/.local/share/fonts/"
unzip /tmp/sourceCodePro.zip -d "$HOME/.local/share/fonts/"
fc-cache -f -v

sudo snap install spotify
sudo snap install vlc
sudo snap install skype --classic
sudo snap install intellij-idea-ultimate --classic

#https://dl.google.com/android/repository/platform-tools-latest-linux.zip
sudo apt autoremove --purge thunderbird

sudo apt clean
