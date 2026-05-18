***Settings***
Resource    common_imports.robot
Suite Teardown    Data Cleanup

***Variables***
${STDRecordType}   STD
${leavereason}     child
${futuredays}      15
${start}           -15
${end}             15

***Test Cases***
Verification of Payment Summary for STD Integrated Insured
    [Tags]    TM-2347    qa-risk-medium    qa-regression
    Test setup for std integrated    ${leavereason}    NGCclass    NGCpolicy

***Keywords***
Test setup for std integrated
    [Arguments]    ${reason}    ${class}    ${policy}
    Common Setup    workState=NY    account=NGC {ZA000001NY}    portal_nav=False    need_claim=False    profile=PLADSUSER    earnings=100000
    Add Class And Policy Relationships    contactId=${contactID}    class=${class}    policy=${policy}
    # Create Continuous New Disability And Absence Intake Claim class
    # wait Until Keyword Succeeds    5x    5s    Case Subject Should Contain    Integrated Claim
    # Navigate To Benefit Claim Page
    # Approve BC Claim Record    caseNumber=${portalCaseNumber}    future_days=${future_days}