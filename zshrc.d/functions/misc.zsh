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

# Calculate something
# calc 1+1
calc() {
  echo "scale=2;$@" | bc
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
