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

Execute Help
    [Tags]                      Global     help
    [Documentation]             Execute Help command and report all help topics
    ${execute}=                 write              help
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}           -ash: help: not found

Execute History 10 And Verify Output
    [Tags]                      Global   history     10
    [Documentation]             Execute history 10 CLI and return the last 10
    ...                         The keyword returns the standard output by default.
    write                       history 10
    set client configuration    prompt=#
    ${output}=                  read until      history
    should not be empty         ${output}
    should not contain          ${output}       -ash: help: not found


Execute Ping on 8.8.8.8
    [Tags]                  Global     ping        8.8.8.8
    [Documentation]         Execute ping on 8.8.8.8 CLI and return the ping hops
    ...                     The keyword returns the standard output by default.
    write                   ping 8.8.8.8
    Sleep                   5
    ${output}=              read until      0% packet loss
    should not be empty     ${output}
    should not contain      ${output}       -ash: help: not found

Executing AR Ping
    [Tags]                      Global     ar_ping     ar  ping
    [Documentation]             Execute Ap Ping and report ping stats
    write                       ping 8.8.8.8 -I 172.16.23.166 repeat 3
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}       -ash: help: not found

Execute Traceroute
    [Tags]                      Global  traceroute
    [Documentation]             Execute Traceroute and report traceroute stats
    ${execute}=                 write       traceroute 8.8.8.8 -s 172.16.23.166 -i eth1
    set client configuration    prompt=#
    ${output}=                  read until   traceroute: can't set multicast source interface
    should not contain          ${output}    Usage: ping [OPTIONS] HOST
    should not Be Equal         ${output}    traceroute: can't set multicast source interface    #has issues

Execute ps Processes
    [Tags]                      Global   ps
    [Documentation]             Execute the ps & return all of the processes
    ${execute}=                 write   ps
    set client configuration    prompt=#
    ${output}=                  read until prompt
    Sleep                       5
    should not be empty         ${output}
    should not contain          ${output}   -ash: help: not found

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

Execute show interfaces
    [Tags]                      Global  show    interfaces
    [Documentation]             Execute the show interfaces & return all of the processes
    ${execute}=                 write   show interfaces
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: help: not found

Execute show ip route
    [Tags]                      Global  show    ip  route
    [Documentation]             Execute the show ip route & return all of the processes
    ${execute}=                 write   show ip route
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: help: not found

Execute show iptables
    [Tags]                      Global  show    iptables
    [Documentation]             Execute the show iptables & return all of the processes
    ${execute}=                 write   show iptables
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: help: not found

Execute "configure" and then "top" to go back to global
    [Tags]                      Configure   top     Global      configure_to_global
    [Documentation]             Execute the configure and then retreat back to global
    ${execute}=                 write   configure
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: configure: not found     (global)#
    should contain              ${output}   (config)#
    ${execute}=                 write       top
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: top: not found
    should not contain          ${output}   (config)#
    should contain              ${output}   (global)#

Execute config
    [Tags]                      Config      config_start
    [Documentation]             Execute the config & confirm prompt is in config level
    ${execute}=                 write   configure
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: configure: not found
    should not contain          ${output}   (global)#
    should contain              ${output}   (config)#

Execute ntp server configuration and show it
    [Tags]                      Config      ntp     show_ntp
    [Documentation]             Execute the ntp & confirm ntp servers are updated & shown
    ${execute}=                 write   ntp server1 www.yahoo.com server2 www.google.com
    ${showntp}=                 write   show ntp
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: ntp: not found
    should not contain          ${output}   -ash: show ntp: not found
    should contain              ${output}   (config)#


*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}
