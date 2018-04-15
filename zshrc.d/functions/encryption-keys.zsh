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
