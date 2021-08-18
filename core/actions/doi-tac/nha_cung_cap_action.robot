*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Resource          ../../_common_keywords/common_Supplier_screen.robot
Resource          ../../share/toast_message.robot
Resource          ../../../config/envi.robot

*** Keywords ***
Create nhom nha cung cap
    [Arguments]    ${nhom_ncc}
    FNB NCC Sidebar Button Them Nhom NCC
    FNB WaitVisible NCC Sidebar Title Them nhom NCC
    FNB NCC Sidebar Textbox Ten Nhom    ${nhom_ncc}
    FNB NCC Sidebar Button Luu Ten Nhom
    Create supplier group message success validation

Input thong tin nha cung cap
    [Arguments]    ${ma_ncc}   ${ten_ncc}    ${nhom_ncc}    ${sdt}    ${dia_chi}
    FNB NCC Add Textbox Ma    ${ma_ncc}
    FNB NCC Add Textbox Ten    ${ten_ncc}
    FNB NCC Add Textbox SDT    ${sdt}
    FNB NCC Add Textbox Dia Chi    ${dia_chi}
    FNB NCC Add Textbox Nhom NCC    ${nhom_ncc}

Chon thoi gian va xuat file cong no NCC
    [Arguments]    ${thoi_gian}
    FNB NCC List Tab No Can Tra NCC
    FNB NCC List Button Xuat File Cong No NCC    True
    FNB WaitVisible NCC List Title Popup Xuat File Cong No
    FNB NCC List Chon Thoi Gian XuatFile CongNo    ${thoi_gian}
    FNB NCC List Button DongY XuatFile Cong No

Input gia tri dieu chinh cong no NCC
    [Arguments]    ${gia_tri}
    FNB NCC List Tab No Can Tra NCC
    FNB NCC List Button Dieu Chinh No Can Tra NCC    True
    FNB WaitVisible NCC List Title Dieu Chinh Cong No
    FNB NCC List Textbox Gia Tri No Dieu Chinh    ${gia_tri}

Input gia tri vao phieu thanh toan no NCC
    [Arguments]    ${gia_tri}
    FNB NCC List Tab No Can Tra NCC
    FNB NCC List Button Thanh Toan No Can Tra NCC    True
    FNB WaitVisible NCC List Title Popup Thanh Toan No
    FNB NCC List Textbox Tra Cho NCC    ${gia_tri}
    FNB NCC List Button Tao Phieu Chi

    #
