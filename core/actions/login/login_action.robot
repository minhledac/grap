*** Settings ***
Library           SeleniumLibrary
Resource          ../../_common_keywords/common_login_screen.robot
Resource          ../../_common_keywords/common_loginPos_screen.robot
Resource          ../../_common_keywords/common_Cashier_screen.robot
Resource          ../../../config/envi.robot
Resource          ../../share/utils.robot
Library          ../../../custom-library/Alert.py

*** Variables ***
${button_dong_popup_TS}            //div[contains(@class,'kv-timesheet')]//a[contains(@class,'k-link')]
${checkbox_khong_hienthi_TS}       //div[contains(@class,'footer-left')]/label

*** Keywords ***
Login Thu Ngan By Url Pos
    [Arguments]    ${retailer}   ${username}    ${password}
    ${page_title}    Get Title
    Return From Keyword If    '${page_title}'!='KiotViet-FNB'    ${page_title}
    FNB Login Pos Textbox Retailer    ${retailer}
    FNB Login Pos Textbox Username    ${username}
    FNB Login Pos Textbox Password    ${password}
    FNB Login Pos Button Dang Nhap

Login Thu Ngan Basic
    [Arguments]    ${retailer}   ${username}    ${password}
    ${page_title}    Get Title
    Return From Keyword If    '${page_title}'!='Đăng nhập'    ${page_title}
    FNB Login Textbox Ten GianHang    ${retailer}
    FNB Login Textbox Username    ${username}
    FNB Login Textbox Password    ${password}
    FNB Login Button BanHang

Login Thu Ngan successfully
    [Arguments]    ${retailer}   ${username}    ${password}
    Login Thu Ngan Basic    ${retailer}   ${username}    ${password}
    Assert login pos successfully


Login Quan Ly
    [Arguments]    ${retailer}   ${username}    ${password}
    ${page_title}    Get Title
    Return From Keyword If    '${page_title}'!='Đăng nhập'    ${page_title}
    FNB Login Textbox Ten GianHang    ${retailer}
    FNB Login Textbox Username    ${username}
    FNB Login Textbox Password    ${password}
    FNB Login Checkbox DuyTri Login
    FNB Login Button QuanLy

Login Quan Ly successfully
    [Arguments]    ${retailer}   ${username}    ${password}
    Login Quan Ly    ${retailer}   ${username}    ${password}
    FNB WaitNotVisible MHTN Header Loading Icon    1 minutes
    Assert success text

Check exist and close popup
    ${button_dong_popup_KV}    FNB GetLocator Login Button Close ThongBao
    ${checkbox_khong_hienthi_KV}    FNB GetLocator Login Checkbox Khong HienThi ThongBao
    ${list_popup}       Create List    ${button_dong_popup_KV}         ${button_dong_popup_TS}
    ${list_checkbox}    Create List    ${checkbox_khong_hienthi_KV}    ${checkbox_khong_hienthi_TS}
    FOR    ${item_close}    ${item_checkbox}    IN ZIP    ${list_popup}    ${list_checkbox}
          sleep    2s
          ${count}     Get Element Count    ${item_close}
          Continue For Loop If    ${count}<1
          Wait Until Element Is Visible    ${item_checkbox}
          KV Click Element    ${item_checkbox}
          KV Click Element    ${item_close}
          Wait Until Element Is Not Visible    ${item_close}
    END

Assert login pos successfully
    FNB WaitNotVisible MHTN Header Loading Icon    2 minutes
    ${loc_button_refresh}    FNB GetLocator MHTN Header Button Tai Lai Trang
    ${is_error}    Run Keyword And Return Status    Wait Until Element Is Visible    ${loc_button_refresh}    timeout=10s
    Run Keyword If    '${is_error}'=='True'     KV Reload Page MHTN
    Run Keyword If    '${is_error}'=='False'     Sleep    5s
    ${loc_tab_phongban}    FNB GetLocator MHTN Header Tab Phong Ban
    ${is_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${loc_tab_phongban}
    Run Keyword If    "${is_visible}"=="False"    Accept Alert

Assert success text
    Check exist and close popup
    ${loc_menu_tongquan}    FNB GetLocator Menu TongQuan
    Wait Until Element Is Visible    ${loc_menu_tongquan}   2 minutes

Assert failure text
    [Arguments]    ${error_msg}
    ${text_failvalidation}    FNB GetLocator Login Message Fail Validation
    Wait Until Element Contains    ${text_failvalidation}    ${error_msg}    5s
