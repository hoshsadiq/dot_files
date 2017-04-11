#!/bin/bash

set -e

# todo: install relevant packages
if [ "$OSTYPE" == "linux-gnu" ]; then
	if cat /etc/*release | grep ^NAME | grep -q Ubuntu; then
		sudo apt-get install git zsh
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	else
		echo "Platform not supported"
		exit 1;
	fi
elif [[ "$OSTYPE" == "cygwin" ]]; then
	echo "We are cygwin! Installing apt-cyg..."
	wget -P ~/bin http://apt-cyg.googlecode.com/svn/trunk/apt-cyg
	chmod +x ~/bin/apt-cyg
	echo "Cygwin implementation not finalised"
	exit 1;
elif [[ "$OSTYPE" == "darwin"* ]]; then
	echo "Implement MacOS"
	exit 1;
else
	echo "Platform not supported"
	exit 1;
fi

if [ ! -d "$HOME/.vim_runtime" ]; then
	echo "Installing vim_runtime"
	git clone git://github.com/amix/vimrc.git "$HOME/.vim_runtime"
	/bin/bash "$HOME/.vim_runtime/install_awesome_vimrc.sh"
fi

powerlevel9k="$HOME/.oh-my-zsh/custom/themes/powerlevel9k"
if [ ! -d "$powerlevel9k" ]; then
	git clone https://github.com/bhilburn/powerlevel9k.git "$powerlevel9k"
fi

echo "Setting up dot_files"
DOT_FILES="$HOME/dot_files"
if [ ! -d "$DOT_FILES" ]; then
	git clone "git://github.com/hoshsadiq/dot_files.git" "$DOT_FILES"
fi

(cd "$DOT_FILES" && git pull)

declare -a files=("gitconfig" "minttyrc" "zshrc" "gitignore" "inputrc" "screenrc" "Xresources" "zshenv")

## now loop through the above array
for file in "${files[@]}"
do
   [ -f "$HOME/.$file" ] &&  mv "$HOME/.$file" "$DOT_FILES/.$file"
	 ln -s "$DOT_FILES/$file" "$HOME/.$file"
done
