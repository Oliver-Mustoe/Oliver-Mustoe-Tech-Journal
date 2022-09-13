#!/bin/bash

netprefix=$1
dns_server=$2

if [[ -n $netprefix ]] && [[ -n $dns_server ]]; then
	echo "DNS resolution for $netprefix"
	for prefix in $(seq 1 254); do
		nslookup $netprefix.$prefix $dns_server 2>/dev/null | egrep '^[[:digit:]]' 
	done # end of prefix loop

	echo "
	Done"
else
	echo "NEED 2 INPUTS, CURRENT INPUTS ARE: $1 and $2!"
fi # end of non-zero check
