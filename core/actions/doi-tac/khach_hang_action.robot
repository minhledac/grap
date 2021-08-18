*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Resource          ../../_common_keywords/common_customers_screen.robot
Resource          ../../share/toast_message.robot
Resource          ../../../config/envi.robot

*** Keywords ***
Input thong tin khach hang
    [Arguments]    ${ma_kh}    ${ten_kh}    ${nhom_kh}    ${sdt}    ${dia_chi}
    FNB KH List Textbox Ma KH    ${ma_kh}
    FNB KH List Textbox Ten KH    ${ten_kh}
    FNB KH List Textbox SDT    ${sdt}
    FNB KH List Textbox DiaChi    ${dia_chi}
    ${textbox_nhom_KH}    FNB GetLocator KH List Textbox Chon Nhom KH
    ${cell_locator}    FNB GetLocator KH List Cell Nhom KH    ${nhom_kh}
    FNB KH List Dropdown Chon Nhom    ${textbox_nhom_KH}    ${nhom_kh}    ${cell_locator}

Filter nhom khach hang
    [Arguments]    ${ten_nhom_kh}
    ${cell_item}    FNB GetLocator KH Sidebar Cell Item Nhom KH    ${ten_nhom_kh}
    FNB KH Sidebar Dropdown Nhom KH    ${cell_item}
    FNB WaitNotVisible Menu Loading Icon

Create nhom khach hang
    [Arguments]    ${ten_nhom_kh}    ${giam_gia_nhom}
    FNB KH Sidebar Button Them Nhom KhachHang
    FNB WaitVisible KH Sidebar Title Them Nhom KH
    FNB KH Sidebar Textbox Ten Nhom    ${ten_nhom_kh}
    Run Keyword If    0 <=${giam_gia_nhom} <=100    Input discount % group customer    ${giam_gia_nhom}
    ...    ELSE IF    ${giam_gia_nhom} > 100    Input discount VND group customer    ${giam_gia_nhom}
    FNB KH Sidebar Button Luu
    Create customer group message success validation

Input discount VND group customer
    [Arguments]    ${giam_gia_nhom}
    FNB KH Sidebar Button GiamGia VND
    FNB KH Sidebar Textbox Giam Gia    ${giam_gia_nhom}

Input discount % group customer
    [Arguments]    ${giam_gia_nhom}
    FNB KH Sidebar Button GiamGia %
    FNB KH Sidebar Textbox Giam Gia    ${giam_gia_nhom}

Input gia tri dieu chinh cong no khach hang
    [Arguments]     ${gia_tri}
    FNB KH List Tab No Can Thu
    FNB KH List Button Dieu Chinh    True
    FNB WaitVisible KH List Title Dieu Chinh Cong No
    FNB KH List Textbox Gia Tri No Dieu Chinh    ${gia_tri}

Input gia tri phieu thanh toan no khach hang
    [Arguments]    ${gia_tri}
    FNB KH List Tab No Can Thu
    FNB KH List Button Thanh Toan    True
    FNB WaitVisible KH List Title Popup Thanh Toan No
    FNB KH List Textbox Thu Tu Khach    ${gia_tri}

Chon thoi gian va xuat file cong no
    [Arguments]    ${thoi_gian}
    FNB KH List Tab No Can Thu
    FNB KH List Button Xuat File Cong No    True
    FNB WaitVisible KH List Title Popup Xuat File Cong No
    FNB KH List Chon Thoi Gian XuatFile CongNo    ${thoi_gian}
    FNB KH List Button DongY XuatFile Cong No

Expand colum in customer screen
    FNB KH Header Button Expand Colum
    FNB KH Header Checkbox No Hien Tai
    FNB KH Header Checkbox Tong Ban
    FNB KH Header Checkbox Tong Ban Tru Tra Hang
    FNB KH Header Button Expand Colum
    Sleep    1s

    #
