function Get-VMSummary([string]$vm) {
    # Get basic information for the VM
    $vmBasicInformation = Get-VM -Name $vm | Select-Object -Property Name,State
    $networkInformation = Get-VMNetworkAdapter -VMName $vm | Select-Object SwitchName,IPAddresses

    # Get a custome object of VM information
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
        VMMemoryAssigned = $vmBasicInformation.MemoryAssigned
        VMSwitch = $networkInformation.SwitchName
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

function New-VMFromTemplate([string]$configpath,[int]$count=1) {
    for($i=1; $i -le $count; $i++){
        Write-Host $num
        try {
            # Get the specified config
            $jsonConfig = Get-Content -Raw -Path $configpath | ConvertFrom-Json
            
            # Change VM named based on if count is specified
            if($count -ge 2){
                $vmName = $jsonConfig.vmname + "0$i"
            }
            else {
                $vmName = $jsonConfig.vmname
            }
            # Get the needed paths
            $rootVMDirectory = $jsonConfig.rootdirectory + "\" + $vmName
            $VMVHDXPath = $rootVMDirectory + "\" + $vmName + ".vhdx"
    
            # Convert into to byte size
            $memory = $jsonConfig.memorygb * 1GB
            $size = $jsonConfig.sizegb * 1GB
    
            # Create the path
            mkdir -Path $rootVMDirectory -ErrorAction SilentlyContinue
    
            if($jsonConfig.linkedclone){
                $parentVHDX = Get-VM -Name $jsonConfig.parent | Select-Object VMId | Get-VHD
    
                # Account for snapshots - assuming base vhdx is the parent
                if($parentVHDX.ParentPath){
                    $parentVHDXPath = $parentVHDX.ParentPath
                }
                else {
                    $parentVHDXPath = $parentVHDX.Path
                }
    
                # Write-Host $parentVHDXPath
                # Create the differencing hard drive and the new vm with said hard drive
                New-VHD -ParentPath $parentVHDXPath -Path $VMVHDXPath -Differencing
                New-VM -Name $vmName -MemoryStartupBytes $memory -Path $rootVMDirectory -VHDPath $VMVHDXPath -Generation 2 -SwitchName $jsonConfig.defaultswitch
            }
            else{
                # If not a linked clone, assume creating a new VM
                New-VM -Name $vmName -MemoryStartupBytes $memory -Path $rootVMDirectory -NewVHDPath $VMVHDXPath -NewVHDSizeBytes $size -Generation 2 -SwitchName $jsonConfig.defaultswitch
            }
            # Create the VM with parameters from JSON (setting up default VM with a CPU count)
            # New-VM -Name $jsonConfig.vmname -MemoryStartupBytes $memory -Path $rootVMDirectory -NewVHDPath $VMVHDXPath -NewVHDSizeBytes $size -Generation 2 -SwitchName $jsonConfig.defaultswitch
            
            
            Set-VMProcessor $vmName -Count $jsonConfig.cpucount
    
            # If secure boot is set to turn off, do so
            if ($jsonConfig.securebootoff){
                Set-VMFirmware -VMName $vmName -EnableSecureBoot Off
            }
            
            # If a DVD path is specified, set it
            if($jsonConfig.dvdpath){
                Write-Host "1"
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

# https://www.unitrends.com/blog/how-to-use-powershell-to-assign-ram-in-hyper-v
function Set-VMAttributes([string]$vm,[string]$memory,[int]$cpu) {
    
}

# Will need to find a root directory
function Remove-VMFull([string]$vmname,[switch]$force=$false) {
    $vmPath = (Get-VM -Name $vmname).Path

    # See if user wants to force or not
    if ($force) {
        # Get and remove needed VMs in hyper-v (Out-Null to wait until VM is removed to actually remove the folder)
        Get-VM -Name $vmname | Remove-VM -Force | Out-Null

        # Remove the host directory aswell
         Remove-Item -Path (Get-Item ($vmPath)).parent.fullname -Recurse -Force
    }
    else {
        # Get and remove needed VMs in hyper-v
        Get-VM -Name $vmname | Remove-VM | Out-Null

        # Remove the host directory aswell
         Remove-Item -Path (Get-Item ($vmPath)).parent.fullname -Recurse
    }
    # https://stackoverflow.com/questions/18261658/trim-or-go-up-one-level-of-directory-tree-in-powershell-variable
}