#!/usr/bin/env bash

## assumes setup.exe is in root folder
if ["$CURRENT_OS" == "cygwin"]; then
	alias cygsetup="cygstart /setup.exe"
fi

alias grep="grep --color"
alias reload=". ~/.bash_profile"

# Default to human readable figures
alias df='df -h'
alias du='du -h'

# Misc :)
alias less='less -r'
alias whence='type -a'
alias grep='grep --color'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias more='less'
alias path='echo -e ${PATH//:/\\n}'

# Some shortcuts for different directory listings
alias ls='ls -hF --color=tty --group-directories-first'
alias dir='ls --color=auto --format=vertical'
alias vdir='ls --color=auto --format=long'
alias ll='ls -l'
#alias lsd='ll | `which grep` --color=never "^d"'
alias lla='ll -a'
alias la='ls -A'
alias l='ls -CF'

## need a linux alternative!
if [ "$CURRENT_OS" == "cygwin" ]; then
	alias ip="ipconfig | grep -v 127.0.0.1 | awk '/IPv4/ { print $NF }' | sed -e 's/^/\t\t/'"
fi
alias extip='curl ifconfig.me'
alias ipinfo='curl ifconfig.me/all'

# This is GOLD for finding out what is taking so much space on your drives!
alias diskspace="du -S | sort -n -r | more"
# Show me the size (sorted) of only the folders in this directory
alias folders="find . -maxdepth 1 -type d -print | xargs du -sk | sort -rn"

# sometimes you're just not sure you want to delete something...
# assumes file exist. maybe create in install.sh?
alias trash='mv -t ~/.local/share/Trash/files --backup=t'

alias tab2space="find -name '*.php' -exec sed -i 's/\t/    /g' {} +"

#:q for bash
alias :q='read -s -n1 -p "Do you realy want to quit the shell? [y]|n "; if [ "$REPLY" = y -o "$REPLY" = Y -o "$REPLY" = " " -o "$REPLY" = "" ]; then exit; else echo; unset REPLY; fi'

# privileged access
if [ $UID -ne 0 ]; then
   #alias sudo='sudo '
   alias scat='sudo cat'
   alias svim='sudo vim'
   alias root='sudo su'
   alias reboot='sudo reboot'
   alias shutdown='sudo shutdown -t3 -h now'
fi

alias back='cd $OLDPWD'