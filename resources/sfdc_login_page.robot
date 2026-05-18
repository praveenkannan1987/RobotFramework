***Settings***
Resource    common_imports.robot

***Variables***
&{SFLP_LOCATORS}    username=username
...                 password=password
...                 login_Btn=Login
...                 loginError=//div[@class="Error"]
...                 identyPage=//h2[text()="verify your Identity"]
...                 skipPhone=//a[text()='I dont want to register my phone']

***Keywords***
Login To Salesforce
    [Arguments]    ${ENV}    ${openBrowser}=False
    ${BASE_URL}=     Replace String    ${BASE_URL}    env    ${ENV}
    Open Tab or Browser    ${BASE_URL}    ${openBrowser}
    ${result}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${SFLP_LOCATORS.identyPage}    timeout=${LOW_WAIT}
    Run Keyword If    '${result}'=='True'    Enter Credentials and login

Open Tab or Browser
    [Arguments]    ${testUrl}    ${openBrowser}=False
    Register Keyword To Run On Failure    NOTHING
    Run Keyword If    '${openBrowser}'=='False'    Run Keywords
        ${openTab}=     Run Keyword And Return Status    Execute JavaScript    window.open();
    Run Keyword If    '${openTab}'=='True' and '${openBrowser}'=='False'    Run Keywords
    ...    Switch Window    NEW
    ...    AND
    ...    Go To    ${testUrl}
    Set Screen Size
    Register Keyword To Run On Failure    Capture Page Screenshot

Set Screen Size
    ${windowSize}=    Split String    ${SCREEN_RESOLUTION}    x
    ${width}=    Get From List    ${windowSize}    0
    ${height}=   Get From List    ${windowSize}    1
    Set Window Size    ${width}    ${height}
    Log To Console    *** Screen Size :  ${width} x ${height} ***

Enter Credentials and login
    Wait Until Element Is Visible    ${SFLP_LOCATORS.username}    timeout=${LOW_WAIT}
    Input Text    ${SFLP_LOCATORS.username}    ${USERNAME}
    Input Text    ${SFLP_LOCATORS.password}    ${PASSWORD}
    Click Element    ${SFLP_LOCATORS.login_Btn}
    Salesforce Login Error Should not be Displayed
    Salesforce Identiy Verification Should not be Displayed
    Skip Salesforce Register You Phone Step
    Log To Console   *** Logged in to Salesforce Sucessfully ***

Salesforce Login Error Should not be Displayed
    wait Until Element Is Not Visible    ${SFLP_LOCATORS.loginError}    timeout=${LOW_WAIT}    error=Login Failed

Salesforce Identiy Verification Should not be Displayed
    wait Until Element Is Not Visible    ${SFLP_LOCATORS.identyPage}    timeout=${LOW_WAIT}    error=Enter Identity

Skip Salesforce Register You Phone Step
    ${result}=     Run Keyword And Return Status    Wait Until Element Is Visible    ${SFLP_LOCATORS.skipPhone}    timeout=${LOW_WAIT}
    IF    '${result}'=='True'
       Click Element    ${SFLP_LOCATORS.skipPhone} 
    END