#!/usr/bin/env zsh

export DEBIAN_FRONTEND=noninteractive

sudo apt-get upgrade -y

sudo apt-get install --quiet --assume-yes \
    git \
    zsh \
    vim \
    tmux \
    meld \
    tree \
    snapd \
    xclip \
    geary \
    kubectl \
    clamav \
    clamtk-gnome \
    moreutils \
    redshift \
    docker-ce \
    net-tools \
    terminator \
    python-pip \
    golang-go \
    "golang-$GOLANG_VERSION-go" \
    source-highlight \
    network-manager-openvpn \
    network-manager-openvpn-gnome \
    exfat-fuse exfat-utils \ # allow mounting exfat filesystems
    openjdk-11-jdk-headless \
    &

typeset -A binApps
binApps=(\
    minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64\
    jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64\
    diff-so-fancy https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy\
)
for app downloadUrl in ${(kv)binApps}; do
    {
      curl -fsSL "$downloadUrl" -o "$HOME/bin/$app"
      chmod +x "$HOME/bin/$app"
    } &
done

# todo latest version
hashicorpApps=(\
    terraform 0.11.3 \
    vagrant 2.2.4 \
    packer 1.4.0 \
)
for app version in ${(kv)hashicorpApps}; do
    {
      curl -fsSL "https://releases.hashicorp.com/${app}/${version}/${app}_${version}_linux_amd64.zip" -o "/tmp/$app.zip"
      unzip -o "/tmp/$app.zip" -d "$HOME/bin"
    } &
done

{
  sourceCodeUrl="$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | $HOME/bin/jq -r '.assets[] | select( .name == "SourceCodePro.zip" ) | .browser_download_url')"
  curl -fsSL "$sourceCodeUrl" -o /tmp/sourceCodePro.zip
  mkdir -p "$HOME/.local/share/fonts/"
  unzip /tmp/sourceCodePro.zip -d "$HOME/.local/share/fonts/"
  fc-cache -f -v
} &

{
  doctlUrl="$(curl -s https://api.github.com/repos/digitalocean/doctl/releases/latest | jq -r '.assets[] | select( .name|endswith("linux-amd64.tar.gz") ) | .browser_download_url')"
  curl -fsSL "$doctlUrl" | tar xzvf - -C "$HOME/bin"
} &

{
  hugoUrl="$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | jq -r '.assets[] | select( .name|endswith("Linux-64bit.deb") ) | .browser_download_url')"
  curl -fsSL https://github.com/gohugoio/hugo/releases/download/v0.42.2/hugo_0.42.2_Linux-64bit.deb -o /tmp/hugo.deb
  sudo dpkg -i /tmp/hugo.deb
} &

{
  curl -o /tmp/keybase.deb -s https://prerelease.keybase.io/keybase_amd64.deb
  sudo dpkg -i /tmp/keybase.deb
  sudo apt-get install -f
  run_keybase
} &

sudo snap install spotify &
sudo snap install vlc &
sudo snap install atom --classic &
sudo snap install skype --classic &
sudo snap install intellij-idea-ultimate --classic &

# fonts
{
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
  sudo apt-get install ttf-mscorefonts-installer --no-install-recommends
} &

wait

#https://dl.google.com/android/repository/platform-tools-latest-linux.zip
sudo apt remove --purge \
  thunderbird \
  transmission-common \
  pix \
  hexchat \
  gnome-terminal \
  gnome-terminal-data \
  rhythmbox \
  rhythmbox-data \
  xplayer \
  tomboy \
  xserver-xorg-input-wacom \
  caribou
sudo apt autoremove --purge

sudo apt clean

# add go binaries to path
gobin="$(dirname $(dpkg -L "golang-$GOLANG_VERSION-go" | grep 'bin/go$'))"
echo "export PATH=$gobin:\$PATH" >> ~/.zshrc_local
