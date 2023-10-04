import getpass, ssl, json
from pyVim.connect import SmartConnect
from pyVmomi import vim
from os.path import realpath,dirname
# Says to go a directory up and import the opylib file
import opylib

# Get file path
scriptdirectory = dirname(realpath(__file__))

si = opylib.ConnectToVcenter(scriptdirectory)

# Setup the session and vm folders from the session
session=si.content.sessionManager.currentSession
vmfolders=si.content.rootFolder.childEntity[0].vmFolder.childEntity

# 
print(f"Current session information\nuser={session.userName}\nsourceip={session.ipAddress}\nvcenterip")

# req 2/3/4
usersearchkey = input('Please enter a search key for VM name:')

if usersearchkey:
    vmlist=opylib.SearchVcenterWithPattern(si, [vim.VirtualMachine], usersearchkey)
    print(f"==VMs that match your key==")
    for vm in vmlist:
        print("---")
        print(f"VM Name: {vm.name}")
        print(f"VM Power State: {vm.summary.runtime.powerState}")
        print(f"VM CPU number: {vm.summary.config.numCpu}")
        print(f"VM MemoryGB: {vm.summary.config.memorySizeMB/1000}")
        print(f"VM Primary IP: {vm.guest.ipAddress}")

else:
    vmlist= [vm for folder in vmfolders for vm in folder.childEntity]
    print(f"==VMs that match your key==")
    for vm in vmlist:
        print("---")
        print(f"VM Name: {vm.name}")
        print(f"VM Power State: {vm.summary.runtime.powerState}")
        print(f"VM CPU number: {vm.summary.config.numCpu}")
        print(f"VM MemoryGB: {vm.summary.config.memorySizeMB/1000}")
        print(f"VM Primary IP: {vm.guest.ipAddress}")