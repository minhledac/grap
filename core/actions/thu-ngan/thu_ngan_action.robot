*** Settings ***
Library           SeleniumLibrary
Library           String
Library           BuiltIn
Resource          ../../_common_keywords/common_login_screen.robot
Resource          ../../_common_keywords/common_loginPos_screen.robot
Resource          ../../_common_keywords/common_Cashier_screen.robot
Resource          ../../API/GET/hang-hoa/api_danhmuc_hanghoa.robot
Resource          ../../API/GET/doi-tac/api_khachhang.robot
Resource          ../../API/GET/doi-tac/api_doi_tac_giao_hang.robot
Resource          ../../share/toast_message.robot
Resource          ../../share/list_dictionary.robot
Resource          ../../../config/envi.robot
Resource          ../../../core/share/utils.robot
Resource          ../../../core/share/constants.robot
Library           ../../../custom-library/PdfHandle.py
Library           String
Library           Collections


*** Keywords ***
KV Reload Page MHTN
    Reload Page
    FNB WaitNotVisible MHTN Header Loading Icon    wait_time_out=1 min
    Sleep     5s
    FNB WaitVisible MHTN Header Text Title Phong Ban    wait_time_out=30s

Get the content of log file
    ${list_log_filepath}    Create List    C:\\Users\\haihv\\AppData\\Local\\Programs\\KiotViet_KetNoi\\logs    C:\\Users\\hanhnt\\AppData\\Local\\Programs\\KiotViet_KetNoi\\logs
    ...                                    C:\\Users\\Thanh Pham\\AppData\\Roaming\\KiotViet_KetNoi\\logs
    ${result_path}    Set Variable    ${EMPTY}
    FOR    ${filepath}    IN    @{list_log_filepath}
        ${is_exist}    Run Keyword And Return Status    Directory Should Exist    ${filepath}
        Continue For Loop If    '${is_exist}'=='False'
        ${result_path}    Set Variable    ${filepath}
    END
    ${current_date}    Get Current Date    result_format=%Y%m%d
    ${log_filename}    Set Variable    info-${current_date}.log
    ${log_fullpath}    Set Variable    ${result_path}\\${log_filename}
    #loannt: cần sleep do phải đợi thời gian app kết nối ghi vào file log
    Sleep    10s
    ${content_log}     Get File    ${log_fullpath}
    KV Log    ${content_log}
    Return From Keyword    ${content_log}

Tim kiem va chon phong ban
    [Arguments]    ${table_name}
    Wait Until Keyword Succeeds    3 times    0s    Check table is chosen success    ${table_name}

Check table is chosen success
    [Arguments]    ${table_name}
    FNB MHTN Header Tab Phong Ban
    FNB MHTN Header Icon Search Phong Ban
    Sleep    0.5s
    FNB MHTN Header Textbox Search Phong Ban    ${table_name}    is_autocomplete=True
    # FNB WaitVisible MHTN Tab PhongBan Item Selected Table    ${table_name}

Tim kiem va them hang hoa vao ban
    [Arguments]    ${list_ma_hh}    ${is_return_ten}=False
    ${type_list_ma_hh}    Evaluate    type($list_ma_hh).__name__
    ${list_ma_hh}    Run Keyword If    '${type_list_ma_hh}'=='list'    Set Variable    ${list_ma_hh}    ELSE    Create List    ${list_ma_hh}
    ${list_ten_hh}    Get list product name by code    ${list_ma_hh}
    ${loc_search_hh}    FNB GetLocator MHTN Header Textbox Search Thuc Don
    FOR    ${ma_hh}    ${ten_hh}    IN ZIP    ${list_ma_hh}    ${list_ten_hh}
        Wait Until Keyword Succeeds    3 times    0s    Check product is sync success    ${ma_hh}     ${loc_search_hh}
        Press Keys    None    ${ENTER_KEY}
        ${loc_ten_hh}    FNB GetLocator MHTN TabOrder Text Ten HH UI    ${ten_hh}
        Wait Until Element Is Visible    ${loc_ten_hh}
        ${text_ten_hh}    Get Text    ${loc_ten_hh}
        KV Should Be Equal As Strings    ${ten_hh}    ${text_ten_hh}    msg=Sai tên HH trên UI
    END
    Return From Keyword If    '${is_return_ten}'=='True'    ${list_ten_hh}

Tim kiem va them hang hoa vao ban khi nhap nhanh
    [Arguments]    ${list_ma_hh}    ${is_return_ten}=False
    ${type_list_ma_hh}    Evaluate    type($list_ma_hh).__name__
    ${list_ma_hh}    Run Keyword If    '${type_list_ma_hh}'=='list'    Set Variable    ${list_ma_hh}    ELSE    Create List    ${list_ma_hh}
    ${list_ten_hh}    Get list product name by code    ${list_ma_hh}
    ${loc_search_hh}    FNB GetLocator MHTN Header Textbox Search Thuc Don
    FOR    ${ma_hh}    ${ten_hh}    IN ZIP    ${list_ma_hh}    ${list_ten_hh}
        Wait Until Keyword Succeeds    3 times    0s    Check product is sync success    ${ma_hh}     ${loc_search_hh}
        Press Keys    None    ${ENTER_KEY}
    END
    Return From Keyword If    '${is_return_ten}'=='True'    ${list_ten_hh}

Check product is sync success
    [Arguments]    ${ma_hh}    ${loc_search_hh}
    KV Pos Input Text    ${loc_search_hh}    ${ma_hh}
    ${search_result_ma_hh}    FNB GetLocator MHTN Tab ThucDon Auto Complete Ma Thuc Don
    Wait Until Element Is Visible    ${search_result_ma_hh}
    ${gettext}    Get Text    ${search_result_ma_hh}
    Should Be Equal As Strings    ${gettext}    ${ma_hh}

# Loan
Tim kiem va them khach hang vao don
    [Timeout]    30s
    [Arguments]    ${ma_kh}    ${use_short_key}=False
    ${ten_kh}    Get customer name by code    ${ma_kh}
    Wait Until Keyword Succeeds    5 times    0s    Check customer is sync success    ${ma_kh}    ${ten_kh}    ${use_short_key}

Tim kiem va them khach hang vao don theo SDT
    [Timeout]    30s
    [Arguments]    ${SDT}    ${use_short_key}=False
    ${ten_kh}    Get customer name by SDT    ${SDT}
    Wait Until Keyword Succeeds    5 times    0s    Check customer is sync success with SDT    ${SDT}    ${ten_kh}    ${use_short_key}

Tim kiem va them khach hang vao don theo Ten KH
    [Timeout]    30s
    [Arguments]    ${TenKH}    ${use_short_key}=False
    Wait Until Keyword Succeeds    5 times    0s    Check customer is sync success with Ten KH    ${TenKH}    ${use_short_key}

Check customer is sync success
    [Arguments]    ${ma_kh}    ${ten_kh}    ${use_short_key}=False
    Run Keyword If    '${use_short_key}'=='True'     Search customer with short key    ${ma_kh}
    ...    ELSE IF    '${use_short_key}'=='False'    FNB MHTN TabOrder Textbox Search KH    ${ma_kh}
    ${loc_autocomplete}    Format String    ${autocomplete_locator}    ${ma_kh}
    Sleep    1s
    KV Click Element JS    ${loc_autocomplete}
    FNB WaitVisible MHTN TabOrder Ten KH Dang Chon    ${ten_kh}

Check customer is sync success with SDT
    [Arguments]    ${SDT}    ${ten_kh}    ${use_short_key}=False
    Run Keyword If    '${use_short_key}'=='True'     Search customer with short key    ${SDT}
    ...    ELSE IF    '${use_short_key}'=='False'    FNB MHTN TabOrder Textbox Search KH    ${SDT}
    ${loc_autocomplete}    Format String    ${autocomplete_locator}    ${SDT}
    Sleep    1s
    KV Click Element JS    ${loc_autocomplete}
    FNB WaitVisible MHTN TabOrder Ten KH Dang Chon    ${ten_kh}

Check customer is sync success with Ten KH
    [Arguments]    ${ten_kh}    ${use_short_key}=False
    Run Keyword If    '${use_short_key}'=='True'     Search customer with short key    ${ten_kh}
    ...    ELSE IF    '${use_short_key}'=='False'    FNB MHTN TabOrder Textbox Search KH    ${ten_kh}
    ${loc_autocomplete}    Format String    ${autocomplete_locator}    ${ten_kh}
    Sleep    1s
    KV Click Element JS    ${loc_autocomplete}
    FNB WaitVisible MHTN TabOrder Ten KH Dang Chon    ${ten_kh}

Search customer with short key
    [Arguments]    ${ma_kh}
    ${loc_ma_kh}    FNB GetLocator MHTN TabOrder Textbox Search KH
    Press Keys    None    ${F4_KEY}
    Element Should Be Focused    ${loc_ma_kh}
    KV Pos Input Text    ${loc_ma_kh}    ${ma_kh}

Tim kiem va chon doi tac giao hang
    [Arguments]    ${ma_dtgh}
    ${ten_dtgh}    Get delivery name by code    ${ma_dtgh}
    Wait Until Keyword Succeeds    5 times    0s    Check delivery is sync success    ${ma_dtgh}    ${ten_dtgh}

Check delivery is sync success
    [Arguments]    ${ma_dtgh}    ${ten_dtgh}
    FNB MHTN TabOrder Texbox Tim Doi Tac GH    ${ma_dtgh}
    FNB WaitVisible MHTN TabOrder Cell Item Ten DTGH    ${ten_dtgh}
    Press Keys    None    ${ENTER_KEY}
    FNB WaitVisible MHTN TabOrder Text Ten DTGH Da Chon    ${ten_dtgh}

OFF tu dong in hoa don
    FNB WaitNotVisible MHTN Header Icon Cai Dat In Disable
    FNB MHTN Header Icon Cai Dat In
    FNB MHTN Header Toogle OFF Tu Dong In
    Sleep    1s
    FNB MHTN Header Button Xong

ON tu dong in hoa don
    FNB MHTN Header Icon Cai Dat In
    FNB MHTN Header Toogle ON Tu Dong In
    Sleep    1s
    FNB MHTN Header Button Xong

Them moi khach hang tu MHTN
    [Arguments]    ${ma_kh}   ${ten_kh}   ${sdt}    ${dia_chi}
    FNB MHTN TabOrder Button Them KH
    FNB Popup Them KH Textbox Ma KH    ${ma_kh}
    FNB Popup Them KH Textbox Ten KH    ${ten_kh}
    FNB Popup Them KH Textbox SDT    ${sdt}
    FNB Popup Them KH Textbox Dia Chi    ${dia_chi}
    FNB Popup Them KH Button Luu
    Update info success validation
    FNB WaitVisible MHTN TabOrder Ten KH Dang Chon    ${ten_kh}

Close popup preview print
    Select Window    NEW
    Execute Javascript    return document.querySelector('print-preview-app').shadowRoot.querySelector('print-preview-sidebar').shadowRoot.querySelector('print-preview-button-strip').shadowRoot.querySelector('cr-button.cancel-button').click();
    Sleep    0.5s
    Select Window    MAIN

Thay doi so luong mon tren don
    [Arguments]    ${list_ten_hh}    ${list_sl}
    ${loc_button_xong}    FNB GetLocator MHTN TabOrder Button Xong Edit SL Mon
    FOR    ${ten_hh}    ${sl}    IN ZIP    ${list_ten_hh}    ${list_sl}
        Continue For Loop If    '${sl}'=='${EMPTY}'
        FNB MHTN TabOrder Button SL Mon    ${ten_hh}
        FNB MHTN TabOrder Textbox Edit SL Mon    ${sl}
        FNB MHTN TabOrder Button Xong Edit SL Mon
        Wait Until Element Is Not Visible    ${loc_button_xong}
        ${loc_bt}    FNB GetLocator MHTN TabOrder Button Chac Chan
        ${is_check}    Run Keyword And Return Status    KV Wait Until Element Is Visible    ${loc_bt}   1s
        Run Keyword If    "${is_check}"=="True"    FNB MHTN TabOrder Button Chac Chan
        ${loc_sl}    FNB GetLocator MHTN TabOrder Button SL Mon    ${ten_hh}
        Sleep    2s
        Wait Until Element Is Visible    ${loc_sl}
        ${gettext_SL}    Get Text    ${loc_sl}
        KV Should Be Equal As Numbers    ${gettext_SL}    ${sl}    msg=Sai số lượng hàng hóa
    END

Nhap so luong mon can tra
    [Arguments]    ${list_ten_hh}    ${list_sl_tra}
    FOR    ${ten_hh}    ${sl_tra}    IN ZIP    ${list_ten_hh}    ${list_sl_tra}
        Continue For Loop If    '${sl_tra}'=='${EMPTY}'
        FNB MHTN TabOrder Textbox SL Tra Mon    ${ten_hh}    ${sl_tra}
    END

Chon mon them cho hang hoa su dung topping va assert UI
    [Arguments]    ${ma_hh}    ${ten_hh}    ${dict_ma_topping}
    FNB WaitVisible MHTN TabOrder Title Ghi Chu Mon Them
    ${list_ma_topping}    Get Dictionary Keys     ${dict_ma_topping}
    ${list_sl_topping}    Get Dictionary Values   ${dict_ma_topping}
    ${list_ten_topping}    Get list product name by code    ${list_ma_topping}
    ${dict_ten_topping}    Create Dictionary
    FOR    ${ten_topping}    ${sl_topping}    IN ZIP    ${list_ten_topping}    ${list_sl_topping}
        FNB MHTN TabOrder Textbox SL Topping    ${ten_topping}    ${sl_topping}
        Set To Dictionary    ${dict_ten_topping}    ${ten_topping}    ${sl_topping}
    END
    FNB MHTN TabOrder Button Xong Nhap Ghi Chu
    FNB WaitNotVisible MHTN TabOrder Title Ghi Chu Mon Them
    # Assert topping da chon tren UI
    ${dict_topping_UI}    Get dict topping da chon tren UI    ${ten_hh}
    KV Dictionaries Should Be Equal    ${dict_ten_topping}    ${dict_topping_UI}    msg=Hiển thị sai topping đã chọn trên UI

Get dict topping da chon tren UI
    [Arguments]    ${ten_hh}
    ${dict_topping_UI}    Create Dictionary
    FOR    ${index}    IN RANGE    1    10
        ${loc_note_T}    FNB GetLocator MHTN TabOrder Text Mon Them Da Chon    ${ten_hh}    ${index}
        ${is_exist}    Run Keyword And Return Status    Page Should Contain Element    ${loc_note_T}
        Exit For Loop If    '${is_exist}'=='False'
        Wait Until Element Is Visible    ${loc_note_T}
        ${gettext_ten_T}    Get Text    ${loc_note_T}
        ${list_char}    Split String    ${gettext_ten_T}    max_split=2
        ${text_ten_T}    Remove String    ${list_char[2]}    ${SPACE},
        ${text_sl_T}    Set Variable    ${list_char[1]}
        Set To Dictionary    ${dict_topping_UI}    ${text_ten_T}    ${text_sl_T}
    END
    Return From Keyword    ${dict_topping_UI}

Lay danh sach ten hang hoa tren UI
    ${list_ten}    Create List
    FOR    ${index}    IN RANGE    1    20
        ${loc_item}    FNB GetLocator MHTN TabOrder Item Ten Hang Hoa    ${index}
        ${is_exist}    Run Keyword And Return Status    Page Should Contain Element    ${loc_item}
        Exit For Loop If    '${is_exist}'=='False'
        Wait Until Element Is Visible    ${loc_item}
        ${get_ten_hh}    Get Text    ${loc_item}
        Append To List    ${list_ten}    ${get_ten_hh}
    END
    Return From Keyword    ${list_ten}

Assert mau sac và SL tra cua hang hoa sau khi tra 1 phan
    [Arguments]    ${list_ten_hh}    ${list_sl_tra}
    FOR    ${ten_hh}    ${sl_tra}    IN ZIP    ${list_ten_hh}    ${list_sl_tra}
        Continue For Loop If    '${sl_tra}'=='${EMPTY}'
        FNB WaitVisible MHTN TabOrder Text Ten HH Tra 1 Phan    ${ten_hh}
        Assert so luong mon da tra tren UI    ${ten_hh}    ${sl_tra}
    END

Assert mau sac và SL tra cua hang hoa sau khi tra het
    [Arguments]    ${list_ten_hh}    ${list_sl}
    FOR    ${ten_hh}    ${sl_tra}    IN ZIP    ${list_ten_hh}    ${list_sl}
        Continue For Loop If    '${sl_tra}'=='${EMPTY}'
        FNB WaitVisible MHTN TabOrder Text Ten HH Tra Het    ${ten_hh}
        Assert so luong mon da tra tren UI    ${ten_hh}    ${sl_tra}
    END

Assert so luong mon da tra tren UI
    [Arguments]    ${ten_hh}    ${sl_tra}
    ${loc_sl_da_tra}    FNB GetLocator MHTN TabOrder Text SL Mon Da Tra    ${ten_hh}
    Wait Until Element Is Visible    ${loc_sl_da_tra}
    ${text_SL_da_tra}    Get Text    ${loc_sl_da_tra}
    ${text_SL_da_tra}    Remove String    ${text_SL_da_tra}    /
    ${text_SL_da_tra}    Convert To Number    ${text_SL_da_tra}
    KV Should Be Equal As Numbers    ${sl_tra}    ${text_SL_da_tra}    msg=Hiển thị sai số lượng đã trả trên UI

#hanh
Input search va get thong tin seach hang hoa man hinh thu ngan
    [Arguments]    ${list_ma_hh}
    ${type_list_ma_hh}    Evaluate    type($list_ma_hh).__name__
    ${list_ma_hh}    Run Keyword If    '${type_list_ma_hh}'=='list'    Set Variable    ${list_ma_hh}    ELSE    Create List    ${list_ma_hh}
    ${list_ten_hang}    Create List
    ${list_gia_ban}     Create List
    ${list_sl_ton}      Create List
    ${loc_search_hh}    FNB GetLocator MHTN Header Textbox Search Thuc Don
    FOR    ${ma_hh}    IN    @{list_ma_hh}
        Wait Until Keyword Succeeds    10 times    0s    Check product is sync success    ${ma_hh}     ${loc_search_hh}
        #get thông tin tên, số lượng tồn, giá của hàng hóa
        ${loc_ten_hang}    FNB GetLocator MHTN Tab ThucDon Auto Complete Ten Thuc Don
        ${ten_hang}    Get Text    ${loc_ten_hang}
        ${loc_gia_ban}    FNB GetLocator MHTN Tab ThucDon Auto Complete Gia
        ${gia_ban}    Convert text to number frm locator    ${loc_gia_ban}
        ${loc_sl_ton}    FNB GetLocator MHTN Tab ThucDon Auto Complete Ton
        ${sl_ton}    Convert text to number frm locator    ${loc_sl_ton}
        Append To List    ${list_ten_hang}    ${ten_hang}
        Append To List    ${list_gia_ban}     ${gia_ban}
        Append To List    ${list_sl_ton}      ${sl_ton}
        Press Keys    None    ${ENTER_KEY}
    END
    Return From Keyword   ${list_ten_hang}    ${list_gia_ban}    ${list_sl_ton}

Tim kiem va chon phong ban bang phim tat
    [Arguments]    ${table}
    Sleep    2s
    Press Keys    None    ${F2_KEY}
    ${lo_seach_pb}    FNB GetLocator MHTN Header Textbox Search Phong Ban
    Element Should Be Focused    ${lo_seach_pb}
    FNB MHTN Header Textbox Search Phong Ban    ${table}
    Set Selenium Speed    ${SELENIUM_SPEED}

Tim kiem va chon hang hoa bang phim tat
    [Arguments]    ${list_pr_code}
    Sleep    2s
    ${loc_search_hh}    FNB GetLocator MHTN Header Textbox Search Thuc Don
    Press Keys    None    ${F3_KEY}
    Element Should Be Focused    ${loc_search_hh}
    FOR    ${pr_code}    IN ZIP    ${list_pr_code}
        Wait Until Keyword Succeeds    10 times    0s    Check product is sync success    ${pr_code}     ${loc_search_hh}
        Press Keys    None    ${ENTER_KEY}
    END

Them nhanh doi tac giao hang
    [Arguments]    ${ma_dtgh}    ${ten_dtgh}
    FNB MHTN TabOrder Textbox Ma Doi Tac    ${ma_dtgh}
    FNB MHTN TabOrder Textbox Ten Doi Tac    ${ten_dtgh}
    FNB MHTN TabOrder Button Luu

Nhap thong tin doi tuong nhan
    [Arguments]    ${ten_nguoinhan}    ${sodienthoai}    ${diachi}    ${khuvuc}    ${phuongxa}
    FNB MHTN TabOrder Textbox Nguoi Nhan    ${ten_nguoinhan}
    FNB MHTN TabOrder Textbox So Dien Thoai    ${sodienthoai}
    FNB MHTN TabOrder Textbox Dia Chi    ${diachi}
    FNB MHTN TabOrder Textbox Khu Vuc    ${khuvuc}
    Press Keys    None    ${ENTER_KEY}
    FNB MHTN TabOrder Textbox Phuong Xa    ${phuongxa}
    Press Keys    None    ${ENTER_KEY}

Them ghi chu vao don
    [Arguments]    ${ghi_chu}
    FNB MHTN Icon Ghi Chu
    FNB MHTN PP Ghi Chu Textbox Ghi Chu Don    ${ghi_chu}
    Sleep    1s
    FNB MHTN PP Ghi Chu Button Xong

Chon kenh ban hang
    [Arguments]    ${kenh_ban}
    FNB MHTN Icon Chon Kenh Ban
    FNB MHTN Textbox Kenh Ban   ${kenh_ban}    is_autocomplete=True

Input thong tin so luong khach
    [Arguments]    ${SoLuong}
    FNB MHTN Textbox SL Khach    ${SoLuong}

Chon ban chuyen
    [Arguments]   ${loai_ban}
    FNB MHTN Header Icon Ten Phong Ban
    FNB Page Chuyen Ban Radio Loai Ban    ${loai_ban}
    FNB Page Gop Ban Button Cap Nhat

Chon chuyen ngoi tai ban sang ngoi tai ban
    [Arguments]   ${ten_ban}
    FNB MHTN Header Icon Ten Phong Ban
    FNB Page Gop Ban Textbox input PB    ${EMPTY}
    Press Keys    None    ${BACK_SPACE_KEY}
    FNB Page Gop Ban Textbox input PB    ${ten_ban}
    Press Keys    None    ${ENTER_KEY}
    FNB Page Gop Ban Button Cap Nhat

Thuc hien thanh toan mot phan
    [Arguments]    ${list_name}    ${list_sl}
    FOR    ${name_pr}    ${so_luong}    IN ZIP    ${list_name}    ${list_sl}
        FNB MH Thanh Toan Button Edit So Luong    ${name_pr}
        FNB MH Thanh Toan Button Input So Luong    ${so_luong}
        FNB MH Thanh Toan Button xong
    END

Nhap so luong hang topping
    [Arguments]     ${list_name_topping}    ${list_sl_topping}
    FOR    ${name_topping}    ${sl_topping}    IN ZIP    ${list_name_topping}    ${list_sl_topping}
        FNB Popup MT Textbox So Luong Mon Them    ${name_topping}    ${sl_topping}
    END
    FNB Popup MT Button Xong



# Assert thông tin hàng hóa giữa API và thông tin trên màn hình thu ngân
Input search va assert thong tin hang hoa man hinh thu ngan
    [Arguments]    ${input_list_ma_hang}    ${input_list_ten_hang}    ${input_list_gia_ban}    ${input_list_sl_ton}
    ${list_ten_hang}    ${list_gia_ban}    ${list_sl_ton}    Input search va get thong tin seach hang hoa man hinh thu ngan    ${input_list_ma_hang}
    KV Lists Should Be Equal    ${input_list_ten_hang}    ${list_ten_hang}    msg=Lỗi sai danh sách tên hàng hóa
    KV Lists Should Be Equal    ${input_list_gia_ban}     ${list_gia_ban}     msg=Lỗi sai danh sách giá bán
    KV Lists Should Be Equal    ${input_list_sl_ton}      ${list_sl_ton}      msg=Lỗi sai danh sách số lượng tồn

Get ma don order man hinh thu ngan
    ${lo_ma_order}    FNB GetLocator MHTN Tab ThucDon Label Ma Don Order
    ${ma_don_order}    Get Text    ${lo_ma_order}
    ${ma_don_order}    Strip String   ${ma_don_order}
    Return From Keyword    ${ma_don_order}

Get list ten hang hoa man hinh thu ngan
    [Arguments]    ${length_check}
    ${lo_list_name}    FNB GetLocator MHTN TabOrder List Ten Hang Hoa
    ${status}    Set Variable    False
    FOR    ${index}    IN RANGE     1000
        ${count}    Get Element Count    ${lo_list_name}
        ${status}    Run Keyword And Return Status    Should Be Equal As Integers    ${count}    ${length_check}    Lỗi sai số lượng món add vào đơn
        ${index}    Evaluate    ${index}+1
        Exit For Loop If    '${status}'=='True'
    END
    ${list_name_hh}    Create List
    FOR    ${index}    IN RANGE    1    ${count} + 1
        ${name_hh}    Get Text    (${lo_list_name})[${index}]
        Append To List    ${list_name_hh}    ${name_hh}
    END
    Return From Keyword    ${list_name_hh}

Get list STT add hang hoa man hinh thu ngan
    ${lo_list_stt}    FNB GetLocator MHTN TabOrder List STT Add Hang Hoa
    ${count}    Get Element Count    ${lo_list_stt}
    ${list_stt_hh}    Create List
    FOR    ${index}    IN RANGE    1    ${count} + 1
        ${stt_hh}    Get Text    (${lo_list_stt})[${index}]
        ${stt_hh}    Convert To Integer    ${stt_hh}
        Append To List    ${list_stt_hh}    ${stt_hh}
    END
    Return From Keyword    ${list_stt_hh}    ${count}

Get list so luong va gia ban hang hoa man hinh thu ngan
    ${lo_list_sl}    FNB GetLocator MHTN TabOrder List SL Mon
    ${count}    Get Element Count    ${lo_list_sl}
    ${lo_list_price}    FNB GetLocator MHTN TabOrder List Gia Ban Hang Hoa
    ${list_sl_hh}    Create List
    ${list_price_hh}    Create List
    FOR    ${index}    IN RANGE    1    ${count} + 1
        ${soluong_hh}    Convert text to number frm locator    (${lo_list_sl})[${index}]
        ${price_hh}    Convert text to number frm locator    (${lo_list_price})[${index}]
        Append To List    ${list_sl_hh}    ${soluong_hh}
        Append To List    ${list_price_hh}    ${price_hh}
    END
    Return From Keyword    ${list_price_hh}    ${list_sl_hh}

Input va get list ghi chu mon man hinh thu ngan
    [Arguments]    ${list_index}    ${list_ghichu}
    ${lo_text_ghichu}    FNB GetLocator MHTN TabOrder List Text Ghi Chu Mon
    ${list_text_ghichu}    Create List
    FOR    ${index}    ${ghi_chu}    IN ZIP    ${list_index}    ${list_ghichu}
        KV Click Element JS   (${lo_text_ghichu})[${index}]
        FNB MHTN TabOrder Textbox Ghi Chu Mon    ${ghi_chu}
        FNB MHTN TabOrder Button Xong Nhap Ghi Chu
        Sleep    3s
        ${text_ghichu}    Get Text    (${lo_text_ghichu})[${index}]
        Append To List    ${list_text_ghichu}    ${text_ghichu}
    END
    Return From Keyword    ${list_text_ghichu}

Get ghi chu don man hinh thu ngan
    FNB MHTN Icon Ghi Chu
    Sleep    1s
    ${loc_ghi_chu}    FNB GetLocator MHTN PP Ghi Chu Textbox Ghi Chu Don
    ${ghi_chu}     Get Value    ${loc_ghi_chu}
    Return From Keyword    ${ghi_chu}

Chon mon huy man hinh thu ngan
    [Arguments]    ${list_pr_code_del}
    FOR    ${pr_code_del}    IN ZIP    ${list_pr_code_del}
        ${pr_del}    Get Product name by code    ${pr_code_del}
        FNB MHTN TabOrder Icon Xoa Mon    ${pr_del}
        FNB MHTN TabOrder Button Chac Chan
    END

Chon mon huy man hinh thu ngan co ly do huy mon
    [Arguments]    ${list_pr_code_del}   ${ly_do_huy_mon}
    FOR    ${pr_code_del}    IN ZIP    ${list_pr_code_del}
        ${pr_del}    Get Product name by code    ${pr_code_del}
        FNB MHTN TabOrder Icon Xoa Mon    ${pr_del}
        FNB MHTN TabOrder Dropdown ly do huy mon   Khác   is_wait_visible=True
        FNB MHTN TabOrder ly do huy mon    ${ly_do_huy_mon}
        FNB MHTN TabOrder Button Chac Chan
    END

Edit gia ban hang hoa trong don
    [Arguments]    ${list_price_edit}    ${list_pr_code_edit}
    FOR    ${pr_code_edit}    ${price_edit}    IN ZIP    ${list_pr_code_edit}    ${list_price_edit}
        ${pr_name}    Get Product name by code    ${pr_code_edit}
        FNB MHTN TabOrder Button Gia Ban    ${pr_name}
        FNB MHTN TabOrder Textbox Gia Moi    ${price_edit}
        FNB MHTN TabOrder Button Xong
    END

ON OFF tu dong in hoa don bang phim tat
    Press Keys    None    CTRL+ALT

Chon danh sach ban gop
    [Arguments]    ${list_table_gop}
    FNB MHTN Header Icon Ten Phong Ban
    FOR    ${table_gop}    IN ZIP    ${list_table_gop}
        FNB Page Gop Ban Textbox input PB    ${table_gop}    False
        Press Keys    None    ${ENTER_KEY}
    END
    FNB Page Gop Ban Button Cap Nhat

Assert icon popup gop ban
    [Arguments]    ${list_table_gop}
    FNB WaitVisible MHTN Header Icon Gop Ban Tab Order
    FNB MHTN Header Icon Ten Phong Ban
    Sleep    1s
    ${list_ban}    Create List
    ${list_loc}    FNB GetLocator Page Gop Ban List Ban Gop
    ${count}    Get Element Count    ${list_loc}

    FOR    ${index}    IN RANGE    1    ${count} + 1
        ${name_ban}    Get Text    (${list_loc})[${index}]
        Append To List    ${list_ban}    ${name_ban}
    END
    FNB Page Gop Ban Button Cap Nhat
    KV Lists Should Be Equal    ${list_table_gop}    ${list_ban}    msg=Sai danh sách list bàn gộp

Assert icon popup bo gop tat ca cac ban
    [Arguments]    ${list_table_gop}
    FNB WaitNotVisible MHTN Header Icon Gop Ban Tab Order
    FNB MHTN Header Icon Ten Phong Ban
    Sleep    1s
    ${list_ban}    Create List
    ${list_loc}    FNB GetLocator Page Gop Ban List Ban Gop
    ${count}    Get Element Count    ${list_loc}

    FOR    ${index}    IN RANGE    1    ${count} + 1
        ${name_ban}    Get Text    (${list_loc})[${index}]
        Append To List    ${list_ban}    ${name_ban}
    END
    FNB Page Gop Ban Button Cap Nhat
    KV Lists Should Be Equal    ${list_table_gop}    ${list_ban}    msg=Sai danh sách list bàn gộp

Chon ban bo gop
    [Arguments]    ${list_bo_gop}
    FNB MHTN Header Icon Ten Phong Ban
    FNB Page Gop Ban Textbox input PB    ${EMPTY}
    FOR   ${ban_bogop}   IN ZIP    ${list_bo_gop}
          Press Keys    None    ${BACK_SPACE_KEY}
    END
    FNB Page Gop Ban Button Cap Nhat

Thuc hien tach don sang ban moi
    [Arguments]    ${table_new}    ${list_pr}    ${list_sl}
    FNB MHTN TabOrder Button Tach Ghep Don
    FNB Page Tach Don Radio Tach Don
    ${loc_chon_pb}   FNB GetLocator Page Tach Don Cell Ban Tach Don    ${table_new}
    FNB Page Tach Don DropDown Tach Don    ${loc_chon_pb}
    FOR    ${name_pr}    ${so_luong}    IN ZIP    ${list_pr}    ${list_sl}
        FNB Page Tach Don Textbox SL Tach    ${name_pr}
        FNB Page Tach Don Popup Input SL    ${so_luong}
        FNB Page Tach Don Button Xong
    END
    FNB Page Ghep Don Button Thuc Hien

Thuc hien tach don sang don co san
    [Arguments]    ${info_don_new}    ${list_pr}    ${list_sl}
    FNB MHTN TabOrder Button Tach Ghep Don
    FNB Page Tach Don Radio Tach Don
    ${loc_don_new}   FNB GetLocator Page Tach Don Cell Don Moi    ${info_don_new}
    FNB Page Tach Don DropDown Chon Ban    ${loc_don_new}
    FOR    ${name_pr}    ${so_luong}    IN ZIP    ${list_pr}    ${list_sl}
        FNB Page Tach Don Textbox SL Tach    ${name_pr}
        FNB Page Tach Don Popup Input SL    ${so_luong}
        FNB Page Tach Don Button Xong
    END
    FNB Page Ghep Don Button Thuc Hien

Get thong tin tong tien hang va giam gia tren UI
    ${loc_tong_tienhang}    FNB GetLocator MH Thanh Toan Textbox Tong Tien Hang
    ${loc_giamgia}    FNB GetLocator MH Thanh Toan Button Giam Gia Don
    ${tong_tien_hang}    Convert text to number frm locator    ${loc_tong_tienhang}
    ${giam_gia}    Convert text to number frm locator    ${loc_giamgia}
    Return From Keyword    ${tong_tien_hang}    ${giam_gia}


#....................................Assert dữ liệu ..............................................................

Assert so luong hang hoa trong api va so luong tren man hinh thu ngan
    [Arguments]    ${sl_mhtn}
    ${soluong_mahang}    Get tong so ma hang
    KV Should Be Equal As Numbers    ${soluong_mahang}    ${sl_mhtn}    msg=Lỗi hiển thị sai số lượng hàng hóa trên màn hình thu ngân

Assert ten hang hoa don order tren man hinh thu ngan
    [Arguments]    ${input_list_ten_hang}
    ${length_check}    Get Length    ${input_list_ten_hang}
    ${list_name_order}    Get list ten hang hoa man hinh thu ngan    ${length_check}
    KV Lists Should Be Equal    ${list_name_order}   ${input_list_ten_hang}    msg=Lỗi add sai hàng hóa vào đơn order

Assert so luong va gia hang hoa don order tren man hinh thu ngan
    [Arguments]    ${input_list_so_luong}    ${input_list_gia_ban}
    ${list_gia_ban}    ${list_so_luong}    Get list so luong va gia ban hang hoa man hinh thu ngan
    KV Lists Should Be Equal    ${list_gia_ban}     ${input_list_gia_ban}     msg=Lỗi add sai giá bán hàng hóa vào đơn order
    KV Lists Should Be Equal    ${list_so_luong}    ${input_list_so_luong}    msg=Lỗi add sai số lượng hàng hóa vào đơn order

Assert gia hang hoa don order tren man hinh thu ngan
    [Arguments]    ${list_price_hh}
    ${list_price_order}    ${list_soluong_order}    Get list so luong va gia ban hang hoa man hinh thu ngan
    KV Lists Should Be Equal    ${list_price_order}   ${list_price_hh}    msg=Lỗi sai giá bán hàng hóa đơn order

Assert stt add hang hoa vao don order tren man hinh thu ngan
    ${list_stt_order}    ${count}    Get list STT add hang hoa man hinh thu ngan
    ${list_stt_hh}    Evaluate    list(range(1,$count+1))
    KV Lists Should Be Equal    ${list_stt_order}   ${list_stt_hh}    msg=Lỗi sai stt add hàng hóa vào đơn order

Assert thong tin nguoi nhan tren UI
    [Arguments]    ${cus_name}    ${cus_number}    ${cus_address}
    FNB MHTN Header Linktext Khach Hang
    Sleep    1s
    ${lo_ten_kh}      FNB GetLocator Popup Them KH Textbox Ten KH
    ${ten_kh}         Get Value    ${lo_ten_kh}
    ${lo_sdt_kh}      FNB GetLocator Popup Them KH Textbox SDT
    ${sdt_kh}         Get Value    ${lo_sdt_kh}
    ${lo_dia_chi}     FNB GetLocator Popup Them KH Textbox Dia Chi
    ${dia_chi}        Get Value    ${lo_dia_chi}
    FNB Popup Them KH Button Luu
    KV Should Be Equal As Strings    ${cus_name}      ${ten_kh}      msg=Hiển thị sai Tên người nhận trên UI
    KV Should Be Equal As Strings    ${cus_number}    ${sdt_kh}      msg=Hiển thị sai SDT người nhận trên UI
    KV Should Be Equal As Strings    ${cus_address}   ${dia_chi}     msg=Hiển thị sai Địa chỉ người nhận trên UI

Assert UI list ten hang-so luong-gia ban cua hang hoa trong don
    [Arguments]    ${length_pr_order}    ${list_pr_name}    ${list_SL}    ${list_price_bg}
    ${list_name_order}    Get list ten hang hoa man hinh thu ngan    ${length_pr_order}
    ${list_price_order}    ${list_soluong_order}    Get list so luong va gia ban hang hoa man hinh thu ngan
    KV Lists Should Be Equal    ${list_pr_name}     ${list_name_order}       msg=Lỗi sai thông tin list tên hàng hóa
    KV Lists Should Be Equal    ${list_SL}          ${list_soluong_order}    msg=Lỗi sai thông tin số lượng hàng hóa
    KV Lists Should Be Equal    ${list_price_bg}    ${list_price_order}      msg=Lỗi sai thông tin giá bán hàng Hóa

Assert thong tin ten phong ban tren UI
    [Arguments]     ${ban_chuyen}
    ${loc_tenban}    FNB GetLocator MHTN Header Icon Ten Phong Ban
    ${ten_ban}      Get Text    ${loc_tenban}
    KV Should Be Equal    ${ban_chuyen}    ${ten_ban}    msg=Sai thông tin tên bàn sau khi chuyển bàn

Assert thong tin bang gia tren UI
    [Arguments]    ${ten_BG}
    ${loc_BG}    FNB GetLocator MHTN TabOrder Dropdown Bang Gia
    ${bang_gia}    Get Text    ${loc_BG}
    KV Should Be Equal    ${bang_gia}    ${ten_BG}    msg=Sai thông tin tên bảng giá sau khi chuyển bàn

Assert thong tin ghi chu don tren UI
    [Arguments]    ${ghi_chu_don}
    FNB MHTN Icon Ghi Chu
    Sleep    1s
    ${loc_ghi_chu}    FNB GetLocator MHTN PP Ghi Chu Textbox Ghi Chu Don
    ${ghi_chu}     Get Value    ${loc_ghi_chu}
    KV Should Be Equal    ${ghi_chu}    ${ghi_chu_don}    msg=Sai thông tin ghi chú sau khi chuyển bàn
    FNB MHTN PP Ghi Chu Button Xong

Assert thong tin kenh ban cua don tren UI
    [Arguments]    ${ten_kenhban}
    ${lo_kenhban}    FNB GetLocator MHTN Header Textbox Kenh Ban Hang
    ${kenh_ban}    Get Element Attribute    ${lo_kenhban}    title
    KV Should Be Equal    ${kenh_ban}    ${ten_kenhban}    msg=Sai thông tin tên kênh bán sau khi chuyển bàn

Assert thong tin SL khach tren UI
    [Arguments]     ${khach_order}
    ${loc_sl_khach}    FNB GetLocator MHTN Textbox SL Khach
    ${sl_khach}    Get Value    ${loc_sl_khach}
    KV Should Be Equal As Strings    ${sl_khach}    ${khach_order}    msg=Sai thông tin số lượng khách trên đơn

Assert thong tin ma hoa don tra hang
    [Arguments]    ${invoice_code}
    ${loc_invoice}    FNB GetLocator MHTN Tab Text Ma Hoa Don Tra Hang
    ${invoice}    Get Text    ${loc_invoice}
    KV Should Contain    ${invoice}    ${invoice_code}    msg=Sai thông tin mã hóa đơn trả hàng
#
# Assert so luong dat hang MHTN va trong API
#     [Arguments]    ${input_code}    ${SL_dathang_thucte}
#     FOR   ${INDEX}    IN RANGE    999
#         Log    ${INDEX}
#         ${Sl_datHang}    Get dict master product info    $.Data[?(@.Code \=\= "${input_code}")].Reserved
#         Exit For Loop if   '${Sl_datHang.Reserved[0]}' != '0'
#         Log   ${Sl_datHang.Reserved[0]}
#     END
#     KV Should Be Equal As Numbers    ${SL_dathang_thucte}    ${Sl_datHang.Reserved[0]}    msg=Hiển thị sai thông tin số lượng đặt hàng


#.................................End Assert...........................................................

Delete don order man hinh thu ngan bang UI
    ${ma_don_order}    Get ma don order man hinh thu ngan
    FNB MHTN Tab ThucDon Icon Dong Don Order    ${ma_don_order}
    FNB Popup Xac Nhan Xoa Order Button Dong Y

# Hai
Tim phong ban trong tung trang cua danh sach va bam chon
   [Arguments]    ${page_count}    ${more}    ${table_name}
   FOR    ${item}    IN RANGE    0    ${page_count}+${more}
      ${table_exist}    Run Keyword And Return Status    FNB MHTN Tab PhongBan Item Table    ${table_name}    wait_time_out=5s
      Exit For Loop If    '${table_exist}'=='True'
      ${icon_disabled}    Run Keyword And Return Status    FNB WaitVisible MHTN Tab PhongBan Icon Disabled Move Next    wait_time_out=5s
      Run Keyword If    '${icon_disabled}'!='True'    FNB MHTN Tab PhongBan Icon Move Next
      ...    ELSE    Fail    ${TEST NAME}
   END

Get page count of table list
    ${loc_count}    FNB GetLocator MHTN Tab PhongBan Count Table Per Page
    ${count_table}    Get Element Count    ${loc_count}
    ${loc_total}    FNB GetLocator MHTN Tab PhongBan Count Total Table
    ${str_total}    Get Text    ${loc_total}
    ${total_table}    Get Substring    ${str_total}    -2
    ${page_count}    ${residual}    Divide And Return Residual    ${total_table}    ${count_table}
    Return From Keyword    ${page_count}    ${residual}

Mo Popup Thanh toan thuong
    [Arguments]    ${order_code}
    FNB MHTN TabOrder Button Thanh Toan
    FNB WaitVisible MH Thanh Toan Header Title
    FNB WaitVisible MH Thanh Toan Header Ma Phieu    ${order_code}

Thuc hien thanh toan thuong
    [Arguments]    ${tien_thanh_toan}    ${phuong_thuc_tt}
    Run Keyword If    '${tien_thanh_toan}'!='Mặc định'    FNB MH Thanh Toan Textbox Khach Thanh Toan    ${tien_thanh_toan}
    FNB MH Thanh Toan RadioButton PT Thanh Toan    ${phuong_thuc_tt}
    FNB MH Thanh Toan Button Thanh Toan Don

Mo Popup Thanh toan bang phim tat
    [Arguments]    ${order_code}
    Press Keys    None    ${F9_KEY}
    FNB WaitVisible MH Thanh Toan Header Title
    FNB WaitVisible MH Thanh Toan Header Ma Phieu    ${order_code}

Thuc hien thanh toan bang phim tat
    [Arguments]    ${tien_thanh_toan}    ${phuong_thuc_tt}
    Run Keyword If    '${tien_thanh_toan}'!='Mặc định'    Input tien thanh toan bang phim tat    ${tien_thanh_toan}
    FNB MH Thanh Toan RadioButton PT Thanh Toan    ${phuong_thuc_tt}
    Press Keys    None    ${ENTER_KEY}

Input tien thanh toan bang phim tat
    [Arguments]    ${tien_thanh_toan}
    ${loc_khach_tt}    FNB GetLocator MH Thanh Toan Textbox Khach Thanh Toan
    Press Keys    None    ${F8_KEY}
    Element Should Be Focused    ${loc_khach_tt}
    FNB MH Thanh Toan Textbox Khach Thanh Toan    ${tien_thanh_toan}

Chon phuong thuc va nhap so tien thanh toan
    [Arguments]    ${list_tien_tt}    ${list_phuong_thuc_tt}
    ${type_list_tien_tt}           Evaluate    type($list_tien_tt).__name__
    ${type_list_phuong_thuc_tt}    Evaluate    type($list_phuong_thuc_tt).__name__
    ${list_tien_tt}           Run Keyword If    '${type_list_tien_tt}'=='list'           Set Variable    ${list_tien_tt}           ELSE    Create List    ${list_tien_tt}
    ${list_phuong_thuc_tt}    Run Keyword If    '${type_list_phuong_thuc_tt}'=='list'    Set Variable    ${list_phuong_thuc_tt}    ELSE    Create List    ${list_phuong_thuc_tt}
    FNB MH Thanh Toan Icon Hinh Thuc Thanh Toan
    FNB WaitVisible PP HT Thanh Toan Title Popup
    FOR    ${item_tien_tt}    ${item_phuong_thuc}    IN ZIP    ${list_tien_tt}    ${list_phuong_thuc_tt}
        FNB PP HT Thanh Toan Textbox Tien Thanh Toan    ${item_tien_tt}
        FNB PP HT Thanh Toan Button Phuong Thuc    ${item_phuong_thuc}
        Run Keyword If    '${item_phuong_thuc}'=='Thẻ' or '${item_phuong_thuc}'=='Chuyển Khoản'   Chon tai khoan nhan thanh toan    ${so_tai_khoan}
    END
    FNB PP HT Thanh Toan Button Xong Chon PT
    Assert phuong thuc da chon tren man hinh thanh toan    ${list_phuong_thuc_tt}

Assert phuong thuc da chon tren man hinh thanh toan
    [Arguments]    ${list_phuong_thuc_tt}
    ${loc_label_method}    FNB GetLocator MH Thanh Toan Label PT Thanh Toan
    ${count}    Get Element Count    ${loc_label_method}
    ${list_get_method}    Create List
    FOR    ${index}    IN RANGE    1    ${count}+1
        ${get_method}    Get Text    ${loc_label_method}\[${index}\]
        ${get_method}    Replace String    ${get_method}    ,    ${EMPTY}
        Append To List    ${list_get_method}    ${get_method}
    END
    KV Lists Should Be Equal    ${list_get_method}    ${list_phuong_thuc_tt}    msg=Lỗi sai phương thức thanh toán trên giao diện

Chon tai khoan nhan thanh toan
    [Arguments]    ${so_tai_khoan}
    ${cell_tai_khoan}    FNB GetLocator PP HT Thanh Toan Cell So Tai Khoan    ${so_tai_khoan}
    FNB PP HT Thanh Toan Button Chon Tai Khoan Nhan
    Scroll Element Into View    ${cell_tai_khoan}
    KV Click Element JS    ${cell_tai_khoan}

Lay so tien khach can tra mac dinh
    ${loc_can_tra}    FNB GetLocator MH Thanh Toan Label Tien Khach Can Tra
    ${tien_can_tra}    Convert text to string frm locator    ${loc_can_tra}
    Return From Keyword    ${tien_can_tra}

Thuc hien kiem do bang button tang giam
    [Arguments]    ${order_code}    ${list_ten_hang}
    FNB MHTN SubMenu Menu Tab Order
    FNB MHTN SubMenu Menu Item Kiem Do
    FNB WaitVisible MHTN PP Kiem Do Header Title    ${order_code}
    ${list_sl_dung}    Create List
    FOR    ${ten_hang}    IN ZIP    ${list_ten_hang}
        FNB MHTN PP Kiem Do Cell Hang Hoa    ${ten_hang}
        FNB MHTN PP Kiem Do Button Tang SL    ${ten_hang}    is_wait_visible=False
        ${loc_sl_goi}    FNB GetLocator MHTN PP Kiem Do Cell Item SL Goi    ${ten_hang}
        ${sl_goi}    Convert text to number frm locator    ${loc_sl_goi}
        ${sl_expected}    Minus    ${sl_goi}    ${1}
        ${loc_sl_dung}    FNB GetLocator MHTN PP Kiem Do Cell Item SL Dung    ${ten_hang}
        ${sl_dung}    Convert text to number frm locator    ${loc_sl_dung}
        KV Should Be Equal As Numbers    ${sl_expected}    ${sl_dung}    msg=Lỗi sai số lượng dùng trên màn hình kiểm đồ
        Append To List    ${list_sl_dung}    ${sl_dung}
    END
    Return From Keyword    ${list_sl_dung}

Thuc hien kiem do bang input so luong
    [Arguments]    ${order_code}    ${list_ten_hang}    ${list_sl_tra}
    FNB MHTN SubMenu Menu Tab Order
    FNB MHTN SubMenu Menu Item Kiem Do
    FNB WaitVisible MHTN PP Kiem Do Header Title    ${order_code}
    ${list_sl_dung}    Create List
    FOR    ${ten_hang}    ${sl_tra}    IN ZIP    ${list_ten_hang}    ${list_sl_tra}
        FNB MHTN PP Kiem Do Cell Texbox SL Tra    ${ten_hang}    ${sl_tra}
        ${loc_sl_goi}    FNB GetLocator MHTN PP Kiem Do Cell Item SL Goi    ${ten_hang}
        ${sl_goi}    Convert text to number frm locator    ${loc_sl_goi}
        ${sl_expected}    Minus    ${sl_goi}    ${sl_tra}
        ${loc_sl_dung}    FNB GetLocator MHTN PP Kiem Do Cell Item SL Dung    ${ten_hang}
        ${sl_dung}    Convert text to number frm locator    ${loc_sl_dung}
        KV Should Be Equal As Numbers    ${sl_expected}    ${sl_dung}    msg=Lỗi sai số lượng dùng trên màn hình kiểm đồ
        Append To List    ${list_sl_dung}    ${sl_dung}
    END
    Return From Keyword    ${list_sl_dung}

Assert so luong mon tren man hinh order sau khi kiem do
    [Arguments]    ${list_ten_hang}    ${list_sl_dung}
    ${list_sl_order}    Get list so luong mon tren man hinh order    ${list_ten_hang}
    KV Lists Should Be Equal    ${list_sl_dung}    ${list_sl_order}    msg=Lỗi sai số lượng món trên màn hình order

Assert so luong mon tren man hinh thanh toan sau khi kiem do
    [Arguments]    ${list_ten_hang}    ${list_sl_dung}
    ${list_sl_tt}    Get list so luong mon tren man hinh thanh toan    ${list_ten_hang}
    KV Lists Should Be Equal    ${list_sl_dung}    ${list_sl_tt}    msg=Lỗi sai số lượng món trên màn hình thanh toán

Get list so luong mon tren man hinh order
    [Arguments]    ${list_ten_hang}
    ${list_sl_order}    Create List
    FOR    ${ten_hang}    IN ZIP    ${list_ten_hang}
        ${loc_sl_order}    FNB GetLocator MHTN TabOrder Button SL Mon    ${ten_hang}
        ${sl_order}    Convert text to number frm locator    ${loc_sl_order}
        Append To List    ${list_sl_order}    ${sl_order}
    END
    Return From Keyword    ${list_sl_order}

Get list so luong mon tren man hinh thanh toan
    [Arguments]    ${list_ten_hang}
    ${list_sl_tt}    Create List
    FOR    ${ten_hang}    IN ZIP    ${list_ten_hang}
        ${loc_sl_tt}    FNB GetLocator MH Thanh Toan Cell Item SoLuong    ${ten_hang}
        ${sl_tt}    Convert text to number frm locator    ${loc_sl_tt}
        Append To List    ${list_sl_tt}    ${sl_tt}
    END
    Return From Keyword    ${list_sl_tt}

Thuc hien them thu khac
    [Arguments]    ${list_thu_khac}
    FNB MH Thanh Toan Button Thu Khac
    FNB WaitVisible PP TT Thu khac Title Popup
    ${tong_thu_khac}    Set Variable    ${0}
    FOR    ${ma_thu_khac}    IN ZIP    ${list_thu_khac}
        FNB PP TT Thu khac Item Checkbox TK    ${ma_thu_khac}
        ${loc_thu_khac}    FNB GetLocator PP TT Thu khac Button Thu Tren HD    ${ma_thu_khac}
        ${item_thu_khac}    Convert text to number frm locator    ${loc_thu_khac}
        ${tong_thu_khac}    Sum    ${tong_thu_khac}    ${item_thu_khac}
        ${loc_tong_thu}    FNB GetLocator PP TT Thu khac Label Tong Thu
        ${get_tong_thu}    Convert text to number frm locator    ${loc_tong_thu}
        KV Should Be Equal As Numbers    ${tong_thu_khac}    ${get_tong_thu}    msg=Lỗi sai tổng thu khác trên popup
    END
    FNB PP TT Thu khac Icon Close Popup
    Return From Keyword    ${tong_thu_khac}

Kiem tra thu khac da duoc tu dong add vao don
    [Arguments]    ${list_ma_thukhac}
    FNB MH Thanh Toan Button Thu Khac
    FNB WaitVisible PP TT Thu khac Title Popup
    ${tong_thu_khac}    Set Variable    ${0}
    FOR    ${ma_thukhac}    IN ZIP    ${list_ma_thukhac}
        ${loc_thu_khac}    FNB GetLocator PP TT Thu khac Button Thu Tren HD    ${ma_thu_khac}
        ${item_thu_khac}    Convert text to number frm locator    ${loc_thu_khac}
        ${tong_thu_khac}    Sum    ${tong_thu_khac}    ${item_thu_khac}
    END
    ${loc_tong_thu}    FNB GetLocator PP TT Thu khac Label Tong Thu
    ${get_tong_thu}    Convert text to number frm locator    ${loc_tong_thu}
    KV Should Be Equal As Numbers    ${tong_thu_khac}    ${get_tong_thu}    msg=Lỗi sai tổng thu khác trên popup
    Return From Keyword    ${tong_thu_khac}

Kiem tra thu khac duoc bo chon
    [Arguments]    ${list_tk_uncheck}    ${tong_thu_khac}
    # Kiểm tra uncheck thu khác
    FOR    ${ma_tk_uncheck}    IN ZIP    ${list_tk_uncheck}
        FNB PP TT Thu khac Item Checkbox TK    ${ma_tk_uncheck}
        ${loc_tk_uncheck}    FNB GetLocator PP TT Thu khac Button Thu Tren HD    ${ma_tk_uncheck}
        ${item_tk_uncheck}    Convert text to number frm locator    ${loc_tk_uncheck}
        ${tong_thu_khac}    Minus    ${tong_thu_khac}    ${item_tk_uncheck}
        ${loc_tong_thu}    FNB GetLocator PP TT Thu khac Label Tong Thu
        ${get_tong_thu}    Convert text to number frm locator    ${loc_tong_thu}
        KV Should Be Equal As Numbers    ${tong_thu_khac}    ${get_tong_thu}    msg=Lỗi sai tổng thu khác trên popup
    END

Go To Lap Phieu Thu Tu MHTN
    FNB MHTN Header Menu Bar Icon
    FNB MHTN Header Menu Bar Button Lap Phieu Thu
    FNB WaitVisible Page Lap PT Header Title

Thao tac lap phieu thu tien mat
    [Arguments]    ${ma_kh}    ${gia_tri}    ${ghi_chu}
    FNB Page Lap PT Textbox Tim Khach Hang    ${ma_kh}
    FNB Page Lap PT First Search Result KH
    FNB Page Lap PT Button Thu Tu Khach
    FNB Page Lap PT Textbox So Tien Thu    ${gia_tri}
    FNB Page Lap PT Button Nhap Xong
    FNB Page Lap PT TextArea Ghi Chu    ${ghi_chu}
    FNB Page Lap PT Button Lap Phieu

Thao tac lap phieu thu the - chuyen khoan
    [Arguments]    ${ma_kh}    ${phuong_thuc}    ${gia_tri}    ${ghi_chu}    ${so_tai_khoan}
    FNB Page Lap PT Textbox Tim Khach Hang    ${ma_kh}
    FNB Page Lap PT First Search Result KH
    FNB Page Lap PT Button Thu Tu Khach
    FNB Page Lap PT Textbox So Tien Thu    ${gia_tri}
    FNB Page Lap PT Button Nhap Xong
    Chon Phuong Thuc TT    ${phuong_thuc}    ${so_tai_khoan}
    FNB Page Lap PT TextArea Ghi Chu    ${ghi_chu}
    FNB Page Lap PT Button Lap Phieu

Chon Phuong Thuc TT
    [Arguments]    ${phuong_thuc}    ${so_tai_khoan}
    FNB Page Lap PT Button PTTT Icon
    Run Keyword If    '${phuong_thuc}'=='Card'    FNB Page Lap PT Button PTTT The
    ...    ELSE IF    '${phuong_thuc}'=='Transfer'    FNB Page Lap PT Button PTTT Chuyen Khoan
    Chon tai khoan nhan thanh toan    ${so_tai_khoan}
    FNB Page Lap PT Button PTTT Xong

Thao tac huy don hang
    [Arguments]    ${order_code}
    FNB MHTN Header Icon Close Tab
    FNB WaitVisible MHTN Header Popup Huy Don Hang Title    ${order_code}
    FNB MHTN Header Popup Huy Don Hang DongY

Go to ghep don
    [Arguments]    ${order_code}
    FNB MHTN TabOrder Button Tach Ghep Don
    FNB WaitVisible Page Ghep Don Header Title    ${order_code}

Chon don ghep den
    [Arguments]    ${table_ghep}
    ${loc_item_ban}    FNB GetLocator Page Ghep Don Item Ban Ghep Don    ${table_ghep}
    FNB Page Ghep Don DropDown Ghep Den    ${loc_item_ban}
    FNB Page Ghep Don Checkbox Don Ghep Den
    FNB Page Ghep Don Button Thuc Hien

Kiem tra thong tin lich su bao bep
    [Arguments]    ${list_info_hhbb}
    Sleep    1s
    FNB MHTN Tab ThucDon Button Lich Su
    ${loc_hh}    FNB GetLocator Page LSBB List Fist Item Hang Hoa LSBB
    ${count}    Get Element Count    ${loc_hh}
    ${list_info_hh}    Create List
    FOR    ${index}    IN RANGE    1    ${count}+ 1
        ${info_hh}    Get Text    (${loc_hh})\[${index}\]
        Append To List    ${list_info_hh}    ${info_hh}
    END
    KV Lists Should Be Equal    ${list_info_hhbb}   ${list_info_hh}    msg=Sai thông tin list hàng hóa lịch sử báo bếp
    FNB Page LSBB Button Dong LSBB

Go to page tra hang tren MHTN
    FNB MHTN Header Menu Bar Icon
    FNB MHTN Header Menu Bar Button Chon Tra Hang

Chon hoa don tra hang
    [Arguments]     ${invoice_code}
    FNB Page Tra Hang Input Search Hoa Don    ${invoice_code}
    FNB Page Tra Hang First Button Chon

Get thong tin hang hoa tra Hang 1 phan
    Sleep    5s
    ${list_pr_name}     Create List
    ${list_pr_sl}       Create List
    ${list_pr_price}    Create List
    ${loc_name}    FNB GetLocator Page Thanh Toan TH List Hang Hoa
    ${count}    Get Element Count    ${loc_name}
    FOR    ${index}    IN RANGE    1    ${count}+ 1
        ${pr_name}    Get Text    (${loc_name})\[${index}\]
        Append To List    ${list_pr_name}    ${pr_name}
    END
    FOR    ${pr_name}    IN ZIP   ${list_pr_name}
        ${loc_sl}    FNB GetLocator Page Thanh Toan TH List So Luong    ${pr_name}
        ${loc_price}    FNB GetLocator Page Thanh Toan TH List Gia Ban    ${pr_name}
        ${pr_sl}    Get Text    ${loc_sl}
        ${pr_sl}    Convert To Integer    ${pr_sl}
        ${pr_price}    Convert text to number frm locator    ${loc_price}
        Append To List    ${list_pr_sl}     ${pr_sl}
        Append To List    ${list_pr_price}    ${pr_price}
    END
    ${index}    Get Index From List    ${list_pr_sl}    0
    ${name_remove}     Remove From List    ${list_pr_name}     ${index}
    ${sl_remove}       Remove From List    ${list_pr_sl}       ${index}
    ${price_remove}    Remove From List    ${list_pr_price}    ${index}
    Return From Keyword    ${list_pr_name}    ${list_pr_sl}    ${list_pr_price}

Get thong tin hang hoa tra Hang het
    Sleep    5s
    ${list_pr_name}     Create List
    ${list_pr_sl}       Create List
    ${list_pr_price}    Create List
    ${loc_name}    FNB GetLocator Page Thanh Toan TH List Hang Hoa
    ${count}    Get Element Count    ${loc_name}
    FOR    ${index}    IN RANGE    1    ${count}+ 1
        ${pr_name}    Get Text    (${loc_name})\[${index}\]
        Append To List    ${list_pr_name}    ${pr_name}
    END
    FOR    ${pr_name}    IN ZIP   ${list_pr_name}
        ${loc_sl}    FNB GetLocator Page Thanh Toan TH List So Luong    ${pr_name}
        ${loc_price}    FNB GetLocator Page Thanh Toan TH List Gia Ban    ${pr_name}
        ${pr_sl}    Get Text    ${loc_sl}
        ${pr_sl}    Convert To Integer    ${pr_sl}
        ${pr_price}    Convert text to number frm locator    ${loc_price}
        Append To List    ${list_pr_sl}     ${pr_sl}
        Append To List    ${list_pr_price}    ${pr_price}
    END
    Return From Keyword    ${list_pr_name}    ${list_pr_sl}    ${list_pr_price}

Assert so don offline
    ${loc_sl_noti}    FNB GetLocator MHTN Header Badge Offline
    ${sl_noti}    Get Text    ${loc_sl_noti}
    KV Should Be Equal As Strings    ${sl_noti}    1    msg=Sai thông tin số lượng của đơn offline

Thuc hien giam gia hoa don theo %
    [Arguments]    ${giam_gia}
    FNB MH Thanh Toan Button Giam Gia Don
    FNB PP GG Thanh Toan Button GG Don %
    FNB PP GG Thanh Toan Textbox GG Don    ${giam_gia}
    Press Keys    none    ${ENTER_KEY}

Thuc hien giam gia hoa don theo VND
    [Arguments]    ${giam_gia}
    FNB MH Thanh Toan Button Giam Gia Don
    FNB PP GG Thanh Toan Button GG Don VND
    FNB PP GG Thanh Toan Textbox GG Don    ${giam_gia}
    Press Keys    none    ${ENTER_KEY}

Go to page nha bep MHTN
    FNB MHTN Header Menu Bar Icon
    FNB MHTN Header Button Nha Bep
    FNB WaitVisible Tab Cho Che Bien Title Tab Cho Che Bien
    FNB WaitNotVisible Tab Cho Che Bien Loading action

Go to page bao cao cuoi ngay MHTN
    FNB MHTN Header Menu Bar Icon
    FNB MHTN Header Button Bao Cao Cuoi Ngay
    FNB WaitVisible Popup BCCN Title Popup BCCN

Thuc hien giam gia hang hoa theo %
    [Arguments]    ${list_discount}    ${list_pr_code_discount}
    FOR    ${pr_code_discount}    ${distcount}    IN ZIP    ${list_pr_code_discount}    ${list_discount}
        ${pr_name}    Get Product name by code    ${pr_code_discount}
        FNB MHTN TabOrder Button Gia Ban    ${pr_name}
        FNB MHTN TabOrder Icon %
        FNB MHTN TabOrder Textbox Giam Gia    ${distcount}
        FNB MHTN TabOrder Button Xong
        Sleep    1s
        ${loc_giatri_discount}    FNB GetLocator MHTN Tab Gia Tri Giam Gia Hang Hoa    ${pr_name}
        ${giatri_discount}    Get Text    ${loc_giatri_discount}
        KV Should Be Equal As Strings    ${giatri_discount}    -${distcount} %    msg=Hiển thị sai thông tin giảm giá trên tab Order
    END

Thuc hien giam gia hang hoa theo VND
    [Arguments]    ${list_discount}    ${list_pr_code_discount}
    FOR    ${pr_code_discount}    ${distcount}    IN ZIP    ${list_pr_code_discount}    ${list_discount}
        ${pr_name}    Get Product name by code    ${pr_code_discount}
        FNB MHTN TabOrder Button Gia Ban    ${pr_name}
        FNB MHTN TabOrder Textbox Giam Gia    ${distcount}
        FNB MHTN TabOrder Button Xong
        Sleep    1s
        ${loc_giatri_discount}    FNB GetLocator MHTN Tab Gia Tri Giam Gia Hang Hoa    ${pr_name}
        ${giatri_discount}    Convert text to string frm locator    ${loc_giatri_discount}
        KV Should Be Equal As Strings    ${giatri_discount}    - ${distcount}    msg=Hiển thị sai thông tin giảm giá trên tab Order
    END

Assert doanh thu va thanh toan dat hang va invoice
    [Arguments]    ${doanhthu_order}    ${thanhtoan_order}    ${doanhthu_invoice}   ${thanhtoan_invoice}    ${doanhthu_return}    ${thanhtoan_return}
    ${loc_doanhthu_dathang}    FNB GetLocator Popup BCCN Text Tong Doanh Thu Dat Hang
    ${loc_thanhtoan_dathang}    FNB GetLocator Popup BCCN Text Thanh Toan Dat Hang
    ${loc_doanhthu_hoadon}    FNB GetLocator Popup BCCN Text Doanh Thu Hoa Don
    ${loc_thanhtoan_hoadon}    FNB GetLocator Popup BCCN Text Thanh Toan Hoa Don
    ${loc_doanhthu_return}    FNB GetLocator Popup BCCN Text Doanh Thu Tra hang
    ${loc_thanhtoan_return}    FNB GetLocator Popup BCCN Text Thanh Toan Tra hang

    ${doanhthu_dathang}    Convert text to string frm locator    ${loc_doanhthu_dathang}
    ${thanhtoan_dathang}    Convert text to string frm locator    ${loc_thanhtoan_dathang}
    ${doanhthu_hoadon}    Convert text to string frm locator    ${loc_doanhthu_hoadon}
    ${thanhtoan_hoadon}    Convert text to string frm locator    ${loc_thanhtoan_hoadon}
    ${doanhthu_trahang}    Convert text to string frm locator    ${loc_doanhthu_return}
    ${thanhtoan_trahang}    Convert text to string frm locator    ${loc_thanhtoan_return}

    KV Should Be Equal As Numbers    ${doanhthu_order}       ${doanhthu_dathang}      msg=Sai thông tin doanh thu đặt hàng trên báo cáo
    KV Should Be Equal As Numbers    ${thanhtoan_order}      ${thanhtoan_dathang}     msg=Sai thông tin thanh toán đặt hàng trên báo cáo
    KV Should Be Equal As Numbers    ${doanhthu_invoice}     ${doanhthu_hoadon}       msg=Sai thông tin doanh thu hóa đơn trên báo cáo
    KV Should Be Equal As Numbers    ${thanhtoan_invoice}    ${thanhtoan_hoadon}      msg=Sai thông tin thanh toán hóa đơn trên báo cáo
    KV Should Be Equal As Numbers    ${doanhthu_return}     ${doanhthu_trahang}       msg=Sai thông tin doanh thu trả hàng trên báo cáo
    KV Should Be Equal As Numbers    ${thanhtoan_return}    ${thanhtoan_trahang}      msg=Sai thông tin thanh toán trả hàng trên báo cáo
