zinit ice depth=1 wait silent
zinit snippet OMZ::lib/completion.zsh

zinit ice depth=1 wait"2" silent
zinit snippet OMZ::lib/compfix.zsh

zinit ice as"completion" has'setcap' wait silent blockf
zinit snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_setcap

zinit ice as"completion" has'vagrant' wait silent blockf
zinit snippet https://raw.githubusercontent.com/soapy1/vagrant/master/contrib/zsh/_vagrant

zinit ice as"completion" has'xinput' wait silent blockf
zinit snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_xinput

zinit ice as"completion" has'ufw' wait silent blockf
zinit snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_ufw

zinit ice as"completion" has'fwupdmgr' wait silent blockf
zinit snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_fwupdmgr

zinit ice as"completion" has'openssl' wait silent blockf
zinit snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_openssl

zinit ice as"completion" has'circleci' wait silent blockf
zinit snippet https://github.com/zchee/zsh-completions/blob/main/src/go/_circleci

zinit ice as"completion" has'dive' wait silent blockf
zinit snippet https://github.com/zchee/zsh-completions/blob/main/src/go/_dive

zinit ice as"completion" has'shellcheck' wait silent blockf
zinit snippet https://github.com/zchee/zsh-completions/blob/main/src/zsh/_shellcheck

# todo doesn't work yet
zinit ice as"completion" has'go' wait silent blockf
zinit snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_golang
