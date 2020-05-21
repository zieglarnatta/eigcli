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
#WLAN Guest 2.4g
WLAN Guest 2.4g: Enter  WLAN Guest 2.4g and then back out to Global
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_in_out
    [Documentation]             Fire off the interface wifi guest 2.4g and then back out via top and then back in and back out via 3 exits
    #configure -> interface wifi guest 2.4g -> conn
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    #sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config)#   (global)#
    #use top to go all the way back into Global Config
    ${output}=                  write   top
    #sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config)#   (config-if-wlan-guest-2.4g)#
    #use 3 exits to get back to global
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config)#   (config-if-wlan-guest-2.4g)#

WLAN Guest 2.4g: Enter  disable
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_disable
    [Documentation]             Fire off the disable and check that wifi 2.4g is disabled
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  disable
    sleep                       10
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    #sleep                       1
    should contain              ${output}  (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config)#   (global)#
    #need to incorporate a UI robot to check on this in the admin
    ${exit}                     write  top

WLAN Guest 2.4g: Enter  enable
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_enable
    [Documentation]             Fire off the enable and check that wifi 2.4g is enabled
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  enable
    sleep                       10
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    sleep                       1
    #should be empty             ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config)#   (global)#
    #need to incorporate a UI robot to check on this in the admin
    ${exit}                     write  top

#WLAN Guest 2.4g: Enter  all the security wpa and then back out
WLAN Guest 2.4g: Enter  security WPA and then back out
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa_in_out
    [Documentation]             Fire off the "security" for wpa - WPA Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-2.4g)#    (config-if-wlan-2.4g-wpa)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa)#     (config)#   (config-if-wlan-guest-2.4g)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa
    sleep                       1
    ${output}=                  write   exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-guest-2.4g-wpa)#  (config-if-wlan-2.4g-wpa)#     (config)#    (global)#

WLAN Guest 2.4g: Enter  security WPA2 and then back out
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa2_in_out
    [Documentation]             Fire off the "security" for wpa2 - WPA2 Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa2
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa2)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa2)#     (config)#   (config-if-wlan-guest-2.4g-wpa2)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa2
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa2)#     (config)#    (global)#

WLAN Guest 2.4g: Enter  security WPA3 and then back out
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa3_in_out
    [Documentation]             Fire off the "security" for wpa3 - WPA3 Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa3
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa3)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa3)#     (config)#   (config-if-wlan-guest-2.4g-wpa3)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa3
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-guest-2.4g-wpa3)#    (config-if-wlan-2.4g-wpa3)#     (config)#    (global)#

WLAN Guest 2.4g: Enter  security WPA12 Mix and then back out
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa12_mix_in_out
    [Documentation]             Fire off the "security" for wpa12_mix - WPA/WPA2 Mix Mode Personal and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa12_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa12-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#  (config-if-wlan-2.4g-wpa12-mix)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa12-mix)#     (config)#   (config-if-wlan-guest-2.4g-wpa12-mix)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa12_mix
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa12-mix)#    (config-if-wlan-2.4gx)#     (config)#    (global)#

WLAN Guest 2.4g: Enter  security WPA23 mix and then back out
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa23_mix_in_out
    [Documentation]             Fire off the "security" for wpa23_mix - WPA2/WPA3 Mix Mode Personal
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa23_mix
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa23-mix)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#  (config-if-wlan-2.4g-wpa23-mix)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa23-mix)#     (config)#   (config-if-wlan-guest-2.4g-wpa23-mix)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa23_mix
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa23-mix)#    (config-if-wlan-guest-2.4g-wpa23-mix)#     (config)#    (global)#

WLAN Guest 2.4g: Enter  security WPA2 WLAN Guest 2.4g: Enterprise and then back out
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa2_enterprise_in_out
    [Documentation]             Fire off the "security" for wpa2_enterprise - WPA2 WLAN Guest 2.4g: Enterprise and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa2_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa2-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#  (config-if-wlan-2.4g)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa2-ent)#     (config)#   (config-if-wlan-guest-2.4g)#    (config-if-wlan-guest-2.4g-wpa2-ent)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa2_enterprise
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa2-ent)#     (config-if-wlan-guest-2.4g-wpa2-ent)#     (config)#    (global)#

WLAN Guest 2.4g: Enter  security WPA3 WLAN Guest 2.4g: Enterprise and then back out
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa3_enterprise_in_out
    [Documentation]             Fire off the "security" for wpa3_enterprise - WPA3 WLAN Guest 2.4g: Enterprise and then back out
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa3-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#  (config-if-wlan-2.4g-wpa3-ent)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa3-ent)#     (config)#   (config-if-wlan-guest-2.4g)#    (config-if-wlan-guest-2.4g-wpa3-ent)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa3_enterprise
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-guest-2.4g-wpa3-ent)#     (config-if-wlan-2.4g-wpa3-ent)#     (config)#    (global)#

WLAN Guest 2.4g: Enter  security WPA12 mix WLAN Guest 2.4g: Enterprise and then back out
    [Tags]                      Config  interface_wifi_guest_2_4g  interface_wifi_guest_2_4g_security_wpa12_mix_enterprise_in_out
    [Documentation]             Fire off the "security" for wpa12_mix_enterprise - WPA/WPA2 Mix Mode WLAN Guest 2.4g: Enterprise
    ${exit}                     write  top
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> Ethernet 0
    sleep                       1
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g-wpa12-mix-ent)#
    should not contain          ${output}   (global)#     (config)#   (config-if-wlan-guest-2.4g)#  (config-if-wlan-2.4g-wpa12-mix-ent)#
    #use top to go all the way to global configuration
    ${output}=                  write  top
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (global)#
    should not contain          ${output}   (config-if-wlan-2.4g-wpa12-mix-ent)#     (config)#   (config-if-wlan-guest-2.4g)#   (config-if-wlan-guest-2.4g-wpa12-mix-ent)#
    #use one exit to go back to (config-if-wlan-guest-2.4g)#
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface wifi guest 2.4g     #to get into Global Connfiguration -> System configuration -> WLAN Guest 2.4g
    #sleep                       1
    ${output}=                  write  security wpa12_mix_enterprise
    sleep                       1
    ${output}=                  write  exit
    ${output}=                  read
    sleep                       1
    set client configuration    prompt=#
    ${output}=                  read until prompt
    should not be empty         ${output}
    should contain              ${output}   (config-if-wlan-guest-2.4g)#
    should not contain          ${output}   (config-if-wlan-guest-2.4g-wpa12-mix-ent)#    (config-if-wlan-2.4g-wpa12-mix-ent)#     (config)#    (global)#


#exit from WLAN 2.4g
Exit from WLAN 2.4g
    [Tags]                      Config  interface_wifi_guest_2_4g     interface_wifi_guest_2_4g_exit
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
#    should not contain          ${output}   (global)#   (config)#   (config-if-wlan-guest-2.4g)#
#    #double ceck by firing off a "show" command and get back error as proof you're logged out
#    ${output}=                 write   show
#    ${output}=                  read
#    sleep                       1
#    should contain              ${output}   OSError: Socket is closed
#    should not be empty             ${output}
#    should not contain          ${output}   (global)#   (config)#   (config-if-wlan-guest-2.4g)#

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