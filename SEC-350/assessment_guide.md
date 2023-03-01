This file contains the all of the information needed to complete the SEC-350 assessment.

| Hostname (oldname)     | IPs                                                                                                             | Network Adapters                                                                                                |
| ---------------------- | --------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| traveler-oliver (rw01) | 10.0.17.25/24                                                                                                   | ![image](https://user-images.githubusercontent.com/71083461/222024872-ef01b2f4-a931-43c6-9e32-275238ae53fa.png) |
| edge01-oliver (fw1)    | ![image](https://user-images.githubusercontent.com/71083461/222025222-9aacebef-09ed-4b33-8793-8f5a9afb4a9f.png) | ![image](https://user-images.githubusercontent.com/71083461/222025037-83e7a6c9-e231-4a74-82c1-31df9b8fd230.png) |
| nginx-oliver (web01)   | 172.16.50.3/29                                                                                                  | ![image](https://user-images.githubusercontent.com/71083461/222025365-e698ac34-7b06-4825-9782-7d3327b482af.png) |
| dhcp-oliver (new)      | **DONT KNOW, CLARIFY**                                                                                          | On LAN                                                                                                          |

# Visualization





# Order of operations

1. For each new box, set network adapters CORRECTLY > take a snapshot

2. On edg01, assign address on LAN interface > open SSH to mgmt01 > upload firewall config **(either the latest one or the one before firewall, decide this SOON)**, don't save

3. While fw01 is being setup, go onto traveler > setup networking (IP/gateway/dns) > curl the powershell file **(MAKE THAT)** (raw version), unblock the file, run it in an administrative console, should make a named administrative user/set hostname/install ssh/make ssh keys for the named administrative user. 

4. After, go onto nginx and dhcp > setup temporary ips (same as the are assigned above)/gateways (can skip if doing manual)

5. Either
   
   1. Automatic: Run ansible script which should do everything in manual automatically
   
   2. Manual (also see below for in-depth)
      
      1. SSH into the boxes (from firewall should have internet access now to copy and paste)
      
      2. Setup proper networking in netplan, re-ssh
      
      3. Copy commands to create named sudo user
      
      4. Copy commands to set hostname
      
      5. On nginx-oliver-Install nginx and setup a basic webpage
      
      6. On dhcp-oliver-Setup DHCP (copy config from Github **DO THIS**)
      
      7. On mgmt01-Use sftp to download keys from named admin on traveler, then scp them to jump.
      
      8. On jump-Append the SSH keys to ~/.ssh/authorized_keys (since manual, do as olivermustoe-jump to make sure perms are good)
      
      9. On nginx and DHCP-Install Wazuh agents



NOTE ABOUT CRD: Will break before firewall is up, MAKE SURE TO LOGOUT OF THE BOX COMPLETELY THE DAY BEFORE AS CRD BREAKS THE USER IF IT ISNT SIGNED OUT! See prep notes for more detail.

# Automatic way



# Manual way

## dhcp-oliver setup instructions

assumption is interface is ens160-change if not the case

### Set temp IPs

```bash
# For DHCP (FIND THIS IP ADDRESS)
sudo ip a add 172.16.150.20/24 dev ens160 # Interface name may need to be changed!
sudo ip route add default via 172.16.150.2
sudo ip link set dev ens160 up
ip route show
```

### Netplan setup

Inside `/etc/neplan/00-installer-config.yaml`

```
# This is the network config written by 'subiquity'
network:
  ethernets:
    ens160:
      addresses:
        - 172.16.150.20/24
      nameservers:
        addresses:
        - 172.16.150.2
      routes:
        - to: default
          via: 172.16.150.2
  version: 2
```

Then issue a `sudo reboot now`

### Set hostnames

```bash
# For DHCP
sudo hostnamectl set-hostname dhcp-oliver
```

### Install DHCP on dhcp-oliver

```bash
sudo apt update -y
sudo apt install isc-dhcp-server -y
sudo vim /etc/default/isc-dhcp-server
# CONFIGURE THE 'INTERFACESv4=””' LINE TO POINT TO INTERFACE (TEMP IP)
# Like 'INTERFACESv4="ens160"'
```

### DHCP config

Copy and paste into `/etc/dhcp/dhcpd.conf`

```
option domain-name-servers 172.16.150.2;
default-lease-time 3600; 
max-lease-time 7200;
authoritative;

subnet 172.16.150.0 netmask 255.255.255.0 {
        option routers                  172.16.150.2;
        option subnet-mask              255.255.255.0;
        option domain-name-servers      172.16.150.2;
        range   172.16.150.100   172.16.150.150;
}
```

Then start the service with `sudo systemctl start isc-dhcp-server`

# Prepping notes

- Probably should uninstall SSH from wk1 in testing to see if script can install it!

- Either CRD is signed into the user, or you sign in on vCenter. If either is still signed in (which CRD DOESNT DO AUTOMATICALLY), the following can be done.
  
  - Chrome Remote Desktop breaks the user if the user hasn't signed out before ending the session, to fix sign out of the user OR if there is no networking just restart the box

- For testing addressing on jump, set netplan to the following and apply
  
  - ![image](https://user-images.githubusercontent.com/71083461/222031696-83e3cd82-55ad-4f00-a37d-c2b0e88ba38d.png)


