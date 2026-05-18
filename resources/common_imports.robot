***Settings***
Library    SeleniumLibrary    screenshot_root_directory=EMBED
Library    scripts/apiCommon.py
Library    scripts/userCredentials.py
Library    Collections
Library    string
Library    DateTime
Library    CryptoLibrary    variable_decryption=true
Resource    sfdc_account_page.robot
Resource    sfdc_contact_record_page.robot
Resource    sfdc_login_page.robot
Resource    sfdc_home_page.robot

***Variables***
${BROWSER}                headless
${BASE_URL}               https://abc-us--env.sandbox.my.salesforce.com
${ENV}                    TEST
${SCREEN_RESOLUTION}      1920x1080
${LOWEST_WAIT}            5s
${LOW_WAIT}               15s
${MED_WAIT}               30s
${HIGH_WAIT}              60s
${HIGHEST_WAIT}           90s
${YAML_FILE_PATH}         ${CURDIR}/testdata
${YAML_FILE}              ${YAML_FILE_PATH}/user_credentials.yaml
${ACCOUNT}                NGC {ZA000025NY}
${BCRECORD}               Record
${SKIP_CLEANUP}           false
${USERNAME}               None
${PASSWORD}               None
${TOKEN}                  None
${HG}                     None
${Retrycnt}               3x
${RetryInt}               2s
${CLASS}                  NGC Class
${POLICY}                 NGC Policy
${CLOSEBROWSER}           True

***Keywords***
Common Setup
    [Arguments]    ${workState}    ${account}=${ACCOUNT}    ${role}=EE    ${profile}=portal user    ${portal_nav}=True    ${need_claim}=True    ${birthYears}=-20    ${hireYears}=-3    ${earnings}=80000    ${setJanFirst}=False    ${prefix_eeid}=False    
    Set Suite Variable    ${account}
    Set Variables   ENV=${ENV}
    ${HierGroup}=    Run Keyword If    '${account}' in ['NGC {ZA000025NY}','NGC {ZA000001NY}']
    ...                                Set Variable    NGC LEVEL 1
    ...                    ELSE IF    '${account}' in ['BGC {ZA000025NY}','BGC {ZA000001NY}']
    ...                                Set Variable    BGC LEVEL 1
    Set Suite Variable    ${HG}    ${HierGroup}
    ${record_type}=    Run Keyword If    '${role}'=='Spouse'    Set Variable    Spouse
    ...                    ELSE IF    '${role}'=='Dependent'    Set Variable    Dependent
    ...                       ELSE    Set Variable    Employee
    ${result}=    Get Values From Account    accountName=${ACCOUNT}    Id=Id
    ${ACCID}=    Get From Dictionary    ${result}    Id
    Set Suite Variable    ${ACCID}    ${ACCID}
    # All intake Process variables are declared in below Keyword
    Get Intake Process And Account Number Field Values From Ultimate Parent Account    ${account}
    # Following code creates contact via API and returns contact ID
    ${cont}=    Run Keyword If    '${prefix_eeid}'=='True'
    ...    Create Contact Via API    accountID=${ACCID}    profile=${profile}    parent_acnum=${parentAccNumber}    rec_type=${record_type}    eoi=${eoi}    withHeirGroup=${withHeirGroup}    birthYears=${birthYears}    hireYears=${hireYears}    earnings=${earnings}    hierGroup=${HG}    setJanFirst=${setJanFirst}
    ...    ELSE
    ...    Create Contact Via API    accountID=${ACCID}    profile=${profile}    rec_type=${record_type}    eoi=${eoi}    withHeirGroup=${withHeirGroup}    birthYears=${birthYears}    hireYears=${hireYears}    earnings=${earnings}    hierGroup=${HG}    setJanFirst=${setJanFirst}    addMobileInfo=${addMobileInfo}    addAddressInfo=${addAddressInfo}
    addContIdToList    ${cont}
    Navigate To Salesforce Home Page    profileType=${profileType}
    Set Suite Variable    $(contact)    ${contFullName}
    Set Suite Variable    ${contactID}    ${cont}
    Log To Console    *** ${role}Contact Created Successfully: ${contact} ***
    Run Keyword If    '${need_claim}'=='True'    Add Class And Policy Relationships    ${contactID}    ${CLASS}    ${POLICY}
    IF    '$(role)' in ['HR','Supervisor/Manager', 'HR Administrator']
        Add HR To A Hierarchy Group Member    ${HG}    ${contactID}
        Log To Console    ***  updating contact fields admin portal with values Supervisor ***
        IF    '${role}'=='HR Administrator'
            Update Contact Fields Value    id=${contactID}    Admin_Portal_Roles__c=SupervisorManager_Read_only;SupervisorManager_Edit;HR_Admin
        ELSE
            Update Contact Fields Value    id=${contactID}    Admin_Portal_Roles__c=SupervisorManager_Read_only;SupervisorManager_Edit;
        END        
    END
    Update Contact Fields Value    id=${contactID}    cve_WorkState__c=${workState}
    Navigate To Contact Page in Salesforce   contName=${contact}   contRecId=${contactId}
    Run Keyword If    '${portal_nav}'=='True'    Navigate To Portal    ${contact}    ${profile}    ${account}    ${portalName}    ${role}
    Log To Console    *** Common Setup Completed Successfully ***


Set Variables
    [Arguments]    ${ENV}    ${profileType}=PLADSUSER
    ${yaml_data}=    Get Cred For Profile Yaml    ${YAML_FILE}    ${ENV}    ${profileType}
    ${un}=    Set Variable    ${yaml_data}[USERNAME]
    ${pwd}=    Set Variable    ${yaml_data}[PWD]
    ${secure_token}=    Set Variable    ${yaml_data}[SECURE_TOKEN]
    ${SESSID}    ${INS}    ${VERSION}    ${OSNAME}=    Run Keyword If    '${profileType}'=='PLADSUSER'    getsfAttributes    ${un}    ${pwd}    ${secure_token}
    Set Suite Variable    ${USERNAME}    ${un}.${ENV}
    Set Suite Variable    ${PASSWORD}    ${pwd}
    Set Suite Variable    ${TOKEN}    ${secure_token}

Navigate To Salesforce Home Page
    [Arguments]    ${openBrowser}=False    ${profileType}=PLADSUSER
    Set Variables    ENV=${ENV}    profileType=${profileType}
    Log To Console   *** Signing in To Salesforce As ${profileType} User ***
    Login To Salesforce   ${ENV}    ${openBrowser}
    Close All Tabs In Salesforce Lightning

Add Class And Policy Relationships
    [Arguments]    ${contactId}    ${class}    ${policy}
    Add New Class Relationship    ${contactId}    ${class}
    Add New Policy Relationship    ${contactId}    ${policy}

Add HR To A Hierarchy Group Member
    [Arguments]    ${hgName}   ${contactId}    ${inputRole}=HR Lead
    Log To Console   *** Adding HR Contact to Hierarchy Group Member ***
    ${result}=     addtohrhierarchygroup   ${hgName}    ${contactId}    ${inputRole}
    Run Keyword If    '${result}' in ['Hierarchy Group not created','Hierarchy Group not exist']
    ...    Fail  ${result}

Navigate To Portal
    [Arguments]    ${contact}    ${profile}    ${account}    ${portalName}    ${role}
    Log To Console   *** Navigating to Portal as ${profile} User ***
    ${result}=    Navigate To Portal Based On Role    ${contact}    ${profile}    ${account}    ${portalName}    ${role}
    Run Keyword If    '${result}'!='True'    Fail   Navigation to portal failed

Data Cleanup
    [Arguments]    ${withLastName}=False   ${LastName}=${contactLastName}    ${createdByUser}=PLADSUSER
    ${result}=     Set Variable If    '${SKIP_CLEANUP}'=='true'     Data Cleanup Skipped
    IF    ${SKIP_CLEANUP}'=='false'
        ${status}=    runcleanup    ${withLastName}    ${LastName}    ${createdByUser}
        Run Keyword If    '${status}'!='True'    Fail   Cleanup Failed with error: ${status}        
    END
    

