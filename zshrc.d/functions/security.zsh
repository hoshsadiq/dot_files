ssh-priv-to-pub() {
  sshPrivKey="$1"
  ssh-keygen -y -f "$sshPrivKey"
}

ssh-gen-deploy-key() {
  local output comment bytes

  output="$1"

  comment=()
  [[ -n "$2" ]] && comment=("-C" "$2")
  bytes="${3:-4096}"

  [[ -z "$output" ]] && { >&2 echo "usage: $0 /path/to/id_rsa [comment] [bytes]"; return 1; }

  ssh-keygen -t rsa -b "$bytes" -f "$output" -N '' "${comment[@]}"
}

ssh-get-fingerprint() {
  keyFile="$1" # can be either public or private key
  hash="${2:-md5}"
  ssh-keygen -E "$hash" -lf "$keyFile"
}

ssl-get-fingerprint() {
  ssl-get-certificate "$@" | openssl x509 -noout -fingerprint -sha256 -in /dev/stdin
}

ssl-get-certificate() {
  website="$1"
  sni="${2:-true}"

  args=("-connect" "$website:443")
  if [[ "$sni" == "true" ]]; then
    args+=("-servername" "$website")
  fi

  openssl s_client -showcerts "${args[@]}" </dev/null 2>/dev/null |
    openssl x509 -text
}

check_gpg_pass() {
  if [[ -z "$1" ]]; then
    >&2 echo "usage: $0 <key-id>"
    return 1
  fi
  echo "1234" | gpg --batch -o /dev/null --local-user "$1" -as - 2>&1 && echo "The correct passphrase was entered for this key"
}

gen-words() {
  count="${1:-4}"
  sep="${2:--}"

  grep -E "^[a-z]{4,10}$" /usr/share/dict/words | sort -R | head -n "$count" | paste -sd "$sep" -
}

gen-pass() {
  local alphabet=true
  local uppercase=true
  local numbers=true
  local specials=true
  local length=30

  while [ $# != 0 ]; do
    case "$1" in
    -na | --no-alphabet) alphabet=false ;;
    -a | --alphabet) alphabet=true ;;
    -nu | --no-uppercase) uppercase=false ;;
    -u | --uppercase) uppercase=true ;;
    -nn | --no-numbers) numbers=false ;;
    -n | --numbers) numbers=true ;;
    -ns | --no-specials) specials=false ;;
    -s | --specials) specials=true ;;
    -l* | --length*)
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

  LC_ALL=C tr -dc "$regex" </dev/urandom | head -c "$length"
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
