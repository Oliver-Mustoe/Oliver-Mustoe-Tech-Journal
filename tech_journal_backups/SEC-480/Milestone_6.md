This page journals content related to NET/SEC/SYS-480 milestone 6.

**Table of contents**

1. [Milestone 6.1 - Network Utility Functions](#milestone-6.1-network-utility-functions)
   
   1. [6.1 reflection](#6.1-reflection)

2. [Milestone 6.2 - Cloning, Networking and Starting fw-blue1](#milestone-6.2-cloning-networking-and-starting-fw-blue1)
   
   1. [6.2 reflection](#6.2-reflection)

3. [Milestone 6.3 - Ansible Ping](#milestone-6.3-ansible-ping)

4. [Milestone 6.4 - vyos configuration](#milestone-6.4-vyos-configuration)
   
   1. [Troubleshooting 6.4](#troubleshooting-6.4)
   
   2. [6.3 and 6.4 reflection](#6.3-and-6.4-reflection)

5. [Sources for all](#sources-for-all)

# Milestone 6.1 - Network Utility Functions

First I created the functions `Get-VMIP` to get networking information about the VMs first adapter, `New-Network` to create a new virtual switch/portgroup, and `StandardError` where I placed the standard error formatting that I use in my try catch statements.

With these functions I could get the networking information I needed (command run and output below):

![image001](https://user-images.githubusercontent.com/71083461/221052622-54a91ede-fbe1-48e8-a008-7dda90698e02.png)

And I could make a new Virtual network (command run and output below):

![image003](https://user-images.githubusercontent.com/71083461/221052625-50f351e1-0b24-45a5-9c5d-1c4cb6256445.png)

![image005](https://user-images.githubusercontent.com/71083461/221052627-23ddb0ac-8b59-42d3-b12e-b66d4a7c9fcf.png)

## 6.1 reflection

This part of the milestone was a nice brush up on Powershell, after not using it for a few days, and a cool chance to add extra utility to 480-utils. I originally was pulling the hostname VMWare detected for my get-ip function, but I relooked at the documentation and realized that I was actually just supposed to get the vm name (which I was entering anyway, so I could just pull that.) The creation of the virtual switch/portgroup was much simpler than I thought it was going to be, which is appreciated (thanks VMWare.)

# Milestone 6.2 - Cloning, Networking and Starting fw-blue1

I then updated/refined my previous functions to switch network adapters/power on a VM and deployed “fw-blue1” like the following:

```
Deploy-Clone -LinkedClone -VMName server.vyos.base -CloneVMName fw-blue1 -defaultJSON ./480.json
```

![image007](https://user-images.githubusercontent.com/71083461/221052629-6f41542b-31a7-4ed3-a952-a90f6f7fac5f.png)

![image009](https://user-images.githubusercontent.com/71083461/221052630-0c11ede4-3e3d-4a2e-9e2d-e1c5b4df6b59.png)

![image011](https://user-images.githubusercontent.com/71083461/221052631-69740167-64b3-4cf0-8196-998b8481bb5a.png)

![image013](https://user-images.githubusercontent.com/71083461/221052632-f9159bcf-1370-43f1-a9e4-36455bd32071.png)

Strangely, when I tried to login the password I had on file was wrong (also double checked and COULD SSH into 480-fw with the password and it works, and I checked the history of 480-fw and didn’t see any changes to the password.)

Because of this I created a new full linked clone from 480-fw:

```
Deploy-Clone -FullClone -VMName 480-fw -CloneVMName test-vyos -defaultJSON ./480.json
```

Powered on test-vyos and selected the option for the login reset:

![image015](https://user-images.githubusercontent.com/71083461/221052634-fedda245-294d-4f5f-bfa6-6260a06d08dc.png)

Selected ‘y’ to reset the login to the password on file:

![image017](https://user-images.githubusercontent.com/71083461/221052637-7859e40c-5208-40f0-8f9d-e4b263a97104.png)

I then logged in with the reset password and ran the following to prep the VM (from https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Milestone-Bare-Metal-1---ESXi-Setup#480-fw):

```
configure

delete interfaces ethernet eth0 hw-id

delete interfaces ethernet eth1 hw-id

set interfaces ethernet eth0 address dhcp

set service ssh listen-address 0.0.0.0

commit

save
```

I would then power down the VM > Take a snapshot called Base2 > Deploy a new vyos base with (deleted the other base and fw-blue1):

```
Deploy-Clone -FullClone -VMName test-vyos -CloneVMName server.vyos.base -defaultJSON ./480.json
```

![image019](https://user-images.githubusercontent.com/71083461/221052638-e00500f7-a4ee-4dd5-bace-9e68fc26bbd3.png)

I then deployed fw-blue1 like the previous deployment and was able to login:

![image021](https://user-images.githubusercontent.com/71083461/221052639-059df3a6-536f-476e-86c4-7a0e7b5b337a.png)

![image023](https://user-images.githubusercontent.com/71083461/221052640-d5af40b6-e68e-4b49-a60d-4b356f46ff4f.png)

![image025](https://user-images.githubusercontent.com/71083461/221052643-d13b0d40-456c-4051-a491-d6f21707a441.png)

And I was able to login successfully:

![image027](https://user-images.githubusercontent.com/71083461/221052646-dd5f333e-4afc-4405-ae9f-ba13b9859d4b.png)

## 6.2 reflection

This part of the milestone was way more convoluted than it needed to be on my end. I still don't know what happened in making the base image from 480-fw that the password wasn’t set, I even tried the default vyos:vyos user/pass combination but that didn’t work. This did give me the opportunity to see how powerful/useful 480-utils is. I could quickly make a new full clone, run what I needed to, and perfectly redeploy fw-blue1 in a very faster amount of time compared to by hand. Either way, I can access both my firewalls and am prepped for Ansible!

# Milestone 6.3 - Ansible Ping

I used the following command to setup my ansible.cfg:

```
cat >> ~/.ansible.cfg << EOF                                                              

[defaults]

host_key_checking = false

EOF
```

![image029](https://user-images.githubusercontent.com/71083461/221052648-6cb27c31-f960-4466-bfc2-da205c1912e9.png)

Then I filled in a inventory file like the following:

```
[vyos]

10.0.17.102 hostname=fw-blue1 mac=00:50:56:81:3f:b2 wan_ip=10.0.17.200 lan_ip=10.0.5.2 network=10.0.5.0/24 nameserver=10.0.17.4 gateway=10.0.17.2

[vyos:vars]

ansible_python_interpreter=/usr/bin/python3
```

And could ping the host:

```
ansible vyos -m ping -i ansible/inventories/fw-blue1-vars.txt --user vyos --ask-pass
```

![image031](https://user-images.githubusercontent.com/71083461/221052649-7eb09c94-1b38-4595-b07f-151638f481fe.png)

# Milestone 6.4 - vyos configuration

First I created a snapshot of fw-blue1 by going to fw-blue1 in vCenter > shutting it down > Snapshots > TAKE SNAPSHOT… > Named it “BEFORE ANSIBLE”:

![image033](https://user-images.githubusercontent.com/71083461/221052650-a43d5069-91ba-4ce7-a28f-40aadb283353.png)

Then I powered it on and ran the following commands while SSH’d into fw-blue1/the last command on the system itself:

```
configure

# Interface setup for eth0

delete interfaces ethernet eth0 address dhcp

set interfaces ethernet eth0 address 10.0.17.200/24

# Interface setup for eth1

set interfaces ethernet eth1 address 10.0.5.2/24

# Gateway and DNS setup

set protocols static route 0.0.0.0/0 next-hop 10.0.17.2

set system name-server 10.0.17.4

# DNS forwarding setup

set service dns forwarding listen-address 10.0.5.2

set service dns forwarding allow-from 10.0.5.0/24

set service dns forwarding system

# NAT forwarding setup

set nat source rule 10 outbound-interface eth0

set nat source rule 10 source address 10.0.5.0/24

set nat source rule 10 translation address masquerade

# Setting system hostname

set system host-name fw-blue1

commit

save
```

I did this so that the /config/config.boot file would contain the needed file structure for jinja templating.

After running the commands, I saved the output of:

```
cat /config/config.boot
```

on fw-blue1 to a file in my Github repository under SEC-480/ansible/files/vyos/config.boot.js:

![image035](https://user-images.githubusercontent.com/71083461/221052652-7243a65d-0cc2-4790-995e-7fa9a258a339.png)

I then updated my vars file like the following:

![image037](https://user-images.githubusercontent.com/71083461/221052653-4803a994-1fae-4dc0-a2e0-2010dfd070bc.png)

Then, taking from my fw-blue1-vars.txt file, for each variable set in the vars file I would replace the value in the config.boot.j2 file with the key in jinjia format (`{{ }}`). For example in the case of the variable key pair `gateway=10.0.17.2` , I would replace all instances of `10.0.17.2` with `{{ gateway }}`. I would also make sure that none of the replaces would impact another replace, so in the case of 10.0.17.2 I added a space at the end of the find to ensure I only interacted with just that IP!

![image039](https://user-images.githubusercontent.com/71083461/221052656-766d0cbf-e4d1-4abe-8e02-ad4a7c86fc23.png)

For 10.0.17.2, I would have to add back in the space:

![image041](https://user-images.githubusercontent.com/71083461/221052657-25672289-ae37-40f8-b258-bb7861cd8804.png)

I would also remove the lines in the interfaces section dealing with hw-id’s:

![image043](https://user-images.githubusercontent.com/71083461/221052658-2b742a44-4630-40d1-a217-faec0ace481a.png)

I also had to edit the password lines to look like the following (removing plaint-text password):

![image045](https://user-images.githubusercontent.com/71083461/221052659-f99dbfc7-fafd-4082-9cd0-8f32d475aac6.png)

I then made the following Ansible file to configure fw-blue1:

![image047](https://user-images.githubusercontent.com/71083461/221052661-e66094ca-d5dd-490d-9afa-87f6c350de10.png)

Below is a running of the Ansible script (right, and the output of Get-VMIP (on the left):

![image049](https://user-images.githubusercontent.com/71083461/221052663-65377366-a1e6-4aa0-afda-4c13b75777c9.png)

![image051](https://user-images.githubusercontent.com/71083461/221052665-78947c27-38de-40ef-967e-6b769f753d2a.png)

## Troubleshooting 6.4:

First I set the encrypted password to line in the config to `{{ password_hash }}`:

![image053](https://user-images.githubusercontent.com/71083461/221052666-faa423db-270d-453d-aec0-00d1cc78c704.png)

With this set and saved, I then made my Ansible script like the following:

![image055](https://user-images.githubusercontent.com/71083461/221052667-652211c6-4dcf-46aa-99aa-f1ddbd246b00.png)

Then I reset fw-blue1 back to the snapshot and turned it on, once it was on I ran the above script like the following (left shows the ip changing, right shows the ansible playbook run!):

![image057](https://user-images.githubusercontent.com/71083461/221052668-827e1f65-1544-410d-8317-b78d3a98e6c5.png)

But this resulted in the password not changing, but everything else was implemented correctly. To troubleshoot, I took the initial configuration I made and fw-blue1’s config after using Ansible. I didn’t see anything different. I then compared the fw-blue1’s config after using Ansible to 480-fw and found that the plaintext-password line was removed. Once I removed this line from config.boot.j2, the password worked!

## 6.3 and 6.4 reflection

I decided to combine the last 2 sub-milestones of milestones 6 together as 6.3 didn’t have much substance to reflect on. Having had some experience with Ansible, I had never before set up the inventory with the variables set. I have previously used group_vars to set variables, but I have never done it in the inventory file before. While later ansible scripts will require the use of an ansible-vault for secrets, it was interesting to see the ability to give variables to hosts in that way. In 6.4, I have used jinja templating a bit in Python and in Ansible scripts, but I have not used it solely for templating. It is very interesting to me and I want to see other applications for it. When making my config, I did have a bit of confusion when it came to setting the password, as it seemingly refused to change. I believe this to be the doing of the plaintext-password line, and I think I could have saved myself a lot of hassle by resetting fw-blue1 when I set its config manually THEN taking its configuration as a base. Overall, a fun milestone and I can’t wait for more Ansible!

# Sources for all:

- [ansible.builtin.set_fact module – Set host variable(s) and fact(s). — Ansible Documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/set_fact_module.html)

- [Using filters to manipulate data — Ansible Documentation](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_filters.html)
