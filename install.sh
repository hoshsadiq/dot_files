#!/bin/bash

set -ex

mkdir -p "$HOME/bin"
mkdir -p "$HOME/Workspace"

export GOLANG_VERSION="1.11"

# todo this needs to be done platform agnostic
sudo apt-get update && sudo apt-get install git zsh -y

# if [[ "$OSTYPE" == "darwin"* ]]; then
#    source "install/os/darwin.sh"
# elif [ -f "install/os/$OSTYPE.sh" ]; then
#    source "install/os/$OSTYPE.sh"
# else
#    echo "Platform not supported"
#    exit 1;
# fi

# source "install/generic.sh"

# if [ ! -d "$HOME/.vim_runtime" ]; then
#     echo "Installing vim_runtime"
#     git clone git://github.com/amix/vimrc.git "$HOME/.vim_runtime"
#     /bin/bash "$HOME/.vim_runtime/install_awesome_vimrc.sh"
# fi

# (cd "$HOME/.vim_runtime" && git pull)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zplugin/master/doc/install.sh)"

if command -v chsh >/dev/null; then
	chsh "$(whoami)" -s "$(which zsh)"
else # todo validate this is cygwin running.
	echo "db_shell: $(which zsh)" >> /etc/nsswitch.conf
	sed -i 's#bash#/usr/bin/zsh#' /Cygwin.bat
fi

typeset -a zshPlugins
zshPlugins=(\
    zdharma/fast-syntax-highlighting\
    zsh-users/zsh-history-substring-search\
    zsh-users/zsh-autosuggestions\
)
for zshPlugin in "${zshPlugins[@]}"; do
    pluginDir="$HOME/.oh-my-zsh/custom/plugins/$(basename "$zshPlugin")"
    if [ ! -d "$pluginDir" ]; then
        git clone "https://github.com/$zshPlugin.git" "$pluginDir"
    fi
    (cd "$pluginDir" && git pull)
done

echo "Setting up dot_files"
DOT_FILES="$HOME/dot_files"
if [ ! -d "$DOT_FILES" ]; then
    git clone "git://github.com/hoshsadiq/dot_files.git" "$DOT_FILES"
fi

#(cd "$DOT_FILES" && git pull)

dots=($(find $DOT_FILES/dots -mindepth 1 -type f -printf "%P\n"))
for file in "${dots[@]}"; do
    dot="$HOME/.$file"
    abs_dot="$DOT_FILES/dots/$file"
    echo "$dot -> $abs_dot"
    [ -f "$dot" ] && mkdir -p "$(dirname $DOT_FILES/backup/.$file)" &&  mv "$dot" "$DOT_FILES/backup/.$file"
    ln -s "$abs_dot" "$dot"
done
