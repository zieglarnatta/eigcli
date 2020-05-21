*** Settings ***
Documentation          This example demonstrates executing a command on a remote machine
...                    and getting its output.
...
...                    Notice how connections are handled as part of the suite setup and
...                    teardown. This saves some time when executing several test cases.

Library                Process
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
    should contain              ${output}   0% packet loss

#Start python http server
#    [Tags]                      Global     ar_ping     ar  ping     python_http_server
#    [Documentation]             Start the http python on localhost on port 7272
#    run process                 python  ${server}   timeout=3min	on_timeout=continue

Global AR Ping
    [Tags]                      Global     ar_ping     ar  ping
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

Global Traceroute
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
    sleep                       2
    #set client configuration    prompt=(global)#
    ${output}=                  read    #until prompt
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
    ${execute}=                 write   top
    ${execute}=                 write   configure
    ${execute}=                 write   ntp server1 www.yahoo.com server2 www.google.com        loglevel=DEBUG
    sleep                       1
    ${ntp}=                  write   show ntp       loglevel=DEBUG
    sleep                       2
    #set client configuration   prompt=(config)#
    ${ntp}=                 read     #until prompt        loglevel=WARN
    #${ntp}=                  read until      www.yahoo.com        loglevel=WARN
    should not be empty         ${ntp}
    should not contain          ${ntp}   -ash: ntp: not found    -ash: show ntp: not found
    should contain              ${ntp}   (config)#     www.yahoo.com
    should contain             ${ntp}   NTP Server1 www.yahoo.com    loglevel=WARN
    ${exit}                     write  top
    ${exit}                     read
    should contain              ${exit}   (global)#
    ${output}=                 write   echo Stahp it NTP!
    should be equal             ${output} Stahp it NTP!

#WAN0
WAN Configuration Wan0 Mode and back out via exit & top
    [Tags]                      WAN     wan0    wan_configuration
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
    ${exit}                     read
    should contain              ${exit}   (global)#

#WAN0 DHCP
Execute conn dhcp to enter the WAN DHCP Configuration Mode, do initial read out & back out via top and 3 exits
    [Tags]                      Config      WAN     wan0    dhcp    conn_dhcp
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

Execute update DHCP mtu, apply and then show DHCP
    [Tags]                      Config      WAN     wan0    dhcp   mtu_dhcp
    [Documentation]             Update mtu, apply and then show DHCP
    ${execute}=                 write   top
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
    ${execute}=                 write   top
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
    ${exit}                     read
    should contain              ${exit}   (global)#

Execute update DHCP querymode to normal (from aggresive default) & then show the applied result
    [Tags]                      Config      WAN     wan0    dhcp   querymode_DHCP
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
    ${exit}                     read
    should contain              ${exit}   (global)#

#next to reset and clean it up
#WIP

#WAN Static config
Execute connect static Wan & then back out
    [Tags]                     Config       WAN     wan0    conn static     conn_static_in_out
    [Documentation]            Enters the WAN Static Configuration Mode, then use top & 3 exits to go back to Global Configuration
    ${execute}=                 write   top
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
    ${exit}                     read
    should contain              ${exit}   (global)#

Execute the dns for WAN Static
    [Tags]                     Config       WAN     wan0    conn_static     dns_static
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
    should not contain          ${output}   MTU=1500    DNS_SERVER=
    ${exit}                     write  top
    ${exit}                     read
    should contain              ${exit}   (global)#

Execute the ip for WAN Static
    [Tags]                     Config       WAN     wan0    conn_static     ip_static
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
    should not contain          ${output}   MTU=1500    DNS_SERVER=     IP_ADDR=
    ${exit}                     write  top
    ${exit}                     read
    should contain              ${exit}   (global)#

Execute the netmask for WAN Static
    [Tags]                     Config       WAN     wan0    conn_static     netmask_static
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
    should not contain          ${output}   MTU=1500    DNS_SERVER=     IP_ADDR=    NETMASK=
    ${exit}                     write  top
    ${exit}                     read
    should contain              ${exit}   (global)#

Execute the gateway for WAN Static
    [Tags]                     Config       WAN     wan0    conn_static     gateway_static
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
    ${exit}                     read
    should contain              ${exit}   (global)#

#WAN PPPoE
Execute connect PPPoE Wan & then back out
    [Tags]                     Config       WAN     wan0    conn pppoe     conn_pppoe_in_out
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
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config-if-wan0)#   (config)#   (config-if-wan0-pppoe)#

#connect again
Execute conn PPPoE to enter Wan PPPoE
    [Tags]                     Config       WAN     wan0    conn pppoe  conn_pppoe  enter_pppoe
    [Documentation]            Enters the WAN PPPoE Configuration Mode and show default values
    ${execute}=                 write   top
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
    ${execute}=                 write   top
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
    ${execute}=                 write   top
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
    ${execute}=                 write   top
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
    ${execute}=                 write   top
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
    ${execute}=                 write   top
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
    ${execute}=                 write   top
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
    ${execute}=                 write   top
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

#PPTP
Enter PPTP and then back out to Global
    [Tags]                      Config       WAN     wan0    conn_pptp  conn_pptp_in_out    pptp
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
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config-if-wan0)#   (config)#   (config-if-wan0-pptp)#

Execute conn pptp to Enter PPTP
    [Tags]                      Config       WAN     wan0    conn_pptp
    [Documentation]             Fire off the conn pptp and then verify it's in PPTP
    #configure -> interface ethernet wan0 -> conn pptp
    ${execute}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pptp
    sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter mtu 1433   #has problems not showing
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_mtu
    [Documentation]             Fire off the conn pptp and then set the mtu
    ${execute}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pptp
    ${output}=                  write  mtu 1433
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   MTU=1433    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter DNS
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_dns
    [Documentation]             Fire off the conn pptp and then set the dns
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pptp
    sleep                       1
    ${output}=                  write  dns 8.8.8.8
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   DNS_SERVER1=8.8.8.8    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter PPTP IP
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_ip
    [Documentation]             Fire off the ip and then set the ip
    ${execute}=                 write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pptp
    sleep                       1
    ${output}=                  write  ip 192.168.0.204
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   IP_ADDR=192.168.0.204    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter netmask   #has issues, not working, not showing
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_netmask
    [Documentation]             Fire off the netmask and then set the netmask
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pptp
    sleep                       1
    ${output}=                  write  netmask 255.255.0.0
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   NETMASK=255.255.0.0    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter gateway   #has issues, not working, not showing
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_gateway
    [Documentation]             Fire off the netmask and then set the gateway
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pptp
    sleep                       1
    ${output}=                  write  gateway 255.255.0.0
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   GATEWAY=255.255.0.0    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter username   #has problems not showing
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_username
    [Documentation]             Fire off the username and then set the username
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pptp
    sleep                       1
    ${output}=                  write  username paul_dirac
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   USER_NAME=paul_dirac    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter password   #has problems not showing
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_password
    [Documentation]             Fire off the password and then set the password
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pptp
    sleep                       1
    ${output}=                  write  password futurePurplePeopleEater
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   PASSWORD=futurePurplePeopleEater    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter vpn   #has problems not showing
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_vpn
    [Documentation]             Fire off the vpn and then set the vpn
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pptp
    sleep                       1
    ${output}=                  write  vpn symantec.com
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   VPN_SERVER=symantec.com    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter hostname
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_hostname
    [Documentation]             Fire off the hostname and then set the hostname
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pptp
    sleep                       1
    ${output}=                  write  host yeehaw2
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   Hostname=yeehaw2    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter default route: enable  #has problems
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_defaultroute
    [Documentation]             Fire off the default route and then set the default route
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pptp
    sleep                       1
    ${output}=                  write  defaultroute enable
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   DEFAULT_ROUTE=enable    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter Encrypt mppe128  #has problems, nothing shown
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_encrypt
    [Documentation]             Fire off the encrypt and then set the encrytion to mppe128
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pptp
    sleep                       1
    ${output}=                  write  encrypt mppe128
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   encrypt    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter options   #has issues
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_options
    [Documentation]             Fire off the options and then set the options as ttyname
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn pptp
    sleep                       1
    ${output}=                  write  options ttyname
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   ADDITIONAL_PPPD_OPTIONS=ttyname    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

#exit from pptp
Exit from PPPoE
    [Tags]                     Config       WAN     wan0    conn_pptp     exit_pptp
    [Documentation]            Exit the WAN L2TP Configuration Mode via "top" command and land at Global vonfiguration level
    ${output}=                 write   top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#

#L2TP
Enter L2TP and then back out to Global
    [Tags]                      Config       WAN     wan0    conn_l2tp  conn_l2tp_in_out    l2tp
    [Documentation]             Fire off the conn l2tp and then back out via top and then back in and back out via 3 exits
    #configure -> interface ethernet wan0 -> conn l2tp
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
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
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config-if-wan0)#   (config)#   (config-if-wan0-l2tp)#

Execute conn l2tp to Enter l2tp
    [Tags]                      Config       WAN     wan0    conn_l2tp
    [Documentation]             Fire off the conn l2tp and then verify it's in l2tp
    #configure -> interface ethernet wan0 -> conn l2tp
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    #sleep                       1
    ${output}=                 write   conn l2tp
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter mtu 1432   #has problems not showing
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_mtu
    [Documentation]             Fire off the conn l2tp and then set the mtu
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn l2tp
    sleep                       1
    ${output}=                  write  mtu 1432
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   MTU=1432    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter DNS
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_dns
    [Documentation]             Fire off the conn l2tp and then set the dns
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn l2tp
    sleep                       1
    ${output}=                  write  dns 192.168.0.205
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   DNS_SERVER1=192.168.0.205    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter l2tp IP
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_ip
    [Documentation]             Fire off the ip and then set the ip
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn l2tp
    sleep                       1
    ${output}=                  write  ip 192.168.0.206
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   IP_ADDR=192.168.0.206    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter netmask   #has issues, not working, not showing
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_netmask
    [Documentation]             Fire off the netmask and then set the netmask
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn l2tp
    sleep                       1
    ${output}=                  write  netmask 255.255.0.0
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   NETMASK=255.255.0.0    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter gateway   #has issues, not working, not showing
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_gateway
    [Documentation]             Fire off the netmask and then set the gateway
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn l2tp
    sleep                       1
    ${output}=                  write  gateway 255.255.0.0
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   GATEWAY=255.255.0.0    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top
    ${exit}                     write  top

Enter username   #has problems not showing
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_username
    [Documentation]             Fire off the username and then set the username
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn l2tp
    sleep                       1
    ${output}=                  write  username ziegler_natta
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   USER_NAME=ziegler_natta    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter password   #has problems not showing
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_password
    [Documentation]             Fire off the password and then set the password
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn l2tp
    sleep                       1
    ${output}=                  write  password reduxProcessChemistry
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   PASSWORD=reduxProcessChemistry    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter vpn   #has problems not showing
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_vpn
    [Documentation]             Fire off the vpn and then set the vpn
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn l2tp
    sleep                       1
    ${output}=                  write  vpn macaffee.com
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   VPN_SERVER=macaffee.com    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter hostname
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_hostname
    [Documentation]             Fire off the hostname and then set the hostname
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn l2tp
    sleep                       1
    ${output}=                  write  host yeehaw3
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   Hostname=yeehaw3    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter default route: enable  #has problems not enabled
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_defaultroute
    [Documentation]             Fire off the default route and then set the default route
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn l2tp
    sleep                       1
    ${output}=                  write  defaultroute enable
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   DEFAULT_ROUTE=enable    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

Enter options   #has problems, snow showing
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_options
    [Documentation]             Fire off the options and then set the options as ttyname
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    ${output}=                 write   conn l2tp
    sleep                       1
    ${output}=                  write  options ttyname
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   ADDITIONAL_PPPD_OPTIONS=ttyname    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    ${exit}                     write  top

#exit from L2TP
Exit from L2TP
    [Tags]                     Config       WAN     wan0    conn_L2TP     exit_L2TP
    [Documentation]            Exit the WAN L2TP Configuration Mode via "top" command and land at Global vonfiguration level
    ${output}=                 write   top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#

#WLAN 2.4g
Enter Wifi 2.4g and then back out to Global
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_in_out
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> conn
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
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

Enter disable
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_disable
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
    #need to incorporate a UI robot to check on this in teh admin
    ${exit}                     write  top

Enter enable
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_enable
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
Enter security WPA and then back out
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_security_wpa_in_out
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
    #sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    #sleep                       1
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

Enter security WPA2 and then back out
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_security_wpa2_in_out
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
    #sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    #sleep                       1
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

Enter security WPA3 and then back out
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_security_wpa3_in_out
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
    #sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    #sleep                       1
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

Enter security WPA12 Mix and then back out
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_security_wpa12_mix_in_out
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
    #sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    #sleep                       1
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

Enter security WPA23 mix and then back out
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_security_wpa23_mix_in_out
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
    #sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    #sleep                       1
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

Enter security WPA2 enterprise and then back out
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_security_wpa2_enterprise_in_out
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
    #sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    #sleep                       1
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

Enter security WPA3 enterprise and then back out
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_security_wpa3_enterprise_in_out
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
    #sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    #sleep                       1
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

Enter security WPA12 mix enterprise and then back out
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_security_wpa12_mix_enterprise_in_out
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
    #sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    #sleep                       1
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


#exit from WLAN 2.4g
Exit from WLAN 2.4g
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_exit
    [Documentation]            Exit the WLAN 2.4g Configuration Mode via "top" command and land at Global vonfiguration level
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#

#WLAN Guest 2.4g
Enter WLAN Guest 2.4g and then back out to Global
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_in_out
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

Enter disable
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_disable
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

Enter enable
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_enable
    [Documentation]             Fire off the enable and check that wifi 2.4g is enabled
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  enable
    sleep                       10
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    sleep                       1
    #should be empty             ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config)#   (global)#
    #need to incorporate a UI robot to check on this in the admin
    ${exit}                     write  top

#enter all the security wpa and then back out
Enter security WPA and then back out
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa_in_out
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

Enter security WPA2 and then back out
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa2_in_out
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

Enter security WPA3 and then back out
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa3_in_out
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

Enter security WPA12 Mix and then back out
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa12_mix_in_out
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

Enter security WPA23 mix and then back out
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa23_mix_in_out
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

Enter security WPA2 enterprise and then back out
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa2_enterprise_in_out
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

Enter security WPA3 enterprise and then back out
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa3_enterprise_in_out
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

Enter security WPA12 mix enterprise and then back out
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa12_mix_enterprise_in_out
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


#exit from WLAN 2.4g
Exit from WLAN 2.4g
    [Tags]                      Config  interface_wifi_guest_2_4g     interface_wifi_guest_2_4g_exit
    [Documentation]            Exit the WLAN 2.4g Configuration Mode via "top" command and land at Global vonfiguration level
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#

#WLAN 2.4g: WPA
WLAN 2.4g: WPA Enter WPA personal
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa_enter
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> seecurity wpa
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


WLAN 2.4g: WPA Set SSID for WPA Personal WLAN 2.4g
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_wpa_ssid
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

WLAN 2.4g: WPA SSID Hide enabled
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 2.4g is SSID is hidden disabled
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

WLAN 2.4g: WPA SSID broadcast
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa_ssid_broadcast
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

WLAN 2.4g: WPA Password
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa_password
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

WLAN 2.4g: WPA maxclient
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa_maxclient
    [Documentation]             Fire off the maclient and check that max clients is updated
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

WLAN 2.4g: WPA Rekey key rotation interval
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa_rekey
    [Documentation]             Fire off the password and check that password is updated
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

#exit from WLAN WPA 2.4g
Exit from WLAN 2.4g WPA
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_wpa_exit
    [Documentation]            Exit the WLAN 2.4g Configuration Mode via "top" command and land at Global vonfiguration level
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#

#WLAN WPA2 2.4g
WLAN WPA2 2.4g: wpa2 personal
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enter
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> seecurity wpa2
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
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_wpa2_ssid
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
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 2.4g is SSID is hidden disabled
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
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_ssid_broadcast
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
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_password
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
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_pmf
    [Documentation]             Fire off the password and check that password is updated
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
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_maxclient
    [Documentation]             Fire off the maclient and check that max clients is updated
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
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_rekey
    [Documentation]             Fire off the password and check that password is updated
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

#exit from WLAN wpa2 2.4g
Exit from WLAN 2.4g wpa2
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_wpa2_exit
    [Documentation]            Exit the WLAN 2.4g Configuration Mode via "top" command and land at Global vonfiguration level
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#

#WLAN 2.4g WPA3
WLAN 2.4g WPA3: Enter wpa3 personal
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_enter
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> seecurity wpa3
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
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_wpa3_ssid
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
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 2.4g is SSID is hidden disabled
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
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_ssid_broadcast
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
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_password
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
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_maxclient
    [Documentation]             Fire off the maclient and check that max clients is updated
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
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_rekey
    [Documentation]             Fire off the password and check that password is updated
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

#exit from WLAN wpa3 2.4g
Exit from WLAN 2.4g wpa3
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_wpa3_exit
    [Documentation]            Exit the WLAN 2.4g Configuration Mode via "top" command and land at Global vonfiguration level
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#

#WLAN WPA 12 mix personal 2.4g
WLAN 2.4g: Enter wpa12_mix personal
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_enter
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> seecurity wpa12_mix
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
    ${exit}=                    write top


WLAN 2.4g: Set SSID for wpa12_mix Personal WLAN 2.4g
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_wpa12_mix_ssid
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
    ${exit}=                    write top

WLAN 2.4g: SSID Hide enabled
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 2.4g is SSID is hidden disabled
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
    ${exit}=                    write top

WLAN 2.4g: SSID broadcast
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_ssid_broadcast
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
    ${exit}=                    write top

WLAN 2.4g: Password
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_password
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
    ${exit}=                    write top

WLAN 2.4g: maxclient
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_maxclient
    [Documentation]             Fire off the maclient and check that max clients is updated
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
    ${exit}=                    write top

WLAN 2.4g: Rekey key rotation interval
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_rekey
    [Documentation]             Fire off the password and check that password is updated
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
    ${exit}=                    write top

#exit from WLAN wpa12_mix 2.4g
Exit from WLAN 2.4g wpa12_mix personal
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_wpa12_mix_exit
    [Documentation]            Exit the WLAN 2.4g Configuration Mode via "top" command and land at Global vonfiguration level
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    ${exit}=                    write top

#WLAN 2.4g WPA23 Mix personal
WLAN 2.4g: Enter wpa23_mix personal
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa23_mix_enter
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> seecurity wpa23_mix
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


WLAN 2.4g: Set SSID for wpa23_mix Personal WLAN 2.4g
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_wpa23_mix_ssid
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

WLAN 2.4g: SSID Hide enabled
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa23_mix_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 2.4g is SSID is hidden disabled
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

WLAN 2.4g: SSID broadcast
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa23_mix_ssid_broadcast
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

WLAN 2.4g: Password
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa23_mix_password
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

WLAN 2.4g: maxclient
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa23_mix_maxclient
    [Documentation]             Fire off the maclient and check that max clients is updated
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

WLAN 2.4g: Rekey key rotation interval
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa23_mix_rekey
    [Documentation]             Fire off the password and check that password is updated
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

#exit from WLAN wpa23_mix 2.4g
Exit from WLAN 2.4g wpa23_mix
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_wpa23_mix_exit
    [Documentation]            Exit the WLAN 2.4g Configuration Mode via "top" command and land at Global configuration level
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#

#WLAN 2.4g WPA2 enterprise
Enter wpa2_enterprise
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enterprise_enter
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> seecurity wpa2_enterprise
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


Set SSID for wpa2_enterprise WLAN 2.4g
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_wpa2_enterprise_ssid
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

SSID Hide enabled
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enterprise_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 2.4g is SSID is hidden disabled
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

SSID broadcast
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enterprise_ssid_broadcast
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

Server IP
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enterprise_server
    [Documentation]             Fire off the password and check that password is updated
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

Port forwarding
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enterprise_port
    [Documentation]             Fire off the password and check that password is updated
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

Connection secret
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enterprise_secret
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

PMF protected Management Frames
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enterprise_pmf
    [Documentation]             Fire off the password and check that password is updated
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

maxclient
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enterprise_maxclient
    [Documentation]             Fire off the maclient and check that max clients is updated
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

Rekey key rotation interval
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa2_enterprise_rekey
    [Documentation]             Fire off the key rotattion and check that upper & lower limits tested & key rotataion is updated
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

#exit from WLAN wpa2_enterprise 2.4g
Exit from WLAN 2.4g wpa2_enterprise
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_wpa2_enterprise_exit
    [Documentation]            Exit the WLAN 2.4g Configuration Mode via "top" command and land at Global configuration level
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#

#WLAN 2.4g WPA3 enterprise
WLAN 2.4g: Enter wpa3_enterprise
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_enterprise_enter
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> seecurity wpa3_enterprise
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


WLAN 2.4g: Set SSID for wpa3_enterprise
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_wpa3_enterprise_ssid
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
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_enterprise_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 2.4g is SSID is hidden disabled
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
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_enterprise_ssid_broadcast
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
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_enterprise_server
    [Documentation]             Fire off the password and check that password is updated
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
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_enterprise_port
    [Documentation]             Fire off the password and check that password is updated
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
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_enterprise_secret
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
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_enterprise_maxclient
    [Documentation]             Fire off the maclient and check that max clients is updated
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
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_enterprise_rekey
    [Documentation]             Fire off the password and check that password is updated
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

#exit from WLAN wpa3_enterprise 2.4g
Exit from WLAN 2.4g wpa3_enterprise
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_wpa3_enterprise_exit
    [Documentation]            Exit the WLAN 2.4g Configuration Mode via "top" command and land at Global configuration level
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#

#WLAN 2.4g WPA12 mix enterprise
WLAN 2.4g: Enter wpa12_mix_enterprise
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_enterprise_enter
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> seecurity wpa12_mix_enterprise
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
    #${exit}                     read
    #should contain              ${exit}   (global)#


WLAN 2.4g WPA12 mix enterprise: Set SSID for wpa12_mix_enterprise
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_wpa12_mix_enterprise_ssid
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
    #${exit}                     read
    #should contain              ${exit}   (global)#

WLAN 2.4g WPA12 mix enterprise: SSID Hide enabled
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_enterprise_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 2.4g is SSID is hidden disabled
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
    #${exit}                     read
    #should contain              ${exit}   (global)#

WLAN 2.4g WPA12 mix enterprise: SSID broadcast
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_enterprise_ssid_broadcast
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
    #should contain              ${exit}   (global)#

WLAN 2.4g WPA12 mix enterprise: Server IP
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_enterprise_server
    [Documentation]             Fire off the password and check that password is updated
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
    #should contain              ${exit}   (global)#

WLAN 2.4g WPA12 mix enterprise: Port forwarding
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_enterprise_port
    [Documentation]             Fire off the password and check that password is updated
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
    #should contain              ${exit}   (global)#

WLAN 2.4g WPA12 mix enterprise: Connection secret
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_enterprise_secret
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
    #should contain              ${exit}   (global)#

WLAN 2.4g WPA12 mix enterprise: maxclient
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_enterprise_maxclient
    [Documentation]             Fire off the maclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa12_mix_enterprise
    ${output}=                  write  maxclient 117
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  MAX_CLIENTS=117
    ${exit}                     write  top
    #should contain              ${exit}   (global)#

WLAN 2.4g WPA12 mix enterprise: Rekey key rotation interval
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa12_mix_enterprise_rekey
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
    #should contain              ${exit}   (global)#

#exit from WLAN wpa12_mix_enterprise 2.4g
WLAN 2.4g WPA12 mix enterprise: Exit from WLAN 2.4g wpa12_mix_enterprise
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_wpa12_mix_enterprise_exit
    [Documentation]            Exit the WLAN 2.4g Configuration Mode via "top" command and land at Global configuration level
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#

#WLAN 5g
WLAN 5g: Enter Wifi 5g and then back out to Global
    [Tags]                      Config  interface_wifi5g  interface_wifi5g_in_out
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
    [Tags]                      Config  interface_wifi5g  interface_wifi5g_disable
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
    #need to incorporate a UI robot to check on this in teh admin
    ${exit}                     write  top

WLAN 5g: Enter enable
    [Tags]                      Config  interface_wifi5g  interface_wifi5g_enable
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
    [Tags]                      Config  interface_wifi5g  interface_wifi5g_security_wpa_in_out
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
    [Tags]                      Config  interface_wifi5g  interface_wifi5g_security_wpa2_in_out
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
    [Tags]                      Config  interface_wifi5g  interface_wifi5g_security_wpa3_in_out
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
    [Tags]                      Config  interface_wifi5g  interface_wifi5g_security_wpa12_mix_in_out
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
    [Tags]                      Config  interface_wifi5g  interface_wifi5g_security_wpa23_mix_in_out
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
    [Tags]                      Config  interface_wifi5g  interface_wifi5g_security_wpa2_enterprise_in_out
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
    [Tags]                      Config  interface_wifi5g  interface_wifi5g_security_wpa3_enterprise_in_out
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
    [Tags]                      Config  interface_wifi5g  interface_wifi5g_security_wpa12_mix_enterprise_in_out
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


#exit from WLAN 5g
Exit from WLAN 5g
    [Tags]                      Config  interface_wifi5g     interface_wifi5g_exit
    [Documentation]            Exit the WLAN 5g Configuration Mode via "top" command and land at Global vonfiguration level
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#

#WLAN Guest 5g
WLAN 5g Guest: Enter WLAN Guest 5g and then back out to Global
    [Tags]                      Config  interface_wifi_guest_5g  interface_wifi_guest_5g_in_out
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
    [Tags]                      Config  interface_wifi_guest_5g  interface_wifi_guest_5g_disable
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
    [Tags]                      Config  interface_wifi_guest_5g  interface_wifi_guest_5g_enable
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
    [Tags]                      Config  interface_wifi_guest_5g  interface_wifi_guest_5g_security_wpa_in_out
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
    [Tags]                      Config  interface_wifi_guest_5g  interface_wifi_guest_5g_security_wpa2_in_out
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
    [Tags]                      Config  interface_wifi_guest_5g  interface_wifi_guest_5g_security_wpa3_in_out
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
    [Tags]                      Config  interface_wifi_guest_5g  interface_wifi_guest_5g_security_wpa12_mix_in_out
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
    [Tags]                      Config  interface_wifi_guest_5g  interface_wifi_guest_5g_security_wpa23_mix_in_out
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
    [Tags]                      Config  interface_wifi_guest_5g  interface_wifi_guest_5g_security_wpa2_enterprise_in_out
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
    [Tags]                      Config  interface_wifi_guest_5g  interface_wifi_guest_5g_security_wpa3_enterprise_in_out
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
    [Tags]                      Config  interface_wifi_guest_5g  interface_wifi_guest_5g_security_wpa12_mix_enterprise_in_out
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


#exit from WLAN 5g Guest
Exit from WLAN 5g Guest
    [Tags]                      Config  interface_wifi_guest_5g     interface_wifi_guest_5g_exit
    [Documentation]            Exit the WLAN 5g Configuration Mode via "top" command and land at Global vonfiguration level
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#

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
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}
