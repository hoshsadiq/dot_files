gcp-get-iam-policy-for-sa() {
#  set -x
  saEmail="${1}"
  shift

#  saUser="${saEmail%%@*}" # todo this might be needed.. maybe
  saUser="${saEmail}"

  common_args=("$@")
  common_args+=(\
    '--flatten' 'bindings[].members' \
    '--format' 'table(bindings.role)' \
    '--filter' "bindings.members:$saUser" \
  )

  projectId="$(gcloud iam service-accounts describe "$saEmail" --format='value(projectId)' "$@")"
  folderId="$(gcloud projects describe "$projectId" --format="value(parent.id)" "$@")"
  orgId="$(gcloud resource-manager folders describe "$folderId" --format="value(parent)" "$@" | awk -F/ '{print $2}')"

  saPolicies="$(gcloud iam service-accounts get-iam-policy "$saEmail" "${common_args[@]}" &)"
  projectPolicies="$(gcloud projects get-iam-policy "$projectId"  "${common_args[@]}" &)"
  folderPolicies="$(gcloud resource-manager folders get-iam-policy "$folderId" "${common_args[@]}" &)"
  orgPolicies="$(gcloud organizations get-iam-policy "$orgId" "${common_args[@]}" &)"

  wait

  if [[ "$saPolicies" != "" ]]; then
    echo "Service Account IAM Policies"
    echo "$saPolicies"
    echo ""
  fi

  if [[ "$projectPolicies" != "" ]]; then
    echo "Project Level IAM Policies"
    echo "$projectPolicies"
    echo ""
  fi

  if [[ "$folderPolicies" != "" ]]; then
    echo "Folder Level IAM Policies"
    echo "$folderPolicies"
    echo ""
  fi

  if [[ "$orgPolicies" != "" ]]; then
    echo "Organisation Level IAM Policies"
    echo "$orgPolicies"
    echo ""
  fi
}