zplugin ice depth=1 wait silent
zplugin snippet OMZ::lib/completion.zsh

zplugin ice depth=1 wait"2" silent
zplugin snippet OMZ::lib/compfix.zsh

zplugin ice as"completion" has'setcap' wait silent blockf
zplugin snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_setcap

zplugin ice as"completion" has'vagrant' wait silent blockf
zplugin snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_vagrant

zplugin ice as"completion" has'virtualbox' wait silent blockf
zplugin snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_virtualbox

zplugin ice as"completion" has'xinput' wait silent blockf
zplugin snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_xinput

zplugin ice as"completion" has'go' wait silent blockf
zplugin snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_golang

zplugin ice as"completion" has'ufw' wait silent blockf
zplugin snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_ufw

zplugin ice as"completion" has'fly' wait silent blockf
zplugin snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_concourse

zplugin ice as"completion" has'fwupdmgr' wait silent blockf
zplugin snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_fwupdmgr

zplugin ice as"completion" has'openssl' wait silent blockf
zplugin snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_openssl

zplugin ice as"completion" has'docker' wait silent blockf
zplugin snippet "https://github.com/docker/cli/blob/v$(docker version --format '{{.Client.Version}}')/contrib/completion/zsh/_docker"

# todo pip, pipenv
