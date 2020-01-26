# docker run --rm --device /dev/input -v /run/udev/data:/run/udev/data -v $(pwd):/workdir -w /workdir -it debian bash

# curl -fsSL https://github.com/Kitware/CMake/releases/download/v3.14.0/cmake-3.14.0-Linux-x86_64.tar.gz -o- | \
#   tar --strip-components=1 -xz -C /usr/local

echo 'deb http://http.us.debian.org/debian/ testing non-free contrib main' > /etc/apt/sources.list.d/debian-testing.list

apt-get update
apt-get install -y git gcc-8 curl make cmake build-essential libinput-dev zlib1g-dev libinput-tools libsystemd-dev

git clone -b v0.0.5 --single-branch --recurse-submodules -j8 https://github.com/Coffee2CodeNL/gebaar-libinput /workdir
mkdir -p /workdir/build
cd /workdir/build
cmake ..
make -j$(nproc)

sudo apt-get install -y libinput-tools xdotool

sudo gpasswd -a $USER input

ln -fs "$DOT_FILES/config/gebaar/gebaard.toml" "$HOME/.config/gebaar/gebaard.toml"
mkdir -p "$HOME/.local/share/systemd/user"
ln -fs "$DOT_FILES/config/systemd/gebaard.service" "$HOME/.local/share/systemd/user/gebaard.service"
