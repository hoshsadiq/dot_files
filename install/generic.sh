if [[ "$OSTYPE" == "darwin"* ]] || [ "$OSTYPE" == "linux-gnu" ]; then
	pip install pip --upgrade

	pip install pip-autoremove --user --upgrade
	pip install --user virtualenv --upgrade

	PYENV="$HOME/Workspace/pyenv"

	for app in awscli; do
		virtualenv "$PYENV/$app"
		"$PYENV/$app/bin/pip" install "$app" --upgrade
	done

    go get -u github.com/jtyr/gbt/cmd/gbt
	go get -u github.com/simplealpine/json2yaml
	go get -u github.com/simplealpine/yaml2json
fi
