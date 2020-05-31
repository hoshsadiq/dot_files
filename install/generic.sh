if [[ "$OSTYPE" == "darwin"* ]] || [ "$OSTYPE" == "linux-gnu" ]; then
  pip install pip --upgrade

  pip install pip-autoremove --user --upgrade
  pip install pip-upgrader --user --upgrade

  GO111MODULE=on go get -u github.com/go-delve/delve/cmd/dlv@latest
  GO111MODULE=on go get mvdan.cc/sh/v3/cmd/shfmt@latest
fi
