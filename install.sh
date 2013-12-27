#!/bin/bash
abspath=$(cd ${0%/*} && echo $PWD/${0##*/})
DIR=`dirname "$abspath"`
cd ~

[ -f .bashrc ] &&  mv .bashrc .bashrc.bak
[ -f .bash_aliases ] &&  mv .bash_aliases .bash_aliases.bak
[ -f .bash_colors ] &&  mv .bash_colors .bash_colors.bak
[ -f .bash_completion ] &&  mv .bash_completion .bash_completion.bak
[ -f .bash_functions ] &&  mv .bash_functions .bash_functions.bak
[ -f .bash_profile ] &&  mv .bash_profile .bash_profile.bak
[ -f .bash_prompt ] &&  mv .bash_prompt .bash_prompt.bak
[ -f .git_completion ] &&  mv .git_completion .git_completion.bak
[ -f .gitconfig ] &&  mv .gitconfig .gitconfig.bak
[ -f .profile ] &&  mv .profile .profile.bak
[ -f .vimrc ] &&  mv .vimrc .vimrc.bak
[ -f .wgetrc ] &&  mv .wgetrc .wgetrc.bak
[ -f .vimrc ] && mv .vimrc .vimrc.bak
[ -f .screenrc ] && mv .screenrc .screenrc.bak
[ -f .Xresources ] && mv .Xresources .Xresources.bak
[ -f .minttyrc ] && mv .minttyrc .minttyrc.bak
[ -d .ssh ] && mv .ssh/config .ssh/config.bak
[ -f ~/bin/updatepma ] && mv ~/bin/updatepma ~/bin/updatepma.bak
[ ! -d ~/bin ] && mkdir ~/bin

if command -v git > /dev/null; then 
	git clone git://github.com/amix/vimrc.git ~/.vim_runtime
	/bin/bash ~/.vim_runtime/install_awesome_vimrc.sh
else
    echo "┌─────────────────────────────────────────────────────────────────────────┐"
    echo -e "│ \033[31mgit is not installed. First install git and run the following commands:\033[0m │"
    echo "├─────────────────────────────────────────────────────────────────────────┤"
    echo "│ cd ~                                                                    │"
    echo "│ git clone git://github.com/amix/vimrc.git ~/.vim_runtime                │"
    echo "│ /bin/bash ~/.vim_runtime/install_awesome_vimrc.sh                       │"
    echo "└─────────────────────────────────────────────────────────────────────────┘"
fi

ln -s $DIR/.bashrc ~/.bashrc
ln -s $DIR/.bash_aliases ~/.bash_aliases
ln -s $DIR/.bash_colors ~/.bash_colors
ln -s $DIR/.bash_completion ~/.bash_completion
ln -s $DIR/.bash_functions ~/.bash_functions
ln -s $DIR/.bash_profile ~/.bash_profile
ln -s $DIR/.bash_prompt ~/.bash_prompt
ln -s $DIR/.git_completion ~/.git_completion
ln -s $DIR/.gitconfig ~/.gitconfig
ln -s $DIR/.profile ~/.profile
ln -s $DIR/.wgetrc ~/.wgetrc
ln -s $DIR/.inputrc ~/.inputrc
ln -s $DIR/.screenrc ~/.screenrc
ln -s $DIR/.Xresources ~/.Xresources
ln -s $DIR/.minttyrc ~/.minttyrc
ln -s $DIR/bin/updatepma ~/bin/updatepma
ln -s $DIR/.ssh/config ~/.ssh/config
chmod 700 $DIR/.ssh/config
chmod u+x ~/bin/updatepma

# apt-cyg to ~/bin if cygwin
if [[ "$OSTYPE" == "cygwin" ]]; then
	echo "We are cygwin! Installing apt-cyg..."
	wget -P ~/bin http://apt-cyg.googlecode.com/svn/trunk/apt-cyg
	chmod +x ~/bin/apt-cyg
fi
