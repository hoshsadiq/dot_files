download-helm-chart() {
    chart="$1"
    targetDir="$2"

    if [ "$chart" = "" ] && [ "$targetDir" = "" ]; then
        echo "Usage: $0 <chart-name> <target-dir>"
    fi

    tmpdir="$(mktemp -d -t helm)"

    curl -sSL -o "$tmpdir/helm-charts.zip" https://github.com/kubernetes/charts/archive/master.zip

    unzip "$tmpdir/helm-charts.zip" "charts-master/stable/$chart*" -d $tmpdir
    mv "$tmpdir/charts-master/stable/$chart" "$targetDir/$chart-helm-chart"
}

kubectl_pod() {
    # todo add --namespace support
    kubectl get pods | awk "/^$1/{print \$1}"
}
