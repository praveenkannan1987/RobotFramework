*** Settings ***
Resource    common_imports.robot


*** Variables ***
&{SF_LOCATORS}    tabsLightning=a[@title='Home']
...                 closeAlITabsTxt=//span[text()='Close all tabs']

*** Keywords ***
Close All Tabs In Salesforce Lightning
    ${tabs Visible}=    Run Keyword And Return Status    Wait Until Element Is Visible ${SF_LOCATORS.tabsLightning}    ${LOW_WAIT}
    Wait For Condition    return document.readyState == "complete"   timeout=30s
    IF    '${tabsVisible}'=='True'
        Press Keys    ${SF_LOCATORS.tabsLightning}    SHIFT+w
        ${closeAllTab}=    Run Keyword And Return Status    Wait Until Element Is Visible ${SF_LOCATORS.closeAlITabsTxt}    ${MED_WAIT}
        IF    '${closeAllTab}'=='True'
        ${closeAllButton}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${SF_LOCATORS.closeAllBtn}    ${MED_WAIT}
        Run Keyword If    '${closeAllButton}'=='True'    Click Element    ${SF_LOCATORS.closeAllBtn}
        END
    END