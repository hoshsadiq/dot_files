if [[ "$OSTYPE" == "darwin"* ]] || [ "$OSTYPE" == "linux-gnu" ]; then
  pip install pip --upgrade

  pip install pip-autoremove --user --upgrade
  pip install virtualenv --user --upgrade
  pip install pip-upgrader --user --upgrade

  PYENV="$HOME/Workspace/pyenv"

  for app in awscli shyaml; do
    virtualenv "$PYENV/$app"
    "$PYENV/$app/bin/pip" install "$app" --upgrade
  done

  ln -s $PYENV/awscli/bin/aws $HOME/bin/aws
  ln -s $PYENV/awscli/bin/aws_completer $HOME/bin/aws_completer
  ln -s $PYENV/awscli/bin/aws_zsh_completer.sh $HOME/bin/aws_zsh_completer.sh
  ln -s $PYENV/shyaml/bin/shyaml $HOME/bin/shyaml

  go get -u github.com/simplealpine/json2yaml
  go get -u github.com/simplealpine/yaml2json
  GO111MODULE=on go get -u github.com/go-delve/delve/cmd/dlv@latest
  GO111MODULE=on go get mvdan.cc/sh/v3/cmd/shfmt@latest
fi
