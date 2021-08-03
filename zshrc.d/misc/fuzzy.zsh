zinit ice silent wait as"program" from"gh-r" atload'export FZF_DEFAULT_OPTS="--reverse --exit-0 --border --ansi"'
zinit light junegunn/fzf

zinit ice as'program' id-as"junegunn/fzf-extras" multisrc"shell/{completion,key-bindings}.zsh" \
  atclone'cp -vf man/man1/fzf* $ZPFX/share/man/man1' \
  atpull"%atclone" \
  pick"bin/fzf-tmux"
zinit light junegunn/fzf

zinit ice silent
zinit light Aloxaf/fzf-tab

zinit ice silent as'program' pick'bin/*'
zinit light bigH/git-fuzzy

manf() {
  MAN="$(command -pv man)"
  if [ -n "$1" ]; then
    batman "$@"
    return $?
  else
    $MAN --manpath="$($MAN -w)" -k . | fzf --reverse --preview="echo {1,2} | sed -E -e 's/ \(/./' -e 's/\)\s*$//' | xargs batman --color=always" | awk '{print $1 "." $2}' | tr -d '()' | xargs -r batman
    return $?
  fi
}

jqf() (
  local exec skip jq_args query input tmp_dir preview_cmd_args_file header_file history_file

  _jqf_panic() {
    # shellcheck disable=SC2059
    printf >&2 "$@"
    exit 1
  }

  jq_args=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --)
      skip=1
      shift
      ;;
    *)
      [[ -n "$skip" ]] && jq_args+=("$1") && shift && continue
      [[ "$1" == "-e" ]] && exec=1 && shift && continue
      [[ -f "$1" ]] && [[ -n "$input" ]] && panic "expected only a single input, already got $input"
      if [[ -f "$1" ]]; then
        if [[ ! -r "$1" ]]; then
          panic "file %s does not exist" "$input"
        fi

        input="$1"
        shift
        continue
      fi
      jq_args+=("$1") && shift
      ;;
    esac
  done

  tmp_dir="$(mktemp --directory -t jqf.XXXXXXXXXX)"
  trap 'command rm -rf $tmp_dir' EXIT

  # todo this doesn't allow for streaming any more. It will block until stdin is finished.
  if [[ -z "$input" ]]; then
    input="$tmp_dir/in"
    cat /dev/stdin >"$input"
  fi

  preview_cmd_args_file="$tmp_dir/args"
  header_file="$tmp_dir/header"
  touch "$preview_cmd_args_file"
  printf '%s\n' '-C' >>"$preview_cmd_args_file"
  command cp "$preview_cmd_args_file" "$header_file"

  history_file="$HOME/.cache/fzf/.jqfhistory"
  [[ ! -d $(dirname "$history_file") ]] && mkdir -p "$(dirname "$history_file")"
  touch "$history_file"

  _jqf_preview_cmd() {
    cat <<EOF
  query={q}
  [ ! -n \$query ] && query="." # todo this doesn't work

  command jq $(printf "%q" "$@") \$(cat "$preview_cmd_args_file") "\$query" "$input" >"$tmp_dir/out.tmp" 2>&1
  rc=\$?

  headers="\$(sed 's/\x1B\[\([0-9]\{1,2\}\(;[0-9]\{1,2\}\)\?\)\?[mGK]//g' $header_file | grep -vE '^(err|null|OK)$')"
  if [[ ! -f $tmp_dir/out ]]; then
    command mv $tmp_dir/out.tmp $tmp_dir/out
    headers="\$(printf '\x1b[1;32mOK\x1b[0m\n%s\n' "\$headers")"
  elif [[ \$rc != 0 ]]; then
    headers="\$(printf '\x1b[1;31merr\x1b[0m\n%s\n' "\$headers")"
    echo -n "\x1b[1;31m"
    command cat "$tmp_dir/out.tmp"
    echo "---\x1b[0m"
  elif [[ "\$(sed 's/\x1B\[\([0-9]\{1,2\}\(;[0-9]\{1,2\}\)\?\)\?[mGK]//g' $tmp_dir/out.tmp)" == 'null' ]]; then
    headers="\$(printf '\x1b[1;33mnull\x1b[0m\n%s\n' "\$headers")"
  else
    command mv $tmp_dir/out.tmp $tmp_dir/out
    headers="\$(printf '\x1b[1;32mOK\x1b[0m\n%s\n' "\$headers")"
  fi
  echo "\$headers" > $header_file
  sync

  command cat $tmp_dir/out
EOF
  }

  _jqf_update_flag_cmd() {
    opt="$1"
    opt_exclusive="${2:-}"

    # language=shell
    command cat <<EOF
    if grep -qF -- "$opt" "$preview_cmd_args_file"; then
      sed -i "/^$opt/d" "$preview_cmd_args_file"
    else
EOF
    if [[ -n $opt_exclusive ]]; then
      command cat <<EOF
      sed -i "/^$opt_exclusive/d" "$preview_cmd_args_file";
EOF
    fi

    command cat <<EOF
      printf "%s\n" "$opt" >> "$preview_cmd_args_file";
    fi
    command cp "$preview_cmd_args_file" "$header_file"
    sync
EOF
  }

  query="$(
    echo -e "$(<"$header_file")\n" |
      fzf --phony \
        --no-extended \
        --disabled \
        --sync \
        --ansi \
        --tabstop=4 \
        --prompt='jq> ' \
        --history="$history_file" \
        --info=hidden \
        --header-lines=1 \
        --print-query \
        --preview-window='down:99%' \
        --preview "$(_jqf_preview_cmd "${jq_args[@]}")" \
        `# todo sleep 0.1 is hacky. Need a better way of ensuring the header file is updated before FZF is reloaded.` \
        --bind "change:refresh-preview+reload(sleep 0.1; tr '\n' ' ' <$header_file)" \
        --bind="alt-r:execute-silent($(_jqf_update_flag_cmd "-r"))+refresh-preview+reload(sleep 0.1; tr '\n' ' ' <$header_file)" \
        --bind="alt-c:execute-silent($(_jqf_update_flag_cmd "-c"))+refresh-preview+reload(sleep 0.1; tr '\n' ' ' <$header_file)" \
        --bind="alt-j:execute-silent($(_jqf_update_flag_cmd "-j")+refresh-preview+reload(sleep 0.1; tr '\n' ' ' <$header_file)" \
        --bind="alt-0:execute-silent($(_jqf_update_flag_cmd "-0")+refresh-preview+reload(sleep 0.1; tr '\n' ' ' <$header_file)" \
        --bind="alt-M:execute-silent($(_jqf_update_flag_cmd "-M" "-C")+refresh-preview+reload(sleep 0.1; tr '\n' ' ' <$header_file)" \
        --bind="alt-C:execute-silent($(_jqf_update_flag_cmd "-C" "-M")+refresh-preview+reload(sleep 0.1; tr '\n' ' ' <$header_file)" \
        `# vim bindings` \
        --bind="ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up" \
        --bind="ctrl-j:preview-down,ctrl-k:preview-up" \
        `# normal bindings` \
        --bind="pgdn:preview-half-page-down,pgup:preview-half-page-up" \
        --bind="down:preview-down,up:preview-up" \
    )"

  if [[ -n "$exec" ]]; then
    jq "${jq_args[@]}" $(cat "$preview_cmd_args_file") "$query" "$input"
    return $?
  fi

  printf "%s" "$query"
)

rga-fzf() {
  RG_PREFIX="rga --files-with-matches"
  local file
  file="$(
    FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
      fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
      --phony -q "$1" \
      --bind "change:reload:$RG_PREFIX {q}" \
      --preview-window="70%:wrap"
  )" &&
    echo "opening $file" &&
    xdg-open "$file"
}

__fffzf_sqlite_query() (
  local db format default_query query
  local sep tmp_file_basename tmpfile profile

  db="$1"
  format="$2"
  default_query="$3"
  query="$4"

  tmp_file_basename="$(basename "$db" .sqlite)"

  sep="{::}"

  tmpfile="$(mktemp "${tmp_file_basename}.XXXXXXXXXX")"
  trap 'command rm -rf $tmpfile' EXIT

  profile="$(awk -F= '/^Default/{print $2}' <"$HOME/.mozilla/firefox/installs.ini")"

  command cp -f "$HOME/.mozilla/firefox/$profile/$db" "$tmpfile"
  chmod 600 "$tmpfile"

  \sqlite3 -readonly -separator "$sep" "$tmpfile" "$query" |
    awk -F $sep "$format" |
    sed -E 's/\x1b\[[0-9;]+m  //g' |
    fzf \
      --ansi \
      --multi \
      --tiebreak=begin \
      --bind 'alt-y:execute-silent(echo {-1} | xclip -i -selection clipboard)+abort' \
      --query "${default_query} "
)

bookmarks() {
  local cols default_query

  cols=$((COLUMNS / 2))

  default_query=()

  # todo the tags column is removed cos apparently I don't use them.
  awk_format="$(
    <<EOF
    {
      if(length(\$1)>${cols}) \$1=substr(\$1,1,${cols}) "...";

      # printf "\x1b[36m%-${cols}s  \x1b[m  %-$((cols / 3))s  %s\n", \$1, \$2, \$3
      printf "\x1b[36m%-${cols}s  \x1b[m  %s\n", \$1, \$2
    }
EOF
  )"

  __fffzf_sqlite_query "weave/bookmarks.sqlite" "$awk_format" "${default_query[*]}" "$(
    <<EOF
      SELECT i.title,
      --       REPLACE(GROUP_CONCAT(t.tag), ',', ', ') AS tags,
             u.url
      FROM items i
               JOIN urls u ON i.urlId = u.id
               LEFT OUTER JOIN tags t ON i.id = t.itemId
      GROUP BY i.id;
EOF
  )"
}

bhistory() {
  local cols date_cols title_cols default_query hide_urls hide_urls_query url_query awk_format

  cols=$((COLUMNS / 3))
  date_cols=19
  title_cols=$(( cols + ((cols - date_cols) / 2) ))

  default_query=()

  hide_urls=("%google.com/search%" "%github.com/search%" "%github.com/notification%" "file://%" "%.com/notifications/" "%.com/notifications" "%.org/profile/notifications/" "%.org/profile/notifications")
  hide_urls_query="$(printf "AND p.url NOT LIKE '%s'\n" "${hide_urls[@]}")"

  # todo the tags column is removed cos apparently I don't use them.
  awk_format="$(
    <<EOF
    {
      printf "%-${date_cols}s  \x1b[36m%-${title_cols}s  \x1b[m  %-${cols}s\n", \$1, \$2, \$3
    }
EOF
  )"

  url_query="$(<<EOF
  CASE
    WHEN substr(p.url, 1, 7) == 'http://'
      THEN 'https://' || substr(p.url, 8, length(p.url))
    ELSE p.url
    END
EOF
)"

  __fffzf_sqlite_query "places.sqlite" "$awk_format" "${default_query[*]}" "$(
    <<EOF
      SELECT
        datetime(v.visit_date / 1000000, 'unixepoch')               AS last_visited,
        CASE
          WHEN p.title IS NULL or p.title == '' THEN '<untitled>'
          ELSE
            CASE
              WHEN length(p.title) > ${title_cols}
                THEN substr(p.title, 1, ${title_cols}) || '...'
              ELSE p.title
              END
          END                                                       AS title,
        ${url_query}                                                AS url
      FROM moz_places p
               JOIN moz_historyvisits v ON p.id = v.place_id
      WHERE 1=1 ${hide_urls_query}
      GROUP BY ${url_query}
      ORDER BY last_visit_date DESC
EOF
  )"
}

# Check out a branch/tag via FZF
# todo should this be in git.zsh?
fco() {
  local tags branches query

  tags="$(git tag | sed -e '/^$/d' -e 's/^/\x1b[31;1mtag\x1b[m\t/')"
  branches="$(git branch --all |
    sed -e "/HEAD/d" -e "s/.* //" -e "s#remotes/[^/]*/##" -e '/^$/d' -e "s/^/\x1b[34;1mbranch\x1b[m\t /" |
    sort -u)"

  query="$({ [[ -n $branches ]] && echo "$branches"; [[ -n $tags ]] && echo "$tags"; } |
    fzf \
      --no-hscroll \
      --reverse \
      --ansi \
      --no-multi \
      --border \
      --delimiter="\t" \
      --nth=2 \
      --query="$*" \
      --height '50%' \
      --bind 'alt-y:execute-silent(echo {-1} | xclip -i -selection clipboard)+abort')" # todo why does `yank` not work?

  if [[ -z $query ]]; then
    # todo how can prevent this error/rc when yanking?
    printf >&2 "Nothing selected, aborting...\n"
    return 1
  fi

  git checkout "$(echo "$query" | awk '{print $2}')"
}
