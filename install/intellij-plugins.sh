# what about macos?
pluginPath="$HOME/.$(grep '\-Didea.paths.selector' /snap/intellij-idea-ultimate/current/bin/idea.sh | awk '{print $1}' | awk -F'=' '{print $2}')/config/plugins"

buildNumber="$(sed -E 's/IU-([0-9]+(\.[0-9]+)?)(\.([0-9]+))?/\1\4/' /snap/intellij-idea-ultimate/current/build.txt)"

typeset -A plugins
plugins=(\
	7724 docker-integration\
	4230 bashsupport\
	7495 ignore\
	7086 acejump\
	9333 makefile-support\
	10037 csv-plugin\
	8045 idea-mind-map\
	164 ideavim\
	7294 editorconfig\
	6834 apache-config-htaccess-support\
	7371 aws-cloudformation\
	9568 go\
	8195 toml\
	10485 kubernetes\
)
jqSubVersion='sub("(?<a>[0-9]+(\\.[0-9]+))(\\.(?<b>[0-9]+))"; "\(.a)\(.b)")'
jqSinceNumber='(.since | '${jqSubVersion}' | tonumber)'
jqUntilNumber='(.until | sub("\\*"; "999999") | '${jqSubVersion}' | tonumber)'
jqUntilIsUnset='(.until == "0.0")'
jqBuildNumber='($buildNumber | tonumber)'
jqQuery="[.updates[] | select( ($jqSinceNumber <= $jqBuildNumber) and (($jqUntilNumber >= $jqBuildNumber) or $jqUntilIsUnset) )][0] | .id"
for id name in ${(kv)plugins}; do
	echo "$id > $name"
	updateId="$(curl -fsSL "https://plugins.jetbrains.com/plugin/updates?pluginId=$id&channel=&start=0&size=20" | jq -r --arg buildNumber $buildNumber "$jqQuery")"
	if [ "$updateId" != "null" ]; then
	    echo "adding $name, $id, $updateId"
        #curl -fsSL "https://plugins.jetbrains.com/plugin/download?rel=true&updateId=$updateId" -o "/tmp/intellij-plugin-$name.zip"
        #unzip -o "/tmp/intellij-plugin-$name.zip" -d "$pluginPath"
	fi
done
