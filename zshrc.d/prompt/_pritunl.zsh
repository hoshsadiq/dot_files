#!/usr/bin/zsh

command -v pritunl-client >/dev/null || return

create_pritunl_prompt() {
  awkScript="$(
    <<'AWK'
    BEGIN {
      disconnected=0
      connecting=0
      connected=0
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

      if (status == "Disconnected") {
        disconnected++
      } else if (status == "Connecting") {
        connecting++
      } else {
        connected++

        serverAddress=$5
        clientAddress=$6
      }
      getline
      gsub(/^[ \(]+|[ \)]+$/, "", $3)
      profile=$3
    }
    END {
      if (connected == 0) {
        if (disconnected == 0 && connecting == 0) {
          print "NO_VPN"
        } else if (connecting > 0) {
          print "CONNECTING "connecting
        } else {
          if (disconnected == 1) {
            print "DISCONNECTED "profile
          } else {
            print "DISCONNECTED"
          }
        }
      } else if (connected == 1) {
        print "CONNECTED "profile
      } else if (connected > 1) {
        print "CONNECTED "connected
      }
    }
AWK
  )"

  function prompt_pritunl() {
    IFS=$" " read -r -A pritunl_status < <(pritunl-client list | awk -F'|' "$awkScript")

    if [[ ${pritunl_status[1]} == "NO_VPN" ]]; then
      return
    fi
    p10k segment -s "${pritunl_status[1]}" -r -i VPN_ICON -f blue -t "${pritunl_status[2]}"
  }
}

create_pritunl_prompt
