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
#WLAN WPA2 Guest 2.4g
WLAN WPA2 Guest 2.4g: wpa2 personal
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_2_4g_wpa2_enter
    [Documentation]             Fire off the interface wifi 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi 2.4g -> seecurity wpa2
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi guest 2.4g
    ${output}=                  write  security wpa2
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa2)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#
    ${exit}                     write  top


WLAN WPA2 Guest 2.4g: Set SSID for wpa2 Personal WLAN Guest 2.4g
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_2_4g_wpa2_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi guest 2.4g
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                 write   ssid Wario_Brothers
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Wario_Brothers
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#

WLAN WPA2 Guest 2.4g: SSID Hide enabled
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_2_4g_wpa2_ssid_hide
    [Documentation]             Fire off the disable and check that wifi 2.4g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi guest 2.4g
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-2.4g)#

WLAN WPA2 Guest 2.4g: SSID broadcast
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_2_4g_wpa2_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi 2.4g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi guest 2.4g
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  HIDE_SSID=Disable

WLAN WPA2 Guest 2.4g: Password
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_2_4g_wpa2_password
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi guest 2.4g
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  password PrincessPeach
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PASSWORD=PrincessPeach

WLAN WPA2 Guest 2.4g: PMF protected Management Frames
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_2_4g_wpa2_pmf
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi guest 2.4g
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  pmf required
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  PROTECTED_MANAGEMENT_FRAMES=Required

WLAN WPA2 Guest 2.4g: maxclient
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_2_4g_wpa2_maxclient
    [Documentation]             Fire off the maclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi guest 2.4g
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  maxclient 120
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  MAX_CLIENTS=120

WLAN WPA2 Guest 2.4g: Rekey key rotation interval
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_2_4g_wpa2_rekey
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Wifi guest 2.4g
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  rekey 3599
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  Syntax error: Illegal parameter  (config)#   (global)#   (config-if-wlan-2.4g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3599s

#exit from WLAN WPA2 Guest 2.4g
Exit from WLAN Guest 2.4g wpa2
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_2_4g_wpa2_exit
    [Documentation]            Exit the WLAN Guest 2.4g Configuration Mode via "top" command and land at Global vonfiguration level
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