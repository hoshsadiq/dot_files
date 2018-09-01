#!/bin/bash

set -e

mkdir -p "$HOME/bin"
mkdir -p "$HOME/Workspace"

# todo ssh config

export GOLANG_VERSION="1.10"



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

chsh `whoami` -s `which zsh`

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

for file in ${DOT_FILES}/dots/*; do
    dot="$HOME/.$(basename $file)"
    echo "$dot -> $file"
    [ -f "$dot" ] &&  mv "$dot" "$DOT_FILES/backup/.$(basename $file)"
    ln -s "$file" "$dot"
done
