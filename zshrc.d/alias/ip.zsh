alias extip='dig +short -4 myip.opendns.com @resolver1.opendns.com'
alias extip6='dig +short -6 myip.opendns.com aaaa @resolver1.ipv6-sandbox.opendns.com'
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
