*** Settings ***
Documentation           Author: Roy Yap
...                     Created: May 1 2020
...                     Last Edited: Mar 16 2021

*** Variables ***
${HOST}                192.168.0.1   #10.0.0.9      #100.194.181.123 in case the local IP doesn't work
${USERNAME}            admin            #sysconsole
${PASSWORD}            admin            #specific to a given device look at the white sticker on EIG
${LOGIN URL}           http://${HOST}/
${FACTORY PASSWORD}            #specific to my device
#${BROWSER}             Firefox  #uncomment this to test via FF
${BROWSER}             headlessfirefox   #uncomment this to use headlessFF
#${BROWSER}             Chrome   #uncomment this to test via chrome
${DELAY}                0.5
${server}               ~/workspace/WebDemo/demoapp/server.py    #local python for AR round trip pings, make sure you have the WebDemo else obtain it from https://github.com/robotframework/WebDemo
${endserver}            exit()      #exit from python server


*** Keywords ***


Suite Setup
    Open Connection And Log In

Suite Teardown
    Close All Connections

Open Connection And Log In
   Open Connection              ${HOST}
   Login                        ${USERNAME}        ${PASSWORD}

Close All Connections
    Write                       logout

Open Browser To Login Page
    #Open Browser                ${LOGIN URL}    ${BROWSER}   #uncomment to use regular, choose only either headless else regular, not both
    Open Browser                ${LOGIN URL}    ${BROWSER}  add_argument("--headless");add_argument("--start-maximized")   #uncomment to use headless
    Maximize Browser Window
    Set Selenium Speed          ${DELAY}

Input Username
    Input Text                  loginName           ${USERNAME}

Input Password
    Input Text                  loginPWD            ${PASSWORD}

Input Factory Password
    Input Text                  loginPWD            ${FACTORY PASSWORD}

Click the Login
    Click Button                    login-submit

Land on Askey Dashboard page
    Wait until Element is visible           nav-fab
    Title should be                         first-menu-name    Dashboard

Click on System Settings
    wait until element is visible           goto_system
    Click element                           goto_system
    wait until element is visible           apply

Click on Password & Timezone
    #Click element                           xpath://*[@id="systemcfg"]/a/span
    wait until element is visible           loginName
    wait until element is visible           old_pwd
    wait until element is visible           sysPwd
    wait until element is visible           repeatPwd
    wait until element is visible           apply

Click on Old Password
    Clear Element Text                      old_pwd
    Input Text                              old_pwd         ${FACTORY PASSWORD}

Click on New Password
    Clear Element Text                      sysPwd
    Input Text                              sysPwd         ${PASSWORD}

Click on Confirm Password
    Clear Element Text                      repeatPwd
    Input Text                              repeatPwd         ${PASSWORD}

Click on Save Button
    click element                           apply

Click on Status
    Click element                       status_info

Click on wireless
    seleniumlibrary.click element       wireless

Click on 2.4g
    seleniumlibrary.click element       href2_4G

Click Expert
    wait until element is visible       reload_page_expert
    Click element                       xpath://*[@id="reload_page_expert"]/span

Click Services
    Click element                   goto_usb

Click CLI
    Click element                   tx_item10

Click No radio button
    Wait until element is visible   xpath://*[@id="collapse-0"]/div/div[1]/div/ul/li[2]/div/label
    Click element                   xpath://*[@id="collapse-0"]/div/div[1]/div/ul/li[2]/div/label

Click Yes radio button
    Wait until element is visible   xpath://*[@id="collapse-0"]/div/div[1]/div/ul/li[1]/div/label
    Click element                   xpath://*[@id="collapse-0"]/div/div[1]/div/ul/li[1]/div/label

#from reset admin
Open SSH
    Open Connection     ${HOST}

Send keygen
    write bare          ssh-keygen -R 10.0.0.9
    Open Connection     ${HOST}
    write               yes
    Login               ${USERNAME}        ${PASSWORD}
