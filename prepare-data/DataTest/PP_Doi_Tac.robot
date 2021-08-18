*** Settings ***
Suite Setup       Setup Test Suite
Test Setup        Setup Test Case
Test Teardown     Teardown Test Case
Suite Teardown    Teardown Test Suite
Force Tags        PP_DataTest
Resource          ../../core/share/computation.robot
Resource          ../../core/share/utils.robot
Resource          ../../core/share/list_dictionary.robot
Resource          ../../core/API/GET/doi-tac/api_khachhang.robot
Resource          ../../core/API/GET/doi-tac/api_nhacungcap.robot
Resource          ../../core/API/GET/doi-tac/api_doi_tac_giao_hang.robot
Resource          ../../core/API/POST/doi-tac/post_doi_tac_giao_hang.robot
Resource          ../../core/API/POST/doi-tac/post_khach_hang.robot
Resource          ../../core/API/POST/doi-tac/post_nha_cung_cap.robot
Resource          ../../core/API/POST/chi-nhanh/post_chi_nhanh.robot
Resource          ../../config/envi.robot
Library           Collections
Library           ExcelLibrary
Library           String

*** Variables ***
${excel_path}    ${EXECDIR}/prepare-data/excel-files/PrepareDataDoiTac.xlsx


*** Test Cases ***
PPDT_00
    [Documentation]
    [Tags]    PPDT_00  
    [Template]    PP tao chi nhanh
    # Sheet name
    Chi Nhánh

PPDT_01
    [Documentation]
    [Tags]    PPDT_01
    [Template]    PP tao nhom khach hang
    # Sheet name
    Nhóm Khách Hàng

PPDT_02
    [Documentation]
    [Tags]    PPDT_02
    [Template]    PP tao nhom nha cung cap
    # Sheet name
    Nhóm Nhà Cung Cấp

PPDT_03
    [Documentation]
    [Tags]    PPDT_03
    [Template]    PP tao nhom doi tac giao hang
    # Sheet name
    Nhóm Đối Tác GH

PPDT_04
    [Documentation]
    [Tags]    PPDT_04
    [Template]    PP tao khach hang
    # Sheet name
    Khách Hàng

PPDT_05
    [Documentation]
    [Tags]    PPDT_05
    [Template]    PP tao nha cung cap
    # Sheet name
    Nhà Cung Cấp

PPDT_06
    [Documentation]
    [Tags]    PPDT_06
    [Template]    PP tao doi tac giao hang
    # Sheet name
    Đối Tác GH


*** Keywords ***
PP tao chi nhanh
    [Arguments]    ${sheet_name}
    ${excel_data}    ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    Run Keyword If    ${length}>0    Them moi list chi nhanh    @{excel_data}

PP tao nhom khach hang
    [Arguments]    ${sheet_name}
    ${excel_data}     ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    Run Keyword If    ${length}>0    Them moi list nhom khach hang     @{excel_data}

PP tao nhom nha cung cap
    [Arguments]    ${sheet_name}
    ${excel_data}    ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    FOR    ${data}    IN    @{excel_data}
        Run Keyword If    ${length}>0    Them moi nhom nha cung cap    @{data}
    END

PP tao nhom doi tac giao hang
    [Arguments]    ${sheet_name}
    ${excel_data}    ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    FOR    ${data}    IN    @{excel_data}
        Run Keyword If    ${length}>0    Them moi nhom doi tac giao hang    @{data}
    END

PP tao khach hang
    [Arguments]    ${sheet_name}
    ${excel_data}     ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    Run Keyword If    ${length}>0    Them moi list khach hang    @{excel_data}

PP tao nha cung cap
    [Arguments]    ${sheet_name}
    ${excel_data}     ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    Run Keyword If    ${length}>0    Them moi list nha cung cap    @{excel_data}

PP tao doi tac giao hang
    [Arguments]    ${sheet_name}
    ${excel_data}    ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    FOR    ${data}    IN    @{excel_data}
        Run Keyword If    ${length}>0    Them moi doi tac giao hang    @{data}
    END

#
