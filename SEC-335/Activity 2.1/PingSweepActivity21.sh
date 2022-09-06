#!/bin/bash
# Script to ping range of 10.0.5.2-10.0.5.50
echo "up ip addresses" >> ./sweep.txt

# For each item in the sequence
for ip in $(seq 2 50) 
do
	# Ping ips, grep if response contains "From"
	IsUp=$(ping -c 1 -i .02 10.0.5.$ip | grep "Destination Host Unreachable")
	# If the variable is empty (indicates no from, so successful ping)
	if [[ -z $IsUp ]]
	then
		echo "10.0.5.$ip" >> ./sweep.txt
	fi
done

