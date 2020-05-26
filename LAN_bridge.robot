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
#LAN0 Bridge DHCP
LAN0 Bridge DHCP: Get into LAN DHCP & then back out to Global
    [Tags]                      Global  Config  bridge  LAN  DHCP_in_out
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

*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}

#Open HTTP server on port 7272
#    Launch server       ${server}