# Vyos reference

This page contains configurations/tips on working with the VyOS.

**Table of contents**

1. [Vyos configs](#vyos-configs)
2. [Commands](#commands)

## Vyos configs:

Current VyOS config -- [1-25-32](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-350/Vyos_configs/1-25-23.md)

Old VyOS configs:

- [1-16-23](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-350/Vyos_configs/1-16-23.md)

Configuration acquired with running the following on a VyOS system:

```
show configuration commands | grep -v "syslog\|ntp\|login\|console\|config\|hw-id\|loopback\|conntrack"
```

**BEFORE DOING ANYTHING** -- Ensure that the correct network adapters are set.

### Note about basic command structure:

Basic command structure in VyOS begins with enter config mode, ``configure``, then doing the commands. To commit the configuration to the system, use `commit`, then to save so that the configuratoin will stay on reboot, use `save`.

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

### Forward authentication messages to rsyslog

```
configure
set system syslog host {LOGGING_SERVER_IP} facility authpriv level info
commit
save
```

  **^ NOTE FOR ABOVE:** `{LOGGING_SERVER_IP}` is the IP of the server you wish to forward syslog messages too. For more information about setting up a syslog logging server, see [here](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Syslog-reference)

## Sources

- https://docs.vyos.io/en/latest/configuration/service/dns.html