export GBT_CAR_SIGN_WRAP=1

export GBT_CAR_DIR_DEPTH=2
export GBT_CAR_KUBECTL_FORMAT=" {{ Icon }} {{ Context }}|{{ Cluster }} "

export GBT_CARS="Status, Os, Hostname, Dir, Git, Kubectl, PyVirtEnv, Sign"

PROMPT='$(gbt $?)'

# GBT_RCARS='Time'
# RPROMPT='$(gbt -right)'
