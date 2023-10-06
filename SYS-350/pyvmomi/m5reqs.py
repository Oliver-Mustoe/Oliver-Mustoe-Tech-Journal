from os.path import realpath,dirname
from pyVmomi import vim
import opylib

# Get file path
scriptdirectory = dirname(realpath(__file__))

si = opylib.ConnectToVcenter(scriptdirectory)

#opylib.CreateClone(si,vmtemplatename="ubuntu.base.template",vmname="test1",vmfolder="TESTING",datacentername="SYS350",poweron=False,datastorename="datastore2-super10",esxiname="super10.oliver.local",linkedclone=False)
#opylib.CreateClone(si,vmtemplatename="ubuntu.base.template",vmname="test2",vmfolder="TESTING",datacentername="SYS350",poweron=False,datastorename="datastore2-super10",esxiname="super10.oliver.local",linkedclone=False)
#opylib.CreateClone(si,vmtemplatename="ubuntu.base.template",vmname="test3",vmfolder="TESTING",datacentername="SYS350",poweron=False,datastorename="datastore2-super10",esxiname="super10.oliver.local",linkedclone=False)

# vmtemplatename = opylib.SearchVcenter(si,[vim.VirtualMachine],"xubuntu2204.base2")
# print(vmtemplatename.snapshot.rootSnapshotList[0].snapshot)

#opylib.PowerOn(si,'xubuntu')

#opylib.DeleteVM(si,vmlist=['xubuntu2'])
#opylib.CreateVMFolder(si,"nottie","SYS350")
#opylib.CreateClone(si,vmtemplatename="pf.base",vmname="test3andfinal",vmfolder="nottie",datacentername="SYS350",poweron=False,datastorename="datastore2-super10",esxiname="super10.oliver.local",linkedclone=True)
opylib.DeleteVMFolder(si,foldername="nottie",datacentername="SYS350")