*** Settings ***
Suite Setup       Setup Test Suite
Test Setup        Setup Test Case
Test Teardown     Teardown Test Case
Suite Teardown    Teardown Test Suite
Force Tags        PP_DataTest
Resource          ../../core/share/computation.robot
Resource          ../../core/share/utils.robot
Resource          ../../core/share/list_dictionary.robot
Resource          ../../core/API/GET/thiet-lap/api_thu_khac.robot
Resource          ../../core/API/POST/thiet-lap/post_thu_khac.robot
Resource          ../../core/API/POST/thiet-lap/post_khuyen_mai.robot
Resource          ../../config/envi.robot
Library           Collections
Library           ExcelLibrary
Library           String

*** Variables ***
${excel_path}    ${EXECDIR}/prepare-data/excel-files/PrepareDataThietLap.xlsx

*** Test Cases ***
PPTL_01
    [Documentation]
    [Tags]    PPTL_01
    [Template]    PP tao loai thu khac
    # Sheet name
    Thu Khác

PPKM_01
    [Documentation]
    [Tags]    PPKM_01
    [Template]    PP tao chuong trinh khuyen mai
    # Sheet name
    Khuyến Mại

*** Keywords ***
PP tao loai thu khac
    [Arguments]    ${sheet_name}
    ${excel_data}     ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    Run Keyword If    ${length}>0    Them moi list loai thu khac    @{excel_data}

PP tao chuong trinh khuyen mai
    [Arguments]     ${sheet_name}
    ${excel_data}     ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    FOR    ${data}    IN    @{excel_data}
        Run Keyword If    ${length}>0    Them moi chuong trinh khuyen mai    @{data}
    END
#
