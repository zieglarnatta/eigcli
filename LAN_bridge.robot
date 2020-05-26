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
#LAN0 Bridge
LAN0 Bridge: Get into LAN bridge & then back out to Global
    [Tags]                      Global  Config  bridge  LAN  lan_bridge_in_out
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
    [Tags]                      Global  Config  bridge  LAN  lan_bridge_ip
    [Documentation]             Execute the LAN bridge IP address & then ake sure it reflects it
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    sleep                       1   #give the system 1 second to rest, seems to help decrease it from tripping on itself
    ${ipaddress}=               write  ip 192.168.1.1
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
    [Tags]                      Global  Config  bridge  LAN  lan_bridge_net_mask
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


*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}

#Open HTTP server on port 7272
#    Launch server       ${server}