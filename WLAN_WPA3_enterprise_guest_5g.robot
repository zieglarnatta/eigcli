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
#WLAN Guest 5g WPA3 enterprise
WLAN Guest 5g: Enter wpa3_enterprise
    [Tags]                      Config  interface_wifi_guest_5g  interface_wifi_guest_5g_wpa3_enterprise_enter
    [Documentation]             Fire off the interface wifi guest 5g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi guest 5g -> seecurity wpa3_enterprise
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-5g-wpa3-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-5g)#
    ${exit}=                  write   top


WLAN 5g: Set SSID for wpa3_enterprise
    [Tags]                      Config  interface_wifi_gust_5g     interface_wifi_guest_5g_wpa3_enterprise_ssid
    [Documentation]             Fire off the ssid  and then verify it's reflected
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                 write   ssid Smurfs
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}   SSID=Smurfs
    should not contain          ${output}   (config)#   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN Guest 5g WPA3 enterprise: SSID Hide enabled
    [Tags]                      Config  interface_wifi_gust_5g  interface_wifi_guest_5g_wpa3_enterprise_ssid_hide
    [Documentation]             Fire off the disable and check that wifi guest 5g is SSID is hidden disabled
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  ssid hide
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should contain              ${output}  HIDE_SSID=Enable
    should not contain          ${output}  No match found   Syntax error: Illegal parameter   (global)#   (config-if-wlan-5g)#
    ${exit}=                  write   top

WLAN Guest 5g WPA3 enterprise: SSID broadcast
    [Tags]                      Config  interface_wifi_gust_5g  interface_wifi_guest_5g_wpa3_enterprise_ssid_broadcast
    [Documentation]             Fire off the bcast and check that wifi guest 5g is SSID is now broadcasting
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  ssid bcast
    sleep                       1
    ${output}=                 write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  HIDE_SSID=Disable
    ${exit}=                  write   top

WLAN Guest 5g WPA3 enterprise: Server IP
    [Tags]                      Config  interface_wifi_gust_5g  interface_wifi_guest_5g_wpa3_enterprise_server
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  server 192.168.0.253
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  SERVER_IP=192.168.0.253
    ${exit}=                  write   top

WLAN Guest 5g WPA3 enterprise: Port forwarding
    [Tags]                      Config  interface_wifi_gust_5g  interface_wifi_guest_5g_wpa3_enterprise_port
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  port 1809
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  PORT_FORWARD=1809
    ${exit}=                  write   top

WLAN Guest 5g WPA3 enterprise: Connection secret
    [Tags]                      Config  interface_wifi_gust_5g  interface_wifi_guest_5g_wpa3_enterprise_secret
    [Documentation]             Fire off the secret and check that secret is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  secret Gargamel321
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  CONNECTION_SECRET=Gargamel321
    ${exit}=                  write   top

WLAN Guest 5g WPA3 enterprise: maxclient
    [Tags]                      Config  interface_wifi_gust_5g  interface_wifi_guest_5g_wpa3_enterprise_maxclient
    [Documentation]             Fire off the maclient and check that max clients is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  maxclient 118
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter  (global)#   (config-if-wlan-5g)#
    should contain              ${output}  MAX_CLIENTS=118
    ${exit}=                  write   top

WLAN Guest 5g WPA3 enterprise: Rekey key rotation interval
    [Tags]                      Config  interface_wifi_gust_5g  interface_wifi_guest_5g_wpa3_enterprise_rekey
    [Documentation]             Fire off the password and check that password is updated
    ${output}=                  write   top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 5g     #to get into Global Connfiguration -> System configuration -> Wifi Guest 5g
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    #lower limit 600 test
    ${output}=                  write  rekey 400
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  rekey must between 600 - 86400
    #upper limit 86400 test
    ${output}=                  write  rekey 90000
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  rekey must between 600 - 86400
    #happy path 3596
    ${output}=                  write  rekey 3580
    sleep                       1
    ${output}=                  write   show
    sleep                       1
    ${output}=                  read
    should not be empty         ${output}
    should not contain          ${output}  No match found   Syntax error: Illegal parameter     (global)#   (config-if-wlan-5g)#
    should contain              ${output}  KEY_ROTATION_INTERVAL=3580s
    ${exit}=                  write   top

#exit from WLAN wpa3_enterprise 5g
Exit from WLAN 5g wpa3_enterprise
    [Tags]                      Config  interface_wifi_gust_5g     interface_wifi_guest_5g_wpa3_enterprise_exit
    [Documentation]            Exit the WLAN 5g Configuration Mode via "top" command and land at Global configuration level
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