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

ssl-get-website-fingerprint() {
  website="$1"

  echo -n \
    | openssl s_client -connect "$website:443" 2>/dev/null \
    | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' \
    | openssl x509 -noout -fingerprint -sha256 -in /dev/stdin
}

check_gpg_pass() {
    if [ "$1x" == "x" ]; then
        echo "$0 <key-id>"
        return 1
    fi
    echo "1234" | gpg --batch -o /dev/null --local-user "$1" -as - 2>&1 && echo "The correct passphrase was entered for this key"
}


gen-pass-from-words() {
  grep -E "^[a-z]{4,10}$" /usr/share/dict/words | sort -R | head -n 4 | paste -sd "-" -
}

gen-pass() {
  local alphabet=true
  local uppercase=true
  local numbers=true
  local specials=true
  local length=30

  while [ $# != 0 ]; do
    case "$1" in
      -na|--no-alphabet) alphabet=false ;;
      -a|--alphabet) alphabet=true ;;
      -nu|--no-uppercase) uppercase=false ;;
      -u|--uppercase) uppercase=true ;;
      -nn|--no-numbers) numbers=false ;;
      -n|--numbers) numbers=true;;
      -ns|--no-specials) specials=false ;;
      -s|--specials) specials=true;;
      -l*|--length*)
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

  LC_ALL=C tr -dc "$regex" < /dev/urandom | head -c "$length"
}

sudo-keep-alive() {
  sudo -v
  {
    while true; do
      sudo -n true
      sleep 60
      kill -0 "$$" || exit
    done
  } 2>/dev/null &
}
