if cat /etc/*release | grep ^NAME | grep -q Ubuntu; then
  curl -fsSL https://build.opensuse.org/projects/home:manuelschneid3r/public_key | sudo apt-key add -
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

  echo "deb http://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_17.10/ /" | sudo tee /etc/apt/sources.list.d/albert.list
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

  sudo apt-get update
  sudo apt-get install -y \
    git \
    zsh \
    vim \
    meld \
    xclip \
    albert \
    clamav \
    docker-ce \
    python-pip \
    $GOLANG_PKG \
    # allow mounting exfat filesystems
    exfat-fuse exfat-utils

  echo "Installing kubectl"
  kubectlLatest="$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
  kubectlUrl="https://storage.googleapis.com/kubernetes-release/release/$kubectlLatest/bin/linux/amd64/kubectl"
  sudo curl -L "$kubectlUrl" -s -o /usr/local/bin/kubectl
  sudo chmod +x /usr/local/bin/kubectl

  pip install pip --upgrade

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

  gobin="$(dirname $(dpkg -L golang-1.9-go | grep 'bin/go$'))"
  echo "export PATH=$gobin:\$PATH" >> ~/.zshrc_local

  $gobin/go get -u github.com/jtyr/gbt/cmd/gbt

  sudo groupadd docker
  sudo usermod -aG docker $USER
  newgrp docker
  sudo systemctl enable docker

  sudo curl -fsSL "https://s3-eu-west-1.amazonaws.com/record-query/record-query/x86_64-unknown-linux-gnu/rq" -o /usr/local/bin/rq
  sudo chmod +x /usr/local/bin/rq

  sourceCodeUrl="$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | rq -j 'at "assets" | spread | find (a => a.name == "SourceCodePro.zip") | at browser_download_url' | awk -F'","' -v OFS=, '{$1=$1;gsub(/^"|"$/,"")}1')"
  curl -fsSL "$sourceCodeUrl" -o /tmp/sourceCodePro.zip
  mkdir -p "$HOME/.local/share/fonts/"
  unzip /tmp/sourceCodePro.zip -d "$HOME/.local/share/fonts/"
  fc-cache -f -v


else
  echo "Platform not supported"
  exit 1;
fi
