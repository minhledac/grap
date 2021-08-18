*** Settings ***
Library           SeleniumLibrary
Resource          ../../_common_keywords/common_Cashier_screen.robot
Resource          ../../share/toast_message.robot
Resource          ../../../config/envi.robot
Resource          ../../API/api_access.robot
Resource          ../login/login_action.robot

*** Keywords ***
Go To Quan Ly From MHTN
    [Timeout]    1 minute
    FNB MHTN Header Menu Bar Icon
    FNB MHTN Header Menu Bar Button Quan Ly
    Assert success text

Dang Xuat From MHTN
    [Timeout]    1 minute
    FNB MHTN Header Menu Bar Icon
    FNB MHTN Header Menu Bar Button Dang Xuat

Chon chi nhanh chuyen
    [Arguments]    ${chi_nhanh}
    FNB Menu Header DropDown List ChiNhanh
    FNB Menu Header Input Search ChiNhanh    ${chi_nhanh}
    FNB Menu Header Cell Item ChiNhanh
