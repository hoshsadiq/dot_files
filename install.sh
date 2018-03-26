#!/bin/bash

set -e

mkdir -p $HOME/bin

# todo ssh config

export GOLANG_VERSION="1.9"

if [[ "$OSTYPE" == "darwin"* ]]; then
	source "install/os/darwin.sh"
elif [ -f "install/os/$OSTYPE.sh" ]; then
	source "install/os/$OSTYPE.sh"
else
	echo "Platform not supported"
	exit 1;
fi

source "install/generic.sh"

if [ ! -d "$HOME/.vim_runtime" ]; then
	echo "Installing vim_runtime"
	git clone git://github.com/amix/vimrc.git "$HOME/.vim_runtime"
	/bin/bash "$HOME/.vim_runtime/install_awesome_vimrc.sh"
fi

zshHistorySubstringSearch="$HOME/.oh-my-zsh/custom/plugins/zsh-history-substring-search"
if [ ! -d "$zshHistorySubstringSearch" ]; then
	git clone https://github.com/zsh-users/zsh-history-substring-search.git "$zshHistorySubstringSearch"
	ln -s "$zshHistorySubstringSearch/zsh-history-substring-search.zsh" "$zshHistorySubstringSearch/zsh-history-substring-search.plugin.zsh"
fi

fastSyntaxHighlighting="$HOME/.oh-my-zsh/custom/plugins/fast-syntax-highlighting"
if [ ! -d "$fastSyntaxHighlighting" ]; then
	git clone https://github.com/zdharma/fast-syntax-highlighting.git "$fastSyntaxHighlighting"
fi

echo "Setting up dot_files"
DOT_FILES="$HOME/dot_files"
if [ ! -d "$DOT_FILES" ]; then
	git clone "git://github.com/hoshsadiq/dot_files.git" "$DOT_FILES"
fi

(cd "$DOT_FILES" && git pull)

declare -a files=("gitconfig" "minttyrc" "zshrc" "gitignore" "inputrc" "screenrc" "Xresources" "zshenv")

## now loop through the above array
for file in "${files[@]}"; do
		echo ".$file"
		[ -f "$HOME/.$file" ] &&  mv "$HOME/.$file" "$DOT_FILES/backup/.$file"
		ln -s "$DOT_FILES/$file" "$HOME/.$file"
done

mkdir -p "$HOME/.config/terminator"
ln -s "$DOT_FILES/terminator_config" "$HOME/.config/terminator/config"

echo ".oh-my-zsh/custom/plugins/hosh"
[ -d "$HOME/.oh-my-zsh/custom/plugins/hosh" ] && mv "$HOME/.oh-my-zsh/custom/plugins/hosh" "$DOT_FILES/backup/zsh_plugin"
ln -s "$DOT_FILES/zsh_plugin/hosh" "$HOME/.oh-my-zsh/custom/plugins/hosh"

mkdir "$HOME/Workspace"
