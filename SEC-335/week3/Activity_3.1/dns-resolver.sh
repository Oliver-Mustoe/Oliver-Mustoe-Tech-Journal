#!/bin/bash

netprefix=$1
dns_server=$2

# Check if variables are empty
if [[ -n $netprefix ]] && [[ -n $dns_server ]]; then
	echo "DNS resolution for $netprefix"
	# For every number between 1-254
	for prefix in $(seq 1 254); do
		# nslookup for variables combined to IP, throw errors in /dev/nul
		nslookup $netprefix.$prefix $dns_server 2>/dev/null | egrep '^[[:digit:]]' # Checks if digit starts line 
	done # end of prefix loop

	echo "
DONE"
else
	echo "NEED 2 INPUTS, CURRENT INPUTS ARE: $1 and $2!"
fi # end of non-zero check
