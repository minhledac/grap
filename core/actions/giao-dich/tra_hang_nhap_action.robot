*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Resource          ../../_common_keywords/common_purchaseReturn_screen.robot
Resource          Giao_Dich_Navigation.robot
Resource          ../../share/toast_message.robot
Resource          ../../share/list_dictionary.robot
Resource          ../../share/computation.robot
Resource          ../../share/constants.robot
Resource          ../../../config/envi.robot
Resource          ../../share/utils.robot
Resource          ../giao-dich/tra_hang_nhap_action.robot

*** Keywords ***
KV Refresh Data Tra Hang Nhap
    Close Popup Mo ban Nhap
    FNB Menu GiaoDich
    FNB Menu GD TraHangNhap
    FNB WaitNotVisible Menu Loading Icon
    FNB WaitVisible THN Title Phieu Tra Hang Nhap

Input hang hoa vao phieu tra hang nhap va assert UI
    [Arguments]    ${item_ma}    ${item_SL}    ${item_gia_von}    ${list_thanh_tien}    ${count_tong_SL}    ${count_total}
    FNB THN Add Textbox Search Ma Ten HH    ${item_ma}    is_autocomplete=True
    FNB WaitVisible THN Add Row Hang Nhap    ${item_ma}
    FNB THN Add Textbox So Luong    ${item_ma}    ${item_SL}
    # tinh thanh tien cua moi san pham va tong tien hang
    ${count_thanh_tien}   Multiplication and round 2    ${item_gia_von}    ${item_SL}
    ${count_tong_SL}      Sum    ${count_tong_SL}       ${item_SL}
    ${count_total}        Sum    ${count_total}         ${count_thanh_tien}
    Append To List    ${list_thanh_tien}    ${count_thanh_tien}
    # Assert thành tiền, tổng tiền hàng, tổng SL trên UI
    ${locator_thanh_tien}    FNB GetLocator THN Add Text Thanh Tien    ${item_ma}
    Convert text to number and assert    ${locator_thanh_tien}    ${count_thanh_tien}
    Assert tong tien hang va tong SL tren UI    ${count_tong_SL}    ${count_total}
    Return From Keyword    ${list_thanh_tien}    ${count_tong_SL}    ${count_total}

Assert tong tien hang va tong SL tren UI
    [Arguments]    ${count_tong_SL}    ${count_total}
    # tong SL va tong tien hang tren UI
    ${locator_tong_SL}    FNB GetLocator THN Add Text Tong SoLuong
    Convert text to number and assert    ${locator_tong_SL}    ${count_tong_SL}
    ${locator_tong_tien_hang}    FNB GetLocator THN Add Text Tong Tien Hang
    Convert text to number and assert    ${locator_tong_tien_hang}    ${count_total}

Input thong tin phieu tra hang nhap
    [Arguments]    ${ma_phieu}    ${ma_ncc}    ${ten_ncc}    ${tien_ncc_tra}
    FNB THN Add TextBox Ma Phieu Tra    ${ma_phieu}
    ${loc_textbox_ma_ncc}    FNB GetLocator THN Add Textbox TimKiem NhaCungCap
    ${loc_cell_item_ten_ncc}    FNB GetLocator THN Add Cell Item Ten NhaCungCap    ${ten_ncc}
    Input Text    ${loc_textbox_ma_ncc}    ${ma_ncc}
    Wait Until Element Is Visible    ${loc_cell_item_ten_ncc}
    Press Keys    ${loc_textbox_ma_ncc}    ${ENTER_KEY}
    Run Keyword If    '${tien_ncc_tra}'!='0'   FNB THN Add Textbox Tien NCC Tra    ${tien_ncc_tra}

Count ton kho sau khi tra hang nhap
    [Arguments]    ${list_ma}    ${list_SL}    ${list_ton_kho}
    ${list_count_ton_kho}    Create List
    FOR    ${item_code}    IN    @{list_ma}
        ${index}    Get Index From List    ${list_ma}    ${item_code}
        ${count_ton_kho}    Minus    ${list_ton_kho[${index}]}    ${list_SL[${index}]}
        Append To List    ${list_count_ton_kho}    ${count_ton_kho}
    END
    Return From Keyword    ${list_count_ton_kho}

Count ton kho va gia von ngam sau khi tra hang nhap
    [Arguments]    ${list_ma}    ${list_SL_tra}    ${list_gia_tra}    ${list_ton_kho}    ${list_gia_von}
    ${list_count_ton_kho}    Create List
    ${list_count_gia_von}    Create List
    FOR    ${item_code}    IN    @{list_ma}
        ${index}    Get Index From List    ${list_ma}    ${item_code}
        ${count_ton_kho}    Minus    ${list_ton_kho[${index}]}    ${list_SL_tra[${index}]}
        Append To List    ${list_count_ton_kho}    ${count_ton_kho}
        # Tinh giá vốn ngầm = [(giá vốn gần nhất * Tồn gần nhất) - (giá trả hàng nhập * SL trả)] / (tồn gần nhất - SL trả)
        ${count_gia_von}    Computaion cost of product after purchase returns    ${list_ton_kho[${index}]}   ${list_gia_von[${index}]}   ${list_SL_tra[${index}]}   ${list_gia_tra[${index}]}
        Append To List    ${list_count_gia_von}    ${count_gia_von}
    END
    Return From Keyword    ${list_count_ton_kho}    ${list_count_gia_von}

Xoa hang khoi phieu tra hang nhap
    [Arguments]    ${ma_remove}    ${list_ma_bf}    ${list_SL_bf}    ${list_don_gia}    ${list_thanh_tien}   ${tong_SL_HH}    ${count_total}    ${index}
    FNB THN Add Button Xoa HH    ${ma_remove}
    FNB WaitNotVisible THN Add Row Hang Nhap    ${ma_remove}
    # Tính toán tổng SL HH và tổng tiền hàng trong phieu
    ${tong_SL_HH}    Minus    ${tong_SL_HH}    ${list_SL_bf[${index}]}
    ${count_total}   Minus    ${count_total}    ${list_thanh_tien[${index}]}
    # Assert UI thong tin tổng SL HH và tổng tiền hàng trong phieu
    Assert tong tien hang va tong SL tren UI    ${tong_SL_HH}    ${count_total}
    Remove From List    ${list_ma_bf}    ${index}
    Remove From List    ${list_SL_bf}    ${index}
    Remove From List    ${list_thanh_tien}    ${index}
    Remove From List    ${list_don_gia}    ${index}
    Return From Keyword    ${list_ma_bf}    ${list_SL_bf}    ${list_don_gia}    ${list_thanh_tien}    ${tong_SL_HH}    ${count_total}

Sua SL hang trong phieu tra hang nhap
    [Arguments]    ${ma_edit}    ${SL_edit}   ${list_SL_bf}    ${list_don_gia}    ${list_thanh_tien}    ${tong_SL_HH}    ${count_total}    ${index}
    FNB THN Add Textbox So Luong    ${ma_edit}    ${SL_edit}
    # tinh thanh tien, tong SL, tong tien hang sau khi edit
    ${tong_SL_HH}=    Minus    ${tong_SL_HH}    ${list_SL_bf[${index}]}
    ${tong_SL_HH}=    Sum      ${tong_SL_HH}    ${SL_edit}
    ${item_thanh_tien_new}     Multiplication and round 2    ${SL_edit}    ${list_don_gia[${index}]}
    # Tổng tiền hàng sau khi edit =(Tổng tiền hàng cũ - Thành tiền cũ) + Thành tiền mới
    ${count_total}=    Minus    ${count_total}    ${list_thanh_tien[${index}]}
    ${count_total}=    Sum      ${count_total}    ${item_thanh_tien_new}
    # assert thanh tien, tong tien hang, tong SL tren UI
    ${locator_thanh_tien}    FNB GetLocator THN Add Text Thanh Tien    ${ma_edit}
    Convert text to number and assert    ${locator_thanh_tien}    ${item_thanh_tien_new}
    Assert tong tien hang va tong SL tren UI    ${tong_SL_HH}    ${count_total}
    # Lấy danh sách mã hàng, SL nhập, thành tiền sau khi sửa SL
    Set List Value    ${list_SL_bf}         ${index}    ${SL_edit}
    Set List Value    ${list_thanh_tien}    ${index}    ${item_thanh_tien_new}
    Return From Keyword    ${list_SL_bf}    ${list_thanh_tien}    ${tong_SL_HH}    ${count_total}

Them hang hoa vao phieu tra hang nhap
    [Arguments]    ${ma_them}   ${SL_them}    ${gia_von_them}    ${list_ma_bf}    ${list_SL_bf}    ${list_thanh_tien}    ${tong_SL_HH}    ${count_total}
    FNB THN Add Textbox Search Ma Ten HH    ${ma_them}    is_autocomplete=True
    FNB WaitVisible THN Add Row Hang Nhap    ${ma_them}
    FNB THN Add Textbox So Luong    ${ma_them}    ${SL_them}
    # tinh thanh tien cua moi san pham va tong tien hang
    ${count_thanh_tien}   Multiplication and round 2    ${gia_von_them}    ${SL_them}
    ${tong_SL_HH}     Sum    ${tong_SL_HH}     ${SL_them}
    ${count_total}    Sum    ${count_total}    ${count_thanh_tien}
    Append To List    ${list_thanh_tien}    ${count_thanh_tien}
    # Assert thành tiền, tổng tiền hàng, tổng SL trên UI
    ${locator_thanh_tien}    FNB GetLocator THN Add Text Thanh Tien    ${ma_them}
    Convert text to number and assert    ${locator_thanh_tien}    ${count_thanh_tien}
    Assert tong tien hang va tong SL tren UI    ${tong_SL_HH}    ${count_total}
    Append To List    ${list_ma_bf}    ${ma_them}
    Append To List    ${list_SL_bf}    ${SL_them}
    Return From Keyword    ${list_ma_bf}    ${list_SL_bf}    ${list_thanh_tien}    ${tong_SL_HH}    ${count_total}

Assert UI and count total after import purchase return file
    [Arguments]    ${item_ma}    ${item_SL_tra}    ${item_gia_tra}    ${list_thanh_tien}    ${count_tong_SL}    ${count_total}
    # tinh thanh tien cua moi san pham va tong tien hang
    ${count_thanh_tien}   Multiplication and round 2    ${item_gia_tra}    ${item_SL_tra}
    ${count_tong_SL}      Sum    ${count_tong_SL}       ${item_SL_tra}
    ${count_total}        Sum    ${count_total}         ${count_thanh_tien}
    Append To List    ${list_thanh_tien}    ${count_thanh_tien}
    # Assert thành tiền, tổng tiền hàng, tổng SL trên UI
    ${locator_thanh_tien}    FNB GetLocator THN Add Text Thanh Tien    ${item_ma}
    Convert text to number and assert    ${locator_thanh_tien}    ${count_thanh_tien}
    Return From Keyword    ${list_thanh_tien}   ${count_tong_SL}    ${count_total}

#
