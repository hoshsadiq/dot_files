# https://grml.org/zsh/zsh-lovers.html

rationalise-dot() {
  if [[ $LBUFFER == *"go "* ]]; then
    LBUFFER+=.
    return
  fi

  if [[ $LBUFFER == *.. ]]; then
    LBUFFER+=/..
  else
    LBUFFER+=.
  fi
}

zle -N rationalise-dot
bindkey . rationalise-dot
# Without the following, typing a period aborts incremental history search
bindkey -M isearch . self-insert
