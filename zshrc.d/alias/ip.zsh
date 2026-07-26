alias extip='dig +short txt ch whoami.cloudflare @1.0.0.1'
#alias extip6='dig +short -6 myip.opendns.com aaaa @resolver1.ipv6-sandbox.opendns.com'
alias ipinfo='curl ifconfig.me/all'

localip() {
  ifconfig | awk '
    /^[a-z]/ {
      if (active && ips) { print iface, ips; found++ }
      iface=$1; active=0; ips=""
    }
    /status: active/ { active=1 }
    /inet / { ips = ips ? ips " " $2 : $2 }
    END {
      if (active && ips) { print iface, ips; found++ }
      if (!found) { print "no active interfaces with an IP found" > "/dev/stderr"; exit 1 }
    }
  '
}
