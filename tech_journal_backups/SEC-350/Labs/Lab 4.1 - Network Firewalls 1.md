This technical journal will cover/link to the following information:

1. [Updating vyos](#updating-vyos)

2. [Configuring RIP](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Vyos-reference#configure-rip)

3. [Firewall Zones creation](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Vyos-reference#create-firewall-zones)

4. [Firewall Rule creation](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Vyos-reference#create-firewall-zones)

5. [Debugging Firewall Blocks](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Vyos-reference#firewalls)

6. [Exporting vyos configurations](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Vyos-reference#vyos-configs)

7. [Reflection](#reflection)

# Updating VyOS

By running the below command, can remove a stale syslog configuration (for example "172.16.50.5")

```
delete system syslog host {SYSLOG_IP}
```

# Reflection

I have learned a lot in the past 2 weeks in SEC-350. Last week, I worked a lot in and created documentation about [Wazuh.](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Wazuh-reference) I like Wazuh, it has a simple to use gui but I sense could be used pretty well if you knew how to use the command line interfaces. So far, we have only used it for logging bad logins. I am overall excited to see what it can do in more serious cirumstances. Using [VyOS](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Vyos-reference), specifically a firewall, has also been an interesting experience. It is very similiar to activities I have done in a 300 level networking class, so it was easy to wrap my mind around it thinking like that. I still need to spend some time with the firewalls to really


