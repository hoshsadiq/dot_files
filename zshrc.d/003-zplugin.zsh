if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light-mode for zinit-zsh/z-a-patch-dl

function _zsh_rebind_globalias() {
    bindkey -r -M viins " "
    bindkey -r -M viins "^ "
    bindkey -M viins "^ " globalias
    bindkey -M viins " " magic-space

    unfunction _zsh_rebind_globalias
}

# oh my zsh plugins
zinit depth=1 wait silent for \
    OMZ::lib/grep.zsh \
    OMZ::lib/spectrum.zsh \
    OMZ::lib/clipboard.zsh \
    OMZ::lib/termsupport.zsh \
    OMZ::plugins/command-not-found/command-not-found.plugin.zsh \
    atload'_zsh_rebind_globalias' OMZ::plugins/globalias/globalias.plugin.zsh

zinit ice wait silent
zinit light hlissner/zsh-autopair

zinit ice wait as"program" pick"tldr" silent
zinit light raylee/tldr

zinit lucid depth=1 wait for \
  compile'{src/*.zsh,src/strategies/*}' atload'_zsh_autosuggest_start' @zsh-users/zsh-autosuggestions \
  blockf @Tarrasch/zsh-functional \
  as"program" pick"$ZPFX/bin/git-*" src"etc/git-extras-completion.zsh" make"PREFIX=$ZPFX" @tj/git-extras

zinit ice wait'1' silent as"command" from"gh-r" pick"gojq_*/gojq jq" \
    atclone'ln -fs gojq_*/gojq jq; compdef _gojq jq; zicompinit; zicdreplay' \
    atpull'%atclone'
zinit light itchyny/gojq

zinit lucid wait'1' for \
  @dracula/zsh-syntax-highlighting \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" @zdharma/fast-syntax-highlighting

zinit for light-mode from'gh-r' as'program' wait'2' silent pick'shellcheck-*/shellcheck' \
      koalaman/shellcheck

zinit light-mode from'gh-r' as'program' wait'2' silent for \
      jesseduffield/lazydocker \
      jesseduffield/lazygit

# todo completion doesn't work yet
zinit for light-mode from'gh-r' as'program' wait'2' atpull'%atclone' run-atpull silent \
      atclone'./awless completion zsh > _awless' src'_awless' @wallix/awless \
      atclone'./saml2aws --completion-script-zsh > _saml2aws' @Versent/saml2aws

zinit for light-mode as'program' wait'2' silent \
      pick'bin/*' @tfutils/tfenv
#      pick'gnome-shell-extension-installer' @brunelli/gnome-shell-extension-installer

zinit light-mode wait'2' silent for \
      @johanhaleby/kubetail

# use https://github.com/zinit-zsh/z-a-readurl
# todo install minikube
# todo install container-diff

# this is quite buggy as of yet, so maybe in the future
#zinit ice silent
#zinit light marlonrichert/zsh-autocomplete

# todo these need to be loaded conditionally
# zinit snippet OMZ::plugins/osx/osx.plugin.zsh

# todo is this atclone necessary?
zinit lucid wait light-mode as"program" from"gh-r" for \
    bpick"*_linux_amd64.tar.gz" pick"dive" @wagoodman/dive \
    atclone"gh completion -s zsh > _gh; mv gh*/share/man/man1/gh* $ZPFX/share/man/man1" atpull"%atclone" bpick'*_linux_amd64.tar.gz' pick"gh_*/bin/gh" @cli/cli \
    pick"awless" @wallix/awless \
    @nektos/act

#zinit lucid wait nocompletions from"gh-r" for \
#      bpick"*.appimage" as"program" mv"nvim.appimage -> nvim" pick"nvim" neovim/neovim
