Below is the network diagram for SEC-350 architecture circa 1/24/23:

![image](https://user-images.githubusercontent.com/71083461/214442814-a69c7e6f-0ca3-46fa-b819-47b309938dce.png)

<details>
<summary>Code</summary>

```
@startuml

'TODO: Double-check info

title Oliver Routing and DMZ Architecture -- SEC-350 
header Updated 1/24/23

' devices/networks
queue "CYBER-DATACENTER 192.168.4.0/24" as CYBER #deepskyblue;line:darkblue;line.bold;text:black

rectangle "GW SEC350-01" as GW

queue "SEC350-01-WAN 10.0.17.0/24" as WAN #pink;line:red;line.bold;text:black
queue "OLIVER-DMZ 172.16.50.0/29" as DMZ #gold;line:goldenrod;line.bold;text:black
queue "OLIVER-LAN 172.16.150.0/24" as LAN #palegreen;line:green;line.bold;text:black

rectangle "<img:https://raw.githubusercontent.com/Roemer/plantuml-office/master/office2014/Servers/application_server.png>RW01-oliver\n'Linux box'" as rw01

rectangle "<img:https://raw.githubusercontent.com/Roemer/plantuml-office/master/office2014/Concepts/firewall.png>FW01-oliver\n'VyOS firewall'" as fw01

rectangle "<img:https://raw.githubusercontent.com/Roemer/plantuml-office/master/office2014/Servers/application_server.png>MGMT01-oliver\n'Linux box'" as mgmt01

rectangle "<img:https://raw.githubusercontent.com/Roemer/plantuml-office/master/office2014/Servers/web_server.png>WEB01-oliver\n'Linux web server'" as web01

rectangle "<img:https://raw.githubusercontent.com/Roemer/plantuml-office/master/office2014/Servers/server_generic.png>LOG01-oliver\n'Linux logging server'" as log01

' Connections
GW -[#red]- WAN: ".2"

fw01 -[#green]- LAN: ".2 (eth1)"
fw01 -[#goldenrod]- DMZ: ".2 (eth2)"

LAN -[#green]- mgmt01: ".10"

DMZ -[#goldenrod]- web01: ".3"
DMZ -[#goldenrod]- log01: ".5"

WAN -[#red]- fw01: ".125 (eth0)"
WAN -[#red]- rw01: ".25"


' References
' https://plantuml.com/deployment-diagram
' https://plantuml.com/color
' https://plantuml.com/stdlib
' https://github.com/Roemer/plantuml-office

' Notes about formatting:
' web01 is an example of web server formatting, log01 is a non-graphical linux box (probably ssh in to), mgmt01 is a linux box with graphical user interface, fw01 is firewall example

@enduml
```
</details>






