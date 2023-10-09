from os.path import realpath,dirname
from pyVmomi import vim
import opylib, argparse, json

def args():
    # Function to gather arguments
    arg_parser = argparse.ArgumentParser(
        prog="rtd",
        description="driver for SYS350 Milestone 5.1",
        formatter_class=argparse.RawTextHelpFormatter
    )

    arg_parser.add_argument(
        "-s","--searchvms", help="Search vcenter for vms by name and create a filtered list",
    )

    arg_parser.add_argument(
        "-ts","--takesnapshot",
        action='store_true',
        help="Whether or not to take snapshots of the searched VMs VMs (REQUIRES '-s')"
    )

    arg_parser.add_argument(
        "-rs","--restoresnapshot",
        action='store_true',
        help="Whether or not to revert to a snapshot of the searched VMS (REQUIRES '-s')"
    )

    arg_parser.add_argument(
        "-sd","--snapshotdescription",
        help="Description of the snapshot to take (REQUIRES '-ts')"
    )

    arg_parser.add_argument(
        "-sn","--snapshotname",
        help="Name of the snapshot to take (REQUIRES '-ts' or '-rs')"
    )

    arg_parser.add_argument(
        "-on","--poweron",
        action='store_true',
        help="Poweron virtual machines from seach (REQUIRES '-s')"
    )

    arg_parser.add_argument(
        "-off","--poweroff",
        action='store_true',
        help="Poweroff virtual machines from seach (REQUIRES '-s')"
    )

    arg_parser.add_argument(
        "-d","--deletevm",
        action='store_true',
        help="Delete virtual machines that match search (REQUIRES '-s')"
    )

    arg_parser.add_argument(
        "-dc","--disabledeletecheck",
        action='store_true',
        help="Disable the delete check for virtual machines that match search (REQUIRES '-s')"
    )

    arg_parser.add_argument(
        "-c","--clonevm",
        # Needs to be loaded with JSON as argparse doesn't do dictionaries natively
        type=json.loads,
        help="""Values of parameters to clone a VM - needs the following keys IN JSON FORMAT:
        'vmtemplate'     : (str) name of the vm you want to clone (can be template or regular VM)
        'vmname'         : (str) name of the vm you want to create
        'datacentername' : (str) name of the datacenter you want the vm in
        'datastorename'  : (str) name of the datastore you want the vm in
        'poweron'        : (bool) whether to power the vm on or not
        'esxiname'       : (str) name of the esxi you want the vm in (need this or a resource pool to put the VM on)
        'vmfolder'       : (str) where you want the VM to go - defaults to the vmFolder
        'resourcepool'   : (str) resource pool you want the VM on (need this or 'esxiname' to put it on the ESXI's default pool)
        'linkedclone'    : (bool) whether you want the VM to be a linked clone or not (wont work with templates)
EX: python3 m5driver.py -c '{"vmtemplate":"pf.base","vmname":"otest6","datacentername":"SYS350","datastorename":"datastore2-super10","poweron":false,"esxiname":"super10.oliver.local","vmfolder":"nottie","resourcepool":"","linkedclone":true}'
        """
    )

    parsed_args = arg_parser.parse_args()
    return parsed_args

if __name__ == "__main__":
    args = args()
    # Get file path
    scriptdirectory = dirname(realpath(__file__))

    # Connect to vcenter
    si = opylib.ConnectToVcenter(scriptdirectory)

    # See if a search is taking place
    if args.searchvms:
        vms = opylib.SearchVcenterWithPattern(si,[vim.VirtualMachine],args.searchvms)

    # For each VM in the search, do operation
        for vm in vms:
            if args.takesnapshot and not args.restoresnapshot:
                opylib.TakeSnapshot(si,vm,args.snapshotdescription,args.snapshotname)

            elif args.restoresnapshot and not args.takesnapshot:
                print(vm.name)
                opylib.RevertToSnapshot(si,vm,args.snapshotname)
            
            if args.poweron:
                opylib.PowerOn(si,vm)
            
            if args.poweroff:
                opylib.PowerOff(si,vm)
            
            if args.deletevm:
                if not args.disabledeletecheck:
                    print('-')
                    print(vm.name)
                    uinput = input("Do you want to delete the above VMs? [y/N]")
                else:
                    uinput = 'y'

                if uinput.lower() == 'y':
                    opylib.DeleteVM(si,vm)
                else:
                    continue

    elif args.clonevm:
        # Make VM with JSON inputted actions
        opylib.CreateClone(si,
                        args.clonevm['vmtemplate'],
                        args.clonevm['vmname'],
                        args.clonevm['datacentername'],
                        args.clonevm['datastorename'],
                        args.clonevm['poweron'],
                        args.clonevm['esxiname'],
                        args.clonevm['vmfolder'],
                        args.clonevm['resourcepool'],
                        args.clonevm['linkedclone'])