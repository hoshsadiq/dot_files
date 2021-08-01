#!/usr/bin/env zsh

set -eo pipefail

source ../../../zshrc.d/functions/os-functions.zsh
source ../../../zshrc.d/functions/github.zsh

export DEBIAN_FRONTEND=noninteractive
go_version="go1.14"

mkdir -p "$HOME/bin"
mkdir -p "$HOME/apps"

bin_dir="$(systemd-path user-binaries)"
hashicorp-get-latest-app-version() {
  app="$1"
  curl -fsSL "https://releases.hashicorp.com/$app/" | awk -F/ '/href="\/[^"]+"/{print $3; exit}'
}

sudo apt-get upgrade -y || true

{
  exec > >(sed 's/^/apt (stdout): /')
  exec 2> >(sed 's/^/apt (stderr): /' >&2)

  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
  sudo apt-get install --no-install-recommends --quiet --assume-yes \
      git \
      zsh \
      vim \
      tmux \
      meld \
      xclip \
      piper \
      bison \
      uidmap slirp4netns podman fuse-overlayfs \
      kubectl \
      wmctrl \
      clamav \
      clamtk-gnome \
      moreutils \
      net-tools \
      python3 \
      python3-pip \
      spotify-client \
      shellcheck \
      apt-transport-https \
      ttf-mscorefonts-installer \
      network-manager-openvpn \
      network-manager-openvpn-gnome \
      exfat-fuse exfat-utils \
      libnotify-bin

  gh-get-latest-release VSCodium/vscodium "_amd64.deb" | \
      xargs curl -fsSL -o "/tmp/vscodium.deb" &
  # todo also download _amd64.deb.sha256 and verify

  {
    vagrant_version="$(hashicorp-get-latest-app-version vagrant)"
    curl -fsSL https://releases.hashicorp.com/vagrant/${vagrant_version}/vagrant_${vagrant_version}_x86_64.deb -o /tmp/vagrant.deb
  } &

  curl -o /tmp/keybase.deb -s https://prerelease.keybase.io/keybase_amd64.deb &

  wait

  sudo dpkg -i /tmp/keybase.deb /tmp/vscodium.deb /tmp/vagrant.deb || true
  sudo apt-get install -f -y

  run_keybase

  systemctl enable --now --user podman.socket
  systemctl start --user podman.socket
} &

wait

{
  exec > >(sed 's/^/pip (stdout): /')
  exec 2> >(sed 's/^/pip (stderr): /' >&2)

  sudo -H python3 -m pip install --upgrade pip
} &

wait

# todo use asdf or move below stuff to zinit
OS="$(go env GOOS)"
ARCH="$(go env GOARCH)"

typeset -A binApps
binApps=(\
    minikube "https://storage.googleapis.com/minikube/releases/latest/minikube-${OS}-${ARCH}" \
)
for app downloadUrl in ${(kv)binApps}; do
    {
      exec > >(sed "s/^/$app (stdout): /")
      exec 2> >(sed "s/^/$app (stderr): /" >&2)

      curl -fsSL "$downloadUrl" -o "$bin_dir/$app"
      chmod +x "$bin_dir/$app"
    } &
done

#{
#  exec > >(sed 's/^/git-hooks (stdout): /')
#  exec 2> >(sed 's/^/git-hooks (stderr): /' >&2)
#
#  curl -fsSL -o- https://github.com/git-hooks/git-hooks/releases/latest/download/git-hooks_${OS}_${ARCH}.tar.gz | \
#    tar -xzv --transform 's!.*/git-hooks_.*!git-hooks!' --show-transformed-names -C "$bin_dir" -f-
#} &

{
  exec > >(sed 's/^/jiq (stdout): /')
  exec 2> >(sed 's/^/jiq (stderr): /' >&2)

  curl -fsSL -o "$bin_dir/jiq" "https://github.com/fiatjaf/jiq/releases/latest/download/jiq_${OS}_${ARCH}"
  chmod +x "$bin_dir/jiq"
} &

{
  exec > >(sed 's/^/nerd-fonts (stdout): /')
  exec 2> >(sed 's/^/nerd-fonts (stderr): /' >&2)

  curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/sourcecodepro.zip" -o /tmp/sourceCodePro.zip
  mkdir -p "$HOME/.local/share/fonts/"
  unzip -q -o /tmp/sourceCodePro.zip -d "$HOME/.local/share/fonts/"
  fc-cache -f -v
} &

#{
#  exec > >(sed 's/^/doctl (stdout): /')
#  exec 2> >(sed 's/^/doctl (stderr): /' >&2)
#
#  gh-get-latest-release digitalocean/doctl "$(get-os)-$(get-arch).tar.gz" | \
#      xargs curl -fsSL "$doctlUrl" | \
#      tar xzvf - -C "$bin_dir"
#} &

#{
#  exec > >(sed 's/^/speedtest-cli (stdout): /')
#  exec 2> >(sed 's/^/speedtest-clie (stderr): /' >&2)
#
#  curl -fsSL -o $bin_dir/speedtest-cli https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
#  chmod +x $bin_dir/speedtest-cli
#  # or perhaps the official client, which requires accepting licenses
#  # todo manpage is in same dir
#  #curl -fsSL -o- "https://bintray.com/ookla/download/download_file?file_path=ookla-speedtest-1.0.0-x86_64-linux.tgz" | tar --directory $bin_dir -xzvf - speedtest
#} &

# todo can flatpak install multiple applications in parallel?
{
  exec > >(sed 's/^/flatpak (stdout): /')
  exec 2> >(sed 's/^/flatpak (stderr): /' >&2)

  flatpak install -y flathub com.bitwarden.desktop \
                     flathub com.spotify.Client \
                     flathub org.libreoffice.LibreOffice \
                     flathub app/org.gnome.Todo/x86_64/stable \
                     flathub org.videolan.VLC \
                     flathub org.kde.krita
}&

{
  exec > >(sed 's/^/awscli (stdout): /')
  exec 2> >(sed 's/^/awscli (stderr): /' >&2)

  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -q -o awscliv2.zip

  # todo verify integrity: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html#v2-install-linux-validate

  sleep 0.5
  sudo ./aws/install || true
  rm -rf awscliv2.zip aws
} &

#{
#  exec > >(sed 's/^/rust (stdout): /')
#  exec 2> >(sed 's/^/rust (stderr): /' >&2)
#
#  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal --no-modify-path --quiet -y
#} &

#{
#  source /etc/os-release
#
#  exec > >(sed 's/^/alacritty (stdout): /')
#  exec 2> >(sed 's/^/alacritty (stderr): /' >&2)
#
#  mkdir /tmp/rustbuild
#  trap 'rm -rf /tmp/rustbuild' SIGQUIT SIGHUP
#  podman run -it --rm --entrypoint /bin/sh -v /tmp/rustbuild:/build ubuntu:$VERSION_ID -ec '
#    export DEBIAN_FRONTEND=noninteractive
#    apt update
#    apt install -y curl build-essential git cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev python3
#    curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal --no-modify-path --quiet -y
#    sleep 0.5
#    source /root/.cargo/env
#
#    cargo install alacritty
#    cp /root/.cargo/bin/alacritty /build
#  '
#  cp /tmp/rustbuild/alacritty $HOME/.local/bin
#
#  alacritty_version="$(alacritty --version | awk '{print $2}')"
#  curl -fsSL https://github.com/alacritty/alacritty/releases/download/v${alacritty_version}/Alacritty.svg -o ~/.local/share/icons/Alacritty.svg
#  curl -fsSL https://github.com/alacritty/alacritty/releases/download/v${alacritty_version}/Alacritty.desktop -o ~/.local/share/applications/Alacritty.desktop
#  curl -fsSL https://github.com/alacritty/alacritty/releases/download/v${alacritty_version}/alacritty.info | tic -xe alacritty,alacritty-direct -
#  curl -fsSL https://github.com/alacritty/alacritty/releases/download/v${alacritty_version}/alacritty.1.gz -o $HOME/.local/share/man/alacritty.1.gz
#} &

{
  exec > >(sed 's/^/rust-apps (stdout): /')
  exec 2> >(sed 's/^/rust-apps (stderr): /' >&2)

  mkdir /tmp/rustbuild
  trap 'rm -rf /tmp/rustbuild' SIGQUIT SIGHUP
  podman run -it --rm --entrypoint /bin/sh -v /tmp/rustbuild:/build ubuntu -ec '
    export DEBIAN_FRONTEND=noninteractive
    apt update
    apt install -y curl build-essential libssl-dev pkg-config
    curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal --no-modify-path --quiet -y
    source /root/.cargo/env

    cargo install rbw
    cp /root/.cargo/bin/rbw /root/.cargo/bin/rbw-agent /build
  '
  cp /tmp/rustbuild/* $HOME/.local/bin
} &

wait

exec > >(sed 's/^/cleanup (stdout): /')
exec 2> >(sed 's/^/cleanup (stderr): /' >&2)

#https://dl.google.com/android/repository/platform-tools-latest-linux.zip

remove_apps=( \
  thunderbird \
  transmission-common \
  pix \
  hexchat \
  rhythmbox \
  rhythmbox-data \
  xplayer \
  tomboy \
  xserver-xorg-input-wacom \
  caribou \
  rdate \
  libreoffice* \
)

# These remove pop-desktop
#  bind9-host \
#  gnome-terminal \
#  gnome-terminal-data \

for app in "${remove_apps[@]}"; do
  sudo apt-get remove --purge --assume-yes $app || true
done

sudo apt-get autoremove
sudo apt-get clean

