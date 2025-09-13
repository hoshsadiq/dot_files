#!/usr/bin/env zsh

set -x
code=""
profile="/tmp/.profile"
marker_start="# ZINIT PATH LOADER START"
marker_end="# ZINIT PATH LOADER END"
paths_file="/tmp/paths.sh"

if [ ! -f "$profile" ]; then
  touch "$profile"
fi

cat <<EOF >"$paths_file"
case "\$-" in
*i*) return ;;
esac

declare -a paths=(
$(printf '  %s\n' "${path[@]}")
)

IFS=':' PATH="\${paths[*]}"
export PATH
EOF

# export PATH=$(print -l "${(F)PATH}")

read -r -d '' code <<-EOF
$marker_start
if [[ -f "$paths_file" ]]; then
  source "$paths_file"
fi
$marker_end
EOF
if grep -qF "$marker_start" "$profile"; then
  # code="$(sed <<<"$code" -e 's/[\/&]/\\&/g')"
  sed -i.bak "/$marker_start/,/$marker_end/c$code" "$profile"
else
  printf "\n%s\n" "$code" >> "$profile"
fi
