# Router settings

### DHCP
[ ] Enable Primary DHCP Server

- Todo add the mac address and IP of pi-hole


### IPv6

#### ULA information
ULA Mode: Manual
Prefix: `fd00::1`


### Security

#### IP Filter
Enable IP Filter [x]
Filter Mode [Blacklist]

#### Rules
- Rule name: block google dns
  Protocol: TCP/UDP
  Direction: Bidirectional
  LAN-side IP Address: <empty>
  WAN-side IP Address: 8.8.8.8 - 8.8.8.8
  WAN-side TCP Port: 53
  WAN-side UDP Port: 53
- Rule name: block google dns 2
  Protocol: TCP/UDP
  Direction: Bidirectional
  LAN-side IP Address: <empty>
  WAN-side IP Address: 8.8.4.4 - 8.8.4.4
  WAN-side TCP Port: 53
  WAN-side UDP Port: 53

## Finally
- Change username and password
