from os.path import realpath,dirname
from pyVmomi import vim
import opylib

# Get file path
scriptdirectory = dirname(realpath(__file__))

si = opylib.ConnectToVcenter(scriptdirectory)

# opylib.CreateClone(si,vmtemplatename="xubuntu2204.base2",vmname="xubuntu",vmfolder="TESTING",datacentername="SYS350",poweron=True,datastorename="datastore2-super10",esxiname="super10.oliver.local",linkedclone=True)
vmtemplatename = opylib.SearchVcenter(si,[vim.VirtualMachine],"xubuntu2204.base2")
print(vmtemplatename.snapshot.rootSnapshotList[0].snapshot)


