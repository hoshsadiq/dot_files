#!/bin/bash

set -ex

mkdir -p "$HOME/bin"
mkdir -p "$HOME/Workspace"

export GOLANG_VERSION="1.11"

# todo need to add other platforms (mac, windows)
if command -v apt-get &>/dev/null; then
    sudo apt-get update && sudo apt-get install git zsh tmux -y
elif command -v yum &>/dev/null; then
    sudo yum update && sudo yum install git zsh tmux -y
fi

sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zplugin/master/doc/install.sh)"

zshExec="$(which zsh)"
if command -v chsh >/dev/null; then
    if ! grep -Fq "$zshExec" /etc/shells; then
        command -v zsh | sudo tee -a /etc/shells
    fi
	sudo chsh "$(whoami)" -s "$zshExec"
else
     # todo validate this is cygwin running.
    echo "db_shell: $zshExec" >> /etc/nsswitch.conf
    sed -i 's#bash#/usr/bin/zsh#' /Cygwin.bat
fi

echo "Setting up dot_files"
DOT_FILES="$HOME/dot_files"
if [ ! -d "$DOT_FILES" ]; then
    git clone "git://github.com/hoshsadiq/dot_files.git" "$DOT_FILES"
fi

(test -d "$DOT_FILES" && cd "$DOT_FILES" && git pull)

echo "export DOT_FILES=\"$DOT_FILES\"" > ~/.zshrc
# shellcheck disable=SC2016
echo 'source $DOT_FILES/config/zsh/zshrc' >> ~/.zshrc

dots=($(find "$DOT_FILES/dots" -mindepth 1 -type f -printf "%P\n"))
for file in "${dots[@]}"; do
    dot="$HOME/.$file"
    abs_dot="$DOT_FILES/dots/$file"
    echo "$dot -> $abs_dot"
    [ -f "$dot" ] && mkdir -p "$(dirname $DOT_FILES/backup/.$file)" &&  mv "$dot" "$DOT_FILES/backup/.$file"
    ln -s "$abs_dot" "$dot"
done

# if [[ "$OSTYPE" == "darwin"* ]]; then
#    source "install/os/darwin.sh"
# elif [ -f "install/os/$OSTYPE.sh" ]; then
#    source "install/os/$OSTYPE.sh"
# else
#    echo "Platform not supported"
#    exit 1;
# fi

# source "install/generic.sh"
