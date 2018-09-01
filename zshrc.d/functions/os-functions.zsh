get-arch() {
  local ARCH=$(uname -m)

  case $ARCH in
    armv5*) ARCH="armv5";;
    armv6*) ARCH="armv6";;
    armv7*) ARCH="armv7";;
    aarch64) ARCH="arm64";;
    x86|i686|i386) ARCH="x86";;
    x86_64) ARCH="amd64";;
  esac
  echo "$ARCH"
}

get-os() {
  local OS=$(uname|tr '[:upper:]' '[:lower:]')

  case "$OS" in
    mingw*) OS='windows';;
    msys*) OS='windows';;
  esac
  echo "$OS"
}
