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

kp() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]
  then
    echo $pid | xargs kill -${1:-9}
  fi
}
