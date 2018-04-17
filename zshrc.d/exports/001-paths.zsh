export GOPATH="$HOME/Workspace"
export PYENV="$GOPATH/pyenv"

# move to ~/apps/android/bin
ANDROID_BIN_PATH=$HOME/apps/android-bin/

# possible different for mac
PIP_LOCAL_BIN="$HOME/.local/bin"

export PATH=$HOME/bin:$PATH
export PATH=$JAVA_HOME/bin:$PATH
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$ANDROID_BIN_PATH
export PATH=$PATH:$PIP_LOCAL_BIN
