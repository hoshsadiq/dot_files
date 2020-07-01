#!/usr/bin/env zsh

# todo perhaps vscodium?
if ! command -v code >/dev/null; then
  >&2 echo "VS Code not installed, installing through snap"

  sudo snap install code
fi

extensions=()
extensions+=("mike-lischke.vscode-antlr4")
extensions+=("ms-vscode.Go")
extensions+=("ms-vsliveshare.vsliveshare")
extensions+=("fatihacet.gitlab-workflow")
extensions+=("rubbersheep.gi")
extensions+=("mads-hartmann.bash-ide-vscode")
extensions+=("rogalmic.bash-debug")
extensions+=("timonwong.shellcheck")
extensions+=("foxundermoon.shell-format")
extensions+=("ms-python.python")
extensions+=("mauve.terraform")
extensions+=("usernamehw.errorlens")
extensions+=("donjayamanne.githistory")
extensions+=("eamodio.gitlens")
extensions+=("Atlassian.atlascode")
extensions+=("wmaurer.vscode-jumpy")

#code --install-extension ms-vsliveshare.vsliveshare
