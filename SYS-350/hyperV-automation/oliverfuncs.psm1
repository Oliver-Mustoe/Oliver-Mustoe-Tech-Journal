function Get-VMSummary([string]$vm) {
    # Get basic information for the VM
    $vmBasicInformation = Get-VM -Name $vm | Select-Object -Property Name,State
    $networkInformation = Get-VMNetworkAdapter -VMName $vm | Select-Object SwitchName,IPAddresses

    # Get a custom object of VM information
    $vmInfo = [PSCustomObject]@{
        VMName = $vmBasicInformation.Name
        VMState = $vmBasicInformation.State
        VMSwitchs = $networkInformation.SwitchName
        VMIPAddresses = $networkInformation.IPAddresses
    }

    # Show the information
    $vmInfo | Format-List
}

function Get-AdvancedVMSummary([string]$vm) {
    # Get basic information for the VM
    $vmBasicInformation = Get-VM -Name $vm | Select-Object -Property Name,CPUUsage,VMId,State,MemoryAssigned,Uptime
    $networkInformation = Get-VMNetworkAdapter -VMName $vm | Select-Object SwitchName,IPAddresses,MacAddress
    
    # Also get the VHD path 
    $vhdPath = $vmBasicInformation.VMId | Get-VHD | Select-Object Path

    # Custom object with the needed attributes
    $vmInfo = [PSCustomObject]@{
        VMName = $vmBasicInformation.Name
        VMState = $vmBasicInformation.State
        VMCPUUsage = $vmBasicInformation.CPUUsage
        VMMemoryAssignedMB = $vmBasicInformation.MemoryAssigned / 1MB
        VMSwitch = $networkInformation.SwitchName
        VMIPAddresses = $networkInformation.IPAddresses
        VMMacAddress = $networkInformation.MacAddress
        VMVHDPath = $vhdPath.Path
        VMUptime = $vmBasicInformation.Uptime
    }

    # Give the output as a list
    $vmInfo | Format-List
}

function Set-VMPowerState([string]$vm,[switch]$on,[switch]$off) {
    if ($on) {
        Start-VM $vm
    }
    elseif ($off) {
        Stop-VM $vm
    }
    else {
        Write-Host "Nothing to do..."
    }
}

# https://www.unitrends.com/blog/how-to-use-powershell-to-assign-ram-in-hyper-v
function Set-VMAttributes([string]$vm,[int]$memorygb,[int]$cpu) {
    # Get the state of the VM
    $vmState = (Get-VM -Name $vm).State

    # Check to see if it is running, if so prompt the user
    if ($vmState -eq "Running"){
        $userResponse = Read-Host -Prompt "The host is currently running, shutdown now? [y/N]"

        if ($userResponse.ToLower() -eq 'y'){
            Stop-VM $vm
        }
        else {
            Write-Error -Exception "THE VM MUST BE STOPPED BEFORE SETTING ATTRIBUTES" -ErrorAction Stop
        }
    }

    # Check if user specified wanting to change memory in GB, if so change the memory
    if ($memorygb) {
        $memory = $memorygb * 1GB
        Set-VM $vm -MemoryStartupBytes $memory
    }
    
    # Check if user specified wanting to change cpu count, if so change the cpu count
    if ($cpu) {
        Set-VM $vm -ProcessorCount $cpu
    }
}

function New-VMFromTemplate([string]$configpath,[int]$count=1) {
    # Go through the count, starting at 1 (so it needs a "equal to" operator)
    for($i=1; $i -le $count; $i++){
        try {
            # Get the specified config
            $jsonConfig = Get-Content -Raw -Path $configpath | ConvertFrom-Json
            
            # Change VM named based on if count is specified (default is 1 VM)
            if($count -ge 2){
                $vmName = $jsonConfig.vmname + "0$i"
            }
            else {
                $vmName = $jsonConfig.vmname
            }
            # Get the needed paths of new VM and it's vhdx
            $rootVMDirectory = $jsonConfig.rootdirectory + "\" + $vmName
            $VMVHDXPath = $rootVMDirectory + "\" + $vmName + ".vhdx"
    
            # Convert memory and size into to gigabyte size
            $memory = $jsonConfig.memorygb * 1GB
            $size = $jsonConfig.sizegb * 1GB
    
            # Create the VM path
            mkdir -Path $rootVMDirectory -ErrorAction SilentlyContinue
            
            # If config specifies a linked clone
            if($jsonConfig.linkedclone){
                # Get the parent VM
                $parentVHDX = Get-VM -Name $jsonConfig.parent | Select-Object VMId | Get-VHD
    
                # Find the path to the parent vhdx, account for snapshots - assuming base vhdx is the parent
                if($parentVHDX.ParentPath){
                    $parentVHDXPath = $parentVHDX.ParentPath
                }
                else {
                    $parentVHDXPath = $parentVHDX.Path
                }
    
                # Create the differencing hard drive and the new vm with said hard drive
                New-VHD -ParentPath $parentVHDXPath -Path $VMVHDXPath -Differencing
                New-VM -Name $vmName -MemoryStartupBytes $memory -Path $rootVMDirectory -VHDPath $VMVHDXPath -Generation 2 -SwitchName $jsonConfig.defaultswitch
            }
            else{
                # If not a linked clone, assume creating a new VM
                New-VM -Name $vmName -MemoryStartupBytes $memory -Path $rootVMDirectory -NewVHDPath $VMVHDXPath -NewVHDSizeBytes $size -Generation 2 -SwitchName $jsonConfig.defaultswitch
            }            
            
            # Set the processor count
            Set-VMProcessor $vmName -Count $jsonConfig.cpucount
    
            # If secure boot is set to turn off, do so
            if ($jsonConfig.securebootoff){
                Set-VMFirmware -VMName $vmName -EnableSecureBoot Off
            }
            
            # If a DVD path is specified, set it
            if($jsonConfig.dvdpath){
                Add-VMDvdDrive -VMName $vmName -Path $jsonConfig.dvdpath
            }
    
            # If user wants to start vm after creation, do so
            if($jsonConfig.startvm){
                Start-VM $vmName
            }
        }
        catch {
            Write-Host "ERROR: $_" -ForegroundColor Red
        }
    }
}
function Remove-VMFull([string]$vmname,[switch]$force=$false) {
    # Get the path and the state of the VM
    $vm = Get-VM -Name $vmname
    $vmPath = $vm.Path
    $vmState = $vm.State

    # See if user wants to force or not
    if ($force) {
        Stop-VM $vm
        
        # Get and remove needed VMs in hyper-v (Out-Null to wait until VM is removed to actually remove the folder)
        Get-VM -Name $vmname | Remove-VM -Force | Out-Null

        # Remove the host directory aswell
        Remove-Item -Path (Get-Item ($vmPath)).parent.fullname -Recurse -Force
    }
    else {
        # Check if the VM is running, if so prompt the user to stop it
        if ($vmState -eq "Running"){
            $userResponse = Read-Host -Prompt "The host is currently running, shutdown now? [y/N]"
    
            if ($userResponse.ToLower() -eq 'y'){
                Stop-VM $vm
            }
            else {
                Write-Error -Exception "THE VM MUST BE STOPPED BEFORE REMOVAL" -ErrorAction Stop
            }
        }
        # Get and remove needed VMs in hyper-v
        Get-VM -Name $vmname | Remove-VM | Out-Null

        # Remove the host directory aswell
        Remove-Item -Path (Get-Item ($vmPath)).parent.fullname -Recurse
    }
    # https://stackoverflow.com/questions/18261658/trim-or-go-up-one-level-of-directory-tree-in-powershell-variable
}