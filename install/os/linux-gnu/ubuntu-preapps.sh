source /etc/os-release

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BA07F4FB # Google keys
curl -fsSL https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
curl -fsSL "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key" | sudo apt-key add -

sudo add-apt-repository -y ppa:libratbag-piper/piper-libratbag-git
sudo apt-add-repository -y "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /"
sudo apt-add-repository -y 'deb http://apt.kubernetes.io/ kubernetes-xenial main'
sudo apt-add-repository -y 'deb http://repository.spotify.com stable non-free'

sudo apt-get update
