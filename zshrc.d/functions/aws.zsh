aws-params-to-args() {
  yaml2json "$1" | jq -r 'map("ParameterKey=\(.ParameterKey),ParameterValue=\(.ParameterValue)") | join(" ")'
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

aws-ec2-attach-sg-id() {
  local instanceId newGroupId newGroupName currentGroups

  instanceId="$1"
  newGroupName="$2"
  if [[ -z $instanceId ]] || [[ -z $newGroupName ]]; then
    echo "usage: $0 instance-id new-group-name"
    return 1
  fi

  newGroupId="$(aws ec2 describe-security-groups --filters "Name=group-name,Values=$newGroupName" --query 'SecurityGroups[*].GroupId' --output text)"
  currentGroups=($(aws ec2 describe-instances --instance-ids="$instanceId" --query 'Reservations[0].Instances[0].SecurityGroups[*].GroupId' --output text))
  aws ec2 modify-instance-attribute --instance-id="$instanceId" --groups "${currentGroups[@]}" "$newGroupId"
}

aws-ec2-detach-sg-id() {
  local instanceId oldGroupName oldGroupName updatedGroups

  instanceId="$1"
  oldGroupName="$2"
  if [[ -z $instanceId ]] || [[ -z $oldGroupName ]]; then
    echo "usage: $0 instance-id old-group-name"
    return 1
  fi

  oldGroupName="$(aws ec2 describe-security-groups --filters "Name=group-name,Values=$oldGroupName" --query 'SecurityGroups[*].GroupId' --output text)"
  updatedGroups=($(aws ec2 describe-instance-attribute --instance-id=i-0eda1dd3a4b5eecf2 --attribute=groupSet --query "Groups[?GroupId != '$vpnSshGroupId'].GroupId" --output text))
  aws ec2 modify-instance-attribute --instance-id="$instanceId" --groups "${updatedGroups[@]}"
}

aws-ec2-get-private-ip() {
  local instanceId

  instanceId="$1"
  if [[ -z $instanceId ]]; then
    echo "usage: $0 instance-id"
    return 1
  fi

  aws ec2 describe-instances --instance-ids=i-0eda1dd3a4b5eecf2 --query 'Reservations[0].Instances[0].NetworkInterfaces[*].PrivateIpAddress' --output text
}
