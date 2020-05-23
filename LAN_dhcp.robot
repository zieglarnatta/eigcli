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
#LAN0 Bridge DHCP
LAN0 Bridge DHCP: Get into LAN DHCP & then back out to Global
    [Tags]                      Global  Config  bridge  LAN  DHCP_in_out
    [Documentation]             Execute the LAN DHCP & then back out to test exit and top commands
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    sleep                       1   #give the system 1 second to rest, seems to help decrease it from tripping on itself
    ${execute}=                 read
    should contain              ${execute}   (config-if-lan0)#
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${output}=                  read
    sleep                       1
    should contain              ${output}   (config-if-lan0-dhcp)#
    should not contain          ${output}   (global)#   (config-if-lan0)#
    #fire off top to get out to global
    ${exit}=                     write   top
    sleep                       1
    ${exit}=                     read
    sleep                       1
    should contain              ${exit}   (global)#
    should not contain          ${exit}   (config-if-lan0-dhcp)#  (config-if-lan0)#
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    sleep                       1
    ${exit}=                     write   exit
    sleep                       1
    ${exit}=                     write   exit
    sleep                       1
    ${exit}=                     read
    sleep                       1
    should contain              ${exit}   (global)#
    should not contain          ${exit}   (config-if-lan0-dhcp)#  (config-if-lan0)#

LAN0 Bridge DHCP: Disable DHCP
    [Tags]                      Global  Config  bridge  LAN  DHCP   DHCP_disable
    [Documentation]             Execute the disable & then check to ensure DHCP is diabled
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   disable     #fire off the disable message to diable the dhcp
    sleep                       1
    ${dhcp}=                     write   show   #show the disable
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${disable}=                 read    #read the result, should be DHCP should be disabled
    sleep                       1
    should not be empty         ${disable}
    should not contain          ${disable}   -ash: ntp: not found    -ash: show ntp: not found
    should contain              ${disable}   DHCP_Service=Disable
    ${exit}                     write  top  #reset the command line to global

LAN0 Bridge DHCP: Enable DHCP
    [Tags]                      Global  Config  bridge  LAN  DHCP   DHCP_enable
    [Documentation]             Execute the enable & then ensure that DHCP is enabled
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   enable     #fire off the enable message
    sleep                       1
    ${dhcp}=                     write   show   #show the enable
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${enable}=                 read    #read the result, should be DHCP should be enabled
    sleep                       1
    should not be empty         ${enable}
    should not contain          ${enable}   -ash: ntp: not found    -ash: show ntp: not found
    should contain              ${enable}   DHCP_Service=Enable
    ${exit}                     write  top  #reset the command line to global

LAN0 Bridge DHCP: Set DHCP domain name
    [Tags]                      Global  Config  bridge  LAN  DHCP   DHCP_domain
    [Documentation]             Execute the domain & then check that domain name is showing
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   domain superfly.com     #fire off the domain message to set dhcp domain URL
    sleep                       1
    ${dhcp}=                     write   show   #show the domain and other results
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${domain}=                 read    #read the result, should be superfly.com as domain
    sleep                       1
    should not be empty         ${domain}
    should not contain          ${domain}   -ash: ntp: not found    -ash: show ntp: not found
    should contain              ${domain}   Domain=superfly.com
    ${exit}                     write  top  #reset the command line to global

LAN0 Bridge DHCP: Set DNS
    [Tags]                      Global  Config  bridge  LAN  DHCP   DHCP_dns
    [Documentation]             Execute the dns & then ensure dns is showing
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   dns 8.8.4.4     #fire off the dns command
    sleep                       1
    ${dhcp}=                     write   show   #show the dns and other results
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${dns}=                 read    #read the result, should be 8.8.4.4 as the dns ip address
    sleep                       1
    should not be empty         ${dns}
    should not contain          ${dns}   -ash: ntp: not found    -ash: show ntp: not found
    should contain              ${dns}   DNS_SERVER=8.8.4.4
    ${exit}                     write  top  #reset the command line to global

LAN0 Bridge DHCP: Set WINS server
    [Tags]                      Global  Config  bridge  LAN  DHCP   DHCP_wins
    [Documentation]             Execute the wins & then ensure wins is showing
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   wins 10.0.0.1     #fire off the wins to set dhcp wins ip address
    sleep                       1
    ${dhcp}=                     write   show   #show the wins and other results
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${wins}=                 read    #read the result, should be 10.0.0.1 as the dhcp wins server
    sleep                       1
    should not be empty         ${wins}
    should not contain          ${wins}   -ash: ntp: not found    -ash: show ntp: not found
    should contain              ${wins}   WINS_SERVER=10.0.0.1
    ${exit}                     write  top  #reset the command line to global

LAN0 Bridge DHCP: ip Assign show
    [Tags]                      Global  Config  bridge  LAN  DHCP   DHCP_ip_assign_show
    [Documentation]             Execute the ip assign show & ensure that it is blank since nothing has been assigned for now. One more will be done once we assign a mac address to the ip
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   ip assign show     #fire off the ip assign show command
    sleep                       1
    ${dhcp}=                     write   show   #show the dns and other results
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${ipassignshow}=                 read    #read the result, should be empty since there is no assigned mac + ip for now
    sleep                       1
    should not be empty             ${ipassignshow}
    should not contain          ${ipassignshow}   MAC   IP Address     -ash: ntp: not found    -ash: show ntp: not found
    ${exit}                     write  top  #reset the command line to global

LAN0 Bridge DHCP: ip Assign add
    [Tags]                      Global  Config  bridge  LAN  DHCP   DHCP_ip_assign_add
    [Documentation]             Execute the ip assign add & ensure that it is not blank
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   ip assign add E8:B3:1F:0C:6D:19 192.168.0.4     #fire off the ip assign add to set one up
    sleep                       1
    ${dhcp}=                     write   show   #show the dns and other results
    sleep                       1
    #need to consider the "apply" command to make it permanent & how to reset it
    ${ipassignadd}=                 read    #read the result, should be empty since there is no assigned mac + ip for now
    sleep                       1
    should not be empty         ${ipassignadd}
    should not contain          ${ipassignadd}   -ash: ntp: not found    -ash: show ntp: not found
    should contain              ${ipassignadd}  MAC   IP Address    E8:B3:1F:0C:6D:19   192.168.0.4
    ${exit}                     write  top  #reset the command line to global

LAN0 Bridge DHCP: ip Assign delete
    [Tags]                      Global  Config  bridge  LAN  DHCP   DHCP_ip_assign_del
    [Documentation]             Execute the ip assign del & ensure that it deletes
    ${execute}=                 write   top    #reset it to ensure we start form global level
    ${execute}=                 write   configure   #system config level
    ${execute}=                 write   interface bridge lan0   #bridge lan0 level
    ${execute}=                 write   dhcp   #dhcp level
    sleep                       1
    ${execute}=                 write   ip assign add E8:B3:1F:0C:6D:19 192.168.0.4
    sleep                       1
    ${execute}=                 write   ip assign add E8:B3:1F:0C:6D:20 192.168.0.5     #fire off the ip assign add to set 1st one up
    sleep                       1
    ${execute}=                 write   ip assign add E8:B3:1A:0C:6D:21 192.168.0.6     #fire off the ip assign add to set 2nd one up
    sleep                       2
    ${execute}=                 write   ip assign del 192.168.0.4     #fire off the ip assign del via ip assignment
    sleep                       2
    ${execute}=                 write   ip assign del E8:B3:1A:0C:6D:21     #fire off the ip assign del via mac assignment
    sleep                       2
    ${dhcp}=                     write   ip assign show   #show the dns and other results
    sleep                       2
    #need to consider the "apply" command to make it permanent & how to reset it
    set client configuration  prompt=#
    ${ipassignadd}=         read until prompt      #read the result, should not be empty since there is one last device
    #${ipassignadd}=                 read
    sleep                       1
    should not be empty         ${ipassignadd}
    should not contain          ${ipassignadd}   E8:B3:1F:0C:6D:19   192.168.0.4    -ash: ntp: not found    -ash: show ntp: not found
    should not contain          ${dhcp}   E8:B3:1A:0C:6D:21   192.168.0.6    MAC   IP Address
    should contain              ${ipassignadd}  E8:B3:1F:0C:6D:20   192.168.0.5
    ${exit}                     write  show
    ${exit}                     write  read
    ${exit}                     write  top  #reset the command line to global


*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}

#Open HTTP server on port 7272
#    Launch server       ${server}