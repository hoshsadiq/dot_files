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
