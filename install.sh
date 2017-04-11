#!/bin/bash

set -e

# todo install kubectl, awscli, awesome-patched fonts
# todo ssh config

if [ "$OSTYPE" == "linux-gnu" ]; then
	if cat /etc/*release | grep ^NAME | grep -q Ubuntu; then
		sudo apt-get update
		sudo apt-get install git zsh
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

		echo "Installing kubectl"
		kubectlLatest="$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
		kubectlUrl="https://storage.googleapis.com/kubernetes-release/release/$kubectlLatest/bin/linux/amd64/kubectl"
		sudo curl -L "$kubectlUrl" -s -o /usr/local/bin/kubectl
		sudo chmod +x /usr/local/bin/kubectl
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
	kubectlSuffix="windows/amd64/kubectl.exe"
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

zshHistorySubstringSearch="$HOME/.oh-my-zsh/custom/plugins/zsh-history-substring-search"
if [ ! -d "$zshHistorySubstringSearch" ]; then
	git clone https://github.com/zsh-users/zsh-history-substring-search.git "$zshHistorySubstringSearch"
	ln -s "$zshHistorySubstringSearch/zsh-history-substring-search.zsh" "$zshHistorySubstringSearch/zsh-history-substring-search.plugin.zsh"
fi

zshSyntaxGighlighting="$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
if [ ! -d "$zshSyntaxGighlighting" ]; then
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zshSyntaxGighlighting"
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
		[ -f "$HOME/.$file" ] &&  mv "$HOME/.$file" "$DOT_FILES/.$file"
		ln -s "$DOT_FILES/$file" "$HOME/.$file"
done

echo ".oh-my-zsh/custom/plugins/hosh"
[ -d "$HOME/.oh-my-zsh/custom/plugins/hosh"
ln -s "$DOT_FILES/zsh_plugin/hosh" "$HOME/.oh-my-zsh/custom/plugins/hosh"
