zplugin ice from"gh-r" as"program" bpick"*linux_amd64.tar.gz" pick"pet/pet" wait silent
zplugin light knqyf263/pet

function pet-register() {
  PREV="$(fc -lrn | head -n 1)"
  sh -c "pet new $(printf %q "$PREV")"
}
function pet-select() {
  BUFFER=$(pet search --color --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle redisplay
}
zle -N pet-select
bindkey '^s' pet-select

#function pet-copy() {
#  pet search --query "$LBUFFER" | clipcopy
#}
#zle -N pet-copy
#bindkey '^l' pet-copy
