#!/bin/bash

set -e

mkdir -p $HOME/bin

# todo ssh config

export GOLANG_VERSION="1.9"

#if [[ "$OSTYPE" == "darwin"* ]]; then
#	source "install/os/darwin.sh"
#elif [ -f "install/os/$OSTYPE.sh" ]; then
#	source "install/os/$OSTYPE.sh"
#else
#	echo "Platform not supported"
#	exit 1;
#fi
#
#source "install/generic.sh"

if [ ! -d "$HOME/.vim_runtime" ]; then
	echo "Installing vim_runtime"
	git clone git://github.com/amix/vimrc.git "$HOME/.vim_runtime"
	/bin/bash "$HOME/.vim_runtime/install_awesome_vimrc.sh"
fi

(cd "$HOME/.vim_runtime" && git pull)

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

(cd "$DOT_FILES" && git pull)

declare -a files=("gitconfig" "minttyrc" "zshrc" "gitignore" "gitattributes" "inputrc" "screenrc" "Xresources" "zshenv")
for file in "${files[@]}"; do
		echo ".$file"
		[ -f "$HOME/.$file" ] &&  mv "$HOME/.$file" "$DOT_FILES/backup/.$file"
		ln -s "$DOT_FILES/$file" "$HOME/.$file"
done

echo ".oh-my-zsh/custom/plugins/hosh"
[ -d "$HOME/.oh-my-zsh/custom/plugins/hosh" ] && mv "$HOME/.oh-my-zsh/custom/plugins/hosh" "$DOT_FILES/backup/zsh_plugin"
ln -s "$DOT_FILES/zsh_plugin/hosh" "$HOME/.oh-my-zsh/custom/plugins/hosh"

mkdir -p "$HOME/Workspace"
