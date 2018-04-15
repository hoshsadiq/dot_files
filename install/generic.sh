if [[ "$OSTYPE" == "darwin"* ]] || [ "$OSTYPE" == "linux-gnu" ]; then
  pip install pip --upgrade

  pip install pip-autoremove --user --upgrade
  pip install --user virtualenv --upgrade

  PYENV="$HOME/Workspace/pyenv"

  for app in awscli shyaml; do
    virtualenv "$PYENV/$app"
    "$PYENV/$app/bin/pip" install "$app" --upgrade
  done

  ln -s $PYENV/awscli/bin/aws $HOME/bin/aws
  ln -s $PYENV/awscli/bin/aws_completer $HOME/bin/aws_completer
  ln -s $PYENV/shyaml/bin/shyaml $HOME/bin/shyaml

  go get -u github.com/jtyr/gbt/cmd/gbt
  go get -u github.com/simplealpine/json2yaml
  go get -u github.com/simplealpine/yaml2json
fi
