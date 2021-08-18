*** Settings ***
Library           SeleniumLibrary
Resource          ../../_common_keywords/common_menu_screen.robot
Resource          ../../_common_keywords/common_products_screen.robot
Resource          ../../share/utils.robot

*** Keywords ***
Select and upload file hang hoa
    [Arguments]    ${filepath}    ${filename}
    FNB HH Header Button Import    is_wait_visible=True
    FNB HH ImportHH Radio Update Ton Kho    is_wait_visible=True
    FNB HH ImportHH Alert Yes Update Ton Kho    is_wait_visible=True
    ${button_chonFile}    FNB GetLocator HH ImportHH Button Chon File
    Choose File    ${button_chonFile}    ${filepath}
    ${title_file_upload}    FNB GetLocator HH ImportHH Title File Upload
    KV Element Should Contain    ${title_file_upload}    ${filename}    Lỗi tên file import input và trên UI khác nhau    True
    FNB HH ImportHH Button Thuc Hien    is_wait_visible=True

# Check export thành công và convert dữ liệu sang dictionary
Check export products successfully and convert data to dictionary
    ${export_filepath}    Check export successfully and return file path
    # Load dữ liệu ra từ file export
    ${export_values_dict}    KV Load Excel As Dictionary    ${export_filepath}
    [Return]    ${export_values_dict}
