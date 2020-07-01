#!/usr/bin/env zsh

set -eo pipefail

source ../../../zshrc.d/functions/os-functions.zsh
source ../../../zshrc.d/functions/github.zsh

export DEBIAN_FRONTEND=noninteractive
go_version="go1.14"

mkdir -p "$HOME/bin"
mkdir -p "$HOME/apps"

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
      exfat-fuse exfat-utils

  gh-get-latest-release jwilm/alacritty "-ubuntu_18_04_$(get-arch).deb" | \
      xargs curl -fsSL -o "/tmp/alacritty.deb" &

  curl -o /tmp/keybase.deb -s https://prerelease.keybase.io/keybase_amd64.deb &

  wait

  sudo dpkg -i "/tmp/alacritty.deb"

  sudo dpkg -i /tmp/keybase.deb || true
  sudo apt-get install -f -y
  run_keybase
} &

wait

{
  exec > >(sed 's/^/pip (stdout): /')
  exec 2> >(sed 's/^/pip (stderr): /' >&2)

  sudo -H python3 -m pip install --upgrade pip
} &

{
  exec > >(sed 's/^/gvm (stdout): /')
  exec 2> >(sed 's/^/gvm (stderr): /' >&2)

  [[ -d $HOME/.gvm ]] || bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
  source "$HOME/.gvm/scripts/gvm"
  gvm install "$go_version" -B
} &

{
  exec > >(sed 's/^/jq (stdout): /')
  exec 2> >(sed 's/^/jq (stderr): /' >&2)

  curl -fsSL -o "$HOME/bin/jq" "https://github.com/stedolan/jq/releases/latest/download/jq-linux64"
  chmod +x "$HOME/bin/jq"
} &

wait

source "$HOME/.gvm/scripts/gvm"
gvm use "$go_version"

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

      curl -fsSL "$downloadUrl" -o "$HOME/bin/$app"
      chmod +x "$HOME/bin/$app"
    } &
done

# other apps can be used through docker or something
hashicorpApps=(vagrant packer)
for app in "${hashicorpApps[@]}"; do
    {
      exec > >(sed "s/^/$app (stdout): /")
      exec 2> >(sed "s/^/$app (stderr): /" >&2)

      version="$(curl -fsSL "https://releases.hashicorp.com/$app/" | awk -F/ '/href="\/[^"]+"/{print $3; exit}')"
      curl -fsSL "https://releases.hashicorp.com/${app}/${version}/${app}_${version}_${OS}_${ARCH}.zip" -o "/tmp/$app.zip"
      unzip -q -o "/tmp/$app.zip" -d "$HOME/bin"
    } &
done

{
  exec > >(sed 's/^/tfenv (stdout): /')
  exec 2> >(sed 's/^/tfenv (stderr): /' >&2)

  curl -fsSL "https://api.github.com/repos/tfutils/tfenv/releases/latest" | \
    jq -r .tarball_url | \
    xargs curl -fsSL -o- | \
    tar --strip-components=1 \
        --exclude='test' \
        --exclude='.*' \
        --exclude='*.md' \
        --exclude='LICENSE' \
        --directory="$HOME/.local" \
        --extract \
        --gzip \
        --verbose \
        --file -
} &

#{
#  exec > >(sed 's/^/git-hooks (stdout): /')
#  exec 2> >(sed 's/^/git-hooks (stderr): /' >&2)
#
#  curl -fsSL -o- https://github.com/git-hooks/git-hooks/releases/latest/download/git-hooks_${OS}_${ARCH}.tar.gz | \
#    tar -xzv --transform 's!.*/git-hooks_.*!git-hooks!' --show-transformed-names -C "$HOME/bin" -f-
#} &

{
  exec > >(sed 's/^/dive (stdout): /')
  exec 2> >(sed 's/^/dive (stderr): /' >&2)

    gh-get-latest-release wagoodman/dive "_$(get-os)_$(get-arch).deb" | \
    xargs curl -fsSL | \
    dpkg-deb --fsys-tarfile - | \
    tar -xvf - --strip-components=3 --directory $(systemd-path user-binaries) usr/local/bin/dive

    # todo:
    # mkdir -p ~/.config/dive
    # ln -fs $DOT_FILES/config/dive $HOME/.config/dive
} &

{
  exec > >(sed 's/^/jiq (stdout): /')
  exec 2> >(sed 's/^/jiq (stderr): /' >&2)

  curl -fsSL -o "$HOME/bin/jiq" "https://github.com/fiatjaf/jiq/releases/latest/download/jiq_${OS}_${ARCH}"
  chmod +x "$HOME/bin/jiq"
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
#      tar xzvf - -C "$HOME/bin"
#} &

{
  exec > >(sed 's/^/gojq (stdout): /')
  exec 2> >(sed 's/^/gojq (stderr): /' >&2)

   gh-get-latest-release itchyny/gojq "$(get-os)_$(get-arch).tar.gz" | \
      xargs curl -fsSL $goJqUrl -o- | \
      tar -xzf - -C "$HOME/bin" --strip-components=1 --wildcards 'gojq*/gojq'
} &

#{
#  exec > >(sed 's/^/speedtest-cli (stdout): /')
#  exec 2> >(sed 's/^/speedtest-clie (stderr): /' >&2)
#
#  curl -fsSL -o $HOME/bin/speedtest-cli https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
#  chmod +x $HOME/bin/speedtest-cli
#  # or perhaps the official client, which requires accepting licenses
#  # todo manpage is in same dir
#  #curl -fsSL -o- "https://bintray.com/ookla/download/download_file?file_path=ookla-speedtest-1.0.0-x86_64-linux.tgz" | tar --directory $HOME/bin -xzvf - speedtest
#} &

{
  exec > >(sed 's/^/bitwarden (stdout): /')
  exec 2> >(sed 's/^/bitwarden (stderr): /' >&2)

  curl -fsSL "https://vault.bitwarden.com/download/?app=desktop&platform=linux" -o "$HOME/apps/bitwarden.AppImage"
  chmod +x "$HOME/apps/bitwarden.AppImage"
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

{
  exec > >(sed 's/^/go-delve (stdout): /')
  exec 2> >(sed 's/^/go-delve (stderr): /' >&2)

  go get -u github.com/go-delve/delve/cmd/dlv || echo "go-delve installion failed, skipping."
} &

{
  exec > >(sed 's/^/goimports (stdout): /')
  exec 2> >(sed 's/^/goimports (stderr): /' >&2)

  go get -u golang.org/x/tools/cmd/goimports
} &

{
  exec > >(sed 's/^/gosec (stdout): /')
  exec 2> >(sed 's/^/gosec (stderr): /' >&2)

  go get -u github.com/securego/gosec/cmd/gosec &
} &

{
  exec > >(sed 's/^/podman-compose (stdout): /')
  exec 2> >(sed 's/^/podman-compose (stderr): /' >&2)

  curl -fsSL -o ~/.local/bin/podman-compose https://raw.githubusercontent.com/containers/podman-compose/devel/podman_compose.py
  chmod +x ~/.local/bin/podman-compose
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
)

# These remove pop-desktop
#  bind9-host \
#  gnome-terminal \
#  gnome-terminal-data \

for app in "${remove_apps[@]}"; do
  sudo apt-get autoremove --purge --assume-yes $app || true
done

sudo apt-get clean

