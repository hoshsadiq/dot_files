# Add defined in bash to ~/.bash_functions
savefunction() {
  declare -f $1 >>$DOT_FILES/zshrc.d/functions/saved.zsh
}

# pretend to be busy in office to enjoy a cup of coffee
allhackingandshit() {
  cat /dev/urandom | hexdump -C | grep --color=auto "ca fe"
}

hgg() {
  if [[ $# -lt 1 ]] || [[ $# -gt 1 ]]; then
    echo "search bash history"
    echo "usage: mg [search pattern]"
  else
    history | grep -i $1 | grep -v hg
  fi
}

# Lists unique IPs currently connected to
# logged-in system & how many concurrent
# connections each IP has
connections() {
  netstat -ntu | awk '{print $5}' | cut -d: -f1 -s | sort | uniq -c | sort -n -r
}

# Reminder for whatever whenever
remindme() {
  nohup sleep $1 && zenity --info --text "$2" &
}

# outputs the pid of the first grepped process
greppid() {
  local context=0
  local proc=$1
  if [ "$1" = "--context" ]; then
    context=1
    proc=$2
  elif [ "$2" = "--context" ]; then
    context=1
  fi

  if [[ "$context" == "1" ]]; then
    ps aux | grep $proc | head -n 1
  else
    ps aux | grep $proc | head -n 1 | awk '{ print $2 }'
  fi
}

# to take a note: note your note
# to clear: note -c
# to view notes: note
note() {
  #if file doesn't exist, create it
  [[ -f $HOME/.notes ]] || touch $HOME/.notes

  #no arguments, print file
  if [[ $# == 0 ]]; then
    cat $HOME/.notes
  #clear file
  elif [[ $1 == -c ]]; then
    >$HOME/.notes
  #add all arguments to file
  else
    echo "$@" >>$HOME/.notes
  fi
}

is-port-open() {
  # todo use nmap when available

  host="$1"
  port="$2"
  bash -c "echo >/dev/tcp/$host/$port"
}

gsettings() {
  if [[ "$#" == "1" && "$1" == "monitor" ]]; then
    command gsettings list-schemas | xargs -n 1 --max-procs=0 -I% bash -e -c 'exec > >(sed "s/^/% /"); exec 2> >(sed "s/^/% /" >&2); command gsettings monitor %'
    return $?
  fi

  command gsettings "$@"
}

text2number() {
  typeset -A mapping
  mapping[a]=2
  mapping[b]=2
  mapping[c]=2
  mapping[d]=3
  mapping[e]=3
  mapping[f]=3
  mapping[g]=4
  mapping[h]=4
  mapping[i]=4
  mapping[j]=5
  mapping[k]=5
  mapping[l]=5
  mapping[m]=6
  mapping[n]=6
  mapping[o]=6
  mapping[p]=7
  mapping[q]=7
  mapping[r]=7
  mapping[s]=7
  mapping[t]=8
  mapping[u]=8
  mapping[v]=8
  mapping[w]=9
  mapping[x]=9
  mapping[y]=9
  mapping[z]=9

  original=""
  numbers=""

  while read -r char; do
    if [[ -n ${mapping[$char]:-} ]]; then
      original="$original$char"
      numbers="$numbers${mapping[$char]}"
    fi
  done < <(command grep -o . <<<"$1")

  printf "%s\n%s\n" "$original" "$numbers"
}
# scroll to a section within man pages
mans() {
  local section="$1"
  shift

  man -P "less -p ^'$section'" "$@"
}

=() {
  bc -l <<<"$*"
}
