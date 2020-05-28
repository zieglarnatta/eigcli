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
WLAN 2.4g: Enter disable
    [Tags]                      Config  WLAN    WLAN2_4g  interface_wifi_2_4g  interface_wifi_2_4g_disable
    [Documentation]             Fire off the disable and check that wifi 2.4g is disabled
    ${exit}                     write  top
Suite Teardown         Close All Connections
Suite Setup            Open Connection And Log In
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN 2.4g
    sleep                       1
    ${output}=                  write  disable
    sleep                       10
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    #sleep                       1
    should contain              ${output}  (config-if-wlan-2.4g)#
    should not contain          ${output}   (config)#   (global)#
    #need to incorporate a UI robot to check on this in the admin
    Open Browser To Login Page
    Input Username
    Input Password
    Click the Login
    Click on Status
    Click on wireless
    Click on 2.4g
    [Teardown]    Close Browser
    ${exit}                     write  top

Open browser UI sandbox
    [Tags]                      open_browser
    [Documentation]             Open the browser template
    #need to incorporate a UI robot to check on this in the admin
    Open Browser To Login Page
    Input Username
    Input Password
    Click the Login
    #look for the 2.4g page
    #Land on Askey Dashboard page
    Click on Status
    Click on wireless
    Click on 2.4g

*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}

#Open HTTP server on port 7272
#    Launch server       ${server}