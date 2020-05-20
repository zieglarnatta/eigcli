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
Execute conn dhcp to enter the WAN DHCP Configuration Mode, do initial read out & back out via top and 3 exits
    [Tags]                      Config      WAN     wan0    dhcp    conn_dhcp
    [Documentation]             Enters the WAN DHCP Configuration Mode
    ${output}=                 write   configure
    ${output}=                 write   interface ethernet wan0
    ${output}=                 write   conn dhcp
    #sleep                       1
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
    #sleep                       1
    ${output}=                 write   interface ethernet wan0
    #sleep                       1
    ${output}=                 write   conn dhcp
    #sleep                       1
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
    sleep                       1
    ${exit}                     read
    should contain              ${exit}   (global)#


Execute update DHCP DNS and then show the applied result
    [Tags]                      Config      WAN     wan0    dhcp   dns_dhcp
    [Documentation]             Update DNS, apply and then show new DNS
    ${output}=                 write   configure
    ${output}=                 write   interface ethernet wan0
    ${output}=                 write    conn dhcp
    ${output}=                 write   dns 8.8.4.4 8.8.8.8
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    #${output}=                 write   apply
    #sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should contain              ${output}   DNS_SERVER1=8.8.4.4
    should contain              ${output}   DNS_SERVER2=8.8.8.8
    should contain              ${output}   (config-if-wan0-dhcp)#
    should not be empty         ${output}
    should not contain          ${output}   -ash: ntp: not found    -ash: show ntp: not found
    ${exit}                     write  top
    sleep                       1
    ${exit}                     read
    should contain              ${exit}   (global)#

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
    should contain              ${output}   (config-if-wan0-dhcp)#
    should not be empty         ${output}
    ${exit}                     write  top
    sleep                       1
    ${exit}                     read
    should contain              ${exit}   (global)#

Execute update DHCP querymode to normal (from aggresive default) & then show the applied result
    [Tags]                      Config      WAN     wan0    dhcp   querymode_DHCP
    [Documentation]             update query mode from Aggresive to Normal
    ${output}=                 write   configure
    ${output}=                 write   interface ethernet wan0
    ${output}=                 write   conn dhcp
    sleep                       1
    ${output}=                 write   querymode normal
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    #${output}=                 write   apply
    #sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should contain              ${output}   QUERY_MODE=Normal
    should contain              ${output}   (config-if-wan0-dhcp)#
    should not be empty         ${output}
    should not contain          ${output}   QUERY_MODE=Agressive
    ${exit}                     write  top
    sleep                       1
    ${exit}                     read
    should contain              ${exit}   (global)#

*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}
