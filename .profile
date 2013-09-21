# To the extent possible under law, the author(s) have dedicated all 
# copyright and related and neighboring rights to this software to the 
# public domain worldwide. This software is distributed without any warranty. 
# You should have received a copy of the CC0 Public Domain Dedication along 
# with this software. 
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>. 

# base-files version 4.1-1

# ~/.profile: executed by the command interpreter for login shells.

# The latest version as installed by the Cygwin Setup program can
# always be found at /etc/defaults/etc/skel/.profile

# Modifying /etc/skel/.profile directly will prevent
# setup from updating it.

# The copy in your home directory (~/.profile) is yours, please
# feel free to customise it to create a shell
# environment to your liking.  If you feel a change
# would be benificial to all, please feel free to send
# a patch to the cygwin mailing list.

# User dependent .profile file

# Set user-defined locale
# export LANG=$(locale -uU)
export LANG="en_GB.UTF-8"

if [[ "$OSTYPE" == "cygwin" ]]; then
	export CYGWIN="ntsec"
fi

# change the default pager for man to most
export MANPAGER="/usr/bin/most -s" 
# bash settings
export EDITOR='vim'
# Set a local bin path
export PATH="$PATH:$HOME/bin"
# X Server display
export DISPLAY=:0.0

# Show the date
#date +"%A %_d %B %Y"
#------------------------------------------
#------WELCOME MESSAGE---------------------
# customize this first message with a message of your choice.
# this will display the username, date, time, a calendar, the amount of users, and the up time.
# clear
if command -v figlet > /dev/null; then
	# Gotta love ASCII art with figlet
	figlet "Welcome, " $USER;
else
	echo "Welcome, " $USER;
fi
# usage of /: df -h / | awk '/\// { print $5,"of",$2 }'
# processes running: ps -W | wc -l
echo -e ""
echo -ne "${_color_red}Current date       :${_color_end} ${_color_cyan}";		echo -n $(date +"%A %_d %B %Y %H:%M");					echo -e  "${_color_end}"
echo -ne "${_color_red}Up time            :${_color_end} ${_color_cyan}";		uptime 2>/dev/null | sed 's/.*up \([^,]*\), .*/\1/';	echo -ne "${_color_end}"
echo -ne "${_color_red}Kernel Information :${_color_end} ${_color_cyan}";		uname -smr;												echo -ne "${_color_end}"
echo -e "\n${_color_red}Memory stats       :${_color_end} ${_color_cyan}" ;		free 2>/dev/null;										echo -ne "${_color_end}"
