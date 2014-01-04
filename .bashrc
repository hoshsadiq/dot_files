# To the extent possible under law, the author(s) have dedicated all 
# copyright and related and neighboring rights to this software to the 
# public domain worldwide. This software is distributed without any warranty. 
# You should have received a copy of the CC0 Public Domain Dedication along 
# with this software. 
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>. 

# base-files version 4.1-1

# ~/.bashrc: executed by bash(1) for interactive shells.

# The latest version as installed by the Cygwin Setup program can
# always be found at /etc/defaults/etc/skel/.bashrc

# Modifying /etc/skel/.bashrc directly will prevent
# setup from updating it.

# The copy in your home directory (~/.bashrc) is yours, please
# feel free to customise it to create a shell
# environment to your liking.  If you feel a change
# would be benifitial to all, please feel free to send
# a patch to the cygwin mailing list.

# User dependent .bashrc file

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# remove duplicate path entries
#export PATH=$(echo $PATH | awk -F: '

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
export HISTCONTROL=ignoredups:ignorespace:erasedups

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=10000
export HISTFILESIZE=200000

# Highlight less
export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
export LESS=' -R'

# bash options
shopt -s histappend # append to history instead of replacing
shopt -s checkwinsize # check window size
shopt -s nocaseglob # ignore case
if [ "$OSTYPE" == "cygwin" ]; then
	shopt -s completion_strip_exe # foo.exe = foo
	EXECIGNORE=*.dll
fi

# make less more friendly for non-text input files, see lesspipe(1)
# disabled because it will interfere with highlighting less
# [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# reload history after every command
export PROMPT_COMMAND="history -a; history -c; history -r;"

# autocomplete

# for aliases
complete -A alias alias unalias
# ssh commands
[[ -r ~/.ssh/config ]] && complete -W "$(echo `cat ~/.ssh/config | egrep '^Host ' | grep -v 'Host \*' | sort | uniq | sed 's/Host //' | tr ' ' '\n'`;)" scp sftp ssh
[[ -r ~/.ssh/known_hosts ]] && complete -W "$(echo `cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | grep -v "\["`;)" scp sftp ssh
