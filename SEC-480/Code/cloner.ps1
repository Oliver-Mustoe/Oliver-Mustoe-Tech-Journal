function main {
    $vcenter=”vcenter.oliver.local”
    
    Connect-VIServer -Server $vcenter -Credential (Get-Credential -Message "Please enter credentials to access $vcenter")

    # Display all of the VMs, prompt user to select one by name, also get the new VM name
    Get-VM
    $vmName=Read-Host -Prompt "Please enter a valid VM name"
    $newVMName=Read-Host -Prompt "Please enter the name for the new Base VM"

    # Get the VM, Snapshot, VMHost, Datastore (just going to program 1 for now), and the linked name
    $vm = Get-VM -Name $vmName
    $snapshot = Get-Snapshot -VM $vm -Name "Base"
    $vmhost=Get-VMHost -Name "192.168.7.25"
    $ds = Get-DataStore -Name “datastore1-super15”
    $linkedClone = “{0}.linked” -f $vm.name

    # Create a new linked clone
    $linkedvm = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds

    # Create a new VM
    $newvm = New-VM -Name $newVMName -VM $linkedvm -VMHost $vmhost -Datastore $ds

    # Make a new Base snapshot
    $newvm | New-Snapshot -Name “Base”

    # Remove the interim linked clone
    $linkedvm | Remove-VM
}

main