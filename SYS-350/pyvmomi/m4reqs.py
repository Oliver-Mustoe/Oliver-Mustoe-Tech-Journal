import getpass, ssl, json
from pyVim.connect import SmartConnect
from os.path import realpath,dirname

# Get file path
scriptdirectory = dirname(realpath(__file__))

# Grab a password
passw = getpass.getpass()

# Setup ssl
s=ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
s.verify_mode=ssl.CERT_NONE

# grab the user variables - req 1
with open(f"{scriptdirectory}/vars.json","r") as v:
    uservars = json.loads(v.read())

# Connect to vcenter
si=SmartConnect(host=uservars["vcenter"], user=uservars["username"], pwd=passw, sslContext=s)

# Setup the session and vm folders from the session
session=si.content.sessionManager.currentSession
vmfolders=si.content.rootFolder.childEntity[0].vmFolder.childEntity

# 
print(f"Current session information\nuser={session.userName}\nsourceip={session.ipAddress}\nvcenterip={uservars['vcenter']}")

# req 2/3/4
usersearchkey = input('Please enter a search key for VM name:')

if usersearchkey:
    vmlist= [vm for folder in vmfolders for vm in folder.childEntity if usersearchkey in vm.name]
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