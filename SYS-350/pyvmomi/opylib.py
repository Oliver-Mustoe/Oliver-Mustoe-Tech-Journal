import getpass, ssl, json
from pyVim.connect import SmartConnect
from os.path import realpath,dirname
import pyVmomi

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

def SearchVcenter(si, vim_type, name, container=None, recursive=True, error=True):
    # Heavily inspired by https://github.com/vmware/pyvmomi-community-samples/blob/7020598713aa440c70816edae89f96a0fe742be8/samples/tools/pchelper.py#L103
    # Get a content view of vCenter
    content = si.RetrieveContent()

    # If no folder is specified then set it to the root folder
    if container is None:
        container = content.rootFolder

    # Create a container view of the vcenter where you are by default starting from the root folder and getting only objects of the vim_type but recursively
    containerview = content.viewManager.CreateContainerView(container, vim_type, recursive)

    # Go through this new container view and check each object reference to see if it matchs the name specified - if it does set the "obj" variable to that
    obj = [managed_obj_ref for managed_obj_ref in containerview.view if managed_obj_ref.name == name]

    # destroy the container view
    container.Destroy()

    # Check if the name was found, if not raise an error
    if not obj and error is True:
        raise RuntimeError(f"{name} not found!")
    return obj


def SearchVcenterWithPattern(si, vim_type, name, container=None, recursive=True, error=True):
    # Heavily inspired by https://github.com/vmware/pyvmomi-community-samples/blob/7020598713aa440c70816edae89f96a0fe742be8/samples/tools/pchelper.py#L103
    # Get a content view of vCenter
    content = si.RetrieveContent()

    # If no folder is specified then set it to the root folder
    if container is None:
        container = content.rootFolder

    # Create a container view of the vcenter where you are by default starting from the root folder and getting only objects of the vim_type but recursively
    containerview = content.viewManager.CreateContainerView(container, vim_type, recursive)

    # Go through this new container view and check if the name is in the object reference - if it does set the "obj" variable to that
    obj = [managed_obj_ref for managed_obj_ref in containerview.view if name in managed_obj_ref.name]

    # destroy the container view
    container.Destroy()

    # Check if the name was found, if not raise an error
    if not obj and error is True:
        raise RuntimeError(f"{name} not found!")
    return obj