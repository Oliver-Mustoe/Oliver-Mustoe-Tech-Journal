#!/usr/bin/bash
# Oliver Mustoe
# Parse the threatintell file and extract IPs

# Check to see if file is downloaded, if it is than continue
if [[ ! -f "access.log" ]];
then
	wget https://nowire.champlain.edu/sys320-file/access.log
fi

# Parse the IP address's of access.log (EX. 1.2.33.122)
toDrop=$(egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" access.log | sort -u)

# Create a variable with a save name for the IPs
saveFile='access-log.rules'

# If the file already exists remove it
if [[ -f "${saveFile}" ]]; then

        rm -f ${saveFile}

fi

# Flush the IPTables ruleset
iptables -F

# Create a for loop to parse the IPs into iptables format.
for eachIP in ${toDrop}; do

	echo "iptables -A INPUT -s ${eachIP} -j DROP" >> ${saveFile}
	echo "iptables -A OUTPUT -d ${eachIP} -j DROP" >> ${saveFile}

done

# Load the rules
bash ${saveFile}
