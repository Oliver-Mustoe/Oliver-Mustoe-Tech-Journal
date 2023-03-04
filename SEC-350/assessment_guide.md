This file contains the all of the information needed to complete the SEC-350 assessment.

| Hostname (oldname)     | IPs                                                                                                             | Network Adapters                                                                                                |
| ---------------------- | --------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| traveler-oliver (rw01) | 10.0.17.25/24                                                                                                   | ![image](https://user-images.githubusercontent.com/71083461/222024872-ef01b2f4-a931-43c6-9e32-275238ae53fa.png) |
| edge01-oliver (fw1)    | ![image](https://user-images.githubusercontent.com/71083461/222025222-9aacebef-09ed-4b33-8793-8f5a9afb4a9f.png) | ![image](https://user-images.githubusercontent.com/71083461/222025037-83e7a6c9-e231-4a74-82c1-31df9b8fd230.png) |
| nginx-oliver (web01)   | 172.16.50.3/29                                                                                                  | ![image](https://user-images.githubusercontent.com/71083461/222025365-e698ac34-7b06-4825-9782-7d3327b482af.png) |
| dhcp-oliver (new)      | 172.16.150.15                                                                                                   | On LAN                                                                                                          |

# Visualization

![image](https://user-images.githubusercontent.com/71083461/222250518-17fed880-5fe7-49e3-b1ed-5b061352b5cd.png)

**NOTE: IPs ARE DIFFERENT FOR MY WAN!**

# Order of operations

0 - Setup ansible like

```bash
sudo apt update
sudo apt install sshpass python3-paramiko git -y
sudo apt-add-repository ppa:ansible/ansible
sudo apt update
sudo apt install ansible -y
cat >> ~/.ansible.cfg << EOF                                                              
[defaults]
host_key_checking = false
EOF
# Also remove known_hosts
rm ~/.ssh/known_hosts
```

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
      
      5. On edge01-Open the firewall for nginx
      
      6. On nginx-oliver-Install nginx and setup a basic webpage
      
      7. On nginx-Install Wazuh agent
      
      8. Close the firewall
      
      9. On dhcp-oliver-Setup DHCP (copy config from Github **DO THIS**)
      
      10. On mgmt01-Use sftp to download keys from named admin on traveler, then scp them to jump.
      
      11. On jump-Append the SSH keys to ~/.ssh/authorized_keys (since manual, do as olivermustoe-jump to make sure perms are good)
      
      12. On DHCP-Install Wazuh agents

NOTE ABOUT CRD: Will break before firewall is up, logout of the user BEFORE the assessment, or just reboot mgmt01.

# Automatic way

**Set adapters like you see at the top of the page, THEN SNAPSHOT**

## *Firewall setup*

Initial setup

```
configure
set interfaces ethernet eth2 address '172.16.150.2/24'
set service ssh listen-address '172.16.150.2'
commit
```

Then ssh into it with `ssh vyos@172.16.150.2`, then run the commands within "fw01-edg01--config.txt (should be on mgmt01's desktop labeled "fw01-edg01--config.txt"). After checking that can ping google, run `save`.

## *traveler setup*

Set the network settings from computer icon right click >  Open Network & Internet settings > Change adapter options > Ethernet0 right click > properties (bottom) > Internet Protocol Version 4 double click:

![image](https://user-images.githubusercontent.com/71083461/222263382-7838cfab-069e-4c2b-9a0a-bbb42c275ea5.png)

Run the following commands **(ADMINISTRATIVE POWERSHELL)** can find on `www.github.com/Oliver-Mustoe/publix`:

```powershell
wget https://github.com/Oliver-Mustoe/publix/blob/main/scripts-to-be-pblic/assess-setup.ps1?raw=true -Outfile assess-setup.ps1
Unblock-File .\assess-setup.ps1
Set-ExecutionPolicy -scope process unrestricted
.\assess-setup.ps1
```

## *nginx-oliver automatic setup instructions*

assumption is interface is ens160 - change in commands if not the case

### Set temp IPs

```bash
# For nginx
sudo ip a add 172.16.50.3/29 dev ens160 # Interface name may need to be changed!
sudo ip route add default via 172.16.50.2
sudo ip link set dev ens160 up
ip route show
# WONT BE ABLE TO PING GOOGLE, TRY PINGING GATEWAY AND SEE IF SSH WORKS```bash
# Can flush IP settings with `ip addr flush eth0`
```

### nginx-oliver automatic Ansible

On mgmt01, run the following in the SEC-350 folder > 'scripts' folder in the home directory of 'olivermustoe'

```bash
ansible-playbook -i ../inventories/assess.txt web01.yml --ask-vault-pass
```

## *dhcp-oliver automatic setup instructions*

assumption is interface is ens160 - change in commands if not the case

### Set temp IPs

```bash
# For DHCP (FIND THIS IP ADDRESS)
sudo ip a add 172.16.150.15/24 dev ens160 # Interface name may need to be changed!
sudo ip route add default via 172.16.150.2
sudo ip link set dev ens160 up
ip route show
# Ping 8.8.8.8
# Can flush IP settings with `ip addr flush eth0`
```

### dhcp-oliver automatic Ansible

On mgmt01, run the following in the SEC-350 folder > scripts folder in the home directory of 'olivermustoe'

```bash
ansible-playbook -i ../inventories/assess.txt dhcp.yml --ask-vault-pass
```

While it is running, go over to WKS01 and set adaper to get a IP through DHCP.

## *Key Setup*

On mgmt01, run the following the following in the SEC-350 folder > scripts folder in the home directory of 'olivermustoe' as 'olivermustoe':

```bash
ssh-add ~/.ssh/id_rsa
bash keys.sh
```

---

# Manual way

### *Firewall setup*

Initial setup

```
configure
set interfaces ethernet eth2 address '172.16.150.2/24'
set service ssh listen-address '172.16.150.10'
commit
```

Then ssh into it with `ssh vyos@172.16.150.2`, then run the commands within "fw01-edg01--config.txt (should be on mgmt01's desktop labeled "fw01-edg01--config.txt"). After checking that can ping google, run `save`.

## *nginx-oliver manual setup instructions*

assumption is interface is ens160-change if not the case

### Open DMZ firewall

In the firewall (edge01)

```
configure
set firewall name DMZ-to-WAN rule 999 action accept
set firewall name DMZ-to-WAN rule 999 source address 172.16.50.3
commit
```

Close it (do later, here to help remember :) )

```
configure
delete firewall name DMZ-to-WAN rule 999
commit
```

### Set temp IPs

```bash
# For nginx
sudo ip a add 172.16.50.3/29 dev ens160 # Interface name may need to be changed!
sudo ip route add default via 172.16.50.2
sudo ip link set dev ens160 up
ip route show
# WONT BE ABLE TO PING GOOGLE, TRY PINGING GATEWAY AND SEE IF SSH WORKS
```

### Netplan setup

Inside `/etc/neplan/00-installer-config.yaml`

```
# This is the network config written by 'subiquity'
network:
  ethernets:
    ens160:
      addresses:
        - 172.16.50.3/29
      nameservers:
        addresses:
        - 172.16.50.2
      routes:
        - to: default
          via: 172.16.50.2
  version: 2
```

Then issue a `sudo reboot now`

### Set hostnames

```bash
# For DHCP
sudo hostnamectl set-hostname nginx-oliver
```

### Create user

```bash
sudo adduser olivermustoe
sudo usermod -aG olivermustoe
sudo passwd olivermustoe
```

### Install nginx and set a banner

```bash
sudo apt update
sudo apt install nginx
sudo echo ‘nginx01-oliver’ > /var/www/html/index.html
```

### Install and setup Wazuh

```bash
curl -so wazuh-agent-4.3.10.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.3.10-1_amd64.deb && sudo WAZUH_MANAGER='172.16.200.10' WAZUH_AGENT_GROUP='linux' dpkg -i ./wazuh-agent-4.3.10.deb
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
```

### CLOSE THE FIREWALL

```
configure
delete firewall name DMZ-to-WAN rule 999
commit
```

Double check that nginx can't ping google, also check webpage is working!

### Install and setup Wazuh

```bash
curl -so wazuh-agent-4.3.10.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.3.10-1_amd64.deb && sudo WAZUH_MANAGER='172.16.200.10' WAZUH_AGENT_GROUP='linux' dpkg -i ./wazuh-agent-4.3.10.deb
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
```

## *dhcp-oliver manual setup instructions*

assumption is interface is ens160-change if not the case

### Set temp IPs

```bash
# For DHCP (FIND THIS IP ADDRESS)
sudo ip a add 172.16.150.15/24 dev ens160 # Interface name may need to be changed!
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
        - 172.16.150.15/24
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

### Create user

```bash
sudo adduser olivermustoe
sudo usermod -aG olivermustoe
sudo passwd olivermustoe
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

### Install and setup Wazuh

```bash
curl -so wazuh-agent-4.3.10.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.3.10-1_amd64.deb && sudo WAZUH_MANAGER='172.16.200.10' WAZUH_AGENT_GROUP='linux' dpkg -i ./wazuh-agent-4.3.10.deb
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
```

## Remove Wazuh agent

From the Wazuh host, run the following in the terminal (exclude the `-r` to just access the menu as the `-r` will automatically delete the agent WITHOUT confirmation!):

```bash
sudo /var/ossec/bin/manage_agents -r {AGENT_UUID}
```

![image](https://user-images.githubusercontent.com/71083461/222210740-c0814d1e-4b48-4f6c-9054-87f8dd77d155.png)

# Prepping notes

- Probably should uninstall SSH from wk1 in testing to see if script can install it!

- Either CRD is signed into the user, or you sign in on vCenter. If either is still signed in (which CRD DOESNT DO AUTOMATICALLY), the following can be done.
  
  - Chrome Remote Desktop breaks the user if the user hasn't signed out before ending the session, to fix sign out of the user OR if there is no networking just restart the box

- For testing addressing on jump, set netplan to the following and apply
  
  - ![image](https://user-images.githubusercontent.com/71083461/222031696-83e3cd82-55ad-4f00-a37d-c2b0e88ba38d.png)

- ![image](https://user-images.githubusercontent.com/71083461/222215810-2f9f05f4-0ea8-4469-ab33-473a87c99a68.png)

- Double quotes "" makes interplotation happen with variables in both PS and Bash!

- ![image](https://user-images.githubusercontent.com/71083461/222569487-f2dadc42-358f-4584-9916-fee2729ddc9e.png)
