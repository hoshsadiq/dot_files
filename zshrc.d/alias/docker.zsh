alias cfn-flip='docker run --rm -i --name cfn-flip -v $(pwd):/workdir -w /workdir cfn-flip'
alias cfviz='docker run --rm -i --name cfviz -v $(pwd):/workdir -w /workdir cfviz'
alias yaml2json='docker run --rm -i --name cfviz -v $(pwd):/workdir -w /workdir simplealpine/yaml2json'
alias graphviz='docker run --rm -i --name graphviz -v $(pwd):/workdir -w /workdir graphviz'
alias nmap='docker run --rm -i --name nmap nmap'
alias sgviz='docker run --rm -i --name sgviz -v $HOME/.aws:/root/.aws -v $(pwd):/workdir -w /workdir sgviz'
alias sipcalc='docker run --rm -i --name sipcalc sipcalc'
alias sqlite3='docker run --rm -i --name sqlite3 -v $(pwd):/workdir -w /workdir sqlite3'
alias travis='docker run --rm -ti --name travis -v $PWD:/workdir -v $HOME/.travis:/travis travis'
alias xml='docker run --rm -i --name xml -v $(pwd):/workdir -w /workdir xml'
alias xml-format='xml fo -s 2 -R'
alias bw='podman run -it --rm -v bw:"/bwcli/.config/Bitwarden CLI" -e BW_SESSION bitwarden-cli:latest'

#alias docker-dive='podman run --rm -it wagoodman/dive:latest'

alias pm='podman'
alias pmx='podman exec'
alias pml='podman logs'
alias pc='podman-compose'
alias pcx='podman-compose exec'

# requires podman 3.2.0 +
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock
