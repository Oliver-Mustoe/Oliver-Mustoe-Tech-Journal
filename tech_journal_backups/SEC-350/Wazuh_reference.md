# Wazuh reference

This page contains configurations/tips on working with the Wazuh.

**Table of contents**

1. [Installing Wazuh](#installing-wazuh)

2. [Group creation](#group-creation)

3. [Config locations](#config-locations)

4. [Sources](#sources)

## Installing Wazuh

To install Wazuh onto the logging host, run the following command:

```bash
curl -sO https://packages.wazuh.com/4.3/wazuh-install.sh && sudo bash ./wazuh-install.sh -a
```

This should, after installation, supply you with an admin credential and password. If this password is lost, it can be recovered by extracting the file "wazuh-install-files.tar" (which will be the directory you ran the above command in), and accessing the file "wazuh-passwords.txt"  

![image](https://user-images.githubusercontent.com/71083461/216200235-ce288a68-466e-4a11-8cb3-db4f054a8db5.png)

This install of Wazuh can then be accessed from the web by going to "https://{IP_OF_LOGGING_SERVER}", for example if the IP was "172.16.200.10":   

![D1](https://user-images.githubusercontent.com/71083461/216200518-f8b6fb96-ea7e-42e3-b3a2-38ea341e593b.PNG)

## Group creation

To create a Wazuh group, use the dropdown to access Management > then under Administration access Groups:  

![image2](https://user-images.githubusercontent.com/71083461/216200649-90aca5de-9bac-43ec-a251-237d35c9afbb.png)

![image12](https://user-images.githubusercontent.com/71083461/216200716-db979339-e5d3-45f8-af5c-997d7dfc51cc.png)

You can then press "Add new group" to add a new group:  

![image](https://user-images.githubusercontent.com/71083461/216201511-f5c31cc6-25c5-4aa7-888f-163e1536ad48.png)

## Agent installation

**REQUIRES A GROUP**

To install a Wazuh agent onto a host,  use the dropdown and goto "Agents" (below is already navigated):

![image9](https://user-images.githubusercontent.com/71083461/216200708-917f7e14-d7c1-477e-bd73-8f8392017878.png)

You would then set the Operating system, Version, Architecture, Wazuh Server IP, and Group. Below shows an example for a host with the following specifications:

1. Rocky Linux OS

2. Wazuh server IP = 172.16.200.10

3. Desginated group = linux

![image4](https://user-images.githubusercontent.com/71083461/216200664-a7877451-5715-49fd-84a1-0dc81f7291d3.png)  

![image10](https://user-images.githubusercontent.com/71083461/216200712-dde1fd0f-7ca6-4559-a406-e0197614d478.png)  

**(ONLY NEED TO SUPPLY 1-5!!!)**

After supplying the needed information, step 6 will supply the commands that need to run on the logging host (in this case, a server with the IP 172.16.50.3):  

![image11](https://user-images.githubusercontent.com/71083461/216202372-16dabbad-89a5-4cd1-a421-3df5efd5ccca.png)  

After the commands in step 6 are ran, do the commands in step 7. After those commands are run, the agents screen will show the following (can access previous screen by pressing "Deploy new agent"):  

![image3](https://user-images.githubusercontent.com/71083461/216200655-ac809f6b-fd08-4f17-affa-fc3365b50749.png)

Pressing on the agent (for example "web01-oliver") will then give you the option to see various events related to it:

![image](https://user-images.githubusercontent.com/71083461/216202903-6646405d-7dbb-4df0-b591-27ca54fe1c24.png)

For example, failed logins would be under "Security events" > Events tab > finding the event:

![D3](https://user-images.githubusercontent.com/71083461/216203444-0f4603b1-bb7a-488f-8c0f-761aca1d7965.PNG)

## Config locations

- **Default Wazuh configuration directory:** `/var/ossec`

- **Wazuh main config file location:** `/var/ossec/etc/ossec.conf`

- **Wazuh agent configuration location:** `/var/ossec/etc/shared/agent.conf`



## Sources

* [Local configuration (ossec.conf) - Reference · Wazuh documentation](https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/index.html#:~:text=conf%20file%20is%20the%20main,)

* [Centralized configuration (agent.conf) - Reference](https://documentation.wazuh.com/current/user-manual/reference/centralized-configuration.html)



---

Can't find something? Look in the [Backup Wazuh reference](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-350/Wazuh_reference.md)
