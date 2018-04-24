export GOPATH="$HOME/Workspace"
export PYENV="$GOPATH/pyenv"

addpath() {
    newelement=${1%/}
    if [ -d "$1" ] && ! echo $PATH | grep -E -q "(^|:)$newelement($|:)" ; then
        if [ "$2" = "after" ] ; then
            PATH="$PATH:$newelement"
        else
            PATH="$newelement:$PATH"
        fi
    fi
}

rmpath() {
    PATH="$(echo $PATH | sed -e "s;\(^\|:\)${1%/}\(:\|\$\);\1\2;g" -e 's;^:\|:$;;g' -e 's;::;:;g')"
}

addpath $HOME/bin after
addpath $JAVA_HOME/bin after
addpath $GOPATH/bin after

# move to ~/apps/android/bin
addpath $HOME/apps/android-bin after
