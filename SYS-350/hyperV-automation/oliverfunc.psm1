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

function Copy-VM {
    
}

# https://www.unitrends.com/blog/how-to-use-powershell-to-assign-ram-in-hyper-v
function Set-VMAttributes([string]$vm,[string]$memory,[int]$cpu) {
    
}

# Will need to find a root directory
function Remove-VMFull {
    
}