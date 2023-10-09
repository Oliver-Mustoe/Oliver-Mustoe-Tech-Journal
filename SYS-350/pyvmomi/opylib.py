import getpass, ssl, json, pyVmomi
from pyVmomi import vim
from pyVim.connect import SmartConnect
from datetime import datetime

__author__ = "OM | SYS-350"

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


def TaskWait(task,message):
    check = False
    while not check:
        if task.info.state == 'success':
            print(message)
            check = True
        elif task.info.state == 'error':
            print(task.info.error)
            check=True
    return task.info.result


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
    message = f"created {vmname}"
    # Check loop to see if error :( or success :)
    TaskWait(task,message)


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

    # Poweroff VM and destroy it
    PowerOff(si,vm)

    task = vm.Destroy_Task()
    message = f"destroyed {vmdisplay}"
    # Check loop to see if error :( or success :)
    TaskWait(task,message)


def PowerOn(si,vmon):
    # Adapted from https://github.com/vmware/pyvmomi-community-samples/blob/master/samples/destroy_vm.py
    if not isinstance(vmon,vim.VirtualMachine):
        vm = SearchVcenter(si,[vim.VirtualMachine],vmon)
    else:
        vm = vmon

    if vm.runtime.powerState == "poweredOff":
        print(f"powering on {vm.name}")
        task = vm.PowerOnVM_Task()
        message = f"powered on {vm.name}"
        # Check loop to see if error :( or success :)
        TaskWait(task,message)

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
    else:
        parentfolder = datacenter.vmFolder

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
                message = f"destroyed {foldername} and its contents"
                # Check loop to see if error :( or success :)
                TaskWait(task,message)
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
        # If no description is given, create a default description of a username and time
        session=si.content.sessionManager.currentSession
        time = datetime.now().strftime("%m/%d/%Y %H:%M:%S")
        description = f"Taken by {session.userName} at {time}"

    # Create the snapshot and have a while loop to check if it is working
    task = vm.CreateSnapshot_Task(snapshotname,description,False,True)
    message = f"created snapshot '{snapshotname}' on {vm.name}"
    TaskWait(task,message)


def RevertToSnapshot(si,vm,snapshotname):
    if not isinstance(vm,vim.VirtualMachine):
        vm = SearchVcenter(si,[vim.VirtualMachine],vm)
    else:
        vm = vm

    # Get a list of all of the snapshots
    allsnapshots = []
    snapshotlist = vm.snapshot.rootSnapshotList
    
    # Get all of the snapshots down each tree - some code inspired by https://stackoverflow.com/questions/36501306/how-to-revert-a-vm-snapshot-with-pyvmomi
    for snapshot in snapshotlist:
        allsnapshots.append(snapshot)
        # If there is a child snapshot list
        if snapshot.childSnapshotList:
            children = True
            while children:
                # Go through each of the child snapshots
                for childsnapshot in snapshot.childSnapshotList:
                    # Append them to the list
                    allsnapshots.append(childsnapshot)
                # If that child has a list
                if childsnapshot.childSnapshotList:
                    # Make snapshot the childsnapshot - this way the for look above will go through the children of our snapshot
                    snapshot = childsnapshot
                else:
                    # Kill the while loop if there is no more children
                    children = False


    # For each snapsnapshot - if the snapshots name is equal to the specified name...
    for snapshot in allsnapshots:
        if snapshot.name == snapshotname:
            print (f"reverting {vm.name} to snapshot {snapshotname}")

            # Create a task to revert to the snapshot - wait until it is done
            task = snapshot.snapshot.RevertToSnapshot_Task()
            message = f"reverted {vm.name} to snapshot {snapshotname}"
            TaskWait(task,message)