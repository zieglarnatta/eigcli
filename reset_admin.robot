*** Settings ***
Documentation       Author: Roy Yap
...                 Created: May 1 2020
...                 Use this to set the CLI access and also set the admin password to admin

Suite Setup         Open Browser To Login Page
Suite Teardown      Close Browser
#Test Setup        Go To Login Page
Library             SeleniumLibrary
Library             SSHLibrary
Library             Process
Resource          resourceLocal.robot


*** Test Cases ***

Admin logs in with factory password
    [Tags]                   factory_login
    Input username
    Input Factory Password
    Click the Login

Land on Askey EIG GUI
    [Tags]                   factory_login
    Click on System Settings
    Click on Password & Timezone
    Click on Old Password
    Click on New Password
    Click on Confirm Password
    Click on Save Button
    Sleep                   8

#paused for now since it is not working, may need ot build a python function for this one to tap into shell method
#SSH Keygen
#    [Tags]                  keygen
    #run process           /Users/ryap/workspace/WebDemo/eigcli/keygen.sh      yes     admin
    #start process           /workspace/WebDemo/eigcli/keygen.sh      yes     admin
#    Open SSH
#    run process           /Users/ryap/workspace/WebDemo/eigcli/keygen.sh      yes     admin
    #Send keygen