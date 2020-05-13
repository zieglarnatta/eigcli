*** Settings ***
Documentation          This example demonstrates executing a command on a remote machine
...                    and getting its output.
...
...                    Notice how connections are handled as part of the suite setup and
...                    teardown. This saves some time when executing several test cases.

Library                SSHLibrary
Suite Setup            Open Connection And Log In
Suite Teardown         Close All Connections
Resource          resource.robot
Resource            resourceLocal.robot

*** Test Cases ***
Execute Hello World Echo Command And Verify Output
    [Tags]              Hello_World
    [Documentation]    Execute Command can be used to run commands on the remote machine.
    ...                The keyword returns the standard output by default.
    ${output}=         Execute Command    echo Hello SSHLibrary!
    Should Be Equal    ${output}          Hello SSHLibrary!

Execute Help
    [Tags]              Global
    [Documentation]    Execute Help command and report all help topics
    ${execute}=          Write              help
    Set client configuration  prompt=#
    ${output}=         Read Until prompt
    Should Not Be Empty     ${output}
    Should Not Be Equal           ${output}           -ash: help: not found

Execute History 10 And Verify Output
    [Tags]              Global
    [Documentation]    Execute history 10 CLI and return the last 10
    ...                The keyword returns the standard output by default.
    Write               history 10
    Set client configuration  prompt=#
    ${output}=          Read Until  history


Execute Ping on 8.8.8.8
    [Tags]              Global
    [Documentation]    Execute ping on 8.8.8.8 and return the results
    ...                The keyword returns the standard output by default.
    Write               ping 8.8.8.8
    Sleep               5
    ${output}=          Read Until  0% packet loss

Executing AR Ping
    [Tags]              Global
    [Documentation]    Execute Ap Ping and report ping stats
    Write              ping 8.8.8.8 -I 172.16.23.166 repeat 3
    Set client configuration  prompt=#
    ${output}=         Read Until prompt

Execute Traceroute
    [Tags]              Global
    [Documentation]    Execute Traceroute and report traceroute stats
    ${execute}=          Write              traceroute 8.8.8.8 -s 172.16.23.166 -i eth1
    Set client configuration  prompt=#
    ${output}=         Read Until   traceroute: can't set multicast source interface
    Should Not Be Equal    ${output}    Usage: ping [OPTIONS] HOST
    Should Not Be Equal    ${output}    traceroute: can't set multicast source interface    #has issues

Execute ps Processes
    [Tags]              Global
    [Documentation]     Execute the ps & return all of the processes
    ${execute}=          Write              ps
    Set client configuration  prompt=#
    ${output}=         Read Until prompt
    Sleep                5
    should not be empty     ${output}

*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}
