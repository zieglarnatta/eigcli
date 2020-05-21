*** Settings ***
Documentation          This example demonstrates executing a command on a remote machine
...                    and getting its output.
...
...                    Notice how connections are handled as part of the suite setup and
...                    teardown. This saves some time when executing several test cases.

Library                SSHLibrary
Suite Setup            Open Connection And Log In
Suite Teardown         Close All Connections
#Suite Setup            Open Browser To Login Page
#Suite Teardown         Close Browser
#Test Setup             Go To Login Page
Resource            resourceLocal.robot

*** Test Cases ***
#WIP WPA3
Enter wpa3 personal
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_enter
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> seecurity wpa3
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-2.4g-wpa3)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    ${exit}=                    write   top

Set SSID for wpa3 Personal WLAN 2.4g
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_wpa3_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${exit}=                    write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                 write   ssid Luigi
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Luigi
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                    write   top

SSID Hide enabled
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 2.4g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#
    ${exit}=                  write   top

SSID broadcast
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 2.4g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

Password
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  password MaMaMiaHereIGoAgain
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PASSWORD=MaMaMiaHereIGoAgain
    ${exit}=                  write   top

maxclient
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_maxclient
    [Documentation]             Fire off the maclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  maxclient 122
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  MAX_CLIENTS=122
    ${exit}=                  write   top

Rekey key rotation interval
    [Tags]                      Config  interface_wifi_2_4g  interface_wifi_2_4g_wpa3_rekey
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi 2.4g
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  rekey 3597
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3597s
    ${exit}=                  write   top

#exit from WLAN wpa3 2.4g
Exit from WLAN 2.4g wpa3
    [Tags]                      Config  interface_wifi_2_4g     interface_wifi_2_4g_wpa3_exit
    [Documentation]            Exit the WLAN 2.4g Configuration Mode via "top" command and land at Global vonfiguration level
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#

#Execute template
#    [Tags]                      template
#    [Documentation]             Update , apply and then show -
#    ${output}=                 write   show
#    sleep                       1   loglevel=NONE
#    ${output}=                 write   apply
#    sleep                      1
#    ${output}=                 write   show
#    sleep                       1   loglevel=NONE
#    ${output}=                  read
#    should contain              ${output}   DNS
#    should not be empty         ${output}
#    should not contain          ${output}   ©
#    should not contain          ${output}   ®
#    should contain              ${output}   DNS
#    should contain             ${output}   (config-if-0-dhcp)#

#would be nice to do this via PhantomJS so that we can eliminate GUI rendering & flaky flow
#Execute factory reset router
#    [Tags]                      factory reset EIG
#    [Documentation]             Use robot framework & Chrome to reset the admin password


#Execute Logout
#    [Tags]                      logout
#    [Documentation]             send logout to exit from the SSH session
#    ${output}=                 write   logout
#    ${output}=                  read
#    sleep                       1
#    should contain              ${output}   Connection to 192.168.0.1 closed.
#    should be empty             ${output}
#    should not contain          ${output}   (global)#   (config)#   (config-if-wlan-2.4g)#
#    #double ceck by firing off a "show" command and get back error as proof you're logged out
#    ${output}=                 write   show
#    ${output}=                  read
#    sleep                       1
#    should contain              ${output}   OSError: Socket is closed
#    should not be empty             ${output}
#    should not contain          ${output}   (global)#   (config)#   (config-if-wlan-2.4g)#

#Execute reboot
#    [Tags]              Global     reboot
#    [Documentation]     Execute the reboot & return all of the processes
#    ${execute}=          write              reboot
#    set client configuration  prompt=#
#    ${output}=         read until prompt
#    should not be empty     ${output}

#Execute Restore
#    [Tags]              Global     restore
#    [Documentation]     Execute the restore & return all of the processes
#    ${execute}=          write              restore
#    set client configuration  prompt=#
#    ${output}=         read until prompt
#    should not be empty     ${output}

#   logout from global configuration CLI by sending "logout"

*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}

Browser is opened to login page
    Open browser to login page

User "${username}" logs in with password "${password}"
    Input username    ${USERNAME}
    Input password    ${FACTORY PASSWORD}
    Submit credentials