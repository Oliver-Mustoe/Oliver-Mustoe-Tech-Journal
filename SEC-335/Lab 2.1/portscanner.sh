#!/bin/bash
# Author: Oliver Mustoe
# Improvements:
# 1. Changed output to look more about listing ports open per host
# 2. Check for having two paramaters entered
# 3. Make .csv file if wanted


# Check if 2 parameters are inputted
if [[ -n $1 && -n $2 ]]; then

# Read input for whether to make .csv or not
read -p "Would you like to export this as a .csv?[y/N] " FileOrNo
# Make that input uppercase
FileOrNoUP=${FileOrNo^^}

# If .csv yes, echo certain results to console and screen
if [[ $FileOrNoUP ==  "Y" ]] || [[ $FileOrNoUP == "YES" ]]; then
	echo "Saving result to 'portscanresult.csv'"
	echo "host,port" >> portscanresult.csv
fi

# Assign input into variables
hostfile=$1
portfile=$2

for host in $(cat $hostfile); do
	# Create array for open ports
	PortsOpen=()
	echo "HOST: $host"

	for port in $(cat $portfile); do
		timeout .1 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null && # && is important here to keep errors away from data
		# Append open port to port array
		PortsOpen+="$port," && # Here too

		# if .csv yes, echo host and port in csv format to file
		if [[ $FileOrNoUP ==  "Y" ]] || [[ $FileOrNoUP == "YES" ]]; then
			echo "$host,$port" >> portscanresult.csv

		fi

	done # End of portfile loop
	# Echo open ports, use sed to substitute last "," for open space
	echo "OPEN PORTS: $PortsOpen" | sed 's/,$//'	
done # End of hostfile loop


else
	echo "Need 2 inputs; current inputs are $1 and $2"
fi # End of if for parameters

# Sources Used:
# https://stackoverflow.com/questions/14840953/how-to-remove-a-character-at-the-end-of-each-line-in-unix
# https://opensource.com/article/18/5/you-dont-know-bash-intro-bash-arrays
# https://linuxhint.com/bash_append_array/
# https://linuxhint.com/bash_lowercase_uppercase_strings/
