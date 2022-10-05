#!/usr/bin/bash
# Oliver Mustoe
# Parse the threatintell file and extract IPs

# Check to see if file is downloaded, if it is than continue
if [[ ! -f "access.log" ]];
then
	# Downloads first link and creates access.log
	wget -O access.log https://www.projecthoneypot.org/list_of_ips.php?t=d
	# Downloads other files but appends them to access.log
	wget https://www.projecthoneypot.org/list_of_ips.php?t=s -O ->> access.log
	wget https://www.projecthoneypot.org/list_of_ips.php?t=p -O ->> access.log

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

# Sources
#https://stackoverflow.com/questions/21276570/how-to-append-the-wget-downloaded-file

#https://stackoverflow.com/questions/16678487/wget-command-to-download-a-file-and-save-as-a-different-filename
