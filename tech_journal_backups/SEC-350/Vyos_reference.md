# Vyos reference

This page contains configurations/tips on working with the VyOS.

**Table of contents**

1. [Vyos configs](#vyos-configs)
2. [Commands](#commands)
3. [Debugging](#debugging)
   1. [Firewalls](#firewalls)

## Vyos configs:

Current VyOS config (All VyOS hosts): W4 -- [2-8-23](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-350/Vyos_configs/2-8-23.md)

Old VyOS configs:

- W3 -- [1-31-23](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-350/Vyos_configs/1-31-23.md)
- W2 -- [1-25-23](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-350/Vyos_configs/1-25-23.md)
- W1 -- [1-16-23](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-350/Vyos_configs/1-16-23.md)

Configuration acquired by running the following on a VyOS system or running [my script](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/SEC-350/FirewallExporter.sh) with `./FirewallExporter.sh 172.16.150.2 172.16.150.3`:

```
show configuration commands | grep -v "syslog\|ntp\|login\|console\|config\|hw-id\|loopback\|conntrack"
```

**BEFORE DOING ANYTHING** -- Ensure that the correct network adapters are set.

### Note about basic command structure:

Basic command structure in VyOS begins with enter config mode, ``configure``, then doing the commands. To commit the configuration to the system, use `commit`, then to save so that the configuration will stay on reboot, use `save`. `set` is used as the way to set a configuration rule, while `delete` is used to delete a configuration rule. Rules are accompanied by a number, where this number is kind of like the name for the rule. Rule numbers are commonly incremented in increments of 5 or 10. In the command examples below, rules are given numbers that CAN be changed to meet the enviroment.

## Commands

Below are commands to setup certain functions of VyOS. Anything that contains a "{}" should be replaced with what is being prescribed inside.

### Change password (for vyos user)

```
configure
set system login user vyos authentication plaintext-password {SECURE_PASS}
commit 
save
```

### Setup hostname:

```
configure  
set system host-name {NAME}  
commit  
save  
exit
```

### Setup descriptions/addresses of interfaces

```
configure
set interfaces ethernet eth{NUMBER} description {DESCRIPTION}
set interfaces ethernet eth{NUMBER} address {IP_ADDRESS}/{NETMASK}
commit
save
```

**^ NOTE FOR ABOVE:** This example is to set 1 interfaces description/address. Add more `set interfaces` lines for multiple interfaces.

### Setup Gateway and DNS on VyOS

```
configure  
set protocols static route 0.0.0.0/0 next-hop {GATEWAY_FIREWALL_IP}
set system name-server {DNS_IP}
commit  
save
```

### Setup SSH

```
configure
set service ssh listen-address {IP}
commit
save
```

**^ NOTE FOR ABOVE:** The IP can be set to 0.0.0.0 to allow any IP to SSH into the router, and `delete service ssh listen-address 0.0.0.0` can be used to delete this.

### Setup NAT forwarding:

```
configure
set nat source rule 10 description "{DESCRIPTION}"
set nat source rule 10 outbound-interface eth{NUMBER}
set nat source rule 10 source address {IP_ADDRESS}/{NETMASK}
set nat source rule 10 translation address masquerade
commit
save
```

**^ EXAMPLE FOR ABOVE:** If you are setting up NAT forwarding from a DMZ to a WAN, the `eth{NUMBER}` would be the number of the WAN interface, and the `source address` would be the network address in CIDR notation of the DMZ.

### Setup DNS forwarding:

```
configure  
set service dns forwarding listen-address {GATEWAY_IP} 
set service dns forwarding allow-from {IP_ADDRESS}/{NETMASK}  
set service dns forwarding system  
commit  
save
```

**^ NOTE FOR ABOVE:** The `{GATEWAY_IP}` is "the local IPv4 or IPv6 addresses to bind the DNS forwarder to. The forwarder will listen on this address for incoming connections." - [VyOS Documentation](https://docs.vyos.io/en/latest/configuration/service/dns.html). The `{IP_ADDRESS}/{NETMASK}` is the allowed network for DNS forwarding.

### Setup Port Forwarding:

```
configure
set nat destination rule 10 destination port {DESINATION_PORT}
set nat destination rule 10 inbound-interface eth{NUMBER}
set nat destination rule 10 protocol {DESTINATION_PROTOCOL}
set nat destination rule 10 translation address {IP_TO_BE_TRANSLATED_TO}
set nat destination rule 10 translation port {PORT_TO_BE_TRANSLATED_TO}
set nat destination rule 10 description {DESCRIPTION}
commit
save
```

**^ NOTE FOR ABOVE:** The destination port is what a user is TRYING TO CONNECT TO, when they do on the inbound-interface/protocol - it will be translated to a request going to the translation address on the translation port A.K.A it translates the users request to point to a certain IP on a certain port if the request is on a certain port/interface. Could in theory also have a destination address with or without a destination port.

### Forward authentication messages to rsyslog

```
configure
set system syslog host {LOGGING_SERVER_IP} facility authpriv level info
commit
save
```

  **^ NOTE FOR ABOVE:** `{LOGGING_SERVER_IP}` is the IP of the server you wish to forward syslog messages too. For more information about setting up a syslog logging server, see [here](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Syslog-reference)

### Configure RIP:

```
Configure  
set protocols rip interface eth{NUM}
set protocols rip network {IP_ADDRESS}/{NETMASK} 
commit  
save
```

**^ NOTE FOR ABOVE:** First set command enables RIP on the interface AND sets the network configured for the interface to be advertised, second sets what additional network to advertise

### Create Firewall Zones:

```
configure  

# Create the zones - one per interface
set zone-policy zone {NAME} interface eth{NUM}

# Create the “firewalls”: One in each direction between each zone, see note
set firewall name {NAME1-TO-NAME2} default-action drop
set firewall name {NAME1-TO-NAME2} enable-default-log 

# Assign the firewalls to the zones (following above name scheme, from is first word)
set zone-policy zone {NAME2} from {NAME1} firewall name {NAME1-TO-NAME2}

# Create the rules in the firewalls, increment rule number by a factor (10 for example)
set firewall name {NAME1-TO-NAME2} rule {NUM} ...

commit  
save  
```

**^ NOTE FOR ABOVE:** Create one zone per interface, for example with a WAN, LAN, DMZ setup you would run the above command with the name, `WAN` for example, set to the interface it is supposed to go to, `eth0` for example. Number of firewalls should be zone*2 (two interfaces/zone = 2 firewalls, three interfaces/zones = 6 firewalls, etc.)

### Create Firewall Rules:

Below is a collection of helpful firewall rules, each of these should be began with `set firewall name {NAME1-TO-NAME2} rule {NUM}` (represented by the `...` dots below). Rules are setup so that if a network packet matches a rules destination/source/protocol requirements, the action set for the rule happens. See an example of the below commands in the [Firewall debugging section](#firewalls).

- Add a destination port condition to a rule
  
  - `...destination port {PORT}`

- Add a source port condition to a rule
  
  - `...source port {PORT}`

- Add a destination address condition to a rule 
  
  - `...destination address {IP}`

- Add a source address condition to a rule
  
  - `...source address {IP}`

- Set the protocol of a rule
  
  - `...protocol tcp`

- Set the action to accept traffic if the conditions of a rule are fulfilled
  
  - `...action accept`

- Add a description to a rule
  
  - `...description "PUT SOMETHING HERE!!!"`

- Set established connections to enable for a rule
  
  - `...state established enable`
    
    - Typically rule 1 will be set to the following
    
    - ```
      set firewall name {NAME1-TO-NAME2} rule 1 action accept
      set firewall name {NAME1-TO-NAME2} rule 1 state established enable
      ```

## Disable/Re-enable rule

```
configure
# Disable
set firewall name {NAME1-TO-NAME2} rule {NUM} disable
# Re-enable
set firewall name {NAME1-TO-NAME2} rule {NUM} disable
commit 
```

## Debugging

### Firewalls

Firewalls can be tricky, as it can get very confusing very quickly about what is going where to who.

When making firewalls/zones, make sure to use a coherent naming scheme and, for convience, name the firewalls ZONE-to-ZONE to make it easier to debug.

Some debugging commands below, output will differ depending if `configure` has been run or not (found it to be more helpful in config mode!):

```
# Show all of the different firewall configurations (can specify by adding `name SOMETHING` to the end of the below command!)
show firewall
# Show all of the zones
show zone
```

Below shows the commands needed to be run to setup fw-mgmt in my environment (see the [Current network architecture](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/SEC-350-Home#current-network-architecture-13023)) for an in production example:

```
configure
# Setup zones
set zone-policy zone LAN interface eth0
set zone-policy zone MGMT interface eth1
# Firewalls setup
set firewall name LAN-to-MGMT default-action drop
set firewall name MGMT-to-LAN default-action drop
set firewall name LAN-to-MGMT enable-default-log 
set firewall name MGMT-to-LAN enable-default-log
# Setup zone policy
set zone-policy zone LAN from MGMT firewall name MGMT-to-LAN
set zone-policy zone MGMT from LAN firewall name LAN-to-MGMT
# LAN-to-MGMT
set firewall name LAN-to-MGMT rule 10 destination port 1514,1515
set firewall name LAN-to-MGMT rule 10 destination address 172.16.200.10
set firewall name LAN-to-MGMT rule 10 protocol tcp
set firewall name LAN-to-MGMT rule 10 action accept
set firewall name LAN-to-MGMT rule 10 description "LAN to wazuh"
set firewall name LAN-to-MGMT rule 20 destination address 172.16.200.10
set firewall name LAN-to-MGMT rule 20 destination port 443
set firewall name LAN-to-MGMT rule 20 source address 172.16.150.10
set firewall name LAN-to-MGMT rule 20 protocol tcp
set firewall name LAN-to-MGMT rule 20 action accept
set firewall name LAN-to-MGMT rule 20 description "HTTPs mgmt01 on LAN to wazuh"
set firewall name LAN-to-MGMT rule 30 destination address 172.16.200.10
set firewall name LAN-to-MGMT rule 30 destination port 22
set firewall name LAN-to-MGMT rule 30 source address 172.16.150.10
set firewall name LAN-to-MGMT rule 30 protocol tcp
set firewall name LAN-to-MGMT rule 30 action accept
set firewall name LAN-to-MGMT rule 30 description "SSH mgmt01 on LAN to wazuh"
set firewall name LAN-to-MGMT rule 1 action accept
set firewall name LAN-to-MGMT rule 1 state established enable
# MGMT-to-LAN
set firewall name MGMT-to-LAN rule 1 action accept
set firewall name MGMT-to-LAN rule 1 state established enable
set firewall name MGMT-to-LAN rule 10 description "Allow MGMT to DMZ"
set firewall name MGMT-to-LAN rule 10 destination address 172.16.50.0/29
set firewall name MGMT-to-LAN rule 10 action accept
set firewall name MGMT-to-LAN rule 20 description "Allow MGMT to LAN"
set firewall name MGMT-to-LAN rule 20 destination address 172.16.150.0/24
set firewall name MGMT-to-LAN rule 20 action accept
commit
save
```

## Sources

- https://docs.vyos.io/en/latest/configuration/service/dns.html
- [The night of living dead protocols: RIPv2](https://blog.vyos.io/the-night-of-living-dead-protocols-ripv2)
- [NAT &mdash; VyOS 1.3.x (equuleus) documentation](https://docs.vyos.io/en/equuleus/configuration/nat/index.html)

***

Cant find something, check in the backup [Vyos reference](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-350/Vyos_reference.md)