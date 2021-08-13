if (($+commands[podman])); then
  # requires podman 3.2.0 +
  export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock
  CONTAINER_RUNTIME="podman"
else
  CONTAINER_RUNTIME="docker"
fi

alias cfn-flip='$CONTAINER_RUNTIME run --rm -i --name cfn-flip -v $(pwd):/workdir -w /workdir cfn-flip'
alias cfviz='$CONTAINER_RUNTIME run --rm -i --name cfviz -v $(pwd):/workdir -w /workdir cfviz'
alias yaml2json='$CONTAINER_RUNTIME run --rm -i --name cfviz -v $(pwd):/workdir -w /workdir simplealpine/yaml2json'
alias graphviz='$CONTAINER_RUNTIME run --rm -i --name graphviz -v $(pwd):/workdir -w /workdir graphviz'
alias nmap='$CONTAINER_RUNTIME run --rm -i --name nmap nmap'
alias sgviz='$CONTAINER_RUNTIME run --rm -i --name sgviz -v $HOME/.aws:/root/.aws -v $(pwd):/workdir -w /workdir sgviz'
alias sipcalc='$CONTAINER_RUNTIME run --rm -i --name sipcalc sipcalc'
alias sqlite3='$CONTAINER_RUNTIME run --rm -i --name sqlite3 -v $(pwd):/workdir -w /workdir sqlite3'
alias travis='$CONTAINER_RUNTIME run --rm -ti --name travis -v $PWD:/workdir -v $HOME/.travis:/travis travis'
alias xml='$CONTAINER_RUNTIME run --rm -i --name xml -v $(pwd):/workdir -w /workdir xml'
alias xml-format='xml fo -s 2 -R'
alias bw='$CONTAINER_RUNTIME run -it --rm -v bw:"/bwcli/.config/Bitwarden CLI" -e BW_SESSION bitwarden-cli:latest'

#alias docker-dive='podman run --rm -it wagoodman/dive:latest'

alias pm='podman'
alias pmx='podman exec'
alias pml='podman logs'
alias pc='podman-compose'
alias pcx='podman-compose exec'
