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
Enter PPTP and then back out to Global
    [Tags]                      Config       WAN     wan0    conn_pptp  conn_pptp_in_out    pptp
    [Documentation]             Fire off the conn pptp and then back out via top and then back in and back out via 3 exits
    #configure -> interface ethernet wan0 -> conn pptp
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    #sleep                       1
    ${output}=                 write   conn pptp
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    #use top to go all the way back into Global Config
    ${output}=                  write   top
    #sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config-if-wan0)#   (config)#   (config-if-wan0-pptp)#
    #use 3 exits to get back to global
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    sleep                       1
    ${output}=                 write   conn pptp
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    ${output}=                 write   exit
    sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config-if-wan0)#   (config)#   (config-if-wan0-pptp)#

Execute conn pptp to Enter PPTP
    [Tags]                      Config       WAN     wan0    conn_pptp
    [Documentation]             Fire off the conn pptp and then verify it's in PPTP
    #configure -> interface ethernet wan0 -> conn pptp
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    #sleep                       1
    ${output}=                 write   conn pptp
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter mtu 1433   #has problems not showing
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_mtu
    [Documentation]             Fire off the conn pptp and then set the mtu
    ${output}=                  write  mtu 1433
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   MTU=1433    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter DNS
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_dns
    [Documentation]             Fire off the conn pptp and then set the dns
    ${output}=                  write  dns 8.8.8.8
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   DNS_SERVER1=8.8.8.8    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter PPTP IP
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_ip
    [Documentation]             Fire off the ip and then set the ip
    ${output}=                  write  ip 192.168.0.204
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   IP_ADDR=192.168.0.204    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter netmask   #has issues, not working, not showing
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_netmask
    [Documentation]             Fire off the netmask and then set the netmask
    ${output}=                  write  netmask 255.255.0.0
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   NETMASK=255.255.0.0    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter gateway   #has issues, not working, not showing
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_gateway
    [Documentation]             Fire off the netmask and then set the gateway
    ${output}=                  write  gateway 255.255.0.0
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   GATEWAY=255.255.0.0    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter username   #has problems not showing
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_username
    [Documentation]             Fire off the username and then set the username
    ${output}=                  write  username paul_dirac
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   USER_NAME=paul_dirac    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter password   #has problems not showing
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_password
    [Documentation]             Fire off the password and then set the password
    ${output}=                  write  password futurePurplePeopleEater
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   PASSWORD=futurePurplePeopleEater    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter vpn   #has problems not showing
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_vpn
    [Documentation]             Fire off the vpn and then set the vpn
    ${output}=                  write  vpn symantec.com
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   VPN_SERVER=symantec.com    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter hostname
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_hostname
    [Documentation]             Fire off the hostname and then set the hostname
    ${output}=                  write  host yeehaw2
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   Hostname=yeehaw2    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter default route: enable  #has problems
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_defaultroute
    [Documentation]             Fire off the default route and then set the default route
    ${output}=                  write  defaultroute enable
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   DEFAULT_ROUTE=enable    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter Encrypt mppe128  #has problems, nothing shown
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_encrypt
    [Documentation]             Fire off the encrypt and then set the encrytion to mppe128
    ${output}=                  write  encrypt mppe128
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   encrypt    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter options   #has issues
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_options
    [Documentation]             Fire off the options and then set the options as ttyname
    ${output}=                  write  options ttyname
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   ADDITIONAL_PPPD_OPTIONS=ttyname    (config-if-wan0-pptp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

#exit from pptp
Exit from PPPoE
    [Tags]                     Config       WAN     wan0    conn_pptp     exit_pptp
    [Documentation]            Exit the WAN L2TP Configuration Mode via "top" command and land at Global vonfiguration level
    ${output}=                 write   top
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
#    should contain             ${output}   (config-if-wan0-dhcp)#

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
#    should not contain          ${output}   (global)#   (config-if-wan0)#   (config)#   (config-if-wan0-pptp)#
#    #double ceck by firing off a "show" command and get back error as proof you're logged out
#    ${output}=                 write   show
#    ${output}=                  read
#    sleep                       1
#    should contain              ${output}   OSError: Socket is closed
#    should not be empty             ${output}
#    should not contain          ${output}   (global)#   (config-if-wan0)#   (config)#   (config-if-wan0-pptp)#

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