export COMPLETIONS_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/mise/completions"
mkdir -p "$COMPLETIONS_DIR"
fpath+=("$COMPLETIONS_DIR")

__load_completions() {
  compfile="$1"
  shift
  compdefs=("$@")

  if [[ $compfile != _* || $compfile == __* ]]; then
    printf >&2 "expected argument #1 compfile to start with a single underscore, got: %s\n" "$compfile"
    return 1
  fi

  if (( ${#compdefs[@]} == 0 )); then
    compdefs+=("${compfile:1}")
  fi

  if [[ -r "$COMPLETIONS_DIR/$compfile" ]]; then
    autoload -Uz "$compfile"
    for compdef in "${compdefs[@]}"; do
      compdef "$compfile" "$compdef"
    done
  fi
}

eval "$(~/.local/bin/mise activate zsh)"

__load_completions _goreleaser
__load_completions _golangci-lint
__load_completions _sg
__load_completions _gojq gojq jq
__load_completions _yq
__load_completions _awless
__load_completions _dive
__load_completions _dyff
__load_completions _topgrade
__load_completions _tree-sitter
