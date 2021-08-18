*** Settings ***
Suite Setup       Setup Test Suite
Test Setup        Setup Test Case
Test Teardown     Teardown Test Case
Suite Teardown    Teardown Test Suite
Force Tags        PP_DataTest
Resource          ../../core/share/computation.robot
Resource          ../../core/share/utils.robot
Resource          ../../core/share/list_dictionary.robot
Resource          ../../core/API/GET/phong-ban/api_phong_ban.robot
Resource          ../../core/API/POST/phong-ban/post_phong_ban.robot
Resource          ../../config/envi.robot
Library           Collections
Library           ExcelLibrary
Library           String

*** Variables ***
${excel_path}    ${EXECDIR}/prepare-data/excel-files/PrepareDataPhongBan.xlsx

*** Test Cases ***
PPPB_01
    [Documentation]
    [Tags]    PPPB_01    
    [Template]    PP tao nhom phong ban
    # Sheet name
    Nhóm Phòng Bàn

PPPB_02
    [Documentation]
    [Tags]    PPPB_02
    [Template]    PP tao phong ban
    # Sheet name
    Phòng Bàn


*** Keywords ***
PP tao nhom phong ban
    [Arguments]    ${sheet_name}
    ${excel_data}     ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    Run Keyword If    ${length}>0    Them moi list nhom phong ban    @{excel_data}

PP tao phong ban
    [Arguments]    ${sheet_name}
    ${excel_data}     ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    Run Keyword If    ${length}>0    Them moi list phong ban    @{excel_data}

#
