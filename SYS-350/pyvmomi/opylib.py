import getpass, ssl, json, pyVmomi
from pyVmomi import vim
from pyVim.connect import SmartConnect
from datetime import datetime

__author__ = "Oliver Mustoe | SYS-350"

def ConnectToVcenter(path=str):
    # Grab a password
    passw = getpass.getpass()
    
    # Setup ssl
    s=ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    s.verify_mode=ssl.CERT_NONE

    # Open the uservars file
    with open(f"{path}/vars.json","r") as v:
        uservars = json.loads(v.read())

    # Connect to vCenter and return a connection object
    si=SmartConnect(host=uservars["vcenter"], user=uservars["username"], pwd=passw, sslContext=s)
    return si

def SearchVcenter(si, vim_type, name, container=None, recursive=True, error=True):
    # Modified version of https://github.com/vmware/pyvmomi-community-samples/blob/7020598713aa440c70816edae89f96a0fe742be8/samples/tools/pchelper.py#L103
    # Returns a singular vim.Virtualmachine object

    # Get a content view of vCenter
    content = si.RetrieveContent()

    # If no folder is specified then set it to the root folder
    if container is None:
        container = content.rootFolder

    # Create a container view of the vcenter where you are by default starting from the root folder and getting only objects of the vim_type but recursively
    containerview = content.viewManager.CreateContainerView(container, vim_type, recursive)

    obj = None
    # Go through this new container view and check each object reference to see if it matchs the name specified - if it does set the "obj" variable to that
    for managed_obj_ref in containerview.view:
        if managed_obj_ref.name == name:
            obj = managed_obj_ref
            break

    # Check if the name was found, if not raise an error
    if not obj and error is True:
        raise RuntimeError(f"{name} not found!")
    return obj


def SearchVcenterWithPattern(si, vim_type, name, container=None, recursive=True, error=True):
    # Modified version of https://github.com/vmware/pyvmomi-community-samples/blob/7020598713aa440c70816edae89f96a0fe742be8/samples/tools/pchelper.py#L103
    # Returns a list of vms matching a certain pattern

    # Get a content view of vCenter
    content = si.RetrieveContent()

    # If no folder is specified then set it to the root folder
    if container is None:
        container = content.rootFolder

    # Create a container view of the vcenter where you are by default starting from the root folder and getting only objects of the vim_type but recursively
    containerview = content.viewManager.CreateContainerView(container, vim_type, recursive)

    # Go through this new container view and check if the name is in the object reference - if it does set the "obj" variable to that
    obj = [managed_obj_ref for managed_obj_ref in containerview.view if name in managed_obj_ref.name]

    # Check if the name was found, if not raise an error
    if not obj and error is True:
        raise RuntimeError(f"{name} not found!")
    return obj

def AllVcenter(si, vim_type, container=None, recursive=True, error=True):
    # Modified version of https://github.com/vmware/pyvmomi-community-samples/blob/7020598713aa440c70816edae89f96a0fe742be8/samples/tools/pchelper.py#L103
    # Returns a list of vms matching a certain pattern

    # Get a content view of vCenter
    content = si.RetrieveContent()

    # If no folder is specified then set it to the root folder
    if container is None:
        container = content.rootFolder

    # Create a container view of the vcenter where you are by default starting from the root folder and getting only objects of the vim_type but recursively
    containerview = content.viewManager.CreateContainerView(container, vim_type, recursive)

    # Go through this new container view and check if the name is in the object reference - if it does set the "obj" variable to that
    obj = [managed_obj_ref for managed_obj_ref in containerview.view]

    # Check if the name was found, if not raise an error
    if not obj and error is True:
        raise RuntimeError(f"not found!")
    return obj

def CreateClone(si,vmtemplatename,vmname,datacentername,datastorename,poweron,esxiname,vmfolder="",resourcepool="",linkedclone=False):
    # Modified version of https://github.com/vmware/pyvmomi-community-samples/blob/7020598713aa440c70816edae89f96a0fe742be8/samples/clone_vm.py#L28    
    # Get the datastore
    datacenter = SearchVcenter(si,[vim.Datacenter],datacentername)

    # Check if vmfolder exists
    if vmfolder:
        destinationfolder = SearchVcenter(si,[vim.Folder],vmfolder)
    else:
        destinationfolder = datacenter.vmFolder
    
    # Get the datastore
    if datastorename:
        datastore = SearchVcenter(si,[vim.Datastore],datastorename)
    else:
        raise RuntimeError(f"{datastorename} not found!")
    
    # Get the esxi
    if resourcepool:
        resourcepool = SearchVcenter(si,[vim.ResourcePool],resourcepool)
    else:
        if esxiname:
            # Get all of the resource pools
            resourcepools = AllVcenter(si,[vim.ResourcePool])

            # Go through each pool then each host in the pool AND then check if the esxiname is equal to the hosts name (would prob add another for loop if their was multiple hosts in the pool)
            for pool in resourcepools:
                for host in pool.owner.host:
                    if esxiname == host.summary.config.name:
                        resourcepool = pool
        else:
            raise RuntimeError(f"{esxiname} not found!")
    
    # Create a VM relocate spec
    relocatespec = vim.vm.RelocateSpec(datastore=datastore,pool=resourcepool)
    if linkedclone:
        relocatespec.diskMoveType = 'createNewChildDiskBacking'

    clonespec = vim.vm.CloneSpec(location=relocatespec,powerOn=poweron)
    # Look for the template
    vmtemplate = SearchVcenter(si,[vim.VirtualMachine],vmtemplatename)
    
    # Add options for linked clones
    if linkedclone:
        clonespec.template = False
        clonespec.snapshot = vmtemplate.snapshot.rootSnapshotList[0].snapshot
    
    print(f"creating {vmname}")
    task = vmtemplate.Clone(folder=destinationfolder, name=vmname, spec=clonespec)

    # Check loop to see if error :( or success :)
    check = False
    while not check:
        if task.info.state == 'success':
            print(f"created {vmname}")
            return task.info.result
        elif task.info.state == 'error':
            print(task.info.error)
            check=True

def DeleteVM(si,vmtodelete,parentfoldername=''):
    # Modified version of https://github.com/vmware/pyvmomi-community-samples/blob/master/samples/destroy_vm.py

    # Check to see if a parent folder is specified
    if parentfoldername:
        # Find the parent folder
        parentfolder = SearchVcenter(si,[vim.Folder],parentfoldername)

        # If the parent exists - then find the virtual machine inside that parent (must be a string since the search has to be done with the parent as the container - in future think about support for the seach string in "SearchVcenter" to support a object but just getting the name of it???)
        if not isinstance(vmtodelete,vim.VirtualMachine):
            vm = SearchVcenter(si,[vim.VirtualMachine],vmtodelete,container=parentfolder)
        else:
            print(f'To look within a parent folder the vmtodelete must be a string value, it is currently {type(vmtodelete)}')
            return None 
    else:
        # If no parent then find the virtual machine or if it is already a VirtualMachine object continue
        if not isinstance(vmtodelete,vim.VirtualMachine):
            vm = SearchVcenter(si,[vim.VirtualMachine],vmtodelete)
            vmdisplay = vmtodelete
        else:
            vm = vmtodelete
            vmdisplay = vmtodelete.name

    PowerOff(si,vm)

    task = vm.Destroy_Task()
    # Check loop to see if error :( or success :)
    check = False
    while not check:
        if task.info.state == 'success':
            print(f"destroyed {vmdisplay}")
            check = True
        elif task.info.state == 'error':
            print(task.info.error)
            check=True

def PowerOn(si,vmon):
    # Adapted from https://github.com/vmware/pyvmomi-community-samples/blob/master/samples/destroy_vm.py
    if not isinstance(vmon,vim.VirtualMachine):
        vm = SearchVcenter(si,[vim.VirtualMachine],vmon)
    else:
        vm = vmon

    if vm.runtime.powerState == "poweredOff":
        print(f"powering on {vm.name}")
        task = vm.PowerOnVM_Task()

        # Check loop to see if error :( or success :)
        check = False
        while not check:
            if task.info.state == 'success':
                print(f"powered on {vm.name}")
                check = True
            elif task.info.state == 'error':
                print(task.info.error)
                check=True

__author__ = "Oliver Mustoe"

def PowerOff(si,vmoff):
    # Adapted from https://github.com/vmware/pyvmomi-community-samples/blob/master/samples/destroy_vm.py
    if not isinstance(vmoff,vim.VirtualMachine):
        vm = SearchVcenter(si,[vim.VirtualMachine],vmoff)
    else:
        vm = vmoff

    if vm.runtime.powerState == "poweredOn":
        print(f"powering off {vm.name}")
        task = vm.PowerOffVM_Task()

        # Check loop to see if error :( or success :)
        check = False
        while not check:
            if task.info.state == 'success':
                print(f"powered off {vm.name}")
                check = True
            elif task.info.state == 'error':
                print(task.info.error)
                check=True

def CreateVMFolder(si,foldername,datacentername,parentfoldername=""):
    #Modified version of https://github.com/vmware/pyvmomi-community-samples/blob/master/samples/create_folder_in_datacenter.py
    datacenter = SearchVcenter(si,[vim.Datacenter],datacentername)
    if parentfoldername:
        parentfolder = SearchVcenter(si,[vim.Folder],parentfoldername)
        foldercheck = SearchVcenter(si,[vim.Folder],foldername,error=False,container=parentfolder)
    else:
        parentfolder = datacenter.vmFolder
        foldercheck = SearchVcenter(si,[vim.Folder],foldername,error=False)

    print(f"making {foldername}")
    try:
        task = parentfolder.CreateFolder(foldername)
        print(f"made {foldername}")
    except Exception as E:
        print(E)

def DeleteVMFolder(si,foldername,datacentername,parentfoldername="",prompt=True):
    datacenter = SearchVcenter(si,[vim.Datacenter],datacentername)
    #foldercheck = SearchVcenter(si,[vim.Folder],foldername,error=False)
    if parentfoldername:
        parentfolder = SearchVcenter(si,[vim.Folder],parentfoldername)
        foldercheck = SearchVcenter(si,[vim.Folder],foldername,error=False,container=parentfolder)
    else:
        foldercheck = SearchVcenter(si,[vim.Folder],foldername,error=False)


    if foldercheck:
            print(f"destroying {foldername}")
            try:
                task = foldercheck.Destroy_Task()
                # Check loop to see if error :( or success :)
                check = False
                while not check:
                    if task.info.state == 'success':
                        print(f"destroyed {foldername} and its contents")
                        check = True
                    elif task.info.state == 'error':
                        print(task.info.error)
                        check=True
            except Exception as E:
                print(E)
    else:
        print(f"{foldername} does not exist")

def TakeSnapshot(si,vm,description,snapshotname=str):
    if not isinstance(vm,vim.VirtualMachine):
        vm = SearchVcenter(si,[vim.VirtualMachine],vm)
    else:
        vm = vm
    
    if not description:
        session=si.content.sessionManager.currentSession
        time = datetime.now().strftime("%m/%d/%Y %H:%M:%S")
        description = f"Taken by {session.userName} at {time}"
    task = vm.CreateSnapshot_Task(snapshotname,description,False,True)
    check = False
    while not check:    
        if task.info.state == 'success':
            print(f"created snapshot '{snapshotname}' on {vm.name}")
            check = True
        elif task.info.state == 'error':
            print(task.info.error)
            check=True

def RevertToSnapshot(si,vm,snapshotname):
    if not isinstance(vm,vim.VirtualMachine):
        vm = SearchVcenter(si,[vim.VirtualMachine],vm)
    else:
        vm = vm

    snapshotlist = vm.snapshot.rootSnapshotList

    for snapshot in snapshotlist:
        if snapshot.name == snapshotname:
            print (f"reverting {vm.name} to snapshot {snapshotname}")

            task = snapshot.snapshot.RevertToSnapshot_Task()
            check = False
            while not check:    
                if task.info.state == 'success':
                    print(f"reverted {vm.name} to snapshot {snapshotname}")
                    check = True
                elif task.info.state == 'error':
                    print(task.info.error)
                    check=True