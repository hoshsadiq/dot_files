# If not running interactively, don't do anything
[[ -z "$PS1" ]] && return

if [[ "$OSTYPE" == "cygwin" ]]; then
	export CYGWIN="ntsec"
fi

# Set a local bin path
PATH="$HOME/bin:$PATH"
export DISPLAY=:0.0


# remove duplicate path entries
#export PATH=$(echo $PATH | awk -F: '

# include other files
[[ -r /etc/bash_completion ]] && . /etc/bash_completion # custom autocompletion
[[ -r ~/.bash_colors ]] && . ~/.bash_colors # colors
[[ -r ~/.bash_aliases ]] && . ~/.bash_aliases # aliases
[[ -r ~/.bash_functions ]] && . ~/.bash_functions # functions
[[ -r ~/.bash_prompt ]] && . ~/.bash_prompt # promps
[[ -r ~/.bash_completion ]] && . ~/.bash_completion # custom bash completition
[[ -r ~/.bash_local ]] && . ~/.bash_local # custom bash completition

# change the default pager for man to most
export MANPAGER="/usr/bin/most -s"
# bash settings
export EDITOR='vim'
# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace:erasedups
# append to history instead of replacing
shopt -s histappend
# reload history after every command
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# autocomplete for aliases
complete -A alias alias unalias

# autocomplete ssh commands
complete -W "$(echo `cat ~/.ssh/config | egrep '^Host ' | grep -v 'Host \*' | sort | uniq | sed 's/Host //' | tr ' ' '\n'`;)" scp sftp ssh
complete -W "$(echo `cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | grep -v "\["`;)" scp sftp ssh

# Show the date
#date +"%A %_d %B %Y"
#------------------------------------------
#------WELCOME MESSAGE---------------------
# customize this first message with a message of your choice.
# this will display the username, date, time, a calendar, the amount of users, and the up time.
clear
if command -v figlet > /dev/null; then
	# Gotta love ASCII art with figlet
	figlet "Welcome, " $USER;
else
	echo "Welcome, " $USER;
fi
echo -e ""
echo -ne "${COLOR_RED}Current date       : ${COLOR_CYAN}"; date
echo -ne "${COLOR_RED}Up time            : ${COLOR_CYAN}";uptime 2>/dev/null | sed 's/.*up \([^,]*\), .*/\1/'
# usage of /: df -h / | awk '/\// { print $5,"of",$2 }'
# total mem: free -mo 2>/dev/null | awk '/Mem:/ { print $2 }'
# total swap: free -mo 2>/dev/null | awk '/Swap:/ { print $2 }'
# mem free: free -mo 2>/dev/null | awk '/Mem:/ { print $4 }'
# swap free: free -mo 2>/dev/null | awk '/Swap:/ { print $4 }'
# processes running: ps -W | wc -l
echo -e  "${COLOR_RED}Kernel Information : ${COLOR_CYAN}"`uname -smr`
echo -e "\n${COLOR_RED}Memory stats       :${COLOR_CYAN} " ; free 2>/dev/null

