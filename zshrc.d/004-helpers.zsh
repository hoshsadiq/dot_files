alias tolower='tr "[:upper:]" "[:lower:]"'
alias toupper='tr "[:lower:]" "[:upper:]"'
alias rmnl='awk '\''BEGIN{ORS="";} {print}'\'

stringContains() {
  [ -z "${2##*$1*}" ]
}

beginsWith() {
  case $2 in
    "$1"*) true;;
    *) false;;
  esac
}

ask() {
  read -p "$@ [y/N] " ans
  case "$ans" in
    y|Y|yes|Yes) return 0;;
    *) return 1;;
  esac
}

# easier column printing with awk
fawk() {
   cmd="awk '{print \$${1}${last}}'"
   eval $cmd
}
