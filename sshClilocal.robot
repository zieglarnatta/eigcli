*** Settings ***
Documentation          This example demonstrates executing a command on a remote machine
...                    and getting its output.
...
...                    Notice how connections are handled as part of the suite setup and
...                    teardown. This saves some time when executing several test cases.

Library                SSHLibrary
Suite Setup            Open Connection And Log In
Suite Teardown         Close All Connections
Resource            resourceLocal.robot

*** Test Cases ***
Execute Hello World Echo Command And Verify Output
    [Tags]                  Hello_World
    [Documentation]         Execute Command can be used to run commands on the remote machine.
    ...                     The keyword returns the standard output by default.
    ${output}=              Execute Command    echo Hello SSHLibrary!
    should be equal         ${output}          Hello SSHLibrary!

#Global configuration level
Execute Help
    [Tags]                      Global     help
    [Documentation]             Execute Help command and report all help topics
    ${execute}=                 write              help
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}           -ash: help: not found
    should contain              ${output}           (global)#

Global History 10 And Verify Output
    [Tags]                      Global   history     10
    [Documentation]             Execute history 10 CLI and return the last 10
    ...                         The keyword returns the standard output by default.
    write                       history 10
    set client configuration    prompt=#
    ${output}=                  read until      history
    should not be empty         ${output}
    should not contain          ${output}       -ash: help: not found


Global Ping on 8.8.8.8
    [Tags]                  Global     ping        8.8.8.8
    [Documentation]         Execute ping on 8.8.8.8 CLI and return the ping hops
    ...                     The keyword returns the standard output by default.
    write                   ping 8.8.8.8
    Sleep                   6
    ${output}=              read until      0% packet loss
    should not be empty     ${output}
    should not contain      ${output}       -ash: help: not found

Global AR Ping
    [Tags]                      Global     ar_ping     ar  ping
    [Documentation]             Execute Ap Ping and report ping stats
    write                       ping 8.8.8.8 -I 172.16.23.166 repeat 3
    Sleep                       6
    ${read}=                    read
    #set client configuration    prompt=#
    #${output}=                  read until prompt
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}       -ash: help: not found
    should not contain          ${output}   Syntax error: Illegal command line

Global Traceroute
    [Tags]                      Global  traceroute
    [Documentation]             Execute Traceroute and report traceroute stats
    ${execute}=                 write       traceroute 8.8.8.8 resolve source 172.16.23.166 interface eth0
    Sleep                       6
    set client configuration    prompt=#
    ${output}=                  read until   traceroute: can't set multicast source interface
    should not contain          ${output}    Usage: ping [OPTIONS] HOST
    should not Be Equal         ${output}    traceroute: can't set multicast source interface    #has issues

Global ps Processes
    [Tags]                      Global   ps
    [Documentation]             Execute the ps & return all of the processes
    ${execute}=                 write   ps
    set client configuration    prompt=#
    ${output}=                  read until prompt
    Sleep                       5
    should not be empty         ${output}
    should not contain          ${output}   -ash: help: not found
    should not contain          ${output}   Syntax error: Illegal command line

Global show interfaces
    [Tags]                      Global  show    interfaces
    [Documentation]             Execute the show interfaces & return all of the processes
    ${execute}=                 write   show interfaces
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: help: not found

Global show ip route
    [Tags]                      Global  show    ip_route
    [Documentation]             Execute the show ip route & return all of the processes
    ${execute}=                 write   show ip route
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: help: not found
    should not contain          ${output}   Syntax error: Illegal command line

Global show iptables
    [Tags]                      Global  show    iptables    show_iptables
    [Documentation]             Execute the show iptables & return all of the processes
    ${execute}=                 write   show iptables
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: help: not found

#configure
Execute "configure" and then "exit", then back to "confgiure" and use "top" to go back to global configuration
    [Tags]                      Global  System_Configuration   top     Global      configure_to_global
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
Global ntp server configuration and show it (has problem matching with double space, also ntp updated on server 6 rather than 1)
    [Tags]                      System_Configuration    ntp     show_ntp
    [Documentation]             Execute the ntp & confirm ntp servers are updated & shown
    ${execute}=                 write   configure
    ${execute}=                 write   ntp server1 www.yahoo.com server2 www.google.com        loglevel=DEBUG
    ${output}=                  write   show ntp       loglevel=DEBUG
    #set client configuration   prompt=#
    #${output}=                 read until prompt        loglevel=DEBUG
    ${output}=                  read until      www.yahoo.com        loglevel=DEBUG
    should not be empty         ${output}
    should not contain          ${output}   -ash: ntp: not found
    should not contain          ${output}   -ash: show ntp: not found
    should contain              ${output}   (config)#
    should contain              ${output}   (config)#     www.yahoo.com
    should contain             ${output}   NTP Server1 www.yahoo.com
    ${exit}                     write  top
    ${exit}                     read
    should contain              ${exit}   (global)#

#WAN0
WAN Configuration Wan0 Mode and back out via exit & top
    [Tags]                      WAN     wan0    wan_configuration
    [Documentation]             Enters the WAN Configuration Mode and retrest to global with top and then repeat but with two exits
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
    ${exit}                     read
    should contain              ${exit}   (global)#

#WAN0 DHCP
Execute conn dhcp to enter the WAN DHCP Configuration Mode, do initial read out & back out via top and 3 exits
    [Tags]                      Config      WAN     wan0    dhcp    conn_dhcp
    [Documentation]             Enters the WAN DHCP Configuration Mode
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

Execute update DHCP mtu, apply and then show DHCP
    [Tags]                      Config      WAN     wan0    dhcp   mtu_dhcp
    [Documentation]             Update mtu, apply and then show DHCP
    ${output}=                 write   configure
    ${output}=                 write   interface ethernet wan0
    ${output}=                 write   conn dhcp
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
    ${exit}                     read
    should contain              ${exit}   (global)#


Execute update DHCP DNS and then show the applied result
    [Tags]                      Config      WAN     wan0    dhcp   dns_dhcp
    [Documentation]             Update DNS, apply and then show new DNS
    ${output}=                 write   configure
    ${output}=                 write   interface ethernet wan0
    ${output}=                 write    conn dhcp
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


Execute update DHCP host name & then show the applied result
    [Tags]                      Config      WAN     wan0    dhcp   host_DHCP
    [Documentation]             update host name as yeehaw, apply & then show it
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
    ${exit}                     read
    should contain              ${exit}   (global)#

Execute update DHCP querymode to normal (from aggresive default) & then show the applied result
    [Tags]                      Config      WAN     wan0    dhcp   querymode_DHCP
    [Documentation]             update query mode from Aggresive to Normal
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
    ${exit}                     read
    should contain              ${exit}   (global)#

#next to reset and clean it up
#WIP

#WAN Static config
Execute connect static Wan & then back out
    [Tags]                     Config       WAN     wan0    conn static     conn_static_in_out
    [Documentation]            Enters the WAN Static Configuration Mode, then use top & 3 exits to go back to Global Configuration
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    #sleep                       1
    ${output}=                 write   conn static     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0 -> Static
    #sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-static)#
    should not be empty         ${output}
    #use top to go all the way back into Global Config
    ${output}=                  write   top
    #sleep                       1
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
    ${output}=                 write   exit
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config-if-wan0)#   (config)#   (config-if-wan0-static)#

Execute the mtu for WAN Static
    [Tags]                     Config       WAN     wan0    conn_static     mtu_static
    [Documentation]            Enters the WAN Static Configuration Mode and set mtu as 1325
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
    ${exit}                     read
    should contain              ${exit}   (global)#

Execute the dns for WAN Static
    [Tags]                     Config       WAN     wan0    conn_static     dns_static
    [Documentation]            Enters the WAN Static Configuration Mode and to set dns as 8.8.8.8
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
    should not contain          ${output}   MTU=1500    DNS_SERVER=
    ${exit}                     write  top
    ${exit}                     read
    should contain              ${exit}   (global)#

Execute the ip for WAN Static
    [Tags]                     Config       WAN     wan0    conn_static     ip_static
    [Documentation]            Enters the WAN Static Configuration Mode and to set ip as 192.168.0.200
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
    should not contain          ${output}   MTU=1500    DNS_SERVER=     IP_ADDR=
    ${exit}                     write  top
    ${exit}                     read
    should contain              ${exit}   (global)#

Execute the netmask for WAN Static
    [Tags]                     Config       WAN     wan0    conn_static     netmask_static
    [Documentation]            Enters the WAN Static Configuration Mode and to set netmask as 255.255.0.0
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
    should not contain          ${output}   MTU=1500    DNS_SERVER=     IP_ADDR=    NETMASK=
    ${exit}                     write  top
    ${exit}                     read
    should contain              ${exit}   (global)#

Execute the gateway for WAN Static
    [Tags]                     Config       WAN     wan0    conn_static     gateway_static
    [Documentation]            Enters the WAN Static Configuration Mode and to set gateway as DEFAULT_GATEWAY=192.168.0.203
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
    ${exit}                     read
    should contain              ${exit}   (global)#

#WAN PPPoE
Execute connect PPPoE Wan & then back out
    [Tags]                     Config       WAN     wan0    conn pppoe     conn_pppoe_in_out
    [Documentation]            Enters the WAN PPPoE Configuration Mode, then use top & 3 exits to go back to Global Configuration
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
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config-if-wan0)#   (config)#   (config-if-wan0-pppoe)#

#connect again
Execute conn PPPoE to enter Wan PPPoE
    [Tags]                     Config       WAN     wan0    conn pppoe  conn_pppoe  enter_pppoe
    [Documentation]            Enters the WAN PPPoE Configuration Mode and show default values
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pppoe
    sleep                       1
    ${output}=                 write   show
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    #${read}=                  read
    set client configuration  prompt=#
    ${output}=         read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wan0-pppoe)#
    should contain              ${output}   PPPoE Configuration:    DNS_AUTO=Enable     USER_NAME=  PASSWORD=
    should contain              ${output}   MTU=    SERVICE_NAME=   ACCESS_CONCENTRATOR_NAME=   ADDITIONAL_PPPD_OPTIONS=
    ${exit}                     write  top
    ${exit}                     read
    should contain              ${exit}   (global)#

#mtu
Execute the mtu for WAN PPPoE
    [Tags]                     Config       WAN     wan0    conn pppoe  conn_pppoe     mtu_pppoe
    [Documentation]            Enters the WAN Static Configuration Mode and set mtu as 1325
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pppoe
    ${output}=                 write   mtu 1324     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0 -> Static
    sleep                       1
    ${output}=                 write   show
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    ${read}=                  read
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-pppoe)#    PPPoE Configuration:   MTU=1324
    should not be empty         ${output}
    should not contain          ${output}   MTU=1500
    ${exit}                     write  top
    ${exit}                     read
    should contain              ${exit}   (global)#

#dns
Execute the dns for WAN PPPoE
    [Tags]                     Config       WAN     wan0    conn_pppoe     dns_pppoe
    [Documentation]            Enters the WAN PPPoE Configuration Mode and to set dns as 8.8.8.8
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pppoe
    ${output}=                 write   dns 8.8.8.8     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0 -> Static
    sleep                       1
    ${output}=                 write   show
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    ${read}=                  read
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-pppoe)#    PPPoE Configuration:   DNS_SERVER1=8.8.8.8
    should not be empty         ${output}
    should not contain          ${output}   MTU=1500    DNS_SERVER=
    ${exit}                     write  top
    ${exit}                     read
    should contain              ${exit}   (global)#

#username
Execute the username for WAN PPPoE
    [Tags]                     Config       WAN     wan0    conn_pppoe     username_pppoe
    [Documentation]            Enters the WAN PPPoE Configuration Mode and to set username as leroy_jenkins
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pppoe
    ${output}=                 write   username leroy_jenkins
    sleep                       1
    ${output}=                 write   show
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    ${read}=                  read
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-pppoe)#    PPPoE Configuration:   USER_NAME=leroy_jenkins
    should not be empty         ${output}
    should not contain          ${output}   MTU=1500    USER_NAME=
    ${exit}                     write  top
    ${exit}                     read
    should contain              ${exit}   (global)#

#password
Execute the password for WAN PPPoE
    [Tags]                     Config       WAN     wan0    conn_pppoe     password_pppoe
    [Documentation]            Enters the WAN PPPoE Configuration Mode and to set password as atLeastWeHaveChicken
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pppoe
    ${output}=                 write   password atLeastWeHaveChicken
    sleep                       1
    ${output}=                 write   show
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    ${read}=                  read
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-pppoe)#    PPPoE Configuration:   PASSWORD=leroy_jenkins
    should not be empty         ${output}
    should not contain          ${output}   MTU=1500    PASSWORD=
    ${exit}                     write  top
    ${exit}                     read
    should contain              ${exit}   (global)#

#servicename
Execute the servicename for WAN PPPoE
    [Tags]                     Config       WAN     wan0    conn_pppoe     servicename_pppoe
    [Documentation]            Enters the WAN PPPoE Configuration Mode and to set servicename as user1-service
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pppoe
    ${output}=                 write   servicename user1-service
    sleep                       1
    ${output}=                 write   show
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    ${read}=                  read
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-pppoe)#    PPPoE Configuration:   SERVICE_NAME=user1-service
    should not be empty         ${output}
    should not contain          ${output}   MTU=1500    PASSWORD=
    ${exit}                     write  top
    ${exit}                     read
    should contain              ${exit}   (global)#

#acname
Execute the acname for WAN PPPoE
    [Tags]                     Config       WAN     wan0    conn_pppoe     acname_pppoe
    [Documentation]            Enters the WAN PPPoE Configuration Mode and to set servicename as user1-service
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pppoe
    ${output}=                 write   acname ispl.com
    sleep                       1
    ${output}=                 write   show
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    ${read}=                  read
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-pppoe)#    PPPoE Configuration:   ACCESS_CONCENTRATOR_NAME=ispl.com
    should not be empty         ${output}
    should not contain          ${output}   MTU=1500    ACCESS_CONCENTRATOR_NAME=
    ${exit}                     write  top
    ${exit}                     read
    should contain              ${exit}   (global)#

#options
Execute the options for WAN PPPoE
    [Tags]                     Config       WAN     wan0    conn_pppoe     options_pppoe
    [Documentation]            Enters the WAN PPPoE Configuration Mode and to set servicename as user1-service
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pppoe
    ${output}=                 write   options ignore-eol-tag
    sleep                       1
    ${output}=                 write   show
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    ${read}=                  read
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-pppoe)#    PPPoE Configuration:   ADDITIONAL_PPPD_OPTIONS=ignore-eol-tag
    should not be empty         ${output}
    should not contain          ${output}   MTU=1500    ADDITIONAL_PPPD_OPTIONS
    ${exit}                     write  top
    ${exit}                     read
    should contain              ${exit}   (global)#

#exit from PPPoE
Exit from PPPoE
    [Tags]                     Config       WAN     wan0    conn_pppoe     exit_pppoe
    [Documentation]            Exit the WAN PPPoE Configuration Mode via "top" command and land at Global vonfiguration level
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#

Execute template
    [Tags]                      template
    [Documentation]             Update , apply and then show -
    ${output}=                 write   show
    sleep                       1   loglevel=NONE
    ${output}=                 write   apply
    #sleep                      1
    ${output}=                 write   show
    sleep                       1   loglevel=NONE
    ${output}=                  read
    should contain              ${output}   DNS
    should not be empty         ${output}
    should not contain          ${output}   ©
    should not contain          ${output}   ®
    should contain              ${output}   DNS
    #should contain             ${output}   (config-if-wan0-dhcp)#

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
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}
