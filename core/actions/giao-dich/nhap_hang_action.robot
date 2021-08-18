*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Resource          ../../_common_keywords/common_purchaseOrder_screen.robot
Resource          ../../_common_keywords/common_products_screen.robot
Resource          ../../API/GET/thiet-lap/api_chi_phi_nhap_hang.robot
Resource          Giao_Dich_Navigation.robot
Resource          ../../share/toast_message.robot
Resource          ../../share/list_dictionary.robot
Resource          ../../share/computation.robot
Resource          ../../share/constants.robot
Resource          ../../../config/envi.robot
Resource          ../../share/utils.robot
Resource          ../hang-hoa/hang_hoa_add_action.robot

*** Keywords ***
KV Refresh Data Nhap hang
    Close Popup Mo ban Nhap
    FNB Menu GiaoDich
    FNB Menu GD NhapHang
    FNB WaitVisible PNH Title Phieu NhapHang

Get ma phieu chi khi update phieu tam
    [Arguments]    ${ma_phieu_nhap}    ${total_ma_pc}
    ${ma_phieu_chi}    Get Ma Phieu In So quy    ${ma_phieu_nhap}    PC
    ${ma_phieu_chi}    Catenate    SEPARATOR=-    ${ma_phieu_chi}    ${total_ma_pc}
    Return From Keyword    ${ma_phieu_chi}
# -----------------------------------------------------------
#          ACTION IMPORT HÀNG HÓA VÀO PHIẾU NHẬP HÀNG
# -----------------------------------------------------------
Assert UI and count total after import file
    [Arguments]    ${ma_hang}    ${don_gia}    ${SL_nhap}    ${giam_gia}    ${giam_gia_%}     ${list_thanh_tien}    ${list_gia_sau_GG}    ${count_tong_SL}    ${count_total}
    # Tinh gia sau GG
    ${price_af_discount}=    Run Keyword If    ${giam_gia} != 0    Computation new price - discount - VND    ${don_gia}    ${giam_gia}
    ...    ELSE IF    ${giam_gia} ==0 and ${giam_gia_%} != 0   Computation new price - discount - %    ${don_gia}    ${giam_gia_%}
    ...    ELSE IF    ${giam_gia} ==0 and ${giam_gia_%}==0     Set Variable    ${don_gia}
    Append To List    ${list_gia_sau_GG}    ${price_af_discount}
    # Tinh thanh tien = gia sau GG * SL nhap
    ${count_thanh_tien}   Multiplication and round 2    ${price_af_discount}    ${SL_nhap}
    ${count_tong_SL}      Sum    ${count_tong_SL}       ${SL_nhap}
    ${count_total}        Sum    ${count_total}         ${count_thanh_tien}
    Append To List    ${list_thanh_tien}    ${count_thanh_tien}
    ${locator_thanh_tien}    FNB GetLocator PNH AddPN Cell ThanhTien    ${ma_hang}
    Convert text to number and assert    ${locator_thanh_tien}    ${count_thanh_tien}
    Return From Keyword    ${list_thanh_tien}    ${list_gia_sau_GG}    ${count_tong_SL}    ${count_total}

Tinh gia nhap hang hoa sau khi phan bo
    [Arguments]    ${gia_hh_sau_GG}    ${tong_CP}    ${tong_CP_khac}    ${count_total}    ${GG_phieu_nhap}
    # Giá nhập mới đã phân bổ của A = Giá HH sau GG + [Giá HH sau GG x(Tổng CP nhập hàng + Tổng CP nhập hàng khác - Giảm giá phiếu nhập)]/Tổng tiền hàng
    ${gia_nhap_phan_bo}   Evaluate    ${gia_hh_sau_GG}+(${gia_hh_sau_GG}*(${tong_CP}+${tong_CP_khac}-${GG_phieu_nhap}))/${count_total}
    KV Log    ${gia_nhap_phan_bo}
    Return From Keyword    ${gia_nhap_phan_bo}

Count Total ExReturnSuppliers and ExReturnThirdParty
    [Arguments]    ${total_af_discount}    ${list_ma_CP}    ${list_ma_CP_khac}
     ${list_id_CP}         ${list_CP_value}         ${list_CP_type}         Get list id and expensesOther value by list code    ${list_ma_CP}
     ${list_id_CP_khac}    ${list_CP_khac_value}    ${list_CP_khac_type}    Get list id and expensesOther value by list code    ${list_ma_CP_khac}
     ${tong_CP}        Tinh tong gia tri chi phi nhap hang    ${total_af_discount}    ${list_CP_value}    ${list_CP_type}
     ${tong_CP_khac}   Tinh tong gia tri chi phi nhap hang    ${total_af_discount}    ${list_CP_khac_value}    ${list_CP_khac_type}
     Return From Keyword    ${tong_CP}    ${tong_CP_khac}

Tinh tong gia tri chi phi nhap hang
    [Arguments]    ${total_af_discount}    ${list_CP_value}    ${list_CP_type}
    ${tong_CP}        Set Variable    0
    FOR    ${expense_value}    ${expense_type}    IN ZIP     ${list_CP_value}    ${list_CP_type}
        KV Log    ${expense_value}
        KV Log    ${expense_type}

        ${value_VND}    Run Keyword If    '${expense_type}' == 'ValueRatio'    Convert % discount to VND    ${total_af_discount}    ${expense_value}
        ...                    ELSE IF    '${expense_type}' == 'Value'    Set Variable    ${expense_value}
        ${tong_CP}    Sum    ${tong_CP}    ${value_VND}
    END
    Return From Keyword    ${tong_CP}
#-----------------------------------------------------------
#          ACTION KHỐI THÔNG TIN BÊN PHẢI
# -----------------------------------------------------------
Them moi hang hoa khi nhap hang va assert thong tin tren UI
    [Arguments]    ${ma_hh_new}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}    ${SL_hang_moi}    ${don_gia}     ${count_tong_SL}    ${count_total}    ${list_thanh_tien}
    FNB PNH AddPN Button Them HangHoa
    FNB WaitVisible HH AddHH Text Them HH Thuong
    Input data to required field in Tab thong tin    ${ma_hh_new}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB HH AddHH Button Luu
    Create product success validation
    FNB PNH AddPN Textbox SoLuong Nhap    ${ma_hh_new}    ${SL_hang_moi}    is_wait_visible=True
    FNB PNH AddPN Textbox DonGia    ${ma_hh_new}    ${don_gia}
    ${count_thanh_tien}    Multiplication and round 2    ${don_gia}    ${SL_hang_moi}
    ${count_total}      Sum    ${count_total}      ${count_thanh_tien}
    ${count_tong_SL}    Sum    ${count_tong_SL}    ${SL_hang_moi}
    Append To List    ${list_thanh_tien}    ${count_thanh_tien}
    # assert thanh tien, tong tien hang, tong SL tren UI
    ${locator_thanh_tien}    FNB GetLocator PNH AddPN Cell ThanhTien    ${ma_hh_new}
    Convert text to number and assert    ${locator_thanh_tien}    ${count_thanh_tien}
    Assert thong tin tong thanh tien tren UI    ${count_tong_SL}    ${count_total}
    Return From Keyword    ${count_tong_SL}    ${count_total}    ${list_thanh_tien}

Them moi nha cung cap va input thong tin phieu nhap hang
    [Arguments]    ${ma_ncc}    ${ten_ncc}    ${sdt_ncc}    ${ma_phieu_nhap}    ${tien_tra_ncc}
    Input thong tin them moi nha cung cap    ${ma_ncc}    ${ten_ncc}    ${sdt_ncc}
    FNB PNH AddPN TextBox Ma PhieuNhap    ${ma_phieu_nhap}
    FNB PNH AddPN Textbox Tien Tra NhaCungCap    ${tien_tra_ncc}

Input thong tin them moi nha cung cap
    [Arguments]    ${ma_ncc}    ${ten_ncc}    ${sdt_ncc}
    FNB PNH AddPN Button Them NhaCungCap
    FNB WaitVisible PNH AddPN Title Them NhaCungCap
    FNB PNH AddPN Textbox Ma NhaCungCap    ${ma_ncc}
    FNB PNH AddPN Textbox Ten NhaCungCap    ${ten_ncc}
    FNB PNH AddPN Textbox SDT NhaCungCap    ${sdt_ncc}
    FNB PNH AddPN Button Luu NhaCungCap
    Create supplier message success validation

Input thong tin phieu nhap hang
    [Arguments]    ${ma_phieu_nhap}    ${ma_ncc}    ${ten_ncc}    ${tien_tra_ncc}
    FNB PNH AddPN TextBox Ma PhieuNhap    ${ma_phieu_nhap}
    ${loc_textbox_ma_ncc}    FNB GetLocator PNH AddPN Textbox TimKiem NhaCungCap
    ${loc_cell_item_ten_ncc}    FNB GetLocator PNH AddPN Cell Item Ten NhaCungCap    ${ten_ncc}
    Input Text    ${loc_textbox_ma_ncc}    ${ma_ncc}
    Wait Until Element Is Visible    ${loc_cell_item_ten_ncc}
    Press Keys    ${loc_textbox_ma_ncc}    ${ENTER_KEY}
    FNB PNH AddPN Textbox Tien Tra NhaCungCap    ${tien_tra_ncc}

Input full thong tin phieu nhap hang
    [Arguments]    ${ma_phieu_nhap}    ${ma_ncc}    ${ten_ncc}    ${tien_tra_ncc}    ${list_ma_CP}    ${list_ma_CP_khac}    ${giam_gia_phieu}
    Run Keyword If    ${giam_gia_phieu} != 0    Input giam gia phieu nhap    ${giam_gia_phieu}
    # Nhap thong tin CP nhap hang
    FNB PNH AddPN Button ChiPhi NhapHang
    FNB WaitVisible PNH AddPN Title Popup ChiPhi NhapHang
    FOR    ${ma_CP}    IN    @{list_ma_CP}
        FNB PNH AddPN Checkbox ChiPhi NhapHang    ${ma_CP}
    END
    Sleep    1s    #son.nd do kiotviet xử lý chậm khi gửi thông tin đến bảng thanh toán nên cần sleep 1 giây
    FNB PNH AddPN Button Close Popup ChiPhi NhapHang
    # Nhap thong tin CP nhap hang khac
    FNB PNH AddPN Button ChiPhi NhapHang Khac
    FNB WaitVisible PNH AddPN Title Popup ChiPhi NhapHang Khac
    FOR    ${ma_CP_khac}    IN    @{list_ma_CP_khac}
        FNB PNH AddPN Checkbox ChiPhi NhapHang    ${ma_CP_khac}
    END
    FNB PNH AddPN Button Close Popup ChiPhi NhapHang Khac
    Input thong tin phieu nhap hang    ${ma_phieu_nhap}    ${ma_ncc}    ${ten_ncc}    ${tien_tra_ncc}
    FNB PNH AddPN Textbox Tien Tra NhaCungCap    ${tien_tra_ncc}

Input giam gia phieu nhap
    [Arguments]    ${giam_gia_phieu}
    FNB PNH AddPN Button GiamGia PhieuNhap
    Run Keyword If   0<${giam_gia_phieu}<=100    Input % purchase order discount    ${giam_gia_phieu}
    ...    ELSE IF    ${giam_gia_phieu} > 100    Input VND purchase order discount    ${giam_gia_phieu}

Input VND purchase order discount
    [Arguments]    ${giam_gia_phieu}
    FNB PNH AddPN Button VND PhieuNhap    is_wait_visible=True
    FNB PNH AddPN Textbox GiaTri GiamGia PhieuNhap    ${giam_gia_phieu}

Input % purchase order discount
    [Arguments]    ${giam_gia_phieu}
    FNB PNH AddPN Button PhanTram PhieuNhap    is_wait_visible=True
    FNB PNH AddPN Textbox GiaTri GiamGia PhieuNhap    ${giam_gia_phieu}

#------------------------------------------------------
Input hang hoa vao phieu nhap va assert thong tin tren UI
    [Arguments]    ${item_ma_hang}    ${item_SL_nhap}    ${list_thanh_tien}    ${list_don_gia}    ${count_tong_SL}    ${count_total}    ${index}
    FNB PNH AddPN Textbox TimKiem HH    ${item_ma_hang}    is_autocomplete=True
    FNB WaitVisible PNH AddPN Row Hang Nhap    ${item_ma_hang}
    FNB PNH AddPN Textbox SoLuong Nhap    ${item_ma_hang}    ${item_SL_nhap}
    FNB PNH AddPN Textbox DonGia    ${item_ma_hang}    ${list_don_gia[${index}]}
    # tinh thanh tien cua moi san pham va tong tien hang
    ${count_thanh_tien}   Multiplication and round 2    ${list_don_gia[${index}]}    ${item_SL_nhap}
    ${count_tong_SL}      Sum    ${count_tong_SL}       ${item_SL_nhap}
    ${count_total}        Sum    ${count_total}         ${count_thanh_tien}
    Append To List    ${list_thanh_tien}    ${count_thanh_tien}
    # assert thanh tien, tong tien hang, tong SL tren UI
    ${locator_thanh_tien}    FNB GetLocator PNH AddPN Cell ThanhTien    ${item_ma_hang}
    Convert text to number and assert    ${locator_thanh_tien}    ${count_thanh_tien}
    Assert thong tin tong thanh tien tren UI     ${count_tong_SL}    ${count_total}
    Return From Keyword    ${list_thanh_tien}    ${count_tong_SL}    ${count_total}

# - Thêm HH vào phiếu va lấy về danh sách mã hàng, SL nhập, đơn giá, thành tiền, tổng SL, tổng tiền hàng sau khi thêm
Input them hang hoa vao phieu nhap hang
    [Arguments]    ${item_ma_them}    ${item_SL_them}    ${item_don_gia}    ${list_ma_bf}    ${list_SL_bf}    ${list_don_gia}    ${list_thanh_tien}
    ...    ${count_tong_SL}    ${count_total_old}
    FNB PNH AddPN Textbox TimKiem HH    ${item_ma_them}    is_autocomplete=True
    FNB WaitVisible PNH AddPN Row Hang Nhap    ${item_ma_them}
    FNB PNH AddPN Textbox SoLuong Nhap    ${item_ma_them}    ${item_SL_them}
    FNB PNH AddPN Textbox DonGia    ${item_ma_them}    ${item_don_gia}
    ${count_thanh_tien}    Multiplication and round 2    ${item_SL_them}    ${item_don_gia}
    ${count_tong_SL}=    Sum    ${count_tong_SL}    ${item_SL_them}
    ${count_total}=      Sum    ${count_total_old}    ${count_thanh_tien}
    # assert thanh tien, tong tien hang, tong SL tren UI
    ${locator_thanh_tien}    FNB GetLocator PNH AddPN Cell ThanhTien    ${item_ma_them}
    Convert text to number and assert    ${locator_thanh_tien}    ${count_thanh_tien}
    Assert thong tin tong thanh tien tren UI    ${count_tong_SL}    ${count_total}
    Append To List    ${list_ma_bf}         ${item_ma_them}
    Append To List    ${list_SL_bf}         ${item_SL_them}
    Append To List    ${list_thanh_tien}    ${count_thanh_tien}
    Append To List    ${list_don_gia}       ${item_don_gia}
    Return From Keyword    ${list_ma_bf}    ${list_SL_bf}    ${list_don_gia}    ${list_thanh_tien}    ${count_tong_SL}    ${count_total}

# - Sửa HH trong phiếu va lấy về danh sách ma hàng, SL nhập, đơn giá, thành tiền, tổng SL, tổng tiền hàng sau khi sửa SL hàng
Sua so luong hang hoa trong phieu nhap
    [Arguments]    ${item_ma_edit}    ${item_SL_edit}    ${list_SL_bf}    ${list_don_gia}    ${list_thanh_tien}    ${count_tong_SL}    ${count_total}    ${index}
    FNB PNH AddPN Textbox SoLuong Nhap    ${item_ma_edit}    ${item_SL_edit}
    # tinh thanh tien, tong SL, tong tien hang sau khi edit
    ${count_tong_SL}=    Minus    ${count_tong_SL}    ${list_SL_bf[${index}]}
    ${count_tong_SL}=    Sum      ${count_tong_SL}    ${item_SL_edit}
    ${item_thanh_tien_new}     Multiplication and round 2    ${item_SL_edit}    ${list_don_gia[${index}]}
    # Tổng tiền hàng sau khi edit =(Tổng tiền hàng cũ - Thành tiền cũ) + Thành tiền mới
    ${count_total}=    Minus    ${count_total}    ${list_thanh_tien[${index}]}
    ${count_total}=    Sum      ${count_total}    ${item_thanh_tien_new}
    # assert thanh tien, tong tien hang, tong SL tren UI
    ${locator_thanh_tien}    FNB GetLocator PNH AddPN Cell ThanhTien    ${item_ma_edit}
    Convert text to number and assert    ${locator_thanh_tien}    ${item_thanh_tien_new}
    Assert thong tin tong thanh tien tren UI    ${count_tong_SL}    ${count_total}
    # Lấy danh sách mã hàng, SL nhập, thành tiền sau khi sửa SL
    Set List Value    ${list_SL_bf}         ${index}    ${item_SL_edit}
    Set List Value    ${list_thanh_tien}    ${index}    ${item_thanh_tien_new}
    Return From Keyword    ${list_SL_bf}    ${list_thanh_tien}    ${count_tong_SL}    ${count_total}

# Xóa HH trong phiếu va lấy về danh sách ma hàng, SL nhập, đơn giá, thành tiền, tổng SL, tổng tiền hàng sau khi xóa hàng
Xoa hang hoa khoi phieu nhap hang
    [Arguments]    ${ma_hang_remove}    ${list_ma_bf}    ${list_SL_bf}    ${list_don_gia}    ${list_thanh_tien}    ${count_tong_SL}    ${count_total}    ${index}
    FNB PNH AddPN Button Xoa Hang    ${ma_hang_remove}
    FNB WaitNotVisible PNH AddPN Row Hang Nhap    ${ma_hang_remove}
    ${count_tong_SL}   Minus    ${count_tong_SL}    ${list_SL_bf[${index}]}
    ${count_total}     Minus    ${count_total}    ${list_thanh_tien[${index}]}
    Assert thong tin tong thanh tien tren UI    ${count_tong_SL}    ${count_total}
    Remove From List    ${list_ma_bf}    ${index}
    Remove From List    ${list_SL_bf}    ${index}
    Remove From List    ${list_don_gia}    ${index}
    Remove From List    ${list_thanh_tien}    ${index}
    Return From Keyword    ${list_ma_bf}    ${list_SL_bf}    ${list_don_gia}    ${list_thanh_tien}    ${count_tong_SL}    ${count_total}

Count ton kho va gia von moi sau khi nhap hang
    [Arguments]    ${list_ma_bf}    ${list_ton_kho}    ${list_gia_von}    ${list_SL_bf}    ${list_gia_nhap}
    ${list_count_ton_kho}    Create List
    ${list_count_gia_von}    Create List
    FOR    ${item_code}    IN    @{list_ma_bf}
        ${index}    Get Index From List    ${list_ma_bf}    ${item_code}
        ${count_ton_kho}    Sum    ${list_ton_kho[${index}]}    ${list_SL_bf[${index}]}
        Append To List    ${list_count_ton_kho}    ${count_ton_kho}
        # Tính giá vốn sau khi nhập hàng
        ${count_gia_von}    Computaion cost of product after purchase orders    ${list_ton_kho[${index}]}    ${list_gia_von[${index}]}    ${list_SL_bf[${index}]}    ${list_gia_nhap[${index}]}
        Append To List    ${list_count_gia_von}    ${count_gia_von}
    END
    Return From Keyword    ${list_count_ton_kho}    ${list_count_gia_von}

Assert thong tin tong thanh tien tren UI
    [Arguments]    ${count_tong_SL}    ${count_total}
    # tong SL va tong tien hang tren UI
    ${locator_tong_SL}    FNB GetLocator PNH AddPN Text Tong SoLuong HangNhap
    Convert text to number and assert    ${locator_tong_SL}    ${count_tong_SL}
    ${locator_tong_tien_hang}    FNB GetLocator PNH AddPN Text Tong Tien Hang
    Convert text to number and assert    ${locator_tong_tien_hang}    ${count_total}

Expand colum in purchase order screen
    FNB PNH Header Button Expand Colum
    Sleep    1s
    FNB PNH Header Checkbox Tong Tien Hang
    FNB PNH Header Checkbox Giam Gia
    FNB PNH Header Checkbox Chi Phi Nhap Hang
    FNB PNH Header Checkbox Can Tra NCC
    FNB PNH Header Checkbox Tien Da Tra NCC
    FNB PNH Header Checkbox Chi Phi Nhap Hang Khac
    FNB PNH Header Button Expand Colum
    Sleep    2s

Get thong tin chung ve tien cua danh sach phieu nhap tren UI
    ${loc_tong_tien}       FNB GetLocator PNH Common Text Tong Tien Hang
    ${loc_giam_gia}        FNB GetLocator PNH Common Text Giam Gia
    ${loc_CP_nhap}         FNB GetLocator PNH Common Text Chi Phi Nhap Hang
    ${loc_can_tra_ncc}     FNB GetLocator PNH Common Text Can Tra NCC
    ${loc_tien_tra_ncc}    FNB GetLocator PNH Common Text Tien Da Tra NCC
    ${loc_CP_nhap_khac}    FNB GetLocator PNH Common Text Chi Phi Nhap Hang Khac
    ${text_tong_tien}      Convert text to number frm locator    ${loc_tong_tien}
    ${text_giam_gia}       Convert text to number frm locator    ${loc_giam_gia}
    ${text_CP_nhap}        Convert text to number frm locator    ${loc_CP_nhap}
    ${text_can_tra_ncc}    Convert text to number frm locator    ${loc_can_tra_ncc}
    ${text_tien_tra_ncc}   Convert text to number frm locator    ${loc_tien_tra_ncc}
    ${text_CP_nhap_khac}   Convert text to number frm locator    ${loc_CP_nhap_khac}
    Return From Keyword    ${text_tong_tien}    ${text_giam_gia}    ${text_CP_nhap}    ${text_can_tra_ncc}    ${text_tien_tra_ncc}    ${text_CP_nhap_khac}

Get thong tin chung ve tien cua mot phieu nhap tren UI
    ${loc_tong_tien}       FNB GetLocator PNH Detail Cell Tong Tien Hang
    ${loc_giam_gia}        FNB GetLocator PNH Detail Cell Giam Gia
    ${loc_CP_nhap}         FNB GetLocator PNH Detail Cell Chi Phi Nhap Hang
    ${loc_can_tra_ncc}     FNB GetLocator PNH Detail Cell Can Tra NCC
    ${loc_tien_tra_ncc}    FNB GetLocator PNH Detail Cell Tien Da Tra NCC
    ${loc_CP_nhap_khac}    FNB GetLocator PNH Detail Cell Chi Phi Nhap Hang Khac
    ${text_tong_tien}      Convert text to number frm locator    ${loc_tong_tien}
    ${text_giam_gia}       Convert text to number frm locator    ${loc_giam_gia}
    ${text_CP_nhap}        Convert text to number frm locator    ${loc_CP_nhap}
    ${text_can_tra_ncc}    Convert text to number frm locator    ${loc_can_tra_ncc}
    ${text_tien_tra_ncc}   Convert text to number frm locator    ${loc_tien_tra_ncc}
    ${text_CP_nhap_khac}   Convert text to number frm locator    ${loc_CP_nhap_khac}
    Return From Keyword    ${text_tong_tien}    ${text_giam_gia}    ${text_CP_nhap}    ${text_can_tra_ncc}    ${text_tien_tra_ncc}    ${text_CP_nhap_khac}

Get thong tin chi tiet ve tien cua 1 phieu nhap
    [Arguments]    ${list_ten_cp}    ${list_ten_cp_khac}
    ${loc_tong_tien_hang}    FNB GetLocator PNH Detail Tong Tien Hang
    ${loc_GG_phieu}          FNB GetLocator PNH Detail Giam Gia Phieu Nhap
    ${loc_can_tra_ncc}       FNB GetLocator PNH Detail Can Tra NCC
    ${loc_tien_tra_ncc}      FNB GetLocator PNH Detail Tien Da Tra NCC
    ${text_tong_tien_hang}   Convert text to number frm locator    ${loc_tong_tien_hang}
    ${text_GG_phieu}         Convert text to number frm locator    ${loc_GG_phieu}
    ${text_can_tra_ncc}      Convert text to number frm locator    ${loc_can_tra_ncc}
    ${text_tien_tra_ncc}     Convert text to number frm locator    ${loc_tien_tra_ncc}
    # list CP
    ${list_gia_tri_cp}    Create List
    FOR    ${ten_cp}    IN    @{list_ten_cp}
        ${loc_item}    FNB GetLocator PNH Detail Gia Tri CP Nhap Theo Ten    ${ten_cp}
        ${item_value}    Convert text to number frm locator    ${loc_item}
        Append To List    ${list_gia_tri_cp}    ${item_value}
    END
    #list CP khac
    ${list_gia_tri_cp_khac}    Create List
    FOR    ${ten_cp_khac}    IN    @{list_ten_cp_khac}
        ${loc_item}    FNB GetLocator PNH Detail CP Nhap Hang Khac Theo Ten    ${ten_cp_khac}
        ${item_value}    Convert text to number frm locator    ${loc_item}
        Append To List    ${list_gia_tri_cp_khac}    ${item_value}
    END
    Return From Keyword    ${text_tong_tien_hang}    ${text_GG_phieu}    ${list_gia_tri_cp}    ${text_can_tra_ncc}    ${text_tien_tra_ncc}    ${list_gia_tri_cp_khac}










#
