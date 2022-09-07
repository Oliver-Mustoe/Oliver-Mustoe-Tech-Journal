#!/bin/bash
# Fping script to sweep 10.0.5.2-10.0.5.50
# Would recommend using one liner

# Ping range with "-g" flag and use "-a" flag to only show alive hosts, 2>/dev/null routes ICMP errors to null since they are not needed 
fping -ga 10.0.5.2 10.0.5.50 2>/dev/null >> sweep.txt
