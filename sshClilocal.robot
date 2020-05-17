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
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}       -ash: help: not found

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

Global show interfaces
    [Tags]                      Global  show    interfaces
    [Documentation]             Execute the show interfaces & return all of the processes
    ${execute}=                 write   show interfaces
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: help: not found

Global show ip route
    [Tags]                      Global  show    ip  route
    [Documentation]             Execute the show ip route & return all of the processes
    ${execute}=                 write   show ip route
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: help: not found

Global show iptables
    [Tags]                      Global  show    iptables    show_iptables
    [Documentation]             Execute the show iptables & return all of the processes
    ${execute}=                 write   show iptables
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: help: not found

Execute "configure" and then "exit", then back to "confiure" and use "top" to go back to global configuration
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
Execute config to enter System Config level
    [Tags]                      System_Configuration    config_start
    [Documentation]             Execute the config & confirm prompt is in System config level
    ${execute}=                 write   configure
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: configure: not found
    should not contain          ${output}   (global)#
    should contain              ${output}   (config)#

Global ntp server configuration and show it (has problem matching with double space, also ntp updated on server 6 rather than 1)
    [Tags]                      System_Configuration    ntp     show_ntp
    [Documentation]             Execute the ntp & confirm ntp servers are updated & shown
    ${execute}=                 write   ntp server1 www.yahoo.com server2 www.google.com        loglevel=DEBUG
    ${output}=                  write   show ntp       loglevel=DEBUG
    #set client configuration   prompt=#
    #${output}=                 read until prompt        loglevel=DEBUG
    ${output}=                  read until      www.yahoo.com        loglevel=DEBUG
    should not be empty         ${output}
    should not contain          ${output}   -ash: ntp: not found
    should not contain          ${output}   -ash: show ntp: not found
    should contain              ${output}   (config)#
    #should contain              ${output}   "NTP Server5  time-e-b.nist.gov"
    should contain              ${output}   www.yahoo.com
    #should be equal             ${output}   NTP Server1 www.yahoo.com
    should contain             ${output}   NTP Server1 www.yahoo.com

Exit from System config
    [Tags]                      System_Configuration    config_end
    [Documentation]             Exit from System config level to Global COnfi level
    ${execute}=                 write   exit
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: configure: not found
    should not contain          ${output}   (config)#
    should contain              ${output}   (global)#


WAN Configuration Mode and back out via exit & top
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


Execute config to enter the WAN DHCP Configuration Mode and do initial read out
    [Tags]                      Config      WAN     wan0    conn dhcp
    [Documentation]             Enters the WAN DHCP Configuration Mode
    ${output}=                 write   configure
    sleep                       1
    ${output}=                 write   interface ethernet wan0
    sleep                       1
    ${output}=                 write   conn dhcp
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}   -ash: ntp: not found
    should not contain          ${output}   -ash: show ntp: not found
    should contain              ${output}   (config-if-wan0-dhcp)#

Execute update mtu, apply and then show DHCP
    [Tags]                      Config      WAN     wan0    conn dhcp   mtu
    [Documentation]             Update mtu, apply and then show DHCP
    ${output}=                 write   mtu 1234
    sleep                       1
    ${output}=                 write   apply
    #sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should contain              ${output}   MTU=1234

Execute update DNS and then show the applied result
    [Tags]                      Config      WAN     wan0    conn dhcp   dns
    [Documentation]             Update DNS, apply and then show new DNS
    ${output}=                 write   dns 8.8.4.4 8.8.8.8
    sleep                       1
    ${output}=                 write   apply
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


Execute update host name & then show the applied result
    [Tags]                      Config      WAN     wan0    conn dhcp   host
    [Documentation]             update host name as yeehaw, apply & then show it
    ${output}=                 write   host yeehaw
    sleep                       1
    ${output}=                 write   apply
    #sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should contain              ${output}   HOST_NAME=yeehaw
    should not be empty         ${output}
    #should not contain          ${output}   HOST_NAME=
    #should not contain          ${output}
    should contain              ${output}   (config-if-wan0-dhcp)#

Execute update querymode to normal (from aggresive default) & then show the applied result
    [Tags]                      Config      WAN     wan0    conn dhcp   querymode
    [Documentation]             update query mode from Aggresive to Normal
    ${output}=                 write   querymode normal
    sleep                       1
    ${output}=                 write   apply
    #sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should contain              ${output}   QUERY_MODE=Normal
    should not be empty         ${output}
    should not contain          ${output}   QUERY_MODE=Agressive
    #should contain              ${output}
    should contain              ${output}   (config-if-wan0-dhcp)#

#next to reset and clean it up
Execute Cleanup of Wan0 a.k.a. DHCP
    [Tags]                      Config      WAN     wan0    conn dhcp   cleanup
    [Documentation]             update query mode from Aggresive to Normal
    #reset the mtu back to auto
    ${output}=                 write   mtu auto
    sleep                       1
    ${output}=                 write   dns 8.8.4.4
    sleep                       1
    ${output}=                 write   dns 8.8.8.8
    sleep                       1
    ${output}=                 write   dns auto
    sleep                       1
    ${output}=                 write   host yeehaw
    sleep                       1
    ${output}=                 write   querymode agressive
    sleep                       1
    ${output}=                 write   apply
    sleep                       2
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should contain              ${output}   DHCP Configuration:
    should contain              ${output}   DNS_AUTO=Enable
    should contain              ${output}   HOST_NAME=
    should contain              ${output}   QUERY_MODE=Agressive
    should contain              ${output}   MTU_AUTO=Enable
    ${output}=                 write   exit     #get out from Global Connfiguration -> System configuration -> Ethernet Wan0 -> DHCP
    sleep                       1
    ${output}=                 write   exit     #get out from Global Connfiguration -> System configuration -> Ethernet Wan0
    sleep                       1
    ${output}=                 write   exit     #get out from Global Connfiguration -> System configuration
    sleep                       1
    should contain              ${output}   (global)#

#WAN Static config
Execute connect static Wan
    [Tags]                     Config       WAN     wan0    conn static
    [Documentation]            Enters the WAN Static Configuration Mode
    ${output}=                 write   configuration     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    sleep                       1
    ${output}=                 write   conn static     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0 -> Static
    sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-static)#
    should not be empty         ${output}

Execute template
    [Tags]                      Config      WAN     wan0    conn dhcp   template
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
