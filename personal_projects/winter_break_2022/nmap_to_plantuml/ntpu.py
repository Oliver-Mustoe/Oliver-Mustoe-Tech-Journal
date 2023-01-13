#!/usr/bin/python3
import argparse
import nmap
from datetime import date
import requests

def main():
    """
    Main function to run everything
    :return: None
    """
    # Gather args into a variable
    arguments = args()

    # Run NMAP, returns list (0=scan,1=scan_time)
    nmap_output = runnmap(arguments)

    # Run planuml conversion
    toplanuml(nmap_output[0],nmap_output[1],arguments)

    pass


def args():
    """
    A function to gather arguments for parsing
    :return: Populated namespace of argument values
    """
    # Setup basic parser
    arg_parser = argparse.ArgumentParser(
        prog="ntpu",
        description="NmapToPlanUml (NTPU) is a command line program that runs nmap to create visual diagrams of a system via PlanUML"
    )

    # Add arguments
    arg_parser.add_argument(
     "-i","--InputFile",
     help="Input file to place the UML code in"
    )

    arg_parser.add_argument(
        "-O","--Output",
        action="store_true",
        help="Enable sending UML code to PlanUML servers and return ASCII art of scanned computers"
    )

    arg_parser.add_argument(
        "TargetIPAddress",
        metavar="IP",
        nargs="+",
        help="The IP address/es of the host/s you wish to scan. Input separated with a space, and can make use of input ranges from NMAP ('-' and CIDR notation). Example: 192.168.0.1 192.168.0.2 192.168.0.5-10 192.168.0.1/23"
        )

    # Parse the arguments are return objects
    args = arg_parser.parse_args()

    return args


def runnmap(args):
    """
    A function that runs nmap, may have variables to define IP's
    :param: Populated namespace of argument values
    :return: Json formatted results of nmap
    """

    # Take the list of target ips from arguments and join them
    ipaddrs = " ".join(args.TargetIPAddress)
    nm = nmap.PortScanner()

    # scan_results = nm.scan(hosts=ipaddrs)
    scan_results = cleanscan(nm.scan(hosts=ipaddrs))

    return scan_results
    

def cleanscan(scan):
    """
    A function to cleanup nmap scan results with default nmap settings
    :param: scan, raw nmap scan results
    :return: List with clean nmap scan results/scan timers
    """

    clean_results = scan['scan']
    scan_time = scan['nmap']['scanstats']

    results = [clean_results,scan_time]

    return results


def toplanuml(nmap_json,scan_time,args):
    """
    A function to convert Json formmatted results of nmap into planttext uml
    :param: nmap_json, clean json formmatted nmap results
    :param: args, Populated namespace of argument values
    :return: None
    """

    # Create a string of beginning uml code
    uml_code=f"""@startuml
!define osaPuml https://raw.githubusercontent.com/Crashedmind/PlantUML-opensecurityarchitecture2-icons/master
!include osaPuml/Common.puml
!include osaPuml/User/all.puml
!include osaPuml/Hardware/all.puml
!include osaPuml/Misc/all.puml
!include osaPuml/Server/all.puml
!include osaPuml/Site/all.puml
allowmixing

title Scan results:
legend
Scanned IPs:{scan_time['totalhosts']} in {scan_time['elapsed']}
end legend

right footer {scan_time['timestr']}

object self {{
    <$osa_desktop>
}}
frame "Scanned Network" {{\n"""

    # For each host in the json
    for num, host in enumerate(nmap_json.keys()):
        # Determine hostname (whether or not nmap collected one)
        if nmap_json[host]['hostnames'][0]['name'] != '':
            hostname = nmap_json[host]['hostnames'][0]['name']
        else:
            hostname = host
        ###
        
        # Handling ports
        total_ports = []
        open_ports = []
        #uml_code += f"total_ports ="
        
        # Append each port with its port and name in a certain format to a list, if it is also open, append that to another list 
        for port in nmap_json[host]['tcp'].keys():
            total_ports.append(f"{port}/{nmap_json[host]['tcp'][port]['name']}")

            if nmap_json[host]['tcp'][port]['state'] == 'open':
                open_ports.append(f"{port}")
        ###

        # From data above, generate a object with information collected from nmap (ports are the joining of the entire list with commas)
        uml_code += f"""object "{hostname}" as {num} {{
                <$osa_server>
                status = {nmap_json[host]['status']['state']}\n
                IPs = {nmap_json[host]['addresses']['ipv4']}
                total_ports/services = {','.join(total_ports)}
                open_ports = {','.join(open_ports)}
                }}
                self <--> {num}\n"""

    # Standard end of formatting
    uml_code += f"@enduml"
    
    if args.Output:
        r = requests.get(f"https://www.plantuml.com/plantuml/txt/~h{planuml_encode(uml_code)}")
        print(r.text)
    else:
        print(f"https://www.plantuml.com/plantuml/uml/~h{planuml_encode(uml_code)}")
    pass



def planuml_encode(planuml_data):
    """
    A function to encode planuml data (currently hex, may be deflate in future)
    :return: String of compressed values use depress
    """
    # Take UML, encode with UTF-8, convert bytes to hex
    encoded_uml = planuml_data.encode('utf-8').hex()

    # Return compressed UML
    return encoded_uml

main()