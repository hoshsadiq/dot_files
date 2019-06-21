# todo base64 on Mac uses -D instead of -d
decode_base64_url() {
  local len=$((${#1} % 4))
  local result="$1"
  if [ $len -eq 2 ]; then result="$1"'=='
  elif [ $len -eq 3 ]; then result="$1"'='
  fi
  echo "$result" | tr '_-' '/+' | base64 -d
}

decode_jwt_section(){
   decode_base64_url "$(echo -n $2 | cut -d "." -f $1)" | jq .
}

decode_jwt_part(){
   decode_jwt_section $1 $2 | jq 'if .iat then (._iat_str = (.iat|todate)) else . end |
                                  if .exp then (._exp_str = (.exp|todate)) else . end |
                                  if .nbf then (._nbf_str = (.nbf|todate)) else . end'
}

decode_jwt(){
  decode_jwt_part 1 $1
  decode_jwt_part 2 $1
}

# Decode JWT header
alias jwth="decode_jwt_part 1"

# Decode JWT Payload
alias jwtp="decode_jwt_part 2"

# Decode JWT header and payload
alias jwthp="decode_jwt"

# Decode JWE header
alias jweh="decode_jwt_section 1"
