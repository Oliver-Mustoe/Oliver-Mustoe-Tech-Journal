This technical journal will cover/link to the following information:

1. [Augment your documentation to include how to change a vyos password](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Vyos-reference#change-password-for-vyos-user)

2. [If you've not done so in your SYS classes, make sure to document how to use ssh keybased authentication.  Make this happen from mgmt01 to at least web01 or log01.](#ssh-keybased-authentication-setup)

3. [Address how to log authpriv messages on linux systems](#authpriv-logging-on-linux)

4. [your rsyslog documentation to cover the new drop in file configuration on the server as well as the changes to the web01 client to forward authentication events.](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Syslog-reference#custom-log-organization)

5. [Describe how to forward authentication events from vyos to a remote syslog server](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Vyos-reference#forward-authentication-messages-to-rsyslog)

6. [Make sure to capture any difficulties or observations as reflections](#reflection)

# SSH keybased authentication setup

The following commands can be used for passwordless SSH:

```bash
# Sets up keys
ssh-keygen -t rsa -b 4096
# Delivers keys to designated host
ssh-copy-id -i ~/.ssh/id_rsa.pub {USER}@{IP}
# Add key to ssh-agent (can add -t flag to specify time)
ssh-add ~/.ssh/id_rsa.pub
```

(**NOTES:** `{USER}@{IP}` is the user/ip of the host you wish to passwordless SSH into.)

Below shows the process of setting up SSH keybased authentication to a host with a user of "olivermustoe" and a IP of "172.16.50.5" (keys already generated):

![image](https://user-images.githubusercontent.com/71083461/214702657-0064d95f-e8df-4e74-9d35-77b25cd5582f.png)

# Authpriv logging on Linux

**Prereqs**: Following information expects a [syslog client setup](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Syslog-reference#configuring-syslog-service-on-logging-client). Output of logs will be set according to the settings outlined in [Time settings](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Time-settings).

Inside "/etc/rsyslog.d", add the following to the .conf file (in this case "sec350-client.conf"). First line in screenshot should already exist:

```
authpriv.* @{LOG_server_IP}
```

![image](https://user-images.githubusercontent.com/71083461/214685204-580be8ee-e2ba-433a-8489-a34a680737e0.png)  

Then the service should be restarted:

```bash
sudo systemctl restart rsyslog
```

After trying to login/successfully logging in, information should populate in "/var/log/remote-syslog/{HOSTNAME}/{DATE}.sshd.log" like the following:

![D3-new](https://user-images.githubusercontent.com/71083461/214685555-4bc59aca-ae3d-4d6e-b12b-8a7def74feec.PNG)

# Reflection

This week in SEC-350 was a lighter, but still informative week compared to the last week. I have dealt with logging before, but usually in the context of troubleshooting a problem. Because the problem is not usually time sensitive, I have never thought to make any sort of logs more robust in the time zone management, so this is good info to know. During the custom log organization, one of my collogues had a problem with their logging not changing. One of the major differences I saw between his and mine was that I created the file initially as root, and effectively filled in the content via VIM (initially tried to cat redirect it into the file, but that ran into issues.) While I am unsure if those were the causes, I will perform the action in a similar manner moving forward to ensure I don't run into issues. I have used SSH key authentication many times in the past, but never did it when it wasn't a requirement for the lab. As I move forward through the course, I will make sure to add this to my designated machines for faster system administration.
