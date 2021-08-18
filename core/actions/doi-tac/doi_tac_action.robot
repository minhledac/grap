*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Resource          ../../_common_keywords/common_deliverypartner_screen.robot
Resource          ../../_common_keywords/common_menu_screen.robot
Resource          doi_tac_navigation.robot
Resource          ../../share/toast_message.robot
Resource          ../../share/utils.robot
Resource          ../../../config/envi.robot

*** Keywords ***
Tao nhom doi tac giao hang
    [Arguments]    ${ten_nhom}
    FNB DTGH Sidebar Icon Them Nhom DoiTac    is_wait_visible=True
    FNB WaitVisible DTGH AddDTGH Title Them Nhom DoiTac
    FNB DTGH AddDTGH Textbox Ten Nhom DoiTac    ${ten_nhom}
    FNB DTGH AddDTGH Button Luu Nhom DoiTac
    Create partner delivery group success validation

Select and upload file doi tac giao hang
    [Arguments]    ${filepath}    ${filename}
    FNB DTGH Header Button Import DoiTac    is_wait_visible=True
    ${button_chonFile}    FNB GetLocator DTGH ImportDTGH Button Chon File
    Choose File    ${button_chonFile}    ${filepath}
    ${title_file_upload}    FNB GetLocator DTGH ImportDTGH Title File Upload
    Element Should Contain    ${title_file_upload}    ${filename}    ignore_case=True
    FNB DTGH ImportDTGH Button Thuc Hien    is_wait_visible=True
    FNB WaitNotVisible DTGH ImportDTGH Title Popup Import

Thuc hien dieu chinh phi can tra doi tac giao hang
    [Arguments]    ${giatri_no_dieuchinh}    ${mo_ta}
    FNB DTGH ListDTGH Tab PhiCanTra DoiTac    is_wait_visible=True
    FNB DTGH ListDTGH Button DieuChinh NoDoiTacGH    is_wait_visible=True
    FNB WaitVisible DTGH PopupDTGH Title Popup DieuChinh
    FNB DTGH PopupDTGH Popup DieuChinh Textbox Gt No    ${giatri_no_dieuchinh}
    FNB DTGH PopupDTGH Popup DieuChinh Textarea MoTa    ${mo_ta}

Thuc hien thanh toan phi cho doi tac giao hang
    [Arguments]    ${giatri_tra_doitac}    ${ghi_chu}
    FNB DTGH ListDTGH Tab PhiCanTra DoiTac    is_wait_visible=True
    FNB DTGH ListDTGH Button ThanhToan NoDoiTacGH    is_wait_visible=True
    FNB WaitVisible DTGH PopupDTGH Title Popup ThanhToan
    ${locator_no_ht}    FNB GetLocator DTGH PopupDTGH Popup ThanhToan Label Gt No HT
    ${get_no_ht}    Convert text to number frm locator    ${locator_no_ht}
    FNB DTGH PopupDTGH Popup ThanhToan Textbox TienTra    ${giatri_tra_doitac}
    ${count_no_sau}    Minus    ${get_no_ht}    ${giatri_tra_doitac}
    ${locator_no_sau}    FNB GetLocator DTGH PopupDTGH Popup ThanhToan Label Gt No Sau
    ${get_no_sau}    Convert text to number frm locator    ${locator_no_sau}
    KV Should Be Equal As Numbers    ${count_no_sau}    ${get_no_sau}    Lỗi tính nợ sau trên UI không đúng
    FNB DTGH PopupDTGH Popup ThanhToan Textarea GhiChu    ${ghi_chu}
    Return From Keyword    ${get_no_sau}

Chon phuong thuc thanh toan phi cho doi tac giao hang
    [Arguments]    ${phuong_thuc_tt}    ${so_tai_khoan}    ${tong_so_tk}
    ${locator_phuong_thuc}    FNB GetLocator DTGH PopupDTGH Popup ThanhToan Cell Item PhuongThuc    ${phuong_thuc_tt}
    FNB DTGH PopupDTGH Popup ThanhToan Dropdown PhuongThuc    ${locator_phuong_thuc}
    FNB WaitVisible DTGH PopupDTGH Popup ThanhToan Label SoTK
    ${locator_so_tk}    FNB GetLocator DTGH PopupDTGH Popup ThanhToan Cell Item SoTK    ${so_tai_khoan}
    Run Keyword If    ${tong_so_tk} > 1    FNB DTGH PopupDTGH Popup ThanhToan Dropdown SoTK    ${locator_so_tk}

Chon hien thi cac truong lien quan den tien page doi tac giao hang
    FNB HD Header Icon Menu Hien Thi Cac Truong
    FNB DTGH Header Column Can Thu Ho
    FNB HD Header Icon Menu Hien Thi Cac Truong
