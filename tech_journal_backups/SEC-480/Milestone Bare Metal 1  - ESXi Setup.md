This page journals content related to NET/SEC/SYS-480 milestone 1.

## VM Inventory

- [xubuntu-wan](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-480/VM-Inventory/xubuntu-wan.md)
- [480-fw](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-480/VM-Inventory/480-fw.md)

# ESXi Installation

DNS **192.168.4.4 .5**

My ESXi hostname = **super15**  
ESXI IP = **192.168.7.25**

From my IPMI IP, I logged in with the user "cncs-sysadmin" (with a password I was emailed). After logging in, I went to the "Remote Control" section to access iKVM (this is shown below.)
![image](https://user-images.githubusercontent.com/71083461/213762684-99fb485b-bcdb-4921-a7c9-eae1aa247a62.png)

Then I used accessed iKVM, and used the Power control setting “Set power reset” to reboot the machine. Then I waited for the 2nd supermicro screen and used the virtual keyboard to press f11, from there I selected the UEFI selection of "General Udsik 5".

Once selected, I would use the “Samsung SSD” storage device to install ESXI: 
![image](https://user-images.githubusercontent.com/71083461/213762941-6ccfce92-fa24-4211-9ba5-2437030697da.png)

I would then go along with the installer, making sure that I set a root password that I saved. Afterwards, I confirmed the install and the installation progress went along:
![image](https://user-images.githubusercontent.com/71083461/213763029-66306a6b-26a4-46fc-8e59-c62148575249.png)

Once the process is finished, I would then press enter and wait for it to restart.

Once it rebooted, I used F2 to login, and used my root password at the login screen. Then using F2 again and was met with this screen:
![image](https://user-images.githubusercontent.com/71083461/213763088-e7502a7b-4cd0-4f68-bffb-c58eb1042f72.png)

Then I went from “Configure Management Network” > “Network Adapters” and changed the selection to "vmnic1" (once I had access to a cable). Following shows this:

![image](https://user-images.githubusercontent.com/71083461/213763228-f85ff5f8-e66a-4058-adc3-be748361c3bb.png)

Inside the management network, I would use the following menus to setup the apprioprate network configurations for my host:

**IPv4 Configuration:**  

![image](https://user-images.githubusercontent.com/71083461/213763117-99667052-2bc9-40c7-85ab-c8ae499ba547.png)

**DNS Configuration:**![image](https://user-images.githubusercontent.com/71083461/213763175-a754b5b9-6dcc-4692-a011-4975137421cc.png)

**Custom DNS Suffixes:**![image](https://user-images.githubusercontent.com/71083461/213763203-878bac14-2bee-4f83-a919-6c3211577e5a.png)

With these options set, I would then use the Esc key to exit, making sure to apply and restart the management network at the popup.

With this set, I went to my IP address "192.168.7.25" and I was met with the following, in which I could login with my root account/password set earlier:
![image](https://user-images.githubusercontent.com/71083461/213763282-2c82a291-6152-4044-9538-c6399082f2e7.png)
![image](https://user-images.githubusercontent.com/71083461/213763291-9c8bcb6a-f890-4f5d-8e04-abf9b11c7d3f.png)

**Reflection:**
The setup of ESXi was a very cool and
enlightening experience for me. Having not worked with this technology before,
I was expecting a harder installation process. The process was fairly self-explanatory,
and besides having to wait for certain cables, took very little time. I also
appreciated my colleagues during this time, as the more experienced ones took
time to make sure that everyone was on the same page. There was also a good
amount of time spent organizing everyone getting their production IP addresses
working on time as well. This part of Milestone 1 was overall a good introduction to
the basic ESXi installation.

# ISOS and Networking

Devin-jump IP:port = 192.168.3.120:8000

After logging into my ESXi host, I then went into the storage menu of my dashboard, right-clicked "datastore1", and selected to "Rename" the datastore to “datastore1-super15”:
![image](https://user-images.githubusercontent.com/71083461/213767184-d1d9a9a3-c49e-4b4c-947c-51191519ae91.png)
![image](https://user-images.githubusercontent.com/71083461/213767233-c63007cd-a708-4c27-8115-00cef933e41b.png)

Then, in the same menu, I created a new datastore, using the “New datastore” option, with the name “datastore2-super15”. All of the rest of the configuration I left default (automatically selects correct creation type, the other storage device, etc.) and just pressed “NEXT” and then pressed “FINISH”.

![image](https://user-images.githubusercontent.com/71083461/213767328-445c2901-0924-4c04-a382-5c6652612461.png)

The end screen of the creation of datastore2:
![image](https://user-images.githubusercontent.com/71083461/213767427-2c143a0a-f6f1-43bb-9ead-0df13725b750.png)

A warning screen will popup about erasing the entire contents, I pressed “YES” on this.

I then double clicked the newly created datastore2 from the storage menu, which opened the datastore in a a dropdown that allowed me to select datastore2 > click “Datastore browser” where I used the "Create directory" option to create a directory called “isos”:
![image](https://user-images.githubusercontent.com/71083461/213767535-df80b9dc-5adb-447e-9368-1875dda83540.png)

I could also access the datastore browser by right clicking “Storage” in the sidebar > selecting “Browse datastores”.

I then enabled SSH by going to the “Host” menu > selecting “ACTIONS” > then selecting “Services” > then selecting “Enable Secure Shell (SSH)”:
![image](https://user-images.githubusercontent.com/71083461/213767617-08be7bc6-4485-45a1-880e-7646d49117fc.png)

**NOTE:** I would make sure to DISABLE SSH while not in use!

Similarly, to the datastore browser, I could have accessed the “Services” section by right clicking the “Host” tab on the sidebar.

Before SSHing, I double checked connectivity with my ESXi host with a ping:
![image](https://user-images.githubusercontent.com/71083461/213767749-8a8891c7-b790-4413-b7e0-59ee33f86201.png)

With this being successful, I SSH’d into my ESXi host:

```bash
ssh root@super15.cyber.local
```

![image](https://user-images.githubusercontent.com/71083461/213772344-4374d5ec-5c1b-42ee-b4a8-d35c31230c9e.png)

And I moved into the created “isos” directory located in datastore2 on the host:

![image](https://user-images.githubusercontent.com/71083461/213771815-c28a58bd-5547-44d5-999c-a8eb52f28312.png)

**NOTE:** datastores are accessed from “vmfs/volumes”, where a link will be made between the pretty name, EXP. “datastore1-super15”, and the actual name:

![image](https://user-images.githubusercontent.com/71083461/213768042-a2020900-6c7d-4332-8788-fe835d83e52a.png)

I then visited “http://192.168.3.120:8000/”, and acquired the link for the iso for “vyos-1.4” by right clicking the link > selecting “Copy link address”:
![image](https://user-images.githubusercontent.com/71083461/213768148-c768f0c9-0981-45e2-bb62-33996db3cfd5.png)

I would then used the following command to download my iso!:

```bash
wget http://192.168.3.120:8000/vyos-1.4-rolling-202301111512-amd64.iso
```

![image](https://user-images.githubusercontent.com/71083461/213772462-6557b921-c7d8-4f58-8561-20e0a8b6e29a.png)

I  would then redo this process to acquire the “xubuntu” iso (Copy link from website >  same wget command from above with a different link:
![image](https://user-images.githubusercontent.com/71083461/213768374-7fba4dd2-b008-4772-9818-89a65b01bbe2.png)

With this completed, I went back into my ESXi Host client, selected the “Networking” menu from the sidebar > selected “Virtual switches” where I setup the following virtual switch “480-WAN” and pressed “ADD”:
![image](https://user-images.githubusercontent.com/71083461/213768469-7d361e88-1ae7-4113-aa42-26a7d9b90cec.png)
NOTE: Removed the Uplink

Then I added the following port group to my “480-WAN” virtual switch by, in the “Networking” menu, going to the “Port groups” section, selecting "Add port group" and setting the options below for a group called “480-WAN”. After I would click “ADD”:
![image](https://user-images.githubusercontent.com/71083461/213768601-525aed86-533c-49b4-a55d-c3bfe6a57826.png)

With this completed, I was able to select the created WAN from the “Virtual switches” category in networking and see the following:
![image](https://user-images.githubusercontent.com/71083461/213768655-57553fc4-6d3d-4ce8-b90c-b053d06b37a0.png)

Reflection:
Having never worked with ESXi before this, learning about basic datastores and the beginning of networking was very interesting. A major note I have about this step is that a lot of the actions I made can be accomplished by right clicking on the sidebar and selecting one of the options. As I move through the course, I will make sure to explore this as it might be faster than going into the menu/category. The introduction to networking I worked on during this step was also very enlightening, even though I don't fully understand the virtual switches/port groups yet. I will later research to resolve the ambiguity for myself!

# 480-fw

From inside the “Virtual Machines” menu, I selected the “Create / Register VM” option > then I selected the default creation type, and gave the VM the name “480-fw” and set the following options. Clicked “NEXT”:
![image](https://user-images.githubusercontent.com/71083461/213783986-3f50750a-c30f-444d-96b1-cd95c35b5b95.png)

NOTE ABOUT COMPATIBILITY: Even though the ESXi host I am working on is ESXi 8, it is recommended to set the compatibility to the lowest common denominator among a group of ESXi hosts (like if you have a mix of 6,7 and 8s, you would choose 6) to not have hardware compatibility issues.

Then I selected datastore2 as the storage for the VM. Clicked “NEXT”:
![image](https://user-images.githubusercontent.com/71083461/213784055-c9721035-b5c0-437f-8fdd-44c8e3aeee12.png)

I then set the following customized settings with the following notes:

- Second network adapter was added with the “Add network adapter” option

- Memory and Hard disk tweaked

- In the Hard disk drop down menu, made sure to select “Thin provisioned” in “Disk Provisioning”
  
  - Thin provisioning only takes the storage that it needs, and grows according to demand up to the specified amount. Thick provisioning takes all of the storage at once.

- Made sure to set the 2 network adapters to “VM Network”
  
  - Did this since I was building a base VM, so I wanted the VM to be generic.

- When selecting the “Datastore ISO file” option in CD/DVD Drive, a pop-up appeared in the “Datastore browser” where I navigated on datastore2 to the vyos-1.4 VM.
  
  - I also could have navigated to this via using the CD/DVD Drives drop-down in the “CD/DVD Media” selection, selecting “BROWSE…”

- Clicked “NEXT”

![image](https://user-images.githubusercontent.com/71083461/213784116-a5b8f085-f15f-4a69-a9a6-fbbf22d9fa09.png) ![image](https://user-images.githubusercontent.com/71083461/213784129-d6acb667-8594-4d16-ab47-f312387a201b.png)



After reviewing the following matched the desired setup, clicked “FINISH”: ![image](https://user-images.githubusercontent.com/71083461/213784149-a26d0394-dd6f-4b8b-ba9c-6b02f27bf270.png)



Then, from within the virtual machines menu, I selected and started the new virtual machine:
![image](https://user-images.githubusercontent.com/71083461/213784183-48d6c0e2-657c-4ee2-98ca-b1e6ae50fdbb.png)



Then from the “Console” dropdown, I opened a console in a new tab, and logged into VyOS with the default user “vyos” with the password “vyos”. Once logged in, I started the VyOS install with the command:

```
Install image
```

![image](https://user-images.githubusercontent.com/71083461/213784211-dae52b64-92fd-4b9c-9d26-6148c85c9fc1.png)



NOTE FOR VYOS INSTALL: By choosing default options, I mean the ones automatically selected when a user presses the Enter key at prompts (the answer within the brackets.)

Along the install process, the only non-default option I would choose is the option that asks about destroying all data on /dev/sda, to which I would enter “yes”. Besides this, I answered with the Enter key:
![image](https://user-images.githubusercontent.com/71083461/213784233-e8f02b76-885e-4ce7-91d8-ff79aabfa32c.png)



When prompted, I would then change the password for the vyos user.

I would answer with the Enter key for default options for the rest of the prompts.

Once this is complete I would use the ```reboot``` command to restart the VM.

Once the VM had rebooted, I used the following commands to remove the MAC addresses (good for cloning):

```
configure
delete interfaces ethernet eth0 hw-id
delete interfaces ethernet eth1 hw-id
commit
save
```

Result of above on the interfaces using the ```show interfaces``` command:
![image](https://user-images.githubusercontent.com/71083461/213784270-c91b5d97-cedb-4c0e-98cd-af7c9e3730f8.png)



I then set eth0 to dhcp, and enabled ssh on the VM with the following commands (if already in configure mode from previous commands, skip initial “configure” command):

```
configure
set interfaces ethernet eth0 address dhcp
set service ssh listen-address 0.0.0.0
commit
save
```

Result of above using the `show` command:
![image](https://user-images.githubusercontent.com/71083461/213784325-f9c932c1-ef93-4577-85ff-7b3ada3c833c.png)



Then I used the commands `exit` and `poweroff` to shutoff the VM.

Then, from the ESXi dashboard, I right clicked the VM in the sidebar, clicked “Edit settings”, and changed the CD/DVD to “Host device”. After saved:
![image](https://user-images.githubusercontent.com/71083461/213784356-af8e228a-cdf8-416f-beba-7eb3fa9872f6.png)

Again I right clicked the VM in the sidebar, hovered over “Snapshots” > Selected “Take snapshot” > named it “Base”:
![image](https://user-images.githubusercontent.com/71083461/213784386-13d43e31-2342-47f2-88f7-9ae192a9aa66.png)

After creating the snapshot (inside the the snapshot section mentioned before, should now be options to restore/manage snapshots) I changed the second adapter on the VM to “480-WAN” (right clicked the VM in the sidebar, clicked “Edit settings”):
![image](https://user-images.githubusercontent.com/71083461/213784421-8aa1b64e-c0a3-4692-b076-ea9347ff6e28.png)

Then I restarted the VM after saving.

Once I have logged back into the firewall, I checked for an address:
![image](https://user-images.githubusercontent.com/71083461/213784443-55bcba8d-cd22-4990-96ff-10bacc8563e9.png)

I would then SSH into the VM using the DHCP address above:
![image](https://user-images.githubusercontent.com/71083461/213784467-1530c893-ef3e-4620-ad48-9444057250c6.png)

Then I changed the password with the following:

```
configure
set system login user vyos authentication plaintext-password {SECURE_PASS}
commit
save
```

Then I ran the following to setup the IP addresses on both interfaces with descriptions/setup gateway and dns for the system/ setup DNS and NAT forwarding:

```
# Interface setup for eth0
delete interfaces ethernet eth0 address dhcp
set interfaces ethernet eth0 address 192.168.7.55/24
set interfaces ethernet eth0 description CYBERLAB
# Interface setup for eth1
set interfaces ethernet eth1 address 10.0.17.2/24
set interfaces ethernet eth0 description 480-WAN
# Gateway and DNS setup
set protocols static route 0.0.0.0/0 next-hop 192.168.7.250
set system name-server 192.168.4.4
set system name-server 192.168.4.5
# DNS forwarding setup
set service dns forwarding listen-address 10.0.17.2
set service dns forwarding allow-from 10.0.17.0/24
set service dns forwarding system
# NAT forwarding setup
set nat source rule 10 outbound-interface eth0
set nat source rule 10 source address 10.0.17.0/24
set nat source rule 10 translation address masquerade
# Setting system hostname
set system host-name 480-fw
commit
```

After the commit, my SSH session closed. So I resumed using the web console from earlier where I checked my interfaces were set, then I used `configure` and `save` to save the config:
![image](https://user-images.githubusercontent.com/71083461/213784535-bd71d887-5de8-47cd-a646-8c776b74d6ca.png)

**Reflection:**
Having used VMs on Vcenter, it was nice to see what the backend setupof it looks like. By doing so, I feel I have a deeper understanding and appreciation for the VMs that I use at Champlain everyday. I have in previous courses worked with the idea of VMware cloning, so setting VyOS to be a base image very much made sense to me. My experience in VyOS in other classes was also very handy in this setup of the firewall. Getting experience with ESXi so far has been a very fun and rewarding experience!

# xubuntu and proof

From my ESXi host client, I right clicked the “Virtual Machines” sidebar and selected “Create/Register VM”:
![image](https://user-images.githubusercontent.com/71083461/213786502-57df33e5-9436-496c-9f67-212968574ef2.png)

With this I would use the default creation type, set the name to “xubuntu-wan” and configured compatibility and guest OS settings as follows:
![image](https://user-images.githubusercontent.com/71083461/213786523-87ed875b-691b-418c-adbf-d5d170b07f5b.png)

I would select to place it onto datastore2:
![image](https://user-images.githubusercontent.com/71083461/213786545-73a788d3-406b-480a-af9f-2d2c04f5ecce.png)

Then I set the virtual machine settings as follows with the following points:

- Use thin provisioning

- Make sure to select the VM in CD/DVD (can use the dropdown and “BROWSE..” in the CD/DVD media section as well)

![image](https://user-images.githubusercontent.com/71083461/213786566-de2b14a9-268e-437d-9c2e-482e3f0f8d5c.png)
![image](https://user-images.githubusercontent.com/71083461/213786575-e671a6a9-8c18-4c04-8866-03b58d70e348.png)

I then finished, then I accessed the console for xubuntu, and followed this setup:

1. Selected to install xubuntu  
   ![image](https://user-images.githubusercontent.com/71083461/213786691-b9791466-8bbf-4cd7-acab-bad84230ec0a.png)  
2. Used the default keyboard layout
3. Kept the default settings and pressed “Continue” in “Update and other software”
4. In “Installation type, chose to “Erase disk and install Xubuntu” (default), pressed “Install Now”  
   ![image](https://user-images.githubusercontent.com/71083461/213786734-04b7384d-87eb-4fc8-b67a-31845d9d3349.png)    
5. When asked about disk changes, just continued on
6. Selected “New York” timezone
7. Setup the following user  
   ![image](https://user-images.githubusercontent.com/71083461/213786750-4b24f844-6399-45c4-a5de-2968629cd973.png)  
8. Once installation was complete, I chose to restart  
   ![image](https://user-images.githubusercontent.com/71083461/213786768-f390dbf8-d8ab-4478-9223-39ae06e4d25b.png)  
   NOTE: I did have to manually turn the VM off and on from the dashboard since the Logo to Xubuntu came up like it SHOULD have loaded, but after leaving it for 5 minutes and checking the performance graph on the VMs menu, I power cycled it. This solved the issue.

With all of this set, I was met with a login screen and was able to login and use the Desktop:
![image](https://user-images.githubusercontent.com/71083461/213786846-fe80d51b-f469-4e5b-b1ad-b65a7f9a8782.png)

Then I ran the instructors provided [script](https://raw.githubusercontent.com/gmcyber/RangeControl/main/src/scripts/base-vms/ubuntu-desktop.sh) to prepare ubuntu desktop for linked cloning:

```bash
sudo -i
wget https://raw.githubusercontent.com/gmcyber/RangeControl/main/src/scripts/base-vms/ubuntu-desktop.sh
chmod +x ubuntu-desktop.sh
./ubuntu-desktop.sh
```

![image](https://user-images.githubusercontent.com/71083461/213786912-950add84-b230-443f-9f77-73d5448ccfbf.png)

I then cleaned up with `rm` and shutdown the VM:  
![image](https://user-images.githubusercontent.com/71083461/213786936-cf45749f-b627-48c7-bbfc-b53318181434.png)

I would then go back to the VMs menu, select “Edit” and change the CD/DVD drive to “Host device”:
![image](https://user-images.githubusercontent.com/71083461/213786974-cb1f6239-0a65-45dc-8b96-92972eb712e4.png)

And then I would select “Actions” from the VMs menu and take a Base snapshot like the following:
![image](https://user-images.githubusercontent.com/71083461/213786996-f4cacc3c-f4b0-4751-8bca-274693b5b805.png)
NOTE: Seemingly anywhere on the VMs menu I can right click and get the same menu as “Actions”

Afterwards I would go back to the VMs menu, select “Edit”, and set the network adapter to “480-WAN”
![image](https://user-images.githubusercontent.com/71083461/213787032-203fdbdb-81c3-482f-99aa-960cac6e7e9b.png)

I then powered on the system and ran the following commands as root to add a sudo user/add that user to the sudo group:

```bash
adduser olivermustoe
usermod -aG sudo olivermustoe
```

Then I powercycled the VM, logged in as “olivermustoe” and removed the champuser user:

```bash
sudo userdel -r champuser
```

End result:
![image](https://user-images.githubusercontent.com/71083461/213787079-8ce94884-20bf-4001-b98c-44119851002f.png)

NOTE: Ran `userdel` command once before a power cycle, but it said the "champuser" account was used by a process, so I powercycled the machine again and was able to effectively remove the user with the same command.

I then (from the network connections > wired connection 1) added the following static IP address:
![image](https://user-images.githubusercontent.com/71083461/213787109-360572e2-8102-469d-841f-d67310151b7d.png)
NOTE: Make sure that Method is set to “Manual” or else even if you have an address listed, xubuntu will still try for a DHCP address.

I would also set my hostname to “xubuntu-wan” with the following command:

```bash
sudo hostnamectl set-hostname xubuntu-wan
```

**Reflection:**

Having only setup 2 VMs, I can say that the process of manually setting up VMs can be a fun, but time-consuming process on ESXi. The install of xubuntu was very smooth, except for when I tried to restart the VM, it froze on startup. This may have been due to the installation media still being install?!? But after checking that the VM was not consuming resources for a good amount of time, I decided to power cycle it and it worked flawlessly from there! The instructore provided script was also very interesting to me, as I wonder if there are guides that exist to prep VMs for this, or it is just general Linux knowledge. As I go through the course, I might develop a resource for this if it becomes a bigger part of the course. With the base setup done, I can't wait to see any more additions we make to it/how we start automating the process in future weeks!

#### Milestone 1 proof:

![image](https://user-images.githubusercontent.com/71083461/213787148-605dd07a-01bd-4082-a548-8919f00077f4.png)

# Sources for all:

- https://www.techtarget.com/searchvmware/definition/VMware-vSphere
