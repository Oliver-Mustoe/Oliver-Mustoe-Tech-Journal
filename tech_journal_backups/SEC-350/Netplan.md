# Netplan

This page contains configurations/tips on working with the Netplan.

**Table of contents**

1. [Basic Netplan config](#basic-netplan-config)
2. [Sources](#sources)

## Basic Netplan Config

A basic Netplan config located at `/etc/netplan/00-installer-config.yaml` would look something like this:

```yaml
network:
  ethernets:
    # For the listed interface...
    ens160:
      # List all addresses for the host... 
      addresses:
        - 172.16.200.10/28
      # List all of the nameservers...
      nameservers:
        addresses: [172.16.200.2]
      # List default gateway
      routes:
        - to: default
          via: 172.16.200.2
  version: 2
```

Generalized version:

```yaml
network:
  ethernets:
    {INTERFACE_NAME}:
      addresses:
        - {SYSTEM_IP}/{SUBNET_MASK}
      nameservers:
        addresses: [{NAMESERVER_IP}]
      routes:
        - to: default
          via: {DEFAULT_GATEWAY}
  version: 2
```

Other not listed sections:

* Under nameservers, a line `search: [mydomain, otherdomain]` can be added to search certain domains (in the listed case mydomain and otherdomain)

* Under the interface name, the line `dhcp4: true` can be used to enable DHCP

# Sources:

* [Canonical Netplan](https://netplan.io/examples)
