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

aws-ecr-login() {
  eval $(aws ecr get-login --no-include-email "$@")
}

# example:
# aws-get-region-map --filters 'Name=name,Values=amzn2-ami-hvm-2017.12.0.20180328.1-x86_64-ebs' 'Name=architecture,Values=x86_64'
aws-get-ami-region-map() {
  # todo need to somehow add --profile flag to the region retrieval list, for now, export AWS_PROFILE
  regionMap=""
  for region in $(aws ec2 describe-regions --query 'Regions[].{Name:RegionName}' --output text | LC_ALL=C sort --human-numeric-sort); do
    images="$(aws ec2 describe-images --owners amazon --region $region "$@" --query 'Images[].ImageId' --output text)"
    imageCount="$(echo "$images" | wc -w | xargs echo -n)"

    if [ "$imageCount" != "1" ]; then
      echo "Found $imageCount AMI for region $region"
      return 1
    fi

    regionMap="$regionMap\n$region:\n  \"64\": $images";
  done

  echo "$regionMap"
}
