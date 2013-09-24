# If not running interactively, don't do anything

[[ -z "$PS1" ]] && return

# include other files
if [[ $TERM != "screen" ]]; then
	### Launch Screen automatically ###  
	echo
	for i in 3 2 1 ; do
		printf "\rStarting screen in %d seconds, press Q to cancel." $i
		read -n 1 -t 1 -s a && break
	done

	set a = $a | tr '[A-Z]' '[a-z]'
	if [ "$a" != "q" ]; then
		screen -D -R main
		logout
	fi
	echo "Canceled"
fi

[[ -r ~/.bash_colors ]] && . ~/.bash_colors # colors
[[ -r ~/.bash_aliases ]] && . ~/.bash_aliases # aliases
[[ -r ~/.bash_functions ]] && . ~/.bash_functions # functions
[[ -r ~/.bash_prompt ]] && . ~/.bash_prompt # promps
[[ -r ~/.bash_completion ]] && . ~/.bash_completion # custom bash completition
[[ -r ~/.bash_local ]] && . ~/.bash_local # custom bash completition
[[ -r ~/.bashrc ]] && . ~/.bashrc # aliases
[[ -r ~/.profile ]] && . ~/.profile # aliases
