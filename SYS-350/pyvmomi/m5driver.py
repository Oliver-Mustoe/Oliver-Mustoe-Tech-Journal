from os.path import realpath,dirname
from pyVmomi import vim
import opylib, argparse, json

def args():
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
        help="Whether or not to take snapshots of VMs"
    )

    arg_parser.add_argument(
        "-rs","--restoresnapshot",
        action='store_true',
        help="Whether or not to revert to a snapshot"
    )

    arg_parser.add_argument(
        "-sd","--snapshotdescription",
        help="Description of the snapshot to take (REQUIRES '--ts')"
    )

    arg_parser.add_argument(
        "-sn","--snapshotname",
        help="Name of the snapshot to take (REQUIRES '--ts' or '--rs')"
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

def takesnapshot(si,snapshotname):
    opylib.TakeSnapshot

if __name__ == "__main__":
    args = args()
    # Get file path
    scriptdirectory = dirname(realpath(__file__))

    si = opylib.ConnectToVcenter(scriptdirectory)

    if args.takesnapshot and args.searchvms or args.restoresnapshot and args.searchvms:
        # possible have vms for operations that support that (everything except vm creation and deletion) then only have a single search for those operations?
        vms = opylib.SearchVcenterWithPattern(si,[vim.VirtualMachine],args.searchvms)

        for vm in vms:
            if args.takesnapshot and not args.restoresnapshot:
                opylib.TakeSnapshot(si,vm,args.snapshotdescription,args.snapshotname)

            if args.restoresnapshot and not args.takesnapshot:
                opylib.RevertToSnapshot(si,vm,args.snapshotname)

    elif args.clonevm:
        print(args.clonevm)
        # Since cloning only supports 1 vm - only search for exact matches
        if args.clonevm['vmfolder']:
            parentfolder = opylib.SearchVcenter(si,[vim.Folder],args.clonevm['vmfolder'])
            vm = opylib.SearchVcenter(si,[vim.VirtualMachine],args.clonevm['vmname'],container=parentfolder,error=False)
        else:
            vm = opylib.SearchVcenter(si,[vim.VirtualMachine],args.clonevm['vmname'],error=False)

        # If the search doesnt find anything, then make VM
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