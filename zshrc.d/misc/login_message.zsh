# processes running: ps -W | wc -l
echo -e ""

echo -ne "$fg[red]Current date       : $fg[cyan]";
echo -n $(date +"%A %_d %B %Y %H:%M");
echo -e  "$fg[white]"

echo -ne "$fg[red]Usage of /         : $fg[cyan]";
echo -n $(df -h / | awk '/\// { print $5,"of",$2 }');
echo -e  "$fg[white]"

# todo: WSL reports 0 when starting a new sessions
echo -ne "$fg[red]Up time            : $fg[cyan]";
uptime 2>/dev/null | sed 's/.*up \([^,]*\), .*/\1/';
echo -ne "$fg[white]"

echo -ne "$fg[red]Kernel Information : $fg[cyan]";
uname -smr;
echo -ne "$fg[white]"

echo -e "\n$fg[red]Memory stats       : $fg[cyan]";
free 2>/dev/null || echo "Memory information not yet available";
echo -ne "$fg[white]"
