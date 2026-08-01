#!/usr/bin/env bash

# sixwordsallcaps16

auth="root:<password>"
ipaddr="192.168.1.1"
authorized_key="$(cat ~/.ssh/id_rsa_ddwrt.pub)"

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
  echo "${encoded}"    # You can either set a return variable (FASTER)
  REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
}

# reset password
# curl -X POST -L \
#   -H "Referer: http://$ipaddr/Factory_Defaults.asp" \
#   -H "Host: $ipaddr" \
#   -H 'Content-Type: application/x-www-form-urlencoded' \
#   --data-binary "submit_button=index&action=Apply&submit_type=changepass&next_page=Info.htm&change_action=gozila_cgi&http_username=root&http_passwd=bpKs3XsPcCh5&http_passwdConfirm=bpKs3XsPcCh5" \
#   "http://$ipaddr/applyuser.cgi"

# Enable sshd
curl -vvv -u "$auth" -X POST -L \
  -H "Referer: http://$ipaddr/Services.asp" \
  -H "Host: $ipaddr" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-binary "submit_button=Services&action=ApplyTake&commit=1&sshd_enable=1&sshd_passwd_auth=0&sshd_authorized_keys=$(rawurlencode "$authorized_key")" \
  "http://$ipaddr/applyuser.cgi"

# Apply changes
curl -vvv -u "$auth" -X POST -L \
  -H "Referer: http://$ipaddr/Services.asp" \
  -H "Host: $ipaddr" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-binary "submit_button=Services&action=ApplyTake&commit=1" \
  "http://$ipaddr/applyuser.cgi"

# Reboot
curl -vvv -u "$auth" -X POST -L \
  -H "Referer: http://$ipaddr/Management.asp" \
  -H "Host: $ipaddr" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-binary "submit_button=Management&action=Reboot&commit=1" \
  "http://$ipaddr/applyuser.cgi"

#keep network on pi-hole
iptables -t nat -I PREROUTING -i br0 -p tcp --dport 53 -j DNAT --to 192.168.100.3:53
iptables -t nat -I PREROUTING -i br0 -p udp --dport 53 -j DNAT --to 192.168.100.3:53
#punch DNS hole for pi-hole
iptables -t nat -I PREROUTING -i br0 -p tcp -s 192.168.100.3 --dport 53 -j ACCEPT
iptables -t nat -I PREROUTING -i br0 -p udp -s 192.168.100.3 --dport 53 -j ACCEPT

declare -A settings
settings[dns_redirect]=1
settings[vlan1_ipaddr]=0.0.0.0
settings[eth0_dns_redirect]=0
settings[eth0_isolation]=0
settings[eth0_mtu]=1500
settings[eth0_dns_ipaddr]=0.0.0.0
settings[eth0_dns_ipaddr]=0.0.0.0
settings[eth2_mtu]=1500
settings[vlan0_dns_redirect]=0
settings[vlan0_dns_ipaddr]=0.0.0.0
settings[vlan1_ipaddr]=0.0.0.0
settings[oet1_peers]=0
settings[vlan1_isolation]=0
settings[vlan0_bridged]=1
settings[vlan1_txq]=0
settings[remote_ip_any]=0
settings[eth1_txq]=1000
settings[vlan0_netmask]=0.0.0.0
settings[cron_enable]=0
settings[default_lanlevel]=100000
settings[bridges_count]=1
settings[block_activex]=1
settings[block_snmp]=
settings[wan_dns]=192.168.100.3
settings[warn_user]=
settings[action_service]=management filters wireless_2 wireless index
settings[vlan1_dns_ipaddr]=0.0.0.0
settings[warn_fromfull]=
settings[samba3_shares]=[]
settings[remote_ip]=192.168.100.3 3
settings[vlan1_netmask]=0.0.0.0
settings[vlan0_nat]=1
settings[vlan0_multicast]=0
settings[wl_regdomain]=UNITED_KINGDOM
settings[vlan1_mtu]=1500
settings[eth0_nat]=1
settings[eth1_mtu]=1500
settings[eth2_txq]=1000
settings[vlan0_txq]=0
settings[vlan_tagcount]=0
settings[limit_ftp]=0
settings[eth0_txq]=1000
settings[vlan0_isolation]=0
settings[probe_blacklist]=vlan1
settings[time_zone]=Europe/London
settings[numfilterservice1]=4
settings[wl_channel]=6
settings[recursive_dns]=0
settings[filter_tod9]=
settings[vlan0_ipaddr]=0.0.0.0
settings[vlan1_multicast]=0
settings[vlan1_dns_redirect]=0
settings[mdhcpd_count]=0
settings[status_auth]=0
settings[vlan1_nat]=1

settings[wl_ssid]=Fix-your-bed-2.4GHz

settings[wl0_auth_mode]=none
settings[wl0_crypto]=aes
settings[wl0_wpa_psk]=sixwordsallcaps16
settings[wl0_authmode]=open
settings[wl0_akm]=psk2
settings[wl0_wep_buf]=:::::
settings[wl0_macmode1]=disabled
settings[wl0_security_mode]=psk2
settings[wl0_ssid]=Fix-your-bed-2.4GHz

settings[wl1_key]=1
settings[wl1_wep_buf]=:::::
settings[wl1_auth_mode]=none
settings[wl1_authmode]=open
settings[wl1_radius_ipaddr]=0.0.0.0
settings[wl1_ssid]=Seriously-it-is-annoying-5GHz
settings[wl1_wpa_psk]=sixwordsallcaps16
settings[wl1_security_mode]=psk2
settings[wl1_radius_port]=1812
settings[wl1_akm]=psk2
settings[wl1_macmode1]=disabled
settings[wl1_wpa_gtk_rekey]=3600
settings[wl1_crypto]=aes
