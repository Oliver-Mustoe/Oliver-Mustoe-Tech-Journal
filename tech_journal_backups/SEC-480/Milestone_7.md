This page journals content related to NET/SEC/SYS-480 milestone 7.

**Table of contents**

* [7.1 Create a Rocky 9.1 Base VM](#71-create-a-rocky-91-base-VM)

* [7.2 - Static Route and DHCP via Ansible](#72---static-route-and-dhcp-via-ansible)
  
  * [Reflection for Milestone 7.1 and 7.2](#reflection-for-milestone-71-and-72)

* [7.3 - Rocky 1-3 Post Provisioning](#73---rocky-1-3-post-provisioning)

* [7.4  Post Provisioning Ubuntu 1-2 with Ansible](#74postprovisioning-ubuntu-1-2-with-ansible)
  
  * [Reflection for Milestone 7.3 and 7.4](#reflection-for-milestone-73-and-74)

* [Sources for all](#sources-for-all)

## VM Inventory

- [ubuntu-1](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-480/VM-Inventory/ubuntu-1-2.md#ubuntu-1)

- [ubuntu-2](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-480/VM-Inventory/ubuntu-1-2.md#ubuntu-2)

- [rocky-1](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-480/VM-Inventory/rocky-1-3.md#rocky-1)

- [rocky-2](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-480/VM-Inventory/rocky-1-3.md#rocky-2)

- [rocky-3](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-480/VM-Inventory/rocky-1-3.md#rocky-3)

# 7.1 Create a Rocky 9.1 Base VM

Used the same process to download the Rocky 9.1 VM as I did in [Milestone 1](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Milestone-Bare-Metal-1---ESXi-Setup#isos-and-networking):

![image001](https://user-images.githubusercontent.com/71083461/222982237-6fc2209b-6711-4c1f-8827-d1c5612f4216.png)

Then I created the following VM in the BASEVM folder with the following settings:  

![image003](https://user-images.githubusercontent.com/71083461/222982238-9a945241-1337-4626-98fa-5f1cf94b5a83.png)  

![image005](https://user-images.githubusercontent.com/71083461/222982239-7d967d46-806d-4d0c-8386-fd4b34dedbc9.png)  

![image007](https://user-images.githubusercontent.com/71083461/222982240-c4620ffb-8d9b-4205-84d0-1340206742a7.png)  

![image009](https://user-images.githubusercontent.com/71083461/222982241-4abb32bd-63df-4be3-8e5c-ffbcd1b50a28.png)  

![image011](https://user-images.githubusercontent.com/71083461/222982242-feb23b1a-f4b0-4054-b113-6ea15efe5fc9.png)  

I then booted ‘server.rocky.9-1.base’, and began the installation with the selection in the terminal:

![image013](https://user-images.githubusercontent.com/71083461/222982243-31e47cf5-ef45-452b-9140-4085c7e7fd26.png)

Then once it began, I would keep the language english. After selecting that I was met with this screen:

![image015](https://user-images.githubusercontent.com/71083461/222982245-60564270-e1aa-4afd-8cad-155b2544a2f8.png)

In ‘Installation Destination’ I would go in, select the VMware Virtual disk, and press Done:

![image017](https://user-images.githubusercontent.com/71083461/222982247-f06b9163-ff5f-4e1b-ab70-c454f180caeb.png)

In ‘User Creation’, I would create a deployer user (**MAKE USER ADMINISTRATOR**):

![image019](https://user-images.githubusercontent.com/71083461/222982248-9fa895a9-3c3a-4874-bbee-8e9d81cfd923.png)

With these two settings finished, began the installation:

![image021](https://user-images.githubusercontent.com/71083461/222982249-adf63770-029b-4e4c-8e0d-26395fc10db5.png)  

![image023](https://user-images.githubusercontent.com/71083461/222982250-38982e2e-d6f1-47cc-b31a-b21ffe5c89e1.png)  

Completed installation:

![image025](https://user-images.githubusercontent.com/71083461/222982251-29c5f203-2a58-493a-86af-e24b8c55ba7e.png)

Once the installation was finished, I shutdown the system (using vCenter Actions > Power > Power Off) and removed the datastore iso (Actions > Edit settings):

![image027](https://user-images.githubusercontent.com/71083461/222982252-a3613d82-4332-4e3d-8b6b-9ed23ba72a36.png)

I then powered on the machine, logged in, and saw that I received a DHCP address from WAN:

![image029](https://user-images.githubusercontent.com/71083461/222982253-f73468a0-14c2-444e-8dbe-a40d736158df.png)

I then ran the following commands to sysprep the VM (turns off VM):

```bash
curl -O https://raw.githubusercontent.com/gmcyber/RangeControl/main/src/scripts/base-vms/rhel-sealer.sh
sudo bash rhel-sealer.sh
```

With the VM turned off, I created a snapshot called Base:

![image031](https://user-images.githubusercontent.com/71083461/222982254-e57b58e0-162e-4051-9992-ada6d4e304c3.png)

# 7.2 - Static Route and DHCP via Ansible

First I ran the following commands on my 480-fw to set the needed static route/correct some descriptions from previous labs:

```
configure
# Correct descriptions from prev labs
set interfaces ethernet eth0 description CYBERLAB
set interfaces ethernet eth1 description 480-WAN
# Set static route to blue-lan
set protocols static route 10.0.5.0/24 next-hop 10.0.17.200
commit
save
```

Result of above commands:  

![image033](https://user-images.githubusercontent.com/71083461/222982255-b4a37b7d-9365-4f1a-9a2c-d721a9b1555c.png)  

Then I created fw-blue1-vars.yaml ansible inventory:

![image035](https://user-images.githubusercontent.com/71083461/222982257-f5e24bb1-faea-40a9-b58e-d8f97c5beb90.png)

And this Ansible vyos-blue.yml playbook:

![image037](https://user-images.githubusercontent.com/71083461/222982258-0a8b51ca-301a-41be-8c77-983e1095569a.png)

Run shown below with command:

```
ansible-playbook -i inventories/fw-blue1-vars.yaml --ask-pass vyos-blue.yml
```

![image039](https://user-images.githubusercontent.com/71083461/222982259-c4ea49a4-6f7c-4f95-a445-ff45c54d8ab0.png)

I then created rocky1-3 with the commands below (using the deploy-clone function to switch adapters and power on VMs):

```powershell
Deploy-Clone -LinkedClone -VMName server.rocky.9-1.base -CloneVMName rocky-1 -defaultJSON ./480.json
Deploy-Clone -LinkedClone -VMName server.rocky.9-1.base -CloneVMName rocky-2 -defaultJSON ./480.json
Deploy-Clone -LinkedClone -VMName server.rocky.9-1.base -CloneVMName rocky-3 -defaultJSON ./480.json
```

Created VMs after being moved into a created folder “BLUE1” shown below (Right clicked 480-Devops > New Folder > New VM and Template Folder > named “BLUE1”):

![image041](https://user-images.githubusercontent.com/71083461/222982260-780b166c-4697-4df9-8dd5-e588c4bf3131.png)

I also updated my Get-VMIP function to accommodate multiple VMs (such as ‘rocky-*’)

![image043](https://user-images.githubusercontent.com/71083461/222982261-a910437f-db85-4314-b8f2-7dd010badbc4.png)

Output of

```powershell
Get-VMIP -VMName rocky-* -defaultJSON ./480.json
```

![image045](https://user-images.githubusercontent.com/71083461/222982262-aab01791-c157-44f5-b242-b1d5ca1fc0fd.png)

## Reflection for Milestone 7.1 and 7.2

Since 7.1 didn’t have much new information to reflect on, I decided to combine it with 7.2. I found milestone 7.1 easy as I could look back at old documentation about how to make VMs in vCenter and I have installed Rocky on VMware workstation before/worked with it in other classes. 7.2 had a few surprises in it, particularly the formatting of the inventory. I have always used a text file for my inventories before, never a yaml file. I definitely see the benefits of a yaml file (overall looks more organized) and I am interested in what other formats Ansible supports for inventories and what their pros and cons are. I also updated in 7.2 my Get-VMIP function to accommodate the use of *, which was actually a pretty easy implementation. I plan to implement this in other functions that could benefit from it.

# 7.3 - Rocky 1-3 Post Provisioning

First I updated my Powercycle function to support using a *. Then I used that new functionality to turn off all of the rocky boxes:

![image047](https://user-images.githubusercontent.com/71083461/222982264-98b90914-c2a5-4192-98a6-c3601722df69.png)

Then for each rocky machine I made a snapshot “BEFORE ANSIBLE”:

![image049](https://user-images.githubusercontent.com/71083461/222982265-9d458f74-4943-42d1-8b32-57f7a56457ff.png)

I then used my Powercycle function to turn them all on.

I then generated a passphraseless RSA key:

![image051](https://user-images.githubusercontent.com/71083461/222982266-49ab3dc5-7b8f-4326-a09a-8a36131a1189.png)

I then made the following linux.yaml playbook (using the RSA public key made above, small change made to instructors as “{{ ansible_default_ipv4.interface }}” will grab the interface dynamically so if the interface isn’t “ens192” the script won’t error out!):

![image053](https://user-images.githubusercontent.com/71083461/222982267-b97ede44-3e76-4a96-931e-4ab6e2cabcab.png)

And I made the following playbook for rocky post provisioning:

![image055](https://user-images.githubusercontent.com/71083461/222982269-b11025eb-47f2-48ae-9d72-ecfbf60cd611.png)  

![image057](https://user-images.githubusercontent.com/71083461/222982270-d36c1e05-c01b-4241-bdfb-3ad5e7b543c3.png)  

Below is a run of the rocky-playbook.yml (-K needed for sudo password):

```bash
ansible-playbook -i inventories/linux.yaml --ask-pass rocky-playbook.yml -K
```

![image059](https://user-images.githubusercontent.com/71083461/222982271-f4503d96-2c90-4fb4-b859-ca6df8629b97.png)

![image061](https://user-images.githubusercontent.com/71083461/222982272-3a3f7a7f-f993-4203-b041-be900849f5a7.png)

New output of

```powershell
Get-VMIP -VMName rocky-* -defaultJSON ./480.json
```

![image063](https://user-images.githubusercontent.com/71083461/222982273-561070b6-e4d4-4b20-ad13-1081ea3a2f66.png)

Showing that I can SSH into one of the new rocky boxes:

![image065](https://user-images.githubusercontent.com/71083461/222982274-d5f68c16-73fb-41ab-ad72-c0ad166a3409.png)

# 7.4  Post Provisioning Ubuntu 1-2 with Ansible

First I created 2 new ubuntu VMs from my base image (also switched the network adapter and turned them on):

```powershell
Deploy-Clone -LinkedClone -VMName ubuntu.22.04.1.base -CloneVMName ubuntu-1 -defaultJSON ./480.json
Deploy-Clone -LinkedClone -VMName ubuntu.22.04.1.base -CloneVMName ubuntu-2 -defaultJSON ./480.json
```

Result after being setup and moved into the right folder:

![image067](https://user-images.githubusercontent.com/71083461/222982275-ab382167-499f-4fcb-bda0-b55cfde0d94c.png)

Then I ran the following commands to get the IPs:

```powershell
Get-VMIP -VMName ubuntu-* -defaultJSON ./480.json
```

![image069](https://user-images.githubusercontent.com/71083461/222982276-a44a7a6b-d147-4012-9b3a-bce56d2626db.png)

With this set, I would repeat the same process of creating snapshots for the ubuntu boxes while they are powered off, afterwards turning them on with `PowerCycle -vm ubuntu-* -on`.

Then I updated my linux.yaml for ubuntu:

![image071](https://user-images.githubusercontent.com/71083461/222982277-b0d38fa0-ea12-4be6-9415-591f0e72d034.png)

Templated a netplan.yaml:

![image073](https://user-images.githubusercontent.com/71083461/222982278-7612326e-2920-4273-9727-5ba8d9dc73c3.png)

Then created ubuntu-playbook.yml (on right side is last 4 lines of the file):

![image075](https://user-images.githubusercontent.com/71083461/222982279-d902c240-b978-4243-bd2a-6ec90d20b3dd.png)

Below is a run of the playbook with command:

```bash
ansible-playbook -i inventories/linux.yaml --ask-pass ubuntu-playbook.yml -K
```

![image077](https://user-images.githubusercontent.com/71083461/222982280-85718e84-700c-4360-83ff-bb0272dc1769.png)

And the new result of:

```powershell
Get-VMIP -VMName ubuntu-* -defaultJSON ./480.json
```

![image079](https://user-images.githubusercontent.com/71083461/222982281-469b86a5-962d-4b9e-a8f8-bda505c6632c.png)

And a SSH session:

![image081](https://user-images.githubusercontent.com/71083461/222982282-f6e68675-7f61-41f7-b165-ea1dd4f0186e.png)

## Reflection for Milestone 7.3 and 7.4

Since these two milestones were so closely aligned, I decided to combine their reflections. 7.3 was an interesting exploration of post provisioning. A lot of the steps, such as the drop in file, I have done before manually but never through Ansible. I did have to change the device variable as my Rocky devices were named differently. I decided to use an Ansible set variable for this as it will dynamically acquire the interface. For 7.4 I was able to pull from another class SEC-350, as I have been using Ansible to automate an upcoming assessment. I templated netplan for the assessment, so with minor variable naming changes I could easily import it to this class. I was originally going to apply the netplan in Ansible, but since we are using a DHCP address I instead used the shutdown command that is used in Rocky. Milestone 7 was overall a good Ansible learning experience, especially when it comes to the inventory, that I am excited to see how it is expanded upon in future milestones!

# Sources for all:

[How to Install Rocky Linux on VMware | phoenixNAP KB](https://phoenixnap.com/kb/rocky-linux-vmware)



---

Can't find something? Check in the [Backup Milestone 7 journal](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-480/Milestone_7.md)
