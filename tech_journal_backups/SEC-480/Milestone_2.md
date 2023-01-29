This page journals content related to NET/SEC/SYS-480 milestone 2.

**Table of contents**

- [Google remote desktop](#google-remote-desktop)

- [Sysprep](#sysprep)

- [Domain install](#domain-install)

- [Reflection](#reflection)

- [Sources](#sources)

## VM Inventory

* [dc1](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-480/VM-Inventory/dc1.md)

## Google remote desktop

First thing I did was install a chrome remote desktop on xubuntu-wan. Seemingly during the base installation, google chrome was not installed. Because of this, I ran the following:

```bash
#chrome remote desktop
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install --assume-yes ./google-chrome-stable_current_amd64.deb
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo apt install --assume-yes ./chrome-remote-desktop_current_amd64.deb
```

![image002](https://user-images.githubusercontent.com/71083461/215291548-491b94e1-0fba-4171-b948-154239ae43ec.gif)

(Tried install as just user, did not work, worked with doing it as root. Above is after running once.)

With google chrome desktop installed, I went to the website “https://remotedesktop.google.com/access”, logged in with a gmail account, and clicked the blue circle button:

![image004](https://user-images.githubusercontent.com/71083461/215291551-64191bd9-afc3-411c-a800-47cc089742cf.gif)

Where I then clicked “Add to Chrome” then add the extension:

![image006](https://user-images.githubusercontent.com/71083461/215291553-7f4b0dfc-c4a3-4238-8936-8d2422c39b93.gif)

I was then told setup a name and a pin, after this is set I gave it a name of hostname and the class (following shows this):

![image008](https://user-images.githubusercontent.com/71083461/215291556-2998c2db-4d6a-4d40-a3a7-d25f1cadc1f5.gif)

I then logged out of the host, and from another machine, used the address “https://remotedesktop.google.com/access” to access the machine (needed to use the pin set before.)

## Sysprep

Inside google chrome, I would first navigate my ESXi host/devins jump box

![image010](https://user-images.githubusercontent.com/71083461/215291558-ca65fbf2-f24f-4c36-8a58-b265b9de0cee.gif)

![image012](https://user-images.githubusercontent.com/71083461/215291560-fa137255-3cc4-4b10-9554-eb6d3ea7f57f.gif)

Then I enabled SSH from the ESXi home dashboard:

![image014](https://user-images.githubusercontent.com/71083461/215291562-9c49f67b-e899-4c6b-b461-49799354be4a.gif)

From there, I used the same process I used in [Milestone 1](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Milestone-Bare-Metal-1---ESXi-Setup#isos-and-networking) to download the VyOS/xubuntu VMs to download the isos for “Win_Server”, “VMware-VCSA”, and “VMware-VMvisor” to datastore2 (Commands below:)

```bash
ssh root@super15.cyber.local
cd vmfs/volumes/datastore2-super15/isos/
wget http://192.168.3.120:8000/VMware-VCSA-all-8.0.0-20519528.iso
wget http://192.168.3.120:8000/VMware-VMvisor-Installer-8.0-20513097.x86_64.iso
wget http://192.168.3.120:8000/SW_DVD9_Win_Server_STD_CORE_2019_1909.4_64Bit_English_DC_STD_MLF_X22-29333.ISO
```

(Note: I installed the VMware isos before starting this milestone, but these are the commands to do so.)

![image016](https://user-images.githubusercontent.com/71083461/215291564-56860fe9-0e66-40ed-98f9-5c7589aff369.gif)

Then I created a new VM (Sidebar > Virtual Machines > Create/Register VM > Default creation type), then I named it and set the following compatibility settings:

![image018](https://user-images.githubusercontent.com/71083461/215291566-b62232df-e27f-46e1-b069-1b746fc1a2f2.gif)

Stored on datastore 2:

![image020](https://user-images.githubusercontent.com/71083461/215291568-d3b977bb-98e3-481e-9a18-6297e09ffdac.gif)

Then I set the following VM settings:

- CD/DVD setting set to the following:  

![image022](https://user-images.githubusercontent.com/71083461/215291571-b1d28c73-c1c1-4f61-82a3-385863985d6b.gif)

- THIN PROVISIONING!!!  

![image024](https://user-images.githubusercontent.com/71083461/215291573-22dc16bd-aeab-43c6-a9b9-7607f7ce84f8.gif)  

![image026](https://user-images.githubusercontent.com/71083461/215291575-fe3e46c4-9ed7-4eed-ad8d-d4f093a06914.gif)  

Overall:  

![image028](https://user-images.githubusercontent.com/71083461/215291577-0af42943-6d83-4659-8ba3-9d463388e096.gif)  

![image030](https://user-images.githubusercontent.com/71083461/215291579-21022596-03dc-49aa-93b1-7aec8c27808e.gif)

I then booted the newly created VM (Virtual Machines menu > double click VM > access on sidebar > Power On):

![image032](https://user-images.githubusercontent.com/71083461/215291582-e64a79d1-75dd-46f2-b539-83d64848eafc.gif)

I then accessed the VM (Console > Open console in new tab) and was met with the following screen:

![image034](https://user-images.githubusercontent.com/71083461/215291585-70c6d0f2-2c4f-4483-9e7f-45fa5d27ff59.gif)

Where I clicked Enter, and on the next screen to prompt install pressed Enter again. I was met with a Windows screen asking for languages, picked “Next”. Then I pressed “Install now”:

![image036](https://user-images.githubusercontent.com/71083461/215291589-e0d6faab-8a91-4bc5-b252-59992b51e886.gif)

From here the setup would go along until I was met with the following screen – where I selected the second option from the top (highlighted in blue in the screenshot below):

![image038](https://user-images.githubusercontent.com/71083461/215291592-3f0d908a-1875-412f-acff-e52162fdd951.gif)

I would accept the license terms and select “Next”:

![image040](https://user-images.githubusercontent.com/71083461/215291594-7d8c7092-3145-4aed-bef1-b67314bc8fb2.gif)

Selected to do a custom install:

![image042](https://user-images.githubusercontent.com/71083461/215291596-195b5836-384e-4c62-aa56-59400813bbbb.gif)

Used the unallocated space:

![image044](https://user-images.githubusercontent.com/71083461/215291598-e959863d-2ee2-4033-a38e-12292bb3e4ba.gif)

Windows will now install (takes awhile):

![image046](https://user-images.githubusercontent.com/71083461/215291600-2e6128ec-d8ad-4f37-9252-0fd5c6f103f2.gif)

After installing/rebooting, I was met with the following customization settings where I held down CTRL+SHIFT+F3 to enter audit mode (because of my pc setup, I also needed to press FN):

![image048](https://user-images.githubusercontent.com/71083461/215291602-85f0a353-f637-4faa-8a66-de127df8e01d.gif)

After letting audit mode setup, I was met with the following screen (I would select “Yes” to the network prompt):

![image050](https://user-images.githubusercontent.com/71083461/215291605-f70b4685-29f9-4bfb-8ad2-f7063eb92ab0.gif)

Then I used the searchbar to open powershell (opens as administrator by default):

![image052](https://user-images.githubusercontent.com/71083461/215291608-d69063e7-3277-4729-8ada-c1cb01dcceeb.gif)

I then used the “sconfig” utility to set the following options:  
![image054](https://user-images.githubusercontent.com/71083461/215291610-e358313c-afbe-4b4b-b746-85c828942fba.gif)

- 5 - Windows Update Settings – set to Manual (press OK)  

![image056](https://user-images.githubusercontent.com/71083461/215291612-a324be7c-5428-41a3-8a2b-5890c439b826.gif)

- 9 – Date and Time – set to Eastern Time (press OK)  

![image058](https://user-images.githubusercontent.com/71083461/215291614-66f99be6-2b9c-400d-893c-df7512b370b2.gif)

- 6 – Download and Install Updates – Search for all update/do all the updates (“A” at the cmd popup prompt/s), this process takes time and multiple restarts (Make sure to check periodically for restart prompts, Windows might say it's done…but not really be done). On restarts, will need to redo the sconfig > option 6 > A > A

![image060](https://user-images.githubusercontent.com/71083461/215291616-cfed12ed-b781-4454-8617-90d4b98881eb.gif)

Following shows a completed updating output:

![image062](https://user-images.githubusercontent.com/71083461/215291620-79017ca3-c697-4e6d-915e-cb285ca15ef6.gif)

Then I installed VMware tools by going back to my ESXi host client > right clicking the VM “dc1” > Guest OS > Install VMware Tools:

![image064](https://user-images.githubusercontent.com/71083461/215291622-7db392b7-0a94-4d71-915a-3cafbb9a3cd2.gif)

Back in the VM, I opened File Explorer > right clicked the new DVD drive for VMware > pressed “Install or run program from your media”:

![image066](https://user-images.githubusercontent.com/71083461/215291624-828ac88b-896a-4301-9f1a-5b105fdfa60c.gif)

In the installer I followed along with the default options (pressing “Next >” on first screen, then install)

![image068](https://user-images.githubusercontent.com/71083461/215291626-f2d4a007-fb9a-4254-ac4a-67c630dc3301.gif)

After pressing Finish, I would choose to NOT restart

Then in powershell I downloaded this instructor provided [script](https://raw.githubusercontent.com/gmcyber/RangeControl/main/src/scripts/base-vms/windows/windows-prep.ps1) onto the Windows host:

```powershell
wget https://raw.githubusercontent.com/gmcyber/RangeControl/main/src/scripts/base-vms/windows/windows-prep.ps1 -Outfile windows-prep.ps1
```

![image070](https://user-images.githubusercontent.com/71083461/215291628-9a481d4b-2a96-4a34-a927-b0882e242417.gif)

**(NOTE: Following has a typo on the line for adding a local group member. Should start with the A in “Add-LocalGroupMember”)**

In this file, using notepad, I made the following changes (essentially uncomment the lines revolving creating the deployer user/comment out the last line), and pressed CTRL+S to save it:

![image072](https://user-images.githubusercontent.com/71083461/215291630-553da11c-6799-486b-9391-17a5510d2aac.gif)

Then I unblocked the file and set the execution policy with the following commands:

```powershell
Unblock-File .\windows-prep.ps1
Set-ExecutionPolicy RemoteSigned
```

![image074](https://user-images.githubusercontent.com/71083461/215291632-3b8d2216-8567-4061-ba7d-a3eb0c806f03.gif)

Then I ran the file with `.\windows-prep.ps1’:

![image076](https://user-images.githubusercontent.com/71083461/215291634-9ee28dc9-2b3e-4133-845f-c1408017558f.gif)

After running, I was met with the following (note above note), pressed OK:

![image078](https://user-images.githubusercontent.com/71083461/215291636-8238d886-5e13-4fb0-8b52-d2ac2d4b9e59.gif)

**BECAUSE OF THE ABOVE TYPO I RAN THE FOLLOWING:**

```powershell
Add-LocalGroupMember -Group Administrators -Member deployer
```

![image080](https://user-images.githubusercontent.com/71083461/215291638-2b508327-c2a1-4de3-b191-8cd590723219.gif)

Then I restarted the host  

Once rebooted, I exited out of the System Preparation Tool, opened powershell, and ran the following commands:

```powershell
C:\Windows\System32\Sysprep\sysprep.exe /oobe /generalize /unattend:C:\unattend.xml
```

![image082](https://user-images.githubusercontent.com/71083461/215291640-db5b570e-d6a6-4c92-94c6-be149d70ce0f.gif)

(This shuts down the machine)

Then from my ESXi Host Client, I right clicked the “dc1” VM on the sidebar > Edit settings and did the following:

- CD/CDC Drive 1 – Set to “Host device”  

![image084](https://user-images.githubusercontent.com/71083461/215291642-89dda1cc-23ef-4c8c-b3cd-ef49c571bb1c.gif)

Then I created a base snapshot from the sidebar from my ESXi Host Client, I right clicked the “dc1” VM on the sidebar > Snapshots > Take snapshot:

![image086](https://user-images.githubusercontent.com/71083461/215291644-978e6aee-d40f-41b2-9fbd-6956b47a130e.gif)

I would name the snapshot “Base” and take it:

![image088](https://user-images.githubusercontent.com/71083461/215291646-f8c39c4b-5cac-4984-9ca8-4a1983883470.gif)

## Domain install

I powered on my dc1, sent a CTRL+ALT+DELETE (Dropdown > Send keys > whatever key you need):

![image090](https://user-images.githubusercontent.com/71083461/215291648-8ffacfd9-c3b0-42c2-a65e-0c99dc2d37e0.gif)

Then set my administrative password (after pressing sign in and ok at the next prompt, then creating a password) and was met with the following:

![image092](https://user-images.githubusercontent.com/71083461/215291650-b4298664-9faa-4aa0-b807-b1da3c059244.gif)

I would then go back to my ESXi dashboard and go to the sidebar > right click dc1 > edit settings > change the network adapter to “480-WAN”:

![image094](https://user-images.githubusercontent.com/71083461/215291652-a31eceb7-a8cc-4f1b-866f-8006d1408057.gif)

I would then go back to dc1 (automatically logged in as administrator), press ok for the network connection, then open powershell and go into `sconfig` where I would set the following (number represents number in sconfig and sub-menus):

- 8 – change the network adapter settings to the following (only 1 network adapter, so edit that):
  
  - 1 – “S” for static IP, 10.0.17.4 IP address, 255.255.255.0 subnet mask, 10.0.17.2 gateway (press ok on the network prompt)  

![image096](https://user-images.githubusercontent.com/71083461/215291654-2c41de23-47fa-422c-aa1c-74c562578e06.gif)

- 2 – set dns to 10.0.17.2, no alternative, yes to any pop ups  

![image098](https://user-images.githubusercontent.com/71083461/215291656-846ee6b2-5554-4aec-9920-25ec053c24f4.gif)

- 2 – Set computer name to “dc1”, restart  

![image100](https://user-images.githubusercontent.com/71083461/215294858-2e83ec79-693e-45bd-adfa-39d593015da9.gif)

On reboot, I would attempt to login via SSH to dc1 from xubuntu, which was successful:

![image102](https://user-images.githubusercontent.com/71083461/215294860-1072dc15-a35e-4b8b-a51f-023d3be74bd1.gif)

I then ran the following commands to [install ADDS, DNS, and DHCP](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/SEC-480/domain-install-commands.md) (for prompts, made safe mode password, answered with the default option for the rest.):

```powershell
# Setup AD
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName “oliver.local”
# Wait for reboot, SSH back in as deployer, then make accounts (might want to switch to new account after creation)
$password = Read-Host "Please enter a password for the oliver-adm.mustoe user" -AsSecureString
New-ADUser -Name oliver-adm.mustoe -AccountPassword $password -Passwordneverexpires $true -Enabled $true
Add-ADGroupMember -Identity "Domain Admins" -Members oliver-adm.mustoe
Add-ADGroupMember -Identity "Enterprise Admins" -Members oliver-adm.mustoe
# Setup DNS and make records (A/PTR)
Install-WindowsFeature DNS -IncludeManagementTools
Add-DnsServerPrimaryZone -NetworkID 10.0.17.0/24 -ZoneFile “17.0.10.in-addr.arpa.dns”
Add-DnsServerResourceRecordA -CreatePtr -Name "vcenter" -ZoneName "oliver.local" -AllowUpdateAny -IPv4Address "10.0.17.3"
Add-DnsServerResourceRecordA -CreatePtr -Name "480-fw" -ZoneName "oliver.local" -AllowUpdateAny -IPv4Address "10.0.17.2"
Add-DnsServerResourceRecordA -CreatePtr -Name "xubuntu-wan" -ZoneName "oliver.local" -AllowUpdateAny -IPv4Address "10.0.17.100"
Add-DnsServerResourceRecordPtr -Name "4" -ZoneName “17.0.10.in-addr.arpa” -AllowUpdateAny -AgeRecord -PtrDomainName "dc1.oliver.local."
# Setup DHCP
Install-WindowsFeature DHCP -IncludeManagementTools
netsh dhcp add securitygroups
Restart-Service dhcpserver
Add-DHCPServerv4Scope -Name “oliver-scope” -StartRange 10.0.17.101 -EndRange 10.0.17.150 -SubnetMask 255.255.255.0 -State Active
# In theory, lease-time flag could be added to the above command, but I did not set it first time. To ensure future running, just added below
Set-DHCPServerv4Scope -ScopeID 10.0.17.0 -Name “oliver-scope” -State Active -LeaseDuration 1.00:00:00
Set-DHCPServerv4OptionValue -ScopeID 10.0.17.0 -DnsDomain dc1.oliver.local -DnsServer 10.0.17.4 -Router 10.0.17.2
# Following must be run as the new adm user
Add-DhcpServerInDC -DnsName "dc1.oliver.local" -IpAddress 10.0.17.4
Restart-service dhcpserver
```

Then, on xubuntu, I changed my DNS settings (Connection dropdown in upper right > Edit Connections…> first option selected and select with gear wheel)  via editing the first wired connection to the following:

![image104](https://user-images.githubusercontent.com/71083461/215294862-59e9a497-ae7e-4229-b756-77cc8b900cac.gif)

After saving, needed to from the dropdown disconnect and reconnect the adapter (this caused my google remote connection to stop, and I needed to power cycle the VM) but I was able to log back in and use the DNS functionality:  

![image106](https://user-images.githubusercontent.com/71083461/215294864-c8d13706-6d48-4f9a-a6e3-a9e1b98bbce5.gif)

I also installed remmina with:

```bash
sudo apt install remmina
```

Then I, from my SSH connection, enabled remote desktop on the Windows host/let it through the firewall (did login via the gui once, but I am unsure if that had an effect or not.):

```powershell
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
```

From here, I could login to my windows host wth remmina!

## Reflection

This milestone was a good introduction to the base imaging process of windows server, and a fun reintroduction into domains for windows. As I have experienced both sysadmins classes, I have a lot of experience with working mostly with Windows server gui. Working with AD in powershell purely was actually a really fun experience, and besides some typos (which lead to looking up and deleting DNS records), I actually found it easier than the gui. I also made sure to mark down the powershell commands I ran, so I can easily repeat the process/start using a utility like Ansible to automate the process. I also didn’t have Google remote desktop installed on my xubuntu box for some reason, even using the install commands manually didn’t work. So as I continue on with the course, I will keep a close eye on things to ensure that nothing gets messed up. If stuff does get messed up from my base image, my plan would be to make a full clone from base > re-run script and ensure proper settings are set > Snapshot2.exe > clone from that from then on. I am hopeful though that it was simply a Google quirk.

## Sources:

- [How to install Remmina - Remmina](https://remmina.org/how-to-install-remmina/)

- [How to enable Remote Desktop using PowerShell on Windows 10 - Pureinfotech](https://pureinfotech.com/enable-remote-desktop-powershell-windows-10/)



****

Can't find something? Look in the backup [Milestone 2](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-480/Milestone_2.md) page
