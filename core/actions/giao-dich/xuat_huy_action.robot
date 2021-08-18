*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Resource          ../../_common_keywords/common_damageItems_screen.robot
Resource          ../../_common_keywords/common_products_screen.robot
Resource          giao_dich_navigation.robot
Resource          ../../share/toast_message.robot
Resource          ../../share/list_dictionary.robot
Resource          ../../share/computation.robot
Resource          ../../share/utils.robot
Resource          ../../../config/envi.robot

*** Keywords ***
KV Refresh Data Xuat Huy
    Close Popup Mo ban Nhap
    FNB Menu GiaoDich
    FNB Menu GD XuatHuy
    FNB WaitVisible PXH Header Title Phieu XuatHuy

Input hang hoa vao phieu xuat huy va assert thong tin tren UI
    [Arguments]    ${ma_hang}    ${sl_huy}    ${list_giatri_huy}    ${count_tong_SL}    ${count_tong_giatri_huy}
    FNB PXH AddPXH Textbox TimKiem HH    ${ma_hang}
    FNB WaitVisible PXH AddPXH Row Hang XuatHuy    ${ma_hang}
    FNB PXH AddPXH Textbox SoLuong Huy    ${ma_hang}    ${sl_huy}    is_wait_visible=True
    ${count_giatri_huy}    Count gia tri huy by gia von UI    ${ma_hang}    ${sl_huy}
    ${count_tong_SL}            Sum    ${count_tong_SL}            ${sl_huy}
    ${count_tong_giatri_huy}    Sum    ${count_tong_giatri_huy}    ${count_giatri_huy}
    Append To List    ${list_giatri_huy}    ${count_giatri_huy}
    # assert gia tri huy, tong gia tri huy, tong SL tren UI
    ${locator_giatri_huy}    FNB GetLocator PXH AddPXH Cell GiaTri Huy    ${ma_hang}
    Convert text to number and assert    ${locator_giatri_huy}    ${count_giatri_huy}
    Assert thong tin tong gia tri huy tren UI     ${count_tong_SL}    ${count_tong_giatri_huy}
    Return From Keyword    ${list_giatri_huy}    ${count_tong_SL}    ${count_tong_giatri_huy}

# - Thêm HH vào phiếu va lấy về danh sách mã hàng, SL hủy, đơn giá, Giá trị hủy, tổng SL, Tổng giá trị hủy sau khi thêm
Add hang hoa vao phieu xuat huy
    [Arguments]    ${ma_hang_add}    ${sl_huy_add}    ${list_ma_hang}    ${list_sl_huy}    ${list_giatri_huy}    ${count_tong_SL}    ${count_tong_giatri_huy_old}
    FNB PXH AddPXH Textbox TimKiem HH    ${ma_hang_add}    is_autocomplete=True
    FNB WaitVisible PXH AddPXH Row Hang XuatHuy    ${ma_hang_add}
    FNB PXH AddPXH Textbox SoLuong Huy    ${ma_hang_add}    ${sl_huy_add}
    ${count_giatri_huy}    Count gia tri huy by gia von UI    ${ma_hang_add}    ${sl_huy_add}
    ${count_tong_SL}    Sum    ${count_tong_SL}    ${sl_huy_add}
    ${count_tong_giatri_huy}    Sum    ${count_tong_giatri_huy_old}    ${count_giatri_huy}
    # assert gia tri huy, tong gia tri huy, tong SL tren UI
    ${locator_giatri_huy}    FNB GetLocator PXH AddPXH Cell GiaTri Huy    ${ma_hang_add}
    Convert text to number and assert    ${locator_giatri_huy}    ${count_giatri_huy}
    Assert thong tin tong gia tri huy tren UI    ${count_tong_SL}    ${count_tong_giatri_huy}
    Append To List    ${list_ma_hang}       ${ma_hang_add}
    Append To List    ${list_sl_huy}        ${sl_huy_add}
    Append To List    ${list_giatri_huy}    ${count_giatri_huy}
    Return From Keyword    ${list_ma_hang}    ${list_sl_huy}    ${list_giatri_huy}    ${count_tong_SL}    ${count_tong_giatri_huy}

# - Sửa HH trong phiếu va lấy về danh sách ma hàng, SL hủy, đơn giá, Giá trị hủy, tổng SL, Tổng giá trị hủy sau khi sửa SL hàng
Sua so luong hang hoa trong phieu xuat huy
    [Arguments]    ${ma_hang_edit}    ${sl_huy_edit}    ${list_ma_hang}    ${list_sl_huy}    ${list_giatri_huy}    ${count_tong_SL}    ${count_tong_giatri_huy}    ${index}
    FNB PXH AddPXH Textbox SoLuong Huy    ${ma_hang_edit}    ${sl_huy_edit}
    # tinh gia tri huy, tong SL, tong gia tri huy sau khi edit
    ${count_tong_SL}=    Minus    ${count_tong_SL}    ${list_sl_huy[${index}]}
    ${count_tong_SL}=    Sum      ${count_tong_SL}    ${sl_huy_edit}
    ${giatri_huy_new}    Count gia tri huy by gia von UI    ${ma_hang_edit}    ${sl_huy_edit}
    # Tổng giá trị hủy sau khi edit =(Tổng giá trị hủy cũ - Giá trị hủy cũ) + Giá trị hủy mới
    ${count_tong_giatri_huy}=    Minus    ${count_tong_giatri_huy}    ${list_giatri_huy[${index}]}
    ${count_tong_giatri_huy}=    Sum      ${count_tong_giatri_huy}    ${giatri_huy_new}
    # assert gia tri huy, tong gia tri huy, tong SL tren UI
    ${locator_giatri_huy}    FNB GetLocator PXH AddPXH Cell GiaTri Huy    ${ma_hang_edit}
    Convert text to number and assert    ${locator_giatri_huy}    ${giatri_huy_new}
    Assert thong tin tong gia tri huy tren UI    ${count_tong_SL}    ${count_tong_giatri_huy}
    # Lấy danh sách mã hàng, SL hủy, Giá trị hủy sau khi sửa SL
    Set List Value    ${list_sl_huy}        ${index}    ${sl_huy_edit}
    Set List Value    ${list_giatri_huy}    ${index}    ${giatri_huy_new}
    Return From Keyword    ${list_sl_huy}    ${list_giatri_huy}    ${count_tong_SL}    ${count_tong_giatri_huy}

# Xóa HH trong phiếu va lấy về danh sách ma hàng, SL hủy, đơn giá, Giá trị hủy, tổng SL, Tổng giá trị hủy sau khi xóa hàng
Xoa hang hoa khoi phieu xuat huy
    [Arguments]    ${ma_hang_remove}    ${list_ma_hang}    ${list_sl_huy}    ${list_giatri_huy}    ${count_tong_SL}    ${count_tong_giatri_huy}    ${index}
    FNB PXH AddPXH Button Xoa Hang    ${ma_hang_remove}
    FNB WaitNotVisible PXH AddPXH Row Hang XuatHuy    ${ma_hang_remove}
    ${count_tong_SL}    Minus    ${count_tong_SL}    ${list_sl_huy[${index}]}
    ${count_tong_giatri_huy}     Minus    ${count_tong_giatri_huy}    ${list_giatri_huy[${index}]}
    Assert thong tin tong gia tri huy tren UI    ${count_tong_SL}    ${count_tong_giatri_huy}
    Remove From List    ${list_ma_hang}    ${index}
    Remove From List    ${list_sl_huy}    ${index}
    Remove From List    ${list_giatri_huy}    ${index}
    Return From Keyword    ${list_ma_hang}    ${list_sl_huy}    ${list_giatri_huy}    ${count_tong_SL}    ${count_tong_giatri_huy}

Assert UI va tinh tong gia tri huy after import file
    [Arguments]    ${ma_hang}    ${so_luong_huy}     ${list_giatri_huy}    ${count_tong_SL}    ${count_tong_giatri_huy}
    # Tinh gia tri huy = gia von * SL huy
    ${count_giatri_huy}    Count gia tri huy by gia von UI    ${ma_hang}    ${so_luong_huy}
    ${count_tong_SL}    Sum    ${count_tong_SL}    ${so_luong_huy}
    ${count_tong_giatri_huy}    Sum    ${count_tong_giatri_huy}    ${count_giatri_huy}
    Append To List    ${list_giatri_huy}    ${count_giatri_huy}
    ${locator_giatri_huy}    FNB GetLocator PXH AddPXH Cell GiaTri Huy    ${ma_hang}
    Convert text to number and assert    ${locator_giatri_huy}    ${count_giatri_huy}
    Return From Keyword    ${list_giatri_huy}    ${count_tong_SL}    ${count_tong_giatri_huy}

Count gia tri huy by gia von UI
    [Arguments]    ${ma_hang}    ${sl_huy}
    ${locator_giavon}    FNB GetLocator PXH AddPXH Cell GiaVon Huy    ${ma_hang}
    ${gia_von}    Convert text to number frm locator    ${locator_giavon}
    # tinh gia tri huy cua moi san pham va tong gia tri huy
    ${count_giatri_huy}   Multiplication and round 2    ${gia_von}    ${sl_huy}
    Return From Keyword    ${count_giatri_huy}

Count ton kho moi sau khi xuat huy
    [Arguments]    ${list_ma_hang}    ${list_ton_kho}    ${list_sl_huy}
    ${list_count_ton_kho}    Create List
    FOR    ${item_code}    IN    @{list_ma_hang}
        ${index}    Get Index From List    ${list_ma_hang}    ${item_code}
        ${count_ton_kho}    Minus    ${list_ton_kho[${index}]}    ${list_sl_huy[${index}]}
        Append To List    ${list_count_ton_kho}    ${count_ton_kho}
    END
    Return From Keyword    ${list_count_ton_kho}

Count ton kho moi sau khi huy bo phieu xuat huy
    [Arguments]    ${list_ma_hang}    ${list_ton_kho}    ${list_sl_huy}
    ${list_count_ton_kho}    Create List
    FOR    ${item_code}    IN    @{list_ma_hang}
        ${index}    Get Index From List    ${list_ma_hang}    ${item_code}
        ${count_ton_kho}    Sum    ${list_ton_kho[${index}]}    ${list_sl_huy[${index}]}
        Append To List    ${list_count_ton_kho}    ${count_ton_kho}
    END
    Return From Keyword    ${list_count_ton_kho}

Assert thong tin tong gia tri huy tren UI
    [Arguments]    ${count_tong_SL}    ${count_tong_giatri_huy}
    # tong SL va tong gia tri huy tren UI
    ${locator_tong_SL}    FNB GetLocator PXH AddPXH Text Tong SoLuong XuatHuy
    Convert text to number and assert    ${locator_tong_SL}    ${count_tong_SL}
    ${locator_tong_giatri_huy}    FNB GetLocator PXH AddPXH Text Tong Gia Tri Huy
    Convert text to number and assert    ${locator_tong_giatri_huy}    ${count_tong_giatri_huy}

Get thong tin cua hang hoa trong phieu xuat huy tren UI
    ${list_sl_huy}        Create List
    ${list_gia_von}       Create List
    ${list_gia_tri_huy}   Create List
    FOR    ${index}    IN RANGE    1    10
        ${loc_item}    FNB GetLocator PXH List Text SL Huy By Index    ${index}
        ${is_exist}    Run Keyword And Return Status    Page Should Contain Element    ${loc_item}
        Exit For Loop If    '${is_exist}'=='False'
        ${loc_gia_von}    FNB GetLocator PXH List Text Gia Von By Index    ${index}
        ${loc_gia_tri_huy}    FNB GetLocator PXH List Text Gia Tri Huy By Index    ${index}
        ${sl_huy}     Convert text to number frm locator    ${loc_item}
        ${gia_von}    Convert text to number frm locator    ${loc_gia_von}
        ${gtri_huy}   Convert text to number frm locator    ${loc_gia_tri_huy}
        Append To List    ${list_sl_huy}         ${sl_huy}
        Append To List    ${list_gia_von}        ${gia_von}
        Append To List    ${list_gia_tri_huy}    ${gtri_huy}
    END
    Return From Keyword    ${list_sl_huy}    ${list_gia_von}    ${list_gia_tri_huy}




#
