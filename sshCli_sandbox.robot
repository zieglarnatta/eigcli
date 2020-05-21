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
Execute conn pptp to Enter PPTP
    [Tags]
    [Documentation]             Fire off the conn pptp and then verify it's in wifi
    #configure -> interface ethernet wan0 -> conn pptp
   ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    #sleep                       1
    ${output}=                  write  security wpa
    sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wlan-2.4g-wpa)#
    should not contain          ${output}   (global)#   (config)#

Set SSID for WPA Personal WLAN 2.4g
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    #configure -> interface wifi 2.4g -> conn
    ${output}=                 write   ssid Super_Mario_Brothers
    #sleep                       1
    ${output}=                 write   show
    #sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   SSID=Super_Mario_Brothers
    should not contain          ${output}   (config)#   (global)#

*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}
