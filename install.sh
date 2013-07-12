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
[ -d .ssh ] && mv .ssh .ssh.bak
[ ! -d .ssh ] && mkdir .ssh && chmod 700 .ssh
[ -d .irssi ] && mv .irssi .irssi.bak
[ ! -d .irssi ] && mkdir .irssi

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
ln -s $DIR/.ssh/config ~/.ssh/config
chmod 700 $DIR/.ssh/config

# irssi requires a bit more work
ln -s $DIR/.irssi/config ~/.irssi/config
ln -s $DIR/.irssi/default.theme ~/.ssh/default.theme

[ ! -d ~/.irssi/scripts ] && mkdir ~/.irssi/scripts
[ ! -d ~/.irssi/scripts/autorun ] && mkdir ~/.irssi/scripts/autorun
ln -s $DIR/.irssi/scripts/hilightwin.pl ~/.irssi/scripts/hilightwin.pl
ln -s $DIR/.irssi/scripts/irssinotifier.pl ~/.irssi/scripts/irssinotifier.pl
ln -s $DIR/.irssi/scripts/nickcolor.pl ~/.irssi/scripts/nickcolor.pl
ln -s $DIR/.irssi/scripts/usercount.pl ~/.irssi/scripts/usercount.pl
ln -s ~/.irssi/scripts/hilightwin.pl ~/.irssi/scripts/autorun/hilightwin.pl
ln -s ~/.irssi/scripts/irssinotifier.pl ~/.irssi/scripts/autorun/irssinotifier.pl
ln -s ~/.irssi/scripts/nickcolor.pl ~/.irssi/scripts/autorun/nickcolor.pl
ln -s ~/.irssi/scripts/usercount.pl ~/.irssi/scripts/autorun/usercount.pl

echo "┌─────────────────────────────────────────────────────────────────────────┐"
echo -e "│ \033[32mAll Linux configuration files are now installed.\033[0m                        │"
echo "├─────────────────────────────────────────────────────────────────────────┤"
echo "│ PhpStorm settings are available also.                                   │"
echo "│ Please import it manually using the following steps:                    │"
echo -e "│  1. Launch \033[35mPhpStorm\033[0m                                                     │"
echo -e "│  2. Click on \033[35mFile\033[0m                                                       │"
echo -e "│  3. Click on \033[35mImport Settings...\033[0m                                         │"
echo -e "│  4. Point the importer to \033[35m$DIR/PhpStorm.jar\033[0m"
echo "└─────────────────────────────────────────────────────────────────────────┘"