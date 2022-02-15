## ignores filenames already in the line
zstyle ':completion:*:(rm|kill|diff):*' ignore-line yes

# Kill colors aren't always correct in the default one provided by oh-my-zsh
zstyle ':completion:*:processes' command 'ps -au$USER -o pid,time,cmd|grep -v "ps -au$USER -o pid,time,cmd"'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)[ 0-9:]#([^ ]#)*=01;30=01;31=01;38'
# extra settings for the "kill"-command
zstyle ':completion:*:*:*:*:processes' menu yes select

zstyle ':completion:*:(killall|pkill|kill):*' menu yes select
zstyle ':completion:*:(killall|pkill|kill):*' force-list always

# Make completion:
# - Try exact (case-sensitive) match first.
# - Then fall back to case-insensitive.
# - Accept abbreviations after . or _ or - (ie. f.b -> foo.bar).
# - Substring complete (ie. bar -> foobar).
zstyle ':completion:*' matcher-list \
    '' \
    '+m:{[:lower:]}={[:upper:]}' \
    '+m:{[:upper:]}={[:lower:]}' \
    '+m:{_-}={-_}' \
    'r:|[._-]=* r:|=*' \
    'l:|=* r:|=*'

# ls colours
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Populate hostname completion.
zstyle -e ':completion:*:hosts' hosts 'reply=(
  ${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) 2>/dev/null)"}%%[#| ]*}//,/ }
  ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*}
  ${=${${${${(@M)${(f)"$(cat ~/.ssh/config ~/.ssh/config_local $(awk "tolower($0) ~ /\s*include/{print $2}" ~/.ssh/config) 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'
zstyle -e ':completion:*:(ping|host):*' hosts 'reply=(
  ${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) 2>/dev/null)"}%%[# ]*}//,/ }
  ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*}
)'

# complete hosts and users
zstyle ':completion:*:(ssh|scp|ftp):*' hosts "$hosts"
zstyle ':completion:*:(ssh|scp|ftp):*' users "$users"
# SSH/SCP/RSYNC
zstyle ':completion:*:(scp|rsync):*' tag-order 'hosts:-host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order users 'hosts:-host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:ssh:*' group-order hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*.*' loopback localhost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^*.*' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^<->.<->.<->.<->' '127.0.0.<->'

# Don't complete uninteresting stuff.
zstyle ':completion:*:*:*:users' ignored-patterns \
    avahi bin colord cups daemon dbus dnsmasq flatpak ftp geoclue git http \
    mail mpd nm-openconnect nm-openvpn nobody ntp polkitd postgres rpc rtkit \
    sddm systemd-bus-proxy systemd-coredump systemd-journal-gateway \
    systemd-journal-remote systemd-network systemd-resolve systemd-timesync \
    usbmux uuidd

# Unless we really want to.
zstyle ':completion:*' single-ignored show
