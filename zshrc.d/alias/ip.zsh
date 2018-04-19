# IP stuff
# todo: Fix linux
# todo: Add MacOS
# interferes with /bin/ip now
# if stringContains "darwin" "$OSTYPE"; then
#     alias ip="ipconfig | grep -v 127.0.0.1 | awk '/IPv4/ { print $NF }' | sed -e 's/^/\t\t/'"
# else
#     alias ip="ifconfig | grep "inet addr" | awk '{ print $3 }' | awk -F ':' '{ print $2 }'"
# fi
alias extip='dig +short myip.opendns.com @resolver1.opendns.com'
alias ipinfo='curl ifconfig.me/all'

localip() {
  while read line; do
      sdev=$(echo $line | awk -F  "(, )|(: )|[)]" '{print $4}')
      if [ -n "$sdev" ]; then
          ifout="$(ifconfig $sdev 2>/dev/null)"
          if echo "$ifout" | grep 'status: active' > /dev/null 2>&1; then
              ipAddress=$(echo "$ifout" | awk '/inet /{print $2}')
          fi
      fi
  done <<< "$(networksetup -listnetworkserviceorder | grep 'Hardware Port')"

  if [ -n "$ipAddress" ]; then
      echo $ipAddress
  else
      >&2 echo "Could not find active ipaddress"
      return 1
  fi
}
