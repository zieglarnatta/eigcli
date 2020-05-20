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
Execute "configure" and then "exit", then back to "configure" and use "top" to go back to global configuration
    [Tags]                      Global  System_Configuration   top     Global      configure_to_global
    [Documentation]             Execute the configure and then retreat back to global via top and one exit statement
    ${execute}=                 write   configure
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: configure: not found     (global)#
    should contain              ${output}   (config)#
    #use "exit" to go up by 1 level to Global Configuration
    ${execute}=                 write   exit
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: configure: not found     (config)#
    should contain              ${output}   (global)#
    #use "top" to go up to the basic level of Global Configuration
    ${execute}=                 write       top
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should not contain          ${output}   -ash: top: not found    (config)#
    should contain              ${output}   (global)#

#System config portion
Global ntp server configuration and show it (has problem matching with double space, also ntp updated on server 6 rather than 1)
    [Tags]                      System_Configuration    ntp     show_ntp
    [Documentation]             Execute the ntp & confirm ntp servers are updated & shown
    ${execute}=                 write   configure
    ${execute}=                 write   ntp server1 www.yahoo.com server2 www.google.com        loglevel=DEBUG
    ${output}=                  write   show ntp       loglevel=DEBUG
    #set client configuration   prompt=#
    #${output}=                 read until prompt        loglevel=DEBUG
    ${output}=                  read until      www.yahoo.com        loglevel=DEBUG
    should not be empty         ${output}
    should not contain          ${output}   -ash: ntp: not found    -ash: show ntp: not found
    should contain              ${output}   (config)#     www.yahoo.com
    should contain              ${output}   NTP Server1 www.yahoo.com
    ${exit}                     write  top
    ${exit}                     read
    should contain              ${exit}   (global)#

*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}