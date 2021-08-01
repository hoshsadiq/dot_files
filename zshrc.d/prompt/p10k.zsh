# for some reason this has to be exported here eventhough $TERM is actually populated with this value already.
# export TERM=xterm-256color

zinit ice depth=1 atload"source $DOT_FILES/config/zsh/p10k.zsh"
zinit light romkatv/powerlevel10k
