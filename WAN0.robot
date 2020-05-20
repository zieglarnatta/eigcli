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
WAN Configuration Wan0 Mode and back out via exit & top
    [Tags]                      WAN     wan0    wan_configuration
    [Documentation]             Enters the WAN Configuration Mode and retrest to global with top and then repeat but with two exits
    ${output}=                 write   configure
    #sleep                       1
    ${output}=                 write   interface ethernet wan0
    #sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}   -ash: ntp: not found   -ash: show ntp: not found
    should not contain          ${output}   (config)#   (global)#
    should contain              ${output}   (config-if-wan0)#
    #use top to get to global
    ${output}=                 write   top
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}   (config)#   (config-if-wan0)#
    should contain              ${output}   (global)#
    #use two exits to get back to global configuration
    ${output}=                 write   configure
    #sleep                       1
    ${output}=                 write   interface ethernet wan0
    #sleep                       1
    ${output}=                 write   exit     #to exit to system configuration level
    #sleep                       1
    ${output}=                 write   exit     #to exit to global configuration level
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}   (config)#   (config-if-wan0)#
    should contain              ${output}   (global)#
    ${exit}                     write  top
    ${exit}                     read
    should contain              ${exit}   (global)#

*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}