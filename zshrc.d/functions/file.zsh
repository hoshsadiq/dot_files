# mkdir & cd
mkcd() {
   if [[ $# != 1 ]]; then
      echo "Usage: mkcd <dir>"
   else
      mkdir -p $1 && cd $1
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

# cygwin specific, opens windows explorer for a given path
# if the path is not given, pwd will be used
# todo: Maybe a *nix version of this?
explore() {
  local exp
  if [ "-"$1"-" = "--" ]; then
    exp=`pwd`
  else
    exp=$1
  fi

  if [ "$OSTYPE" = "cygwin" ]; then
    cygstart explorer.exe /e,$(cygpath -w "$exp")
  elif stringContains "darwin" "$OSTYPE"; then
    echo "todo"
  else
    nautilus "$exp"
  fi
}
