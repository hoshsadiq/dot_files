# extract files
# Maybe add install instructions if not installed?
extract () {
   if [[ -f $1 ]] ; then
      case $1 in
         *.tar.bz2)   tar xvjf $1    ;;
         *.tar.gz)    tar xvzf $1    ;;
         *.bz2)       bunzip2 $1     ;;
         *.rar)       unrar x $1     ;;
         *.gz)        gunzip $1      ;;
         *.tar)       tar xvf $1     ;;
         *.tbz2)      tar xvjf $1    ;;
         *.tgz)       tar xvzf $1    ;;
         *.zip)       unzip $1       ;;
         *.Z)         uncompress $1  ;;
         *.7z)        7z x $1        ;;
         *)           echo "don't know how to extract '$1'..." ;;
      esac
   else
      echo "'$1' is not a valid file!"
   fi
}

# cdup <number>
# cds <number> of times up
# cd 3 == cd ../../..
cdup(){
   local d=""
   limit=$1
   for ((i=1 ; i <= limit ; i++))
   do
      d=$d/..
   done
   d=$(echo $d | sed 's/^\///')
   if [[ -z "$d" ]]; then
      d=..
   fi
   cd $d
}

# easier column printing with awk
fawk() {
   cmd="awk '{print \$${1}${last}}'"
   eval $cmd
}

# mkdir & cd
mkcd() {
   if [[ $# != 1 ]]; then
      echo "Usage: mkcd <dir>"
   else
      mkdir -p $1 && cd $1
   fi
}

# cygwin specific, opens windows explorer for a given path
# if the path is not given, pwd will be used
# todo: Maybe a *nix version of this?
if [[ "$OSTYPE" == "cygwin" ]]; then
  explore() {
     if [[ "-"$1"-" = "--" ]]; then
        local exp=`pwd`
     else
        local exp=$1
     fi
     cygstart explorer.exe /e,`cygpath -w $exp`
  }
fi

# Calculate something
# calc 1+1
calc() {
    echo "scale=2;$@" | bc;
}

# to take a note: note your note
# to clear: note -c
# to view notes: note
note () {
   #if file doesn't exist, create it
   [[ -f $HOME/.notes ]] || touch $HOME/.notes

   #no arguments, print file
   if [[ $# = 0 ]]; then
          cat $HOME/.notes
   #clear file
   elif [[ $1 = -c ]]; then
      > $HOME/.notes
   #add all arguments to file
   else
      echo "$@" >> $HOME/.notes
   fi
}

# outputs stuff to figure out what a command does
h () {
  for ARG; do
    case `type -t "$ARG"` in 
      alias) alias "$ARG";;
      keyword) type $ARG;;
      function) type $ARG;;
      builtin) help $ARG;;
      file) FILE=`which "$ARG"`
        case `file --mime --dereference --brief "$FILE"` in
      text/*|application/x-sh)
        if [[ 50 -gt `wc -l <"$FILE"` ]]; then cat "$FILE"
        else echo "$FILE is quite a long text file. I will not cat it."; fi
        ;;
      application/*)
        if man "$ARG" >/dev/null 2>&1; then
          man "$ARG"
        else
          echo "$FILE is a compiled executable or unsupported format."
          echo "It does not have a man page installed. Try '$FILE --help' or '-h'."
        fi
        ;;
    esac
    ;;
      *) echo "Error: '$ARG' not recognized." 1>&2;;
    esac
  done
}


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

# Creates an archive from given directory
mktar() { tar cvf  "${1%%/}.tar"     "${1%%/}/"; }
mktgz() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }
mktbz() { tar cvjf "${1%%/}.tar.bz2" "${1%%/}/"; }

# Touchscreen toggling
function touchscreen() {
  local devid="$(xinput | grep Touchscreen | awk '{ print $5 }' | awk -F '=' '{ print $2 }')"
  case "$1" in
    "off")
      xinput set-prop $devid 'Device Enabled' 0
      ;;
    *)
      xinput set-prop $devid 'Device Enabled' 1
      ;;
  esac
}

# Add defined function in bash to ~/.bash_functions
function addfunction() { declare -f $1 >> ~/.bash_functions ; }

# pretend to be busy in office to enjoy a cup of coffee
function allhackingandshit()
{
  cat /dev/urandom | hexdump -C | grep --color=auto "ca fe"
}

function hgg()
{
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
function connections()
{
  "netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n"
}

# Reminder for whatever whenever
function remindme()
{
  sleep $1 && zenity --info --text "$2" &
}

# google search
function google() {
  if [[ $1 ]]; then
    q="$@"
    q=$(echo ${q//[^a-zA-Z0-9]/+})
    if [[ "$OSTYPE" == "cygwin" ]]; then
      cygstart firefox -new-tab "https://www.google.com/search?q="$q;
    else
      firefox -new-tab "https://www.google.com/search?q="$q;
    fi
  else
    echo 'Usage: google seach terms';
  fi
}

function json_pretty() {
  php -r "echo json_encode(json_decode(file_get_contents('$1')), JSON_PRETTY_PRINT);"
}

# out puts the pid of the first grepped process
function greppid () {
  local context=0
  local proc=$1
  if [[ "$1" == "--context" ]]; then
    context=1
    proc=$2
  else
    if [[ "$2" == "--context" ]]; then
      context=1
    fi
  fi

  if [[ "$context" == "1" ]]; then
    ps aux | grep $proc | head -n 1
  else
    ps aux | grep $proc | head -n 1 | awk '{ print $2 }'
  fi
}


function ask() {
  read -p "$@ [y/N] " ans
  case "$ans" in
    y|Y|yes|Yes) return 0;;
    *) return 1;;
  esac
}