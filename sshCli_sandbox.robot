*** Settings ***
Documentation          This example demonstrates executing a command on a remote machine
...                    and getting its output.
...
...                    Notice how connections are handled as part of the suite setup and
...                    teardown. This saves some time when executing several test cases.

Library                SSHLibrary
Suite Setup            Open Connection And Log In
Suite Teardown         Close All Connections
Resource            resource.robot

*** Test Cases ***
Execute configure
    [Tags]              Configure
    [Documentation]     Execute the show iptables & return all of the processes
    ${execute}=          write              configure
    set client configuration  prompt=#
    ${output}=         read until prompt
    should not be empty     ${output}
    should not contain   ${output}           -ash: help: not found
    should contain  ${output}   (configure) #

*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}
