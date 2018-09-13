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

  go get -u github.com/jtyr/gbt/cmd/gbt
  go get -u github.com/simplealpine/json2yaml
  go get -u github.com/simplealpine/yaml2json
fi

version="$(curl -fsSL https://glide.sh/version)"
curl -fsSL "https://github.com/Masterminds/glide/releases/download/$version/glide-$version-$(uname|tr '[:upper:]' '[:lower:]')-amd64.tar.gz" | tar xzvf - -C $HOME/bin/ --strip-components=1 darwin-amd64/glide
