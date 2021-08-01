alias g="git"
alias gd="git diff"
alias gco="git checkout"
#alias gci="git commit" # conflicts with gci command
alias gits="git status"
alias gph="git push -u origin HEAD"

git_suffix_clone() {
  url="$1"
  cdinto="${2:-true}"

  readonly URI_REGEX='^(([^:/?#]+):)?(//((([^:/?#]+)@)?([^:/?#]+)(:([0-9]+))?))?(/([^?#]*))(\?([^#]*))?(#(.*))?'
  if [[ -n $WORKSPACE ]] && [[ "$url" =~ $URI_REGEX ]]; then
    if [[ "${match[7]}" == "github.com" ]] || [[ "${match[7]}" == "gitlab.com" ]]; then
      mkdir -p "$WORKSPACE/${match[7]}/${match[11]%%\.git}"
      dir="$_"
      git clone "$url" "$dir"
      if [[ "$cdinto" == "true" ]]; then
        builtin cd "$dir" || return $?
      fi
      return 0
    fi
  fi

  printf >&2 "failed to determine a cloning directory, reverting to default behaviour."
  git clone "$url"
  dir="$_"
  if [[ "$cdinto" == "true" ]]; then
    builtin cd "$dir" || return $?
  fi
  return 0
}

alias -s git="git_suffix_clone"
