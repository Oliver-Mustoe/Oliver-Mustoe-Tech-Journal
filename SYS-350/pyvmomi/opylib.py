import getpass, ssl, json, pyVmomi
from pyVmomi import vim
from pyVim.connect import SmartConnect

__author__ = "Oliver Mustoe"

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

# def wait(task):
#     check = False
#     while not check:
#         if task.info.state == 'success':
#             result = True
#         elif task.info.state == 'error':
#             print(task.info.error)
#             check=True

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
    
    task = vmtemplate.Clone(folder=destinationfolder, name=vmname, spec=clonespec)

    # Check loop to see if error :( or success :)
    check = False
    while not check:
        if task.info.state == 'success':
            print(f"created {vmname}")
            check=True
        elif task.info.state == 'error':
            print(task.info.error)
            check=True

def DeleteVM(si,vmlist=list):
    # Modified version of https://github.com/vmware/pyvmomi-community-samples/blob/master/samples/destroy_vm.py
    for vmtodelete in vmlist:
        vm = SearchVcenter(si,[vim.VirtualMachine],vmtodelete)
        PowerOff(si,vm)

        task = vm.Destroy_Task()
        # Check loop to see if error :( or success :)
        check = False
        while not check:
            if task.info.state == 'success':
                print(f"destroyed {vmtodelete}")
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

    if foldercheck:
        print(f"{foldername} already exists!")
    else:
        print(f"making {foldername}")
        try:
            task = parentfolder.CreateFolder(foldername)
            print(f"made {foldername}")
        except Exception as E:
            print(E)

# def wait(task):
#     check = True

#     while check:
#         if task.info.state == 'success':
#             return True
#         elif task.info.state == 'error':
#             print('Error has occured')
#             print(task.info.error)
#             check = False

def DeleteVMFolder(si,foldername,datacentername):
    datacenter = SearchVcenter(si,[vim.Datacenter],datacentername)
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