zinit ice as"completion"
zinit snippet OMZ::plugins/extract/_extract

zplugin snippet OMZ::plugins/extract/extract.plugin.zsh

# Creates an archive from given directory
mktar() {
  tar cvf  "${1%%/}.tar" "${1%%/}/"
}
mktgz() {
  tar cvzf "${1%%/}.tar.gz" "${1%%/}/"
}
mktbz() {
  tar cvjf "${1%%/}.tar.bz2" "${1%%/}/"
}
