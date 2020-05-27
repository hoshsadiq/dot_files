rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"
}

proxy() {
  # https://github.com/tmatilai/vagrant-proxyconf/tree/master/lib/vagrant-proxyconf/config
  action="$1"

  local PROXY_URL=""

  if [ -z "$PROXY_URL" ]; then
    echo "No proxy has been set"
    return 1
  fi

  case "$action" in
    "off"|"disable")
      http_proxy=""
      https_proxy=""
      HTTP_PROXY=""
      HTTPS_PROXY=""
      export http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
      echo "Proxy disabled"
      ;;
    "on"|"enable")
      http_proxy="$PROXY_URL"
      https_proxy="$PROXY_URL"
      HTTP_PROXY="$PROXY_URL"
      HTTPS_PROXY="$PROXY_URL"
      export http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
      echo "Proxy enabled"
      ;;
    *)
      echo "$0 [enable|on]|[disable|off]"
      ;;
  esac
}

setproxy() {
  if [[ -z "$PROXY_USERNAME" ]]; then
      echo -n "Enter your proxy username [$(whoami)]: "
      read -r PROXY_USERNAME
      : "${PROXY_USERNAME:="$USER"}"
  fi

  if [[ -z "$PROXY_PASSWORD" ]]; then
      echo -n "Enter your proxy password: "
      read -r -s PROXY_PASSWORD
  fi

  if [[ -z "$PROXY_HOST" ]]; then
      echo -n "Enter your proxy host/port: "
      read -r -s PROXY_HOST
  fi

  PROXY_URL="http://$(rawurlencode "$PROXY_USERNAME"):$(rawurlencode "$PROXY_PASSWORD")@$PROXY_HOST/"
  NO_PROXY="localhost,127.0.0.1,localaddress,.localdomain.com"

  if [[ ! -z "$PROXY_SKIP" ]]; then
    NO_PROXY="$NO_PROXY,$PROXY_SKIP"
  fi

  export PROXY_URL NO_PROXY
  proxy on
}

unsetproxy() {
  proxy off
  unset NO_PROXY
  unset PROXY_URL
}

if [[ -n "$PROXY_USERNAME" && -n "$PROXY_PASSWORD" && -n "$PROXY_HOST" ]]; then
  setproxy
fi
