function 480Banner() {
    $banner = "

    ░░██╗██╗░█████╗░░█████╗░░░██╗░░░██╗████████╗██╗██╗░░░░░░██████╗
    ░██╔╝██║██╔══██╗██╔══██╗░░██║░░░██║╚══██╔══╝██║██║░░░░░██╔════╝
    ██╔╝░██║╚█████╔╝██║░░██║░░██║░░░██║░░░██║░░░██║██║░░░░░╚█████╗░
    ███████║██╔══██╗██║░░██║░░██║░░░██║░░░██║░░░██║██║░░░░░░╚═══██╗
    ╚════██║╚█████╔╝╚█████╔╝░░╚██████╔╝░░░██║░░░██║███████╗██████╔╝
    ░░░░░╚═╝░╚════╝░░╚════╝░░░░╚═════╝░░░░╚═╝░░░╚═╝╚══════╝╚═════╝░ - Oliver Mustoe 2023
    "

    Write-Host $banner -ForegroundColor Blue
}

function 480Connect([string]$server) {
    # See if the global variable set by vCenter for a connection is set
    $connection = $Global:DefaultVIServer

    # If we are already connected...
    if ($connection){
        $msg = "[Already connected to: {0}]" -f $connection

        Write-Host $msg -ForegroundColor Green
    }
    else {
        $connection = Connect-VIServer -Server $server
    }
}

function Get-480Config([string]$config_path) {
    Write-Host "[Reading $config_path]"
    $conf=$null

    if(Test-Path $config_path){
        $conf= Get-Content -Path $config_path -Raw | ConvertFrom-Json
        $msg = "[Using Configuration at {0}]" -f $config_path
        Write-Host $msg -ForegroundColor Green
    }
    else{
        Write-Host "[No configuration found at $config_path]" -ForegroundColor Yellow
    }
    return $conf
}

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
                Write-Host "[ERROR: Please select an inbound index]" -ForegroundColor Red
            }
        }
        Write-Host "You picked" $selected_vm.name
        #note this is a full on vm object that we can interact with
        return $selected_vm
    }
    catch{
        Write-Host "[Invalid Folder: $folder]" -ForegroundColor Red
    }
}


function Select-Folder() {
    $selected_folder=$null

    try{
        $folders = Get-Folder
        $index=1
        foreach($folder in $folders){
            Write-Host [$index] $folder.Name
            $index+=1
        }
        while($true){
            $pick_index = Read-Host "Which index number [x] do you wish to pick?"
            # 480-TODO need to deal with invalid index
            if($pick_index -le ($index - 1)) {
                $selected_folder=$folders[$pick_index - 1]
                break
            }
            else {
                Write-Host "[ERROR: Please select an inbound index]" -ForegroundColor Red
            }
        }
        Write-Host "You picked" $selected_folder.name
        #note this is a full on vm object that we can interact with
        return $selected_folder
    }
    catch{
        Write-Host "[Invalid Folder: $folder]" -ForegroundColor Red
    }
}


# Function to change network adapter
# https://vdc-repo.vmware.com/vmwb-repository/dcr-public/6fb85470-f6ca-4341-858d-12ffd94d975e/4bee17f3-579b-474e-b51c-898e38cc0abb/doc/Get-VirtualNetwork.html
# https://developer.vmware.com/docs/powercli/latest/vmware.vimautomation.core/commands/get-networkadapter/#VirtualDeviceGetter

function Switch-VMNetworkAdapter([string]$vm) {
    try{
        # Go through all adapters on vm and ask user to select 1
        Write-Host "Which network adapter would you like to change?"
        $adapters = Get-NetworkAdapter -VM $vm
        $index=1
        foreach($adapter in $adapters){
            Write-Host ("[$index] {0}/{1}" -f $adapter.Name,$adapter.NetworkName)
            $index+=1
        }
        while($true){
            $pick_index = Read-Host "Which index number [x] do you wish to pick?"
            if($pick_index -le ($index - 1)) {
                $selected_adapter=$adapters[$pick_index - 1]
                break
            }
            else {
                Write-Host "[ERROR: Please select an inbound index]" -ForegroundColor Red
            }
        }
        Write-Host "You selected",$selected_adapter.Name,$selected_adapter.NetworkName -ForegroundColor Green
        #note this is a full on vm object that we can interact with
        
        # Go through all available adapters and ask the user to select 1 to change it to
        Write-Host "Which network would you like to switch",$adapter.Name,"to?"
        $ava_adapters = Get-VirtualNetwork
        $index=1
        foreach($ava_adapter in $ava_adapters){
            Write-Host ("[$index] {0}" -f $ava_adapter)
            $index+=1
        }
        while($true){
            $pick_index = Read-Host "Which index number [x] do you wish to pick?"
            if($pick_index -le ($index - 1)) {
                $selected_ava_adapter=$ava_adapters[$pick_index - 1]
                break
            }
            else {
                Write-Host "[ERROR: Please select an inbound index]" -ForegroundColor Red
            }
        }
        Write-Host "You selected",$ava_selected_adapter -ForegroundColor Green

        Write-Host ("[Setting {0} to {1}]" -f $selected_adapter.Name,$selected_ava_adapter) -ForegroundColor Green
        Get-VM -Name $vm | Get-NetworkAdapter -Name $selected_adapter.Name | Set-NetworkAdapter -NetworkName $selected_ava_adapter

    }
    catch{
        Write-Host "[Invalid VM: $vm]" -ForegroundColor Red
    }
}


# Function to power VM on
# https://williamlam.com/2017/04/how-to-determine-when-a-virtual-machine-is-ready-for-additional-operations.html
# https://vdc-repo.vmware.com/vmwb-repository/dcr-public/f2319b2a-6378-4635-a1cd-90b14949b62a/0ac4f829-f79b-40a6-ac10-d22ec76937ec/doc/Start-VM.html
function PowerCycle([switch]$on,[switch]$off,[string]$vm) {
    if($vm -eq ""){
        Write-Error "VM NAME '$vm' IS NOT VALID"
    }
    else {
        if ($on) {
            Start-VM -VM $vm -Confirm:$true
        }
        elseif ($off) {
            Stop-VM -VM $vm -Confirm:$true
        }
        else {
            Write-Error "Please select a power state, either '-on' or '-off'"
        }
    }
    
}

# Function to create clone
# https://developer.vmware.com/docs/powercli/latest/vmware.vimautomation.core/commands/connect-viserver/#Default
# https://www.gngrninja.com/script-ninja/2016/6/5/powershell-getting-started-part-11-error-handling
function Deploy-Clone([switch]$LinkedClone=$false,[switch]$FullClone=$false,[string]$VMName = "",[string]$CloneVMName = "",[string]$defaultJSON = "") {
    # Determine if clone type is set
    while($true){
        if($LinkedClone){
            Write-Host "[Linked clone selected, skipping selection]" -ForegroundColor Green
            break
        }
        elseif($FullClone){
            Write-Host "[Full clone selected, skipping selection]" -ForegroundColor Green
            break
        }
        else {
            $clone_choice = Read-Host -Prompt "Will you be creating a [F]ull clone or a [L]inked clone"
                if($clone_choice.ToLower() -eq "l"){
                    $LinkedClone=$true
                }
                elseif($clone_choice.ToLower() -eq "f") {
                    $FullClone=$true
                }
        }
    }
    
    # Find the path of the json file
    if ($defaultJSON -eq "") {
        $defaultJSON = Read-Host -Prompt "Please enter the path for the default JSON config"
        $conf = Get-480Config -config_path $defaultJSON
    }
    else {
        $conf = Get-480Config -config_path $defaultJSON
    }

    # Connect to Vcenter
    480Connect -server $conf.vcenter_server

    ### Find the VM name, clone name, and the folder of the VM
    try{
        # If VM name is NOT set then...
        if ($VMName -eq "") {
            # Decide whether to select a folder interactively or use the default
            $cfolder = Read-Host -Prompt ('Is the VM you wish to clone in the default folder "{0}" [Y/n]?' -f $conf.default_folder)
            if ($cfolder.ToLower() -eq "n"){
                $folder = Select-Folder
            }
            else{
                Write-Host "Using default" $conf.default_folder -ForegroundColor Green
                $folder = $conf.default_folder
            }
            # Display all of the VMs, prompt user to select one by name
            Write-Host "Please select a VM to create a clone of:"
            $VMName=Select-VM -folder $folder
        }
        else{
            # Else skip
            Write-Host "[VM name '$VMName' chosen, skipping selection]" -ForegroundColor Green
        }

        # If VM clone name is NOT set then...
        if ($CloneVMName -eq "") {
            $CloneVMName=Read-Host -Prompt "Please enter the name for the new clone"
        }
        else{
            # Else skip
            Write-Host "[VM clone name '$CloneVMName' chosen, skipping selection]" -ForegroundColor Green
        }
    }
    catch{
        # https://stackoverflow.com/questions/17226718/how-to-get-the-line-number-of-error-in-powershell
        $e=$_.Exception.Message
        $line=$_.InvocationInfo.ScriptLineNumber
        Write-Error "$e at line $line"
        break
    }
    ###

    ### Create clone if it does not exist
    # See if Clone exists
    $vmcheck = Get-VM -Name $CloneVMName -ErrorAction SilentlyContinue

    # If it does...
    if($vmcheck){
        # Tell that it is found
        Write-Host "Found $CloneVMName" -ForegroundColor Yellow
    }
    else {
        # Else...
        try{
            ### Get the VM, Snapshot, VMHost, Datastore
            $vm = Get-VM -Name $VMName -ErrorAction Stop
            #
            if ((Read-Host -Prompt ('Do you wish to use the default datastore "{0}" [Y/n]?' -f $conf.default_datastore)).ToLower() -eq "n"){
                $ds_selection = Read-Host -Prompt "Please enter a datastore"
            }
            else{
                Write-Host "Using default" $conf.default_datastore -ForegroundColor Green
                $ds_selection = $conf.default_datastore
            }
            $ds = Get-DataStore -Name $ds_selection -ErrorAction Stop
            #
            if ((Read-Host -Prompt ('Do you wish to use the default snapshot "{0}" [Y/n]?' -f $conf.default_snapshot)).ToLower() -eq "n"){
                $snapshot_selection = Read-Host -Prompt "Please enter a snapshot name"
            }
            else{
                Write-Host "Using default" $conf.default_snapshot -ForegroundColor Green
                $snapshot_selection = $conf.default_snapshot
            }
            $snapshot = Get-Snapshot -VM $vm -Name $snapshot_selection -ErrorAction Stop
            #
            if ((Read-Host -Prompt ('Do you wish to use the default esxi server "{0}" [Y/n]?' -f $conf.esxi_server)).ToLower() -eq "n"){
                $vmhost_selection = Read-Host -Prompt "Please enter a esxi server name"
            }
            else{
                Write-Host "Using default" $conf.esxi_server -ForegroundColor Green
                $vmhost_selection = $conf.esxi_server
            }
            $vmhost = Get-VMHost -Name $vmhost_selection -ErrorAction Stop
            ###

            Write-Host "[Creating $CloneVMName]" -ForegroundColor Green

            # Determine if linked clone or full clone, execute accordingly

            if($LinkedClone){
                # Create a new linked clone
                $linkedvm = New-VM -LinkedClone -Name $CloneVMName -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
            }
            elseif ($FullClone) {
                $lclone = “{0}.linked” -f $vm.name

                Write-Host "[Creating $lclone]" -ForegroundColor Green
                # Create a new linked clone
                $linkedvm = New-VM -LinkedClone -Name $lclone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds

                Write-Host "[Creating $CloneVMName from $lclone]" -ForegroundColor Green
                # Create a new VM
                $newvm = New-VM -Name $CloneVMName -VM $linkedvm -VMHost $vmhost -Datastore $ds

                Write-Host "[Creating Base snapshot of $lclone]" -ForegroundColor Green
                # Make a new Base snapshot
                $newvm | New-Snapshot -Name $conf.default_snapshot

                Write-Host "[Removing $lclone]" -ForegroundColor Green
                # Remove the interim linked clone
                $linkedvm | Remove-VM -Confirm:$false
            }

        }
        catch{
            # https://stackoverflow.com/questions/17226718/how-to-get-the-line-number-of-error-in-powershell
            $e=$_.Exception.Message
            $line=$_.InvocationInfo.ScriptLineNumber
            Write-Error "$e at line $line"
            break
        }
        ###

        ### After creation tasks
        # Double check the VM was created
        $vmcheck = Get-VM -Name $CloneVMName -ErrorAction SilentlyContinue

        if($vmcheck){
            Write-Host "[Found $CloneVMName]" -ForegroundColor Green
            # Check if the user wants to change any adapters, if they do call switch adapter function, if not, then finish.
            if ((Read-Host -Prompt ('Do you wish to change {0}s adapters? [y/N]?' -f $linkedvm.Name)).ToLower() -eq "y"){
                while($true){
                    # Change adapter until user issues anything else besides y
                    Switch-VMNetworkAdapter -vm $linkedvm
                
                    if((Read-Host -Prompt "Do you wish to change another adapter? [y/N]").ToLower() -ne "y"){
                        break
                    }
                }
            }
        }
        else {
            Write-Host "[Didnt find $CloneVMName]" -ForegroundColor Red
        }

        Write-Host "[DONE]"
    }
}
        ###

#Planned functions: Expand folders (being able to make, select folders, also placing something in deploy clone so you can place a VM inside a folder)