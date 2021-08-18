*** Settings ***
Suite Setup       Setup Test Suite
Test Setup        Setup Test Case
Test Teardown     Teardown Test Case
Suite Teardown    Teardown Test Suite
Force Tags        PPHH_DataTest    PP_DataTest
Resource          ../../core/share/computation.robot
Resource          ../../core/share/utils.robot
Resource          ../../core/share/list_dictionary.robot
Resource          ../../core/API/GET/hang-hoa/api_danhmuc_hanghoa.robot
Resource          ../../core/API/POST/hang-hoa/post_hang_hoa.robot
Resource          ../../core/API/POST/hang-hoa/post_bang_gia.robot
Resource          ../../config/envi.robot
Library           Collections
Library           ExcelLibrary
Library           String

*** Variables ***
${excel_path}    ${EXECDIR}/prepare-data/excel-files/PrepareDataHangHoa.xlsx


*** Test Cases ***
PPHH_01
    [Documentation]
    [Tags]    PPHH_01
    [Template]    PP tao nhom hang
    # Sheet name
    Nhóm Hàng

PPHH_02
    [Documentation]
    [Tags]    PPHH_02
    [Template]    PP tao thuoc tinh
    # Sheet name
    Thuộc Tính

PPHH_03
    [Documentation]
    [Tags]    PPHH_03
    [Template]    PP tao vi tri
    # Sheet name
    Vị Trí

PPHH_04
    [Documentation]
    [Tags]    PPHH_04
    [Template]    PP tao hang thuong
    # Sheet name
    HH Thường

PPHH_05
    [Documentation]
    [Tags]    PPHH_05
    [Template]    PP tao hang thuong Full
    # Sheet name
    HH Thường Full

PPHH_06
    [Documentation]
    [Tags]    PPHH_06
    [Template]    PP tao hang san xuat
    # Sheet name
    HH Sản Xuất

PPHH_07
    [Documentation]
    [Tags]    PPHH_07
    [Template]    PP tao hang che bien
    # Sheet name
    HH Chế Biến

PPHH_08
    [Documentation]
    [Tags]    PPHH_08
    [Template]    PP tao hang dich vu
    # Sheet name
    HH Dịch Vụ

PPHH_09
    [Documentation]
    [Tags]    PPHH_09
    [Template]    PP tao hang dich vu tinh gio
    # Sheet name
    HH Tính Giờ

PPHH_10
    [Documentation]
    [Tags]    PPHH_10
    [Template]    PP tao hang combo
    # Sheet name
    HH Combo

*** Keywords ***
PP tao nhom hang
    [Arguments]     ${sheet_name}
    ${excel_data}    ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    FOR    ${data}    IN    @{excel_data}
        Run Keyword If    ${length}>0    Them moi nhom hang    @{data}
    END

PP tao thuoc tinh
    [Arguments]     ${sheet_name}
    ${excel_data}    ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    FOR    ${data}    IN    @{excel_data}
        Run Keyword If    ${length}>0    Them moi thuoc tinh    @{data}
    END

PP tao vi tri
    [Arguments]     ${sheet_name}
    ${excel_data}    ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    FOR    ${data}    IN    @{excel_data}
        Run Keyword If    ${length}>0    Them moi vi tri frm API    @{data}
    END

PP tao hang thuong
    [Arguments]     ${sheet_name}
    ${excel_data}     ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    Run Keyword If    ${length}>0    Them moi list hang thuong    @{excel_data}

PP tao hang thuong Full
    [Arguments]     ${sheet_name}
    ${excel_data}    ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    FOR    ${data}    IN    @{excel_data}
        Run Keyword If    ${length}>0    Run Keyword And Return Status    Them moi hang thuong all field    @{data}
    END

PP tao hang san xuat
    [Arguments]     ${sheet_name}
    ${excel_data}     ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    Run Keyword If    ${length}>0    Them moi list hang san xuat    @{excel_data}

PP tao hang che bien
    [Arguments]     ${sheet_name}
    ${excel_data}     ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    FOR    ${data}    IN    @{excel_data}
        Run Keyword If    ${length}>0    Them moi hang che bien    @{data}
    END

PP tao hang dich vu
    [Arguments]     ${sheet_name}
    ${excel_data}     ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    FOR    ${data}    IN    @{excel_data}
        Run Keyword If    ${length}>0    Them moi hang dich vu    @{data}
    END

PP tao hang dich vu tinh gio
    [Arguments]     ${sheet_name}
    ${excel_data}     ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    FOR    ${data}    IN    @{excel_data}
        Run Keyword If    ${length}>0    Them moi hang tinh gio    @{data}
    END

PP tao hang combo
    [Arguments]     ${sheet_name}
    ${excel_data}     ${length}    KV Read Excel As List Data Row     ${excel_path}    ${sheet_name}
    FOR    ${data}    IN    @{excel_data}
        Run Keyword If    ${length}>0    Them moi hang combo    @{data}
    END
