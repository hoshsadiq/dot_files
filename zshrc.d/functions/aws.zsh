aws-params-to-args() {
  yaml2json "$1" | jq -r 'map("ParameterKey=\(.ParameterKey),ParameterValue=\(.ParameterValue)") | join(" ")'
}

aws-export-session-env() {
  profile="$1"

  if [ -z "$profile" ]; then
    echo "usage:"
    echo "  $0 <profile>"
    echo "Note this clears all sessions and only keeps the newly created session"
    return 1
  fi

  # rm -rf $HOME/.aws/cli/cache/*.json
  calledIdentity="$(aws sts get-caller-identity --profile "$profile")"
  assumedRoleId="$(echo "$calledIdentity" | jq -r '.UserId')"
  account="$(echo "$calledIdentity" | jq -r '.Account')"
  arn="$(echo "$calledIdentity" | jq -r '.Arn')"
  if ! beginsWith "arn:aws:sts::${account}:assumed-role/" "$arn"; then
    echo 'This utility ony works with assumed-roles for now'
    return 0
  fi

  for sessionFile in $HOME/.aws/cli/cache/*.json; do
    sessionAssumedRoleId="$(jq -r '.AssumedRoleUser.AssumedRoleId' $sessionFile)"
    sessionArn="$(jq -r '.AssumedRoleUser.Arn' $sessionFile)"

    if [ "$sessionAssumedRoleId" = "$assumedRoleId" -a "$sessionArn" = "$arn" ]; then
      export AWS_ACCESS_KEY_ID="$(jq -r '.Credentials.AccessKeyId' "$sessionFile")"
      export AWS_SECRET_ACCESS_KEY="$(jq -r '.Credentials.SecretAccessKey' "$sessionFile")"
      export AWS_SESSION_TOKEN="$(jq -r '.Credentials.SessionToken' "$sessionFile")"
    fi
  done
}

ecr_login() {
  eval $(aws ecr get-login --no-include-email "$@")
}
