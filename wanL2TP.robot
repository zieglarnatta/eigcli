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
Enter L2TP and then back out to Global
    [Tags]                      Config       WAN     wan0    conn_l2tp  conn_l2tp_in_out    l2tp
    [Documentation]             Fire off the conn l2tp and then back out via top and then back in and back out via 3 exits
    #configure -> interface ethernet wan0 -> conn l2tp
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    #sleep                       1
    ${output}=                 write   conn l2tp
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#
    #use top to go all the way back into Global Config
    ${output}=                  write   top
    #sleep                       1
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (global)#
    should not be empty         ${output}
    should not contain          ${output}   (config-if-wan0)#   (config)#   (config-if-wan0-l2tp)#
    #use 3 exits to get back to global
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    sleep                       1
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    sleep                       1
    ${output}=                 write   conn l2tp
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
    should not contain          ${output}   (config-if-wan0)#   (config)#   (config-if-wan0-l2tp)#

Execute conn l2tp to Enter l2tp
    [Tags]                      Config       WAN     wan0    conn_l2tp
    [Documentation]             Fire off the conn l2tp and then verify it's in l2tp
    #configure -> interface ethernet wan0 -> conn l2tp
    ${output}=                 write   configure     #to get into Global Connfiguration -> System configuration
    #sleep                       1
    ${output}=                 write   interface ethernet wan0     #to get into Global Connfiguration -> System configuration -> Ethernet Wan0
    #sleep                       1
    ${output}=                 write   conn l2tp
    set client configuration  prompt=#
    ${output}=         read until prompt
    should contain              ${output}   (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter mtu 1432   #has problems not showing
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_mtu
    [Documentation]             Fire off the conn l2tp and then set the mtu
    ${output}=                  write  mtu 1432
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   MTU=1432    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter DNS
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_dns
    [Documentation]             Fire off the conn l2tp and then set the dns
    ${output}=                  write  dns 192.168.0.205
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   DNS_SERVER1=192.168.0.205    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter l2tp IP
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_ip
    [Documentation]             Fire off the ip and then set the ip
    ${output}=                  write  ip 192.168.0.206
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   IP_ADDR=192.168.0.206    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter netmask   #has issues, not working, not showing
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_netmask
    [Documentation]             Fire off the netmask and then set the netmask
    ${output}=                  write  netmask 255.255.0.0
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   NETMASK=255.255.0.0    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter gateway   #has issues, not working, not showing
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_gateway
    [Documentation]             Fire off the netmask and then set the gateway
    ${output}=                  write  gateway 255.255.0.0
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   GATEWAY=255.255.0.0    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter username   #has problems not showing
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_username
    [Documentation]             Fire off the username and then set the username
    ${output}=                  write  username ziegler_natta
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   USER_NAME=ziegler_natta    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter password   #has problems not showing
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_password
    [Documentation]             Fire off the password and then set the password
    ${output}=                  write  password reduxProcessChemistry
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   PASSWORD=reduxProcessChemistry    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter vpn   #has problems not showing
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_vpn
    [Documentation]             Fire off the vpn and then set the vpn
    ${output}=                  write  vpn macaffee.com
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   VPN_SERVER=macaffee.com    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter hostname
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_hostname
    [Documentation]             Fire off the hostname and then set the hostname
    ${output}=                  write  host yeehaw3
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   Hostname=yeehaw3    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter default route: enable  #has problems not enabled
    [Tags]                      Config       WAN     wan0    conn_l2tp  l2tp_defaultroute
    [Documentation]             Fire off the default route and then set the default route
    ${output}=                  write  defaultroute enable
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   DEFAULT_ROUTE=enable    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

Enter options   #has problems, snow showing
    [Tags]                      Config       WAN     wan0    conn_pptp  pptp_options
    [Documentation]             Fire off the options and then set the options as ttyname
    ${output}=                  write  options ttyname
    sleep                       1
    ${output}=                  write  show
    sleep                       1
    #set client configuration    prompt=#
    ${output}=                  read    #until prompt
    should contain              ${output}   ADDITIONAL_PPPD_OPTIONS=ttyname    (config-if-wan0-l2tp)#
    should not contain          ${output}   (config-if-wan0)#   (config)#

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
#    should not contain          ${output}   (global)#   (config-if-wan0)#   (config)#   (config-if-wan0-l2tp)#
#    #double ceck by firing off a "show" command and get back error as proof you're logged out
#    ${output}=                 write   show
#    ${output}=                  read
#    sleep                       1
#    should contain              ${output}   OSError: Socket is closed
#    should not be empty             ${output}
#    should not contain          ${output}   (global)#   (config-if-wan0)#   (config)#   (config-if-wan0-l2tp)#

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