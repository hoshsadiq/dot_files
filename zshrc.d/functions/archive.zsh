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

# Creates an archive from given directory
mktar() {
  tar cvf  "${1%%/}.tar" "${1%%/}/"
}
mktgz() {
  tar cvzf "${1%%/}.tar.gz" "${1%%/}/"
}
mktbz() {
  tar cvjf "${1%%/}.tar.bz2" "${1%%/}/"
}
