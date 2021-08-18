*** Settings ***
Resource          ../../api_access.robot
Resource          ../hang-hoa/api_danhmuc_hanghoa.robot
Resource          ../giao-dich/api_nhaphang.robot
Resource          ../../../share/computation.robot
Library           String
Library           Collections

*** Keywords ***
# Lấy dict danh sách NCC mặc định filter mặc định: All Trạng thái
Get dict all supplier info frm API
    [Documentation]    is_active=All   => get all trạng thái
    ...                is_active=True  => get NCC với trạng thái Đang hoạt động
    ...                is_active=False => get NCC với trạng thái Ngừng hoạt động
    [Arguments]    ${list_jsonpath}    ${so_ban_ghi}=${EMPTY}    ${is_active}=All
    ${data_filter}    KV Get Filter Status Supplier    ${is_active}
    ${find_dict}      Create Dictionary    so_ban_ghi=${so_ban_ghi}    data_filter=${data_filter}
    ${result_dict}    API Call From Template    /nha-cung-cap/all_nha_cung_cap.txt    ${find_dict}     ${list_jsonpath}
    Return From Keyword    ${result_dict}

KV Get Filter Status Supplier
    [Arguments]    ${is_active}
    ${data_filter}    Run Keyword If    '${is_active}'=='True'    Set Variable    ,"%24filter=isActive+eq+true"
    ...                      ELSE IF    '${is_active}'=='False'   Set Variable    ,"%24filter=isActive+eq+false"
    ...                      ELSE IF    '${is_active}'=='All'     Set Variable    ${EMPTY}
    Return From Keyword    ${data_filter}

Get dict supplier debt info frm API
    [Arguments]    ${supplier_id}    ${list_jsonpath}    ${so_ban_ghi}=${EMPTY}
    ${find_dict}      Create Dictionary    id_nha_cung_cap=${supplier_id}    so_ban_ghi=${so_ban_ghi}
    ${result_dict}    API Call From Template    /nha-cung-cap/no_can_tra_ncc.txt    ${find_dict}     ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get dict supplier transactionhistory info frm API
    [Arguments]    ${id_ncc}    ${list_jsonpath}
    ${find_dict}    Create Dictionary    id_ncc=${id_ncc}
    ${result_dict}    API Call From Template    /nha-cung-cap/lich_su_nhap_tra_hang.txt    ${find_dict}   ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get dict all supplier group info frm API
    [Arguments]   ${list_jsonpath}
    ${result_dict}    API Call From Template    /nha-cung-cap/all_nhom_NCC.txt    ${EMPTY}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get supplier name and supplier debt by code
    [Arguments]    ${supplier_code}
    ${jsonpath}         Set Variable    $.Data[?(@.Code\=\="${supplier_code}")].["Name","Debt"]
    ${result_dict}      Get dict all supplier info frm API    ${jsonpath}
    ${supplier_name}    Set Variable Return From Dict    ${result_dict.Name[0]}
    ${supplier_debt}    Set Variable Return From Dict    ${result_dict.Debt[0]}
    Return From Keyword    ${supplier_name}    ${supplier_debt}

Get supplier debt by code
    [Arguments]    ${supplier_code}
    ${jsonpath}       Set Variable    $.Data[?(@.Code\=\="${supplier_code}")].["Debt"]
    ${result_dict}    Get dict all supplier info frm API    ${jsonpath}
    ${supplier_debt}         Set Variable Return From Dict    ${result_dict.Debt[0]}
    Return From Keyword    ${supplier_debt}

Get supplier id by code
    [Arguments]    ${supplier_code}
    ${jsonpath}       Set Variable    $.Data[?(@.Code\=\="${supplier_code}")].Id
    ${result_dict}    Get dict all supplier info frm API    ${jsonpath}
    Return From Keyword    ${result_dict.Id[0]}

Get list supplier id by list code
    [Arguments]    ${list_supplier_code}
    ${result_dict}    Get dict all supplier info frm API    $.Data[*].["Id","Code"]
    ${list_id}      Set Variable Return From Dict    ${result_dict.Id}
    ${list_code}    Set Variable Return From Dict    ${result_dict.Code}
    ${result_list_id}    Create List
    FOR    ${supplier_code}    IN    @{list_supplier_code}
        ${index}    Get Index From List    ${list_code}    ${supplier_code}
        Append To List    ${result_list_id}    ${list_id[${index}]}
    END
    Return From Keyword    ${result_list_id}

Get supplier group id by name
    [Arguments]    ${ten_nhom_ncc}
    ${result_dict}    Get dict all supplier group info frm API    $.Data[?(@.Name\=\="${ten_nhom_ncc}")].Id
    ${id_nhom_ncc}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${id_nhom_ncc}

Get list supplier group id by list name
    [Arguments]    ${list_nhom_ncc}
    ${result_dict}    Get dict all supplier group info frm API    $.Data[*].["Id","Name"]
    ${list_id}    Set Variable Return From Dict    ${result_dict.Id}
    ${list_name}    Set Variable Return From Dict    ${result_dict.Name}
    ${result_list_group_id}    Create List
    FOR    ${nhom_ncc}    IN    @{list_nhom_ncc}
        ${index}    Get Index From List    ${list_name}    ${nhom_ncc}
        Append To List    ${result_list_group_id}    ${list_id[${index}]}
    END
    Return From Keyword    ${result_list_group_id}

Get Value and Balance in debt tab
    [Arguments]    ${ma_phieu}    ${supplier_id}
    ${jsonpath}      Set Variable    $.Data[?(@.DocumentCode\=\="${ma_phieu}")].["Value","Balance"]
    ${result_dict}    Get dict supplier debt info frm API    ${supplier_id}    ${jsonpath}
    ${value}    Set Variable Return From Dict    ${result_dict.Value[0]}
    ${balance}    Set Variable Return From Dict    ${result_dict.Balance[0]}
    Return From Keyword    ${value}    ${balance}

# Tính Nợ cần trả NCC sau khi tạo  phiếu nhập hàng
Count no nha cung cap sau khi tao phieu
    [Documentation]    loai_phieu=PC  => đối với giao dịch nhập hàng
    ...                loai_phieu=PT  => đối với giao dịch trả hàng nhập
    [Arguments]    ${ma_ncc}    ${count_total}    ${no_ncc_bf}    ${loai_phieu}
    ${supplier_id}    Get supplier id by code    ${ma_ncc}
    ${count_total_negative}    Minus    0    ${count_total}
    ${no_ncc_bf_negative}    Run Keyword If    '${loai_phieu}'=='PC'    Minus    0    ${no_ncc_bf}    ELSE IF   '${loai_phieu}'=='PT'    Set Variable    ${no_ncc_bf}
    ${count_no_ncc_af}         Sum      ${no_ncc_bf_negative}    ${count_total_negative}
    Return From Keyword    ${count_no_ncc_af}    ${supplier_id}

# ===================== ASSERT SỔ QUỸ KHI TẠO PHIẾU NHẬP HÀNG - PHIẾU TRẢ HÀNG NHẬP  ==========================

# Assert thông tin trong Tab Nợ cần trả NCC sau khi tạo phiếu tạm
Assert thong tin no NCC sau khi tao phieu tam
    [Documentation]    loai_phieu=PC  => đối với giao dịch nhập hàng
    ...                loai_phieu=PT  => đối với giao dịch trả hàng nhập
    [Arguments]    ${ma_ncc}    ${ma_phieu}    ${ma_phieu_thu_chi}    ${count_total}    ${no_ncc_bf}    ${tien_tra_ncc}    ${loai_phieu}
    ${supplier_id}        Get supplier id by code    ${ma_ncc}
    # Do mã phiếu nhập tạm không ghi nhận trong Tab Nợ cần trả NCC
    ${count_no_ncc_af}    Set Variable    ${no_ncc_bf}
    Assert values not avaiable in supplier debt tab    ${ma_phieu}    ${ma_ncc}
    Run Keyword If    '${ma_phieu_thu_chi}'!='${EMPTY}'    Get and assert data phieu thu chi cua phieu trong NCC    ${ma_phieu_thu_chi}    ${count_no_ncc_af}    ${tien_tra_ncc}
    ...    ${supplier_id}    ${loai_phieu}

# Assert thong tin tab [Nợ cần trả NCC] sau khi tạo phiếu hoàn thành
Assert thong tin no NCC sau khi tao phieu hoan thanh
    [Documentation]    loai_phieu=PC  => đối với giao dịch nhập hàng
    ...                loai_phieu=PT  => đối với giao dịch trả hàng nhập
    [Arguments]    ${ma_ncc}    ${ma_phieu}    ${ma_phieu_thu_chi}    ${count_total}    ${no_ncc_bf}    ${tien_tra_ncc}    ${loai_phieu}
    ${count_no_ncc_af}    ${supplier_id}    Count no nha cung cap sau khi tao phieu    ${ma_ncc}    ${count_total}    ${no_ncc_bf}    ${loai_phieu}
    Get and assert data cua phieu trong NCC    ${ma_phieu}    ${count_total}    ${count_no_ncc_af}    ${supplier_id}    ${loai_phieu}
    Run Keyword If    '${ma_phieu_thu_chi}'!='${EMPTY}'    Get and assert data phieu thu chi cua phieu trong NCC    ${ma_phieu_thu_chi}    ${count_no_ncc_af}    ${tien_tra_ncc}
    ...    ${supplier_id}    ${loai_phieu}

# get thong tin cua phieu thu/chi tu tab No can tra NCC
Get and assert data phieu thu chi cua phieu trong NCC
    [Documentation]    loai_phieu=PC  => đối với giao dịch nhập hàng
    ...                loai_phieu=PT  => đối với giao dịch trả hàng nhập
    [Arguments]    ${ma_phieu_thu_chi}    ${count_no_ncc_af}    ${tien_tra_ncc}    ${supplier_id}    ${loai_phieu}
    ${value}    ${balance}    Get Value and Balance in debt tab    ${ma_phieu_thu_chi}    ${supplier_id}
    ${tien_tra_ncc}      Run Keyword If   '${loai_phieu}'=='PC'    Set Variable   ${tien_tra_ncc}       ELSE IF   '${loai_phieu}'=='PT'    Minus    0     ${tien_tra_ncc}
    ${count_no_ncc_af}   Run Keyword If   '${loai_phieu}'=='PC'    Set Variable    ${count_no_ncc_af}   ELSE IF   '${loai_phieu}'=='PT'    Minus    0     ${count_no_ncc_af}
    ${count_balance_ncc_result}    Sum    ${count_no_ncc_af}    ${tien_tra_ncc}
    KV Should Be Equal As Numbers    ${count_balance_ncc_result}    ${balance}    msg=Lỗi sai giá trị nợ hiện tại
    KV Should Be Equal As Numbers    ${tien_tra_ncc}    ${value}    msg=Lỗi sai giá trị tiền trả NCC

# get thong tin cua phieu tu tab No can tra NCC
Get and assert data cua phieu trong NCC
    [Documentation]    loai_phieu=PC  => đối với giao dịch nhập hàng
    ...                loai_phieu=PT  => đối với giao dịch trả hàng nhập
    [Arguments]    ${ma_phieu}    ${count_total}    ${count_no_ncc_af}    ${supplier_id}    ${loai_phieu}
    ${value}    ${balance}    Get Value and Balance in debt tab    ${ma_phieu}    ${supplier_id}
    ${count_total_negative}    Run Keyword If   '${loai_phieu}'=='PC'    Minus    0     ${count_total}        ELSE IF   '${loai_phieu}'=='PT'    Set Variable    ${count_total}
    ${count_no_ncc_af}         Run Keyword If   '${loai_phieu}'=='PC'    Set Variable   ${count_no_ncc_af}    ELSE IF   '${loai_phieu}'=='PT'    Minus    0     ${count_no_ncc_af}
    KV Should Be Equal As Numbers    ${count_total_negative}    ${value}    msg=Lỗi sai giá trị phiếu
    KV Should Be Equal As Numbers    ${count_no_ncc_af}    ${balance}    msg=Lỗi sai giá trị nợ cần trả NCC

# ================= end ========================
# ========================= ASSERT THONG TIN SAU KHI IMPORT - EXPORT NCC ===========================
Get info supplier to import - export
    [Arguments]
    ${list_jsonpath}    Create List    $.Data[?(@.Id!=-1)].["Code","Name","Email","Phone","Address","LocationName","WardName","TotalInvoiced","Debt","TaxCode","Comment","Groups","isActive","TotalInvoicedWithoutReturn","Company"]
    ${dict_all}    Get dict all supplier info frm API    ${list_jsonpath}
    ${dict_all.Email}           Set Variable Return From Dict    ${dict_all.Email}
    ${dict_all.Phone}           Set Variable Return From Dict    ${dict_all.Phone}
    ${dict_all.Address}         Set Variable Return From Dict    ${dict_all.Address}
    ${dict_all.LocationName}    Set Variable Return From Dict    ${dict_all.LocationName}
    ${dict_all.WardName}        Set Variable Return From Dict    ${dict_all.WardName}
    ${dict_all.TaxCode}         Set Variable Return From Dict    ${dict_all.TaxCode}
    ${dict_all.Comment}         Set Variable Return From Dict    ${dict_all.Comment}
    ${dict_all.Groups}          Set Variable Return From Dict    ${dict_all.Groups}
    ${dict_all.Company}         Set Variable Return From Dict    ${dict_all.Company}
    Return From Keyword    ${dict_all}

Get info supplier after import
    [Arguments]    ${list_ma_ncc}
    ${dict_all}    Get info supplier to import - export
    ${result_dict}    Create Dictionary    ma_ncc=@{EMPTY}        ten_ncc=@{EMPTY}                  email=@{EMPTY}         sdt=@{EMPTY}        dia_chi=@{EMPTY}    khu_vuc=@{EMPTY}
    ...              phuong_xa=@{EMPTY}    tong_mua=@{EMPTY}      no_can_tra_hien_tai=@{EMPTY}      ma_so_thue=@{EMPTY}    ghi_chu=@{EMPTY}
    ...              nhom_ncc=@{EMPTY}     trang_thai=@{EMPTY}    tong_mua_tru_tra_hang=@{EMPTY}    cong_ty=@{EMPTY}

    FOR   ${ma_ncc}    IN    @{list_ma_ncc}
        ${index}    Get Index From List    ${list_ma_ncc}    ${ma_ncc}
        ${status}       Run Keyword If    '${dict_all.isActive[${index}]}'=='False'    Set Variable    0
        ...                    ELSE IF    '${dict_all.isActive[${index}]}'=='True'     Set Variable    1
        Append To List    ${result_dict.ma_ncc}                  ${dict_all.Code[${index}]}
        Append To List    ${result_dict.ten_ncc}                 ${dict_all.Name[${index}]}
        Append To List    ${result_dict.email}                   ${dict_all.Email[${index}]}
        Append To List    ${result_dict.sdt}                     ${dict_all.Phone[${index}]}
        Append To List    ${result_dict.dia_chi}                 ${dict_all.Address[${index}]}
        Append To List    ${result_dict.khu_vuc}                 ${dict_all.LocationName[${index}]}
        Append To List    ${result_dict.phuong_xa}               ${dict_all.WardName[${index}]}
        Append To List    ${result_dict.tong_mua}                ${dict_all.TotalInvoiced[${index}]}
        Append To List    ${result_dict.no_can_tra_hien_tai}     ${dict_all.Debt[${index}]}
        Append To List    ${result_dict.ma_so_thue}              ${dict_all.TaxCode[${index}]}
        Append To List    ${result_dict.ghi_chu}                 ${dict_all.Comment[${index}]}
        Append To List    ${result_dict.nhom_ncc}                ${dict_all.Groups[${index}]}
        Append To List    ${result_dict.trang_thai}              ${status}
        Append To List    ${result_dict.cong_ty}                 ${dict_all.Company[${index}]}
        Append To List    ${result_dict.tong_mua_tru_tra_hang}   ${dict_all.TotalInvoicedWithoutReturn[${index}]}
    END
    Return From Keyword    ${result_dict}

Get info to export debit file of Supplier
    [Arguments]    ${id_ncc}    ${id_phieunhap}
    ${result_dict}    Get dict supplier debt info frm API    ${id_ncc}    $.Data[*].["DocumentCode","DocumentType","TransDate","Value"]
    ${list_document_code}    Set Variable Return From Dict    ${result_dict.DocumentCode}
    ${list_document_type}    Set Variable Return From Dict    ${result_dict.DocumentType}
    ${list_value}            Set Variable Return From Dict    ${result_dict.Value}
    ${list_thoi_gian}        Set Variable Return From Dict    ${result_dict.TransDate}
    ${list_thoi_gian}        KV Convert DateTime To String    ${list_thoi_gian}    result_format=%d/%m/%Y %H:%M

    ${target_dict}   Create Dictionary   thoi_gian=@{EMPTY}   ma=@{EMPTY}   dien_giai=@{EMPTY}   dvt=@{EMPTY}   sl=@{EMPTY}   gia_nhap_tra=@{EMPTY}   thanh_tien=@{EMPTY}   ghi_no=@{EMPTY}   ghi_co=@{EMPTY}

    ${list_jsonpath}    Create List    $.PurchaseOrderDetails[*].["ProductCode","Quantity","Price","SubTotal"]    $.PurchaseOrderDetails[*].["Product.Unit","Product.Name"]
    ${list_document_code}    ${list_document_type}    ${list_value}    ${list_thoi_gian}    Reverse four lists    ${list_document_code}    ${list_document_type}    ${list_value}    ${list_thoi_gian}

    FOR    ${ma_phieu}    IN ZIP    ${list_document_code}
        ${index}      Get Index From List    ${list_document_code}   ${ma_phieu}
        ${dict_phieunhap}    Run Keyword If    '${list_document_type[${index}]}'=='2'    Get dict update detail purchase order info    ${id_phieunhap}    ${list_jsonpath}
        Run Keyword If   '${list_document_type[${index}]}'=='2'   Mix Product Data Of Purchase To Export Debit File    ${ma_phieu}    ${list_thoi_gian[${index}]}    ${target_dict}    ${dict_phieunhap}    ${list_value[${index}]}
        Run Keyword If   '${list_document_type[${index}]}'=='0'   Mix Info Supplier Common To Export Debit File        ${ma_phieu}    ${list_thoi_gian[${index}]}    ${target_dict}    ${list_value[${index}]}    Thanh toán
        Log Dictionary    ${target_dict}
    END
    Return From Keyword    ${target_dict}

# Thông tin tương ứng với dòng mã phiếu trong file excel
Mix Info Supplier Common To Export Debit File
    [Arguments]    ${document_code}    ${thoi_gian}    ${target_dict}    ${document_value}    ${description}
    # Giá trị trong file excel là số dương nên cần convert sang số dương
    ${value}    Run Keyword If    ${document_value} > 0    Set Variable    ${document_value}    ELSE    Minus    0    ${document_value}
    Append To List    ${target_dict.thoi_gian}     ${thoi_gian}
    Append To List    ${target_dict.ma}            ${document_code}
    Append To List    ${target_dict.dien_giai}     ${description}
    Append To List    ${target_dict.dvt}           ${0}
    Append To List    ${target_dict.sl}            ${0}
    Append To List    ${target_dict.gia_nhap_tra}  ${0}
    Append To List    ${target_dict.thanh_tien}    ${0}
    Run Keyword If    ${document_value} < 0    Run Keywords    Append To List    ${target_dict.ghi_no}    ${value}   AND    Append To List    ${target_dict.ghi_co}    ${0}
    ...    ELSE IF    ${document_value} > 0    Run Keywords    Append To List    ${target_dict.ghi_no}    ${0}       AND    Append To List    ${target_dict.ghi_co}    ${value}

Mix Product Data Of Purchase To Export Debit File
    [Arguments]    ${document_code}    ${thoi_gian}     ${target_dict}    ${dict_phieunhap}    ${document_value}
    ${list_pr_code}      Set Variable Return From Dict    ${dict_phieunhap.ProductCode}
    ${list_pr_name}      Set Variable Return From Dict    ${dict_phieunhap.Name}
    ${list_pr_dvt}       Set Variable Return From Dict    ${dict_phieunhap.Unit}
    ${list_pr_quantity}  Set Variable Return From Dict    ${dict_phieunhap.Quantity}
    ${list_pr_price}     Set Variable Return From Dict    ${dict_phieunhap.Price}
    ${list_pr_subtotal}  Set Variable Return From Dict    ${dict_phieunhap.SubTotal}
    Mix Info Supplier Common To Export Debit File    ${document_code}    ${thoi_gian}     ${target_dict}     ${document_value}    Nhập hàng
    FOR     ${code}    IN    @{list_pr_code}
        ${index}    Get Index From List    ${list_pr_code}    ${code}
        Append To List    ${target_dict.thoi_gian}      ${0}
        Append To List    ${target_dict.ma}             ${code}
        Append To List    ${target_dict.dien_giai}      ${list_pr_name[${index}]}
        Append To List    ${target_dict.dvt}            ${list_pr_dvt[${index}]}
        Append To List    ${target_dict.sl}             ${list_pr_quantity[${index}]}
        Append To List    ${target_dict.gia_nhap_tra}   ${list_pr_price[${index}]}
        Append To List    ${target_dict.thanh_tien}     ${list_pr_subtotal[${index}]}
        Append To List    ${target_dict.ghi_no}         ${0}
        Append To List    ${target_dict.ghi_co}         ${0}
    END

Get Info To Export Debt Of Supplier
    [Arguments]    ${id_ncc}
    ${result_dict}    Get dict supplier debt info frm API    ${id_ncc}    $.Data[*].["DocumentCode","TransDate","DocumentType","Value","Balance"]
    FOR    ${value}    ${blance}    IN ZIP    ${result_dict.Value}    ${result_dict.Balance}
        ${index}    Get Index From List    ${result_dict.Value}    ${value}
        ${value_neg}     Minus    0    ${value}
        ${blance_neg}    Minus    0    ${blance}
        Set List Value    ${result_dict.Value}      ${index}    ${value_neg}
        Set List Value    ${result_dict.Balance}    ${index}    ${blance_neg}
    END
    ${result_dict.TransDate}    KV Convert DateTime To String    ${result_dict.TransDate}
    ${result_dict.DocumentType}    Convert DocumentType To String Of Supplier    ${result_dict.DocumentType}
    Return From Keyword    ${result_dict}

Convert DocumentType To String Of Supplier
    [Arguments]    ${document_type}
    ${type}     Evaluate    type($document_type).__name__
    ${list_document_type}    Run Keyword If    '${type}'=='list'    Set Variable    ${document_type}    ELSE    Create List    ${document_type}
    ${result_list}    Create List
    FOR    ${item_doc}    IN    @{list_document_type}
        ${item_str}    Run Keyword If    '${item_doc}'=='0'    Set Variable    Thanh toán
        ...                   ELSE IF    '${item_doc}'=='2'    Set Variable    Nhập hàng
        ...                   ELSE IF    '${item_doc}'=='5'    Set Variable    Trả hàng nhà cung cấp
        Append To List    ${result_list}    ${item_str}
    END
    Return From Keyword    ${result_list}

Get Info To Export Transactionhistory Of Supplier
    [Arguments]    ${id_ncc}
    ${result_dict}    Get dict supplier transactionhistory info frm API    ${id_ncc}    $.Data[*].["Code","TransDate","BranchName","SupplierName","ReceivedByUser","Total","Status","Description"]
    ${description}    Set Variable Return From Dict    ${result_dict.Description}
    ${result_dict.TransDate}    KV Convert DateTime To String    ${result_dict.TransDate}
    ${result_dict.Status}    Convert Status In Transactionhistory Supplier To String    ${result_dict.Status}
    Return From Keyword    ${result_dict}

Convert Status In Transactionhistory Supplier To String
    [Arguments]    ${status}
    ${type_status}     Evaluate    type($status).__name__
    ${list_status}          Run Keyword If    '${type_status}'=='list'     Set Variable    ${status}    ELSE    Create List    ${status}
    ${result_list}    Create List
    FOR    ${status}    IN ZIP    ${list_status}
        ${item_str}    Run Keyword If    '${status}'=='1'    Set Variable    Đã trả hàng
        ...                   ELSE IF    '${status}'=='3'    Set Variable    Đã nhập hàng
        Append To List    ${result_list}    ${item_str}
    END
    Return From Keyword    ${result_list}


# ================= end ========================

Get all documents in supplier debt tab
    [Arguments]    ${ma_ncc}
    ${supplier_id}    Get supplier id by code    ${ma_ncc}
    ${result_dict}    Get dict supplier debt info frm API    ${supplier_id}    $.Data[*].DocumentCode
    ${list_all_doc}   Set Variable Return From Dict    ${result_dict.DocumentCode}
    Return From Keyword    ${list_all_doc}

Assert values not avaiable in supplier debt tab
    [Arguments]    ${ma_phieu_nhap}    ${ma_ncc}
    [Timeout]    1 minute
    ${all_docs}    Get all documents in supplier debt tab    ${ma_ncc}
    KV List Should Not Contain Value    ${all_docs}    ${ma_phieu_nhap}    msg=Lỗi vẫn tồn tại mã phiếu trong tab Nợ cần trả NCC

Assert thong tin them moi nha cung cap
    [Arguments]    ${ma_ncc}   ${ten_ncc}    ${sdt}    ${dia_chi}=${EMPTY}    ${nhom_ncc}=${EMPTY}
    ${list_jsonpath}    Create List    $.Data[?(@.Code\=\="${ma_ncc}")].["Name","Phone","Address","Groups"]
    ${result_dict}   Get dict all supplier info frm API    ${list_jsonpath}
    ${get_ten_ncc}   Set Variable Return From Dict    ${result_dict.Name[0]}
    ${get_sdt}       Set Variable Return From Dict    ${result_dict.Phone[0]}
    ${get_dia_chi}   Set Variable Return From Dict    ${result_dict.Address[0]}
    ${get_nhom_ncc}  Set Variable Return From Dict    ${result_dict.Groups[0]}
    KV Compare Scalar Values    ${get_ten_ncc}    ${ten_ncc}    msg=Lỗi sai thông tin tên NCC
    KV Compare Scalar Values    ${get_sdt}    ${sdt}    msg=Lỗi sai thông tin SĐT NCC
    Run Keyword If    '${dia_chi}'!='${EMPTY}'    KV Compare Scalar Values    ${get_dia_chi}    ${dia_chi}    msg=Lỗi sai thông tin địa chỉ NCCC
    Run Keyword If    '${nhom_ncc}'!='${EMPTY}'    KV Compare Scalar Values    ${get_nhom_ncc}    ${nhom_ncc}    msg=Lỗi sai thông tin nhóm NCCC

Assert thong tin khi xoa nha cung cap
    [Arguments]   ${ma_ncc_delete}
    ${list_jsonpath}    Set Variable    $.Data[?(@.Id!=-1)].Code
    ${result_dict}    Get dict all supplier info frm API    ${list_jsonpath}
    ${list_code}    Set Variable Return From Dict    ${result_dict.Code}
    KV List Should Not Contain Value    ${list_code}    ${ma_ncc_delete}    msg=Lỗi vẫn tồn tại mã NCC đã xóa trong hệ thống

Get no hien tai cua NCC
    [Arguments]    ${id_ncc}
    ${result_dict}    Get dict all supplier info frm API    $.Data[?(@.Id\=\=${id_ncc})].Debt
    ${no_hien_tai}    Set Variable Return From Dict    ${result_dict.Debt[0]}
    Return From Keyword    ${no_hien_tai}

Assert phieu can bang sau khi dieu chinh cong no NCC
    [Arguments]    ${id_ncc}    ${gia_tri}
    ${gia_tri_neg}    Minus    0    ${gia_tri}
    ${get_no_hien_tai}    Get no hien tai cua NCC    ${id_ncc}
    ${result_dict}    Get dict supplier debt info frm API    ${id_ncc}    $.Data[*].Value
    ${get_value}    Set Variable Return From Dict    ${result_dict.Value[0]}
    KV Should Be Equal As Numbers    ${gia_tri}        ${get_no_hien_tai}    msg=Lỗi sai nợ hiện tại của NCC
    KV Should Be Equal As Numbers    ${gia_tri_neg}    ${get_value}          msg=Lỗi sai nợ giá trị trong phiếu điều chỉnh nợ NCC

Assert phieu thanh toan cho NCC va return ma phieu
    [Arguments]    ${id_ncc}    ${gia_tri}    ${count_no_af}
    ${get_no_hien_tai}    Get no hien tai cua NCC    ${id_ncc}
    ${result_dict}    Get dict supplier debt info frm API    ${id_ncc}    $.Data[*].["Value","DocumentCode"]
    ${get_gia_tri}    Set Variable Return From Dict    ${result_dict.Value[0]}
    ${ma_phieu_tt}    Set Variable Return From Dict    ${result_dict.DocumentCode[0]}
    KV Should Be Equal As Numbers    ${gia_tri}        ${get_gia_tri}        msg=Lỗi sai giá trị phiếu thanh toán nợ NCC
    KV Should Be Equal As Numbers    ${count_no_af}    ${get_no_hien_tai}    msg=Lỗi sai nợ hiện tại của NCC sau khi lập phiếu thanh toán
    Return From Keyword    ${ma_phieu_tt}

Assert thong tin tong trong man hinh nha cung cap giua UI va API
    [Arguments]    ${text_tong_no}    ${text_tong_mua}    ${text_tong_mua_tru_tra}    ${ma_ncc}=${EMPTY}
    ${list_jsonpath}    Create List    $.Data[?(@.Id!=-1)].["TotalInvoicedWithoutReturn"]    $.["Total1Value","Total2Value"]
    ${result_dict}    Get dict all supplier info frm API    ${list_jsonpath}    is_active=True
    ${get_tong_mua_tru_tra}    Sum values in list    ${result_dict.TotalInvoicedWithoutReturn}
    KV Should Be Equal As Numbers    ${text_tong_no}            ${result_dict.Total2Value[0]}    msg=Hiển thị sai thông tin chung: Tổng nợ cần trả hiện tại
    KV Should Be Equal As Numbers    ${text_tong_mua}           ${result_dict.Total1Value[0]}    msg=Hiển thị sai thông tin chung: Tổng mua
    KV Should Be Equal As Numbers    ${text_tong_mua_tru_tra}   ${get_tong_mua_tru_tra}          msg=Hiển thị sai thông tin chung: Tổng mua trừ trả hàng

Assert thong tin tong trong chi tiet 1 nha cung cap giua UI va API
    [Arguments]    ${text_tong_no}    ${text_tong_mua}    ${text_tong_mua_tru_tra}    ${ma_ncc}
    ${list_jsonpath}    Create List    $.Data[?(@.Code=="${ma_ncc}")].["Debt","TotalInvoiced","TotalInvoicedWithoutReturn"]
    ${result_dict}    Get dict all supplier info frm API    ${list_jsonpath}    is_active=True
    KV Should Be Equal As Numbers    ${text_tong_no}            ${result_dict.Debt[0]}             msg=Hiển thị sai thông tin chung: Tổng nợ cần trả hiện tại
    KV Should Be Equal As Numbers    ${text_tong_mua}           ${result_dict.TotalInvoiced[0]}    msg=Hiển thị sai thông tin chung: Tổng mua
    KV Should Be Equal As Numbers    ${text_tong_mua_tru_tra}   ${result_dict.TotalInvoicedWithoutReturn[0]}    msg=Hiển thị sai thông tin chung: Tổng mua trừ trả hàng






#
