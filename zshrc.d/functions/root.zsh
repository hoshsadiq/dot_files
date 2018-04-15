# test if a file should be opened normally, or as root (vi)
reqroot () {
  count=0;
  for arg in "$@"; do
    if [[ ! "$arg" =~ '-' ]]; then count=$(($count+1)); fi;
  done;
  echo $count;
}

# replaces vi with vim and checks if the file
# requires root, if it does, it prompts to edit as root
vi () {
  if [[ `reqroot "$@"` > 1 ]]; then /usr/bin/vim $@;
  elif [[ $1 = '' ]]; then /usr/bin/vim;
  elif [[ ! -f $1 ]] || [[ -w $1 ]]; then /usr/bin/vim $@;
  else
    echo -n "File is readonly. Edit as root? (Y/n): "
    read -n 1 yn; echo;
    if [[ "$yn" = 'n' ]] || [[ "$yn" = 'N' ]]; then /usr/bin/vim $*;
    else sudo /usr/bin/vim $*;
    fi
  fi
}
