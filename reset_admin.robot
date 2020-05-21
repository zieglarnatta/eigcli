*** Settings ***
Documentation     A test suite with a single Gherkin style test.
...
...               This test is functionally identical to the example in
...               valid_login.robot file.
Resource          resourceLocal.robot
Test Teardown     Close Browser
Documentation     Use this to set the CLI access and also set the admin password to admin

Suite Setup       Open Browser To Login Page
Suite Teardown    Close Browser
Test Setup        Go To Login Page
Resource          resourceLocal.robot


*** Test Cases ***
Valid Login
    Given browser is opened to login page
    When user "demo" logs in with password "mode"
    Then

*** Keywords ***
Browser is opened to login page
    Open browser to login page

User "${username}" logs in with password "${password}"
    Input username    ${USERNAME}
    Input password    ${FACTORY PASSWORD}
    Submit credentials
