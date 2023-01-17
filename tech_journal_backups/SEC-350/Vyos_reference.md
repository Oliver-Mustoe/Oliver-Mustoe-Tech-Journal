# Vyos reference
This page contains configurations/tips on working with the VyOS. Periodically, journaling notes that contain setup involving VyOS will also be linked on this page.

**Table of contents**
1. [Vyos configs](#vyos-configs)
2. [Commands](#commands)

## Vyos configs:
Current VyOS config -- [1-16-23](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-350/Vyos_configs/1-16-23.md)

Old VyOS configs:
- None

Configuration acquired with running the following on a VyOS system:
```
show configuration commands | grep -v "syslog\|ntp\|login\|console\|config\|hw-id\|loopback\|conntrack"
```


**BEFORE DOING ANYTHING** -- Ensure that the correct network adapters are set.

### Note about basic command structure:
Basic command structure in VyOS begins with enter config mode, ``configure``, the doing the commands. To commit the configuration to the system, use `commit`, then to save so that the configuratoin will stay on reboot, use `save`.


## Commands
Below are commands to setup certain functions of VyOS. Anything that contains a "{}" should be replaced with what is being prescribed inside.

### Change password (for vyos user)
```
configure
set system login user vyos authentication plaintext-password {INSERT_PASS_HERE}
commit 
save
```

### Setup hostname:
```
configure  
set system host-name fw01-oliver  
commit  
save  
exit
```

### Setup descriptions/addresses of interfaces
```
configure
set interfaces ethernet eth{NUMBER} description {ENTER_DESCRIPTION_HERE}
set interfaces ethernet eth{NUMBER} address {ENTER_ADDRESS_HERE}
commit
save
```
**^ NOTE FOR ABOVE:** This example is change 1 interfaces description/address. Add more `set interfaces` lines for multiple interfaces

### Setup Gateway and DNS on VyOS
```
configure  
set protocols static route 0.0.0.0/0 next-hop {GATEWAY_FIREWALL_IP}
set system name-server {DNS_IP}
commit  
save
```

### Setup NAT forwarding:
```
configure
set nat source rule 10 description "{DESCRIPTION}"
set nat source rule 10 outbound-interface eth{NUMBER_OF_WAN_INTERFACE}
set nat source rule 10 source address {ADDRESS_RANGE_IN_CIDR}
set nat source rule 10 translation address masquerade
commit
save
```

### Setup DNS forwarding:
```
configure  
set service dns forwarding listening-address {DMZ_GATEWAY_IP} 
set service dns forwarding allow-from {ADDRESS_RANGE_IN_CIDR}  
set service dns forwarding system  
commit  
save
```
