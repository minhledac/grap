*** Settings ***
Resource          ../../api_access.robot
Resource          ../../../share/utils.robot
Library           String
Library           Collections

*** Keywords ***
# Lấy danh sách khách hàng mặc định khách hàng Đang hoạt động
Get dict all customer info frm API
    [Documentation]    is_active=True  -> ds khach hang Dang hoat dong
    ...                is_active=False -> ds khach hang Ngung hoat dong
    ...                is_active=All   -> ds khach hang Ngung hoat dong + Dang hoat dong
    [Arguments]   ${list_jsonpath}    ${is_active}=True    ${so_ban_ghi}=${EMPTY}
    ${filter_status}    Run Keyword If    '${is_active}' == 'True'     Set Variable    "IsActive=true","%24filter=IsActive+eq+true",
    ...                        ELSE IF    '${is_active}' == 'False'    Set Variable    "IsActive=false","%24filter=IsActive+eq+false",
    ...                        ELSE IF    '${is_active}' == '${EMPTY}'    Set Variable    ${EMPTY}

    ${input_dict}    Create Dictionary    so_ban_ghi=${so_ban_ghi}    filter_status=${filter_status}
    ${result_dict}    API Call From Template    /khach-hang/all_khach_hang.txt    ${input_dict}   ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get dict summary of all customer frm API
    [Documentation]    Lấy thông tin tổng chung của các khách hàng đang hoạt động
    [Arguments]    ${list_jsonpath}    ${ma_kh}=${EMPTY}
    ${input_dict}    Create Dictionary    ma_kh=${ma_kh}
    ${result_dict}    API Call From Template    /khach-hang/summary_khach_hang.txt    ${input_dict}   ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get dict all customer group info frm API
    [Arguments]    ${list_jsonpath}
    ${result_dict}    API Call From Template    /khach-hang/all_nhom_KH.txt    ${EMPTY}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get dict transaction history info frm API
    [Arguments]    ${customer_id}    ${transaction_code}    ${list_key}     ${json_path}=${EMPTY}    ${list_key_path}=$.Data[?(@.Code\=\="${transaction_code}")]
    ${list_json_path}    Get List JSONPath    ${list_key}     ${json_path}    ${list_key_path}
    ${find_dict}    Create Dictionary    customer_id=${customer_id}
    ${result_dict}    API Call From Template    /khach-hang/lichsu_ban_tra_hang.txt    ${find_dict}    ${list_json_path}
    Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get dict debt customer history info frm API
    [Arguments]    ${customer_id}    ${document_code}    ${list_key}     ${json_path}=${EMPTY}    ${list_key_path}=$.Data[?(@.Code\=\="${document_code}")]
    ${list_json_path}    Get List JSONPath    ${list_key}     ${json_path}    ${list_key_path}
    ${find_dict}    Create Dictionary    customer_id=${customer_id}
    ${result_dict}    API Call From Template    /khach-hang/no_can_thu_tu_kh.txt    ${find_dict}    ${list_json_path}
    Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get dict rewardpoint history info frm API
    [Arguments]    ${customer_id}    ${document_code}    ${list_key}     ${json_path}=${EMPTY}    ${list_key_path}=$.Data[?(@.DocumentCode\=\="${document_code}")]
    ${list_json_path}    Get List JSONPath    ${list_key}     ${json_path}    ${list_key_path}
    ${find_dict}    Create Dictionary    customer_id=${customer_id}
    ${result_dict}    API Call From Template    /khach-hang/lich_su_tich_diem.txt    ${find_dict}    ${list_json_path}
    Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get customer id by code
    [Arguments]    ${customer_code}
    ${result_dict}    Get dict all customer info frm API    $.Data[?(@.Code\=\="${customer_code}")].Id
    ${customer_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${customer_id}

Get customer name by code
    [Arguments]    ${customer_code}
    ${result_dict}    Get dict all customer info frm API    $.Data[?(@.Code\=\="${customer_code}")].Name
    ${customer_name}    Set Variable Return From Dict    ${result_dict.Name[0]}
    Return From Keyword    ${customer_name}

Get customer name by SDT
    [Arguments]    ${customer_SDT}
    ${result_dict}    Get dict all customer info frm API    $.Data[?(@.ContactNumber\=\="${customer_SDT}")].Name
    ${customer_name}    Set Variable Return From Dict    ${result_dict.Name[0]}
    Return From Keyword    ${customer_name}

Get list customer id by list code
    [Arguments]    ${list_ma_kh}
    ${result_dict}    Get dict all customer info frm API    $.Data[*].["Id","Code"]
    ${list_id}      Set Variable Return From Dict    ${result_dict.Id}
    ${list_code}    Set Variable Return From Dict    ${result_dict.Code}
    ${result_list_id}    Create List
    FOR    ${ma_kh}    IN    @{list_ma_kh}
        ${index}    Get Index From List    ${list_code}    ${ma_kh}
        Append To List    ${result_list_id}    ${list_id[${index}]}
    END
    Return From Keyword    ${result_list_id}

Get id customer group by name
    [Arguments]    ${ten_nhom_kh}
    ${result_dict}    Get dict all customer group info frm API    $.Data[?(@.Name\=\="${ten_nhom_kh}")].Id
    ${get_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${get_id}

Get list customer group id by list name
    [Arguments]    ${list_nhom_kh}
    ${result_dict}    Get dict all customer group info frm API    $.Data[*].["Id","Name"]
    ${list_id}    Set Variable Return From Dict    ${result_dict.Id}
    ${list_name}    Set Variable Return From Dict    ${result_dict.Name}
    ${result_list_group_id}    Create List
    FOR    ${nhom_kh}    IN    @{list_nhom_kh}
        ${index}    Get Index From List    ${list_name}    ${nhom_kh}
        Append To List    ${result_list_group_id}    ${list_id[${index}]}
    END
    Return From Keyword    ${result_list_group_id}

Get Name - Phone Number - Address of Customer
    [Arguments]    ${customer_code}    ${is_return_group}=False
    ${list_jsonpath}    Create List    $.Data[?(@.Code\=\="${customer_code}")].["Name","ContactNumber","Address","Groups"]
    ${result_dict}    Get dict all customer info frm API    ${list_jsonpath}
    ${name}       Set Variable Return From Dict    ${result_dict.Name[0]}
    ${phone}      Set Variable Return From Dict    ${result_dict.ContactNumber[0]}
    ${address}    Set Variable Return From Dict    ${result_dict.Address[0]}
    ${group}      Set Variable Return From Dict    ${result_dict.Groups[0]}
    Run Keyword If    '${is_return_group}'=='False'    Return From Keyword    ${name}   ${phone}    ${address}
    ...    ELSE IF    '${is_return_group}'=='True'     Return From Keyword    ${name}   ${phone}    ${address}    ${group}

Assert thong tin khach hang
    [Arguments]   ${input_ma_kh}   ${input_ten_kh}    ${input_nhom_kh}   ${input_sdt}    ${input_dia_chi}
    ${get_name}   ${get_phone}    ${get_address}    ${get_group}    Get Name - Phone Number - Address of Customer    ${input_ma_kh}    is_return_group=True
    KV Compare Scalar Values    ${input_ten_kh}    ${get_name}      msg=Sai Tên khách hàng
    Run Keyword If    '${input_nhom_kh}'!='${EMPTY}'    KV Compare Scalar Values    ${input_nhom_kh}   ${get_group}     msg=Sai Nhóm khách hàng
    KV Compare Scalar Values    ${input_sdt}       ${get_phone}     msg=Sai SĐT khách hàng
    KV Compare Scalar Values    ${input_dia_chi}   ${get_address}   msg=Sai Địa chỉ khách hàng

Assert thong tin khi them moi nhom khach hang
    [Arguments]    ${input_nhom_kh}
    ${result_dict}    Get dict all customer group info frm API    $.Data[*].Name
    ${list_grounp_name}    Set Variable Return From Dict    ${result_dict.Name}
    KV List Should Contain Value    ${list_grounp_name}    ${input_nhom_kh}    msg=Lỗi tên nhóm hàng không tồn tại trong danh sách

Assert thong tin khi xoa khach hang
    [Arguments]    ${ma_kh_delete}
    ${result_dict}    Get dict all customer info frm API    $.Data[*].Code
    ${list_ma_kh}    Set Variable Return From Dict    ${result_dict.Code}
    KV List Should Not Contain Value    ${list_ma_kh}    ${ma_kh_delete}    msg=Lỗi mã khách hàng đã xóa vẫn tồn tại trong hệ thống

Assert thong tin tong trong man hinh khach hang giua UI va API
    [Arguments]    ${text_tong_no}    ${text_tong_ban}    ${text_tong_ban_tru_tra}    ${ma_kh}=${EMPTY}
    ${result_dict}    Get dict summary of all customer frm API    $.["Debt","TotalInvoiced","TotalRevenue"]    ${ma_kh}
    KV Should Be Equal As Numbers    ${text_tong_no}            ${result_dict.Debt[0]}            msg=Hiển thị sai thông tin chung: Tổng nợ hiện tại
    KV Should Be Equal As Numbers    ${text_tong_ban}           ${result_dict.TotalInvoiced[0]}   msg=Hiển thị sai thông tin chung: Tổng bán
    KV Should Be Equal As Numbers    ${text_tong_ban_tru_tra}   ${result_dict.TotalRevenue[0]}    msg=Hiển thị sai thông tin chung: Tổng bán trừ trả hàng

# ========================== IMPORT / EXPORT KHÁCH HÀNG =============================
Get info customer after import
    [Arguments]    ${list_ma_kh}
    ${list_jsonpath}    Create List    $.Data[?(@.Id!=-1)].["CustomerType","Code","Name","SearchNumber","Address","LocationName","WardName","Organization","TaxCode","BirthDate","Gender","Comments","Email","Groups","LastTradingDate","RewardPoint","Debt","TotalPoint","TotalInvoiced","IsActive"]
    ${dict_all}    Get dict all customer info frm API    ${list_jsonpath}    is_active=${EMPTY}
    ${dict_all.SearchNumber}      Set Variable Return From Dict    ${dict_all.SearchNumber}
    ${dict_all.Address}           Set Variable Return From Dict    ${dict_all.Address}
    ${dict_all.LocationName}      Set Variable Return From Dict    ${dict_all.LocationName}
    ${dict_all.WardName}          Set Variable Return From Dict    ${dict_all.WardName}
    ${dict_all.Organization}      Set Variable Return From Dict    ${dict_all.Organization}
    ${dict_all.TaxCode}           Set Variable Return From Dict    ${dict_all.TaxCode}
    ${dict_all.BirthDate}         Set Variable Return From Dict    ${dict_all.BirthDate}
    ${dict_all.Gender}            Set Variable Return From Dict    ${dict_all.Gender}
    ${dict_all.Comments}          Set Variable Return From Dict    ${dict_all.Comments}
    ${dict_all.Email}             Set Variable Return From Dict    ${dict_all.Email}
    ${dict_all.Groups}            Set Variable Return From Dict    ${dict_all.Groups}
    ${dict_all.LastTradingDate}   Set Variable Return From Dict    ${dict_all.LastTradingDate}
    ${dict_all.RewardPoint}       Set Variable Return From Dict    ${dict_all.RewardPoint}
    ${dict_all.Debt}              Set Variable Return From Dict    ${dict_all.Debt}

    ${dict_all.BirthDate}    KV Convert DateTime To String    ${dict_all.BirthDate}    result_format=%Y-%m-%d

    ${result_dict}    Create Dictionary    loai_khach=@{EMPTY}    ma_kh=@{EMPTY}    ten_kh=@{EMPTY}       sdt=@{EMPTY}         dia_chi=@{EMPTY}    khu_vuc=@{EMPTY}
    ...    phuong_xa=@{EMPTY}    cong_ty=@{EMPTY}        ma_so_thue=@{EMPTY}        ngay_sinh=@{EMPTY}    gioi_tinh=@{EMPTY}    email=@{EMPTY}     nhom_kh=@{EMPTY}
    ...    ghi_chu=@{EMPTY}      ngay_GD_cuoi=@{EMPTY}   diem_hien_tai=@{EMPTY}     no_can_thu_hien_tai=@{EMPTY}
    ...    tong_diem=@{EMPTY}    tong_ban=@{EMPTY}       trang_thai=@{EMPTY}

    FOR    ${ma_kh}    IN    @{list_ma_kh}
        ${index}    Get Index From List    ${dict_all.Code}    ${ma_kh}
        ${gioi_tinh}    Run Keyword If    '${dict_all.Gender[${index}]}'=='False'    Set Variable    Nữ
        ...                    ELSE IF    '${dict_all.Gender[${index}]}'=='True'     Set Variable    Nam
        ...                    ELSE     Set Variable    0
        ${status}       Run Keyword If    '${dict_all.IsActive[${index}]}'=='False'    Set Variable    0
        ...                    ELSE IF    '${dict_all.IsActive[${index}]}'=='True'     Set Variable    1

        Append To List    ${result_dict.loai_khach}      ${dict_all.CustomerType[${index}]}
        Append To List    ${result_dict.ma_kh}           ${dict_all.Code[${index}]}
        Append To List    ${result_dict.ten_kh}          ${dict_all.Name[${index}]}
        Append To List    ${result_dict.sdt}             ${dict_all.SearchNumber[${index}]}
        Append To List    ${result_dict.dia_chi}         ${dict_all.Address[${index}]}
        Append To List    ${result_dict.khu_vuc}         ${dict_all.LocationName[${index}]}
        Append To List    ${result_dict.phuong_xa}       ${dict_all.WardName[${index}]}
        Append To List    ${result_dict.cong_ty}         ${dict_all.Organization[${index}]}
        Append To List    ${result_dict.ma_so_thue}      ${dict_all.TaxCode[${index}]}
        Append To List    ${result_dict.ngay_sinh}       ${dict_all.BirthDate[${index}]}
        Append To List    ${result_dict.gioi_tinh}       ${gioi_tinh}
        Append To List    ${result_dict.email}           ${dict_all.Email[${index}]}
        Append To List    ${result_dict.nhom_kh}         ${dict_all.Groups[${index}]}
        Append To List    ${result_dict.ghi_chu}         ${dict_all.Comments[${index}]}
        Append To List    ${result_dict.ngay_GD_cuoi}    ${dict_all.LastTradingDate[${index}]}
        Append To List    ${result_dict.diem_hien_tai}   ${dict_all.RewardPoint[${index}]}
        Append To List    ${result_dict.no_can_thu_hien_tai}   ${dict_all.Debt[${index}]}
        Append To List    ${result_dict.tong_diem}       ${dict_all.TotalPoint[${index}]}
        Append To List    ${result_dict.tong_ban}        ${dict_all.TotalInvoiced[${index}]}
        Append To List    ${result_dict.trang_thai}      ${status}
    END
    Return From Keyword    ${result_dict}

Get info to export all customer
    [Arguments]
    ${list_jsonpath}    Create List    $.Data[?(@.Id!=-1)].["CustomerType","BranchName","Code","Name","SearchNumber","Address","LocationName","WardName","Organization","TaxCode","BirthDate","Gender","Comments","CreatedByName","Email","Groups","CreatedDate","LastTradingDate","RewardPoint","Debt","TotalPoint","TotalInvoiced","TotalRevenue","IsActive"]
    ${dict_all}    Get dict all customer info frm API    ${list_jsonpath}
    ${dict_all.SearchNumber}      Set Variable Return From Dict    ${dict_all.SearchNumber}
    ${dict_all.Address}           Set Variable Return From Dict    ${dict_all.Address}
    ${dict_all.LocationName}      Set Variable Return From Dict    ${dict_all.LocationName}
    ${dict_all.WardName}          Set Variable Return From Dict    ${dict_all.WardName}
    ${dict_all.Organization}      Set Variable Return From Dict    ${dict_all.Organization}
    ${dict_all.TaxCode}           Set Variable Return From Dict    ${dict_all.TaxCode}
    ${dict_all.BirthDate}         Set Variable Return From Dict    ${dict_all.BirthDate}
    ${dict_all.Gender}            Set Variable Return From Dict    ${dict_all.Gender}
    ${dict_all.Comments}          Set Variable Return From Dict    ${dict_all.Comments}
    ${dict_all.Email}             Set Variable Return From Dict    ${dict_all.Email}
    ${dict_all.Groups}            Set Variable Return From Dict    ${dict_all.Groups}
    ${dict_all.LastTradingDate}   Set Variable Return From Dict    ${dict_all.LastTradingDate}
    ${dict_all.RewardPoint}       Set Variable Return From Dict    ${dict_all.RewardPoint}
    ${dict_all.Debt}              Set Variable Return From Dict    ${dict_all.Debt}

    ${dict_all.BirthDate}         KV Convert DateTime To String    ${dict_all.BirthDate}    result_format=%Y-%m-%d
    ${dict_all.CreatedDate}       KV Convert DateTime To String    ${dict_all.CreatedDate}
    ${dict_all.LastTradingDate}   KV Convert DateTime To String    ${dict_all.LastTradingDate}    result_format=%Y-%m-%d

    FOR    ${ma_kh}    IN    @{dict_all.Code}
        ${index}    Get Index From List    ${dict_all.Code}    ${ma_kh}
        ${gioi_tinh}    Run Keyword If    '${dict_all.Gender[${index}]}'=='False'    Set Variable    Nữ
        ...                    ELSE IF    '${dict_all.Gender[${index}]}'=='True'     Set Variable    Nam
        ...                    ELSE     Set Variable    0
        ${status}       Run Keyword If    '${dict_all.IsActive[${index}]}'=='False'    Set Variable    0
        ...                    ELSE IF    '${dict_all.IsActive[${index}]}'=='True'     Set Variable    1
        Set List Value    ${dict_all.Gender}    ${index}    ${gioi_tinh}
        Set List Value    ${dict_all.IsActive}    ${index}    ${status}
    END
    Return From Keyword    ${dict_all}

# Lay thong tin Xuat file chi cong no khach hang
Get info to export debit file
    [Arguments]    ${id_kh}    ${id_invoice}
    ${result_dict}    Get dict debt customer history info frm API    ${id_kh}    ${EMPTY}    ${EMPTY}    $.Data[*].["DocumentCode","DocumentType","Value","TransDate"]
    ${list_document_code}    Set Variable Return From Dict    ${result_dict.DocumentCode}
    ${list_document_type}    Set Variable Return From Dict    ${result_dict.DocumentType}
    ${list_value}            Set Variable Return From Dict    ${result_dict.Value}
    ${list_thoi_gian}        Set Variable Return From Dict    ${result_dict.TransDate}
    ${list_thoi_gian}        KV Convert DateTime To String    ${list_thoi_gian}    result_format=%d/%m/%Y %H:%M


    ${target_dict}     Create Dictionary    thoi_gian=@{EMPTY}     ma=@{EMPTY}           dien_giai=@{EMPTY}    dvt=@{EMPTY}      sl=@{EMPTY}
    ...                                     gia_ban_tra=@{EMPTY}   thanh_tien=@{EMPTY}   ghi_no=@{EMPTY}       ghi_co=@{EMPTY}

    ${list_jsonpath_hd}    Create List    $.InvoiceDetails[*].["ProductCode","ProductSName","Quantity","Price","SubTotal"]    $.InvoiceDetails[*].["Product.Unit"]
    ${list_document_code}    ${list_document_type}    ${list_value}    ${list_thoi_gian}    Reverse four lists    ${list_document_code}    ${list_document_type}    ${list_value}    ${list_thoi_gian}
    FOR    ${ma_phieu}    IN ZIP    ${list_document_code}
        ${index}      Get Index From List    ${list_document_code}   ${ma_phieu}
        ${dict_hoadon}    Run Keyword If    '${list_document_type[${index}]}'=='3'    Get dict detail invoice frm API    ${id_invoice}    ${list_jsonpath_hd}
        Run Keyword If   '${list_document_type[${index}]}'=='3'   Mix Product Data Of Invoice To Export Debit File    ${ma_phieu}    ${list_thoi_gian[${index}]}    ${target_dict}    ${dict_hoadon}    ${list_value[${index}]}
        Run Keyword If   '${list_document_type[${index}]}'=='0'   Mix Info Customer Common To Export Debit File       ${ma_phieu}    ${list_thoi_gian[${index}]}    ${target_dict}    ${list_value[${index}]}    Thanh toán
        Log Dictionary    ${target_dict}
    END
    Return From Keyword    ${target_dict}

# Thông tin tương ứng với dòng mã phiếu trong file excel
Mix Info Customer Common To Export Debit File
    [Arguments]    ${document_code}    ${thoi_gian}    ${target_dict}    ${document_value}    ${description}
    # Giá trị trong file excel là số dương nên cần convert sang số dương
    ${value}    Run Keyword If    ${document_value} > 0    Set Variable    ${document_value}    ELSE    Minus    0    ${document_value}
    Append To List    ${target_dict.thoi_gian}    ${thoi_gian}
    Append To List    ${target_dict.ma}           ${document_code}
    Append To List    ${target_dict.dien_giai}    ${description}
    Append To List    ${target_dict.dvt}          ${0}
    Append To List    ${target_dict.sl}           ${0}
    Append To List    ${target_dict.gia_ban_tra}  ${0}
    Append To List    ${target_dict.thanh_tien}   ${0}
    Run Keyword If    ${document_value} > 0    Run Keywords    Append To List    ${target_dict.ghi_no}    ${value}   AND    Append To List    ${target_dict.ghi_co}    ${0}
    ...    ELSE IF    ${document_value} < 0    Run Keywords    Append To List    ${target_dict.ghi_no}    ${0}       AND    Append To List    ${target_dict.ghi_co}    ${value}

Mix Product Data Of Invoice To Export Debit File
    [Arguments]    ${document_code}    ${thoi_gian}     ${target_dict}    ${dict_hoadon}    ${document_value}
    ${list_pr_code}      Set Variable Return From Dict    ${dict_hoadon.ProductCode}
    ${list_pr_name}      Set Variable Return From Dict    ${dict_hoadon.ProductSName}
    ${list_pr_dvt}       Set Variable Return From Dict    ${dict_hoadon.Unit}
    ${list_pr_quantity}  Set Variable Return From Dict    ${dict_hoadon.Quantity}
    ${list_pr_price}     Set Variable Return From Dict    ${dict_hoadon.Price}
    ${list_pr_subtotal}  Set Variable Return From Dict    ${dict_hoadon.SubTotal}
    Mix Info Customer Common To Export Debit File    ${document_code}    ${thoi_gian}     ${target_dict}     ${document_value}    Bán hàng
    FOR     ${code}    IN    @{list_pr_code}
        ${index}    Get Index From List    ${list_pr_code}    ${code}
        Append To List    ${target_dict.thoi_gian}     ${0}
        Append To List    ${target_dict.ma}            ${code}
        Append To List    ${target_dict.dien_giai}     ${list_pr_name[${index}]}
        Append To List    ${target_dict.dvt}           ${list_pr_dvt[${index}]}
        Append To List    ${target_dict.sl}            ${list_pr_quantity[${index}]}
        Append To List    ${target_dict.gia_ban_tra}   ${list_pr_price[${index}]}
        Append To List    ${target_dict.thanh_tien}    ${list_pr_subtotal[${index}]}
        Append To List    ${target_dict.ghi_no}        ${0}
        Append To List    ${target_dict.ghi_co}        ${0}
    END

# Lấy thông tin export Nợ cần thu từ khách
Get Info To Export Debt Of Customer
    [Arguments]    ${id_kh}
    ${result_dict}    Get dict debt customer history info frm API    ${id_kh}    ${EMPTY}    ${EMPTY}    $.Data[*].["DocumentCode","DocumentType","Value","TransDate","Balance"]
    ${result_dict.TransDate}    KV Convert DateTime To String    ${result_dict.TransDate}    result_format=%Y-%m-%d %H:%M:%S
    ${result_dict.DocumentType}    Convert DocumentType To String Of Customer    ${result_dict.DocumentType}
    Return From Keyword    ${result_dict}

Convert DocumentType To String Of Customer
    [Arguments]    ${document_type}
    ${type}     Evaluate    type($document_type).__name__
    ${list_document_type}    Run Keyword If    '${type}'=='list'    Set Variable    ${document_type}    ELSE    Create List    ${document_type}
    ${result_list}    Create List
    FOR    ${item_doc}    IN    @{list_document_type}
        ${item_str}    Run Keyword If    '${item_doc}'=='0'    Set Variable    Thanh toán
        ...                   ELSE IF    '${item_doc}'=='4'    Set Variable    Trả hàng
        ...                   ELSE IF    '${item_doc}'=='3'    Set Variable    Bán hàng
        Append To List    ${result_list}    ${item_str}
    END
    Return From Keyword    ${result_list}

# Lấy thông tin export Lịch sử bán/trả hàng
Get Info To Export Transactionhistory Of Customer
    [Arguments]    ${id_kh}
    ${result_dict}    Get dict transaction history info frm API    ${id_kh}    ${EMPTY}    ${EMPTY}    $.Data[*].["Code","TransDate","BranchName","CustomerName","SoldByUser","Total","Status","Description","DocumentType"]
    ${result_dict.Description}   Set Variable Return From Dict    ${result_dict.Description}
    ${result_dict.TransDate}     KV Convert DateTime To String    ${result_dict.TransDate}
    ${result_dict.Status}        Convert Status In Transactionhistory Of Customer    ${result_dict.Status}    ${result_dict.DocumentType}
    Remove From Dictionary    ${result_dict}    DocumentType
    Return From Keyword    ${result_dict}

Convert Status In Transactionhistory Of Customer
    [Arguments]    ${status}    ${document_type}
    ${type_status}     Evaluate    type($status).__name__
    ${type_document}   Evaluate    type($document_type).__name__
    ${list_status}          Run Keyword If    '${type_status}'=='list'     Set Variable    ${status}           ELSE    Create List    ${status}
    ${list_document_type}   Run Keyword If    '${type_document}'=='list'   Set Variable    ${document_type}    ELSE    Create List    ${document_type}
    ${result_list}    Create List
    FOR    ${item_status}    ${item_doc}    IN ZIP    ${list_status}    ${list_document_type}
        ${item_str}    Run Keyword If    '${item_status}'=='5'    Set Variable    Không giao được
        ...                   ELSE IF    '${item_status}'=='4'    Set Variable    Đang giao hàng
        ...                   ELSE IF    '${item_status}'=='3'    Set Variable    Chưa giao hàng
        ...                   ELSE IF    '${item_status}'=='1' and '${item_doc}'=='1'    Set Variable    Hoàn thành
        ...                   ELSE IF    '${item_status}'=='1' and '${item_doc}'=='6'    Set Variable    Đã trả
        Append To List    ${result_list}    ${item_str}
    END
    Return From Keyword    ${result_list}

# ========================== END IMPORT / EXPORT KHÁCH HÀNG =============================

Get all transaction code in transaction history
    [Arguments]    ${customer_id}
    ${dict_transaction}    Get dict transaction history info frm API    ${customer_id}    ${EMPTY}    ${EMPTY}    $.Data[*].Code
    ${list_transaction_code}    Set Variable    ${dict_transaction.Code}
    Return From Keyword    ${list_transaction_code}

Get transaction history info by code
    [Arguments]    ${customer_id}    ${transaction_code}
    ${dict_info}    Get dict transaction history info frm API    ${customer_id}    ${transaction_code}    ["BranchName","CustomerName","SoldByUser","Status","Total","TransDate"]

Get all document code in debt customer history
    [Arguments]    ${customer_id}
    ${dict_document}    Get dict debt customer history info frm API    ${customer_id}    ${EMPTY}    ${EMPTY}    $.Data[*].DocumentCode
    ${list_document_code}    Set Variable    ${dict_document.DocumentCode}
    Return From Keyword    ${list_document_code}

Get all document code in rewardpoint history
    [Arguments]    ${customer_id}
    ${dict_document}    Get dict rewardpoint history info frm API    ${customer_id}    ${EMPTY}    ${EMPTY}    $.Data[*].DocumentCode
    ${list_document_code}    Set Variable    ${dict_document.DocumentCode}
    Return From Keyword    ${list_document_code}

Assert transaction code not avaiable in transaction history
    [Arguments]    ${input_ma_chungtu}    ${id_khach_hang}
    ${all_trans}    Get all transaction code in transaction history    ${id_khach_hang}
    KV List Should Not Contain Value    ${all_trans}    ${input_ma_chungtu}    msg=Lỗi vẫn tồn tại mã chứng từ trong tab Lịch sử bán/trả hàng

Assert document code not avaiable in debt history
    [Arguments]    ${input_ma_chungtu}    ${id_khach_hang}
    ${all_docs}    Get all document code in debt customer history   ${id_khach_hang}
    KV List Should Not Contain Value    ${all_docs}    ${input_ma_chungtu}    msg=Lỗi vẫn tồn tại mã chứng từ trong tab Nợ cần thu từ khách

Assert document code not avaiable in rewardpoint history
    [Arguments]    ${input_ma_chungtu}    ${id_khach_hang}
    ${all_docs}    Get all document code in rewardpoint history    ${id_khach_hang}
    KV List Should Not Contain Value    ${all_docs}    ${input_ma_chungtu}    msg=Lỗi vẫn tồn tại mã chứng từ trong tab Lịch sử tích điểm

Get no hien tai cua khach hang
    [Arguments]    ${id_kh}
    ${result_dict}    Get dict all customer info frm API    $.Data[?(@.Id\=\=${id_kh})].Debt
    ${no_hien_tai}    Set Variable Return From Dict    ${result_dict.Debt[0]}
    Return From Keyword    ${no_hien_tai}

Assert phieu can bang sau khi dieu chinh cong no khach hang
    [Arguments]    ${id_kh}    ${gia_tri}
    ${result_dict}    Get dict debt customer history info frm API    ${id_kh}    ${EMPTY}    ${EMPTY}    $.Data[0].Balance
    ${get_gia_tri}    Set Variable Return From Dict    ${result_dict.Balance[0]}
    ${no_hien_tai}    Get no hien tai cua khach hang    ${id_kh}
    KV Should Be Equal As Numbers    ${gia_tri}    ${get_gia_tri}    msg=Lỗi sai giá trị điều chỉnh công nợ khách hàng
    KV Should Be Equal As Numbers    ${gia_tri}    ${no_hien_tai}    msg=Lỗi sai công nợ khách hàng sau khi điều chỉnh

Assert thong tin sau khi lap phieu thanh toan va return ma phieu thanh toan
    [Arguments]    ${id_kh}    ${gia_tri}    ${count_no_af}
    ${gia_tri}    Minus    0    ${gia_tri}
    ${get_no_hien_tai}    Get no hien tai cua khach hang    ${id_kh}
    ${result_dict}    Get dict debt customer history info frm API    ${id_kh}    ${EMPTY}    ${EMPTY}    $.Data[*].["Value","DocumentCode"]
    ${get_gia_tri}    Set Variable Return From Dict    ${result_dict.Value[0]}
    ${ma_phieu_tt}    Set Variable Return From Dict    ${result_dict.DocumentCode[0]}
    KV Should Be Equal As Numbers    ${gia_tri}        ${get_gia_tri}        msg=Lỗi sai giá trị phiếu thanh toán nợ khách hàng
    KV Should Be Equal As Numbers    ${count_no_af}    ${get_no_hien_tai}    msg=Lỗi sai nợ hiện tại của khách hàng sau khi lập phiếu thanh toán
    Return From Keyword    ${ma_phieu_tt}


#
