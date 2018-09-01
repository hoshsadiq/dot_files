## "manual" settings

This directory is not necessarily for manual settings, however, I need to keep
track for when I automate it.

There's a big todo here to automate my whole network and improve things. This means:
- Use Raspberry Pis for a cheap and open Mesh network
- Block not just DNS records, but also bad IP address (e.g. Google DNS)
- Use unbound
- Constant running VPN with policy based routing
- Guest VLAN
- Smart device VLAN
- Run Prometheus + Grafana and direct all logs and sensors (especially pi-hole logs as they kill the SD card)
