# Milestone 8

This page journals content related to NET/SEC/SYS-480 milestone 8.

**Table of contents**

1. [480-utils updates](milestone-8.md#480-utils-updates)
2. [8.1 Splunk Enterprise Installation](milestone-8.md#8.1-splunk-enterprise-installation)
3. [8.2 Splunk Forwarder installation](milestone-8.md#8.2-splunk-forwarder-installation)
4. [Milestone 8 reflection](milestone-8.md#milestone-8-reflection)
5. [Created files](milestone-8.md#created-files)
6. [Sources for Milestone 8](milestone-8.md#sources-for-milestone-8)

### VM Inventory

* [splunk](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech\_journal\_backups/SEC-480/VM-Inventory/splunk.md)

## 480-utils updates

First I deployed a new Ubuntu VM named "splunk" (VM in vCenter shown below):

```powershell
Deploy-Clone -LinkedClone -VMName ubuntu.22.04.1.base -CloneVMName splunk -defaultJSON ./480.json
```

<figure><img src="../.gitbook/assets/image (3) (2).png" alt=""><figcaption></figcaption></figure>

Then in my 480-utils function, I added the following function to allow the editing of deployed VMs:

```powershell
function Edit-VMs ([string]$defaultJSON="",[string]$VM="",[int]$CPU=0,[int]$Memory=0) {
    try{
        # Find the path of the json file
        if ($defaultJSON -eq "") {
            $defaultJSON = Read-Host -Prompt "Please enter the path for the default JSON config"
            $conf = Get-480Config -config_path $defaultJSON
        }
        else {
            $conf = Get-480Config -config_path $defaultJSON
        }

        # Connect to vcenter server
        480Connect -server $conf.vcenter_server

        # See if user has selected a VM, if not...
        if ($VM -eq ""){
            # Get all VMs and display them
            $vms = Get-VM
            $index=1
            foreach($vm in $vms){
                Write-Host [$index] $vm
                $index+=1
            }
            while($true){
                # Choose a VM
                [int]$pick_index = Read-Host "Which index number [x] do you wish to pick?"
                if($pick_index -lt $index -and $pick_index -gt 0) {
                    $selected_vm=$vms[$pick_index - 1]
                    break
                }
                else {
                    Write-Host "[ERROR: Please select an inbound index]" -ForegroundColor Red
                }
            }
        }
        else {
            $selected_vm=Get-VM -Name $VM
        }
        Write-Host "You selected",$selected_vm.Name

        # Gather the relevant information and display to screen
        $VmName=$selected_vm.Name
        $NumCpu=$selected_vm.NumCpu
        $RamCount=$selected_vm.MemoryGB

        Write-Host "Information for $VmName :
[CPU] $NumCpu
[RAM] $RamCount (GB)
        "

        # See if user has selected a cpu or memory amount, if not
        if ($Cpu -eq 0 -and $Memory -eq 0) {

            # Prompt user for what they want to change, switch on it
            $UserChange = (Read-Host -Prompt "Would you like to change $VmName's [C]PU or [R]AM or [E]xit (C/R/E)").ToLower()

            switch ($UserChange) {
                # For CPU/Memory, prompt the user for the new settings and set it
                "c" {
                    $NewCpu = Read-Host -Prompt "Please enter in the new CPU amount"

                    $selected_vm | set-VM -NumCpu $NewCpu
                }
                "r"{
                    $NewRam = Read-Host -Prompt "Please enter in the new RAM amount in GB"

                    $selected_vm | set-VM -MemoryGB $NewRam
                }
                # ELSE give the exit
                "e"{
                    exit
                }
                Default {
                    Write-Host "NOTHING HAS OCCURED"
                }
            }
        }
       else {
            # If CPU and Memory are explicit, set them to what the user asks
            if($Cpu){
                $selected_vm | set-VM -NumCpu $Cpu
            }
            if($Memory){
                $selected_vm | set-VM -MemoryGB $Memory
            }

        }
    }
    catch{
        StandardError -err $_
        break
    }
}
```

And increased my splunk VMs CPU and Memory like the following (deployment and applied changes shown below):

```powershell
Edit-VMs -defaultJSON 480.json -VM splunk -CPU 4 -Memory 4
```

<figure><img src="../.gitbook/assets/image (1) (1) (1).png" alt=""><figcaption></figcaption></figure>

<figure><img src="../.gitbook/assets/image (2) (1).png" alt=""><figcaption></figcaption></figure>

I then powered splunk on and moved it into the BLUE1 folder. I waited until splunk was full powered on and grabbed the IP with the command below:

```powershell
get-VMIP -VMName splunk -defaultJSON ./480.json
```

<figure><img src="../.gitbook/assets/image (5) (1).png" alt=""><figcaption></figcaption></figure>

Afterwards I shutdown the VM and made a snapshot in the splunk Actions dropdown > Snapshots > Take Snapshot > named "BEFORE ANSIBLE":

<figure><img src="../.gitbook/assets/image (4) (2).png" alt=""><figcaption></figcaption></figure>

## 8.1 Splunk Enterprise Installation

With this setup, I made a Splunk account, created a directory in ansible/files named splunk, and downloaded the .deb file for Splunk enterprise onto xubuntu-wan to be copied to the splunk VM:

```bash
wget -O files/splunk/splunk-9.0.4-de405f4a7979-linux-2.6-amd64.deb "https://download.splunk.com/products/splunk/releases/9.0.4/linux/splunk-9.0.4-de405f4a7979-linux-2.6-amd64.deb"
```

<figure><img src="../.gitbook/assets/image (1) (1).png" alt=""><figcaption></figcaption></figure>

I also downloaded the universal forwarder as well to be copied to one of the BLUE1 machines:

```bash
wget -O files/splunk/splunkforwarder-9.0.4-de405f4a7979-linux-2.6-amd64.deb "https://download.splunk.com/products/universalforwarder/releases/9.0.4/linux/splunkforwarder-9.0.4-de405f4a7979-linux-2.6-amd64.deb"
```

<figure><img src="../.gitbook/assets/image (2) (3).png" alt=""><figcaption></figcaption></figure>

As well I downloaded the needed Add-on from [https://splunkbase.splunk.com/app/833](https://splunkbase.splunk.com/app/833):

<figure><img src="../.gitbook/assets/image (4) (1).png" alt=""><figcaption></figcaption></figure>

and moved it to my ansible/files/splunk directory:

```
cp -r ~/Downloads/splunk-add-on-for-unix-and-linux_880.tgz files/splunk/
```

<figure><img src="../.gitbook/assets/image (4) (3).png" alt=""><figcaption></figcaption></figure>

Then I created a Ansible script/Inventory ([splunk-enterprise-setup.yaml](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/SEC-480/ansible/splunk-enterprise-setup.yaml)) to do the following:

1. Install Splunk onto the Splunk VM with the following parameters (see [here](milestone-8.md#created-files) for the created files list):
   1. Hostname: splunk
   2. IP: 10.0.5.200/24
   3. Create a splunk service user
   4. Add-Ons: Splunk Add-on for Unix and Linux
   5. Added indexes: 1x called 480
   6. Receiver on the default port (9997)

<figure><img src="../.gitbook/assets/image (2) (5).png" alt=""><figcaption></figcaption></figure>

Below is a run of the script (command/result):

```bash
ansible-playbook -i inventories/splunk-inventory.yaml splunk-enterprise-setup.yaml --ask-pass -K
```

<figure><img src="../.gitbook/assets/image (2).png" alt=""><figcaption></figcaption></figure>

<figure><img src="../.gitbook/assets/image (9).png" alt=""><figcaption></figcaption></figure>

Result:

<figure><img src="../.gitbook/assets/image (9) (1).png" alt=""><figcaption></figcaption></figure>

## 8.2 Splunk Forwarder installation

I chose to use ubuntu-1 (10.0.5.30/24) as my Splunk forwarder, where in its logs would be forwarded to my splunk VM in the "480" index. First, using the same process as splunk, I created a new snapshot for the ubuntu-1-1 VM labeled "BEFORE FORWARDER":

<figure><img src="../.gitbook/assets/image (1).png" alt=""><figcaption></figcaption></figure>

I then created an Ansible script ([splunk-forwarder-setup.yaml](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/SEC-480/ansible/splunk-forwarder-setup.yaml))/Updated my splunk-inventory for the following requirements (see [here](milestone-8.md#created-files) for the created files list):

1. Install the Splunk universal forwarder on ubuntu-1
2. Have the configuration on ubuntu-1 sends logs to the 480 index

Below is a run of the script (command/result):

```bash
ansible-playbook -i inventories/splunk-inventory.yaml splunk-forwarder-setup.yaml
```

<figure><img src="../.gitbook/assets/image (3).png" alt=""><figcaption></figcaption></figure>

Result seen in a Splunk search:

<figure><img src="../.gitbook/assets/image (6).png" alt=""><figcaption></figcaption></figure>

## Milestone 8 reflection

The steps for creating the Splunk enterprise and forwarder was a very mixed process, so I decided to include the reflection for both steps in one reflection. The majority of the problems I was having with milestone were minor, annoying things. I didn't know about the user seed config to begin with, and I couldn't really find anything on the internet except that the instructor video mentioned a user seed file. After that, it caught my eye in an article I was reading and I was able to find that it was exactly what I needed to not manually enter in a password into the Splunk install. Making a designated service user was also a little confusing overall, but it was mostly a permissions headache which are solved through perseverance more than anything. The Add-on and the index were the last piece of the puzzle. The addon was confusing to install (the docs didn't help much) but it was a simple copy past. After installation, setting up the inputs.conf was annoying, but I got there in the end through trial and error. The index also had scarce documentation associated with it in terms of automation, but I was able to find a good guide for Ansible after a bit of Googling. Setting up the receiver was quite easy, as the documentation for Splunk clearly listed a config file to edit. The rest of the problems I had were simple misspellings/forgetting to cross my t's and dot my i's. Overall this milestone was a very good introduction to the Splunk installation and becoming more comfortable with Ansible.

## Created files

1.  [splunk-enterprise-setup.yaml](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/SEC-480/ansible/splunk-enterprise-setup.yaml)

    1. A ansible playbook to fully provision a ubuntu VM from linked state to being a splunk enterprise server (first part of script shown):

    <figure><img src="../.gitbook/assets/image (10).png" alt=""><figcaption></figcaption></figure>
2.  [splunk-forwarder-setup.yaml](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/SEC-480/ansible/splunk-forwarder-setup.yaml)

    1. A ansible playbook to provision a configured ubuntu VM with a splunk forwarder (first part of script shown):

    <figure><img src="../.gitbook/assets/image (5).png" alt=""><figcaption></figcaption></figure>
3.  [splunk-inventory.yaml](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/SEC-480/ansible/inventories/splunk-inventory.yaml)

    1. A ansible inventory of both the enterprise and forwarder machines as well as needed variables:

    <figure><img src="../.gitbook/assets/image (4).png" alt=""><figcaption></figcaption></figure>
4.  [user-seed.j2](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/SEC-480/ansible/files/splunk/user-seed.j2)

    1. A templated Jinja file that provides the user info needed by splunk on initial user setup:



    <figure><img src="../.gitbook/assets/image (8).png" alt=""><figcaption></figcaption></figure>
5.  [unix\_inputs.conf.j2](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/SEC-480/ansible/files/splunk/unix\_inputs.conf.j2)

    1. A templated Jinja file to enable the \*nix addon for splunks inputs (first part of script shown):

    <figure><img src="../.gitbook/assets/image (12).png" alt=""><figcaption></figcaption></figure>
6.  [inputs.conf](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/SEC-480/ansible/files/splunk/inputs.conf)

    1. A config file to setup a reciever on a enterprise splunk instance for the TCP port 9997 (first part of script shown):&#x20;

    <figure><img src="../.gitbook/assets/image (7).png" alt=""><figcaption></figcaption></figure>
7.  [forwarder\_outputs.conf.j2](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/SEC-480/ansible/files/splunk/forwarder\_configs/forwarder\_outputs.conf.j2)

    1. A templated Jinja file that sets up a forwarders output group/the enterprise address and port it should be forwarding to:

    <figure><img src="../.gitbook/assets/image (13).png" alt=""><figcaption></figcaption></figure>

## Sources for Milestone 8

* [https://medium.com/splunkuserdeveloperadministrator/automating-your-splunk-installation-with-ansible-c47bbf65eb52](https://medium.com/splunkuserdeveloperadministrator/automating-your-splunk-installation-with-ansible-c47bbf65eb52)
* [https://www.bitsioinc.com/install-splunk-ubuntu/](https://www.bitsioinc.com/install-splunk-ubuntu/)
* [https://www.13cubed.com/downloads/splunk\_manual.pdf](https://www.13cubed.com/downloads/splunk\_manual.pdf)
* [https://docs.splunk.com/Documentation/Splunk/9.0.4/Installation/StartSplunkforthefirsttime](https://docs.splunk.com/Documentation/Splunk/9.0.4/Installation/StartSplunkforthefirsttime)
* [https://docs.ansible.com/ansible/latest/playbook\_guide/playbooks\_privilege\_escalation.html](https://docs.ansible.com/ansible/latest/playbook\_guide/playbooks\_privilege\_escalation.html)
* [https://docs.splunk.com/Documentation/Splunk/9.0.4/Installation/RunSplunkasadifferentornon-rootuser](https://docs.splunk.com/Documentation/Splunk/9.0.4/Installation/RunSplunkasadifferentornon-rootuser)
* [https://www.inmotionhosting.com/support/security/install-splunk/](https://www.inmotionhosting.com/support/security/install-splunk/)
* [https://docs.splunk.com/Documentation/Splunk/9.0.4/Admin/User-seedconf](https://docs.splunk.com/Documentation/Splunk/9.0.4/Admin/User-seedconf)
* [https://dev.splunk.com/enterprise/tutorials/module\_getstarted/useeventgen/](https://dev.splunk.com/enterprise/tutorials/module\_getstarted/useeventgen/)
* [https://community.splunk.com/t5/Splunk-Enterprise-Security/How-to-install-splunk-app-through-Linux-terminal/m-p/421216](https://community.splunk.com/t5/Splunk-Enterprise-Security/How-to-install-splunk-app-through-Linux-terminal/m-p/421216)
* [https://docs.splunk.com/Documentation/AddOns/released/Linux/Install](https://docs.splunk.com/Documentation/AddOns/released/Linux/Install)
* [https://docs.splunk.com/Documentation/AddOns/released/UnixLinux/Install](https://docs.splunk.com/Documentation/AddOns/released/UnixLinux/Install)
* [https://community.splunk.com/t5/All-Apps-and-Add-ons/A-guide-to-installing-a-Splunk-TA-at-command-line-CentOS7-Splunk/m-p/325427/highlight/true](https://community.splunk.com/t5/All-Apps-and-Add-ons/A-guide-to-installing-a-Splunk-TA-at-command-line-CentOS7-Splunk/m-p/325427/highlight/true)
* [https://stackoverflow.com/questions/56367775/accepting-splunk-license-agreement-using-ansible-playbook](https://stackoverflow.com/questions/56367775/accepting-splunk-license-agreement-using-ansible-playbook)
* [https://www.oreilly.com/library/view/implementing-splunk-7/9781788836289/115bdebc-66fc-4336-a3c6-2968bf9674a3.xhtml#:\~:text=Each%20index%20occupies%20a%20set,%2Fvar%2Flib%2Fsplunk%20.\&text=If%20our%20Splunk%20installation%20lives,%2Flib%2Fsplunk%2Fdefaultdb%20.](https://www.oreilly.com/library/view/implementing-splunk-7/9781788836289/115bdebc-66fc-4336-a3c6-2968bf9674a3.xhtml)
* [https://community.splunk.com/t5/All-Apps-and-Add-ons/A-guide-to-installing-a-Splunk-TA-at-command-line-CentOS7-Splunk/m-p/325427/highlight/true](https://community.splunk.com/t5/All-Apps-and-Add-ons/A-guide-to-installing-a-Splunk-TA-at-command-line-CentOS7-Splunk/m-p/325427/highlight/true)
* [https://community.splunk.com/t5/Splunk-Enterprise-Security/How-to-install-splunk-app-through-Linux-terminal/m-p/421216](https://community.splunk.com/t5/Splunk-Enterprise-Security/How-to-install-splunk-app-through-Linux-terminal/m-p/421216)
* [https://www.tekstream.com/blog/create-splunk-indexes-and-hec-inputs-with-ansible/](https://www.tekstream.com/blog/create-splunk-indexes-and-hec-inputs-with-ansible/)
* [https://dev.splunk.com/enterprise/tutorials/module\_getstarted/useeventgen/](https://dev.splunk.com/enterprise/tutorials/module\_getstarted/useeventgen/)
* [https://docs.splunk.com/Documentation/Splunk/9.0.4/Forwarding/Enableareceiver](https://docs.splunk.com/Documentation/Splunk/9.0.4/Forwarding/Enableareceiver)
* [https://docs.splunk.com/Documentation/Forwarder/9.0.4/Forwarder/Installanixuniversalforwarder](https://docs.splunk.com/Documentation/Forwarder/9.0.4/Forwarder/Installanixuniversalforwarder)
* [https://docs.splunk.com/Documentation/Splunk/9.0.4/Admin/Inputsconf#MONITOR:](https://docs.splunk.com/Documentation/Splunk/9.0.4/Admin/Inputsconf#MONITOR:)
* [https://docs.splunk.com/Documentation/Splunk/9.0.4/Admin/Outputsconf](https://docs.splunk.com/Documentation/Splunk/9.0.4/Admin/Outputsconf)
* [https://docs.splunk.com/Documentation/Forwarder/9.0.4/Forwarder/Configureforwardingwithoutputs.conf](https://docs.splunk.com/Documentation/Forwarder/9.0.4/Forwarder/Configureforwardingwithoutputs.conf)
* [https://community.splunk.com/t5/Getting-Data-In/How-to-use-custom-index-for-Universal-Forwarder/m-p/65512](https://community.splunk.com/t5/Getting-Data-In/How-to-use-custom-index-for-Universal-Forwarder/m-p/65512)
* [https://docs.splunk.com/Documentation/Splunk/9.0.4/Installation/RunSplunkasadifferentornon-rootuser](https://docs.splunk.com/Documentation/Splunk/9.0.4/Installation/RunSplunkasadifferentornon-rootuser)
* [https://medium.com/@sweetdee360/making-my-way-through-splunk-bff7c1ccb1c1](https://medium.com/@sweetdee360/making-my-way-through-splunk-bff7c1ccb1c1)
* [https://docs.splunk.com/Documentation/Splunk/9.0.4/Admin/ConfigureSplunktostartatboottime#Enable\_boot-start\_as\_a\_non-root\_user](https://docs.splunk.com/Documentation/Splunk/9.0.4/Admin/ConfigureSplunktostartatboottime#Enable\_boot-start\_as\_a\_non-root\_user)

