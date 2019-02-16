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
