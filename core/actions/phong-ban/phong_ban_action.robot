*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Resource          ../../_common_keywords/common_tableroom_screen.robot
Resource          ../../_common_keywords/common_menu_screen.robot
Resource          phong_ban_navigation.robot
Resource          ../../share/toast_message.robot
Resource          ../../../config/envi.robot

*** Keywords ***
Tao nhom phong ban
    [Arguments]    ${ten_nhom}
    FNB PB AddPB Icon Them Nhom PhongBan
    FNB WaitVisible PB AddPB Title Them Nhom PhongBan
    FNB PB AddPB Textbox Ten Nhom PhongBan    ${ten_nhom}
    FNB PB AddPB Button Luu Nhom PhongBan
    Update data success validation

Select and upload file phong ban
    [Arguments]    ${filepath}    ${filename}
    FNB PB Header Button Import PhongBan    is_wait_visible=True
    ${button_chonFile}    FNB GetLocator PB ImportPB Button Chon File
    Choose File    ${button_chonFile}    ${filepath}
    ${title_file_upload}    FNB GetLocator PB ImportPB Title File Upload
    Element Should Contain    ${title_file_upload}    ${filename}    ignore_case=True
    FNB PB ImportPB Button Thuc Hien    is_wait_visible=True
    FNB WaitNotVisible PB ImportPB Title Popup Import
