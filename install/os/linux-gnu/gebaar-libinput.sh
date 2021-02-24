#!/usr/bin/env bash

exec > >(sed 's/^/gebaar-libinput (stdout): /')
exec 2> >(sed 's/^/gebaar-libinput (stderr): /' >&2)

mkdir /tmp/gebaard
trap 'rm -rf /tmp/gebaard' SIGQUIT SIGHUP
{
  podman run --rm -it --device /dev/input -v /run/udev/data:/run/udev/data -v /tmp/gebaard:/workdir -w /workdir ubuntu bash -euo pipefail -c "$(cat <<-'EOF'
    export DEBIAN_FRONTEND=non-interactive
    apt-get update -q
    apt-get install -q -y git gcc-8 curl make cmake build-essential libinput-dev zlib1g-dev libinput-tools libsystemd-dev
    apt-get upgrade -q -y

    git clone --single-branch --recurse-submodules -j8 https://github.com/NICHOLAS85/gebaar-libinput.git /workdir
    mkdir -p /workdir/build
    cd /workdir/build
    cmake ..
    make -j$(nproc)
EOF
)"

  cp /tmp/gebaard/build/gebaard "$(systemd-path user-binaries)/gebaard"
} &

sudo apt-get install -y libinput-tools xdotool &

{
  sudo gpasswd -a $USER input

  mkdir -p "$HOME/.local/share/systemd/user" "$HOME/.config/gebaar/"
  ln -fs "$DOT_FILES/config/gebaar/gebaard.toml" "$HOME/.config/gebaar/gebaard.toml"
  ln -fs "$DOT_FILES/config/systemd/gebaard.service" "$HOME/.local/share/systemd/user/gebaard.service"
} &

wait

systemctl enable --user gebaard.service
systemctl start --user gebaard.service
