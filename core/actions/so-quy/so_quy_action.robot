*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Resource          ../../_common_keywords/common_cashFlow_screen.robot
Resource          ../../_common_keywords/common_menu_screen.robot
Resource          so_quy_navigation.robot
Resource          ../../share/toast_message.robot
Resource          ../../share/utils.robot
Resource          ../../../config/envi.robot

*** Keywords ***
Input thong tin phieu thu tien mat
    [Arguments]    ${ma_phieu}    ${sdt_nguoi_nop}    ${gia_tri}
    FNB SQ Add Textbox Ma Phieu Thu    ${ma_phieu}
    FNB SQ Add Textbox Ten Nguoi Nop    ${sdt_nguoi_nop}
    ${cell_nguoi_nop}    FNB GetLocator SQ Add Cell Ten Nguoi Nop    ${sdt_nguoi_nop}
    KV Wait Until Element Is Stable    ${cell_nguoi_nop}
    Click Element    ${cell_nguoi_nop}
    FNB SQ Add Textbox Gia Tri Thu Chi    ${gia_tri}

Input thong tin phieu chi tien mat
    [Arguments]    ${ma_phieu}    ${sdt_nguoi_nhan}    ${gia_tri}
    FNB SQ Add Textbox Ma Phieu Chi    ${ma_phieu}
    FNB SQ Add Textbox Ten Nguoi Nhan    ${sdt_nguoi_nhan}
    ${cell_nguoi_nhan}    FNB GetLocator SQ Add Cell Ten Nguoi Nhan    ${sdt_nguoi_nhan}
    KV Wait Until Element Is Stable    ${cell_nguoi_nhan}
    Click Element    ${cell_nguoi_nhan}
    FNB SQ Add Textbox Gia Tri Thu Chi     ${gia_tri}

Input thong tin phieu thu ngan hang
    [Arguments]    ${ma_phieu}    ${sdt_nguoi_nop}    ${gia_tri}   ${phuong_thuc}    ${so_tai_khoan}    ${total_bank_account}
    Input thong tin phieu thu tien mat    ${ma_phieu}    ${sdt_nguoi_nop}    ${gia_tri}
    ${cell_phuong_thuc}    FNB GetLocator SQ Add Cell Ten Phuong Thuc    ${phuong_thuc}
    FNB SQ Add Dropdown Chon Phuong Thuc    ${cell_phuong_thuc}
    Run Keyword If    ${total_bank_account} > 1    Chon tai khoan nhan

Chon tai khoan nhan
    ${cell_tai_khoan}    FNB GetLocator SQ Add Cell So Tai Khoan    ${so_tai_khoan}
    FNB SQ Add Button Chon Tai Khoan Nhan
    KV Scroll Element Into View    ${cell_tai_khoan}
    Click Element    ${cell_tai_khoan}

Input thong tin phieu chi ngan hang
    [Arguments]    ${ma_phieu}    ${sdt_nguoi_nhan}    ${gia_tri}   ${phuong_thuc}    ${so_tai_khoan}    ${total_bank_account}
    Input thong tin phieu chi tien mat    ${ma_phieu}    ${sdt_nguoi_nhan}    ${gia_tri}
    ${cell_phuong_thuc}    FNB GetLocator SQ Add Cell Ten Phuong Thuc    ${phuong_thuc}
    FNB SQ Add Dropdown Chon Phuong Thuc    ${cell_phuong_thuc}
    Run Keyword If    ${total_bank_account} > 1    Chon tai khoan gui

Chon tai khoan gui
    ${cell_tai_khoan}    FNB GetLocator SQ Add Cell So Tai Khoan    ${so_tai_khoan}
    FNB SQ Add Button Chon Tai Khoan Gui
    KV Scroll Element Into View    ${cell_tai_khoan}
    Click Element    ${cell_tai_khoan}

Get list gia tri theo ma phieu thu chi
    [Arguments]     ${list_ma_phieu_tm}
    ${list_giatri_tm}    Create List
    FOR    ${ma_phieu_tm}    IN ZIP    ${list_ma_phieu_tm}
        ${loc_giatri_tm}    FNB GetLocator SQ List Tong Gia Tri    ${ma_phieu_tm}
        ${text_giatri_tm}    Convert text to number frm locator    ${loc_giatri_tm}
        Append To List    ${list_giatri_tm}    ${text_giatri_tm}
    END
    Return From Keyword    ${list_giatri_tm}


#
