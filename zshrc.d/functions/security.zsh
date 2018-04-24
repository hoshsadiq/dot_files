ssh-priv-to-pub() {
  sshPrivKey="$1"
  ssh-keygen -y -f "$sshPrivKey"
}

ssh-gen-deploy-key() {
  output="$1"
  comment="$2"
  bytes="${3:-4096}"

  if [ ! -z "$comment" ]; then
    comment="-C $comment"
  fi
  ssh-keygen -t rsa -b "$bytes" -f "$output" -N '' $comment
}

ssh-get-fingerprint() {
  keyFile="$1" # can be either public or private key
  hash="${2:-md5}"
  ssh-keygen -E "$hash" -lf "$keyFile"
}

check_gpg_pass() {
    if [ "$1x" == "x" ]; then
        echo "$0 <key-id>"
        return 1
    fi
    echo "1234" | gpg --batch -o /dev/null --local-user "$1" -as - 2>&1 && echo "The correct passphrase was entered for this key"
}


gen-pass() {
  local alphabet=true
  local uppercase=true
  local numbers=true
  local specials=true
  local length=30

  while [ $# != 0 ]; do
    case "$1" in
      --no-alphabet) alphabet=false ;;
      --alphabet) alphabet=true ;;
      --no-uppercase) uppercase=false ;;
      --uppercase) uppercase=true ;;
      --no-numbers) numbers=false ;;
      --numbers) numbers=true;;
      --uppercase) uppercase=true ;;
      --no-specials) specials=false ;;
      --specials) specials=true;;
      --uppercase) uppercase=true ;;
      --length*)
        # todo ensure value is numbers only
        if stringContains "=" "$1"; then
          length="${1#*=}"
        elif [ -n "$2" ]; then
          length="$2"
          shift
        fi
        ;;
    esac
    shift
  done

  local regex=""
  if [ "$alphabet" = "true" ]; then
    regex="${regex}a-z"
  fi
  if [ "$uppercase" = "true" ]; then
    regex="${regex}A-Z"
  fi
  if [ "$numbers" = "true" ]; then
    regex="${regex}0-9"
  fi
  if [ "$specials" = "true" ]; then
    regex="${regex}!\"#$%&'()*+,-./:;<=>?@\[\]^_\`{\|}~"
  fi

  head /dev/urandom | tr -dc "$regex" | head -c "$length"
}
