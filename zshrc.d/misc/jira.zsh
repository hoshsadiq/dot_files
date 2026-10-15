jira() {
  local skip_1password=false
  for i in "$@"; do
    case $i in
      completion|init|man|version|help|--help|-h) skip_1password=true ;;
    esac
  done

  # todo: add support for other password managers
  # if [[ $skip_1password == false && -z $JIRA_API_TOKEN ]]; then
  #   if ! JIRA_API_TOKEN="$(op item get --vault Employee 'JIRA API Token' --reveal --fields credential)"; then
  #     return $?
  #   fi
  #   export JIRA_API_TOKEN
  # fi
  command jira "$@"
}
