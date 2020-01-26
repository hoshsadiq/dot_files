#!/usr/bin/env zsh

source ../../zshrc.d/functions/os-functions.zsh
source /etc/upstream-release/lsb-release

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
    piper \
    kubectl \
    clamav \
    clamtk-gnome \
    moreutils \
    redshift \
    docker-ce \
    net-tools \
    python-pip \
    python3 \
    python3-pip \
    golang-go \
    "golang-$GOLANG_VERSION-go" \
    source-highlight \
    apt-transport-https \
    network-manager-openvpn \
    network-manager-openvpn-gnome \
    exfat-fuse exfat-utils \ # allow mounting exfat filesystems
    openjdk-11-jdk-headless \
    &

sudo -H python2 -m pip install --upgrade pip &
sudo -H python3 -m pip install --upgrade pip &

get-latest-gh-release() {
  repo="$1"
  endswith="$2"

  curl -s "https://api.github.com/repos/$repo/releases/latest" | jq --arg ending "$endswith" -r '.assets[] | select(.name | endswith($ending)).browser_download_url'
}

typeset -A binApps
binApps=(\
    minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64\
    jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64\
)
for app downloadUrl in ${(kv)binApps}; do
    {
      curl -fsSL "$downloadUrl" -o "$HOME/bin/$app"
      chmod +x "$HOME/bin/$app"
    } &
done

# todo latest version
hashicorpApps=(\
    vagrant 2.2.4 \
    packer 1.4.0 \
)
for app version in ${(kv)hashicorpApps}; do
    {
      curl -fsSL "https://releases.hashicorp.com/${app}/${version}/${app}_${version}_linux_amd64.zip" -o "/tmp/$app.zip"
      unzip -o "/tmp/$app.zip" -d "$HOME/bin"
    } &
done

curl -fsSL -o- http://github.com/tfutils/tfenv/archive/v1.0.2.tar.gz | \
    tar --transform='s#^tfenv-[^/]\+#tfenv#' --exclude='test' --exclude='.*' --exclude='*.md' --exclude='LICENSE' --directory='~/apps' --extract -gzip --verbose --file - &

{
  sourceCodeUrl="$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | $HOME/bin/jq -r '.assets[] | select( .name == "SourceCodePro.zip" ) | .browser_download_url')"
  curl -fsSL "$sourceCodeUrl" -o /tmp/sourceCodePro.zip
  mkdir -p "$HOME/.local/share/fonts/"
  unzip /tmp/sourceCodePro.zip -d "$HOME/.local/share/fonts/"
  fc-cache -f -v
} &

{
  doctlUrl="$(get-latest-gh-release digitalocean/doctl/releases/latest "$(get-os)-$(get-arch).tar.gz")"
  curl -fsSL "$doctlUrl" | tar xzvf - -C "$HOME/bin"
} &

{
  alacrittyUrl="$(get-latest-gh-release jwilm/alacritty "-ubuntu_18_04_$(get-arch).deb")"
  alacrittyFilename="$(basename "$alacrittyUrl")"
  curl -fsSL "$alacrittyUrl" -o "/tmp/$alacrittyFilename"
  sudo dpkg -i "/tmp/$alacrittyFilename"
} &

{
   goJqUrl="$(get-latest-gh-release itchyny/gojq "$(get-os)_$(get-arch).tar.gz")"
   curl -fsSL $goJqUrl -o- | tar -xzf - -C "$HOME/bin" --strip-components=1 --wildcards 'gojq*/gojq'
} &

{
  hugoUrl="$(get-latest-gh-release gohugoio/hugo "Linux-64bit.deb")"
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
  caribou \
  rdate \
  bind9-host \
  libbind9-90

sudo apt autoremove --purge

sudo apt clean
