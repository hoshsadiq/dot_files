buildFile=""
if [[ "$OSTYPE" == "darwin"* ]]; then
	getStringFromInfoPlist() {
		key="$1"
		path="$2"
		/usr/bin/grep "$key" -A1 "$path" | /usr/bin/grep -o '<string>.*</string>' | /usr/bin/tr -d '\n' | /usr/bin/sed -E 's#(<string>|</string>)##g'
	}

	intellijInstallPath="$(getStringFromInfoPlist JetBrainsToolboxApp "$HOME/Applications/JetBrains Toolbox/IntelliJ IDEA Ultimate.app/Contents/Info.plist")"
	prefix="$(getStringFromInfoPlist 'idea.paths.selector' "$intellijInstallPath/Contents/Info.plist")"

	pluginPath="$HOME/Library/Application Support/$prefix"
	buildFile="$intellijInstallPath/Contents/Resources/build.txt"
else
	pluginPath="$HOME/.$(grep '\-Didea.paths.selector' /snap/intellij-idea-ultimate/current/bin/idea.sh | awk '{print $1}' | awk -F'=' '{print $2}')/config/plugins"
	buildFile="/snap/intellij-idea-ultimate/current/build.txt"
fi

if [ -z "$buildFile" ]; then
	echo "Could not find build file"
	exit 1
fi

buildNumber="$(sed -E 's/IU-([0-9]+(\.[0-9]+)?)(\.([0-9]+))?/\1\4/' "$buildFile")"

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
