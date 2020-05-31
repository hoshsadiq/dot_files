zinit ice depth=1 wait silent
zinit snippet OMZ::lib/completion.zsh

zinit ice depth=1 wait"2" silent
zinit snippet OMZ::lib/compfix.zsh

zinit ice as"completion" has'setcap' wait silent blockf
zinit snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_setcap

zinit ice as"completion" has'vagrant' wait silent blockf
zinit snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_vagrant

zinit ice as"completion" has'virtualbox' wait silent blockf
zinit snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_virtualbox

zinit ice as"completion" has'xinput' wait silent blockf
zinit snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_xinput

zinit ice as"completion" has'go' wait silent blockf
zinit snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_golang

zinit ice as"completion" has'ufw' wait silent blockf
zinit snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_ufw

zinit ice as"completion" has'fly' wait silent blockf
zinit snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_concourse

zinit ice as"completion" has'fwupdmgr' wait silent blockf
zinit snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_fwupdmgr

zinit ice as"completion" has'openssl' wait silent blockf
zinit snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_openssl

zinit ice as"completion" has'podman' wait silent blockf
zinit snippet "https://github.com/containers/libpod/blob/v$(podman version --format '{{.Client.Version}}')/completions/zsh/_podman"

# todo pip, pipenv
