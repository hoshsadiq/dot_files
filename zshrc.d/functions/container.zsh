# container.zsh — enhance `container image ls` with real on-disk usage.
#
# Apple's container CLI reports only compressed manifest blob sizes, which
# badly under-report disk usage. The snapshot store keeps one sparse ext4
# file per image variant, keyed by manifest digest:
#   ~/Library/Application Support/com.apple.container/snapshots/<digest>/snapshot
#
# This overrides `container` so `container image ls` prints the same table as
# `container image ls --verbose`, plus an ON DISK column showing what du says
# that variant's snapshot actually allocates, and a footer listing orphaned
# snapshot dirs left behind by deleted images.
#
# Scripted consumers are left alone: `--format json`, `--quiet`, and every
# other `container` subcommand pass through to the real binary untouched.

_container_human_size() {
    # $1 = bytes. print "X.Y unit" without spawning external tools.
    awk -v b="$1" 'BEGIN{
        if (b >= 1073741824) printf "%.1f GiB", b/1073741824;
        else if (b >= 1048576) printf "%.1f MiB", b/1048576;
        else printf "%.1f KiB", b/1024;
    }'
}

_container_image_ls() {
    local snap_dir="${CONTAINER_SNAP_DIR:-$HOME/Library/Application Support/com.apple.container/snapshots}"
    local json idx digest size on_disk created

    if (( ${+commands[jq]} == 0 )); then
        command container image ls --verbose
        return
    fi

    json="$(command container image ls --format json 2>/dev/null)" || {
        command container image ls
        return
    }

    printf '%-13s %-9s %-13s %-6s %-5s %-8s %-10s %-10s %-20s %s\n' \
        NAME TAG "INDEX DIGEST" OS ARCH VARIANT "FULL SIZE" "ON DISK" CREATED "SNAPSHOT DIGEST"

    print -r -- "$json" \
    | jq -r '.[]
        | .id as $idx
        | .configuration.name as $name
        | .variants[]
        | [ ($name
             | split(":")[0] | split("/") | last),
            ($name | split(":") | if length > 1 then last else "-" end),
            $idx[0:12],
            .platform.os,
            .platform.architecture,
            (.platform.variant // "-"),
            .size,
            (.config.created // ""),
            .digest
          ] | @tsv' \
    | while IFS=$'\t' read -r name tag idx os arch variant size created digest; do
        digest="${digest#sha256:}"
        if [[ -f "$snap_dir/$digest/snapshot" ]]; then
            on_disk="$(_container_human_size "$(( $(du -k "$snap_dir/$digest/snapshot" | cut -f1) * 1024 ))")"
        else
            on_disk="-"
        fi
        printf '%-13s %-9s %-13s %-6s %-5s %-8s %-10s %-10s %-20s %s\n' \
            "$name" "$tag" "$idx" "$os" "$arch" "$variant" \
            "$(_container_human_size "$size")" "$on_disk" "${created[1,19]}" "$digest"
    done

    _container_orphans "$snap_dir"
}

# Footer: snapshot dirs whose digest no current image references. These are
# leftovers from deleted images (`container image prune` is known-broken and
# does not reclaim them).
_container_orphans() {
    local snap_dir="$1"
    local -a known orphans
    local d b size json
    local total=0

    json="$(command container image ls --format json 2>/dev/null)" &&
        known=(${(f)"$(print -r -- "$json" | jq -r '.[].variants[].digest // empty' | sed 's/^sha256://' | sort -u)"})

    for d in "$snap_dir"/*(N/); do
        b="${d:t}"
        [[ $b == ingest ]] && continue
        (( ${known[(Ie)$b]} )) && continue
        size=0
        [[ -f "$d/snapshot" ]] && size="$(du -k "$d/snapshot" 2>/dev/null | cut -f1)"
        [[ -n $size ]] || size=0
        orphans+=("$size|$b")
        (( total += size ))
    done

    (( ${#orphans} )) || return 0

    printf '\nORPHANED SNAPSHOTS (unreferenced by any image — prune candidates):\n'
    for o in $orphans; do
        printf '  %-64s %s\n' "${o#*|}" "$(_container_human_size "$(( ${o%%|*} * 1024 ))")"
    done
    printf '  %-64s %s reclaimable\n' "(total)" "$(_container_human_size "$(( total * 1024 ))")"
    return 0
}

container() {
    # Only intercept `container image ls` / `container image list`.
    if (( $# >= 2 )) && [[ $1 == image ]] && [[ $2 == ls || $2 == list ]] &&
       [[ " $* " != *" --format "* ]] && [[ " $* " != *" --quiet "* ]] && [[ " $* " != *" -q "* ]]; then
        _container_image_ls
        return
    fi
    command container "$@"
}