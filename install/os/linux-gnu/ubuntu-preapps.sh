#!/usr/bin/env zsh

source /etc/os-release

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BA07F4FB # Google keys
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 75060AA4 # libcontainers

sudo add-apt-repository --no-update -y ppa:libratbag-piper/piper-libratbag-git
sudo apt-add-repository --no-update -y "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /"
sudo apt-add-repository --no-update -y 'deb http://apt.kubernetes.io/ kubernetes-xenial main'

sudo apt-get update
