*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Resource          ../../_common_keywords/common_stocktakes_screen.robot
Resource          hang_hoa_navigation.robot
Resource          ../../share/toast_message.robot
Resource          ../../share/list_dictionary.robot
Resource          ../../share/computation.robot
Resource          ../../share/utils.robot
Resource          ../../API/GET/hang-hoa/api_danhmuc_hanghoa.robot
Resource          ../../../config/envi.robot

*** Keywords ***
KV Refresh Data Kiem Kho
    Close Popup Mo ban Nhap
    FNB Menu HangHoa
    FNB Menu HH KiemKho
    FNB WaitVisible KK Title Phieu KiemKho

Input data in textbox
    [Arguments]    ${ma_hang}    ${SL_thuc_te}
    ${textbox_search_hh}    FNB GetLocator KK AddPK Textbox TimKiem HH
    FNB KK AddPK Textbox TimKiem HH    ${ma_hang}    is_autocomplete=True
    FNB WaitVisible KK AddPK Row Hang Kiem    ${ma_hang}
    FNB KK AddPK Textbox SoLuong ThucTe    ${ma_hang}    ${SL_thuc_te}
    Click Element    ${textbox_search_hh}

Assert UI after import inventory excel file
    [Arguments]    ${ma_hang}    ${SL_thuc_te}    ${list_count_SL_lech}    ${list_count_gia_tri_lech}    ${count_tong_SL_thucte}
    # Get gia tri ton kho va gia von cua HH trước khi kiểm tu API
    ${gia_von_before}    ${ton_kho_before}        Get Gia von va Ton kho from API    ${ma_hang}
    ${count_SL_lech}   Minus       ${SL_thuc_te}    ${ton_kho_before}
    ${count_SL_lech}   Evaluate    round(${count_SL_lech},3)
    ${count_gia_tri_lech}   Multiplication    ${gia_von_before}    ${count_SL_lech}
    ${count_gia_tri_lech}   Evaluate    round(${count_gia_tri_lech},5)
    ${count_tong_SL_thucte}    Sum    ${count_tong_SL_thucte}    ${SL_thuc_te}
    Append To List    ${list_count_SL_lech}    ${count_SL_lech}
    Append To List    ${list_count_gia_tri_lech}    ${count_gia_tri_lech}
    Return From Keyword    ${list_count_SL_lech}    ${list_count_gia_tri_lech}    ${count_tong_SL_thucte}

Input data in stocktake and assert value on UI
    [Arguments]    ${ma_hang}    ${SL_thuc_te}    ${list_count_SL_lech}    ${list_count_gia_tri_lech}    ${count_tong_SL_thucte}
    Input data in textbox    ${ma_hang}    ${SL_thuc_te}
    Get and assert value in recent activites    ${SL_thuc_te}
    ${result_tong_SL_thucte}    Sum    ${count_tong_SL_thucte}    ${SL_thuc_te}
    Assert tong so luong lech on UI    ${result_tong_SL_thucte}
    # Get gia tri ton kho va gia von cua HH trước khi kiểm tu API
    ${gia_von_before}    ${ton_kho_before}        Get Gia von va Ton kho from API    ${ma_hang}
    ${count_SL_lech}     ${count_gia_tri_lech}    Assert SL lech va Gia tri lech on UI    ${ma_hang}    ${SL_thuc_te}    ${ton_kho_before}    ${gia_von_before}
    Append To List    ${list_count_SL_lech}    ${count_SL_lech}
    Append To List    ${list_count_gia_tri_lech}    ${count_gia_tri_lech}
    Return From Keyword    ${list_count_SL_lech}    ${list_count_gia_tri_lech}    ${result_tong_SL_thucte}

Count total actual quantity
    [Arguments]    ${list_SL}
    ${total_quantity}   Set Variable    0
    FOR   ${item_SL}    IN    @{list_SL}
        ${total_quantity}    Evaluate    ${total_quantity}+${item_SL}
        KV Log    ${total_quantity}
    END
    ${total_quantity}    Convert To Number    ${total_quantity}
    Return From Keyword    ${total_quantity}

Get and assert value in recent activites
    [Arguments]    ${input_sl_thucte}
    ${cell_soluong_kiem_ganday}   FNB GetLocator KK AddPK SL Kiem GanDay
    ${gettext_soluong_kiem}    Get Text    ${cell_soluong_kiem_ganday}
    ${gettext_soluong_kiem}    Replace String    ${gettext_soluong_kiem}    (    ${EMPTY}
    ${gettext_soluong_kiem}    Replace String    ${gettext_soluong_kiem}    )    ${EMPTY}
    ${gettext_soluong_kiem}    Convert To Number    ${gettext_soluong_kiem}
    ${input_sl_thucte}    Convert To Number    ${input_sl_thucte}
    Should Be Equal    ${gettext_soluong_kiem}    ${input_sl_thucte}

Assert tong so luong lech on UI
    [Arguments]    ${result_tong_SL_thucte}
    ${locator_tong_SL_thucte}   FNB GetLocator KK AddPK Tong SL ThucTe
    ${gettext_tong_SL_thucte}   Get Text    ${locator_tong_SL_thucte}
    ${gettext_tong_SL_thucte}   Convert To Number    ${gettext_tong_SL_thucte}
    Should Be Equal As Numbers    ${result_tong_SL_thucte}    ${gettext_tong_SL_thucte}

Assert SL lech va Gia tri lech on UI
    [Arguments]    ${ma_hang}    ${SL_thuc_te}    ${ton_kho_before}    ${gia_von_before}
    # Get text SL lech va gia tri lech hien thi tren UI
    ${gettext_SL_lech}    ${gettext_gia_tri_lech}    Get text of actual count and value on UI    ${ma_hang}
    # Tính toán SL lệch , giá tri lệch và assert
    ${count_SL_lech}    Minus    ${SL_thuc_te}    ${ton_kho_before}
    ${count_gia_tri_lech}   Multiplication and round 4    ${gia_von_before}    ${count_SL_lech}
    Should Be Equal As Numbers    ${gettext_SL_lech}    ${count_SL_lech}
    Should Be Equal As Numbers    ${gettext_gia_tri_lech}    ${count_gia_tri_lech}
    Return From Keyword    ${count_SL_lech}    ${count_gia_tri_lech}

# lấy SL lệch và giá trị lệch trên UI và convert to number
Get text of actual count and value on UI
    [Arguments]    ${ma_hang}
    ${locator_SL_lech}         FNB GetLocator KK AddPK SoLuong Lech    ${ma_hang}
    ${locator_gia_tri_lech}    FNB GetLocator KK AddPK GiaTri Lech     ${ma_hang}
    ${gettext_SL_lech}         Get Text    ${locator_SL_lech}
    ${gettext_gia_tri_lech}    Get Text    ${locator_gia_tri_lech}
    ${gettext_SL_lech}         Replace String    ${gettext_SL_lech}    ,    ${EMPTY}
    ${gettext_gia_tri_lech}    Replace String    ${gettext_gia_tri_lech}    ,    ${EMPTY}
    ${gettext_SL_lech}         Convert To Number    ${gettext_SL_lech}
    ${gettext_gia_tri_lech}    Convert To Number    ${gettext_gia_tri_lech}
    Return From Keyword    ${gettext_SL_lech}    ${gettext_gia_tri_lech}

Get list ton kho - SL lech - gia tri lech moi nhat cua hang hoa trong phieu kiem
    [Arguments]    ${list_hh_in_PK}    ${list_tonkho}    ${list_SL_thucte}    ${list_SL_lech}    ${list_value_lech}
    FOR    ${item_ma}    IN    @{list_hh_in_PK}
        ${index}    Get Index From List    ${list_hh_in_PK}    ${item_ma}
        ${gia_von_newest}    ${ton_kho_newest}    Get Gia von va Ton kho from API    ${item_ma}
        ${SL_lech}    ${gia_tri_lech}    Run Keyword If    ${ton_kho_newest} !=${list_tonkho[${index}]}    Count SL lech va gia tri lech    ${list_SL_thucte[${index}]}    ${ton_kho_newest}    ${gia_von_newest}
        ...    ELSE    Set Variable    ${list_SL_lech[${index}]}    ${list_value_lech[${index}]}
        Run Keyword If    ${ton_kho_newest} !=${list_tonkho[${index}]}    Run Keywords
        ...    Set List Value    ${list_SL_lech}    ${index}    ${SL_lech}
        ...    AND    Set List Value    ${list_value_lech}    ${index}    ${gia_tri_lech}
    END
    Return From Keyword    ${list_SL_lech}    ${list_value_lech}

Count SL lech va gia tri lech
    [Arguments]    ${SL_thuc_te}    ${ton_kho}    ${gia_von}
    ${SL_lech}    Minus    ${SL_thuc_te}    ${ton_kho}
    ${gia_tri_lech}    Multiplication and round 4    ${gia_von}    ${SL_lech}
    Return From Keyword    ${SL_lech}    ${gia_tri_lech}

# Remove hàng hóa khỏi phiếu kiểm và assert giá trị trên UI
Delete product in inventory and assert value on UI
    [Arguments]    ${ma_hang_remove}    ${list_hh_in_PK}    ${list_SL_thucte_in_PK}    ${list_SL_lech_in_PK}    ${list_value_lech_in_PK}    ${tong_SL_thucte}    ${index}
    FNB KK AddPK Button Xoa Hang    ${ma_hang_remove}    True
    FNB WaitVisible KK AddPK Title Xoa Hang Khoi PhieuKiem
    FNB KK AddPK Button DongY XoaHang
    FNB WaitNotVisible KK AddPK Row Hang Kiem    ${ma_hang_remove}
    Get and assert value in recent activites    ${list_SL_thucte_in_PK[${index}]}
    ${result_tong_SL_thucte}    Minus    ${tong_SL_thucte}    ${${list_SL_thucte_in_PK[${index}]}}
    Assert tong so luong lech on UI    ${result_tong_SL_thucte}
    Remove From List    ${list_hh_in_PK}            ${index}
    Remove From List    ${list_SL_thucte_in_PK}     ${index}
    Remove From List    ${list_SL_lech_in_PK}       ${index}
    Remove From List    ${list_value_lech_in_PK}    ${index}
    Return From Keyword    ${result_tong_SL_thucte}    ${list_hh_in_PK}    ${list_SL_thucte_in_PK}    ${list_SL_lech_in_PK}    ${list_value_lech_in_PK}

Update quantity of product in inventory and assert value on UI
    [Arguments]    ${ma_hang_edit}    ${SL_edit}    ${list_hh_in_PK}    ${list_SL_thucte_in_PK}    ${list_SL_lech_in_PK}    ${list_value_lech_in_PK}    ${tong_SL_thucte}    ${index}
    ${textbox_search_hh}    FNB GetLocator KK AddPK Textbox TimKiem HH
    FNB KK AddPK Textbox SoLuong ThucTe    ${ma_hang_edit}    ${SL_edit}
    Click Element    ${textbox_search_hh}
    Get and assert value in recent activites    ${SL_edit}
    ${gia_von_newest}    ${ton_kho_newest}    Get Gia von va Ton kho from API    ${ma_hang_edit}
    ${tong_SL_thucte_af_remove}    Minus    ${tong_SL_thucte}    ${list_SL_thucte_in_PK[${index}]}
    ${result_tong_SL_thucte}       Sum      ${tong_SL_thucte_af_remove}    ${SL_edit}
    Assert tong so luong lech on UI    ${result_tong_SL_thucte}
    # ${count_SL_lech}    ${count_gia_tri_lech}    Assert SL lech va Gia tri lech on UI    ${ma_hang_edit}    ${SL_edit}    ${ton_kho_newest}    ${gia_von_newest}
    ${count_SL_lech}    ${count_gia_tri_lech}    Count SL lech va gia tri lech    ${SL_edit}    ${ton_kho_newest}    ${gia_von_newest}

    # Thay thế SL edit trong list SL thực tế, SL lệch và Giá tri lệch thưc tê
    Run Keyword If    '${list_hh_in_PK[${index}]}'=='${ma_hang_edit}'    Run Keywords
    ...           Set List Value    ${list_SL_thucte_in_PK}     ${index}    ${SL_edit}
    ...    AND    Set List Value    ${list_SL_lech_in_PK}       ${index}    ${count_SL_lech}
    ...    AND    Set List Value    ${list_value_lech_in_PK}    ${index}    ${count_gia_tri_lech}
    Return From Keyword    ${result_tong_SL_thucte}    ${list_SL_thucte_in_PK}    ${list_SL_lech_in_PK}    ${list_value_lech_in_PK}

Input them hang hoa vao phieu tam
    [Arguments]    ${ma_hang}    ${SL_thuc_te}    ${list_hh_in_PK}    ${list_SL_thucte_in_PK}    ${list_count_SL_lech}    ${list_count_gia_tri_lech}    ${count_tong_SL_thucte}
    Input data in textbox    ${ma_hang}    ${SL_thuc_te}
    Get and assert value in recent activites    ${SL_thuc_te}
    ${result_tong_SL_thucte}    Sum    ${count_tong_SL_thucte}    ${SL_thuc_te}
    Assert tong so luong lech on UI    ${result_tong_SL_thucte}
    # Get gia tri ton kho va gia von cua HH trước khi kiểm tu API
    ${gia_von_newest}    ${ton_kho_newest}        Get Gia von va Ton kho from API    ${ma_hang}
    ${count_SL_lech}     ${count_gia_tri_lech}    Assert SL lech va Gia tri lech on UI    ${ma_hang}    ${SL_thuc_te}    ${ton_kho_newest}    ${gia_von_newest}
    Append To List    ${list_hh_in_PK}    ${ma_hang}
    Append To List    ${list_SL_thucte_in_PK}    ${SL_thuc_te}
    Append To List    ${list_count_SL_lech}    ${count_SL_lech}
    Append To List    ${list_count_gia_tri_lech}    ${count_gia_tri_lech}
    Return From Keyword    ${result_tong_SL_thucte}    ${list_hh_in_PK}    ${list_SL_thucte_in_PK}    ${list_count_SL_lech}    ${list_count_gia_tri_lech}

Get thong tin chung ve tien tren UI
    ${loc_tong_chenh_lech}    FNB GetLocator KK List Text Tong Chenh Lech
    ${loc_tong_gtri_lech}     FNB GetLocator KK List Text Tong Gia Tri Lech
    ${loc_sl_lech_tang}       FNB GetLocator KK List Text SL Lech Tang
    ${loc_tong_gtri_tang}     FNB GetLocator KK List Text Tong Gia Tri Tang
    ${loc_sl_lech_giam}       FNB GetLocator KK List Text SL Lech Giam
    ${loc_tong_gtri_giam}     FNB GetLocator KK List Text Tong Gia Tri Giam
    ${text_tong_chenh_lech}   Convert text to number frm locator    ${loc_tong_chenh_lech}
    ${text_tong_gtri_lech}    Convert text to number frm locator    ${loc_tong_gtri_lech}
    ${text_sl_lech_tang}      Convert text to number frm locator    ${loc_sl_lech_tang}
    ${text_tong_gtri_tang}    Convert text to number frm locator    ${loc_tong_gtri_tang}
    ${text_sl_lech_giam}      Convert text to number frm locator    ${loc_sl_lech_giam}
    ${text_tong_gtri_giam}    Convert text to number frm locator    ${loc_tong_gtri_giam}
    Return From Keyword    ${text_tong_chenh_lech}    ${text_tong_gtri_lech}    ${text_sl_lech_tang}    ${text_tong_gtri_tang}    ${text_sl_lech_giam}    ${text_tong_gtri_giam}

Get thong tin tong chi tiet cua phieu kiem tren UI
    ${loc_tong_thuc_te}       FNB GetLocator KK Detail Gia Tri Tong Thuc Te
    ${loc_tong_lech_tang}     FNB GetLocator KK Detail Gia Tri Tong Lech Tang
    ${loc_tong_lech_giam}     FNB GetLocator KK Detail Gia Tri Tong Lech Giam
    ${loc_tong_chenh_lech}    FNB GetLocator KK Detail Gia Tri Tong Chenh Lech
    ${text_tong_thuc_te}      Convert text to number frm locator    ${loc_tong_thuc_te}
    ${text_tong_lech_tang}    Convert text to number frm locator    ${loc_tong_lech_tang}
    ${text_tong_lech_giam}    Convert text to number frm locator    ${loc_tong_lech_giam}
    ${text_tong_chenh_lech}   Convert text to number frm locator    ${loc_tong_chenh_lech}
    Return From Keyword    ${text_tong_thuc_te}    ${text_tong_lech_tang}    ${text_tong_lech_giam}    ${text_tong_chenh_lech}



#
