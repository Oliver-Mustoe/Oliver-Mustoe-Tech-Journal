param(
    [Parameter(HelpMessage="Name of VM on Server to clone")]
    [string]$VMName = "",

    [Parameter(HelpMessage="Name for the linked clone")]
    [string]$CloneVMName = "",

    [Parameter(HelpMessage="Name for the linked clone")]
    [string]$defaultJSON = ""
)

# Find the path of the script where the default.json file is expected to be, CHANGE THE PATH FOR NON-480 USE
# $default=Get-Content ~\Oliver-Mustoe-Tech-Journal\SEC-480\Code\defaults.json -Raw | ConvertFrom-Json

$default=Get-Content ~\Oliver-Mustoe-Tech-Journal\SEC-480\Code\defaults.json -Raw | ConvertFrom-Json

# Set this way for prompt formatting
$vcenter = $default.vcenter
$adapter = $default.adapter

# Connect to the server
$viConnect = Connect-VIServer -Server $vcenter -Credential (Get-Credential -Message "Please enter credentials to access $vcenter")

# If one or none of the parameters is set then...
if ($VMName -eq "" -or $CloneVMName -eq "" -or $defaultJSON -eq "") {
    # Display all of the VMs, prompt user to select one by name, also get the linked VM name
    Get-VM
    $VMName=Read-Host -Prompt "Please enter a the name of the VM to clone"
    $CloneVMName=Read-Host -Prompt "Please enter the name for the new linked clone"
    $defaultJSON = Read-Host -Prompt "Please enter the path for the default JSON config"
}

# Get the VM, Snapshot, VMHost, Datastore
$vm = Get-VM -Name $VMName -Server $viConnect
$snapshot = Get-Snapshot -VM $vm -Name "Base" -Server $viConnect
$vmhost=Get-VMHost -Name $default.host -Server $viConnect
$ds = Get-DataStore -Name $default.datastore -Server $viConnect

Write-Host "[Creating $CloneVMName]" -ForegroundColor Green
# Create a new linked clone
$linkedvm = New-VM -LinkedClone -Name $CloneVMName -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds -Server $viConnect

# Set network adapter properly
Write-Host "[Setting $CloneVMName network adapter to $adapter]" -ForegroundColor Green
$linkedvm | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $adapter -Confirm:$false

Write-Host "[DONE]" -ForegroundColor Green