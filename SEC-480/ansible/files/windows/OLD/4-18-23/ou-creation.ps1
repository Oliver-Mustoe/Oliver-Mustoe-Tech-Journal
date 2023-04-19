import-module activedirectory

# get the the ous to create
$scriptpath = Split-Path $($myInvocation.MyCommand.Path) -Parent
$ou_full = Get-Content -Path "$scriptpath\ou.txt"

# foreach of the paths given in the ou file
foreach ($ou_path in $ou_full){
    # split the entire string by comma and make a blank array
    $path = $ou_path.Split(",")
    $root = @()

    # take the split paths, see if are apart of the domain name, seprate those into the array for the root
    foreach ($ou in $path){
        if ($ou -like "dc=*"){
            $root += $ou
        }
    }

    # get the length of the root and join it
    $rootlen = $root.Length
    $root = $root -join ","

    # create a new path without the root
    $path = $path | Select-Object -SkipLast $rootlen
    
    # reverse the path (order that it will have to be made in)
    [array]::Reverse($path)

    # foreach ou
    foreach ($ou in $path){
        # create the path that the out should exist at
        $tpath = "AD:\$ou,$root"
        Write-Output "[CREATING $tpath]"

        # test if the out exists, if it doesnt, create it
        if (!$(Test-Path -Path $tpath)){
            # in a variable to silence output
            $dir = mkdir $tpath
            
            # double check the ou exists
            if ($(Test-Path -Path $tpath)){
                Write-Output "[FOUND $tpath]"
                # update the root since the next ou is assumed to be created under the current $ou
                $root = "$ou,$root"
            }
            else {
                Write-Output "[$tpath NOT CREATED]"
            }
        }

        # if the out already exists, tell the user
        else {
            Write-Output "[FOUND $tpath]"
            # update the root since the next ou is assumed to be created under the current $ou
            $root = "$ou,$root"
        }
    }
}
# Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase 'DC=BLUE1,DC=LOCAL' | Format-Table DistinguishedName