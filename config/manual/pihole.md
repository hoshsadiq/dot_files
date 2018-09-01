## PiHole settings

Lists:
- https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
- https://mirror1.malwaredomains.com/files/justdomains
- http://sysctl.org/cameleon/hosts
- https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist
- https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt
- https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
- https://hosts-file.net/ad_servers.txt
- https://raw.githubusercontent.com/hoshsadiq/adblock-nocoin-list/master/hosts.txt
- https://adaway.org/hosts.txt
- https://pgl.yoyo.org/as/serverlist.php?hostformat=hosts&showintro=0
- https://raw.githubusercontent.com/hoshsadiq/blocked-hosts/master/hosts

DNS:
Use Quad9 DNS

Additionally, the following settings:

[x] Never forward non-FQDNs
[x] Never forward reverse lookups for private IP ranges
[x] Use DNSSEC

DHCP
[x] Enabled
[x] Enable IPv6 support (SLAAC + RA)

- Ensure IP ranges match router IPs
- Todo add the mac addresses, IPs and hostnames
