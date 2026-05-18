***Settings***
Library    SeleniumLibrary    screenshot_root_directory=EMBED
Library    scripts/sfAccountApi.py

***Keywords***
Get Values From Account
    [Arguments]    ${accountName}    &{inputFields}
    ${result}=    get_account_field_values    ${accountName}    &{inputFields}
    ${error}=    Get From Dictionary    ${result}    Error
    Run Keyword If    '${error}'!='None'    Fail    ${error}
    RETURN    ${result}

Get Intake Process And Account Number Field Values From Ultimate Parent Account
    [Arguments]    ${account}
    ${result}=    Get Values From Ultimate Parent Account    ${account}    Intake_Process_Disability_and_Absence_c-Intake_Process_Disability_and_Absence_r.Name    Intake_Process_Accommodation_c=Intake_Process_Accommodation_r.Name    Intake_Process_EOI_c=Intake_Process_EOT__r.External_ID_c    Intake_Process_Life_c=Intake_Process_Life_r.Name    AccountNumber=AccountNumber
    ${intakeProcess}=    Get From Dictionary    ${result}    Intake_Process_Disability_and_Absence_r.Name
    ${intakeAccomodation}=    Get From Dictionary    ${result}    Intake_Process_Accommodation_r.Name
    ${eoiIntakeProcess}=    Get From Dictionary    ${result}    Intake_Process_EOI_r.External_ID_c
    ${intakeProcessLife}=    Get From Dictionary    ${result}    Intake_Process_Life_r.Name
    ${parentAccNumber}=    Get From Dictionary    ${result}    AccountNumber
    Log To Console    *** Intake_Process_Disability_and_Absence_c Value At Ultimate Parent Account of ${account} Is: ${intakeProcess} ***
    Log To Console    *** Intake_Process_Accommodation_c Value At Ultimate Parent Account of ${account} Is: ${intakeAccomodation} ***
    Log To Console    *** Intake_Process_EOI_c Value At Ultimate Parent Account of ${account} Is: ${eoiIntakeProcess} ***
    Log To Console    *** Intake_Process_Life_c Value At Ultimate Parent Account of ${account} Is: ${intakeProcessLife} ***
    Log To Console    *** AccountNumber Value At Ultimate Parent Account of ${account} Is: ${parentAccNumber} ***
    Log Many    ${result}
    Set Suite Variable    ${intakeProcess}
    Set Suite Variable    ${intakeAccomodation}
    Set Suite Variable    ${eoiIntakeProcess}
    Set Suite Variable    ${intakeProcessLife}
    Set Suite Variable    ${parentAccNumber}