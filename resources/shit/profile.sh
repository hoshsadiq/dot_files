# todo maybe utilise: https://github.com/LEI/porcelain/blob/master/porcelain.sh
function __fastgit_ps1 () {
    return 0

    local headfile head branch status
    local dir="$PWD"

    while [ -n "$dir" ]; do
        if [ -e "$dir/.git/HEAD" ]; then
            headfile="$dir/.git/HEAD"
            break
        fi
        dir="${dir%/*}"
    done

    if [ -e "$headfile" ]; then
        read -r head < "$headfile" || return
        case "$head" in
            ref:*) branch="${head#*/}"; branch="${branch#*/}" ;;
            "") branch="" ;;
            *) branch="${head:0:7}" ;;
        esac
    fi

    if [ -z "$branch" ]; then
        return 0
    fi

    # modified from https://github.com/jethrokuan/git_porcelain/blob/master/functions/git_porcelain.fish
    if command -v git >/dev/null; then
      status="$(git status --porcelain 2>/dev/null | \
                    awk "
                      /^A[MCDR ]/                  { sa++ }
                      /^M[ACDRM ]/ || /^[ACDRM ]M/ { sm++ }
                      /^D[AMCR ]/ || /^[AMCR ]D/   { sd++ }
                      /^R[AMCD ]/                  { sr++ }
                      /^C[AMDR ]/                  { sc++ }
                      /^\?\?/                      { uu++ }
                      END {
                        if (sa > 0) { printf(\" %dA\", sa); }
                        if (sm > 0) { printf(\" %dM\", sm); }
                        if (sd > 0) { printf(\" %dD\", sd); }
                        if (sr > 0) { printf(\" %dR\", sr); }
                        if (sc > 0) { printf(\" %dC\", sc); }
                        if (su > 0) { printf(\" %dU\", su); }
                      }"
                )"
    else
      status=""
    fi

    if [[ -z "$1" ]]; then
        printf "(%s%s) " "$branch" "$status"
    else
        printf "$1" "$branch" "$status"
    fi
}

source /etc/environment

shopt -s histappend                                       # Append to the history file, do not overwrite it
shopt -s cmdhist                                          # Save multi-line commands as one command

PROMPT_COMMAND="history -a"                               # Record each line as it gets issued

HISTSIZE=500000                                           # Huge history. Does not appear to slow things down, so why not?
HISTFILESIZE=100000
HISTCONTROL="erasedups:ignoreboth"                        # Avoid duplicate entries
HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"           # Do not record some commands
HISTTIMEFORMAT="%F %T "                                   # Use standard ISO 8601 timestamp

#HISTFILE=...                                             # Retrieved from --env var from docker/podman

shopt -s autocd 2> /dev/null                              # Prepend cd to directory names automatically
shopt -s dirspell 2> /dev/null                            # Correct spelling errors during tab-completion
shopt -s cdspell 2> /dev/null                             # Correct spelling errors in arguments supplied to cd

PROMPT_DIRTRIM="3"

PS1=""
for pkgMan in apt-get apk yum microdnf; do
  if command -v $pkgMan >/dev/null; then
    PS1="$PS1\[\e[32m\](\[\e[m\]\[\e[33m\]$pkgMan\[\e[m\]\[\e[32m\])\[\e[m\] "
  fi
done
if [[ -z $PS1 ]]; then
  PS1="$PS1\[\e[32m\](\[\e[m\]\[\e[33m\]???\[\e[m\]\[\e[32m\])\[\e[m\] "
fi
PS1="$PS1\[\e[32m\][\[\e[m\]"
PS1="$PS1\[\e[31m\]\u\[\e[m\]"
PS1="$PS1\[\e[32m\]:\[\e[m\]"
PS1="$PS1\[\e[36m\]\w\[\e[m\]"
PS1="$PS1\$(__fastgit_ps1 \"\[\e[32m\]@\[\e[m\]\[\e[01;32m\]%s%s\[\e[m\]\")"
PS1="$PS1\[\e[32m\]]\[\e[m\]"
PS1="$PS1\[\e[32m\]\\$\[\e[m\] "

export PIP_ROOT_USER_ACTION=ignore
export PATH="$PATH:$HOME/.local/bin"
