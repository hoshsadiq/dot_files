#!/usr/bin/env zsh

source ../../zshrc.d/functions/os-functions.zsh
source ../../zshrc.d/functions/github.zsh
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
    shellcheck \
    source-highlight \
    apt-transport-https \
    network-manager-openvpn \
    network-manager-openvpn-gnome \
    exfat-fuse exfat-utils \ # allow mounting exfat filesystems
    openjdk-11-jdk-headless \
    &

sudo -H python2 -m pip install --upgrade pip &
sudo -H python3 -m pip install --upgrade pip &

OS="$(go env GOOS)"
ARCH="$(go env GOARCH)"

{
  curl -fsSL -o "$HOME/bin/jq" "https://github.com/stedolan/jq/releases/latest/download/jq-linux64"
  chmod +x "$HOME/bin/jq"
}

typeset -A binApps
binApps=(\
    minikube "https://storage.googleapis.com/minikube/releases/latest/minikube-${OS}-${ARCH}" \
)
for app downloadUrl in ${(kv)binApps}; do
    {
      curl -fsSL "$downloadUrl" -o "$HOME/bin/$app"
      chmod +x "$HOME/bin/$app"
    } &
done

# other apps can be used through docker or something
hashicorpApps=(vagrant packer)
for app in "${hashicorpApps[@]}"; do
    {
      version="$(curl -fsSL "https://releases.hashicorp.com/$app/" | awk -F/ '/href="\/[^"]+"/{print $3; exit}')"
      curl -fsSL "https://releases.hashicorp.com/${app}/${version}/${app}_${version}_${OS}_${ARCH}.zip" -o "/tmp/$app.zip"
      unzip -o "/tmp/$app.zip" -d "$HOME/bin"
    } &
done

curl -fsSL "https://api.github.com/repos/tfutils/tfenv/releases/latest" | \
    jq -r .tarball_url | \
    xargs curl -fsSL -o- | \
    tar --transform='s#^tfenv-[^/]\+#tfenv#' --exclude='test' --exclude='.*' --exclude='*.md' --exclude='LICENSE' --directory='~/apps' --extract -gzip --verbose --file - &

curl -fsSL -o- https://github.com/git-hooks/git-hooks/releases/latest/download/git-hooks_${OS}_${ARCH}.tar.gz | \
    tar -xzv --transform 's!.*/git-hooks_.*!git-hooks!' --show-transformed-names -C "$HOME/bin" -f- &

{
  curl -fsSL -o "$HOME/bin/jiq" "https://github.com/fiatjaf/jiq/releases/latest/download/jiq_${OS}_${ARCH}"
  chmod +x "$HOME/bin/jiq"
} &

{
  curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/sourcecodepro.zip" -o /tmp/sourceCodePro.zip
  mkdir -p "$HOME/.local/share/fonts/"
  unzip /tmp/sourceCodePro.zip -d "$HOME/.local/share/fonts/"
  fc-cache -f -v
} &

{
  doctlUrl="$(gh-get-latest-release digitalocean/doctl "$(get-os)-$(get-arch).tar.gz")"
  curl -fsSL "$doctlUrl" | tar xzvf - -C "$HOME/bin"
} &

{
  gh-get-latest-release jwilm/alacritty "-ubuntu_18_04_$(get-arch).deb" | \
      xargs curl -fsSL -o "/tmp/alacritty.deb"
  sudo dpkg -i "/tmp/alacritty.deb"
} &

{
   goJqUrl="$(gh-get-latest-release itchyny/gojq "$(get-os)_$(get-arch).tar.gz")"
   curl -fsSL $goJqUrl -o- | tar -xzf - -C "$HOME/bin" --strip-components=1 --wildcards 'gojq*/gojq'
} &

{
  gh-get-latest-release gohugoio/hugo "Linux-64bit.deb" | grep -v extended | \
  xargs curl -fsSL -o- |
  tar -C "$HOME/bin" -xzvf -  hugo
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

{
  curl -fsSL -o $HOME/bin/speedtest-cli https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
  chmod +x $HOME/bin/speedtest-cli
  # or perhaps the official client, which requires accepting licenses
  # todo manpage is in same dir
  #curl -fsSL -o- "https://bintray.com/ookla/download/download_file?file_path=ookla-speedtest-1.0.0-x86_64-linux.tgz" | tar --directory $HOME/bin -xzvf - speedtest
} &

{
  curl -fsSL "https://vault.bitwarden.com/download/?app=desktop&platform=linux" -o "$HOME/apps/bitwarden.AppImage"
  chmod +x "$HOME/apps/bitwarden.AppImage"
}&

wait

#https://dl.google.com/android/repository/platform-tools-latest-linux.zip
sudo apt autoremove --purge \
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

sudo apt clean
