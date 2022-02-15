if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}%F{220}Installing %F{33}zdharma-continuum/zinit%F{220}…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}%F{34}Installation successful.%f%b" || \
        print -P "%F{160}The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light-mode for \
  @zdharma-continuum/zinit-annex-patch-dl

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
    OMZ::lib/termsupport.zsh \
    OMZ::plugins/command-not-found/command-not-found.plugin.zsh \
    atload'_zsh_rebind_globalias' OMZ::plugins/globalias/globalias.plugin.zsh

zinit light-mode silent wait silent as"program" for \
  pick"tldr" @raylee/tldr

zinit light-mode depth=1 wait silent for \
  @hlissner/zsh-autopair \
  compile'{src/*.zsh,src/strategies/*}' atload'_zsh_autosuggest_start' @zsh-users/zsh-autosuggestions \
  blockf @Tarrasch/zsh-functional \
  as"program" pick"$ZPFX/bin/git-*" src"etc/git-extras-completion.zsh" make"PREFIX=$ZPFX" @tj/git-extras

zinit lucid wait'1' for \
  @dracula/zsh-syntax-highlighting \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" @zdharma-continuum/fast-syntax-highlighting

zinit light-mode from'gh-r' as'program' wait'2' silent for \
  pick'shellcheck-*/shellcheck' koalaman/shellcheck \
  jesseduffield/lazydocker \
  jesseduffield/lazygit

# zinit for light-mode as'program' wait'2' silent \
#      pick'gnome-shell-extension-installer' @brunelli/gnome-shell-extension-installer

# todo use kubectl krew instead.
#zinit light-mode wait'2' silent for \
#      @johanhaleby/kubetail

# use https://github.com/zdharma-continuum/zinit-annex-readurl
# todo install minikube
# todo install container-diff

# this is quite buggy as of yet, so maybe in the future
#zinit ice silent
#zinit light marlonrichert/zsh-autocomplete

# todo these need to be loaded conditionally
# zinit snippet OMZ::plugins/osx/osx.plugin.zsh

__spicetify_setup_spicetify_themes() {
  if [[ -d "$PWD/spicetify-themes" ]]; then
    git -C "$PWD/spicetify-themes" pull
  else
    git clone https://github.com/morpheusthewhite/spicetify-themes.git "$PWD/spicetify-themes"
  fi

  find "$PWD/Themes" -type l -delete
  find "$PWD/spicetify-themes" -mindepth 1 -maxdepth 1 -type d -not -name ".*" -not -name "_*" -print0 | xargs -0 -n1 -i% -- ln -fs % "$PWD/Themes"

  unfunction __spicetify_setup_spicetify_themes
}

__spicetify_setup_flatpak() {
  local spicetify_path current_dirs dir

  spicetify_path="$(dirname "$(spicetify -c)")"
  current_dirs=("${(@f)$(flatpak override --user --show com.spotify.Client | awk -F= '/^filesystems/{print $2}' | tr ';' '\n')}")
  for dir in {"$spicetify_path","$PWD"}/{CustomApps,Extensions}:ro; do
    if [[ ${current_dirs[(r)$dir]} != "$dir" ]] ; then
      flatpak override --user --filesystem="$dir" com.spotify.Client
    fi
  done

  unfunction __spicetify_setup_flatpak
}

zinit light-mode wait silent as"program" from"gh-r" for \
    atclone'ln -fs gojq_*/gojq jq; compdef _gojq jq' atpull'%atclone' pick"gojq_*/gojq jq" atinit'zicompinit; zicdreplay' @itchyny/gojq \
    atclone"__spicetify_setup_spicetify_themes" atpull"%atclone" pick'spicetify' atload'__spicetify_setup_flatpak' @khanhas/spicetify-cli \
    atload'!source <(./saml2aws --completion-script-zsh)' @Versent/saml2aws \
    atload'!source <(./awless completion zsh)' @wallix/awless \
    bpick"*_linux_amd64.tar.gz" pick"dive" @wagoodman/dive \
    @wader/fq \
    @matsuyoshi30/gitsu \
    @nektos/act \
    @PaulJuliusMartinez/jless \
    @hoshsadiq/big-fat-converter \
    @hrkfdn/ncspot \
    atinit'alias watch=viddy' @sachaos/viddy \
    pick'tfq' @mattcanty/terraform-query \
    pick"nvim*/bin/nvim" @neovim/neovim \
    @benibela/xidel


zinit light-mode wait silent as"program" for \
    atclone"md2man -in=README.md -out=$ZPFX/share/man/man1/x11docker.1" pick'x11docker x11docker-gui' @mviereck/x11docker \
    make'!' atclone"mv bin/go-md2man bin/md2man; md2man -in=go-md2man.1.md -out=$ZPFX/share/man/man1/md2man.1" atpull"%atclone" pick"bin/md2man" @cpuguy83/go-md2man

# for neovim
zinit light-mode wait silent as'program' from"gh-r" for \
      mv'tree-sitter* -> tree-sitter' pick'tree-sitter' @tree-sitter/tree-sitter
