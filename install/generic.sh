if [[ "$OSTYPE" == "darwin"* ]] || [ "$OSTYPE" == "linux-gnu" ]; then
	pip install pip --upgrade

	pip install pip-autoremove --user --upgrade
	pip install --user virtualenv --upgrade

	PYENV="$HOME/Workspace/pyenv"

	for app in awscli; do
		virtualenv "$PYENV/$app"
		"$PYENV/$app/bin/pip" install "$app" --upgrade
	done
fi
