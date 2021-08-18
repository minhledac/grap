*** Settings ***
Suite Setup       Setup Test Suite
Test Setup        Setup Test Case
Test Teardown     Teardown Test Case
Suite Teardown    Teardown Test Suite
Force Tags        PP_DataTest
Resource          ../../core/share/computation.robot
Resource          ../../core/share/utils.robot
Resource          ../../core/share/list_dictionary.robot
Resource          ../../core/API/POST/giao-dich/post_kenh_ban.robot
Resource          ../../config/envi.robot
Library           Collections
Library           ExcelLibrary
Library           String

*** Variables ***
${excel_path}    ${EXECDIR}/prepare-data/excel-files/PrepareDataGiaoDich.xlsx


*** Test Cases ***
PPGD_01
    [Documentation]
    [Tags]    PPGD_01
    [Template]    PP tao kenh ban
    # Sheet name
    Kênh Bán

*** Keywords ***
PP tao kenh ban
    [Arguments]     ${sheet_name}
    ${excel_data}    ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    Run Keyword If    ${length}>0    Them moi list kenh ban   @{excel_data}
