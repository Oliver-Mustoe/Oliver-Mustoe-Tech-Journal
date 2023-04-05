#import-module activedirectory

# jinjia template the following, need to also make a loop going backwards and making the ous
#$ou_full = @("OU=Servers,OU=Computers,OU=blue1,DC=blue1,DC=local","ou=gamer2,ou=gamer1,dc=blue1,dc=local")
$scriptpath = Split-Path $($myInvocation.MyCommand.Path) -Parent
$ou_full = Get-Content -Path "$scriptpath\ou.txt"
#$ou_root = "dc=blue1,dc=local"

foreach ($ou_path in $ou_full){
    $path = $ou_path.Split(",")
    $root = @()
    #$root = "{0},{1}" -f $path[-2],$path[-1]
    #$path = $path | Select-Object -SkipLast 2
    # reverse it (order that it will have to be made in)
    #[array]::Reverse($path)

    foreach ($ou in $path){
        if ($ou -like "dc=*"){
            $root += $ou
        }
    }

    $rootlen = $root.Length
    $root = $root -join ","
    $path = $path | Select-Object -SkipLast $rootlen
    # reverse it (order that it will have to be made in)
    [array]::Reverse($path)

    Write-Output $path
    Write-Output $root

    # foreach ($ou in $path){
    #     $tpath = "AD:\$ou$root"
    #     if (!$(Test-Path -Path $tpath)){
    #         mkdir $tpath
    #         $root = "$ou$root"
    #     }
    # }
}
# Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase 'OU=BLUE1,DC=BLUE1,DC=LOCAL' | Format-Table Name