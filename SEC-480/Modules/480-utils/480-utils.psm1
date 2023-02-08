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
        $msg = "Already connected to: {0}" -f $connection

        Write-Host $msg -ForegroundColor Green
    }
    else {
        $connection = Connect-VIServer -Server $server
    }
}

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


# Function to create linked clone

# Function to create full clone

# Function to change network adapter
# https://vdc-repo.vmware.com/vmwb-repository/dcr-public/6fb85470-f6ca-4341-858d-12ffd94d975e/4bee17f3-579b-474e-b51c-898e38cc0abb/doc/Get-VirtualNetwork.html
# https://developer.vmware.com/docs/powercli/latest/vmware.vimautomation.core/commands/get-networkadapter/#VirtualDeviceGetter

# Function to power VM on
# https://williamlam.com/2017/04/how-to-determine-when-a-virtual-machine-is-ready-for-additional-operations.html
# https://vdc-repo.vmware.com/vmwb-repository/dcr-public/f2319b2a-6378-4635-a1cd-90b14949b62a/0ac4f829-f79b-40a6-ac10-d22ec76937ec/doc/Start-VM.html
