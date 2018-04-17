# Docker aliases
alias sipcalc='docker run --rm -i --name sipcalc sipcalc'
alias cfn-flip='docker run --rm -i --name cfn-flip -v $(pwd):/workdir -w /workdir cfn-flip'
alias cfviz='docker run --rm -i --name cfviz -v $(pwd):/workdir -w /workdir cfviz'
alias graphviz='docker run --rm -i --name graphviz -v $(pwd):/workdir -w /workdir graphviz'
alias sgviz='docker run --rm -i --name sgviz -v $HOME/.aws:/root/.aws -v $(pwd):/workdir -w /workdir sgviz'
