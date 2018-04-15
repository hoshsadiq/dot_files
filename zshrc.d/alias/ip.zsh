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
