#!/bin/bash
# Author: Oliver Mustoe


# Check if 2 parameters are inputted
if [[ -n $1 ]] && [[ -n $2 ]]; then

# Read input for whether to make .csv or not
read -p "Would you like to export this as a .csv?[y/N] " FileOrNo
# Make that input uppercase
FileOrNoUP=${FileOrNo^^}

# If .csv yes, echo certain results to console and screen
if [[ $FileOrNoUP ==  "Y" ]] || [[ $FileOrNoUP == "YES" ]]; then
	echo "Saving result to 'Scanresult.csv'"
	echo "host,port" >> Scanresult.csv 
fi

# Assign input into variables
hostprefix=$1
port=$2

for prefix in $(seq 1 254); do
	# Assign the host variable to the host prefix with prefix
	host=$hostprefix.$prefix

	timeout .1 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null && # && is important here to keep errors away from data
	# Echo the port if above command is successful
echo "
HOST: $hostprefix.$prefix
OPEN PORT: $port" &&
	# Append to file if above command is successful	
	# if .csv yes, echo host and port in csv format to file
	if [[ $FileOrNoUP ==  "Y" ]] || [[ $FileOrNoUP == "YES" ]]; then
		echo "$host,$port" >> Scanresult.csv

	fi


done # End of prefix loop
echo "DONE"

else
	echo "Need 2 inputs; current inputs are $1 and $2"
fi # End of if for parameters

# Sources Used:
# https://stackoverflow.com/questions/14840953/how-to-remove-a-character-at-the-end-of-each-line-in-unix
# https://opensource.com/article/18/5/you-dont-know-bash-intro-bash-arrays
# https://linuxhint.com/bash_append_array/
# https://linuxhint.com/bash_lowercase_uppercase_strings/
