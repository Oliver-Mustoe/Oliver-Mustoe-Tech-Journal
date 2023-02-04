This page journals content related to NET/SEC/SYS-480 milestone 4.

**Table of contents**

- [Milestone 4.1 – Active Directory LDAPs SSO Provider](#milestone-41–active-directory-ldaps-sso-provider)
  
  - [CA and SSO setup and initialization](#ca-and-sso-setup-and-initialization)
  
  - [Reflection](#reflection-for-41)
  
  - [Troubleshooting #1](#troubleshooting-1)
  
  - [Sources](#sources-for-41)

- [Milestone 4.2 Powershell, PowerCLI and Our First Clone](#milestone-42-powershell-powercli-and-our-first-clone)
  
  - [Dependency installation](#dependency-installation)
  
  - [Powercli](#powercli)
  
  - [Github setup](#github-setup)
  
  - [Reflection](#reflection-for-42)
  
  - [Sources](#sources-for-42)

- [Milestone 4.3 Ubuntu Server Base VM and Linked Clone](#milestone-43-ubuntu-server-base-vm-and-linked-clone)
  
  - [Folder management](#folder-management)
  
  - [Ubuntu server base installation](#ubuntu-server-base-installation)
  
  - [Cloning](#cloning)
  
  - [Troubleshooting #2](#troubleshooting-2)
  
  - [Reflection](#reflection-for-43)
  
  - [Sources](#sources-for-43)

## VM Inventory

- desktop.xubuntu.gui.base
- server.2019.gui.base
- server.vyos.base
- ubuntu.22.04.1.base
- awx

## Milestone 4.1 – Active Directory LDAPs SSO Provider

I powercyc’d my xubuntu-wan VM, as it was acting really funny with chrome remote desktop. After that it worked fine.

### CA and SSO setup and initialization

Then I SSH’d into dc1 as my named administrative user and used the following powershell commands to install Certification Authority features and configure the Active Directory Certificate Services with an Enterprise Root CA (see [Troubleshooting #1](#troubleshooting-1)):

```powershell
Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools
Install-AdcsCertificationAuthority -CACommonName "oliver-DC1-CA" -CAType EnterpriseRootCa -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" -KeyLength 2048 -credential (get-credential) -HashAlgorithmName SHA512
```

![image002](https://user-images.githubusercontent.com/71083461/216635968-991c579e-4323-4c27-8178-a3fdf2db57b3.gif)

Then I rebooted the computer.

From a remmina connection in to show:

![image004](https://user-images.githubusercontent.com/71083461/216635974-5027c61d-4db2-4038-9f74-0bc7338a3666.gif)

(For transparency, the order of operations in real-time was creating a bad CA, setting up vCenter in the active directory, setting up another bad CA, and then finally setting up a good CA. So in a perfect world, CA creation > vCenter AD setup)

Then from my vcenter instance at “vcenter.oliver.local”, I used the dropdown on the left > Administration > Single Sign on area > Configuration:

![image006](https://user-images.githubusercontent.com/71083461/216635977-9b792347-4f1f-4c01-8eb3-084521205675.gif)

Then I navigate from Identity Sources down to Active Directory Domain:

![image008](https://user-images.githubusercontent.com/71083461/216635981-58d55e20-c152-4110-8b08-fd638ad203ba.gif)

Where I clicked to JOIN AD, where I entered in the following:

![image010](https://user-images.githubusercontent.com/71083461/216635984-3e7435a4-e2a4-42d4-9b63-c107deda1419.gif)

And then I pressed join, which gave the following:

![image012](https://user-images.githubusercontent.com/71083461/216635989-97aba3e1-9efa-4963-b645-ef7a5b848e9b.gif)

(NOTE: I would repeat this process once as I, in finding how to reboot, pressed the refresh button which whipped away the settings :), above is from the last time entering!)

Then to restart the node I (still in Administration) navigated to the deployment section > System Configuration > selected vcenter and pressed “REBOOT NODE” (gave a popup that require a reason for rebooting, just answered “SSO” and pressed REBOOT):

![image014](https://user-images.githubusercontent.com/71083461/216635995-dd0e3659-1950-4651-89c9-ce23c1fabc83.gif)

![image016](https://user-images.githubusercontent.com/71083461/216635997-6d054abc-5ca0-4a83-9f43-2edb9fb01602.gif)

Then I ran the following powershell commands in a SSH session to create the required OU structure and user:

```powershell
New-ADOrganizationalUnit -Name "480" -Path "DC=oliver,DC=local"
New-ADOrganizationalUnit -Name "Accounts" -Path "OU=480,DC=oliver,DC=local"
New-ADOrganizationalUnit -Name "Services" -Path "OU=Accounts,OU=480,DC=oliver,DC=local"
$password = Read-Host "Please enter a password for the vcenterldap user" -AsSecureString
New-ADUser -Name vcenterldap -GivenName vcenterldap -AccountPassword $password -description "ldap binding for vcenter active directory sso" -DisplayName vcenterldap -Passwordneverexpires $true -Enabled $true -path "OU=Services,OU=Accounts,OU=480,DC=oliver,DC=local"
# Made a mistake of the ServiceAccount OU name, so I renamed it here
Rename-ADObject -Identity "OU=Services,OU=Accounts,OU=480,DC=oliver,DC=local" -NewName "ServiceAccount"
```

End result:

![image018](https://user-images.githubusercontent.com/71083461/216635999-ca29bc6a-9110-49ef-bd85-6c04e66cc112.gif)

I then rebooted dc1

After the reboot, I used the following command on my xubuntu-wan box to grab the SSL certificate:

```
openssl s_client -connect dc1:636 -showcerts
```

![image020](https://user-images.githubusercontent.com/71083461/216636005-b9077622-1145-4db5-bd8a-45725a9d8fe6.gif)

I would save the certificate inside a folder on my desktop called “ldapcert.cert” (used SHIFT+INSERT in VI to copy and past the output):

![image022](https://user-images.githubusercontent.com/71083461/216636009-0eb47f3f-ca91-4a42-b97e-8da0bcf5bfb8.gif)

I then ran the following powershell commands to move my named domain user to the correct OU, and created a group with my named domain admin user added:

```powershell
Get-ADUser -Identity oliver-adm.mustoe | Move-ADObject -TargetPath "OU=Accounts,OU=480,DC=oliver,DC=local"
New-ADGroup -Name "vcenter-admins" -SamAccountName vcenter-admins -GroupCategory Security -GroupScope Global -DisplayName "vcenter-admins" -Path "OU=Accounts,OU=480,DC=oliver,DC=local" -Description "Members of this group are vcenter admins"
Add-ADGroupMember -Identity "vcenter-admins" -Members oliver-adm.mustoe
```

Following shows this completed:

![image024](https://user-images.githubusercontent.com/71083461/216636012-8bd3db51-9252-4350-aae7-a6cc3e5bcd07.gif)

Back in vCenter, I navigated back to the Administration area > Singe Sign On section > Configuration > Identity Sources where I chose to ADD an identity source (following shows the pop-up form filled out) then pressed ADD:

![image026](https://user-images.githubusercontent.com/71083461/216636014-e4e8f072-5a21-4afd-b877-1630f2298449.gif)

Tips:

- In active directory, can set advanced view, which means that you can right click on a folder > properties > Attribute Editor > see the path

![image028](https://user-images.githubusercontent.com/71083461/216636017-3fd0e60d-835d-4afe-985e-52055b229e23.gif)

![image030](https://user-images.githubusercontent.com/71083461/216636021-f2bc6e7a-aa80-492e-a696-60d4f9ab878b.gif)

It being set:

![image032](https://user-images.githubusercontent.com/71083461/216636024-185c5c11-e539-455b-9379-65bf4e26571c.gif)

After its set, I navigated to Users and Groups in Single Sign On > Groups tab (left of Users tab, under heading):

![image034](https://user-images.githubusercontent.com/71083461/216636027-c3226575-fbcb-4f75-8bf1-25356843411b.gif)

Then I selected Administrators > ADD MEMBERS > filled in the following (enter “vcenter-admins” in the search, will then be added to the other groups) and pressed SAVE :

![image036](https://user-images.githubusercontent.com/71083461/216636029-9744a830-af7b-4804-b80b-1b4f2dedc9c4.gif)

I then restarted the node like I did before, after the restart, I could sign in as my admin user:

![image038](https://user-images.githubusercontent.com/71083461/216636035-60c10e9e-761b-4f63-8b2b-bbf1b7d0eb50.gif)

I would also go back into the dropdown > Administration area > Singe Sign On section > Configuration > Identity Sources where I would set my AD as the default (OK at the popup)  First pic shows before, second shows after:

![image040](https://user-images.githubusercontent.com/71083461/216636039-4cc12553-f894-44ee-9660-a27e0737385c.gif)

![image042](https://user-images.githubusercontent.com/71083461/216636044-0b0e062a-e6ba-44c7-95bb-4769098eb991.gif)

### Reflection for 4.1:

This part of milestone 4 was really cool, and I am really enjoying seeing the progression from nothing to mini cyber.local. I had a really big troubleshooting time with the CA, which ended up being that I didn’t include the credential flag in my powershell command. This I believe made it so that my certificate wasn’t being signed by the private key, so the certificate was essentially broken. From troubleshooting, I was able to fix this and successfully have a certificate. I also tried to use powershell commands to manage AD (including OU, users, and groups) and I actually find it to be about as fast if not faster than doing it by hand. I have found that it is especially easier to tech journal as I can just supply the commands. Overall, fun step, looking forward to .2 and .3 later.

### Troubleshooting #1

Originally ran the following incorrect commands to setup the CA:

```powershell
Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools
Install-AdcsCertificationAuthority -CACommonName "oliver-DC1-CA" -CAType EnterpriseRootCa
```

Which I believe caused by CA certificates to not work correctly, so I ran the following to uninstall the certificate authority:

```powershell
Uninstall-AdcsCertificationAuthority
```

And then used the following correct commands to setup the authority (what is prescribed above, changed name from “oliver” to “olivermustoe” as the private key was already made):

```powershell
Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools
Install-AdcsCertificationAuthority -CACommonName "olivermustoe-DC1-CA" -CAType EnterpriseRootCa -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" -KeyLength 2048 -HashAlgorithmName SHA512
```

I would later find where the keys are (at least I believe):

![image044](https://user-images.githubusercontent.com/71083461/216636047-e9f680ff-8769-4a7f-8a19-44e8965aaec3.gif)

![image046](https://user-images.githubusercontent.com/71083461/216636053-43d905ee-991f-494b-83a8-956ce638e132.gif)

I would then go down a very long road in which my CA still didn’t work, but I found the solution, which is that I need to add “-credential” to the install command for install an enterprise root CA. So I did the following to cleanup the other 2 CA’s and install another “oliver-DC1-CA:

Ran `Uninstall-AdcsCertificationAuthority`, rebooted, and deleted the certificates in “Manage computer certificates”. Following shows cleaned certificates folder, deleted 2 certificates named “oliver-DC1-CA” and “olivermustoe-DC1-CA” (essentially removed the old CA’s names):

![image048](https://user-images.githubusercontent.com/71083461/216636055-13c991c7-e2f7-47c0-a680-46784ddcdd5f.gif)

Then I made sure the keys were deleted from “C:\ProgramData\Microsoft\Crypto\Keys” (deleted highlighted):

![image050](https://user-images.githubusercontent.com/71083461/216636057-4ee39fd7-3146-4712-af4f-6762e274dc02.gif)

Then I ran the following commands to setup the CA correctly:

```powershell
Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools
Install-AdcsCertificationAuthority -CACommonName "oliver-DC1-CA" -CAType EnterpriseRootCa -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" -KeyLength 2048 -credential (get-credential) -HashAlgorithmName SHA512
```

![image051](https://user-images.githubusercontent.com/71083461/216636059-5561e0a3-99e2-4f95-a5bc-42743aa7e266.gif)

Then rebooted computer AND IT WORKS WOOOOOOOOOOOOOOOOOOO. Above, I corrected the main documentation to reflect the correct process :).

### Sources for 4.1:

- [How to install Active Directory Certificate Services on Windows server 2012 | Dell Canada](https://www.dell.com/support/kbdoc/en-ca/000121419/how-to-install-active-directory-certificate-services)

- [Microsoft Powershell &#8211; Install and Configure AD Certificate Services (Windows Server 2016) &#8211; IT Wiz Technology Blog](https://blog.wiztechtalk.com/2019/04/03/microsoft-powershell-install-and-configure-ad-certificate-services-windows-server-2016/)

- [Install-AdcsCertificationAuthority (ADCSDeployment) | Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/adcsdeployment/install-adcscertificationauthority?view=windowsserver2022-ps)

- [Reboot a Node](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.vcsa.doc/GUID-63A3FB6C-9EF5-4AF6-8120-6711799A2CAD.html)

- [Create Bulk Organizational Units (OU) in Active Directory with PowerShell &#x2d; Active Directory Pro](https://activedirectorypro.com/create-bulk-organizational-units-ou-in-active-directory-with-powershell/)

- [New-ADUser (ActiveDirectory) | Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-aduser?view=windowsserver2022-ps)

- [Zachary's Memo (IT Career): Windows -- How to enable LDAP over SSL on Windows 2012 or later](https://blog.bridgeclouds.com/2015/04/how-to-enable-ldap-over-ssl-on-windows.html)

- https://social.technet.microsoft.com/wiki/contents/articles/2980.ldap-over-ssl-ldaps-certificate.aspx

- [Get-Credential (Microsoft.PowerShell.Security) - PowerShell | Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-credential?view=powershell-7.3)

- [New-ADGroup (ActiveDirectory) | Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-adgroup?view=windowsserver2022-ps)

- [Move Ad User to another OU with PowerShell - ShellGeek](https://shellgeek.com/move-ad-user-to-another-ou/)

- [How to Add User to Group in PowerShell with Add-ADGroupMember](https://lazyadmin.nl/powershell/add-user-to-group-add-adgroupmember/#:~:text=To%20add%20users%20to%20a,groups%20to%20an%20AD%20Group).

## Milestone 4.2

### Dependency installation:

I installed Ansible on my xubuntu-wan VM by running the following commands:

```bash
sudo apt update
sudo apt install sshpass python3-paramiko git -y
sudo apt-add-repository ppa:ansible/ansible
sudo apt update
sudo apt install ansible -y
```

Double checking the installation was a success with `ansible –version`:

![image053](https://user-images.githubusercontent.com/71083461/216636061-eeb22768-84ea-431f-a6f3-9b7698761c2e.gif)

The I installed powershell with the following command:

```bash
sudo snap install powershell --classic
```

Ensuring that I can access powershell with `pwsh` and that my versioning is correct with `Write-Host $PSVersionTable`:

![image055](https://user-images.githubusercontent.com/71083461/216636063-f5491a56-9727-4dfe-afe1-c99c3fb5e833.gif)

Then I installed the needed dependencies/configured them for Powercli (answered “y” to all prompts):

```powershell
Install-Module VMware.PowerCLI -Scope CurrentUser
Get-Module VMware.PowerCLI -ListAvailable
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false
```

### Powercli

After entering my Powershell instance on xubuntu-wan with `pwsh`, I could connect to vcenter by entering the following:

```powershell
$vcenter=”vcenter.oliver.local”
Connect-VIServer -Server $vcenter
```

![image057](https://user-images.githubusercontent.com/71083461/216636065-8100241d-7901-44a1-9770-99163a269360.gif)

I would then set:‘$vm’ to dc1 and set ‘$snapshot’ to the snapshot command for dc1, the ‘$vmhost’ variable to the host, ‘$ds’ to the designated datastore, $linkedClone to get the linked clone name for dc1:

```powershell
# Use the command ‘Get-VM’ to see which host you should be selecting
$vm = Get-VM -Name dc1
$snapshot = Get-Snapshot -VM $vm -Name "Base"
# Use the command ‘Get-VMHost’ to see which host you should be selecting
$vmhost=Get-VMHost -Name "192.168.7.25"
# Use the command ‘Get-Datastore’ to get the datastore names
$ds = Get-DataStore -Name “datastore1-super15”
# “{0}” represents a placeholder for the first index, which the vm objects name attribute is being formatted (‘-f’) into
$linkedClone = “{0}.linked” -f $vm.name
```

See all set below:

![image059](https://user-images.githubusercontent.com/71083461/216636068-8621c839-b23c-4c77-8d87-86575a26d99a.gif)

I would then setup my ‘$linkedvm’ variable to create a linked clone with the following:

```powershell
$linkedvm = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
```

And then I created a new VM with the ‘$newvm’ clone:

```powershell
$newvm = New-VM -Name “server.2019.gui.base” -VM $linkedvm -VMHost $vmhost -Datastore $ds
```

Results from above:

![image061](https://user-images.githubusercontent.com/71083461/216636072-3225e7e7-df64-4c06-a21e-fb0962ee1248.gif)

I then created a new snapshot on my new VM:

```powershell
$newvm | New-Snapshot -Name “Base”
```

 And removed the linked clone:

```powershell
$linkedvm | Remove-VM
```

[I would then create a script to automate this process.](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/SEC-480/Code/cloner.ps1) I would make use of Github, [see setup below](#github-setup), for transporting my script between my main host and xubuntu-wan. With the script, I would create the following base VMs:

- “desktop.xubuntu.gui.base” from xubuntu-wan

- “server.vyos.base” from 480-wan

![image063](https://user-images.githubusercontent.com/71083461/216636074-50f5fcec-f540-422a-96dc-cba19dd24bd6.gif)

Test run:

```powershell
./Oliver-Mustoe-Tech-Journal/SEC-480/Code/cloner.ps1 -VMName 480-wan -CloneVMName testforgithub
```

![image065](https://user-images.githubusercontent.com/71083461/216636078-47974c98-7f9c-4ac3-91f2-6c9c2bed7eb3.gif)

![image067](https://user-images.githubusercontent.com/71083461/216636082-cf2ba771-489d-45d0-8acb-15843ac57b06.gif)

### Github setup

For easy transportation, I decided to setup my Github repository on my xubuntu-wan management box. I first ran the following commands to create my keys:

```bash
# Made the key
ssh-keygen -t ed25519
# Add the key to the ssh-agent
ssh-add ~/.ssh/id_ed25519
```

Then I went to my account on github > dropdown > Settings > SSH and GPG keys on the sidebar > New SSH key > where I would add my public key!  

![image](https://user-images.githubusercontent.com/71083461/216782693-ea7a93f2-4cb2-4f73-a880-80e8cbf134fd.png)  

From there, I could use the Code dropdown > copy the SSH clone command > and use `git clone {SSH_CODE}` to access my repository!

### Reflection for 4.2:

This was a really fun milestone, as it was a really good introduction to Powercli and a good place for me to flex my Powershell skills. I implemented both in script and flags for setting the name variables which was fun to learn/implement. I am really glad I did this, as in the future if I already know the names I want/need, I can directly deploy new Base clones. I also learned about using formatting in Powershell using `-f`, which was not something I was familiar with at all. Some of the output from the commands actually differs from flags/manual inputs, but that does not seem to have any effect on the output. I will monitor this and decide if it needs changing. I am very much enjoying Powercli at the moment, and I hope the final part of this milestone has a little left to do of it!

### Sources for 4.2

- https://groupe-sii.github.io/cheat-sheets/powercli/index.html 

- [Understanding PowerShell and Basic String Formatting - Scripting Blog](https://devblogs.microsoft.com/scripting/understanding-powershell-and-basic-string-formatting/)

## Milestone 4.3 Ubuntu Server Base VM and Linked Clone

### Folder management

In VSphere, I navigated to the VMs and templates area…

![image071](https://user-images.githubusercontent.com/71083461/216636088-4a609473-37aa-48fa-aff8-6b8706840bbb.gif)

Then I right clicked “480-Devops” > New Folder > New VM and Template Folder > entered and made the following folders (first folder shown made below, second folder made in the same way!):

![image073](https://user-images.githubusercontent.com/71083461/216636092-56a81343-64e6-4d75-8e63-3ed1f68f99db.gif)

Result:

![image075](https://user-images.githubusercontent.com/71083461/216636096-ee8a2a1c-0d3c-479a-96fc-551305a119d3.gif)

I then moved each of the VMs into the corresponding folders:

BASEVM:

- desktop.xubuntu.gui.base

- server.2019.gui.base

- server.vyos.base

PROD

- vcenter

- xubuntu-wan

- dc1

- 480-fw

This results in the following after the are moved (drag and drop into the folder):

![image077](https://user-images.githubusercontent.com/71083461/216636100-0d40a987-6aaa-43e0-811a-9068fd30f7f5.gif)

I the used the process outlined in https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Milestone-Bare-Metal-1---ESXi-Setup#isos-and-networking to download ubuntu-22.04 (the only change is that I enabled SSH through clicking on the host > Configure > System > Services:)

![image079](https://user-images.githubusercontent.com/71083461/216636106-63b0571a-e6a1-4f7b-bf28-24380615ef64.gif)

![image081](https://user-images.githubusercontent.com/71083461/216636109-2b5fc7e1-5090-4e4a-90ba-3ad89ec6fbca.gif)

### Ubuntu server base installation

I then, in vCenter, right clicked the “BASEVM” folder > New Virtual Machine… > Set the following:

1. Default creation type

2. Placed in BASEVM, with the name “ubuntu22.04.1.base”

![image083](https://user-images.githubusercontent.com/71083461/216636113-2799f20d-ac69-4ede-a8c3-fb3eac970cc8.gif)

3. Default option (ESXi host)

4. Selected datastore1

![image085](https://user-images.githubusercontent.com/71083461/216636116-a3a64511-e5c6-4969-91a1-2b55a9d1985e.gif)

5. Set compatibility to ESXi 8.0

![image087](https://user-images.githubusercontent.com/71083461/216636120-a049e5d7-5f12-4867-8513-388d8796e95c.gif)

6. Setup the guest OS

![image089](https://user-images.githubusercontent.com/71083461/216636124-bf4f14b9-5205-4430-9856-883639fdd073.gif)

7. Set the following settings **(Thin provisioning the Hard disk, not shown in picture but set under the hard disk dropdown in “Disk Provisioning”. Also change the SCSI controller to “LSI Logic Parallel”. Picture below are in order and show all configured information)**

![image091](https://user-images.githubusercontent.com/71083461/216636128-349a8954-c7d5-4390-ad76-29ccbc4a7516.gif)

![image093](https://user-images.githubusercontent.com/71083461/216636131-31960551-b67a-4193-8f64-ccfb89375926.gif)

![image095](https://user-images.githubusercontent.com/71083461/216636133-de54b9a0-42e1-4ea0-8bdc-9298aead136c.gif)

8. Finishing:

![image097](https://user-images.githubusercontent.com/71083461/216636136-985eafbf-148a-43a6-96a6-0c38e369632a.gif)

![image099](https://user-images.githubusercontent.com/71083461/216636140-65966a72-c716-4e86-bff4-5ca33a0cf019.gif)

I then in vSphere right clicked the VM > Power > Power On > Launch it in a web console >  followed the default installation except for the following:

(default installation means just pressing/giving the default option when presented in the installer)

Updated to the new installer:

![image101](https://user-images.githubusercontent.com/71083461/216651471-641b44aa-cc48-40b7-8dbe-df0d6a3e18f7.gif)

Set up a rangeuser account like the following:

![image103](https://user-images.githubusercontent.com/71083461/216651474-f15146ad-1a56-498b-b9fc-2b89229b6b0d.gif)

Installed OpenSSH server:

![image105](https://user-images.githubusercontent.com/71083461/216651477-e44acdce-337b-4c6c-a8bb-e9115e427729.gif)

Then I rebooted the host:

![image107](https://user-images.githubusercontent.com/71083461/216651479-4e22781d-5e31-433c-a22a-2be089a5a99b.gif)

**(NOTE: BE CAREFUL ON WHICH BASE VM YOU ARE POWERING ON**, I accidentally powered on the xubuntu based image, in which I used my script made from 4.2 to redeploy the base image. Also, the instructor's guide mentions “No Snaps”, but I saw no prompt that asked for that so I assume it was something I had to opt-in to.)

I would then reboot the machine from vSphere using the same process I used to power it on (see above) but selected reset instead of power on.

When the host was powered on, I signed in as the rangeuser (had to press Enter to get the prompt), I disabled IPv6:

```bash
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1
```

![image109](https://user-images.githubusercontent.com/71083461/216651482-da1e5034-cd80-479c-bcbf-5fdd2013dedc.gif)

Then I downloaded and ran the following the [instructor provided script:](https://raw.githubusercontent.com/gmcyber/RangeControl/main/src/scripts/base-vms/ubuntu-server.sh)

```bash
wget https://raw.githubusercontent.com/gmcyber/RangeControl/main/src/scripts/base-vms/ubuntu-server.sh && sudo bash ubuntu-server.sh
```

**NOTE:** Did once try to run the bash command as a non-root user, which resulted in a bunch of issues with permissions. Just stopped the command and added sudo to the command! Also, a screen pop-up came asking for restarting services, I just pressed enter and it worked fine.

Then I ran the following **AS ROOT** (originally ran after completion of the assignment, see [troubleshooting #2](#troubleshooting-2)):

```bash
echo -n > /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id
```

![image](https://user-images.githubusercontent.com/71083461/216709956-ec8146ac-5dc6-42be-9449-8979579465dd.png)

Then I shutdown the host, `shutdown -h now`, then right clicked the VM in vSphere > Edit settings > set CD/DVD to Client Device, OK:

![image111](https://user-images.githubusercontent.com/71083461/216651486-efc4cd31-fc04-49e2-8018-9f9630c8df07.gif)

I would then right click the VM > Snapshots > Take Snapshots… > Name it “Base > Create:

![image113](https://user-images.githubusercontent.com/71083461/216651489-2c8e73da-461d-41de-be21-f74c91f38304.gif)

### Cloning

I then used my own script to create a linked clone named “awx”, [LINK HERE.](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/SEC-480/Code/linkedcloner.ps1) Ran like the following (see [troubleshooting #2](#troubleshooting-2)):

```powershell
./Oliver-Mustoe-Tech-Journal/SEC-480/Code/linkedcloner.ps1 -VMName ubuntu.22.04.1.base -CloneVMName awx -defaultJSON ./Oliver-Mustoe-Tech-Journal/SEC-480/Code/defaults.json
```

![image](https://user-images.githubusercontent.com/71083461/216711140-0d1ab6b4-172a-4ef9-9c4d-124eb287a0fc.png)

With the linked clone created, on the right network adapter, I booted it up, logged in as rangeuser, and saw that I gained an IP from DHCP:  

![image](https://user-images.githubusercontent.com/71083461/216782827-f7550559-045c-48de-860b-baebd231dce4.png)

### Troubleshooting #2

After completing the Milestone, I went back to my VM and tested making a second linked clone. It worked successfully, but unfortunetly, I got the same DHCP address on the second linked clone. I, after researching, found that Ubuntu uses machine-id for DHCP, but I believed that it got trunacated in the instructors script. To try to get to the bottom of this, I powered on my base image and re-ran the instructors script from above/double-checked the machine-id was truncated (empty) with `cat`, then I shutdown the box.

![image](https://user-images.githubusercontent.com/71083461/216707096-3fd77367-0b4f-4e48-8cda-7dd2822c34dd.png)

Then I made another snapshot, named "Base2", same process as above, and made a temp .json file:

![image](https://user-images.githubusercontent.com/71083461/216707834-6462ce2d-14c4-4681-8db8-1ff50700574c.png)

Then I ran an updated version of my script and created 2 linked clones like the following:

![image](https://user-images.githubusercontent.com/71083461/216708177-56bf5516-8187-437b-a3f0-aebc6b6611d2.png)

Unfortunelty the 2 linked clones had the same machine-id, so I deleted Base2 snapshot > reverted to Base > powered the machine back on and re-ran the instructor script and ran the following commands **AS ROOT**:

```bash
echo -n > /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id
```

![image](https://user-images.githubusercontent.com/71083461/216709956-ec8146ac-5dc6-42be-9449-8979579465dd.png)  

Shutdown > "Base2" snapshot > 2 more linked clones **AND THIS FIXED IT**. So I removed my "Base" snapshot > renamed "Base2" to "Base" and deleted all of my linked clones and recreated "awx" using the prescribed command. I updated the above documentation to reflect what the correct process for cloning would be.

### Reflection for 4.3

This milestone was a fun learning experience that carried over a lot from the previous part of the milestone. The Powershell was mostly the same, and I was able to take my cloner.ps1 script and edit it slightly to accommodate linked clones. I also implemented using a json file to store “default” variables such as the vcenter address. As I explore more Powercli, I plan to make the script more robust/add in items to defaults.json. I did some independent testing for this milestone and actually experimented with creating another awx clone “awx2” to see the behavior of the networking.. I found that while the 2 clones had different MAC addresses, they would still get the same IP “.101”. Initially I thought this was related to hostname, but I found via research that to correct this behavior I had to run the commands designated in VMware documentation. I very much enjoyed having flags for my .ps1 files in this milestone, as it meant I could very quickly run a command to spin up a new base/linked clone when I wanted. Overall, a very interesting, learning heavy milestone with automation scripts that I will use/improve over the course.

### Sources for 4.3

- [VMware Knowledge Base](https://kb.vmware.com/s/article/82229)
- https://manpages.ubuntu.com/manpages/bionic/man5/machine-id.5.html#:~:text=The%20%2Fetc%2Fmachine%2Did,may%20not%20be%20all%20zeros.
- https://greenmountaincyber.com/docs/topics/vmware/base-vms/ubuntu-server
