***Settings***
Resource    common_imports.robot
Library    SeleniumLibrary    screenshot_root_directory=EMBED
Library    String
Library    DateTime
Library    scripts/sfContactApi.py
Library    scripts/date_time.py
Library    scripts/apiCommon.py

*** Variables ***
${contactFirstName}    Robot
${contactLastName}     Automation
&{SFCR_Locators}      contactNameHeader=//a[text()='contact-name']

***Keywords***
Create Contact Via API
    [Arguments]    ${accountID}    ${parent_acnum}=None    ${profile}=Portal user    ${rec_type}=Employee    ${eoi}=False    ${withHeirGroup}=True    ${birthYears}=-20    ${hireYears}=-3    ${earnings}=80000    ${hierGroup}=None    ${setJanFirst}=False    ${addMobileInfo}=yes    ${addAddressInfo}=yes
    ${contact}=    Create Dictionary
    ${firstname}=    Generate First Name
    ${lastname}=    Generate Last Name
    ${mobilePhone}=    Generate Mobile Number
    ${ssn}=    Generate SSN
    ${id}=    Generate Employee ID
    Set Suite Variable    ${empId}    ${id}
    Set Suite Variable    ${empSSN}    ${ssn}
    Set Suite Variable    ${empFirstName}    ${firstname}
    Set Suite Variable    ${empLastName}    ${lastname}
    ${EE_type}=    Set Variable    01236000000F9rNAAS
    ${SP_type}=    Set Variable    0123600000OnkiJAAQ
    ${DE_type}=    Set Variable    01236000000nKiIAAQ
    ${name}=    Catenate    ${first_name}    ${last_name}
    Set Suite Variable    ${contFullName}    ${name}
    ${namestripped}=    Remove String    ${name}    ${SPACE}
    ${email}=    Set Variable    ${namestripped}@test.com
    ${accID}=    Set Variable    ${accountID}
    ${eoiDate}=    Generate A Date    apiFormat=True
    ${hireDate}=    Generate A Date    years=${hireYears}    apiFormat=True    setJanFirst=${setJanFirst}
    ${birthdate}=    Generate A Date    years=${birthYears}    apiFormat=True
    ${birthDatePortal}=    Generate A Date    years=${birthYears}    withMonthName=True    qdePortal=True
    ${eoiDate}=    Convert To String    ${eoiDate}
    ${birthdate}=    Convert To String    ${birthdate}
    ${birthDatePortal}=    Convert To String    ${birthDatePortal}
    ${hireDate}=    Convert To String    ${hireDate}
    Set Suite Variable    ${empBirthDate}    ${birthdate}
    Set Suite Variable    ${empBirthDatePortal}    ${birthDatePortal}
    Set Suite Variable    ${emailId}    ${email}
    Set Suite Variable    ${empHireDate}    ${hireDate}
    Set Suite Variable    ${empGender}    Female
    ${type}=    Run Keyword If    '${rec_type}'=='Spouse'    Set Variable    ${sp_type}
    ...    ELSE IF    '${rec_type}'=='Dependent'    Set Variable    ${DE_type}
    ...    ELSE    Set Variable    ${EE_type}
    Set To Dictionary    ${contact}    RecordTypeId    ${type}
    Set To Dictionary    ${contact}    FirstName    ${firstname}
    Set To Dictionary    ${contact}    LastName    ${lastname}
    ${ee_id}=    Run Keyword If    '${parent_acnum}'!='None'    Catenate    SEPARATOR=    ${parent_acnum}    ${id}
    ...    ELSE    Set Variable    ${id}
    IF    '${hierGroup}'!='None' and ${withHeirGroup}==True
        ${hg_group}=    getHierarchyGroupId    groupName=${hierGroup}
        Set To Dictionary    ${contact}    Reports_To_Group_c    ${hg_group}
    END
    Set To Dictionary    ${contact}    cve_EmployeeIdentificationNumber_c    ${ee_id}
    Set To Dictionary    ${contact}    cve_DateOfHire_c    ${hireDate}
    Set To Dictionary    ${contact}    Birthdate    ${birthdate}
    Set To Dictionary    ${contact}    Email    ${email}
    Set To Dictionary    ${contact}    AccountId    ${accID}
    Set To Dictionary    ${contact}    ZExternalIDContact_c    ${id}
    Set To Dictionary    ${contact}    ZNA_SocialsecurityNumber_c    ${ssn}
    Set To Dictionary    ${contact}    cve_Gender_c    ${empGender}
    Set To Dictionary    ${contact}    Gender_c    ${empGender}
    Set To Dictionary    ${contact}    cvab_Earnings_c    ${earnings}
    Set To Dictionary    ${contact}    cve_Earnings_c    ${earnings}
    Set To Dictionary    ${contact}    cvab_EarningsPeriod_c    Year
    Set To Dictionary    ${contact}    cve_EarningsPeriod_c    Year
    Set To Dictionary    ${contact}    cvab_EmploymentClassification_c    Full-time
    IF    '${addMobileInfo}'=='yes'
        Set To Dictionary    ${contact}    MobilePhone    ${mobilePhone}
    END
    IF    '${addAddressInfo}'=='yes'
        Set To Dictionary    ${contact}    MailingStreet    ${ssn} Test Street
        Set To Dictionary    ${contact}    MailingCity    ${ssn} Mailing City
        Set To Dictionary    ${MailingZipPostalCode}    MailingStateCode    NJ
        Set To Dictionary    ${contact}    MailingPostalCode    92927    ${MailingZipPostalCode}
    END
    Set To Dictionary    ${contact}    cvab_Hoursworked__c    4000
    Set To Dictionary    ${contact}    cve_HoursWorkedPerweek_c    40
    Set To Dictionary    ${contact}    cvab_MonthsOfService_c    24
    Set To Dictionary    ${contact}    Community_Profile_Name_c    ${profile}
    Run Keyword If    '${eoi}'=='TRUE'
    ...    Run Keywords    Set To Dictionary    ${contact}    Life_Reason_For_Coverage_c    Open enrollment
    ...    AND    Set To Dictionary    ${contact}    Data_Source_c    EOI 
    ...    AND    Set To Dictionary    ${contact}    Basic_Life_Current_Amt_c    100000
    ...    AND    Set To Dictionary    ${contact}    Basic_Life_Additional_Amount_Requested_c    100000
    ...    And    Set To Dictionary    ${contact}    EOI_Requested_Date_c    ${eoiDate}
    Run Keyword If    '${rec_type}'=='Spouse' and '${eoi}'=='TRUE'     Run Keywords
    ...    Set To Dictionary    ${contact}    Dependent_Life_Spouse_Current_Amt_c    50000
    ...    AND    Set To Dictionary    ${contact}    Dep_life_Spouse_Additional_Amount_Requested_c    50000
    ${id}=    Wait Until Keyword Succeeds    ${Retrycnt}    ${RetryInt}    Create Contact In Salesforce    ${contact}
    RETURN    ${id}

Generate First Name
    [Arguments]    ${inputstr}=${contactFirstName}    ${strlen}=5
    ${num}=    Generate Random String    ${strlen}    chars=[NUMBERS]
    ${fName}=    Catenate    ${num}    ${inputstr}
    RETURN    ${fName}

Generate Last Name
    [Arguments]    ${inputstr}=${contactLastName}    ${strlen}=5
    ${num}=    Generate Random String    ${strlen}    chars=[NUMBERS]
    ${LName}=    Catenate    ${num}    ${inputstr}
    RETURN    ${LName}

Generate Mobile Number
    ${area_Code}=    Set Variable    555
    ${phone}=    Generate Random String    7    chars=[NUMBERS]
    ${mobile}=    Catenate    SEPERATOR=      ${area_Code}    ${phone}
    RETURN    ${mobile}

Generate SSN
    ${num}=    Generate Random String    9    chars=[NUMBERS]
    ${first}=     Get Substring     ${num}   0    1
    ${ssn}=     Run Keyword If    '${first}'=='9'    Replace String    ${num}    ${first}    1
    ...    ELSE    Set Variable    ${num}
    RETURN    ${ssn}

Generate Employee ID
    ${num}=    Generate Random String    9    chars=[NUMBERS]
    RETURN    ${num}

Generate Email Address
    ${name}=    Generate Random String    8    chars=[LOWER]
    ${email}=    Catenate    SEPERATOR=      ${name}    @test.com
    RETURN    ${email}

Generate A Date
    #This keyword will generate a current or past or future date, the length can be defined and passed in as an argument like days=10 or months-6 or years-5[for future] and days=-1[for past] 
    [Arguments]    ${orgName}=${ACCOUNT}    ${days}=0    ${months}=0    ${years}=0    ${apiFormat}=False    ${withMonthName}=False    ${withoutWeekend}=False    ${qdePortal}=False    ${withWeekend}=False    ${setJanFirst}=False
    ${date}=    getnewdate    orgName=${orgName}    yy=${years}    mm=${months}    dd=${days}    api=${apiFormat} mon=${withMonthName}    setjanfirst=${setJanFirst}    qde=${qdePortal}    checkNonwd=${withoutWeekend}    weekEnd=${withWeekend}
    # Create date in SFDC format for data validation
    ${sfdcDate}=    getnewdate    orgName=${orgName}    yy=${years}    mm=${months}    dd=${days}    weekEnd=${withWeekend}    setjanfirst=${setJanFirst} 
    Set Suite Variable    ${sfdcDate}
    RETURN    ${date}

Add New Class Relationship
    [Arguments]    ${contactId}    ${class}
    addClassRel    ${contactId}    ${class}

Add New Policy Relationship
    [Arguments]    ${contactId}    ${policy}
    addPolicyRel    ${contactId}    ${policy}

Update Contact Fields Value
    [Arguments]    ${id}    &{fieldValuePairs}
    ${result}=    updateContactField    ${id}    &{fieldValuePairs}
    Run Keyword If    '${result}'=='Contact Update Failed'   Fail   ${result}

Navigate To Contact Page in Salesforce
    [Arguments]    ${contName}=None    ${contRecId}=None    ${sso}=False
    IF    '${contRecId}'=='None'
        ${contRecId}=    getContactId      ${contName}
    END
    Run Keyword If   '${sso}'=='True'   addcontIdTolist   ${contRecId}
    Set Suite Variable     ${contact_loc}    https://${APINSTANCE}/${contRecId}/view
    Go To   ${contact_loc}
    Wait Until Keyword Succeeds   ${Retrycnt}   ${RetryInt}   Contact Record Should be loaded   ${contName}

Contact Record Should be loaded
    [Arguments]    ${contName}
    ${locator}    Replace String    ${SFCR_Locators.contactNameHeader}    contact-name    ${contName}
    ${status}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    timeout=${MED_WAIT}
    Log To Console   *** Navigated to Contact Record Page ***

Navigate To Portal Based On Role
    [Arguments]    ${contact}    ${profile}    ${account}    ${portalName}    ${role}
    ${result}=    navigateToPortalBasedOnRole    ${contact}    ${profile}    ${account}    ${portalName}    ${role}
    Run Keyword If    '${result}'!='True'    Fail   Navigation to portal failed