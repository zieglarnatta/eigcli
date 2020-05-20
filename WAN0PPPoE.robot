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

*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}