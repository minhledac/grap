*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Resource          ../../_common_keywords/common_transfer_screen.robot
Resource          ../../_common_keywords/common_products_screen.robot
Resource          giao_dich_navigation.robot
Resource          ../menu/header_menu_action.robot
Resource          ../../API/GET/hang-hoa/api_danhmuc_hanghoa.robot
Resource          ../../share/toast_message.robot
Resource          ../../share/list_dictionary.robot
Resource          ../../share/computation.robot
Resource          ../../share/utils.robot
Resource          ../../../config/envi.robot

*** Keywords ***
KV Refresh Data Chuyen Hang
    Close Popup Mo ban Nhap
    FNB Menu GiaoDich
    FNB Menu GD ChuyenHang
    FNB WaitVisible PCH Header Title Phieu Chuyen

Chon hien thi cac truong lien quan den tien page chuyen hang
    FNB HD Header Icon Menu Hien Thi Cac Truong
    FNB PCH Header Column Tong SL Nhan
    FNB PCH Header Column Gia Tri Nhan
    FNB PCH Header Column Tong So Mat Hang
    FNB PCH Header Column Tong SL Chuyen
    FNB HD Header Icon Menu Hien Thi Cac Truong

Input hang hoa vao phieu chuyen hang va assert thong tin tren UI
    [Arguments]    ${ma_hang}    ${sl_chuyen}    ${list_thanh_tien}    ${count_tong_SL}    ${count_tong_giatri_chuyen}
    FNB PCH AddPCH Textbox TimKiem HH    ${ma_hang}
    FNB WaitVisible PCH AddPCH Row Hang Chuyen    ${ma_hang}
    # Khi input vào textbox số lượng do delay quá ít nên bị fail case. Sleep để đảm bảo không bị fail
    Sleep    0.5
    FNB PCH AddPCH Textbox SoLuong Chuyen    ${ma_hang}    ${sl_chuyen}    is_wait_visible=True
    ${count_thanh_tien}    Count gia tri chuyen by gia von API    ${ma_hang}    ${sl_chuyen}
    ${count_tong_SL}    Sum    ${count_tong_SL}    ${sl_chuyen}
    ${count_tong_giatri_chuyen}    Sum    ${count_tong_giatri_chuyen}    ${count_thanh_tien}
    Append To List    ${list_thanh_tien}    ${count_thanh_tien}
    # assert gia tri chuyen, tong SL tren UI
    ${locator_thanh_tien}    FNB GetLocator PCH AddPCH Cell Thanh Tien Chuyen    ${ma_hang}
    Convert text to number and assert    ${locator_thanh_tien}    ${count_thanh_tien}
    Assert thong tin tong so luong chuyen tren UI     ${count_tong_SL}
    Return From Keyword    ${list_thanh_tien}    ${count_tong_SL}    ${count_tong_giatri_chuyen}

Mo phieu chuyen hang can cap nhat
    [Arguments]    ${ma_phieu_update}
    FNB PCH Sidebar Textbox Search Ma PhieuChuyen    ${ma_phieu_update}
    FNB WaitNotVisible Menu Loading Icon
    ${loc_button_open}    FNB GetLocator PCH List Button Mo PhieuChuyen
    KV Scroll Element Into View    ${loc_button_open}    is_wait_loading=true
    KV Click Element    ${loc_button_open}

# - Thêm HH vào phiếu và lấy về danh sách mã hàng, SL chuyển, Giá trị chuyển, tổng SL, Tổng giá trị chuyển sau khi thêm
Add hang hoa vao phieu chuyen hang
    [Arguments]    ${ma_hang_add}    ${sl_chuyen_add}    ${list_ma_hang}    ${list_sl_chuyen}    ${list_thanh_tien}    ${count_tong_SL}    ${count_tong_giatri_chuyen_old}
    FNB PCH AddPCH Textbox TimKiem HH    ${ma_hang_add}    is_autocomplete=True
    FNB WaitVisible PCH AddPCH Row Hang Chuyen    ${ma_hang_add}
    Sleep    0.5
    FNB PCH AddPCH Textbox SoLuong Chuyen    ${ma_hang_add}    ${sl_chuyen_add}
    ${count_thanh_tien}    Count gia tri chuyen by gia von API    ${ma_hang_add}    ${sl_chuyen_add}
    ${count_tong_SL}    Sum    ${count_tong_SL}    ${sl_chuyen_add}
    ${count_tong_giatri_chuyen}    Sum    ${count_tong_giatri_chuyen_old}    ${count_thanh_tien}
    # assert gia tri chuyen, tong gia tri chuyen, tong SL tren UI
    ${locator_thanh_tien}    FNB GetLocator PCH AddPCH Cell Thanh Tien Chuyen    ${ma_hang_add}
    Convert text to number and assert    ${locator_thanh_tien}    ${count_thanh_tien}
    Assert thong tin tong so luong chuyen tren UI    ${count_tong_SL}
    Append To List    ${list_ma_hang}       ${ma_hang_add}
    Append To List    ${list_sl_chuyen}        ${sl_chuyen_add}
    Append To List    ${list_thanh_tien}    ${count_thanh_tien}
    Return From Keyword    ${list_ma_hang}    ${list_sl_chuyen}    ${list_thanh_tien}    ${count_tong_SL}    ${count_tong_giatri_chuyen}

# - Sửa HH trong phiếu và lấy về danh sách mã hàng, SL chuyển, Giá trị chuyển, tổng SL, Tổng giá trị chuyển sau khi sửa SL hàng
Sua so luong hang hoa trong phieu chuyen hang
    [Arguments]    ${ma_hang_edit}    ${sl_chuyen_edit}    ${list_sl_chuyen}    ${list_thanh_tien}    ${count_tong_SL}    ${count_tong_giatri_chuyen}    ${index}
    Sleep    0.5
    FNB PCH AddPCH Textbox SoLuong Chuyen    ${ma_hang_edit}    ${sl_chuyen_edit}
    # tinh gia tri chuyen, tong SL, tong gia tri chuyen sau khi edit
    ${count_tong_SL}=    Minus    ${count_tong_SL}    ${list_sl_chuyen[${index}]}
    ${count_tong_SL}=    Sum      ${count_tong_SL}    ${sl_chuyen_edit}
    ${giatri_chuyen_new}    Count gia tri chuyen by gia von API    ${ma_hang_edit}    ${sl_chuyen_edit}
    # Tổng giá trị chuyển sau khi edit =(Tổng giá trị chuyển cũ - Giá trị chuyển cũ) + Giá trị chuyển mới
    ${count_tong_giatri_chuyen}=    Minus    ${count_tong_giatri_chuyen}    ${list_thanh_tien[${index}]}
    ${count_tong_giatri_chuyen}=    Sum      ${count_tong_giatri_chuyen}    ${giatri_chuyen_new}
    # assert gia tri chuyen, tong gia tri chuyen, tong SL tren UI
    ${locator_thanh_tien}    FNB GetLocator PCH AddPCH Cell Thanh Tien Chuyen     ${ma_hang_edit}
    Convert text to number and assert    ${locator_thanh_tien}    ${giatri_chuyen_new}
    Assert thong tin tong so luong chuyen tren UI    ${count_tong_SL}
    # Lấy danh sách mã hàng, SL chuyển, Giá trị chuyển sau khi sửa SL
    Set List Value    ${list_sl_chuyen}     ${index}    ${sl_chuyen_edit}
    Set List Value    ${list_thanh_tien}    ${index}    ${giatri_chuyen_new}
    Return From Keyword    ${list_sl_chuyen}    ${list_thanh_tien}    ${count_tong_SL}    ${count_tong_giatri_chuyen}

# Xóa HH trong phiếu va lấy về danh sách ma hàng, SL chuyển, Giá trị chuyển, tổng SL, Tổng giá trị chuyển sau khi xóa hàng
Xoa hang hoa khoi phieu chuyen hang
    [Arguments]    ${ma_hang_remove}    ${list_ma_hang}    ${list_sl_chuyen}    ${list_thanh_tien}    ${count_tong_SL}    ${count_tong_giatri_chuyen}    ${index}
    FNB PCH AddPCH Button Xoa Hang    ${ma_hang_remove}
    FNB WaitNotVisible PCH AddPCH Row Hang Chuyen    ${ma_hang_remove}
    ${count_tong_SL}    Minus    ${count_tong_SL}    ${list_sl_chuyen[${index}]}
    ${count_tong_giatri_chuyen}     Minus    ${count_tong_giatri_chuyen}    ${list_thanh_tien[${index}]}
    Assert thong tin tong so luong chuyen tren UI    ${count_tong_SL}
    Remove From List    ${list_ma_hang}    ${index}
    Remove From List    ${list_sl_chuyen}    ${index}
    Remove From List    ${list_thanh_tien}    ${index}
    Return From Keyword    ${list_ma_hang}    ${list_sl_chuyen}    ${list_thanh_tien}    ${count_tong_SL}    ${count_tong_giatri_chuyen}

Assert UI va tinh tong gia tri chuyen after import file
    [Arguments]    ${ma_hang}    ${so_luong_chuyen}     ${list_thanh_tien}    ${count_tong_SL}    ${count_tong_giatri_chuyen}
    # Tinh gia tri chuyen = gia chuyen * SL chuyen
    ${count_thanh_tien}    Count gia tri chuyen by gia von API    ${ma_hang}    ${so_luong_chuyen}
    ${count_tong_SL}    Sum    ${count_tong_SL}    ${so_luong_chuyen}
    ${count_tong_giatri_chuyen}    Sum    ${count_tong_giatri_chuyen}    ${count_thanh_tien}
    Append To List    ${list_thanh_tien}    ${count_thanh_tien}
    ${locator_thanh_tien}    FNB GetLocator PCH AddPCH Cell Thanh Tien Chuyen    ${ma_hang}
    Convert text to number and assert    ${locator_thanh_tien}    ${count_thanh_tien}
    Return From Keyword    ${list_thanh_tien}    ${count_tong_SL}    ${count_tong_giatri_chuyen}

Count gia tri nhan by gia nhan UI
    [Arguments]    ${ma_hang}    ${sl_nhan}
    ${locator_gianhan}    FNB GetLocator PCH AddPCH Cell Gia Nhan    ${ma_hang}
    ${gia_nhan}    Convert text to number frm locator    ${locator_gianhan}
    # tinh gia tri nhan cua moi san pham
    ${count_thanh_tien}   Multiplication and round 2    ${gia_nhan}    ${sl_nhan}
    Return From Keyword    ${count_thanh_tien}

Count gia tri chuyen by gia von API
    [Arguments]    ${ma_hang}    ${sl_chuyen}
    ${gia_chuyen}    Get Gia von of product by code    ${ma_hang}
    # tinh gia tri chuyen = gia von * so luong chuyen
    ${count_thanh_tien}   Multiplication and round 2    ${gia_chuyen}    ${sl_chuyen}
    Return From Keyword    ${count_thanh_tien}

Count ton kho moi sau khi chuyen hang
    [Arguments]    ${list_ma_hang}    ${list_ton_kho}    ${list_sl_chuyen}
    ${list_count_tk_chuyen}    Create List
    FOR    ${item_code}    IN    @{list_ma_hang}
        ${index}    Get Index From List    ${list_ma_hang}    ${item_code}
        ${count_ton_kho}    Minus    ${list_ton_kho[${index}]}    ${list_sl_chuyen[${index}]}
        Append To List    ${list_count_tk_chuyen}    ${count_ton_kho}
    END
    Return From Keyword    ${list_count_tk_chuyen}

Count ton kho moi sau khi nhan hang
    [Arguments]    ${list_ma_hang}    ${list_ton_kho}    ${list_sl_nhan}
    ${list_count_tk_nhan}    Create List
    FOR    ${item_code}    IN    @{list_ma_hang}
        ${index}    Get Index From List    ${list_ma_hang}    ${item_code}
        ${count_ton_kho}    Sum    ${list_ton_kho[${index}]}    ${list_sl_nhan[${index}]}
        Append To List    ${list_count_tk_nhan}    ${count_ton_kho}
    END
    Return From Keyword    ${list_count_tk_nhan}

Count ton kho moi sau khi huy bo phieu chuyen hang
    [Arguments]    ${list_ma_hang}    ${list_ton_kho}    ${list_sl_chuyen}
    ${list_count_ton_kho}    Create List
    FOR    ${item_code}    IN    @{list_ma_hang}
        ${index}    Get Index From List    ${list_ma_hang}    ${item_code}
        ${count_ton_kho}    Sum    ${list_ton_kho[${index}]}    ${list_sl_chuyen[${index}]}
        Append To List    ${list_count_ton_kho}    ${count_ton_kho}
    END
    Return From Keyword    ${list_count_ton_kho}

Assert thong tin tong so luong chuyen tren UI
    [Arguments]    ${count_tong_SL_chuyen}
    # tong SL chuyen
    ${locator_tong_SL_chuyen}    FNB GetLocator PCH AddPCH Text Tong SoLuong Chuyen
    Convert text to number and assert    ${locator_tong_SL_chuyen}    ${count_tong_SL_chuyen}

Assert thong tin tong so luong chuyen va nhan tren chi nhanh nhan UI
    [Arguments]    ${count_tong_SL_chuyen}    ${count_tong_SL_nhan}
    # tong SL chuyen
    ${locator_tong_SL_chuyen}    FNB GetLocator PCH AddPCH Cell TongSoLuong Chuyen
    Convert text to number and assert    ${locator_tong_SL_chuyen}    ${count_tong_SL_chuyen}
    # tong SL nhan
    ${locator_tong_SL_nhan}    FNB GetLocator PCH AddPCH Cell TongSoLuong Nhan
    Convert text to number and assert    ${locator_tong_SL_nhan}    ${count_tong_SL_nhan}

Assert cac thong tin phieu chuyen hang tren UI chi nhanh nhan
    [Arguments]    ${ma_hang}    ${sl_chuyen}    ${list_thanh_tien_nhan}    ${count_tong_SL_nhan}    ${count_tong_giatri_nhan}
    FNB WaitVisible PCH AddPCH Row Hang Chuyen    ${ma_hang}
    ${locator_ton_kho}    FNB GetLocator PCH AddPCH Cell TonKho HT    ${ma_hang}
    # KV Check Element Is Stable    ${locator_ton_kho}
    ${get_txt_ton_kho}    Get Text    ${locator_ton_kho}
    ${ton_kho_cn}    Get Ton kho theo chi nhanh frm API    ${ma_hang}
    KV Compare Scalar Values    ${get_txt_ton_kho}    ${ton_kho_cn}    Lỗi tồn kho theo chi nhánh trên UI và trong API khác nhau
    ${locator_sl_chuyen}    FNB GetLocator PCH AddPCH Cell SoLuong Chuyen    ${ma_hang}
    # KV Check Element Is Stable    ${locator_sl_chuyen}
    ${get_txt_sl_chuyen}    Get Text    ${locator_sl_chuyen}
    KV Compare Scalar Values    ${get_txt_sl_chuyen}    ${sl_chuyen}    Lỗi số lượng chuyển trên UI chi nhánh nhận và input khác nhau
    # Trường hợp không input số lượng nhận -> mặc định là số lượng nhận bằng số lượng chuyển
    ${count_thanh_tien_nhan}    Count gia tri nhan by gia nhan UI    ${ma_hang}    ${sl_chuyen}
    ${count_tong_SL_nhan}    Sum    ${count_tong_SL_nhan}    ${sl_chuyen}
    ${count_tong_giatri_nhan}    Sum    ${count_tong_giatri_nhan}    ${count_thanh_tien_nhan}
    Append To List    ${list_thanh_tien_nhan}    ${count_thanh_tien_nhan}
    # assert gia tri nhan, tong SL tren UI
    ${locator_thanh_tien}    FNB GetLocator PCH AddPCH Cell Thanh Tien Nhan    ${ma_hang}
    Convert text to number and assert    ${locator_thanh_tien}    ${count_thanh_tien_nhan}
    Return From Keyword    ${list_thanh_tien_nhan}    ${count_tong_SL_nhan}    ${count_tong_giatri_nhan}
