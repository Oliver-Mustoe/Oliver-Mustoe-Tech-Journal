from os.path import realpath,dirname
from pyVmomi import vim
import opylib
# TODO: Add some more functions
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
# opylib.CreateVMFolder(si,foldername="fottie",datacentername="SYS350",parentfoldername="nottie")
#opylib.CreateClone(si,vmtemplatename="pf.base",vmname="test3andfinal",vmfolder="nottie",datacentername="SYS350",poweron=False,datastorename="datastore2-super10",esxiname="super10.oliver.local",linkedclone=True)
# opylib.TakeSnapshot(si,'test3andfinal',"Base")
# opylib.DeleteVMFolder(si,foldername="nottie",datacentername="SYS350")
# opylib.CreateVMFolder(si,"nottie","SYS350")
#t1 = opylib.CreateClone(si,vmtemplatename="pf.base",vmname="test1",datacentername="SYS350",poweron=False,datastorename="datastore2-super10",esxiname="super10.oliver.local",linkedclone=True)
#t2 = opylib.CreateClone(si,vmtemplatename="pf.base",vmname="test2",vmfolder='nottie',datacentername="SYS350",poweron=False,datastorename="datastore2-super10",esxiname="super10.oliver.local",linkedclone=True)
# print(t1)
# print(t2)
# opylib.CreateClone(si,vmtemplatename="pf.base",vmname="otest1",vmfolder='nottie',datacentername="SYS350",poweron=False,datastorename="datastore2-super10",esxiname="super10.oliver.local",linkedclone=True)
# opylib.CreateClone(si,vmtemplatename="pf.base",vmname="otest2",vmfolder='nottie',datacentername="SYS350",poweron=False,datastorename="datastore2-super10",esxiname="super10.oliver.local",linkedclone=True)
opylib.CreateClone(si,vmtemplatename="pf.base",vmname="otest3",vmfolder='nottie',datacentername="SYS350",poweron=False,datastorename="datastore2-super10",esxiname="super10.oliver.local",linkedclone=False)
#opylib.TakeSnapshot(si,'test3andfinal',"Base")
# opylib.DeleteVM(si,vmtodelete='test3andfinal')

#opylib.CreateVMFolder(si,'gottie',"SYS350",'nottie')
#opylib.CreateVMFolder(si,'gottie',"SYS350")
# opylib.DeleteVMFolder(si,'gottie',"SYS350")