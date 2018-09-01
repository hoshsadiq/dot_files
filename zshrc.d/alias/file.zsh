alias mkdir="mkdir -pv"
alias rm="rm -rfv"
alias cp="cp -v"
alias ln="ln -v"
alias rmdir="rmdir -pv"
alias mv="mv -v"

# This is GOLD for finding out what is taking so much space on your drives!
alias diskspace="du -S | sort -n -r | more"
# Show me the size (sorted) of only the folders in this directory
alias folders="find . -maxdepth 1 -type d -print | xargs du -sk | sort -rn"

# sometimes you're just not sure you want to delete something...
# assumes file exist. maybe create in install.sh?
# todo: Use ~/Trash for MacOS
alias trash='mv -t ~/.local/share/Trash/files --backup=t'

# Remove .DS_Store files in current path
alias rm-dsstore='rm -f **/.DS_Store'
