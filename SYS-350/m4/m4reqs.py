import getpass, ssl, json
from pyVim.connect import SmartConnect
passw = getpass.getpass()
s=ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
s.verify_mode=ssl.CERT_NONE

# grab the user variables
with open("vars.json","r") as v:
    uservars = json.loads(v.read())

si=SmartConnect(host=uservars["vcenter"], user=uservars["username"], pwd=passw, sslContext=s)
session=si.content.sessionManager.currentSession
vmfolders=si.content.rootFolder.childEntity[0].vmFolder.childEntity

print(f"Current session information\nuser={session.userName}\nsourceip={session.ipAddress}\nvcenterip={uservars['vcenter']}")

usersearchkey = input('Please enter a search key for VM name:')

if usersearchkey:
    for folder in vmfolders:
        print(folder.name)
        for vm in folder.childEntity:
            if usersearchkey in vm.name:
                print(vm.name)
else:
    for folder in vmfolders:
        print(folder.name)
        for vm in folder.childEntity:
             print(vm.name)