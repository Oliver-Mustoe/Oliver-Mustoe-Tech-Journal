#!/bin/bash
# Script to parse input form, expected run `./FirewallExporter.sh 192.168.1.1 192.168.1.2`

# Iterate over every input inputted ($@)
for ip in $@; do
    ssh vyos@$ip 'vbash -s' << EOF
    source /opt/vyatta/etc/functions/script-template
    run show configuration commands | grep -v "syslog global\|ntp\|login\|console\|config\|hw-id\|loopback\|conntrack"
    exit
EOF
done