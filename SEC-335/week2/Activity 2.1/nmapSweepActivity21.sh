#!/bin/bash
# Script to conduct a ping sweep with nmap
# Recommended to use as one liner

# Uses nmap with -n (no DNS resolution) and -sn (no port scan after discover) of the range 10.0.5.2-50, then pipe that into awk where I look for a certain line, and select the last field (awk deliminates by whitespace by default, 0 is whole field)
sudo nmap -n -sn 10.0.5.2-50 | awk '/Nmap scan report for/ {print $5}' >> sweep.txt

