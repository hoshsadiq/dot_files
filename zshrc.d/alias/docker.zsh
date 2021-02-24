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
alias bw='docker run -it --rm -v bw:"/root/.config/Bitwarden CLI" -e BW_SESSION bitwarden-cli:latest'

#alias docker-dive='podman run --rm -it wagoodman/dive:latest'

alias pm='podman'
alias pmx='podman exec'
alias pml='podman logs'
alias pc='podman-compose'
alias pcx='podman-compose exec'

shit() {
  podman run -it --rm --entrypoint /bin/sh -v "${PWD}:/workdir" -w /workdir "$@" -c '# shit-run
command -v bash >/dev/null || {
  >&2 echo "Bash not available, installing first..."
  command -v apt-get >/dev/null && export DEBIAN_FRONTEND=noninteractive && apt-get update -q && apt-get install bash
  command -v apk >/dev/null && apk add --no-cache -q --no-progress bash
  command -v yum >/dev/null && yum install -q bash
}

if grep -qFi debian /etc/os-release; then
  echo "Setting DEBIAN_FRONTEND=noninteractive; Remember to set it in your Dockerfile if you need"
  export DEBIAN_FRONTEND=noninteractive
fi

# todo need to find additional env vars that might be needed
echo "PATH=$PATH" >> ~/.bash_profile

exec bash -l
'
}
