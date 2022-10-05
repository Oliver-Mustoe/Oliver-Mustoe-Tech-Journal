#!/bin/bash
# Name: Oliver Mustoe
# Assignment: Extract information from /etc/passwd and format it
# Example entry: ddunston:x:1006:1007::/home/vpn1:/bin/bash

# Extracts the information using the delimiter ":" and groups the information into columns
awk -F: ' BEGIN { format = "%-18s %-10s %-10s %-25s %s\n"
       printf format,  "Username", "User ID", "Group ID", "Home Directory", "Default shell"
       printf format,  "-------", "-------", "--------", "--------------", "-------------"   }
    { printf format,  $1, $3, $4, $6, $7 }' /etc/passwd
