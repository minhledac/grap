*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Resource          ../../_common_keywords/common_manufacturing_screen.robot
Resource          ../../_common_keywords/common_menu_screen.robot
Resource          hang_hoa_navigation.robot
Resource          ../../share/toast_message.robot
Resource          ../../share/list_dictionary.robot
Resource          ../../../config/envi.robot

*** Keywords ***
Input minor data to Thong tin SX
    [Arguments]    ${thoigian_sx}    ${ghi_chu}
    FNB SX AddPSX Textbox Ma PhieuSX    ${ma_phieu_sx}
    FNB SX AddPSX Textbox Thoigian TaoPhieuSX    ${thoigian_sx}
    FNB SX AddPSX Textarea GhiChu    ${ghi_chu}

Input ma hang san xuat va so luong
    [Arguments]    ${ma_hh_sx}    ${so_luong_sx}
    FNB SX AddPSX Textbox Search SanXuat MatHang    ${ma_hh_sx}    is_wait_visible=True    is_autocomplete=True
    ${label_mahh_sx}    FNB GetLocator SX AddPSX Label MaHang SanXuat
    ${hh_sx_added}    Get Text    ${label_mahh_sx}
    Should Contain    ${hh_sx_added}    ${ma_hh_sx}
    FNB SX AddPSX Textbox SoLuong SanXuat    ${so_luong_sx}

Edit ma hang san xuat va so luong
    [Arguments]    ${ma_hh_sx}    ${so_luong_sx}
    FNB SX AddPSX Icon Delete MaHang SX    is_wait_visible=True
    FNB SX AddPSX Textbox Search SanXuat MatHang    ${ma_hh_sx}    is_wait_visible=True    is_autocomplete=True
    ${label_mahh_sx}    FNB GetLocator SX AddPSX Label MaHang SanXuat
    ${hh_sx_added}    Get Text    ${label_mahh_sx}
    Should Contain    ${hh_sx_added}    ${ma_hh_sx}
    FNB SX AddPSX Textbox SoLuong SanXuat    ${so_luong_sx}
