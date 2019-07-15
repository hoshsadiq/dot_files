echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0EBFCD88
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BA07F4FB

curl -fsSL https://build.opensuse.org/projects/home:manuelschneid3r/public_key | sudo apt-key add -
curl -fsSL https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo apt-key add -

source /etc/upstream-release/lsb-release

sudo add-apt-repository -y ppa:geary-team/releases
sudo add-apt-repository -y ppa:gophers/archive
sudo add-apt-repository -y ppa:libratbag-piper/piper-libratbag-git

# todo fix java, need to install java10
# sudo add-apt-repository -y ppa:webupd8team/java
sudo add-apt-repository -y "deb http://download.opensuse.org/repositories/home:/manuelschneid3r/x${DISTRIB_ID}_${DISTRIB_RELEASE}/ /" # albert
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $DISTRIB_CODENAME stable"
sudo add-apt-repository -y "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $DISTRIB_CODENAME contrib"
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
