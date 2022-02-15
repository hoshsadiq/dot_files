# for now! though, apparently asdf plugins handle completions
zinit ice has'goreleaser' id-as'goreleaser---completions' \
        wait silent blockf nocompile as'completion' \
        atclone'goreleaser completion zsh >! _goreleaser' \
        atpull'%atclone' run-atpull
zinit light zdharma-continuum/null
