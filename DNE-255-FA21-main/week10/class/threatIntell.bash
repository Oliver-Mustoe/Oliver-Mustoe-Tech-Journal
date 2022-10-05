#!/usr/bin/bash
: '
# Parse the threatintell file and extract IPs
if [[ -f "emerging-drop.suricata.rules" ]];
then
	read -p  "File exists, Do you want to delete it? [y|n]" deleteOrNot

	if [[ "${deleteOrNote}" == 'y' ]];
	then

		rm -f "emerging-drop.suricata.rules"
		wget http://rules.emergingthreats.net/blockrules/emerging-drop.suricata.rules


	else
		wget http://rules.emergingthreats.net/blockrules/emerging-drop.suricata.rules
	fi

fi
'
# Parse the IP address: 1.2.33.122/24
toDrop=$(egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}" emerging-drop.suricata.rules | sort -u)

saveFile='iptables-spamhause.rules'

if [[ -f "${saveFile}" ]]; then

	rm -f ${saveFile}

fi
# Flush the IPTables ruleset
iptables -F

# Create a for loop to parse the Ips into iptables format.
for eachIP in ${toDrop}; do

	echo "iptables -A INPUT -s ${eachIP} -j DROP" >> ${saveFile}
	echo "iptables -A OUTPUT -d ${eachIP} -j DROP" >> ${saveFile}

done

# Load the rules
bash ${saveFile}
