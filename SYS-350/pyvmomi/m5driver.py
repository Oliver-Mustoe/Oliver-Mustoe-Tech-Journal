from os.path import realpath,dirname
from pyVmomi import vim
import opylib, argparse



def args():
    arg_parser = argparse.ArgumentParser(
        prog="rtd",
        description="driver for SYS350 Milestone 5.1"
    )

    arg_parser.add_argument(
        "-s","--searchvms",
        help="Search vcenter for vms by name and create a filtered list",
        required=True
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
        help="Name of the snapshot to take (REQUIRES '--ts' or '--rs' BUT NOT BOTH)"
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
    vms = opylib.SearchVcenterWithPattern(si,[vim.VirtualMachine],args.searchvms)

    for vm in vms:
        if args.takesnapshot and not args.restoresnapshot:
            opylib.TakeSnapshot(si,vm,args.snapshotdescription,args.snapshotname)

        if args.restoresnapshot and not args.takesnapshot:
            opylib.RevertToSnapshot(si,vm,args.snapshotname)