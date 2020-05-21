*** Settings ***
Documentation          This example demonstrates executing a command on a remote machine
...                    and getting its output.
...
...                    Notice how connections are handled as part of the suite setup and
...                    teardown. This saves some time when executing several test cases.

Library                 Process
Library                SSHLibrary
Suite Setup            Open Connection And Log In
Suite Teardown         Close All Connections
Resource            resourceLocal.robot

*** Test Cases ***
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

*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}

#Open HTTP server on port 7272
#    Launch server       ${server}