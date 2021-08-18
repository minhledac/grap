*** Settings ***
Resource           ../../api_access.robot
Resource           ../../GET/so-quy/api_soquy.robot
Resource          ../../../../config/envi.robot

*** Keywords ***
Them moi nguoi nop-nhan
    [Arguments]    ${partner_name}    ${partner_phone}
    ${find_id}    Get partner id by phone number    ${partner_phone}
    ${input_dict}    Create Dictionary    ten_nguoi_nop=${partner_name}    sdt_nguoi_nop=${partner_phone}
    ${result_dict}    Run Keyword If    ${find_id} == 0    API Call From Template    /so-quy/add_partner.txt    ${input_dict}    $.Id
    ${result_id}      Run Keyword If    ${find_id} == 0    Set Variable Return From Dict    ${result_dict.Id[0]}    ELSE    Set Variable    ${find_id}
    Return From Keyword    ${result_id}

Delete nguoi nop-nhan
    [Arguments]    ${partner_id}
    ${input_dict}    Create Dictionary    id=${partner_id}
    API Call From Template    /so-quy/delete_partner.txt    ${input_dict}
#----------------
Them phieu thu chi
    [Documentation]    phuong_thuc=Cash     -> tiền mặt
    ...                phuong_thuc=Card     -> thẻ
    ...                phuong_thuc=Transfer -> chuyển khoản
    [Arguments]    ${ma_phieu}    ${id_nguoi_nop}   ${gia_tri}    ${is_phieu_thu}    ${ten_loai_thu_chi}=${EMPTY}    ${phuong_thuc}=Cash    ${id_tai_khoan}=${EMPTY}
    ${gia_tri}    Run Keyword If    '${is_phieu_thu}' == 'True'    Set Variable    ${gia_tri}    ELSE IF    '${is_phieu_thu}' == 'False'    Minus    0    ${gia_tri}
    ${loai_thu_chi}      Run Keyword If    '${ten_loai_thu_chi}'=='${EMPTY}' and '${is_phieu_thu}'=='True'    Set Variable    Tìm loại thu
    ...                         ELSE IF    '${ten_loai_thu_chi}'=='${EMPTY}' and '${is_phieu_thu}'=='False'   Set Variable    Tìm loại chi
    ...                         ELSE IF    '${ten_loai_thu_chi}'!='${EMPTY}'    Set Variable    ${ten_loai_thu_chi}

    ${data_tai_khoan}    Run Keyword If    '${phuong_thuc}' == 'Cash'    Set Variable    ${EMPTY}
    ...    ELSE IF    '${phuong_thuc}'=='Card' or '${phuong_thuc}'=='Transfer'    Set Variable   ,"AccountId": ${id_tai_khoan}

    ${input_dict}     Create Dictionary    ma_phieu=${ma_phieu}    phuong_thuc=${phuong_thuc}    id_nguoi_nop=${id_nguoi_nop}    branch_id=${BRANCH_ID}
    ...    loai_thu_chi=${loai_thu_chi}    gia_tri=${gia_tri}    data_tai_khoan=${data_tai_khoan}
    ${result_dict}    API Call From Template    /so-quy/add_phieu_thu_chi.txt    ${input_dict}    $.Id
    ${result_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${result_id}

Them moi list phieu thu chi
    [Arguments]   @{list_data}
    ${list_id}    Create List
    FOR    ${data}    IN    @{list_data}
        ${id_phieu}    Them phieu thu chi    @{data}
        Append To List    ${list_id}    ${id_phieu}
    END
    Return From Keyword    ${list_id}

Delete phieu thu chi
    [Arguments]    ${id_phieu}
    ${input_dict}    Create Dictionary    id_phieu=${id_phieu}
    Run Keyword If    ${id_phieu}!=0    API Call From Template    /so-quy/delete_phieu_thu_chi.txt    ${input_dict}

Delete list phieu thu chi
    [Arguments]    ${list_id}
    FOR    ${id_phieu}    IN     @{list_id}
        Delete phieu thu chi    ${id_phieu}
    END

# Xóa phiếu thanh toán nợ cho Khách hàng
Delete phieu thanh toan
    [Arguments]    ${ma_phieu}
    ${input_dict}    Create Dictionary    ma_phieu=${ma_phieu}
    API Call From Template    /so-quy/delete_phieu_thanh_toan.txt    ${input_dict}

# Xoá phiếu thanh toán nợ cho NCC
Delete purchase payment
    [Arguments]    ${ma_phieu}
    ${input_dict}    Create Dictionary    ma_phieu=${ma_phieu}
    API Call From Template    /so-quy/delete_purchase_payment.txt    ${input_dict}

# ------------------
Them moi tai khoan ngan hang
    [Arguments]    ${ten_tai_khoan}    ${chu_tai_khoan}   ${so_tai_khoan}   ${bank_code}    ${bank_name}    ${bank_branch_id}    ${bank_branch_name}
    ${find_id}   Get bank account id    ${so_tai_khoan}
    ${input_dict}    Create Dictionary    ten_tai_khoan=${ten_tai_khoan}    so_tai_khoan=${so_tai_khoan}    bank_code=${bank_code}    bank_branch_id=${bank_branch_id}
    ...    chu_tai_khoan=${chu_tai_khoan}    bank_name=${bank_name}    bank_branch_name=${bank_branch_name}
    ${result_dict}    Run Keyword If    ${find_id}==0    API Call From Template    /so-quy/add_bank_account.txt    ${input_dict}    $.Id
    ${result_id}      Run Keyword If    ${find_id}==0    Set Variable Return From Dict    ${result_dict.Id[0]}    ELSE    Set Variable    ${find_id}
    Return From Keyword    ${result_id}

Delete tai khoan ngan hang
    [Arguments]    ${id_tai_khoan}
    ${input_dict}    Create Dictionary    id=${id_tai_khoan}
    API Call From Template    /so-quy/delete_bank_account.txt    ${input_dict}

    #
