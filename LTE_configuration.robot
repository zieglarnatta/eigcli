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
#LTE configuration
LTE Configuration: Get into LTE & then back out to Global
    [Tags]                      Global  Config    LTE_config_in_out
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
    [Tags]                      Global  Config    LTE_apn
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
    [Tags]                      Global  Config    LTE_ip_type
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



*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}

#Open HTTP server on port 7272
#    Launch server       ${server}