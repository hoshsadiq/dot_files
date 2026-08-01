#!/usr/bin/env bash

set -eu

TEMP_SSH_KEY="$HOME/.ssh/ssm-ssh-tmp"

ensure_session_manager_plugin_installed() {
  if command -v session-manager-plugin >/dev/null; then
    return
  fi

  printf >&2 "Installing AWS CLI session-manager-plugin..."
  if [[ -r /etc/os-release ]]; then
    source /etc/os-release

    if [[ $ID == "debian" ]] || grep -qF debian <<<"${ID_LIKE:-}"; then
      curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "/tmp/session-manager-plugin.deb"
      sudo dpkg -i /tmp/session-manager-plugin.deb

      return 0
    elif [[ $ID == "fedora" ]] || grep -qF fedora <<<"${ID_LIKE:-}" || [[ $ID == "centos" ]] || grep -qF centos <<<"${ID_LIKE:-}"; then
      curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "/tmp/session-manager-plugin.rpm"
      sudo yum install -y session-manager-plugin.rpm

      return 0
    fi
  elif uname -s | grep -qFx Darwin; then
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip" -o "/tmp/sessionmanager-bundle.zip"
    unzip -d /tmp/ /tmp/sessionmanager-bundle.zip
    sudo /tmp/sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
    rm /tmp/session-manager-plugin-bundle.zip

    return 0
  fi

  printf >&2 "Found unsupported OS when trying to installed session-manager-plugin."
  printf >&2 "You install it manually (and update the script) then try again."
  printf >&2 "Refer here for instructions: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html"
  exit 1
}

get_temp_ssh_key() {
  if [[ ! -f "$TEMP_SSH_KEY" ]]; then
    ssh-keygen -q -t rsa -b 4096 -f "$TEMP_SSH_KEY" -C ssh-over-ssm -N ''
  fi

  ssh-keygen -y -f "$TEMP_SSH_KEY"
}

get_instance_id() {
  local requested_host filters instance_ids
  requested_host="$1"

  filters=()
  case $requested_host in
  i-* | mi-*)
    printf "%s" "$requested_host"
    return 0
    ;;
  filters:*)
    IFS=';' read -r -a filters <<<"${requested_host#filters:}"
    ;;
  *)
    filters+=("Name=private-ip-address,Values=${requested_host}")
    ;;
  esac

  instance_ids=()
  read -r -a instance_ids < <(aws ec2 describe-instances --filter "${filters[@]}" --query 'Reservations[].Instances[].InstanceId' --output text)
  # maybe connect to one at random but with a warning?
  if ((${#instance_ids[@]} != 1)); then
    printf >&2 "Expected to find exactly 1 instance ID, but found %d instances for %q.\n" "${#instance_ids[@]}" "$requested_host"
    return 1
  fi

  printf "%s" "${instance_ids[0]}"
}

upload_ssh_key() {
  local instance_id ssh_user availability_zone
  instance_id="$1"
  ssh_user="$2"

  availability_zone="$(aws ec2 describe-instances \
    --instance-ids "$instance_id" \
    --query 'Reservations[0].Instances[0].Placement.AvailabilityZone' \
    --output text)"

  printf >&2 "Sending SSH public key for '%s' to instance '%s' (%s)\n" "$ssh_user" "$instance_id" "$availability_zone"
  aws ec2-instance-connect send-ssh-public-key \
    --instance-id "$instance_id" \
    --instance-os-user "$ssh_user" \
    --ssh-public-key "file://${TEMP_SSH_KEY}.pub" \
    --availability-zone "$availability_zone"
}

start_ssh_session() {
  local instance_id ssh_user ssh_port

  instance_id="$1"
  ssh_user="$2"
  ssh_port="$3"

  printf >&2 "Starting ssm session to instance '%s' for '%s'\n" "$instance_id" "$ssh_user"
  exec aws ssm start-session \
    --target "${instance_id}" \
    --document-name 'AWS-StartSSHSession' \
    --parameters "portNumber=${ssh_port}"
}

main() {
  local instance_id ssh_user ssh_port

  if [[ $# -ne 3 ]]; then
    printf "usage: %s <instance-id> <ssh-user> <ssh-port>\n" "${0##*/}"
  elif [[ $(basename -- "$(ps -o comm= -p $PPID)") != "ssh" ]]; then
    exec ssh -o IdentityFile="${TEMP_SSH_KEY}" "$@"
    exit 0
  fi

  instance_id="$(get_instance_id "$1")"
  ssh_user="$2"
  ssh_port="$3"

  ensure_session_manager_plugin_installed

  # get_temp_ssh_key
  # upload_ssh_key "$instance_id" "$ssh_user"

  start_ssh_session "$instance_id" "$ssh_user" "$ssh_port"
}

# we can't use trap due to usage of exec, so we remove it once it process is finished.
{
  while kill -0 $$ 2>/dev/null; do sleep 1; done
  rm -f "${TEMP_SSH_KEY}" "${TEMP_SSH_KEY}.pub"
} 2>/dev/null &
main "$@"
