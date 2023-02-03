param(
    [Parameter(HelpMessage="Name of VM on Server to clone")]
    [string]$VMName = "",

    [Parameter(HelpMessage="Name for the new Base VM clone")]
    [string]$CloneVMName = ""
)

$vcenter=”vcenter.oliver.local”

$viConnect = Connect-VIServer -Server $vcenter -Credential (Get-Credential -Message "Please enter credentials to access $vcenter")

# If one or none of the parameters is set then...
if ($VMName -eq "" -or $CloneVMName -eq "") {
    # Display all of the VMs, prompt user to select one by name, also get the new VM name
    Get-VM
    $VMName=Read-Host -Prompt "Please enter a the name of the VM to clone"
    $CloneVMName=Read-Host -Prompt "Please enter the name for the new Base VM clone"
}

# Get the VM, Snapshot, VMHost, Datastore (just going to program 1 for now), and the linked name
$vm = Get-VM -Name $VMName -Server $viConnect
$snapshot = Get-Snapshot -VM $vm -Name "Base" -Server $viConnect
$vmhost=Get-VMHost -Name "192.168.7.25" -Server $viConnect
$ds = Get-DataStore -Name “datastore1-super15” -Server $viConnect
$linkedClone = “{0}.linked” -f $vm.name

# Create a new linked clone
$linkedvm = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds -Server $viConnect

# Create a new VM
$newvm = New-VM -Name $CloneVMName -VM $linkedvm -VMHost $vmhost -Datastore $ds -Server $viConnect

# Make a new Base snapshot
$newvm | New-Snapshot -Name “Base” -Server $viConnect

# Remove the interim linked clone
$linkedvm | Remove-VM -Confirm:$false -Server $viConnect