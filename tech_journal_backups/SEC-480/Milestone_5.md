This page journals content related to NET/SEC/SYS-480 milestone 5.

**Table of contents**

1. [Pre-flight](#pre-flight)

2. [Requesting a license](#requesting-a-license)

3. [VSCode installation](#vscode-installation)



# Pre-flight

I noticed that my DHCP option for searching domain was incorrect, found this by checking awx’s /etc/resolv.conf and it was searching “dc1.oliver.local” meaning I couldnt `nslookup` anything. To correct this, I SSH’d into dc1 and used the following command:

```powershell
Set-DHCPServerv4OptionValue -ScopeID 10.0.17.0 -DnsDomain oliver.local -DnsServer 10.0.17.4 -Router 10.0.17.2
```

Then I rebooted awx, and it worked correctly now:

![image001](https://user-images.githubusercontent.com/71083461/218274129-f48981d5-13e0-4e31-a97d-b061a64f78ae.png)

# Requesting a license

Has I had pre-registered an account, all I had to do was navigate to [Software Licenses Repository](https://itacademy.vmware.com/catalog?pagename=Software-Licenses-Repository) and request a key for “VMware vSphere 8.x Enterprise Plus” and “VMware vCenter Server 8.x Standard”:  

![image003](https://user-images.githubusercontent.com/71083461/218274132-4358d9f8-5b04-448e-aec2-21a78d660047.png)

![image005](https://user-images.githubusercontent.com/71083461/218274134-e0ade5f8-0694-44ef-930e-ebbb465fdff3.png)



I would continue with the milestone and come back to this once I had a key/s.

I would soon receive a license key, then I would login to my vCenter > click on the MANAGE YOUR LICENSES that appears at the top:  

![image007](https://user-images.githubusercontent.com/71083461/218274136-8fc788fb-3d8f-44a9-9f87-a3b77d5ce029.png)

![image009](https://user-images.githubusercontent.com/71083461/218274138-fdda50ec-59d3-4ef8-8b64-9f4340bb0c92.png)

Then I clicked ADD > Added my key (from the sent email) > Named the license “480-ESXi” > Finished:  

![image011](https://user-images.githubusercontent.com/71083461/218274140-f73320f0-cac0-48cc-8780-9dfdef627ea8.png)



Then I went over to Assets (on the top row under Licenses header) > Went to HOSTS > Selected the asset “192.168.7.25” > Then ASSIGN LICENSE:  

![image013](https://user-images.githubusercontent.com/71083461/218274142-b6e21452-8c5c-4e49-a674-77638fff5161.png)



Then once I gained the vCenter license, I repeated the process to add the license with the name “480-vcenter”:  

![image015](https://user-images.githubusercontent.com/71083461/218274146-474c232e-b3c6-4881-90cc-d379a3672cba.png)



Then I went over to Assets (on the top row under Licenses header) > Went to VCENTER SERVER SYSTEMS > Selected the asset “vcenter.oliver.local” > Assigned the “480-vcenter”:  

![image017](https://user-images.githubusercontent.com/71083461/218274149-047d9399-cbc9-40bc-87ee-5cac955d9c78.png)

# VSCode installation

I installed VSCode with the command:

```bash
sudo snap install code --classic
```

I then setup my needed directory structure with the following command inside my Github installation (See [Milestone 4](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Milestone-4---VCenter-AD-Integration%2C-PowerCLI-and-Linked-Clones#github-setup)):

```bash
mkdir -p Modules/480-utils
```

![image019](https://user-images.githubusercontent.com/71083461/218274152-c111fde4-60f9-4ee1-a3b0-e026f9ef4c61.png)



Then I created a Module manifest in my 480-utils for my 480-utils.psm1 in **powershell** and created the needed psm file with the commands below:

```powershell
New-ModuleManifest -Path .\480-utils.psd1 -Author 'OliverMustoe' -CompanyName 'Champlain College' -RootModule '480-utils.psm1' -Description 'vsphere automation module for DevOps-480'
touch 480-utils.psm1
```

![image021](https://user-images.githubusercontent.com/71083461/218274154-d4a676e9-24e0-4ed0-92a8-779ef46c55b0.png)  

![image023](https://user-images.githubusercontent.com/71083461/218274157-8119dbc6-2b9b-4d1d-9395-d5db18f658cf.png)  



Then I opened up Visual studio code from the “SEC-480” directory:

```powershell
code .
```

![image025](https://user-images.githubusercontent.com/71083461/218274159-7a1eef46-7168-4363-8086-dab1de9c5f55.png)



Which opened Visual Studio Code:  

![image027](https://user-images.githubusercontent.com/71083461/218274163-65cb0504-1fd4-4d0d-9540-329cf0533ef0.png)



Inside Visual studio, I would navigate to the .psm file (Modules > 480-utils > 480-tils.psm1) and, when entering the file, would install the Powershell extension:  

![image029](https://user-images.githubusercontent.com/71083461/218274165-22227cc5-6bbd-405a-b806-30b9d25bfa5d.png)



I would populate psm file with a basic function called “480Banner”:  

```powershell
function 480Banner() {
    Write-Host "Hello SYS480-Devops"
}
```

Then, I would change my VSCode profile to point towards my Modules folder with the command:

```powershell
code $profile
```

![image031](https://user-images.githubusercontent.com/71083461/218274167-1d1d3503-25f5-41ae-be83-2f351286a4be.png)  

(Will prompt to open file, allow it)



I then entered the following into the profile to set the module path, `$env:PSModulePath`, to be equal to itself plus the path to the modules folder:

```powershell
$env:PSModulePath = $env:PSModulePath + ":/home/olivermustoe/Oliver-Mustoe-Tech-Journal/SEC-480/Modules"
```

![image033](https://user-images.githubusercontent.com/71083461/218274170-8f76094a-6ea6-4bbe-9f95-85a280248597.png)



After saving the file, CTRL+S, I would reboot my Visual studio code (opened same way as above)

This can be double checked like the following:

![image035](https://user-images.githubusercontent.com/71083461/218274172-ccb4e69d-c7f8-4c90-a14b-ed72806fc25c.png)



Then I imported my 480-utils module with the following command (`-Force` since I want it to always load/reload the module) and I can run the module by using the function name:

```powershell
Import-Module '480-utils' -Force
```

![image037](https://user-images.githubusercontent.com/71083461/218274175-cb22666f-7495-4eb3-9288-43387892a6c2.png)



I would then create a dedicated function for creating a connection with vcenter called “480Connect”, also added some additional text to my banner function (this would be used in the session before other functions were run below). Below is the new function:

```powershell
function 480Connect([string]$server) {
    # See if the global variable set by vCenter for a connection is set
    $connection = $Global:DefaultVIServer
    # If we are already connected...
    if ($connection){
        $msg = "Already connected to: {0}}" -f $connection
        Write-Host $msg -ForegroundColor Green
    }
    else {
        $connection = Connect-VIServer -Server $server
    }
}
```

![image039](https://user-images.githubusercontent.com/71083461/218274177-9a33ea4f-11b9-40e2-baa4-1ea1d4dd9bdf.png)



New banner (screenshot since the formatting gets messed up with a copy paste):

![image041](https://user-images.githubusercontent.com/71083461/218274179-1a69ac6a-a9db-4d0e-a75f-5cd05c78eaad.png)



Then, inside the SEC-480 directory, I created the files “480driver.ps1” and “480.json:

```powershell
touch 480driver.ps1
touch 480.json
```

![image043](https://user-images.githubusercontent.com/71083461/218274182-644ca40e-97f8-4f0d-97cd-99a684181ebd.png)



I would fill 480driver.ps1 with the following code:

```powershell
Import-Module '480-utils' -Force
# Call Banner Function
480Banner
```

Below shows the file in action:

![image045](https://user-images.githubusercontent.com/71083461/218274186-4dff93c5-0c65-443f-9332-6de8273af4c3.png)



I would file 480.json with the following:

```
{
    "vcenter_server": "vcenter.oliver.local"
}
```

![image047](https://user-images.githubusercontent.com/71083461/218274188-703e1ddb-97bc-47ff-a7e6-cea22bf95842.png)



I then created a function dedicated for getting a json config with “Get-480Config”:

```powershell
function Get-480Config([string]$config_path) {
    Write-Host "Reading $config_path"
    $conf=$null
    if(Test-Path $config_path){
        $conf= Get-Content -Path $config_path -Raw | ConvertFrom-Json
        $msg = "Using Configuration at {0}" -f $config_path
        Write-Host $msg -ForegroundColor Green
    }
    else{
        Write-Host "No configuration found at $config_path" -ForegroundColor Yellow
    }
    return $conf
}
```



Below shows a test of this function (once imported either through the import command listed above OR via 480driver.ps1, which runs that import command):

![image049](https://user-images.githubusercontent.com/71083461/218274191-44161572-c029-4b8f-8865-c15628dcd483.png)



I would then update my 480driver.ps1 with the following:

```powershell
Import-Module '480-utils' -Force
# Call Banner Function
480Banner
$conf=Get-480Config -config_path "/home/olivermustoe/Oliver-Mustoe-Tech-Journal/SEC-480/480.json"
480Connect -server $conf.vcenter_server
```

![image051](https://user-images.githubusercontent.com/71083461/218274193-179fa8f4-44c0-4dc0-831d-75ffe069f732.png)



Then I created a function to select VMs called “Select-VM” (in later testing, found that below could be simplified and integers with 2 numbers, such as 10, would create an error. Both of these are fixed/changed in the [480-utils.psm1](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/SEC-480/Modules/480-utils/480-utils.psm1)):  

```powershell
function Select-VM([string]$folder) {
    $selected_vm=$null
    try{
        $vms = Get-VM -Location $folder
        $index=1
        foreach($vm in $vms){
            Write-Host [$index] $vm.Name
            $index+=1
        }
        while($true){
            $pick_index = Read-Host "Which index number [x] do you wish to pick?"
            # 480-TODO need to deal with invalid index
            if($pick_index -le ($index - 1)) {
                $selected_vm=$vms[$pick_index - 1]
                break
            }
            else {
                Write-Host "ERROR: Please select an inbound index" -ForegroundColor Red
            }

        }
        Write-Host "You picked " $selected_vm.name
        #note this is a full on vm object that we can interact with
        return $selected_vm
    }

    catch{
        Write-Host "Invalid Folder: $folder" -ForegroundColor Red
    }
}
```



Example run:

![image053](https://user-images.githubusercontent.com/71083461/218274195-7b83feb3-2e9b-4715-abed-d1888a4bf6f0.png)



Then I updated 480.json again with the following:

```
{
    "vcenter_server": "vcenter.hermione.local",
    "vm_folder": "BASEVM"
}
```

![image055](https://user-images.githubusercontent.com/71083461/218274197-4ec126ae-53e2-46e9-8301-d747e4a1a476.png)



I would then update my 480driver.ps1 with the following:

```powershell
Import-Module '480-utils' -Force
# Call Banner Function
480Banner
$conf=Get-480Config -config_path "/home/olivermustoe/Oliver-Mustoe-Tech-Journal/SEC-480/480.json"
480Connect -server $conf.vcenter_server
Write-Host "Selecting your VM"
Select-VM -folder "BASEVM"
```

Test run below:

![image057](https://user-images.githubusercontent.com/71083461/218274199-4b820849-f0ca-40cd-9834-cd5727bd1cd8.png)



I would commit this code to my Github (had to use the `git config –global` command to set user.email and user.name.)

With this done, I would create functions to do the following in my [480-utils.psm1](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/SEC-480/Modules/480-utils/480-utils.psm1), gathering data only from prompts/a json config file:

1. Create a full clone
2. Create a linked clone
3. Change a network adapter
4. Power VM on

NOTE: Different module path profiles for Powershell and VSCode exist

---

Can't find something? Check in the [Backup Milestone 5](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-480/Milestone_5.md)
