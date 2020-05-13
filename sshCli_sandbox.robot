*** Settings ***
Documentation          This example demonstrates executing a command on a remote machine
...                    and getting its output.
...
...                    Notice how connections are handled as part of the suite setup and
...                    teardown. This saves some time when executing several test cases.

Library                SSHLibrary
Suite Setup            Open Connection And Log In
Suite Teardown         Close All Connections
Resource        resource.robot
Resource            resource.robot

*** Test Cases ***
Execute Help
    [Tags]              Global
    [Documentation]    Execute Help command and report all help topics
    ${execute}=          Write              ps
    Set client configuration  prompt=#
    ${output}=         Read Until prompt
    Sleep                5
    should not be empty     ${output}

*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}
