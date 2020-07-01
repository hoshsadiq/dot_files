zinit snippet OMZ::plugins/extract

zinit ice as"completion" pick'_extract'
zinit snippet OMZ::plugins/extract/_extract

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
