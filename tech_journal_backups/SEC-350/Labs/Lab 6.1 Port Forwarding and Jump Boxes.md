This technical journal will cover/link to the following information:

1. [Netplan configuration, ideally this is a link to your SYS265 tech journal article.](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Netplan-reference)

2. Port Forwarding and firewall adjustments for vyos
   
   1. [Port Forwarding](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Vyos-reference#setup-port-forwarding)
   
   2. [Firewall adjustments (SSH)](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Vyos-reference#setup-ssh)

3. [Creation of a passwordless user on jump](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/SSH-keys-reference#creating-a-passwordless-user)

4. [Key based ssh to the jump box](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/SSH-keys-reference#method-2-sftp)

5. [Agent installation on jump](#agent-installation-on-jump)

# Agent installation on jump

I used the same process seen in [Agent installation seen on my Wazuh reference](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Wazuh-reference#agent-installation) BUT with a slight modifcation to the command run in step 6 -- I instead used MGMT01 to download the .deb file and then SCP'd it over to the jump box like the process listed below:

First I downloaded the Wazuh deb file on the mgmt:

```bash
sudo apt-get update
sudo apt install curl -y
mkdir for_jump
cd for_jump
scp wazuh-agent-4.3.10.deb olivermustoe@172.16.50.4:
curl -so wazuh-agent-4.3.10.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.3.10-1_amd64.deb
scp wazuh-agent-4.3.10.deb olivermustoe@172.16.50.4:
```

![image1](https://user-images.githubusercontent.com/71083461/221033008-8097a0f0-b393-4981-871f-8e85cd804139.png)        

 Then I installed Wazuh on jump:

```bash
sudo WAZUH_MANAGER='172.16.200.10' WAZUH_AGENT_GROUP='linux' dpkg -i ./wazuh-agent-4.3.10.deb
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
```

![image2](https://user-images.githubusercontent.com/71083461/221032973-13047d7b-2295-4350-bc90-a96c43e8bd60.png)  

Result:  

![image5](https://user-images.githubusercontent.com/71083461/221032998-5b86eacf-083e-43e6-b530-9b36371fad33.png)



---

Can't find something, look in the [backup.](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-350/Labs/Lab%206.1%20Port%20Forwarding%20and%20Jump%20Boxes.md)
