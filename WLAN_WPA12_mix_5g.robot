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
#WLAN WPA 12 mix personal 5g
WLAN 5g WPA12 mix personal: Enter wpa12_mix personal
    [Tags]                      Config  interface_wifi_5g  interface_wifi_5g_wpa12_mix_enter
    [Documentation]             Fire off the interface wifi 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 5g -> seecurity wpa12_mix
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-5g-wpa12-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    ${exit}=                    write top


WLAN 5g WPA12 mix personal: Set SSID for wpa12_mix Personal WLAN 5g
    [Tags]                      Config  interface_wifi_5g     interface_wifi_5g_wpa12_mix_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                 write   ssid Pikachu
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Pikachu
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                    write top

WLAN 5g WPA12 mix personal: SSID Hide enabled
    [Tags]                      Config  interface_wifi_5g  interface_wifi_5g_wpa12_mix_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 5g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                    write top

WLAN 5g WPA12 mix personal: SSID broadcast
    [Tags]                      Config  interface_wifi_5g  interface_wifi_5g_wpa12_mix_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 5g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                    write top

WLAN 5g WPA12 mix personal: Password
    [Tags]                      Config  interface_wifi_5g  interface_wifi_5g_wpa12_mix_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  password IchooseYou
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PASSWORD=IchooseYou
    ${exit}=                    write top

WLAN 5g WPA12 mix personal: maxclient
    [Tags]                      Config  interface_wifi_5g  interface_wifi_5g_wpa12_mix_maxclient
    [Documentation]             Fire off the maclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  maxclient 123
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  MAX_CLIENTS=123
    ${exit}=                    write top

WLAN 5g WPA12 mix personal: Rekey key rotation interval
    [Tags]                      Config  interface_wifi_5g  interface_wifi_5g_wpa12_mix_rekey
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  rekey 3596
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-5g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3596s
    ${exit}=                    write top

#exit from WLAN wpa12_mix 5g
Exit from WLAN 5g wpa12_mix personal
    [Tags]                      Config  interface_wifi_5g     interface_wifi_5g_wpa12_mix_exit
    [Documentation]            Exit the WLAN 5g Configuration Mode via "top" command and land at Global vonfiguration level
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi 5g     #to get into Global Connfiguration -> System configuration -> Wifi 5g
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                 write    top
    sleep                       1
    #will address the "apply" command separately because once it is applied then we have to do a factory "reset" to get rid of it
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    ${exit}=                    write top

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
#    should not contain          ${output}   (global)#   (config)#   (config-if-wlan-5g)#
#    #double ceck by firing off a "show" command and get back error as proof you're logged out
#    ${output}=                 write   show
#    ${output}=                  read
#    sleep                       1
#    should contain              ${output}   OSError: Socket is closed
#    should not be empty             ${output}
#    should not contain          ${output}   (global)#   (config)#   (config-if-wlan-5g)#

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