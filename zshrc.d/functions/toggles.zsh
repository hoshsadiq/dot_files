proxy() {
  action="$1"

  local PROXY_URL=""

  if [ -z "$PROXY_URL" ]; then
    echo "No proxy has been set"
    return 1
  fi

  case "$action" in
    "off"|"disable")
      export http_proxy=""
      export https_proxy=""
      echo "Proxy disabled"
      ;;
    "on"|"enable")
      export http_proxy="$PROXY_URL"
      export https_proxy="$PROXY_URL"
      echo "Proxy enabled"
      ;;
    *)
      echo "$0 enable|on|disable|off"
      ;;
  esac
}

# Touchscreen toggling
touchscreen() {
  action="$1"

  local devid="$(xinput | awk '/Touchscreen/{ print $5 }' | awk -F '=' '{ print $2 }')"
  case "$action" in
    "off"|"disable")
      xinput set-prop $devid 'Device Enabled' 0
      echo "Touchscreen disabled"
      ;;
    "on"|"enable")
      xinput set-prop $devid 'Device Enabled' 1
      echo "Touchscreen enabled"
      ;;
    *)
      echo "$0 enable|on|disable|off"
      ;;
  esac
}
