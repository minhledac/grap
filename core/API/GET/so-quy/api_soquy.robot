*** Settings ***
Library           Collections
Library           RequestsLibrary
Library           SeleniumLibrary
Library           OperatingSystem
Library           String
Resource          ../../../share/computation.robot
Resource          ../../api_access.robot
Resource          ../../../../config/envi.robot
Resource          ../../../share/utils.robot

*** Keywords ***
# Lay danh sach phieu thu chi theo CN dang login va mac dinh filter: thang nay, phieu da thanh toan, phuong thuc thanh toan all (cả tiền mặt và Ngân hàng)
Get dict all cashflow info
    [Documentation]    method=Cash  -> lay cac phieu thu chi theo Tab Tien mat
    ...                method=Card  -> lay cac phieu thu chi theo Tab Ngan hang
    ...                method=EMPTY -> lay cac phieu thu chi theo Tab Tong quy
    [Arguments]    ${list_jsonpath}    ${so_ban_ghi}=${EMPTY}    ${filter_time}=thismonth    ${is_da_thanhtoan}=True    ${is_da_huy}=False    ${method}=${EMPTY}
    ${filter_status}    KV Get Filter Status Cash Flow    ${is_da_thanhtoan}    ${is_da_huy}
    ${data_method}    Run Keyword If    '${method}'=='Cash'    Set Variable    +and+Method+eq+'Cash'
    ...                      ELSE IF    '${method}'=='Card'    Set Variable    +and+Method+ne+'Cash'
    ...                      ELSE IF    '${method}'=='${EMPTY}'    Set Variable    ${EMPTY}
    ${filter_data}    Set Variable    (BranchId+eq+${BRANCH_ID}+and+TransDate+eq+'${filter_time}'+and+(${filter_status})${data_method})
    ${find_dict}    Create Dictionary    so_ban_ghi=${so_ban_ghi}    filter_data=${filter_data}
    ${result_dict}    API Call From Template    /so-quy/all_so_quy.txt    ${find_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

# Filter theo status của sổ quỹ
KV Get Filter Status Cash Flow
    [Arguments]    ${is_da_thanhtoan}    ${is_da_huy}
    ${list_filter}    Create List
    Run Keyword If    '${is_da_thanhtoan}' == 'True'           Append To List    ${list_filter}    Status+eq+0
    Run Keyword If    '${is_da_huy}' == 'True'                 Append To List    ${list_filter}    Status+eq+1
    ${list_filter}     Evaluate    "+or+".join(${list_filter})
    Return From Keyword    ${list_filter}

# Lấy danh sách người nộp-nhập
Get dict all partner frm API
    [Arguments]    ${list_jsonpath}
    ${result_dict}    API Call From Template    /so-quy/all_partner.txt    ${EMPTY}     ${list_jsonpath}
    Return From Keyword    ${result_dict}

# Lấy danh sách tài khoản ngân hàng
Get dict all bank account frm API
    [Arguments]    ${list_jsonpath}
    ${result_dict}    API Call From Template    /so-quy/all_bank_account.txt    ${EMPTY}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get bank account id
    [Arguments]    ${so_tai_khoan}
    ${result_dict}    Get dict all bank account frm API    $.Data[?(@.Account\=\="${so_tai_khoan}")].Id
    ${id_account}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${id_account}

Get so tai khoan by account id
    [Arguments]    ${id_account}
    ${result_dict}    Get dict all bank account frm API    $.Data[?(@.Id\=\=${id_account})].Account
    ${so_tai_khoan}    Set Variable Return From Dict    ${result_dict.Account[0]}
    Return From Keyword    ${so_tai_khoan}

Get number of bank account
    ${result_dict}    Get dict all bank account frm API    $.Total
    ${total_bank_account}    Set Variable Return From Dict    ${result_dict.Total[0]}
    Return From Keyword    ${total_bank_account}

Get partner id by phone number
    [Arguments]    ${partner_phone}
    ${result_dict}    Get dict all partner frm API    $.Data[?(@.ContactNo\=\="${partner_phone}")].Id
    ${result_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${result_id}

Validate So quy info from Rest API if Purchase is not paid
    [Arguments]    ${input_ma_phieu}
    ${result_dict}    Get dict all cashflow info    $.Data[0].["Code"]
    KV Should Not Be Equal    ${input_ma_phieu}    ${result_dict.Code[0]}    msg=Lỗi mã phiếu có tồn tại trong sổ quỹ

Validate So quy info from Rest API if Purchase is paid
    [Arguments]    ${input_purchase_code}    ${input_amount}
    ${list_jsonpath}     Set Variable    $.Data[?(@.Code\=\="${input_purchase_code}")].["Amount","CashGroup"]
    ${result_dict}       Get dict all cashflow info    ${list_jsonpath}
    ${get_giatri_phieu}  Set Variable    ${result_dict.Amount[0]}
    ${get_loaithutien}   Set Variable    ${result_dict.CashGroup[0]}
    ${get_amount}        Minus    0    ${input_amount}
    ${result_amount}       Set Variable If    '${get_loaithutien}' == 'Tiền trả NCC'    ${get_amount}    ${input_amount}
    KV Should Be Equal As Numbers    ${get_giatri_phieu}    ${result_amount}    msg=Lỗi sai giá trị phiếu

Get status ma phieu trong so quy
    [Arguments]    ${ma_phieu}
    ${jsonpath}    Set Variable    $.Data[?(@.Code\=\="${ma_phieu}")].Status
    ${result_dict}    Get dict all cashflow info    ${jsonpath}    is_da_huy=True
    Return From Keyword    ${result_dict.Status[0]}

Get id phieu trong so quy
    [Arguments]    ${ma_phieu}
    ${jsonpath}    Set Variable    $.Data[?(@.Code\=\="${ma_phieu}")].Id
    ${result_dict}    Get dict all cashflow info    ${jsonpath}    is_da_huy=True
    Return From Keyword    ${result_dict.Id[0]}

Assert thong tin phieu thu - chi khi huy phieu
    [Documentation]    status=1 => trang thai da huy
    ...                status=0 => trang thai da thanh toan
    [Arguments]    ${ma_phieu}    ${status_ma_phieu}
    ${get_status}    Get status ma phieu trong so quy    ${ma_phieu}
    KV Should Be Equal As Integers    ${get_status}    ${status_ma_phieu}    msg=Lỗi sai trạng thái phiếu chi

Assert phieu thanh toan no trong so quy
    [Arguments]    ${ma_phieu}    ${gia_tri}
    ${result_dict}    Get dict all cashflow info    $.Data[?(@.Code\=\="${ma_phieu}")].Amount
    KV Should Be Equal As Numbers    ${gia_tri}    ${result_dict.Amount[0]}    msg=Lỗi sai giá trị phiếu thanh toán nợ đối tác trong sổ quỹ

Get all document code in cash flow
    ${result_dict}    Get dict all cashflow info    $.Data[*].Code
    ${list_document_code}    Set Variable    ${result_dict.Code}
    Return From Keyword    ${list_document_code}

Assert document code not avaiable in cash flow
    [Arguments]    ${input_ma_phieu}
    ${all_docs}    Get all document code in cash flow
    KV List Should Not Contain Value    ${all_docs}    ${input_ma_phieu}    msg=Lỗi mã phiếu vẫn tồn tại trong danh sách phiếu Đã thanh toán

Assert thong tin khi tao moi phieu thu - chi tien mat
    [Arguments]    ${ma_phieu}    ${sdt_nguoi_nop_nhan}    ${gia_tri}
    ${result_dict}    Get dict all cashflow info    $.Data[?(@.Code\=\="${ma_phieu}")].["ContactNumber","Amount","Method","Status"]
    KV Should Be Equal As Strings    ${result_dict.ContactNumber[0]}   ${sdt_nguoi_nop_nhan}   msg=Lỗi sai số điện thoại người nộp/nhận
    KV Should Be Equal As Numbers    ${result_dict.Amount[0]}          ${gia_tri}         msg=Lỗi sai giá trị phiếu
    KV Should Be Equal As Strings    ${result_dict.Method[0]}          Cash               msg=Lỗi sai phương thức phiếu
    KV Should Be Equal As Numbers    ${result_dict.Status[0]}          0                  msg=Lỗi sai trạng thái phiếu

Assert thong tin khi tao moi phieu thu - chi ngan hang
    [Arguments]    ${ma_phieu}    ${sdt_nguoi_nop_nhan}    ${gia_tri}   ${phuong_thuc}    ${so_tai_khoan}
    ${result_dict}    Get dict all cashflow info    $.Data[?(@.Code\=\="${ma_phieu}")].["ContactNumber","Amount","Method","AccountId","Status"]
    ${phuong_thuc}    Convert VI Method To EN    ${phuong_thuc}
    # loan.nt: do giá trị Account lấy từ "Get dict all cashflow info" luôn = 0 (chưa rõ nguyên nhân) nên phải lấy thông qua AccountId
    ${id_account}    Set Variable Return From Dict    ${result_dict.AccountId[0]}
    ${bank_account}    Get so tai khoan by account id    ${id_account}
    KV Should Be Equal As Strings    ${result_dict.ContactNumber[0]}   ${sdt_nguoi_nop_nhan}    msg=Lỗi sai số điện thoại người nộp/nhận
    KV Should Be Equal As Numbers    ${result_dict.Amount[0]}          ${gia_tri}          msg=Lỗi sai giá trị phiếu
    KV Should Be Equal As Strings    ${result_dict.Method[0]}          ${phuong_thuc}      msg=Lỗi sai phương thức phiếu
    KV Should Be Equal As Strings    ${bank_account}                   ${so_tai_khoan}     msg=Lỗi sai số tài khoản
    KV Should Be Equal As Numbers    ${result_dict.Status[0]}          0                   msg=Lỗi sai trạng thái phiếu

Assert thong tin update phieu thu - chi
    [Arguments]    ${ma_phieu}    ${gia_tri}    ${ghi_chu}
    ${result_dict}    Get dict all cashflow info    $.Data[?(@.Code\=\="${ma_phieu}")].["Amount","Description"]
    KV Should Be Equal As Numbers    ${result_dict.Amount[0]}        ${gia_tri}          msg=Lỗi sai giá trị phiếu
    KV Should Be Equal As Strings    ${result_dict.Description[0]}   ${ghi_chu}          msg=Lỗi sai thông tin ghi chú

# Lay ra cac thong tin de so sanh vs file excel khi xuat file
Get info to export cashFlow
    [Arguments]    ${thoi_gian}    ${method}=Cash
    ${list_jsonpath}    Create List    $.Data[*].["Code","TransDate","CashGroup","PartnerName","Amount","Method"]    $.["Total","Total1Value","Total2Value","Total3Value","Total4Value"]
    ${result_dict}    Get dict all cashflow info    ${list_jsonpath}    filter_time=${thoi_gian}    method=${method}
    ${result_dict.CashGroup}    Set Variable Return From Dict    ${result_dict.CashGroup}
    ${tong_phieu}   Set Variable Return From Dict    ${result_dict.Total[0]}
    ${tong_thu}     Set Variable Return From Dict    ${result_dict.Total1Value[0]}
    ${tong_chi}     Set Variable Return From Dict    ${result_dict.Total2Value[0]}
    ${ton_quy}      Set Variable Return From Dict    ${result_dict.Total3Value[0]}
    ${quy_dau_ky}   Set Variable Return From Dict    ${result_dict.Total4Value[0]}

    # Chuẩn hóa dữ liệu để khớp với file excel
    ${result_dict.TransDate}    KV Convert DateTime To String    ${result_dict.TransDate}
    FOR    ${code}    IN     @{result_dict.Code}
        ${index}    Get Index From List    ${result_dict.Code}    ${code}
        ${loai_thu_chi}    Run Keyword If    ${result_dict.Amount[${index}]} < 0 and '${result_dict.CashGroup[${index}]}'=='0'    Set Variable    Chi phí khác
        ...                       ELSE IF    ${result_dict.Amount[${index}]} > 0 and '${result_dict.CashGroup[${index}]}'=='0'    Set Variable    Thu nhập khác
        ...                       ELSE IF    ${result_dict.Amount[${index}]} > 0 and '${result_dict.CashGroup[${index}]}'!='0'    Set Variable    Phiếu thu ${result_dict.CashGroup[${index}]}
        ...                       ELSE IF    ${result_dict.Amount[${index}]} < 0 and '${result_dict.CashGroup[${index}]}'!='0'    Set Variable    Phiếu chi ${result_dict.CashGroup[${index}]}
        Set List Value    ${result_dict.CashGroup}    ${index}    ${loai_thu_chi}
    END
    Remove From Dictionary    ${result_dict}    Total1Value
    Remove From Dictionary    ${result_dict}    Total2Value
    Remove From Dictionary    ${result_dict}    Total3Value
    Remove From Dictionary    ${result_dict}    Total4Value
    Remove From Dictionary    ${result_dict}    Total
    Run Keyword If    '${method}'=='Cash' or '${method}'=='${EMPTY}'    Remove From Dictionary    ${result_dict}    Method

    ${dict_summary}    Create Dictionary    quy_dau_ky=@{EMPTY}    tong_thu=@{EMPTY}    tong_chi=@{EMPTY}    ton_quy=@{EMPTY}
    Append To List    ${dict_summary.quy_dau_ky}   ${quy_dau_ky}
    Append To List    ${dict_summary.tong_thu}     ${tong_thu}
    Append To List    ${dict_summary.tong_chi}     ${tong_chi}
    Append To List    ${dict_summary.ton_quy}      ${ton_quy}
    Return From Keyword    ${result_dict}    ${dict_summary}    ${tong_phieu}

# Assert thông tin phiếu thu tạo từ MHTN
Assert thong tin phieu thu trong api
    [Arguments]    ${ten_kh}    ${hinh_thuc_TT}    ${gia_tri}    ${ghi_chu}    ${account}
    ${list_jsonpath}    Create List    $.Data[0].["PartnerName","Method","Amount","Description","AccountId"]
    ${result_dict}    Get dict all cashflow info    ${list_jsonpath}    ${BRANCH_ID}    filter_time=today
    ${get_ten_kh}    Set Variable Return From Dict    ${result_dict.PartnerName[0]}
    ${get_hinh_thuc_TT}    Set Variable Return From Dict    ${result_dict.Method[0]}
    ${get_giatri}    Set Variable Return From Dict    ${result_dict.Amount[0]}
    ${get_ghi_chu}    Set Variable Return From Dict    ${result_dict.Description[0]}
    ${id_account}    Set Variable Return From Dict    ${result_dict.AccountId[0]}
    ${bank_account}    Get so tai khoan by account id    ${id_account}
    KV Should Be Equal As Strings    ${ten_kh}    ${get_ten_kh}    msg=Lưu sai thông tin tên khách hàng
    KV Should Be Equal As Strings    ${hinh_thuc_TT}    ${get_hinh_thuc_TT}    msg=Lưu sai thông tin hình thức thanh toán
    KV Should Be Equal As Numbers    ${gia_tri}    ${get_giatri}    msg=Lưu sai thông tin giá trị phiếu
    KV Should Be Equal As Strings    ${ghi_chu}    ${get_ghi_chu}    msg=Lưu sai thông tin tên ghi chú phiếu
    Run Keyword If    '${account}'!='${EMPTY}'     KV Should Be Equal As Strings    ${account}    ${bank_account}    msg=Lưu sai thông tin tên khách hàng

Assert thong tin so quy trong API va UI
    [Arguments]    ${text_quy_dauky}    ${text_tongthu}    ${text_tongchi}    ${text_tonquy}    ${method}
    ${result_dict}    Get dict all cashflow info    $.["Total1Value","Total2Value","Total3Value","Total4Value"]    method=${method}

    KV Should Be Equal As Numbers    ${text_quy_dauky}    ${result_dict.Total4Value[0]}    msg=Lưu sai thông tin quỹ đầu kỳ
    KV Should Be Equal As Numbers    ${text_tongthu}      ${result_dict.Total1Value[0]}    msg=Lưu sai thông tin tổng thu
    KV Should Be Equal As Numbers    ${text_tongchi}      ${result_dict.Total2Value[0]}    msg=Lưu sai thông tin tổng chi
    KV Should Be Equal As Numbers    ${text_tonquy}       ${result_dict.Total3Value[0]}    msg=Lưu sai thông tin tồn quỹ

Get list gia tri thanh toan trong so quy
    [Arguments]    ${list_ma_phieu}    ${method}=${EMPTY}
    ${list_giatri}    Create List
    FOR    ${ma_phieu}    IN ZIP    ${list_ma_phieu}
        ${result_dict}    Get dict all cashflow info    $.Data[?(@.Code\=\="${ma_phieu}")].Amount    method=${method}
        ${giatri}    Set Variable Return From Dict    ${result_dict.Amount[0]}
        Append To List    ${list_giatri}    ${giatri}
    END
    Return From Keyword    ${list_giatri}

Get dict info detail phieu thu chi frm API
    [Arguments]    ${id_phieu_thuchi}    ${list_jsonpath}
    ${input_dict}    Create Dictionary    id_phieu_thuchi=${id_phieu_thuchi}
    ${result_dict}    API Call From Template    /so-quy/detail_thuchi.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get gia tri cua phieu thu chi from API detail
    [Arguments]    ${id_phieu_thuchi}
    ${result_dict}    Get dict info detail phieu thu chi frm API    ${id_phieu_thuchi}    $.["Value"]
    ${gia_tri}     Set Variable Return From Dict    ${result_dict.Value[0]}
    Return From Keyword    ${gia_tri}
