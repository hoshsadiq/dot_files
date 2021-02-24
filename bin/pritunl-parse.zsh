#!/usr/bin/awk -f

BEGIN {
  FS="|"
  OFS="\t"


  $1="id"
  $2="profile"
  $3="status"
  $4="user"
  $5="clientAddress"
  $6="serverAddress"
  print
}
NR>=4 && $2 != "" {
  gsub(/^ +| +$/, "", $2)
  gsub(/^ +| +$/, "", $3)
  gsub(/^ *| *$/, "", $4)
  gsub(/^ +| +$/, "", $5)
  gsub(/^ +| +$/, "", $6)

  id=$2
  user=$3
  status=$4

  if (status != "Disconnected" && status != "Connecting") {
    status="Connected"
    serverAddress=$5
    clientAddress=$6
  }
  getline
  gsub(/^[ \(]+|[ \)]+$/, "", $3)
  profile=$3

  $1=id
  $2=profile
  $3=status
  $4=user
  $5=clientAddress
  $6=serverAddress

  print
}
#END {
#  if (connected == 0) {
#    if (disconnected == 0 && connecting == 0) {
#      print "NO_VPN"
#    } else if (connecting > 0) {
#      print "CONNECTING "connecting
#    } else {
#      if (disconnected == 1) {
#        print "DISCONNECTED "profile
#      } else {
#        print "DISCONNECTED"
#      }
#    }
#  } else if (connected == 1) {
#    print "CONNECTED "profile
#  } else if (connected > 1) {
#    print "CONNECTED "connected
#  }
#}