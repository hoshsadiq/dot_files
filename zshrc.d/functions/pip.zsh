pip_create_venv_and_install() {
    venv="$1"
    apps="$@"

    virtualenv "$PYENV/$venv"
    venvPip="$PYENV/$venv/bin/pip"

    for app in "$apps"; do
        if pip show "$app" &> /dev/null; then
            echo "Installing pip package $app"
            "$venvPip" install "$app" --upgrade
        fi

        pyenvAppPath="$PYENV/$venv/bin/$app"
        if [ -x "$pyenvAppPath" ]; then
            echo "Linking $HOME/bin/$app to $pyenvAppPath"
            ln -s "$pyenvAppPath" "$HOME/bin/$app"
        fi
    done
}
