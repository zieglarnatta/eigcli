*** Settings ***
Documentation    Suite description
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
Execute connect static Wan & then back out
    [Tags]                     Config       WAN     wan0    conn static     conn_static_in_out
    [Documentation]            Enters the WAN Static Configuration Mode, then use top & 3 exits to go back to Global Configuration
    ${output}=                  write   top
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
    ${output}=                  write   top
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
    ${output}=                  write   top
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
    ${output}=                  write   top
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
    ${output}=                  write   top
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
    ${output}=                  write   top
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
    ${output}=                  write   top
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

*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}
