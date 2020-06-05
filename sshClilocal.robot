*** Settings ***
Documentation          This example demonstrates executing a command on a remote machine
...                    and getting its output.
...
...                    Notice how connections are handled as part of the suite setup and
...                    teardown. This saves some time when executing several test cases.

Library                Process
Library                SSHLibrary
Suite Setup            Open Connection And Log In
#Suite Teardown         Close All Connections
Resource            resourceLocal.robot

*** Test Cases ***
Execute Hello World Echo Command And Verify Output
    [Tags]                  Hello_World
    [Documentation]         Execute Command can be usWLANed to run commands on the remote machine.
    ...                     The keyword returns the standard output by default.
    ${output}=              Execute Command    echo Hello SSHLibrary!
    should be equal         ${output}          Hello SSHLibrary!

#Global configuration level
Global: Execute Help
    [Tags]                      Global     help
    [Documentation]             Execute Help command and report all help topics
    ${execute}=                 write              help
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}           -ash: help: not found
    should contain              ${output}           (global)#

Global: History 10 And Verify Output
    [Tags]                      Global   history     10
    [Documentation]             Execute history 10 CLI and return the last 10
    ...                         The keyword returns the standard output by default.
    write                       history 10
    set client configuration    prompt=#
    ${output}=                  read until      history
    should not be empty         ${output}
    should not contain          ${output}       -ash: help: not found


Global: Ping on 8.8.8.8
    [Tags]                  Global     ping        8.8.8.8
    [Documentation]         Execute ping on 8.8.8.8 CLI and return the ping hops
    ...                     The keyword returns the standard output by default.
    write                   ping 8.8.8.8
    Sleep                   6
    ${output}=              read until      0% packet loss
    should not be empty     ${output}
    should not contain      ${output}       -ash: help: not found
    should contain              ${output}   0% packet loss

#Start python http server
#    [Tags]                      Global     ar_ping     ar  ping     python_http_server
#    [Documentation]             Start the http python on localhost on port 7272
#    run process                 python  ${server}   timeout=3min	on_timeout=continue

Global: AR Ping
    [Tags]                      Global     ar_ping
    [Documentation]             Execute Ap Ping and report ping stats
    #Start the http python on localhost on port 7272
    run process                 python  ${server}   timeout=3min	on_timeout=continue
    #start ar ping
    write                       ping ip localhost:7272 source 192.168.0.1 repeat 3
    Sleep                       2
    ${output}=                  read until      0% packet loss
    should not be empty         ${output}
    should not contain          ${output}   Syntax error: Illegal command line    -ash: help: not found
    should contain              ${output}   0% packet loss

Global: Traceroute
    [Tags]                      Global  traceroute
    [Documentation]             Execute Traceroute and report traceroute stats
    #Start the http python on localhost on port 7272
    #run process                 python  ${server}   timeout=3min	on_timeout=continue
    #start traceroute
    #${execute}=                 write       traceroute 8.8.8.8 resolve source localhost:7272 interface eth0
    #${execute}=                 write       traceroute localhost:7272
    ${execute}=                 write       traceroute 192.168.1.250
    Sleep                       12
    set client configuration    prompt=(global)#
    ${output}=                  read until prompt   #traceroute: can't set multicast source interface
    should not contain          ${output}    Usage: ping [OPTIONS] HOST     Syntax error: Illegal parameter
    should not contain          ${output}   traceroute: can't set multicast source interface    Illegal command line
    #should not Be Equal         ${output}    traceroute: can't set multicast source interface    #has issues

Global: ps Processes
    [Tags]                      Global   ps
    [Documentation]             Execute the ps & return all of the processes
    ${execute}=                 write   ps
    set client configuration    prompt=#
    ${output}=                  read until prompt
    Sleep                       5
    should not be empty         ${output}
    should not contain          ${output}   -ash: help: not found
    should not contain          ${output}   Syntax error: Illegal command line

Global: show interfaces
    [Tags]                      Global  show    interfaces  show_interfaes
    [Documentation]             Execute the show interfaces & return all of the processes
    ${execute}=                 write   show interfaces
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: help: not found

Global: show ip route
    [Tags]                      Global  show    ip_route    show_ip_route
    [Documentation]             Execute the show ip route & return all of the processes
    ${execute}=                 write   show ip route
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: help: not found
    should not contain          ${output}   Syntax error: Illegal command line

Global: show iptables
    [Tags]                      Global  show    iptables    show_iptables
    [Documentation]             Execute the show iptables & return all of the processes
    ${execute}=                 write   show iptables
    sleep                       2
    #set client configuration    prompt=(global)#
    ${output}=                  read    #until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: help: not found

#Global --> configure --> Global
Global: Execute "configure" and then "exit", then back to "confgiure" and use "top" to go back to global configuration
    [Tags]                      Global  Config      System_Configuration   top     Global      configure_in_out
    [Documentation]             Execute the configure and then retreat back to global via top and one exit statement
    ${execute}=                 write   configure
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: configure: not found     (global)#
    should contain              ${output}   (config)#
    #use "exit" to go up by 1 level to Global Configuration
    ${execute}=                 write   exit
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: configure: not found     (config)#
    should contain              ${output}   (global)#
    #use "top" to go up to the basic level of Global Configuration
    ${execute}=                 write       top
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: top: not found    (config)#
    should contain              ${output}   (global)#

#System config portion
Global: ntp server configuration and show it (has problem matching with double space, also ntp updated on server 6 rather than 1)
    [Tags]                      Config      System_Configuration    ntp     show_ntp
    [Documentation]             Execute the ntp & confirm ntp servers are updated & shown
    ${execute}=                 write   top
    ${execute}=                 write   configure
    ${execute}=                 write   ntp server1 www.yahoo.com server2 www.google.com server3 www.msn.com server4 server5        loglevel=DEBUG
    sleep                       1
    ${ntp}=                  write   show ntp       loglevel=DEBUG
    sleep                       2
    #set client configuration   prompt=(config)#
    ${ntp}=                 read     #until prompt        loglevel=WARN
    #${ntp}=                  read until      www.yahoo.com        loglevel=WARN
    should not be empty         ${ntp}
    should not contain          ${ntp}   -ash: ntp: not found    -ash: show ntp: not found
    should contain              ${ntp}   (config)#     www.yahoo.com
    should contain             ${ntp}   NTP Server1  www.yahoo.com    loglevel=WARN
    ${exit}                     write  top
    #${exit}                     read
    #should contain              ${exit}   (global)#
    #${output}=                 write   echo Stahp it NTP!
    #should be equal             ${output} Stahp it NTP!

#WAN0
WAN0 Configuration: Wan0 Mode and back out via exit & top
    [Tags]                      Config      WAN     wan0    wan_configuration   wan0_in_out
    [Documentation]             Enters the WAN Configuration Mode and retrest to global with top and then repeat but with two exits
    ${execute}=                 write   top
    ${output}=                 write   configure
    sleep                       1
    ${output}=                 write   interface ethernet wan0
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}   -ash: ntp: not found
    should not contain          ${output}   -ash: show ntp: not found
    should not contain          ${output}   (global)#
    should not contain          ${output}   (config)#
    should contain              ${output}   (config-if-wan0)#
    should contain              ${output}   DHCP Configuration:
    should contain              ${output}   DNS_AUTO=Enable
    should contain              ${output}   HOST_NAME=
    should contain              ${output}   QUERY_MODE=Agressive
    should contain              ${output}   MTU_AUTO=Enable
    #use top to get to global
    ${output}=                 write   top
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}   (config)#
    should not contain          ${output}   (config-if-wan0)#
    should contain              ${output}   (global)#
    #use two exits to get back to global configuration
    ${output}=                 write   configure
    sleep                       1
    ${output}=                 write   interface ethernet wan0
    sleep                       1
    ${output}=                 write   exit     #to exit to system configuration level
    sleep                       1
    ${output}=                 write   exit     #to exit to global configuration level
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}   (config)#
    should not contain          ${output}   (config-if-wan0)#
    should contain              ${output}   (global)#
    ${exit}                     write  top

#WAN0 DHCP
WAN0 dhcp: Execute conn dhcp to enter the WAN DHCP Configuration Mode, do initial read out & back out via top and 3 exits
    [Tags]                      Config      WAN     wan0    dhcp    conn_dhcp_in_out
    [Documentation]             Enters the WAN DHCP Configuration Mode
    ${execute}=                 write   top
    ${output}=                 write   configure
    ${output}=                 write   interface ethernet wan0
    ${output}=                 write   conn dhcp
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}   -ash: ntp: not found
    should not contain          ${output}   -ash: show ntp: not found
    should contain              ${output}   (config-if-wan0-dhcp)#
    #top to get to global
    ${output}=                 write   top
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}   (config-if-wan0-dhcp)#
    should not contain          ${output}   -ash: show ntp: not found
    should contain              ${output}   (global)#
    #3 exits to get back to global
    ${output}=                 write   configure
    sleep                       1
    ${output}=                 write   interface ethernet wan0
    sleep                       1
    ${output}=                 write   conn dhcp
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}   (config-if-wan0-dhcp)#
    should not contain          ${output}   -ash: show ntp: not found
    should contain              ${output}   (global)#

WAN0 dhcp: Execute update DHCP mtu, apply and then show DHCP
    [Tags]                      Config      WAN     wan0    dhcp   dhcp_mtu
    [Documentation]             Update mtu, apply and then show DHCP
    ${execute}=                 write   top
    ${output}=                 write   configure
    ${output}=                 write   interface ethernet wan0
    ${output}=                 write   conn dhcp
    sleep                       1
    ${mtuauto}=                 write   mtu auto
    sleep                       1
    ${mtuauto}=                 write   show
    sleep                       1
    ${mtuauto}=                  read
    should contain              ${mtuauto}   MTU_AUTO=Enable
    sleep                       1
    ${output}=                 write   mtu 1234
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    #${output}=                 write   apply
    #sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should contain              ${output}   MTU=1234
    ${exit}                     write  top

WAN0 dhcp: Execute update DHCP DNS and then show the applied result
    [Tags]                      Config      WAN     wan0    dhcp   dhcp_dns
    [Documentation]             Update DNS, apply and then show new DNS
    ${execute}=                 write   top
    ${output}=                 write   configure
    ${output}=                 write   interface ethernet wan0
    ${output}=                 write    conn dhcp
    sleep                       1
    ${dnsauto}=                 write   dns auto
    sleep                       1
    ${dnsauto}=                 write   show
    sleep                       1
    ${dnsauto}=                 read
    sleep                       1
    should contain              ${dnsauto}     DNS_AUTO=Enable
    sleep                       1
    ${output}=                 write   dns 8.8.4.4 8.8.8.8
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    #${output}=                 write   apply
    #sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should contain              ${output}   DNS_SERVER1=8.8.4.4
    should contain              ${output}   DNS_SERVER2=8.8.8.8
    should not be empty         ${output}
    should not contain          ${output}   -ash: ntp: not found
    should not contain          ${output}   -ash: show ntp: not found
    should contain              ${output}   (config-if-wan0-dhcp)#


WAN0 dhcp: Execute update DHCP host name & then show the applied result
    [Tags]                      Config      WAN     wan0    dhcp   DHCP_host
    [Documentation]             update host name as yeehaw, apply & then show it
    ${execute}=                 write   top
    ${output}=                 write   configure
    ${output}=                 write   interface ethernet wan0
    ${output}=                 write   conn dhcp
    ${output}=                 write   host yeehaw
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    #${output}=                 write   apply
    #sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should contain              ${output}   HOST_NAME=yeehaw
    should not be empty         ${output}
    #should not contain          ${output}   HOST_NAME=
    #should not contain          ${output}
    should contain              ${output}   (config-if-wan0-dhcp)#
    ${exit}                     write  top

WAN0 dhcp: Execute update DHCP querymode to normal (from aggresive default) & then show the applied result
    [Tags]                      Config      WAN     wan0    dhcp   dhcp_query_mode
    [Documentation]             update query mode from Aggresive to Normal
    ${execute}=                 write   top
    ${output}=                 write   configure
    ${output}=                 write   interface ethernet wan0
    ${output}=                 write   conn dhcp
    ${output}=                 write   querymode normal
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    #${output}=                 write   apply
    #sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should contain              ${output}   QUERY_MODE=Normal
    should not be empty         ${output}
    should not contain          ${output}   QUERY_MODE=Agressive
    should contain              ${output}   (config-if-wan0-dhcp)#
    ${exit}                     write  top

#next to reset and clean it up
#WIP

#WAN Static config
WAN0 static: Execute connect static Wan & then back out
    [Tags]                     Config       WAN     wan0  static:  conn static     static_in_out
    [Documentation]            Enters the WAN Static Configuration Mode, then use top & 3 exits to go back to Global Configuration
    ${execute}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    sleep                       1
    ${output}=                 write   conn static     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0 -> Static
    sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-static)#
    should not be empty         ${output}
    #use top to go all the way back into Global Config
    ${output}=                  write   top
    sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config-if-wan0)#   (config)#   (config-if-wan0-static)#
    #use 3 exits to get back to global
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    sleep                       1
    ${output}=                 write   conn static     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0 -> Static
    sleep                       1
    ${exit}=                 write   exit
    sleep                       1
    ${exit}=                 write   exit
    sleep                       1
    ${exit}=                 write   exit
    sleep                       1
    ${exit}=                 write   exit
    sleep                       1
    set client configuration  prompt=#
    ${exit}=         read until prompt
    sleep                       1
    should contain              ${exit}   (global)#
    should not be empty         ${exit}
    should not contain          ${exit}   (config-if-wan0)#   (config)#   (config-if-wan0-static)#

WAN0 static: Execute the mtu for WAN Static
    [Tags]                     Config       WAN     wan0  static  conn_static     static_mtu
    [Documentation]            Enters the WAN Static Configuration Mode and set mtu as 1325
    ${execute}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn static
    ${output}=                 write   mtu 1325     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0 -> Static
    sleep                       1
    ${output}=                 write   show
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    ${read}=                  read
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-static)#    WAN Static Configuration:   MTU=1325
    should not be empty         ${output}
    should not contain          ${output}   MTU=1500
    ${exit}                     write  top

WAN0 static: Execute the dns for WAN Static
    [Tags]                     Config       WAN     wan0  static  conn_static     static_dns
    [Documentation]            Enters the WAN Static Configuration Mode and to set dns as 8.8.8.8
    ${execute}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn static
    ${output}=                 write   dns 8.8.8.8     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0 -> Static
    sleep                       1
    ${output}=                 write   show
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    ${read}=                  read
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-static)#    WAN Static Configuration:   DNS_SERVER1=8.8.8.8
    should not be empty         ${output}
    should not contain          ${output}   DNS_SERVER=
    ${exit}                     write  top

WAN0 static: Execute the ip for WAN Static
    [Tags]                     Config       WAN     wan0  static  conn_static     static_ip
    [Documentation]            Enters the WAN Static Configuration Mode and to set ip as 192.168.0.200
    ${execute}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn static
    ${output}=                 write   ip 192.168.0.200     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0 -> Static
    sleep                       1
    ${output}=                 write   show
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    ${read}=                  read
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-static)#    WAN Static Configuration:   IP_ADDR=192.168.0.200
    should not be empty         ${output}
    should not contain          ${output}   DNS_SERVER=     IP_ADDR=
    ${exit}                     write  top

WAN0 static: Execute the netmask for WAN Static
    [Tags]                     Config       WAN     wan0  static   conn_static     static_netmask
    [Documentation]            Enters the WAN Static Configuration Mode and to set netmask as 255.255.0.0
    ${execute}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn static
    ${output}=                 write   netmask 255.255.0.0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0 -> Static
    sleep                       1
    ${output}=                 write   show
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    ${read}=                  read
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-static)#    WAN Static Configuration:   NETMASK=255.255.0.0
    should not be empty         ${output}
    should not contain          ${output}   DNS_SERVER=     IP_ADDR=    NETMASK=
    ${exit}                     write  top

WAN0 static: Execute the gateway for WAN Static
    [Tags]                     Config       WAN     wan0  static  conn_static     static_gateway
    [Documentation]            Enters the WAN Static Configuration Mode and to set gateway as DEFAULT_GATEWAY=192.168.0.203
    ${execute}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn static
    ${output}=                 write   gateway 192.168.0.203     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0 -> Static
    sleep                       1
    ${output}=                 write   show
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    ${read}=                  read
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-static)#    WAN Static Configuration:   DEFAULT_GATEWAY=192.168.0.203
    should not be empty         ${output}
    should not contain          ${output}   DNS_SERVER=     IP_ADDR=    NETMASK=    DEFAULT_GATEWAY=
    ${exit}                     write  top

#WAN PPPoE
WAN0 PPPoE: Execute connect PPPoE Wan & then back out
    [Tags]                     Config       WAN     wan0  PPPoE   conn pppoe     pppoe_in_out
    [Documentation]            Enters the WAN PPPoE Configuration Mode, then use top & 3 exits to go back to Global Configuration
    ${execute}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    #sleep                       1
    ${output}=                 write   conn pppoe     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0 -> Static
    #sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-pppoe)#
    should not be empty         ${output}
    #use top to go all the way back into Global Config
    ${output}=                  write   top
    #sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config-if-wan0)#   (config)#   (config-if-wan0-pppoe)#
    #use 3 exits to get back to global
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    sleep                       1
    ${output}=                 write   conn pppoe     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0 -> Static
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    #set client configuration  prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config-if-wan0)#   (config)#   (config-if-wan0-pppoe)#

#dns
WAN0 PPPoE: Execute the dns for WAN PPPoE
    [Tags]                     Config       WAN     wan0   PPPoE  conn_pppoe     pppoe_dns
    [Documentation]            Enters the WAN PPPoE Configuration Mode and to set dns as 8.8.8.8
    ${execute}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pppoe
    ${output}=                 write   dns 8.8.8.8     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0 -> Static
    sleep                       1
    ${output}=                 write   apply
    sleep                       1
    ${output}=                 write   show
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    #${read}=                  read
    #set client configuration  prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   (config-if-wan0-pppoe)#    PPPoE Configuration:   DNS_SERVER1=8.8.8.8
    should not be empty         ${output}
    should not contain          ${output}   MTU=1500    DNS_SERVER=     ERROR:
    ${exit}                     write  top

#username & password
WAN0 PPPoE: Execute the username & password for WAN PPPoE
    [Tags]                     Config       WAN     wan0  PPPoE   conn_pppoe     pppoe_username_password
    [Documentation]            Enters the WAN PPPoE Configuration Mode and to set username as leroy_jenkins
    ${execute}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pppoe
    ${output}=                 write   username leroy_jenkins
    sleep                       1
    ${output}=                 write   password atLeastWeHaveChicken
    sleep                       1
    ${output}=                 write   apply
    sleep                       1
    ${output}=                 write   show
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    ${read}=                  read
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-pppoe)#    PPPoE Configuration:   USER_NAME=leroy_jenkins    PASSWORD=atLeastWeHaveChicken
    should not be empty         ${output}
    should not contain          ${output}   MTU=1500    USER_NAME=      PASSWORD=      ERROR:
    ${exit}                     write  top

#mtu
WAN0 PPPoE: Execute the mtu for WAN PPPoE
    [Tags]                     Config       WAN     wan0  PPPoE   conn pppoe  conn_pppoe     pppoe_mtu
    [Documentation]            Enters the WAN Static Configuration Mode and set mtu as 1325
    ${execute}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pppoe
    ${output}=                 write   mtu 1324     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0 -> Static
    sleep                       1
    ${output}=                 write   apply
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    ${read}=                  read
    #set client configuration  prompt=#
    #${output}=         read until prompt
    should contain              ${read}   (config-if-wan0-pppoe)#    PPPoE Configuration:   MTU=1324
    should not be empty         ${read}
    should not contain          ${read}   MTU=1500    ERROR:
    ${exit}                     write  top


#servicename
WAN0 PPPoE: Execute the servicename for WAN PPPoE
    [Tags]                     Config       WAN     wan0  PPPoE   conn_pppoe     pppoe_servicename
    [Documentation]            Enters the WAN PPPoE Configuration Mode and to set servicename as user1-service
    ${execute}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pppoe
    ${output}=                 write   servicename user1-service
    sleep                       1
    ${output}=                 write   apply
    sleep                       1
    ${output}=                 write   show
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    sleep                       1
    #${read}=                  read
    #set client configuration  prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   (config-if-wan0-pppoe)#    PPPoE Configuration:   SERVICE_NAME=user1-service
    should not be empty         ${output}
    should not contain          ${output}   MTU=1500    PASSWORD=
    ${exit}                     write  top

#acname
WAN0 PPPoE: Execute the acname for WAN PPPoE
    [Tags]                     Config       WAN     wan0   PPPoE  conn_pppoe     pppoe_acname
    [Documentation]            Enters the WAN PPPoE Configuration Mode and to set servicename as user1-service
    ${execute}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pppoe
    ${output}=                 write   acname ispl.com
    sleep                       1
    ${output}=                 write   apply
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    #${read}=                  read
    #set client configuration  prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   (config-if-wan0-pppoe)#    PPPoE Configuration:   ACCESS_CONCENTRATOR_NAME=ispl.com
    should not be empty         ${output}
    should not contain          ${output}   MTU=1500    ACCESS_CONCENTRATOR_NAME=
    ${exit}                     write  top

#options
WAN0 PPPoE: Execute the options for WAN PPPoE
    [Tags]                     Config       WAN     wan0  PPPoE  conn_pppoe     pppoe_options
    [Documentation]            Enters the WAN PPPoE Configuration Mode and to set servicename as user1-service
    ${execute}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pppoe
    ${output}=                 write   options ignore-eol-tag
    sleep                       1
    ${output}=                 write   apply
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    #${read}=                  read
    #set client configuration  prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   (config-if-wan0-pppoe)#    PPPoE Configuration:   ADDITIONAL_PPPD_OPTIONS=ignore-eol-tag    SERVICE_NAME=user1-service
    should contain              ${output}   MTU=1324   USER_NAME=leroy_jenkins    PASSWORD=atLeastWeHaveChicken    DNS_SERVER1=8.8.8.8
    should not be empty         ${output}
    should not contain          ${output}   Usage: uci [<options>] <command> [<arguments>]    MTU=1500    ADDITIONAL_PPPD_OPTIONS
    ${exit}                     write  top
#NOTE: After this PPPoE is done, you will need to reset via gui or RESTORE back to DHCP else risk losing Connection

#PPTP
WAN0 PPTP: Enter PPTP and then back out to Global
    [Tags]                      Config       WAN     wan0  PPTP  conn_pptp  conn_pptp_in_out
    [Documentation]             Fire off the conn pptp and then back out via top and then back in and back out via 3 exits
    #configure -> interface ethernet wan0 -> conn pptp
    ${execute}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    #sleep                       1
    ${output}=                 write   conn pptp
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    #use top to go all the way back into Global Config
    ${output}=                  write   top
    #sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config-if-wan0)#   (config)#   (config-if-wan0-pptp)#
    #use 3 exits to get back to global
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    sleep                       1
    ${output}=                 write   conn pptp
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    #set client configuration  prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config-if-wan0)#   (config)#   (config-if-wan0-pptp)#

#NOTE: After this PPTP is done, you will need to reset via gui or RESTORE back to DHCP else risk losing Connection
#PPTP
WAN0 PPTP: Execute All PPTP and then show, followed by apply and then show again
   [Tags]                      Config       WAN     wan0  PPTP  conn_pptp
    [Documentation]             Fire off all PPTP, show, apply and then show again
    ${execute}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pptp
    sleep                       1
    #mtu
    ${output}=                  write  mtu 1433
    sleep                       1
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    #dns
    ${output}=                  write  dns 8.8.8.8
    sleep                       1
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    #ip
    ${output}=                  write  ip 192.168.0.204
    sleep                       1
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    #netmask
    ${output}=                  write  netmask 255.255.0.0
    sleep                       1
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    #gateway
    ${output}=                  write  gateway 255.255.0.0
    sleep                       1
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    #username
    ${output}=                  write  username paul_dirac
    sleep                       1
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    #password
    ${output}=                  write  password futurePurplePeopleEater
    sleep                       1
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    #vpn
    ${output}=                  write  vpn symantec.com
    sleep                       1
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    #hostname
    ${output}=                  write  host yeehaw2
    sleep                       1
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    #defaultroute
    ${output}=                  write  defaultroute enable
    sleep                       1
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    #encrypt mppe
    ${output}=                  write  encrypt mppe128
    sleep                       1
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    #options
    ${output}=                  write  options ttyname
    sleep                       1
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    #show it
    ${output}=                  write  show
    sleep                       1
    ${output}=                  read
    should contain              ${output}   MTU=1433  DNS_SERVER1=8.8.8.8  IP_ADDR=192.168.0.204  (config-if-wan0-pptp)#
    should contain              ${output}   NETMASK=255.255.0.0    USER_NAME=paul_dirac    PASSWORD=futurePurplePeopleEater    VPN_Server=symantec.com
    should contain              ${output}   Hostname=yeehaw2    DEFAULT_ROUTE=Enable    encrypt    ADDITIONAL_PPPD_OPTIONS=ttyname
    #apply it
    ${output}=                  write  apply
    sleep                       2
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    ${output}=                  write  show
    sleep                       2
    ${output}=                  read    #until prompt
    should contain              ${output}   MTU=1433  DNS_SERVER1=8.8.8.8  IP_ADDR=192.168.0.204  (config-if-wan0-pptp)#
    should contain              ${output}   NETMASK=255.255.0.0    USER_NAME=paul_dirac    PASSWORD=futurePurplePeopleEater    VPN_Server=symantec.com
    should contain              ${output}   Hostname=yeehaw2    DEFAULT_ROUTE=Enable    encrypt    ADDITIONAL_PPPD_OPTIONS=ttyname

    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top
#NOTE: After this PPTP is done, you will need to reset via gui or RESTORE back to DHCP else risk losing Connection

#L2TP
WAN0 L2TP: Enter L2TP and then back out to Global
    [Tags]                      Config       WAN     wan0    conn_l2tp  conn_l2tp_in_out    L2TP
    [Documentation]             Fire off the conn l2tp and then back out via top and then back in and back out via 3 exits
    #configure -> interface ethernet wan0 -> conn l2tp
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    sleep                       1
    ${output}=                 write   conn l2tp
    sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    #use top to go all the way back into Global Config
    ${output}=                  write   top
    #sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config-if-wan0)#   (config)#   (config-if-wan0-l2tp)#
    #use 3 exits to get back to global
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    sleep                       1
    ${output}=                 write   conn l2tp
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    #${output}=                 read
    #${output}=                 write   exit
    #sleep                       1
    #set client configuration  prompt=#
    ${global}=                  read    #until prompt
    should contain              ${global}   (global)#
    should not be empty         ${global}
    should not contain          ${global}   (config-if-wan0)#   (config)#   (config-if-wan0-l2tp)#

#NOTE: After this L2TP is done, you will need to reset via gui or RESTORE back to DHCP else risk losing Connection
WAN0 L2TP: Start configuring all one shot & apply   #has problems not showing
    [Tags]                      Config       WAN     wan0  L2TP  conn_l2tp
    [Documentation]             Fire off all commands and then only show and then only apply adn show again. NOTE: Will need to reset via gui or RESTORE back to DHCP else risk losing Connection
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn l2tp
    sleep                       1
    #username
    ${output}=                  write  username ziegler_natta
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    sleep                       1
    #password
    ${output}=                  write  password reduxProcessChemistry
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    sleep                       1
    #mtu
    ${output}=                  write  mtu 1432
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    sleep                       1
    #dns
    ${output}=                  write  dns 192.168.0.205
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    sleep                       1
    #ip
    ${output}=                  write  ip 192.168.0.206
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    sleep                       1
    #netmask
    ${output}=                  write  netmask 255.255.0.0
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]   loglevel=warn
    sleep                       1
    #gateway
    ${output}=                  write  gateway 255.255.0.0
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]   loglevel=warn
    sleep                       1
    #vpn
    ${output}=                  write  vpn macaffee.com
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    sleep                       1
    #hostname
    ${output}=                  write  host yeehaw3
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    sleep                       1
    #defaultroute
    ${output}=                  write  defaultroute enable
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    sleep                       1
    #options
    ${output}=                  write  options ttyname
    should not contain          ${output}   error   ERROR:   ERROR: MTU need set, errno: [-1]
    sleep                       3
    #show
    ${output}=                  write  show
    sleep                       1
    ${read}=                    read
    sleep                       1
    should contain              ${read}   MTU=1432    DNS_SERVER1=192.168.0.205    IP_ADDR=192.168.0.206   (config-if-wan0-l2tp)#
    should contain              ${read}   USER_NAME=ziegler_natta    PASSWORD=reduxProcessChemistry  VPN_Server=macaffee.com    Hostname=yeehaw3
    should contain              ${read}   DEFAULT_ROUTE=Enable    ADDITIONAL_PPPD_OPTIONS=ttyname
    should not contain          ${read}   (config-if-wan0)#   (config)#    ERROR:    error
    sleep                       1
    #apply
    ${apply}=                  write  apply
    sleep                       1
    ${apply}=                    read
    should not contain          ${apply}   ERROR:   ERROR: MTU need set, errno: [-1]
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   MTU=1432    DNS_SERVER1=192.168.0.205    IP_ADDR=192.168.0.206   (config-if-wan0-l2tp)#
    should contain              ${output}   USER_NAME=ziegler_natta    PASSWORD=reduxProcessChemistry  VPN_Server=macaffee.com    Hostname=yeehaw3
    should contain              ${output}   DEFAULT_ROUTE=Enable    ADDITIONAL_PPPD_OPTIONS=ttyname
    should not contain          ${output}   (config-if-wan0)#   (config)#    ERROR:    error
    ${exit}                     write  top
#NOTE: After this L2TP is done, you will need to reset via gui or RESTORE back to DHCP else risk losing Connection

Suite Teardown         Close All Connections
    sleep                       3

Suite Setup            Open Connection And Log In
    sleep                       3

#WLAN 2.4g
WLAN 2.4g: Enter Wifi 2.4g and then back out to Global
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_in_out
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> conn
    ${start}                     write  top
    sleep                       1
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wlan-2.4g)#
    should not contain          ${output}   (config)#   (global)#
    #use top to go all the way back into Global Config
    ${output}=                  write   top
    #sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config)#   (config-if-wlan-2.4g)#
    #use 3 exits to get back to global
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config)#   (config-if-wlan-2.4g)#

WLAN 2.4g: Enter disable
    [Tags]                      Config  WLAN    WLAN2_4g  interface_wifi_2_4g  interface_wifi_2_4g_disable
    [Documentation]             Fire off the disable and check that wifi 2.4g is disabled
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  disable
    sleep                       10
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    #sleep                       1
    should contain              ${output}  (config-if-wlan-2.4g)#
    should not contain          ${output}   (config)#   (global)#
    #need to incorporate a UI robot to check on this in the admin
    ${exit}                     write  top

WLAN 2.4g: Enter enable
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_enable
    [Documentation]             Fire off the enable and check that wifi 2.4g is enabled
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  enable
    sleep                       10
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    sleep                       1
    #should be empty             ${output}
    should contain              ${output}   (config-if-wlan-2.4g)#
    should not contain          ${output}   (config)#   (global)#
    #need to incorporate a UI robot to check on this in the admin
    ${exit}                     write  top

#enter all the security wpa and then back out
WLAN 2.4g WPA: Enter security WPA and then back out
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_security_wpa_in_out
    [Documentation]             Fire off the "security" for wpa - WPA Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  security wpa
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g-wpa)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa)#     (config)#   (config-if-wlan-2.4g)#
    #use one exit to go back to (config-if-wlan-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write   exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa)#     (config)#    (global)#

WLAN 2.4g WPA2: Enter security WPA2 and then back out
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_security_wpa2_in_out
    [Documentation]             Fire off the "security" for wpa2 - WPA2 Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  security wpa2
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g-wpa2)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa2)#     (config)#   (config-if-wlan-2.4g)#
    #use one exit to go back to (config-if-wlan-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa2)#     (config)#    (global)#

WLAN 2.4g WPA3: Enter security WPA3 and then back out
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_security_wpa3_in_out
    [Documentation]             Fire off the "security" for wpa3 - WPA3 Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  security wpa3
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g-wpa3)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa3)#     (config)#   (config-if-wlan-2.4g)#
    #use one exit to go back to (config-if-wlan-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa3)#     (config)#    (global)#

WLAN 2.4g WPA12 mix: Enter security WPA12 Mix and then back out
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_security_wpa12_mix_in_out
    [Documentation]             Fire off the "security" for wpa12_mix - WPA/WPA2 Mix Mode Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  security wpa12_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g-wpa12-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa12-mix)#     (config)#   (config-if-wlan-2.4g)#
    #use one exit to go back to (config-if-wlan-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa12-mix)#     (config)#    (global)#

WLAN 2.4g WPA23 Mix: Enter security WPA23 mix and then back out
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_security_wpa23_mix_in_out
    [Documentation]             Fire off the "security" for wpa23_mix - WPA2/WPA3 Mix Mode Personal
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  security wpa23_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g-wpa23-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa23-mix)#     (config)#   (config-if-wlan-2.4g)#
    #use one exit to go back to (config-if-wlan-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa23-mix)#     (config)#    (global)#

WLAN 2.4g WPA2 enterprise: Enter security WPA2 enterprise and then back out
    [Tags]                      Config  WLAN    WLAN_2_4g   interface_wifi_2_4g  interface_wifi_2_4g_security_wpa2_enterprise_in_out
    [Documentation]             Fire off the "security" for wpa2_enterprise - WPA2 Enterprise and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  security wpa2_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g-wpa2-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa2-ent)#     (config)#   (config-if-wlan-2.4g)#
    #use one exit to go back to (config-if-wlan-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  security wpa2_enterprise
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa2-ent)#     (config)#    (global)#

WLAN 2.4g WPA3 enterprise: Enter security WPA3 enterprise and then back out
    [Tags]                      Config  WLAN    WLAN_2_$g  interface_wifi_2_4g  interface_wifi_2_4g_security_wpa3_enterprise_in_out
    [Documentation]             Fire off the "security" for wpa3_enterprise - WPA3 Enterprise and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g-wpa3-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa3-ent)#     (config)#   (config-if-wlan-2.4g)#
    #use one exit to go back to (config-if-wlan-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa3-ent)#     (config)#    (global)#

WLAN 2.4g WPA12 mix enerprise: Enter security WPA12 mix enterprise and then back out
    [Tags]                      Config  WLAN    WLAN_2_4g   interface_wifi_2_4g  interface_wifi_2_4g_security_wpa12_mix_enterprise_in_out
    [Documentation]             Fire off the "security" for wpa12_mix_enterprise - WPA/WPA2 Mix Mode Enterprise
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g-wpa12-mix-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa12-mix-ent)#     (config)#   (config-if-wlan-2.4g)#
    #use one exit to go back to (config-if-wlan-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa12-mix-ent)#     (config)#    (global)#

#WLAN Guest 2.4g
WLAN Guest 2.4g: Enter WLAN Guest 2.4g and then back out to Global
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_in_out
    [Documentation]             Fire off the interface wifi guest 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi guest 2.4g -> conn
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    #sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config)#   (global)#
    #use top to go all the way back into Global Config
    ${output}=                  write   top
    #sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config)#   (config-if-wlan-guest-2.4g)#
    #use 3 exits to get back to global
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config)#   (config-if-wlan-guest-2.4g)#

WLAN Guest 2.4g: Enter disable
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_disable
    [Documentation]             Fire off the disable and check that wifi 2.4g is disabled
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  disable
    sleep                       10
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    #sleep                       1
    should contain              ${output}  (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config)#   (global)#
    #need to incorporate a UI robot to check on this in the admin
    ${exit}                     write  top

WLAN Guest 2.4g: Enter enable
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_enable
    [Documentation]             Fire off the enable and check that wifi 2.4g is enabled
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  enable
    sleep                       10
    ${output}=                  read
    sleep                       1
    #should be empty             ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config)#   (global)#
    #need to incorporate a UI robot to check on this in the admin
    ${exit}                     write  top

#enter all the security wpa and then back out
WLAN Guest 2.4g WPA: Enter security WPA and then back out
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa_in_out
    [Documentation]             Fire off the "security" for wpa - WPA Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#    (config-if-wlan-2.4g-wpa)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa)#     (config)#   (config-if-wlan-guest-2.4g)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write   exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-guest-2.4g-wpa)#  (config-if-wlan-2.4g-wpa)#     (config)#    (global)#

WLAN Guest 2.4g WPA2: Enter security WPA2 and then back out
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa2_in_out
    [Documentation]             Fire off the "security" for wpa2 - WPA2 Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa2
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa2)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa2)#     (config)#   (config-if-wlan-guest-2.4g-wpa2)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa2)#     (config)#    (global)#

WLAN Guest 2.4g WPA3: Enter security WPA3 and then back out
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa3_in_out
    [Documentation]             Fire off the "security" for wpa3 - WPA3 Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa3
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa3)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa3)#     (config)#   (config-if-wlan-guest-2.4g-wpa3)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-guest-2.4g-wpa3)#    (config-if-wlan-2.4g-wpa3)#     (config)#    (global)#

WLAN Guest 2.4g WPA12 Mix: Enter security WPA12 Mix and then back out
    [Tags]                      Config  WLAN    WLAN2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa12_mix_in_out
    [Documentation]             Fire off the "security" for wpa12_mix - WPA/WPA2 Mix Mode Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa12_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa12-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#  (config-if-wlan-2.4g-wpa12-mix)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa12-mix)#     (config)#   (config-if-wlan-guest-2.4g-wpa12-mix)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa12-mix)#    (config-if-wlan-2.4gx)#     (config)#    (global)#

WLAN Guest 2.4g WPA23 Mix: Enter security WPA23 mix and then back out
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa23_mix_in_out
    [Documentation]             Fire off the "security" for wpa23_mix - WPA2/WPA3 Mix Mode Personal
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa23_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa23-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#  (config-if-wlan-2.4g-wpa23-mix)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa23-mix)#     (config)#   (config-if-wlan-guest-2.4g-wpa23-mix)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa23-mix)#    (config-if-wlan-guest-2.4g-wpa23-mix)#     (config)#    (global)#

WLAN Guest 2.4g WPA2 enterprise: Enter security WPA2 enterprise and then back out
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa2_enterprise_in_out
    [Documentation]             Fire off the "security" for wpa2_enterprise - WPA2 Enterprise and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa2_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa2-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#  (config-if-wlan-2.4g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa2-ent)#     (config)#   (config-if-wlan-guest-2.4g)#    (config-if-wlan-guest-2.4g-wpa2-ent)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa2_enterprise
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa2-ent)#     (config-if-wlan-guest-2.4g-wpa2-ent)#     (config)#    (global)#

WLAN Guest 2.4g WPA3 enterprise: Enter security WPA3 enterprise and then back out
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa3_enterprise_in_out
    [Documentation]             Fire off the "security" for wpa3_enterprise - WPA3 Enterprise and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa3-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#  (config-if-wlan-2.4g-wpa3-ent)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa3-ent)#     (config)#   (config-if-wlan-guest-2.4g)#    (config-if-wlan-guest-2.4g-wpa3-ent)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-guest-2.4g-wpa3-ent)#     (config-if-wlan-2.4g-wpa3-ent)#     (config)#    (global)#

WLAN 2.4g WPA12 Mix enterprise: Enter security WPA12 mix enterprise and then back out
    [Tags]                      Config  WLAN    WLAN_2_4g    interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa12_mix_enterprise_in_out
    [Documentation]             Fire off the "security" for wpa12_mix_enterprise - WPA/WPA2 Mix Mode Enterprise
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa12-mix-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#  (config-if-wlan-2.4g-wpa12-mix-ent)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa12-mix-ent)#     (config)#   (config-if-wlan-guest-2.4g)#   (config-if-wlan-guest-2.4g-wpa12-mix-ent)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-guest-2.4g-wpa12-mix-ent)#    (config-if-wlan-2.4g-wpa12-mix-ent)#     (config)#    (global)#

#WLAN 2.4g: WPA
WLAN 2.4g WPA: Enter WPA personal
    [Tags]                      Config  WLAN  WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa_in_out
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> security wpa
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration WLAN 2.4g
    sleep                       1
    ${output}=                  write  security wpa
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g-wpa)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top


WLAN 2.4g WPA: Set SSID for WPA Personal WLAN 2.4g
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g     interface_wifi_2_4g_wpa_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration WLAN 2.4g
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                 write   ssid Super_Mario_Brothers
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Super_Mario_Brothers
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

WLAN 2.4g WPA: SSID Hide enabled
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa_ssid_hide
    [Documentation]             Fire off the ssid hide and check that wifi 2.4g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration WLAN 2.4g
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

WLAN 2.4g WPA: SSID broadcast
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 2.4g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration WLAN 2.4g
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN 2.4g WPA: Password
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration WLAN 2.4g
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  password YoshiYoshi
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PASSWORD=YoshiYoshi
    ${exit}=                  write   top

WLAN 2.4g WPA: maxclient
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration WLAN 2.4g
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  maxclient 120
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  MAX_CLIENTS=120
    ${exit}=                  write   top

WLAN 2.4g WPA: Rekey key rotation interval
    [Tags]                      Config    WLAN  WLAN_2_4g   interface_wifi_2_4g  interface_wifi_2_4g_wpa_rekey
    [Documentation]             Fire off the rekey and check that it is updated in seconds
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration WLAN 2.4g
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  rekey 3599
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3599s
    ${exit}=                  write   top

#WLAN WPA2 2.4g
WLAN WPA2 2.4g: wpa2 personal
    [Tags]                      Config  WLAN    WLAN_2_4g   interface_wifi_2_4g  interface_wifi_2_4g_wpa2_in_out
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> security wpa2
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa2
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g-wpa2)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    ${exit}                     write  top


WLAN WPA2 2.4g: Set SSID for wpa2 Personal WLAN 2.4g
    [Tags]                      Config  WLAN    WLAN_2_4g   interface_wifi_2_4g     interface_wifi_2_4g_wpa2_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                 write   ssid Wario_Brothers
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Wario_Brothers
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#

WLAN WPA2 2.4g: SSID Hide enabled
    [Tags]                      Config  WLAN    WLAN_2_4g   interface_wifi_2_4g  interface_wifi_2_4g_wpa2_ssid_hide
    [Documentation]             Fire off the ssid hide and check that wifi 2.4g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#

WLAN WPA2 2.4g: SSID broadcast
    [Tags]                      Config  WLAN    WLAN_2_4g   interface_wifi_2_4g  interface_wifi_2_4g_wpa2_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 2.4g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  HIDE_SSID=Disable

WLAN WPA2 2.4g: Password
    [Tags]                      Config  WLAN    WLAN_2_4g   interface_wifi_2_4g  interface_wifi_2_4g_wpa2_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  password PrincessPeach
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PASSWORD=PrincessPeach

WLAN WPA2 2.4g: PMF protected Management Frames
    [Tags]                      Config  WLAN    WLAN_2_4g   interface_wifi_2_4g  interface_wifi_2_4g_wpa2_pmf
    [Documentation]             Fire off the protected management frames and check that pmf is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  pmf required
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PROTECTED_MANAGEMENT_FRAMES=Required

WLAN WPA2 2.4g: maxclient
    [Tags]                      Config  WLAN    WLAN_2_4g   interface_wifi_2_4g  interface_wifi_2_4g_wpa2_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  maxclient 120
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  MAX_CLIENTS=120

WLAN WPA2 2.4g: Rekey key rotation interval
    [Tags]                      Config  WLAN    WLAN_2_4g   interface_wifi_2_4g  interface_wifi_2_4g_wpa2_rekey
    [Documentation]             Fire off the rekey and check that it is updated in seconds
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  rekey 3599
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3599s

#WLAN 2.4g WPA3
WLAN 2.4g WPA3: Enter wpa3 personal
    [Tags]                      Config  WLAN    WLAN_2_4g   interface_wifi_2_4g  interface_wifi_2_4g_wpa3_in_out
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> security wpa3
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g-wpa3)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    ${exit}=                    write   top

WLAN 2.4g WPA3: Set SSID for wpa3 Personal WLAN 2.4g
    [Tags]                      Config  WLAN    WLAN_2_4g   interface_wifi_2_4g     interface_wifi_2_4g_wpa3_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${exit}=                    write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                 write   ssid Luigi
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Luigi
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                    write   top

WLAN 2.4g WPA3: SSID Hide enabled
    [Tags]                      Config  WLAN    WLAN_2_4g   interface_wifi_2_4g  interface_wifi_2_4g_wpa3_ssid_hide
    [Documentation]             Fire off the ssid hide and check that wifi 2.4g is SSID is hidden / disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

WLAN 2.4g WPA3: SSID broadcast
    [Tags]                      Config  WLAN    WLAN_2_4g   interface_wifi_2_4g  interface_wifi_2_4g_wpa3_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 2.4g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN 2.4g WPA3: Password
    [Tags]                      Config  WLAN    WLAN_2_4g   interface_wifi_2_4g  interface_wifi_2_4g_wpa3_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  password MaMaMiaHereIGoAgain
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PASSWORD=MaMaMiaHereIGoAgain
    ${exit}=                  write   top

WLAN 2.4g WPA3: maxclient
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  maxclient 122
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  MAX_CLIENTS=122
    ${exit}=                  write   top

WLAN 2.4g WPA3: Rekey key rotation interval
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_rekey
    [Documentation]             Fire off the rekey and check that i is updated in seconds
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  rekey 3597
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3597s
    ${exit}=                  write   top

#WLAN WPA 12 mix personal 2.4g
WLAN 2.4g WPA12 mix: Enter wpa12_mix personal
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_in_out
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> security wpa12_mix
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g-wpa12-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    ${exit}=                    write   top


WLAN 2.4g WPA12 mix: Set SSID for wpa12_mix Personal WLAN 2.4g
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g     interface_wifi_2_4g_wpa12_mix_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                 write   ssid Pikachu
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Pikachu
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                    write   top

WLAN 2.4g WPA12 mix: SSID Hide enabled
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_ssid_hide
    [Documentation]             Fire off the ssid hdie and check that wifi 2.4g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                    write   top

WLAN 2.4g WPA12 mix: SSID broadcast
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 2.4g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                    write   top

WLAN 2.4g WPA12 mix: Password
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  password IchooseYou
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PASSWORD=IchooseYou
    ${exit}=                    write   top

WLAN 2.4g WPA12 mix: maxclient
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  maxclient 123
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  MAX_CLIENTS=123
    ${exit}=                    write   top

WLAN 2.4g WPA12 mix: Rekey key rotation interval
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_rekey
    [Documentation]             Fire off the rekey and check that it is updated ins econds
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  rekey 3596
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3596s
    ${exit}=                    write   top

#WLAN 2.4g WPA23 Mix personal
WLAN 2.4g WPA23 mix: Enter wpa23_mix personal
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa23_mix_in_out
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> security wpa23_mix
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g-wpa23-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top


WLAN 2.4g WPA23 mix: Set SSID for wpa23_mix Personal WLAN 2.4g
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g     interface_wifi_2_4g_wpa23_mix_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                 write   ssid Pokemon
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Pokemon
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

WLAN 2.4g WPA23 mix: SSID Hide enabled
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa23_mix_ssid_hide
    [Documentation]             Fire off the ssid hide and check that wifi 2.4g is SSID is hidden / disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

WLAN 2.4g WPA23 mix: SSID broadcast
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa23_mix_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 2.4g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN 2.4g WPA23 mix: Password
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa23_mix_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  password GottaCatchThemAll
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PASSWORD=GottaCatchThemAll
    ${exit}=                  write   top

WLAN 2.4g WPA23 mix: maxclient
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa23_mix_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  maxclient 123
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  MAX_CLIENTS=123
    ${exit}=                  write   top

WLAN 2.4g WPA23 mix: Rekey key rotation interval
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa23_mix_rekey
    [Documentation]             Fire off the rekey and check that rekey is updated in seconds
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  rekey 3596
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3596s
    ${exit}=                  write   top

#WLAN 2.4g WPA2 enterprise
WLAN 2.4g WPA2 enterprise: Enter wpa2_enterprise
    [Tags]                      Config  WLAN   WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enterprise_in_out
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> security wpa2_enterprise
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa2_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g-wpa2-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    ${exit}=                    write   top


WLAN 2.4g WPA2 enterprise: Set SSID for wpa2_enterprise WLAN 2.4g
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g     interface_wifi_2_4g_wpa2_enterprise_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                 write   ssid Pokemon
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Pokemon
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

WLAN 2.4g WPA2 enterprise: SSID Hide enabled
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enterprise_ssid_hide
    [Documentation]             Fire off the ssid hide and check that wifi 2.4g is SSID is hidden / disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}  No match found   Syntax error: Illegal parameter   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

WLAN 2.4g WPA2 enterprise: SSID broadcast
    [Tags]                      Config  WLAN    WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enterprise_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 2.4g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN 2.4g WPA2 enterprise: Server IP
    [Tags]                      Config  WLAN    WLAN_2_4g   interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enterprise_server
    [Documentation]             Fire off the server IP and check that it is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  server 192.168.0.253
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  SERVER_IP=192.168.0.253
    ${exit}=                  write   top

WLAN 2.4g WPA2 enterprise: Port forwarding
    [Tags]                      Config     WLAN  WLAN_2_4g  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enterprise_port
    [Documentation]             Fire off the port forwarding and check that it is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  port 1811
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PORT_FORWARD=1811
    ${exit}=                  write   top

WLAN 2.4g WPA2 enterprise: Connection secret
    [Tags]                      Config   WLAN  WLAN_2_4g    interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enterprise_secret
    [Documentation]             Fire off the secret and check that secret is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  secret PowerExtreme!
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  CONNECTION_SECRET=PowerExtreme!
    ${exit}=                  write   top

WLAN 2.4g WPA2 enterprise: PMF protected Management Frames
    [Tags]                      Config   WLAN  WLAN_2_4g    interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enterprise_pmf
    [Documentation]             Fire off the protected management frames and check that pmf is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  pmf required
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PROTECTED_MANAGEMENT_FRAMES=Required
    ${exit}=                  write   top

WLAN 2.4g WPA2 enterprise: maxclient
    [Tags]                      Config   WLAN  WLAN_2_4g    interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enterprise_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  maxclient 123
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  MAX_CLIENTS=123
    ${exit}=                  write   top

WLAN 2.4g WPA2 enterperise: Rekey key rotation interval
    [Tags]                      Config   WLAN  WLAN_2_4g    interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enterprise_rekey
    [Documentation]             Fire off the key rotation and check that upper & lower limits tested & key rotataion is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa2_enterprise
    #lower limit 600 test
    ${output}=                  write  rekey 400
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  rekey must between 600 - 86400
    #upper limit 86400 test
    ${output}=                  write  rekey 90000
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  rekey must between 600 - 86400
    #happy path 3596
    ${output}=                  write  rekey 3596
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3596s
    ${exit}=                  write   top

#WLAN 2.4g WPA3 enterprise
WLAN 2.4g WPA3 enterprise: Enter wpa3_enterprise
    [Tags]                      Config   WLAN  WLAN_2_4g    interface_wifi_2_4g  interface_wifi_2_4g_wpa3_enterprise_in_out
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> security wpa3_enterprise
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g-wpa3-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top


WLAN 2.4g WPA3 enterprise: Set SSID for wpa3_enterprise
    [Tags]                      Config   WLAN  WLAN_2_4g    interface_wifi_2_4g     interface_wifi_2_4g_wpa3_enterprise_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                 write   ssid Smurfs
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Smurfs
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

WLAN 2.4g WPA3 enterprise: SSID Hide enabled
    [Tags]                      Config   WLAN  WLAN_2_4g    interface_wifi_2_4g  interface_wifi_2_4g_wpa3_enterprise_ssid_hide
    [Documentation]             Fire off the ssid hide and check that wifi 2.4g is SSID is hidden / disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}  No match found   Syntax error: Illegal parameter   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

WLAN 2.4g WPA3 enterprise: SSID broadcast
    [Tags]                      Config    WLAN  WLAN_2_4g   interface_wifi_2_4g  interface_wifi_2_4g_wpa3_enterprise_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 2.4g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN 2.4g WPA3 enterprise: Server IP
    [Tags]                      Config   WLAN  WLAN_2_4g    interface_wifi_2_4g  interface_wifi_2_4g_wpa3_enterprise_server
    [Documentation]             Fire off the server ip and check that server ip is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  server 192.168.0.253
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  SERVER_IP=192.168.0.253
    ${exit}=                  write   top

WLAN 2.4g WPA3 enterprise: Port forwarding
    [Tags]                      Config   WLAN  WLAN_2_4g    interface_wifi_2_4g  interface_wifi_2_4g_wpa3_enterprise_port
    [Documentation]             Fire off the port forwarding and check that it is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  port 1809
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PORT_FORWARD=1809
    ${exit}=                  write   top

WLAN 2.4g WPA3 enterprise: Connection secret
    [Tags]                      Config   WLAN  WLAN_2_4g    interface_wifi_2_4g  interface_wifi_2_4g_wpa3_enterprise_secret
    [Documentation]             Fire off the secret and check that secret is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  secret Gargamel321
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  CONNECTION_SECRET=Gargamel321
    ${exit}=                  write   top

WLAN 2.4g WPA3 enterprise: maxclient
    [Tags]                      Config   WLAN  WLAN_2_4g    interface_wifi_2_4g  interface_wifi_2_4g_wpa3_enterprise_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  maxclient 118
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  MAX_CLIENTS=118
    ${exit}=                  write   top

WLAN 2.4g WPA3 enterprise: Rekey key rotation interval
    [Tags]                      Config   WLAN  WLAN_2_4g    interface_wifi_2_4g  interface_wifi_2_4g_wpa3_enterprise_rekey
    [Documentation]             Fire off the rekey and check that rekey is updated in seconds
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    #lower limit 600 test
    ${output}=                  write  rekey 400
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  rekey must between 600 - 86400
    #upper limit 86400 test
    ${output}=                  write  rekey 90000
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  rekey must between 600 - 86400
    #happy path 3596
    ${output}=                  write  rekey 3580
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3580s
    ${exit}=                  write   top

#WLAN 2.4g WPA12 mix enterprise
WLAN 2.4g: Enter wpa12_mix_enterprise
    [Tags]                      Config   WLAN  WLAN_2_4g    interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_enterprise_in_out
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> security wpa12_mix_enterprise
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    #sleep                       1
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g-wpa12-mix-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    ${exit}                     write  top

WLAN 2.4g WPA12 mix enterprise: Set SSID for wpa12_mix_enterprise
    [Tags]                      Config   WLAN  WLAN_2_4g    interface_wifi_2_4g     interface_wifi_2_4g_wpa12_mix_enterprise_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    ${output}=                 write   ssid Snorks
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Snorks
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}                     write  top

WLAN 2.4g WPA12 mix enterprise: SSID Hide enabled
    [Tags]                      Config   WLAN  WLAN_2_4g    interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_enterprise_ssid_hide
    [Documentation]             Fire off the ssid hide and check that wifi 2.4g is SSID is hidden / disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}  No match found   Syntax error: Illegal parameter   (global)#   (config-if-wlan-2.4g)#
    ${exit}                     write  top

WLAN 2.4g WPA12 mix enterprise: SSID broadcast
    [Tags]                      Config   WLAN  WLAN_2_4g    interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_enterprise_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 2.4g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}                     write  top

WLAN 2.4g WPA12 mix enterprise: Server IP
    [Tags]                      Config    WLAN  WLAN_2_4g   interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_enterprise_server
    [Documentation]             Fire off the server IP and check that server ip is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  server 192.168.0.252
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  SERVER_IP=192.168.0.252
    ${exit}                     write  top

WLAN 2.4g WPA12 mix enterprise: Port forwarding
    [Tags]                      Config    WLAN  WLAN_2_4g    WLAN  WLAN_2_4g    interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_enterprise_port
    [Documentation]             Fire off the port forwarding and check that it is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  port 1808
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PORT_FORWARD=1808
    ${exit}                     write  top

WLAN 2.4g WPA12 mix enterprise: Connection secret
    [Tags]                      Config   WLAN  WLAN_2_4g    interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_enterprise_secret
    [Documentation]             Fire off the secret and check that secret is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  secret BestUnderwaterLife
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  CONNECTION_SECRET=BestUnderwaterLife
    ${exit}                     write  top

WLAN 2.4g WPA12 mix enterprise: maxclient
    [Tags]                      Config    WLAN  WLAN_2_4g   interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_enterprise_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa12_mix_enterprise
    #test upper boundary >128
    ${output}=                  write   maxclient 300
    sleep                       1
    ${output}=                  read
    should contain              ${output}   maxclient must between 1 - 128  Syntax error: Illegal parameter
    #test lower boundary <1
    ${output}=                  write   maxclient 0
    sleep                       1
    ${output}=                  read
    should contain              ${output}   maxclient must between 1 - 128  Syntax error: Illegal parameter
    sleep                       1
    #test happy path
    ${output}=                  write  maxclient 117
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  MAX_CLIENTS=117
    ${exit}                     write  top

WLAN 2.4g WPA12 mix enterprise: Rekey key rotation interval
    [Tags]                      Config   WLAN  WLAN_2_4g    interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_enterprise_rekey
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa12_mix_enterprise
    #lower limit 600 test
    ${output}=                  write  rekey 400
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  rekey must between 600 - 86400
    #upper limit 86400 test
    ${output}=                  write  rekey 90000
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  rekey must between 600 - 86400
    #happy path 3596
    ${output}=                  write  rekey 3579
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3579s
    ${exit}                     write  top

Suite Teardown         Close All Connections

Suite Setup            Open Connection And Log In

#WLAN 5g
WLAN 5g: Enter Wifi 5g and then back out to Global
    [Tags]                      Config   WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_in_out
    [Documentation]             Fire off the interface wifi 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 5g -> conn
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wlan-5g)#
    should not contain          ${output}   (config)#   (global)#
    #use top to go all the way back into Global Config
    ${output}=                  write   top
    #sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config)#   (config-if-wlan-5g)#
    #use 3 exits to get back to global
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config)#   (config-if-wlan-5g)#

WLAN 5g: Enter disable
    [Tags]                      Config   WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_disable
    [Documentation]             Fire off the disable and check that wifi 5g is disabled
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    sleep                       1
    ${output}=                  write  disable
    sleep                       10
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    #sleep                       1
    should contain              ${output}  (config-if-wlan-5g)#
    should not contain          ${output}   (config)#   (global)#
    #need to incorporate a UI robot to check on this in the admin
    ${exit}                     write  top

WLAN 5g: Enter enable
    [Tags]                      Config   WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_enable
    [Documentation]             Fire off the enable and check that wifi 5g is enabled
    ${exit}                     write  top
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    sleep                       1
    ${output}=                  write  enable
    sleep                       10
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    sleep                       1
    #should be empty             ${output}
    should contain              ${output}   (config-if-wlan-5g)#
    should not contain          ${output}   (config)#   (global)#
    #need to incorporate a UI robot to check on this in the admin
    ${exit}                     write  top

#5g: Enter all the security wpa and then back out
WLAN 5g: Enter security WPA and then back out
    [Tags]                      Config   WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_security_wpa_in_out
    [Documentation]             Fire off the "security" for wpa - WPA Personal and then back out
    ${exit}                     write  top
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    sleep                       1
    ${output}=                  write  security wpa
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g-wpa)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-5g-wpa)#     (config)#   (config-if-wlan-5g)#
    #use one exit to go back to (config-if-wlan-5g)#
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    #sleep                       1
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write   exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g)#
    should not contain          ${output}   (config-if-wlan-5g-wpa)#     (config)#    (global)#

WLAN 5g: Enter security WPA2 and then back out
    [Tags]                      Config   WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_security_wpa2_in_out
    [Documentation]             Fire off the "security" for wpa2 - WPA2 Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    sleep                       1
    ${output}=                  write  security wpa2
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g-wpa2)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-5g-wpa2)#     (config)#   (config-if-wlan-5g)#
    #use one exit to go back to (config-if-wlan-5g)#
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    #sleep                       1
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g)#
    should not contain          ${output}   (config-if-wlan-5g-wpa2)#     (config)#    (global)#

WLAN 5g: Enter security WPA3 and then back out
    [Tags]                      Config    WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_security_wpa3_in_out
    [Documentation]             Fire off the "security" for wpa3 - WPA3 Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    sleep                       1
    ${output}=                  write  security wpa3
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g-wpa3)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-5g-wpa3)#     (config)#   (config-if-wlan-5g)#
    #use one exit to go back to (config-if-wlan-5g)#
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    #sleep                       1
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g)#
    should not contain          ${output}   (config-if-wlan-5g-wpa3)#     (config)#    (global)#

WLAN 5g: Enter security WPA12 Mix and then back out
    [Tags]                      Config   WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_security_wpa12_mix_in_out
    [Documentation]             Fire off the "security" for wpa12_mix - WPA/WPA2 Mix Mode Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    sleep                       1
    ${output}=                  write  security wpa12_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g-wpa12-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-5g-wpa12-mix)#     (config)#   (config-if-wlan-5g)#
    #use one exit to go back to (config-if-wlan-5g)#
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    #sleep                       1
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g)#
    should not contain          ${output}   (config-if-wlan-5g-wpa12-mix)#     (config)#    (global)#

WLAN 5g: Enter security WPA23 mix and then back out
    [Tags]                      Config   WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_security_wpa23_mix_in_out
    [Documentation]             Fire off the "security" for wpa23_mix - WPA2/WPA3 Mix Mode Personal
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    sleep                       1
    ${output}=                  write  security wpa23_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g-wpa23-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-5g-wpa23-mix)#     (config)#   (config-if-wlan-5g)#
    #use one exit to go back to (config-if-wlan-5g)#
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    #sleep                       1
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g)#
    should not contain          ${output}   (config-if-wlan-5g-wpa23-mix)#     (config)#    (global)#

WLAN 5g: Enter security WPA2 enterprise and then back out
    [Tags]                      Config   WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_security_wpa2_enterprise_in_out
    [Documentation]             Fire off the "security" for wpa2_enterprise - WPA2 Enterprise and then back out
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    sleep                       1
    ${output}=                  write  security wpa2_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g-wpa2-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-5g-wpa2-ent)#     (config)#   (config-if-wlan-5g)#
    #use one exit to go back to (config-if-wlan-5g)#
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    #sleep                       1
    ${output}=                  write  security wpa2_enterprise
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g)#
    should not contain          ${output}   (config-if-wlan-5g-wpa2-ent)#     (config)#    (global)#

WLAN 5g: Enter security WPA3 enterprise and then back out
    [Tags]                      Config   WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_security_wpa3_enterprise_in_out
    [Documentation]             Fire off the "security" for wpa3_enterprise - WPA3 Enterprise and then back out
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    sleep                       1
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g-wpa3-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-5g-wpa3-ent)#     (config)#   (config-if-wlan-5g)#
    #use one exit to go back to (config-if-wlan-5g)#
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    #sleep                       1
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g)#
    should not contain          ${output}   (config-if-wlan-5g-wpa3-ent)#     (config)#    (global)#

WLAN 5g: Enter security WPA12 mix enterprise and then back out
    [Tags]                      Config   WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_security_wpa12_mix_enterprise_in_out
    [Documentation]             Fire off the "security" for wpa12_mix_enterprise - WPA/WPA2 Mix Mode Enterprise
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    sleep                       1
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g-wpa12-mix-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-5g-wpa12-mix-ent)#     (config)#   (config-if-wlan-5g)#
    #use one exit to go back to (config-if-wlan-5g)#
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> WLAN 5g
    #sleep                       1
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g)#
    should not contain          ${output}   (config-if-wlan-5g-wpa12-mix-ent)#     (config)#    (global)#

#WLAN Guest 5g
WLAN 5g Guest: Enter WLAN Guest 5g and then back out to Global
    [Tags]                      Config   WLAN  WLAN_guest_5g    interface_wifi_guest_5g  interface_wifi_guest_5g_in_out
    [Documentation]             Fire off the interface wifi guest 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi guest 5g -> conn
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    #sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wlan-guest-5g)#
    should not contain          ${output}   (config)#   (global)#
    #use top to go all the way back into Global Config
    ${output}=                  write   top
    #sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config)#   (config-if-wlan-guest-5g)#
    #use 3 exits to get back to global
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 5g
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config)#   (config-if-wlan-guest-5g)#

WLAN 5g Guest: Enter disable
    [Tags]                      Config   WLAN  WLAN_guest_5g    interface_wifi_guest_5g  interface_wifi_guest_5g_disable
    [Documentation]             Fire off the disable and check that wifi 5g is disabled
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  disable
    sleep                       10
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    #sleep                       1
    should contain              ${output}  (config-if-wlan-guest-5g)#
    should not contain          ${output}   (config)#   (global)#
    #need to incorporate a UI robot to check on this in the admin
    ${exit}                     write  top

WLAN 5g Guest: Enter enable
    [Tags]                      Config   WLAN  WLAN_guest_5g    interface_wifi_guest_5g  interface_wifi_guest_5g_enable
    [Documentation]             Fire off the enable and check that wifi 5g is enabled
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  enable
    sleep                       10
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    sleep                       1
    #should be empty             ${output}
    should contain              ${output}   (config-if-wlan-guest-5g)#
    should not contain          ${output}   (config)#   (global)#
    #need to incorporate a UI robot to check on this in the admin
    ${exit}                     write  top

#WLAN 5g: Enter all the security wpa and then back out
WLAN 5g Guest: Enter security WPA and then back out
    [Tags]                      Config   WLAN  WLAN_guest_5g    interface_wifi_guest_5g  interface_wifi_guest_5g_security_wpa_in_out
    [Documentation]             Fire off the "security" for wpa - WPA Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g-wpa)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#    (config-if-wlan-5g-wpa)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-5g-wpa)#     (config)#   (config-if-wlan-guest-5g)#
    #use one exit to go back to (config-if-wlan-guest-5g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 5g
    #sleep                       1
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write   exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g)#
    should not contain          ${output}   (config-if-wlan-guest-5g-wpa)#  (config-if-wlan-5g-wpa)#     (config)#    (global)#

WLAN 5g Guest: Enter security WPA2 and then back out
    [Tags]                      Config   WLAN  WLAN_guest_5g    interface_wifi_guest_5g  interface_wifi_guest_5g_security_wpa2_in_out
    [Documentation]             Fire off the "security" for wpa2 - WPA2 Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa2
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g-wpa2)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-5g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-5g-wpa2)#     (config)#   (config-if-wlan-guest-5g-wpa2)#
    #use one exit to go back to (config-if-wlan-guest-5g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 5g
    #sleep                       1
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g)#
    should not contain          ${output}   (config-if-wlan-5g-wpa2)#     (config)#    (global)#

WLAN 5g Guest: Enter security WPA3 and then back out
    [Tags]                      Config   WLAN  WLAN_guest_5g    interface_wifi_guest_5g  interface_wifi_guest_5g_security_wpa3_in_out
    [Documentation]             Fire off the "security" for wpa3 - WPA3 Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa3
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g-wpa3)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-5g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-5g-wpa3)#     (config)#   (config-if-wlan-guest-5g-wpa3)#
    #use one exit to go back to (config-if-wlan-guest-5g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 5g
    #sleep                       1
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g)#
    should not contain          ${output}   (config-if-wlan-guest-5g-wpa3)#    (config-if-wlan-5g-wpa3)#     (config)#    (global)#

WLAN 5g Guest: Enter security WPA12 Mix and then back out
    [Tags]                      Config   WLAN  WLAN_guest_5g    interface_wifi_guest_5g  interface_wifi_guest_5g_security_wpa12_mix_in_out
    [Documentation]             Fire off the "security" for wpa12_mix - WPA/WPA2 Mix Mode Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa12_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g-wpa12-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-5g)#  (config-if-wlan-5g-wpa12-mix)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-5g-wpa12-mix)#     (config)#   (config-if-wlan-guest-5g-wpa12-mix)#
    #use one exit to go back to (config-if-wlan-guest-5g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 5g
    #sleep                       1
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g)#
    should not contain          ${output}   (config-if-wlan-5g-wpa12-mix)#    (config-if-wlan-5gx)#     (config)#    (global)#

WLAN 5g Guest: Enter security WPA23 mix and then back out
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_security_wpa23_mix_in_out
    [Documentation]             Fire off the "security" for wpa23_mix - WPA2/WPA3 Mix Mode Personal
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa23_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g-wpa23-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-5g)#  (config-if-wlan-5g-wpa23-mix)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-5g-wpa23-mix)#     (config)#   (config-if-wlan-guest-5g-wpa23-mix)#
    #use one exit to go back to (config-if-wlan-guest-5g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 5g
    #sleep                       1
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g)#
    should not contain          ${output}   (config-if-wlan-5g-wpa23-mix)#    (config-if-wlan-guest-5g-wpa23-mix)#     (config)#    (global)#

WLAN 5g Guest: Enter security WPA2 enterprise and then back out
    [Tags]                      Config   WLAN  WLAN_guest_5g     interface_wifi_guest_5g  interface_wifi_guest_5g_security_wpa2_enterprise_in_out
    [Documentation]             Fire off the "security" for wpa2_enterprise - WPA2 Enterprise and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa2_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g-wpa2-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-5g)#  (config-if-wlan-5g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-5g-wpa2-ent)#     (config)#   (config-if-wlan-guest-5g)#    (config-if-wlan-guest-5g-wpa2-ent)#
    #use one exit to go back to (config-if-wlan-guest-5g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 5g
    #sleep                       1
    ${output}=                  write  security wpa2_enterprise
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g)#
    should not contain          ${output}   (config-if-wlan-5g-wpa2-ent)#     (config-if-wlan-guest-5g-wpa2-ent)#     (config)#    (global)#

WLAN 5g Guest: Enter security WPA3 enterprise and then back out
    [Tags]                      Config   WLAN  WLAN_guest_5g    interface_wifi_guest_5g  interface_wifi_guest_5g_security_wpa3_enterprise_in_out
    [Documentation]             Fire off the "security" for wpa3_enterprise - WPA3 Enterprise and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g-wpa3-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-5g)#  (config-if-wlan-5g-wpa3-ent)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-5g-wpa3-ent)#     (config)#   (config-if-wlan-guest-5g)#    (config-if-wlan-guest-5g-wpa3-ent)#
    #use one exit to go back to (config-if-wlan-guest-5g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 5g
    #sleep                       1
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g)#
    should not contain          ${output}   (config-if-wlan-guest-5g-wpa3-ent)#     (config-if-wlan-5g-wpa3-ent)#     (config)#    (global)#

WLAN 5g Guest: Enter security WPA12 mix enterprise and then back out
    [Tags]                      Config    WLAN  WLAN_guest_5g    interface_wifi_guest_5g  interface_wifi_guest_5g_security_wpa12_mix_enterprise_in_out
    [Documentation]             Fire off the "security" for wpa12_mix_enterprise - WPA/WPA2 Mix Mode Enterprise
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g-wpa12-mix-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-5g)#  (config-if-wlan-5g-wpa12-mix-ent)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-5g-wpa12-mix-ent)#     (config)#   (config-if-wlan-guest-5g)#   (config-if-wlan-guest-5g-wpa12-mix-ent)#
    #use one exit to go back to (config-if-wlan-guest-5g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 5g
    #sleep                       1
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g)#
    should not contain          ${output}   (config-if-wlan-guest-5g-wpa12-mix-ent)#    (config-if-wlan-5g-wpa12-mix-ent)#     (config)#    (global)#

#WLAN 5g WPA Personal
WLAN 5g WPA personal: Enter WPA personal
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa_enter
    [Documentation]             Fire off the interface wifi 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 5g -> security wpa
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g-wpa)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    ${exit}=                  write   top


WLAN 5g WPA personal: Set SSID for WPA Personal WLAN 5g
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g     interface_wifi_5g_wpa_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                 write   ssid Super_Mario_Brothers
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Super_Mario_Brothers
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN 5g WPA personal: SSID Hide enabled
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa_ssid_hide
    [Documentation]             Fire off the ssid hide and check that wifi 5g is SSID is hidden / disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN 5g WPA personal: SSID broadcast
    [Tags]                      Config     WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_wpa_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 5g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN 5g WPA personal: Password
    [Tags]                      Config     WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_wpa_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  password YoshiYoshi
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PASSWORD=YoshiYoshi
    ${exit}=                  write   top

WLAN 5g WPA personal: maxclient
    [Tags]                      Config     WLAN  WLAN_5g     WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  maxclient 120
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  MAX_CLIENTS=120
    ${exit}=                  write   top

WLAN 5g WPA personal: Rekey key rotation interval
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa_rekey
    [Documentation]             Fire off the rekey and check that rekey is updated ins econds
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  rekey 3599
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3599s
    ${exit}=                  write   top

#WLAN WPA2 personal 5g
WLAN WPA2 5g personal: wpa2 personal
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa2_enter
    [Documentation]             Fire off the interface wifi 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 5g -> security wpa2
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa2
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g-wpa2)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    ${exit}                     write  top


WLAN WPA2 5g personal: Set SSID for wpa2 Personal WLAN 5g
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g     interface_wifi_5g_wpa2_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                 write   ssid Wario_Brothers
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Wario_Brothers
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}                     write  top

WLAN WPA2 5g personal: SSID Hide enabled
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa2_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 5g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}                     write  top

WLAN WPA2 5g personal: SSID broadcast
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa2_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 5g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}                     write  top

WLAN WPA2 5g personal: Password
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa2_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  password PrincessPeach
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PASSWORD=PrincessPeach
    ${exit}                     write  top

WLAN WPA2 5g personal: PMF protected Management Frames
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa2_pmf
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  pmf required
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PROTECTED_MANAGEMENT_FRAMES=Required
    ${exit}                     write  top

WLAN WPA2 5g personal: maxclient
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa2_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  maxclient 120
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  MAX_CLIENTS=120
    ${exit}                     write  top

WLAN WPA2 5g personal: Rekey key rotation interval
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa2_rekey
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  rekey 3599
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3599s
    ${exit}                     write  top

#WLAN 5g WPA3 personal
WLAN 5g WPA3 personal: Enter wpa3 personal
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa3_enter
    [Documentation]             Fire off the interface wifi 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 5g -> security wpa3
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa3
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g-wpa3)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    ${exit}=                    write   top

WLAN 5g WPA3 personal: Set SSID for wpa3 Personal WLAN 5g
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g     interface_wifi_5g_wpa3_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${exit}=                    write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                 write   ssid Luigi
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Luigi
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                    write   top

WLAN 5g WPA3 personal: SSID Hide enabled
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa3_ssid_hide
    [Documentation]             Fire off the ssaid hide and check that wifi 5g is SSID is hidden / disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN 5g WPA3 personal: SSID broadcast
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa3_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 5g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN 5g WPA3 personal: Password
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa3_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  password MaMaMiaHereIGoAgain
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PASSWORD=MaMaMiaHereIGoAgain
    ${exit}=                  write   top

WLAN 5g WPA3 personal: maxclient
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa3_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  maxclient 122
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  MAX_CLIENTS=122
    ${exit}=                  write   top

WLAN 5g WPA3 personal: Rekey key rotation interval
    [Tags]                      Config     WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_wpa3_rekey
    [Documentation]             Fire off the rekey and check that rekey is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  rekey 3597
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3597s
    ${exit}=                  write   top

#WLAN WPA 12 mix personal 5g
WLAN 5g WPA12 mix personal: Enter wpa12_mix personal
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa12_mix_enter
    [Documentation]             Fire off the interface wifi 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 5g -> security wpa12_mix
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g-wpa12-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    ${exit}=                    write   top


WLAN 5g WPA12 mix personal: Set SSID for wpa12_mix Personal WLAN 5g
    [Tags]                      Config    WLAN  WLAN_5g   interface_wifi_5g     interface_wifi_5g_wpa12_mix_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                 write   ssid Pikachu
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Pikachu
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                    write   top

WLAN 5g WPA12 mix personal: SSID Hide enabled
    [Tags]                      Config    WLAN  WLAN_5g  interface_wifi_5g  interface_wifi_5g_wpa12_mix_ssid_hide
    [Documentation]             Fire off the ssid hide and check that wifi 5g is SSID is hidden / disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                    write   top

WLAN 5g WPA12 mix personal: SSID broadcast
    [Tags]                      Config    WLAN  WLAN_5g  interface_wifi_5g  interface_wifi_5g_wpa12_mix_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 5g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                    write   top

WLAN 5g WPA12 mix personal: Password
    [Tags]                      Config   WLAN  WLAN_5g  interface_wifi_5g  interface_wifi_5g_wpa12_mix_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  password IchooseYou
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PASSWORD=IchooseYou
    ${exit}=                    write   top

WLAN 5g WPA12 mix personal: maxclient
    [Tags]                      Config     WLAN  WLAN_5g  interface_wifi_5g  interface_wifi_5g_wpa12_mix_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  maxclient 123
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  MAX_CLIENTS=123
    ${exit}=                    write   top

WLAN 5g WPA12 mix personal: Rekey key rotation interval
    [Tags]                      Config    WLAN  WLAN_5g interface_wifi_5g  interface_wifi_5g_wpa12_mix_rekey
    [Documentation]             Fire off the rekey and check that rekey is updated in seconds
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  rekey 3596
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3596s
    ${exit}=                    write   top

#WLAN 5g WPA23 Mix personal
WLAN 5g WPA23 mix personal: Enter wpa23_mix personal
    [Tags]                      Config     WLAN  WLAN_5g  interface_wifi_5g  interface_wifi_5g_wpa23_mix_enter
    [Documentation]             Fire off the interface wifi 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 5g -> security wpa23_mix
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g-wpa23-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    ${exit}=                  write   top


WLAN 5g WPA23 mix personal: Set SSID for wpa23_mix Personal WLAN 5g
    [Tags]                      Config     WLAN  WLAN_5g  interface_wifi_5g     interface_wifi_5g_wpa23_mix_ssid
    [Documentation]             Fire off the ssid name and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                 write   ssid Pokemon
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Pokemon
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN 5g WPA23 mix personal: SSID Hide enabled
    [Tags]                      Config     WLAN  WLAN_5g  interface_wifi_5g  interface_wifi_5g_wpa23_mix_ssid_hide
    [Documentation]             Fire off the ssid hide and check that wifi 5g is SSID is hidden / disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN 5g WPA23 mix personal: SSID broadcast
    [Tags]                      Config     WLAN  WLAN_5g  interface_wifi_5g  interface_wifi_5g_wpa23_mix_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 5g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN 5g WPA23 mix personal: Password
    [Tags]                      Config     WLAN  WLAN_5g  interface_wifi_5g  interface_wifi_5g_wpa23_mix_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  password GottaCatchThemAll
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PASSWORD=GottaCatchThemAll
    ${exit}=                  write   top

WLAN 5g WPA23 mix personal: maxclient
    [Tags]                      Config     WLAN  WLAN_5g  interface_wifi_5g  interface_wifi_5g_wpa23_mix_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  maxclient 123
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  MAX_CLIENTS=123
    ${exit}=                  write   top

WLAN 5g WPA23 mix personal: Rekey key rotation interval
    [Tags]                      Config      WLAN  WLAN_5g interface_wifi_5g  interface_wifi_5g_wpa23_mix_rekey
    [Documentation]             Fire off the rekey and check that rekey is updated in seconds
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  rekey 3596
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3596s
    ${exit}=                  write   top

#WLAN 5g WPA2 enterprise
WLAN 5g WPA2 Enterprise: Enter wpa2_enterprise
    [Tags]                      Config     WLAN  WLAN_5g  interface_wifi_5g  interface_wifi_5g_wpa2_enterprise_enter
    [Documentation]             Fire off the interface wifi 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 5g -> security wpa2_enterprise
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa2_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g-wpa2-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    ${exit}=                    write   top


WLAN 5g WPA2 Enterprise: Set SSID for wpa2_enterprise WLAN 5g
    [Tags]                      Config     WLAN  WLAN_5g   interface_wifi_5g     interface_wifi_5g_wpa2_enterprise_ssid
    [Documentation]             Fire off the ssid name and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                 write   ssid Pokemon
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Pokemon
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN 5g WPA2 Enterprise: SSID Hide enabled
    [Tags]                      Config      WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_wpa2_enterprise_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 5g is SSID is hidden / disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}  No match found   Syntax error: Illegal parameter   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN 5g WPA2 Enterprise: SSID broadcast
    [Tags]                      Config     WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa2_enterprise_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 5g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN 5g WPA2 Enterprise: Server IP
    [Tags]                      Config     WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa2_enterprise_server
    [Documentation]             Fire off the server ip and check that server ip is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  server 192.168.0.253
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  SERVER_IP=192.168.0.253
    ${exit}=                  write   top

WLAN 5g WPA2 Enterprise: Port forwarding
    [Tags]                      Config     WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_wpa2_enterprise_port
    [Documentation]             Fire off the port forwarding and check that port forwarding is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  port 1811
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PORT_FORWARD=1811
    ${exit}=                  write   top

WLAN 5g WPA2 Enterprise: Connection secret
    [Tags]                      Config     WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_wpa2_enterprise_secret
    [Documentation]             Fire off the secret and check that secret is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  secret PowerExtreme!
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  CONNECTION_SECRET=PowerExtreme!
    ${exit}=                  write   top

WLAN 5g WPA2 Enterprise: PMF protected Management Frames
    [Tags]                      Config    WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa2_enterprise_pmf
    [Documentation]             Fire off the protected management frames and check that pmf is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  pmf required
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PROTECTED_MANAGEMENT_FRAMES=Required
    ${exit}=                  write   top

WLAN 5g WPA2 Enterprise: maxclient
    [Tags]                      Config   WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_wpa2_enterprise_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  maxclient 123
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  MAX_CLIENTS=123
    ${exit}=                  write   top

WLAN 5g WPA2 Enterprise: Rekey key rotation interval
    [Tags]                      Config    WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_wpa2_enterprise_rekey
    [Documentation]             Fire off the key rotation and check that upper & lower limits tested & key rotataion is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa2_enterprise
    #lower limit 600 test
    ${output}=                  write  rekey 400
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  rekey must between 600 - 86400
    #upper limit 86400 test
    ${output}=                  write  rekey 90000
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  rekey must between 600 - 86400
    #happy path 3596
    ${output}=                  write  rekey 3596
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3596s
    ${exit}=                  write   top

#WLAN 5g WPA3 enterprise
WLAN 5g: Enter wpa3_enterprise
    [Tags]                      Config    WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_wpa3_enterprise_enter
    [Documentation]             Fire off the interface wifi 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 5g -> security wpa3_enterprise
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g-wpa3-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    ${exit}=                  write   top


WLAN 5g: Set SSID for wpa3_enterprise
    [Tags]                      Config    WLAN  WLAN_5g   interface_wifi_5g     interface_wifi_5g_wpa3_enterprise_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                 write   ssid Smurfs
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Smurfs
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN 5g WPA3 enterprise: SSID Hide enabled
    [Tags]                      Config    WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_wpa3_enterprise_ssid_hide
    [Documentation]             Fire off the ssid hide and check that wifi 5g is SSID is hidden / disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}  No match found   Syntax error: Illegal parameter   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN 5g WPA3 enterprise: SSID broadcast
    [Tags]                      Config    WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_wpa3_enterprise_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 5g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN 5g WPA3 enterprise: Server IP
    [Tags]                      Config    WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_wpa3_enterprise_server
    [Documentation]             Fire off the server ip and check that server ip is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  server 192.168.0.253
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  SERVER_IP=192.168.0.253
    ${exit}=                  write   top

WLAN 5g WPA3 enterprise: Port forwarding
    [Tags]                      Config    WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_wpa3_enterprise_port
    [Documentation]             Fire off the port forwarding and check that port forwarding is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  port 1809
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PORT_FORWARD=1809
    ${exit}=                  write   top

WLAN 5g WPA3 enterprise: Connection secret
    [Tags]                      Config   WLAN  WLAN_5g      interface_wifi_5g  interface_wifi_5g_wpa3_enterprise_secret
    [Documentation]             Fire off the secret and check that secret is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  secret Gargamel321
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  CONNECTION_SECRET=Gargamel321
    ${exit}=                  write   top

WLAN 5g WPA3 enterprise: maxclient
    [Tags]                      Config   WLAN  WLAN_5g      WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_wpa3_enterprise_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  maxclient 118
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  MAX_CLIENTS=118
    ${exit}=                  write   top

WLAN 5g WPA3 enterprise: Rekey key rotation interval
    [Tags]                      Config    WLAN  WLAN_5g     interface_wifi_5g  interface_wifi_5g_wpa3_enterprise_rekey
    [Documentation]             Fire off the rekey and check that rekey is updated inseconds, also test upper & lower limits
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    #lower limit 600 test
    ${output}=                  write  rekey 400
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  rekey must between 600 - 86400
    #upper limit 86400 test
    ${output}=                  write  rekey 90000
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  rekey must between 600 - 86400
    #happy path 3596
    ${output}=                  write  rekey 3580
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3580s
    ${exit}=                  write   top

#WLAN 5g WPA12 mix enterprise
WLAN 5g: Enter wpa12_mix_enterprise
    [Tags]                      Config   WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa12_mix_enterprise_enter
    [Documentation]             Fire off the interface wifi 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 5g -> security wpa12_mix_enterprise
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    #sleep                       1
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g-wpa12-mix-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    ${exit}                     write  top


WLAN 5g WPA12 mix enterprise: Set SSID for wpa12_mix_enterprise
    [Tags]                      Config    WLAN  WLAN_5g   interface_wifi_5g     interface_wifi_5g_wpa12_mix_enterprise_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    ${output}=                 write   ssid Snorks
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Snorks
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}                     write  top

WLAN 5g WPA12 mix enterprise: SSID Hide enabled
    [Tags]                      Config    WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_wpa12_mix_enterprise_ssid_hide
    [Documentation]             Fire off the ssid hide and check that wifi 5g is SSID is hidden / disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}  No match found   Syntax error: Illegal parameter   (global)#   (config-if-wlan-5g)#
    ${exit}                     write  top

WLAN 5g WPA12 mix enterprise: SSID broadcast
    [Tags]                      Config    WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_wpa12_mix_enterprise_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 5g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}                     write  top

WLAN 5g WPA12 mix enterprise: Server IP
    [Tags]                      Config   WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa12_mix_enterprise_server
    [Documentation]             Fire off the server ip and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  server 192.168.0.252
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  SERVER_IP=192.168.0.252
    ${exit}                     write  top

WLAN 5g WPA12 mix enterprise: Port forwarding
    [Tags]                      Config   WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa12_mix_enterprise_port
    [Documentation]             Fire off the port  and check that port forwarding is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  port 1808
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PORT_FORWARD=1808
    ${exit}                     write  top

WLAN 5g WPA12 mix enterprise: Connection secret
    [Tags]                      Config    WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_wpa12_mix_enterprise_secret
    [Documentation]             Fire off the secret and check that secret is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  secret BestUnderwaterLife
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  CONNECTION_SECRET=BestUnderwaterLife
    ${exit}                     write  top

WLAN 5g WPA12 mix enterprise: maxclient
    [Tags]                      Config   WLAN  WLAN_5g    interface_wifi_5g  interface_wifi_5g_wpa12_mix_enterprise_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix_enterprise
    #test upper boundary >128
    ${output}=                  write   maxclient 300
    sleep                       1
    ${output}=                  read
    should contain              ${output}   maxclient must between 1 - 128  Syntax error: Illegal parameter
    #test lower boundary <1
    ${output}=                  write   maxclient 0
    sleep                       1
    ${output}=                  read
    should contain              ${output}   maxclient must between 1 - 128  Syntax error: Illegal parameter
    sleep                       1
    #test happy path
    ${output}=                  write  maxclient 117
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  MAX_CLIENTS=117
    ${exit}                     write  top
    

WLAN 5g WPA12 mix enterprise: Rekey key rotation interval
    [Tags]                      Config   WLAN  WLAN_5g   interface_wifi_5g  interface_wifi_5g_wpa12_mix_enterprise_rekey
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix_enterprise
    #lower limit 600 test
    ${output}=                  write  rekey 400
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  rekey must between 600 - 86400
    #upper limit 86400 test
    ${output}=                  write  rekey 90000
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  rekey must between 600 - 86400
    #happy path 3596
    ${output}=                  write  rekey 3579
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3579s
    ${exit}                     write  top
    

#WLAN Guest 5g
WLAN Guest 5g: Enter WLAN Guest 5g and then back out to Global
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_in_out
    [Documentation]             Fire off the interface wifi guest 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi guest 5g -> conn
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    #sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wlan-guest-5g)#
    should not contain          ${output}   (config)#   (global)#
    #use top to go all the way back into Global Config
    ${output}=                  write   top
    #sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config)#   (config-if-wlan-guest-5g)#
    #use 3 exits to get back to global
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config)#   (config-if-wlan-guest-2.4g)#

WLAN Guest 5g: Enter disable
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_disable
    [Documentation]             Fire off the disable and check that wifi 2.4g is disabled
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  disable
    sleep                       10
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    #sleep                       1
    should contain              ${output}  (config-if-wlan-guest-5g)#
    should not contain          ${output}   (config)#   (global)#
    #need to incorporate a UI robot to check on this in the admin
    ${exit}                     write  top

WLAN Guest 5g: Enter enable
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_enable
    [Documentation]             Fire off the enable and check that wifi 5g is enabled
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  enable
    sleep                       10
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    sleep                       1
    #should be empty             ${output}
    should contain              ${output}   (config-if-wlan-guest-5g)#
    should not contain          ${output}   (config)#   (global)#
    #need to incorporate a UI robot to check on this in the admin
    ${exit}                     write  top

#WLAN Guest 5g: Enter  all the security wpa and then back out
WLAN Guest 5g: Enter security WPA and then back out
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_security_wpa_in_out
    [Documentation]             Fire off the "security" for wpa - WPA Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#    (config-if-wlan-2.4g-wpa)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa)#     (config)#   (config-if-wlan-guest-2.4g)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write   exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-guest-2.4g-wpa)#  (config-if-wlan-2.4g-wpa)#     (config)#    (global)#

WLAN Guest 2.4g: Enter security WPA2 and then back out
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa2_in_out
    [Documentation]             Fire off the "security" for wpa2 - WPA2 Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa2
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa2)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa2)#     (config)#   (config-if-wlan-guest-2.4g-wpa2)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa2)#     (config)#    (global)#

WLAN Guest 2.4g: Enter security WPA3 and then back out
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa3_in_out
    [Documentation]             Fire off the "security" for wpa3 - WPA3 Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa3
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa3)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa3)#     (config)#   (config-if-wlan-guest-2.4g-wpa3)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-guest-2.4g-wpa3)#    (config-if-wlan-2.4g-wpa3)#     (config)#    (global)#

WLAN Guest 2.4g: Enter security WPA12 Mix and then back out
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa12_mix_in_out
    [Documentation]             Fire off the "security" for wpa12_mix - WPA/WPA2 Mix Mode Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa12_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa12-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#  (config-if-wlan-2.4g-wpa12-mix)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa12-mix)#     (config)#   (config-if-wlan-guest-2.4g-wpa12-mix)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa12-mix)#    (config-if-wlan-2.4gx)#     (config)#    (global)#

WLAN Guest 2.4g: Enter security WPA23 mix and then back out
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa23_mix_in_out
    [Documentation]             Fire off the "security" for wpa23_mix - WPA2/WPA3 Mix Mode Personal
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa23_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa23-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#  (config-if-wlan-2.4g-wpa23-mix)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa23-mix)#     (config)#   (config-if-wlan-guest-2.4g-wpa23-mix)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa23-mix)#    (config-if-wlan-guest-2.4g-wpa23-mix)#     (config)#    (global)#

WLAN Guest 2.4g: Enter security WPA2 WLAN Guest 2.4g: Enterprise and then back out
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa2_enterprise_in_out
    [Documentation]             Fire off the "security" for wpa2_enterprise - WPA2 WLAN Guest 2.4g: Enterprise and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa2_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa2-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#  (config-if-wlan-2.4g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa2-ent)#     (config)#   (config-if-wlan-guest-2.4g)#    (config-if-wlan-guest-2.4g-wpa2-ent)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa2_enterprise
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa2-ent)#     (config-if-wlan-guest-2.4g-wpa2-ent)#     (config)#    (global)#

WLAN Guest 2.4g: Enter security WPA3 WLAN Guest 2.4g: Enterprise and then back out
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa3_enterprise_in_out
    [Documentation]             Fire off the "security" for wpa3_enterprise - WPA3 WLAN Guest 2.4g: Enterprise and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa3-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#  (config-if-wlan-2.4g-wpa3-ent)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa3-ent)#     (config)#   (config-if-wlan-guest-2.4g)#    (config-if-wlan-guest-2.4g-wpa3-ent)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-guest-2.4g-wpa3-ent)#     (config-if-wlan-2.4g-wpa3-ent)#     (config)#    (global)#

WLAN Guest 2.4g: Enter security WPA12 mix WLAN Guest 2.4g: Enterprise and then back out
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa12_mix_enterprise_in_out
    [Documentation]             Fire off the "security" for wpa12_mix_enterprise - WPA/WPA2 Mix Mode WLAN Guest 2.4g: Enterprise
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa12-mix-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#  (config-if-wlan-2.4g-wpa12-mix-ent)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa12-mix-ent)#     (config)#   (config-if-wlan-guest-2.4g)#   (config-if-wlan-guest-2.4g-wpa12-mix-ent)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-guest-2.4g-wpa12-mix-ent)#    (config-if-wlan-2.4g-wpa12-mix-ent)#     (config)#    (global)#

#WLAN Guest 2.4g: WPA
WLAN Guest 2.4g: WPA Enter WPA personal
    [Tags]                      Config    WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa_enter
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> security wpa
    ${output}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration WLAN Guest 2.4g
    sleep                       1
    ${output}=                  write  security wpa
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top


WLAN Guest 2.4g: WPA Set SSID for WPA Personal WLAN Guest 2.4g
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g     interface_wifi_guest_2_4g_wpa_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration WLAN Guest 2.4g
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                 write   ssid Super_Mario_Brothers
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Super_Mario_Brothers
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

WLAN Guest 2.4g: WPA SSID Hide enabled
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 2.4g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration WLAN Guest 2.4g
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

WLAN Guest 2.4g: WPA SSID broadcast
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 2.4g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration WLAN Guest 2.4g
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN Guest 2.4g: WPA Password
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration WLAN Guest 2.4g
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  password YoshiYoshi
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PASSWORD=YoshiYoshi
    ${exit}=                  write   top

WLAN Guest 2.4g: WPA maxclient
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration WLAN Guest 2.4g
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  maxclient 33
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  MAX_CLIENTS=33
    ${exit}=                  write   top

WLAN Guest 2.4g: WPA Rekey key rotation interval
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa_rekey
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration WLAN Guest 2.4g
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  rekey 3599
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3599s
    ${exit}=                  write   top

#exit from WLAN WPA 2.4g
Exit from WLAN Guest 2.4g WPA
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g     interface_wifi_guest_2_4g_wpa_exit
    [Documentation]            Exit the WLAN Guest 2.4g Configuration Mode via "top" command and land at Global vonfiguration level
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#

#WLAN Guest 2.4g WPA3
WLAN Guest 2.4g WPA3: Enter wpa3 personal
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa3_enter
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> security wpa3
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa3)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    ${exit}=                    write   top

WLAN Guest 2.4g WPA3: Set SSID for wpa3 Personal WLAN 2.4g
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g     interface_wifi_guest_2_4g_wpa3_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${exit}=                    write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                 write   ssid Luigi
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Luigi
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                    write   top

WLAN Guest 2.4g WPA3: SSID Hide enabled
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa3_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 2.4g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

WLAN Guest 2.4g WPA3: SSID broadcast
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa3_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 2.4g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN Guest 2.4g WPA3: Password
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa3_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  password MaMaMiaHereIGoAgain
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PASSWORD=MaMaMiaHereIGoAgain
    ${exit}=                  write   top

WLAN Guest 2.4g WPA3: maxclient
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa3_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  maxclient 34
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  MAX_CLIENTS=34
    ${exit}=                  write   top

WLAN Guest 2.4g WPA3: Rekey key rotation interval
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa3_rekey
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  rekey 3597
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3597s
    ${exit}=                  write   top

#WLAN WPA 12 mix personal guest 2.4g
WLAN Guest 2.4g: Enter wpa12_mix personal
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa12_mix_enter
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> security wpa12_mix
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa12-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    ${exit}=                    write   top


WLAN Guest 2.4g: Set SSID for wpa12_mix Personal WLAN 2.4g
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g     interface_wifi_guest_2_4g_wpa12_mix_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                 write   ssid Pikachu
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Pikachu
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                    write   top

WLAN Guest 2.4g: SSID Hide enabled
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa12_mix_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 2.4g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                    write   top

WLAN Guest 2.4g: SSID broadcast
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa12_mix_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 2.4g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                    write   top

WLAN Guest 2.4g: Password
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa12_mix_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  password IchooseYou
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PASSWORD=IchooseYou
    ${exit}=                    write   top

WLAN Guest 2.4g: maxclient
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa12_mix_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  maxclient 35
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  MAX_CLIENTS=35
    ${exit}=                    write   top

WLAN Guest 2.4g: Rekey key rotation interval
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa12_mix_rekey
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  rekey 3596
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3596s
    ${exit}=                    write   top

#WLAN Guest 2.4g WPA23 Mix personal
WLAN Guest 2.4g WPA23 Mix: Enter wpa23_mix personal
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa23_mix_enter
    [Documentation]             Fire off the interface wifi guest 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi guest 2.4g -> security wpa23_mix
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    sleep                       1
    ${output}=                  write  security wpa23_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa23-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top


WLAN Guest 2.4g WPA23 Mix: Set SSID for wpa23_mix Personal WLAN 2.4g
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g     interface_wifi_guest_2_4g_wpa23_mix_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    sleep                       1
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                 write   ssid Pokemon
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Pokemon
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

WLAN Guest 2.4g WPA23 Mix: SSID Hide enabled
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa23_mix_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 2.4g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

WLAN Guest 2.4g WPA23 Mix: SSID broadcast
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa23_mix_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 2.4g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN Guest 2.4g WPA23 Mix: Password
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa23_mix_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  password GottaCatchThemAll
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PASSWORD=GottaCatchThemAll
    ${exit}=                  write   top

WLAN Guest 2.4g WPA23 Mix: maxclient
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa23_mix_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  maxclient 36
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  MAX_CLIENTS=36
    ${exit}=                  write   top

WLAN Guest 2.4g WPA23 Mix: Rekey key rotation interval
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa23_mix_rekey
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  rekey 3596
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3596s
    ${exit}=                  write   top

#WLAN 2.4g WPA2 enterprise Guest
WLAN 2.4g WPA2 enterprise Guest: Enter wpa2_enterprise
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa2_enterprise_enter
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> security wpa2_enterprise
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa2_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa2-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    ${exit}=                    write   top


WLAN 2.4g WPA2 enterprise Guest: Set SSID for wpa2_enterprise
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g     interface_wifi_guest_2_4g_wpa2_enterprise_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                 write   ssid Pokemon
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Pokemon
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

WLAN 2.4g WPA2 enterprise Guest: SSID Hide enabled
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa2_enterprise_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 2.4g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}  No match found   Syntax error: Illegal parameter   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

WLAN 2.4g WPA2 enterprise Guest: SSID broadcast
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa2_enterprise_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 2.4g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN 2.4g WPA2 enterprise Guest: Server IP
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa2_enterprise_server
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  server 192.168.0.253
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  SERVER_IP=192.168.0.253
    ${exit}=                  write   top

WLAN 2.4g WPA2 enterprise Guest: Port forwarding
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa2_enterprise_port
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  port 1811
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PORT_FORWARD=1811
    ${exit}=                  write   top

WLAN 2.4g WPA2 enterprise Guest: Connection secret
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa2_enterprise_secret
    [Documentation]             Fire off the secret and check that secret is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  secret PowerExtreme!
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  CONNECTION_SECRET=PowerExtreme!
    ${exit}=                  write   top

WLAN 2.4g WPA2 enterprise Guest: PMF protected Management Frames
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa2_enterprise_pmf
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  pmf required
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PROTECTED_MANAGEMENT_FRAMES=Required
    ${exit}=                  write   top

WLAN 2.4g WPA2 enterprise Guest: maxclient
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa2_enterprise_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa2_enterprise
    #test upper boundary >50
    ${output}=                  write   maxclient 300
    sleep                       1
    ${output}=                  read
    should contain              ${output}   maxclient must between 1 - 50  Syntax error: Illegal parameter
    #test lower boundary <1
    ${output}=                  write   maxclient 0
    sleep                       1
    ${output}=                  read
    should contain              ${output}   maxclient must between 1 - 50  Syntax error: Illegal parameter
    sleep                       1
    #test happy path
    ${output}=                  write  maxclient 25
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  MAX_CLIENTS=25
    ${exit}                     write  top

WLAN 2.4g WPA2 enterprise Guest: Rekey key rotation interval
    [Tags]                      Config  WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa2_enterprise_rekey
    [Documentation]             Fire off the key rotation and check that upper & lower limits tested & key rotataion is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa2_enterprise
    #lower limit 600 test
    ${output}=                  write  rekey 400
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  rekey must between 600 - 86400
    #upper limit 86400 test
    ${output}=                  write  rekey 90000
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  rekey must between 600 - 86400
    #happy path 3596
    ${output}=                  write  rekey 3596
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3596s
    ${exit}=                  write   top

#WLAN Guest 2.4g WPA3 enterprise
WLAN Guest 2.4g WPA3 enterprise: Enter wpa3_enterprise
    [Tags]                      Config   WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa3_enterprise_enter
    [Documentation]             Fire off the interface wifi guest 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi guest 2.4g -> security wpa3_enterprise
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa3-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top


WLAN Guest 2.4g WPA3 enterprise: Set SSID
    [Tags]                      Config   WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g     interface_wifi_guest_2_4g_wpa3_enterprise_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                 write   ssid Smurfs
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Smurfs
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

WLAN Guest 2.4g WPA3 enterprise: SSID Hide enabled
    [Tags]                      Config   WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa3_enterprise_ssid_hide
    [Documentation]             Fire off the disable and check that wifi guest 2.4g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}  No match found   Syntax error: Illegal parameter   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

WLAN Guest 2.4g WPA3 enterprise: SSID broadcast
    [Tags]                      Config   WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa3_enterprise_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi guest 2.4g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN Guest 2.4g WPA3 enterprise: Server IP
    [Tags]                      Config   WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa3_enterprise_server
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  server 192.168.0.253
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  SERVER_IP=192.168.0.253
    ${exit}=                  write   top

WLAN Guest 2.4g WPA3 enterprise: Port forwarding
    [Tags]                      Config   WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa3_enterprise_port
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  port 1809
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PORT_FORWARD=1809
    ${exit}=                  write   top

WLAN Guest 2.4g WPA3 enterprise: Connection secret
    [Tags]                      Config   WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa3_enterprise_secret
    [Documentation]             Fire off the secret and check that secret is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  secret Gargamel321
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  CONNECTION_SECRET=Gargamel321
    ${exit}=                  write   top

WLAN Guest 2.4g WPA3 enterprise: maxclient
    [Tags]                      Config   WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa3_enterprise_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    #upper boundary test >50
    ${output}=                  write  maxclient 118
    sleep                       1
    ${output}=                  read
    should contain              ${output}       maxclient must between 1 - 50   Syntax error: Illegal parameter
    sleep                       1
    #lower boundary test <1
    ${output}=                  write  maxclient 0
    sleep                       1
    ${output}=                  read
    should contain              ${output}       maxclient must between 1 - 50   Syntax error: Illegal parameter
    sleep                       1
    #happy path between 1 - 50
    ${output}=                  write  maxclient 21
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  MAX_CLIENTS=21
    ${exit}=                  write   top

WLAN Guest 2.4g WPA3 enterprise: Rekey key rotation interval
    [Tags]                      Config   WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa3_enterprise_rekey
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    #lower limit 600 test
    ${output}=                  write  rekey 400
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  rekey must between 600 - 86400
    #upper limit 86400 test
    ${output}=                  write  rekey 90000
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  rekey must between 600 - 86400
    #happy path 3596
    ${output}=                  write  rekey 3580
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3580s
    ${exit}=                  write   top

#WLAN Guest 2.4g WPA12 mix enterprise
WLAN Guest 2.4g WPA12 mix enterprise: Enter wpa12_mix_enterprise
    [Tags]                      Config   WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa12_mix_enterprise_enter
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> security wpa12_mix_enterprise
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa12-mix-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    ${exit}                     write  top
    
WLAN Guest 2.4g WPA12 mix enterprise: Set SSID for wpa12_mix_enterprise
    [Tags]                      Config   WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g     interface_wifi_guest_2_4g_wpa12_mix_enterprise_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    ${output}=                 write   ssid Snorks
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Snorks
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}                     write  top

WLAN Guest 2.4g WPA12 mix enterprise: SSID Hide enabled
    [Tags]                      Config   WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa12_mix_enterprise_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 2.4g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}  No match found   Syntax error: Illegal parameter   (global)#   (config-if-wlan-2.4g)#
    ${exit}                     write  top
    
WLAN Guest 2.4g WPA12 mix enterprise: SSID broadcast
    [Tags]                      Config   WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa12_mix_enterprise_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 2.4g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}                     write  top
    

WLAN Guest 2.4g WPA12 mix enterprise: Server IP
    [Tags]                      Config   WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa12_mix_enterprise_server
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  server 192.168.0.252
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  SERVER_IP=192.168.0.252
    ${exit}                     write  top
    

WLAN Guest 2.4g WPA12 mix enterprise: Port forwarding
    [Tags]                      Config   WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa12_mix_enterprise_port
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  port 1808
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PORT_FORWARD=1808
    ${exit}                     write  top
    

WLAN Guest 2.4g WPA12 mix enterprise: Connection secret
    [Tags]                      Config   WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa12_mix_enterprise_secret
    [Documentation]             Fire off the secret and check that secret is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  secret BestUnderwaterLife
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  CONNECTION_SECRET=BestUnderwaterLife
    ${exit}                     write  top
    

WLAN Guest 2.4g WPA12 mix enterprise: maxclient
    [Tags]                      Config   WLAN  WLAN_guest_2_4g  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa12_mix_enterprise_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa12_mix_enterprise
    #test upper boundary >50
    ${output}=                  write   maxclient 300
    sleep                       1
    ${output}=                  read
    should contain              ${output}   maxclient must between 1 - 50  Syntax error: Illegal parameter
    #test lower boundary <1
    ${output}=                  write   maxclient 0
    sleep                       1
    ${output}=                  read
    should contain              ${output}   maxclient must between 1 - 50  Syntax error: Illegal parameter
    sleep                       1
    #test happy path
    ${output}=                  write  maxclient 23
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  MAX_CLIENTS=23
    ${exit}                     write  top
    

WLAN Guest 2.4g WPA12 mix enterprise: Rekey key rotation interval
    [Tags]                      Config   WLAN  WLAN_guest_2_4g   interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_wpa12_mix_enterprise_rekey
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 2.4g
    ${output}=                  write  security wpa12_mix_enterprise
    #lower limit 600 test
    ${output}=                  write  rekey 400
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  rekey must between 600 - 86400
    #upper limit 86400 test
    ${output}=                  write  rekey 90000
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  rekey must between 600 - 86400
    #happy path 3596
    ${output}=                  write  rekey 3579
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3579s
    ${exit}                     write  top
    

#WLAN Guest 5g: WPA
WLAN Guest 5g: WPA Enter WPA personal
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa_enter
    [Documentation]             Fire off the interface wifi 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 5g -> security wpa
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration WLAN Guest 5g
    sleep                       1
    ${output}=                  write  security wpa
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g-wpa)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    ${exit}=                  write   top


WLAN Guest 5g: WPA Set SSID for WPA Personal WLAN Guest 5g
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g     interface_wifi_guest_5g_wpa_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration WLAN Guest 5g
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                 write   ssid Super_Mario_Brothers
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Super_Mario_Brothers
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN Guest 5g: WPA SSID Hide enabled
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa_ssid_hide
    [Documentation]             Fire off the ssid hide and check that wifi 5g is SSID is hidden / disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration WLAN Guest 5g
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN Guest 5g: WPA SSID broadcast
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 5g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration WLAN Guest 5g
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN Guest 5g: WPA Password
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration WLAN Guest 5g
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  password YoshiYoshi
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PASSWORD=YoshiYoshi
    ${exit}=                  write   top

WLAN Guest 5g: WPA maxclient
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration WLAN Guest 5g
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  maxclient 37
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  MAX_CLIENTS=37
    ${exit}=                  write   top

WLAN Guest 5g: WPA Rekey key rotation interval
    [Tags]                      Config    WLAN  WLAN_guest_5g  interface_wifi_guest_5g  interface_wifi_guest_5g_wpa_rekey
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration WLAN Guest 5g
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write  rekey 3599
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3599s
    ${exit}=                  write   top

#WLAN WPA2 personal guest 5g
WLAN WPA2 guest 5g personal: wpa2 personal
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_5g  interface_wifi_5g_wpa2_enter
    [Documentation]             Fire off the interface wifi 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 5g -> security wpa2
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa2
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g-wpa2)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    ${exit}                     write  top


WLAN WPA2 guest 5g personal: Set SSID for wpa2 Personal WLAN 5g
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_5g     interface_wifi_5g_wpa2_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                 write   ssid Wario_Brothers
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Wario_Brothers
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}                     write  top

WLAN WPA2 guest 5g personal: SSID Hide enabled
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_5g  interface_wifi_5g_wpa2_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 5g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}                     write  top

WLAN WPA2 guest 5g personal: SSID broadcast
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_5g  interface_wifi_5g_wpa2_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 5g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}                     write  top

WLAN WPA2 guest 5g personal: Password
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_5g  interface_wifi_5g_wpa2_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  password PrincessPeach
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PASSWORD=PrincessPeach
    ${exit}                     write  top

WLAN WPA2 guest 5g personal: PMF protected Management Frames
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_5g  interface_wifi_5g_wpa2_pmf
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  pmf required
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PROTECTED_MANAGEMENT_FRAMES=Required
    ${exit}                     write  top

WLAN WPA2 guest 5g personal: maxclient
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_5g  interface_wifi_guest_5g_wpa2_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated #has issue file bug
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  maxclient 38
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  MAX_CLIENTS=38
    ${exit}                     write  top

WLAN WPA2 guest 5g personal: Rekey key rotation interval
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_5g  interface_wifi_5g_wpa2_rekey
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  rekey 3599
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3599s
    ${exit}                     write  top

#WLAN Guest 5g WPA3 personal
WLAN Guest 5g WPA3 personal: Enter wpa3 personal
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa3_enter
    [Documentation]             Fire off the interface wifi 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 5g -> security wpa3
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g-wpa3)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    ${exit}=                    write   top

WLAN Guest 5g WPA3 personal: Set SSID for wpa3 Personal WLAN 5g
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g     interface_wifi_guest_5g_wpa3_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${exit}=                    write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                 write   ssid Luigi
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Luigi
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                    write   top

WLAN Guest 5g WPA3 personal: SSID Hide enabled
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa3_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 5g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN Guest 5g WPA3 personal: SSID broadcast
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa3_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 5g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN Guest 5g WPA3 personal: Password
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa3_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  password MaMaMiaHereIGoAgain
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PASSWORD=MaMaMiaHereIGoAgain
    ${exit}=                  write   top

WLAN Guest 5g WPA3 personal: maxclient
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa3_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated #has issue file a bug
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  maxclient 39
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  MAX_CLIENTS=39
    ${exit}=                  write   top

WLAN Guest 5g WPA3 personal: Rekey key rotation interval
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa3_rekey
    [Documentation]             Fire off the rekey and check that rekey is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  rekey 3597
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3597s
    ${exit}=                  write   top

#WLAN Guest 5g WPA 12 mix personal
WLAN Guest 5g WPA12 mix personal: Enter wpa12_mix personal
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa12_mix_enter
    [Documentation]             Fire off the interface wifi 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 5g -> security wpa12_mix
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g-wpa12-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    ${exit}=                    write    top


WLAN Guest 5g WPA12 mix personal: Set SSID for wpa12_mix Personal WLAN 5g
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g     interface_wifi_guest_5g_wpa12_mix_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                 write   ssid Pikachu
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Pikachu
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                    write    top

WLAN Guest 5g WPA12 mix personal: SSID Hide enabled
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa12_mix_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 5g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                    write    top

WLAN Guest 5g WPA12 mix personal: SSID broadcast
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa12_mix_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 5g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                    write    top

WLAN Guest 5g WPA12 mix personal: Password
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa12_mix_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  password IchooseYou
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PASSWORD=IchooseYou
    ${exit}=                    write    top

WLAN Guest 5g WPA12 mix personal: maxclient
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa12_mix_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    #test lower limit <1
    #${lowerlimit}=               write  maxclient 0
    #sleep                       2
    #${lowerlimit}=               write   show
    #sleep                       1
    #${lowerlimit}=               read
    #sleep                       1
    #should contain              ${lowerlimit}    maxclient must between 1 - 50
    #test upper limit > 50
    #${upperlimit}=              write  maxclient 101
    #sleep                       2
    #${upperlimit}=              write   show
    #sleep                       1
    #${upperlimit}=              read
    #sleep                       1
    #should contain              ${upperlimit}    maxclient must between 1 - 50
    #test happy path
    ${happypath}=                  write  maxclient 30
    sleep                       2
    #${output}=                  write  apply
    #sleep                       1
    ${happypath}=                  write   show
    sleep                       1
    ${happypath}=                  read
    sleep                       1
    should contain              ${happypath}  MAX_CLIENTS=30
    should not be empty         ${happypath}
    should not contain          ${happypath}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should not contain          ${happypath}   maxclient must between 1 - 50
    should contain              ${happypath}  MAX_CLIENTS=30
    ${exit}=                    write    top

WLAN Guest 5g WPA12 mix personal: Rekey key rotation interval
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa12_mix_rekey
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  rekey 3596
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3596s
    ${exit}=                    write    top

#exit from WLAN wpa12_mix 5g
WLAN Guest 5g WPA12 mix personal: Exit from WLAN 5g wpa12_mix personal
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g     interface_wifi_guest_5g_wpa12_mix_exit
    [Documentation]            Exit the WLAN 5g Configuration Mode via "top" command and land at Global vonfiguration level
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    #set client configuration  prompt=#
    ${output}=              read    #until prompt
    should contain              ${output}   (global)#
    ${exit}=                    write    top

#WLAN Guest 5g WPA23 mix personal
WLAN Guest 5g WPA23 mix personal: Enter wpa23_mix personal
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa23_mix_enter
    [Documentation]             Fire off the interface wifi guest 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi guest 5g -> security wpa23_mix
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g-wpa23-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    ${exit}=                  write   top


WLAN Guest 5g WPA23 mix personal: Set SSID for wpa23_mix Personal WLAN 5g
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g     interface_wifi_guest_5g_wpa23_mix_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                 write   ssid Pokemon
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Pokemon
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN Guest 5g WPA23 mix personal: SSID Hide enabled
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa23_mix_ssid_hide
    [Documentation]             Fire off the disable and check that wifi guest 5g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN Guest 5g WPA23 mix personal: SSID broadcast
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa23_mix_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi guest 5g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN Guest 5g WPA23 mix personal: Password
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa23_mix_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  password GottaCatchThemAll
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PASSWORD=GottaCatchThemAll
    ${exit}=                  write   top

WLAN Guest 5g WPA23 mix personal: maxclient
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa23_mix_maxclient
    [Documentation]             Fire off the maxlient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  maxclient 32
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  MAX_CLIENTS=32
    ${exit}=                  write   top

WLAN Guest 5g WPA23 mix personal: Rekey key rotation interval
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa23_mix_rekey
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  rekey 3596
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3596s
    ${exit}=                    write   top


#exit from WLAN wpa23_mix 5g
WLAN Guest 5g WPA23 mix personal: Exit from WLAN 5g wpa23_mix
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g     interface_wifi_guest_5g_wpa23_mix_exit
    [Documentation]            Exit the WLAN 5g Configuration Mode via "top" command and land at Global configuration level
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    #set client configuration  prompt=#
    ${output}=              read     #until prompt
    should contain              ${output}   (global)#

#WLAN guest 5g WPA12 mix enterprise
WLAN Guest 5g WPA12 mix enterprise: Enter wpa12_mix_enterprise
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa12_mix_enterprise_enter
    [Documentation]             Fire off the interface wifi guest 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi guest 5g -> security wpa12_mix_enterprise
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    #sleep                       1
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g-wpa12-mix-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    ${exit}                     write  top

WLAN Guest 5g WPA12 mix enterprise: Set SSID for wpa12_mix_enterprise
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g     interface_wifi_guest_5g_wpa12_mix_enterprise_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    ${output}=                 write   ssid Snorks
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Snorks
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}                     write  top
    
    

WLAN Guest 5g WPA12 mix enterprise: SSID Hide enabled
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa12_mix_enterprise_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 5g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}  No match found   Syntax error: Illegal parameter   (global)#   (config-if-wlan-5g)#
    ${exit}                     write  top
    
    

WLAN Guest 5g WPA12 mix enterprise: SSID broadcast
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa12_mix_enterprise_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 5g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}                     write  top
    

WLAN Guest 5g WPA12 mix enterprise: Server IP
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa12_mix_enterprise_server
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  server 192.168.0.252
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  SERVER_IP=192.168.0.252
    ${exit}                     write  top
    

WLAN Guest 5g WPA12 mix enterprise: Port forwarding
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa12_mix_enterprise_port
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  port 1808
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PORT_FORWARD=1808
    ${exit}                     write  top
    

WLAN Guest 5g WPA12 mix enterprise: Connection secret
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa12_mix_enterprise_secret
    [Documentation]             Fire off the secret and check that secret is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  secret BestUnderwaterLife
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  CONNECTION_SECRET=BestUnderwaterLife
    ${exit}                     write  top
    

WLAN Guest 5g WPA12 mix enterprise: maxclient
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa12_mix_enterprise_maxclient
    [Documentation]             Fire off the maxclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa12_mix_enterprise
    #test upper boundary >50
    ${output}=                  write   maxclient 300
    sleep                       1
    ${output}=                  read
    should contain              ${output}   maxclient must between 1 - 50  Syntax error: Illegal parameter
    #test lower boundary <1
    ${output}=                  write   maxclient 0
    sleep                       1
    ${output}=                  read
    should contain              ${output}   maxclient must between 1 - 50  Syntax error: Illegal parameter
    sleep                       1
    #test happy path
    ${output}=                  write  maxclient 21
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  MAX_CLIENTS=21
    ${exit}                     write  top
    

WLAN Guest 5g WPA12 mix enterprise: Rekey key rotation interval
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa12_mix_enterprise_rekey
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa12_mix_enterprise
    #lower limit 600 test
    ${output}=                  write  rekey 400
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  rekey must between 600 - 86400
    #upper limit 86400 test
    ${output}=                  write  rekey 90000
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  rekey must between 600 - 86400
    #happy path 3596
    ${output}=                  write  rekey 3579
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3579s
    ${exit}                     write  top
    

#exit from WLAN wpa12_mix_enterprise 5g
WLAN Guest 5g WPA12 mix enterprise: Exit from WLAN 5g wpa12_mix_enterprise
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g     interface_wifi_guest_5g_wpa12_mix_enterprise_exit
    [Documentation]            Exit the WLAN 5g Configuration Mode via "top" command and land at Global configuration level
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#

#WLAN Guest 5g WPA2 enterprise
WLAN Guest 5g WPA2 enterprise: Enter wpa2_enterprise
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa2_enterprise_enter
    [Documentation]             Fire off the interface wifi guest 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi guest 5g -> seecurity wpa2_enterprise
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa2_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g-wpa2-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    ${exit}=                    write   top


WLAN Guest 5g WPA2 enterprise: Set SSID for wpa2_enterprise WLAN 5g
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g     interface_wifi_guest_5g_wpa2_enterprise_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                 write   ssid Pokemon
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Pokemon
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN Guest 5g WPA2 enterprise: SSID Hide enabled
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa2_enterprise_ssid_hide
    [Documentation]             Fire off the disable and check that wifi guest 5g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}  No match found   Syntax error: Illegal parameter   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN Guest 5g WPA2 enterprise: SSID broadcast
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa2_enterprise_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi guest 5g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN Guest 5g WPA2 enterprise: Server IP
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa2_enterprise_server
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  server 192.168.0.253
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  SERVER_IP=192.168.0.253
    ${exit}=                  write   top

WLAN Guest 5g WPA2 enterprise: Port forwarding
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa2_enterprise_port
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  port 1811
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PORT_FORWARD=1811
    ${exit}=                  write   top

WLAN Guest 5g WPA2 enterprise: Connection secret
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa2_enterprise_secret
    [Documentation]             Fire off the secret and check that secret is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  secret PowerExtreme!
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  CONNECTION_SECRET=PowerExtreme!
    ${exit}=                  write   top

WLAN Guest 5g WPA2 enterprise: PMF protected Management Frames
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa2_enterprise_pmf
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa2_enterprise
    ${output}=                  write  pmf required
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PROTECTED_MANAGEMENT_FRAMES=Required
    ${exit}=                  write   top

WLAN Guest 5g WPA2 enterprise: maxclient
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa2_enterprise_maxclient
    [Documentation]             Fire off the maclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa2_enterprise
    #test upper boundary >50
    ${output}=                  write   maxclient 300
    sleep                       1
    ${output}=                  read
    should contain              ${output}   maxclient must between 1 - 50  Syntax error: Illegal parameter
    #test lower boundary <1
    ${output}=                  write   maxclient 0
    sleep                       1
    ${output}=                  read
    should contain              ${output}   maxclient must between 1 - 50  Syntax error: Illegal parameter
    sleep                       1
    #test happy path
    ${output}=                  write  maxclient 26
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  MAX_CLIENTS=26
    ${exit}                     write  top

WLAN Guest 5g WPA2 enterprise: Rekey key rotation interval
    [Tags]                      Config   WLAN  WLAN_guest_5g    interface_wifi_guest_5g  interface_wifi_guest_5g_wpa2_enterprise_rekey
    [Documentation]             Fire off the key rotation and check that upper & lower limits tested & key rotataion is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa2_enterprise
    #lower limit 600 test
    ${output}=                  write  rekey 400
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  rekey must between 600 - 86400
    #upper limit 86400 test
    ${output}=                  write  rekey 90000
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  rekey must between 600 - 86400
    #happy path 3596
    ${output}=                  write  rekey 3596
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3596s
    ${exit}=                  write   top

#WLAN Guest 5g WPA3 enterprise
WLAN Guest 5g: Enter wpa3_enterprise
    [Tags]                      Config  WLAN  WLAN_guest_5g    interface_wifi_guest_5g  interface_wifi_guest_5g_wpa3_enterprise_enter
    [Documentation]             Fire off the interface wifi guest 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi guest 5g -> seecurity wpa3_enterprise
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g-wpa3-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN Guest 5g: Set SSID for wpa3_enterprise
    [Tags]                      Config  WLAN  WLAN_guest_5g    interface_wifi_guest_5g     interface_wifi_guest_5g_wpa3_enterprise_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                 write   ssid Smurfs
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Smurfs
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN Guest 5g WPA3 enterprise: SSID Hide enabled
    [Tags]                      Config  WLAN  WLAN_guest_5g     interface_wifi_guest_5g  interface_wifi_guest_5g_wpa3_enterprise_ssid_hide
    [Documentation]             Fire off the disable and check that wifi guest 5g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}  No match found   Syntax error: Illegal parameter   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN Guest 5g WPA3 enterprise: SSID broadcast
    [Tags]                      Config   WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa3_enterprise_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi guest 5g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN Guest 5g WPA3 enterprise: Server IP
    [Tags]                      Config  WLAN  WLAN_guest_5g     interface_wifi_guest_5g  interface_wifi_guest_5g_wpa3_enterprise_server
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  server 192.168.0.253
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  SERVER_IP=192.168.0.253
    ${exit}=                  write   top

WLAN Guest 5g WPA3 enterprise: Port forwarding
    [Tags]                      Config  WLAN  WLAN_guest_5g     interface_wifi_guest_5g  interface_wifi_guest_5g_wpa3_enterprise_port
    [Documentation]             Fire off the port forwarding and check that port forwarding is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  port 1809
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PORT_FORWARD=1809
    ${exit}=                  write   top

WLAN Guest 5g WPA3 enterprise: Connection secret
    [Tags]                      Config  WLAN  WLAN_guest_5g     interface_wifi_guest_5g  interface_wifi_guest_5g_wpa3_enterprise_secret
    [Documentation]             Fire off the secret and check that secret is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  secret Gargamel321
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  CONNECTION_SECRET=Gargamel321
    ${exit}=                  write   top

WLAN Guest 5g WPA3 enterprise: maxclient
    [Tags]                      Config  WLAN  WLAN_guest_5g     interface_wifi_guest_5g  interface_wifi_guest_5g_wpa3_enterprise_maxclient
    [Documentation]             Fire off the maxlient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    #upper boundary test >50
    ${output}=                  write  maxclient 118
    sleep                       1
    ${output}=                  read
    should contain              ${output}       maxclient must between 1 - 50   Syntax error: Illegal parameter
    sleep                       1
    #lower boundary test <1
    ${output}=                  write  maxclient 0
    sleep                       1
    ${output}=                  read
    should contain              ${output}       maxclient must between 1 - 50   Syntax error: Illegal parameter
    sleep                       1
    #happy path between 1 - 50
    ${output}=                  write  maxclient 21
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  MAX_CLIENTS=21
    ${exit}=                  write   top

WLAN Guest 5g WPA3 enterprise: Rekey key rotation interval
    [Tags]                      Config  WLAN  WLAN_guest_5g   interface_wifi_guest_5g  interface_wifi_guest_5g_wpa3_enterprise_rekey
    [Documentation]             Fire off the rekey and check that rekey is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    #lower limit 600 test
    ${output}=                  write  rekey 400
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  rekey must between 600 - 86400
    #upper limit 86400 test
    ${output}=                  write  rekey 90000
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  rekey must between 600 - 86400
    #happy path 3596
    ${output}=                  write  rekey 3580
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3580s
    ${exit}=                  write   top

#exit from WLAN wpa3_enterprise 5g
WLAN Guest 5g WPA3 enterprise: Exit from WLAN 5g wpa3_enterprise
    [Tags]                      Config  WLAN  WLAN_guest_5g   interface_wifi_guest_5g     interface_wifi_guest_5g_wpa3_enterprise_exit
    [Documentation]            Exit the WLAN 5g Configuration Mode via "top" command and land at Global configuration level
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    #set client configuration  prompt=#
    ${output}=         read     #until prompt
    should contain              ${output}   (global)#
    ${exit}=                  write   top

#LTE configuration
LTE Configuration: Get into LTE & then back out to Global
    [Tags]                      Config  LTE    LTE_config_in_out
    [Documentation]             Execute the LAN DHCP & then back out to test exit and top commands
    ${execute}=                 write   top    #reset it to ensure we start from global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface lte   #lte level
    sleep                       1   #give the system 1 second to rest, seems to help decrease it from tripping on itself
    ${output}=                  read
    sleep                       1
    should contain              ${output}   (config-if-lte)#
    should not contain          ${output}   (global)#   (config)#
    #fire off top to get out to global
    ${exit}=                     write   top
    sleep                       1
    ${exit}=                     read
    sleep                       1
    should contain              ${exit}   (global)#
    should not contain          ${exit}   (config-if-lte)#  (config)#
    ${execute}=                 write   top    #reset it to ensure we start from global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface lte   #lte level
    sleep                       1
    ${exit}=                     write   exit
    sleep                       1
    ${exit}=                     write   exit
    sleep                       1
    ${exit}=                     read
    sleep                       1
    should contain              ${exit}   (global)#
    should not contain          ${exit}   (config-if-lte)#   (config)#

LTE Configuration: Set the APN
    [Tags]                      Config  LTE    LTE_apn
    [Documentation]             Execute the apn as Fast.t-mobile.com & make sure it reflects it
    ${execute}=                 write   top    #reset it to ensure we start from global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface lte   #lte level
    sleep                       1   #give the system 1 second to rest, seems to help decrease it from tripping on itself
    ${output}=                  write   apn Fast.t-mobile.com   #set the apn as Fast.t-mobile.com
    sleep                       1
    ${apn}=                     write   show
    sleep                       1
    ${apn}=                     read
    should contain              ${apn}   APN=Fast.t-mobile.com
    should not contain          ${apn}   (config)#
    ${exit}=                    write   top    #reset it to ensure we start from global level

LTE Configuration: Set the ip type
    [Tags]                      Config  LTE    LTE_ip_type
    [Documentation]             Execute the ip type as ipv4|ipv6|ipv4v6 & make sure it reflects it
    ${execute}=                 write   top    #reset it to ensure we start from global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface lte   #lte level
    sleep                       1   #give the system 1 second to rest, seems to help decrease it from tripping on itself
    #ipv4
    ${output}=                  write   ip type ipv4   #set the ip type as ipv4
    sleep                       1
    ${ipv4}=                     write   show
    sleep                       1
    ${ipv4}=                     read
    should contain              ${ipv4}   IP_TYPE=ipv4
    should not contain          ${ipv4}   (config)#   IP_TYPE=ipv6    IP_TYPE=ipv4v6
    sleep                       1
    #ipv6
    ${output}=                  write   ip type ipv6   #set the ip type as ipv6
    sleep                       1
    ${ipv6}=                     write   show
    sleep                       1
    ${ipv6}=                     read
    should contain              ${ipv6}   IP_TYPE=ipv6
    should not contain          ${ipv6}   (config)#   IP_TYPE=ipv4    IP_TYPE=ipv4v6
    sleep                       1
    #ipv4v6
    ${output}=                  write   ip type ipv4v6   #set the ip type as ipv4v6
    sleep                       1
    ${ipv6}=                     write   show
    sleep                       1
    ${ipv6}=                     read
    should contain              ${ipv6}   IP_TYPE=ipv4v6
    should not contain          ${ipv6}   (config)#   IP_TYPE=ipv4    IP_TYPE=ipv6
    ${exit}=                    write   top    #reset it to ensure we start from global level

#LAN0 Bridge
LAN0 Bridge: Get into LAN bridge & then back out to Global
    [Tags]                      Config  bridge  LAN  lan_bridge_in_out
    [Documentation]             Execute the LANfrom & then back out to test exit and top commands
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    sleep                       1   #give the system 1 second to rest, seems to help decrease it from tripping on itself
    ${execute}=                 read
    sleep                       1
    should contain              ${execute}   (config-if-lan0)#
    should not contain          ${execute}   (global)#   (config-if-lan0-dhcp)#  (config)#
    #fire off top to get out to global
    ${exit}=                     write   top
    sleep                       1
    ${exit}=                     read
    sleep                       1
    should contain              ${exit}   (global)#
    should not contain          ${exit}   (config-if-lan0-dhcp)#  (config-if-lan0)#
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    sleep                       1
    ${exit}=                     write   exit
    sleep                       1
    ${exit}=                     write   exit
    sleep                       1
    ${exit}=                     read
    sleep                       1
    should contain              ${exit}   (global)#
    should not contain          ${exit}   (config-if-lan0-dhcp)#  (config-if-lan0)#

LAN0 Bridge: Config LAN IP address
    [Tags]                      Config  bridge  LAN  lan_bridge_ip
    [Documentation]             Execute the LAN bridge IP address & then ake sure it reflects it
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    sleep                       1   #give the system 1 second to rest, seems to help decrease it from tripping on itself
    ${ipaddress}=               write  ip 192.168.1.1   #this may cause issue
    sleep                       1
    ${ipaddress}=               write  show
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${ipaddress}=               read
    sleep                       1
    should contain              ${ipaddress}   IP_ADDR=192.168.1.1
    should not contain          ${ipaddress}   (global)#   (config-if-lan0-dhcp)#  (config)#
    ${exit}=                     write   top    #reset & exit from LAN bridge

LAN0 Bridge: Config LAN Net Mask
    [Tags]                      Config  bridge  LAN  lan_bridge_net_mask
    [Documentation]             Execute the net mask IP address & then make sure it reflects it
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    sleep                       1   #give the system 1 second to rest, seems to help decrease it from tripping on itself
    ${ipaddress}=               write  netmask 255.255.0.0
    sleep                       1
    ${ipaddress}=               write  show
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${ipaddress}=               read
    sleep                       1
    should contain              ${ipaddress}   NETMASK=255.255.0.0
    should not contain          ${ipaddress}   (global)#   (config-if-lan0-dhcp)#  (config)#
    ${exit}=                     write   top    #reset & exit from LAN bridge

#LAN0 Bridge DHCP
LAN0 Bridge DHCP: Get into LAN DHCP & then back out to Global
    [Tags]                      Config  bridge  LAN  DHCP   DHCP_in_out
    [Documentation]             Execute the LAN DHCP & then back out to test exit and top commands
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    sleep                       1   #give the system 1 second to rest, seems to help decrease it from tripping on itself
    ${execute}=                 read
    should contain              ${execute}   (config-if-lan0)#
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${output}=                  read
    sleep                       1
    should contain              ${output}   (config-if-lan0-dhcp)#
    should not contain          ${output}   (global)#   (config-if-lan0)#
    #fire off top to get out to global
    ${exit}=                     write   top
    sleep                       1
    ${exit}=                     read
    sleep                       1
    should contain              ${exit}   (global)#
    should not contain          ${exit}   (config-if-lan0-dhcp)#  (config-if-lan0)#
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    sleep                       1
    ${exit}=                     write   exit
    sleep                       1
    ${exit}=                     write   exit
    sleep                       1
    ${exit}=                     read
    sleep                       1
    should contain              ${exit}   (global)#
    should not contain          ${exit}   (config-if-lan0-dhcp)#  (config-if-lan0)#

LAN0 Bridge DHCP: Disable DHCP
    [Tags]                      Config  bridge  LAN  DHCP   DHCP_disable
    [Documentation]             Execute the disable & then check to ensure DHCP is diabled
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   disable     #fire off the disable message to diable the dhcp
    sleep                       1
    ${dhcp}=                     write   show   #show the disable
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${disable}=                 read    #read the result, should be DHCP should be disabled
    sleep                       1
    should not be empty         ${disable}
    should not contain          ${disable}   -ash: ntp: not found    -ash: show ntp: not found
    should contain              ${disable}   DHCP_Service=Disable
    ${exit}                     write  top  #reset the command line to global

LAN0 Bridge DHCP: Enable DHCP
    [Tags]                      Config  bridge  LAN  DHCP   DHCP_enable
    [Documentation]             Execute the enable & then ensure that DHCP is enabled
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   enable     #fire off the enable message
    sleep                       1
    ${dhcp}=                     write   show   #show the enable
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${enable}=                 read    #read the result, should be DHCP should be enabled
    sleep                       1
    should not be empty         ${enable}
    should not contain          ${enable}   -ash: ntp: not found    -ash: show ntp: not found
    should contain              ${enable}   DHCP_Service=Enable
    ${exit}                     write  top  #reset the command line to global

LAN0 Bridge DHCP: Set DHCP domain name
    [Tags]                      Config  bridge  LAN  DHCP   DHCP_domain
    [Documentation]             Execute the domain & then check that domain name is showing
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   domain superfly.com     #fire off the domain message to set dhcp domain URL
    sleep                       1
    ${dhcp}=                     write   show   #show the domain and other results
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${domain}=                 read    #read the result, should be superfly.com as domain
    sleep                       1
    should not be empty         ${domain}
    should not contain          ${domain}   -ash: ntp: not found    -ash: show ntp: not found
    should contain              ${domain}   Domain=superfly.com
    ${exit}                     write  top  #reset the command line to global

LAN0 Bridge DHCP: Set DNS
    [Tags]                      Config  bridge  LAN  DHCP   DHCP_dns
    [Documentation]             Execute the dns & then ensure dns is showing
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   dns 8.8.4.4     #fire off the dns command
    sleep                       1
    ${dhcp}=                     write   show   #show the dns and other results
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${dns}=                 read    #read the result, should be 8.8.4.4 as the dns ip address
    sleep                       1
    should not be empty         ${dns}
    should not contain          ${dns}   -ash: ntp: not found    -ash: show ntp: not found
    should contain              ${dns}   DNS_SERVER=8.8.4.4
    ${exit}                     write  top  #reset the command line to global

LAN0 Bridge DHCP: Set WINS server
    [Tags]                      Config  bridge  LAN  DHCP   DHCP_wins
    [Documentation]             Execute the wins & then ensure wins is showing
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   wins 10.0.0.1     #fire off the wins to set dhcp wins ip address
    sleep                       1
    ${dhcp}=                     write   show   #show the wins and other results
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${wins}=                 read    #read the result, should be 10.0.0.1 as the dhcp wins server
    sleep                       1
    should not be empty         ${wins}
    should not contain          ${wins}   -ash: ntp: not found    -ash: show ntp: not found
    should contain              ${wins}   WINS_SERVER=10.0.0.1
    ${exit}                     write  top  #reset the command line to global

#moved these tests higher up since the ip assign del is flakey
LAN0 Bridge DHCP: ip range
    [Tags]                      Config  bridge  LAN  DHCP   DHCP_ip_range
    [Documentation]             Execute the ip range to add a range of IPs & ensure that it gets reflected
    ${execute}=                 write   top    #reset it to ensure we start form global level
    sleep                       1
    ${execute}=                 write   configure   #system config level
    sleep                       1
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    sleep                       1
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   ip range 192.168.0.2 192.168.0.5     #fire off the ip range from 2 to 5
    sleep                       1
    ${dhcp}=                     write   show   #show the results
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${ipassignadd}=                 read    #read the result, should be empty since there is no assigned mac + ip for now
    sleep                       1
    should not be empty         ${ipassignadd}
    should not contain          ${ipassignadd}   -ash: ntp: not found    -ash: show ntp: not found
    should contain              ${ipassignadd}  IP_Range_Start=192.168.0.2  IP_Range_End=192.168.0.5
    ${exit}                     write  top  #reset the command line to global

LAN0 Bridge DHCP: lease
    [Tags]                      Config  bridge  LAN  DHCP   DHCP_lease
    [Documentation]             Execute the lease to change lease time in seconds (from 24h default) & ensure that it gets reflected
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   lease 80000     #fire off the lease to be 80,000 seconds
    sleep                       1
    ${dhcp}=                     write   show   #show the results
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${lease}=                 read    #read the result, should be empty since there is no assigned mac + ip for now
    sleep                       1
    should not be empty         ${lease}
    should not contain          ${lease}   -ash: ntp: not found    -ash: show ntp: not found
    should contain              ${lease}  LEASE_TIME=80000s
    ${exit}                     write  top  #reset the command line to global

LAN0 Bridge DHCP: gateway
    [Tags]                      Config  bridge  LAN  DHCP   DHCP_gateway
    [Documentation]             Execute the gateway to specify the ip gateway & ensure that it gets reflected
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   gateway 192.168.2.1     #fire off the gateway to be 192.168.2.1
    sleep                       1
    ${dhcp}=                     write   show   #show the results
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${gateway}=                 read    #read the result, should be empty since there is no assigned mac + ip for now
    sleep                       1
    should not be empty         ${gateway}
    should not contain          ${gateway}   -ash: ntp: not found    -ash: show ntp: not found
    should contain              ${gateway}  DEFAULT_GATEWAY=192.168.2.1
    ${exit}                     write  top  #reset the command line to global

LAN0 Bridge DHCP: ip Assign show
    [Tags]                      Config  bridge  LAN  DHCP   DHCP_ip_assign_show
    [Documentation]             Execute the ip assign show & ensure that it is blank since nothing has been assigned for now. One more will be done once we assign a mac address to the ip
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   ip assign show     #fire off the ip assign show command
    sleep                       1
    ${dhcp}=                     write   show   #show the dns and other results
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${ipassignshow}=                 read    #read the result, should be empty since there is no assigned mac + ip for now
    sleep                       1
    should not be empty             ${ipassignshow}
    should not contain          ${ipassignshow}   MAC   IP Address     -ash: ntp: not found    -ash: show ntp: not found
    ${exit}                     write  top  #reset the command line to global

LAN0 Bridge DHCP: ip Assign add
    [Tags]                      Config  bridge  LAN  DHCP   DHCP_ip_assign_add DHCP_ip_assign_combo
    [Documentation]             Execute the ip assign add & ensure that it is not blank
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   ip assign add E8:B3:1F:0C:6D:19 192.168.0.4     #fire off the ip assign add to set one up
    sleep                       1
    ${dhcp}=                     write   show   #show the dns and other results
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${ipassignadd}=                 read    #read the result, should be empty since there is no assigned mac + ip for now
    sleep                       1
    should not be empty         ${ipassignadd}
    should not contain          ${ipassignadd}   -ash: ntp: not found    -ash: show ntp: not found
    should contain              ${ipassignadd}  MAC   IP Address    E8:B3:1F:0C:6D:19   192.168.0.4
    ${exit}                     write  top  #reset the command line to global

LAN0 Bridge DHCP: ip Assign delete
    [Tags]                      Config  bridge  LAN  DHCP   DHCP_ip_assign_del
    [Documentation]             Execute the ip assign del & ensure that it deletes
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   ip assign add E8:B3:1F:0C:6D:19 192.168.0.200
    sleep                       3
    ${execute}=                 write   show
    sleep                       2
    ${execute}=                 read
    should contain              ${execute}  E8:B3:1F:0C:6D:19 192.168.0.200
    sleep                       1
    ${execute}=                 write   ip assign add E8:B3:1F:0C:6D:20 192.168.0.201     #fire off the ip assign add to set 1st one up
    sleep                       3
    ${execute}=                 write   show
    sleep                       2
    ${execute}=                 read
    should contain              ${execute}  E8:B3:1F:0C:6D:20 192.168.0.201
    ${execute}=                 write   ip assign add E8:B3:1A:0C:6D:21 192.168.0.202     #fire off the ip assign add to set 2nd one up
    sleep                       3
    ${execute}=                 write   show
    sleep                       2
    ${execute}=                 read
    should contain              ${execute}  E8:B3:1A:0C:6D:21 192.168.0.202
    sleep                       1
    ${execute}=                 write   ip assign del 192.168.0.200     #fire off the ip assign del via ip assignment
    sleep                       3
    ${execute}=                 write   show
    sleep                       2
    ${execute}=                 read
    should not contain              ${execute}  E8:B3:1F:0C:6D:19 192.168.0.200
    sleep                       1
    ${execute}=                 write   ip assign del E8:B3:1A:0C:6D:21     #fire off the ip assign del via mac assignment
    sleep                       3
    ${execute}=                 write   show
    sleep                       2
    ${execute}=                 read
    should not contain              ${execute}  E8:B3:1A:0C:6D:21 192.168.0.202
    sleep                       1
    ${execute}=                 read
    sleep                       1
    ${ipassignshow}=            write   ip assign show   #show the dns and other results
    sleep                       3
    #need to consider the "apply" command to make it permanent & how to reset it
    ${ipassignshow}=                 read
    should not be empty         ${ipassignshow}
    should not contain          ${ipassignshow}   E8:B3:1F:0C:6D:19   192.168.0.200    -ash: ntp: not found    -ash: show ntp: not found
    should not contain          ${ipassignshow}   E8:B3:1A:0C:6D:21   192.168.0.202    MAC   IP Address
    should contain              ${ipassignshow}  Device:E8:B3:1F:0C:6D:20 IP Address:192.168.0.201
    ${exit}                     write  show
    ${exit}                     write  read
    sleep                       1
    ${exit}                     write  top  #reset the command line to global


#Execute template
#    [Tags]                      template
#    [Documentation]             Update , apply and then show -
#    ${exit}                     write  top
#    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
#    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
#    sleep                       1
#    ${output}=                 write   show
#    sleep                       1   loglevel=NONE
#    ${output}=                 write   apply
#    #sleep                      1
#    ${output}=                 write   show
#    sleep                       1   loglevel=NONE
#    ${output}=                  read
#    should contain              ${output}   DNS
#    should not be empty         ${output}
#    should not contain          ${output}   ©
#    should not contain          ${output}   ®
#    should contain              ${output}   DNS
#    #should contain             ${output}   (config-if-wan0-dhcp)#
#    ${exit}                     write  top

#Execute reboot
#    [Tags]              Global     reboot
#    [Documentation]     Execute the reboot & return all of the processes
#    ${execute}=          write              reboot
#    set client configuration  prompt=#
#    ${output}=         read until prompt
#    should not be empty     ${output}

#Execute Restore
#    [Tags]              Global     restore
#    [Documentation]     Execute the restore & return all of the processes
#    ${execute}=          write              restore
#    set client configuration  prompt=#
#    ${output}=         read until prompt
#    should not be empty     ${output}

#   logout from global configuration CLI by sending "logout"

*** Keywords ***

Suite Setup
    Open Connection And Log In


Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}

Close All Connections
    Write               logout

#Suite Teardown
#    Close All Connections