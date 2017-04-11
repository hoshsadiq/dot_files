#!/bin/bash

# todo: install relevant packages
if [ "$OSTYPE" == "linux-gnu" ]; then
	if cat /etc/*release | grep ^NAME | grep Ubuntu; then
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

echo "Installing vim_runtime"
git clone git://github.com/amix/vimrc.git "$HOME/.vim_runtime"
/bin/bash "$HOME/.vim_runtime/install_awesome_vimrc.sh"

echo "Setting up dot_files"
DOT_FILES="$HOME/dot_files"
git clone git@github.com/hoshsadiq/dot_files.git "$DOT_FILES"

declare -a files=("gitconfig" "minttyrc" "zshrc" "gitignore" "inputrc" "screenrc" "Xresources" "zshenv")

## now loop through the above array
for file in "${files[@]}"
do
   [ -f "$HOME/.$file" ] &&  mv "$HOME/.$file" "$HOME/.$file"
	 ln -s "$DOT_FILES/$file" "$HOME/.$file"
done
