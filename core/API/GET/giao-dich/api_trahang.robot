*** Settings ***
Resource          ../../api_access.robot
Resource          ../hang-hoa/api_danhmuc_hanghoa.robot
Library           String
Library           Collections

*** Keywords ***
# Lấy thông tin all phiếu tra hang mặc định theo Hôm nay. (gồm các phiếu ở trạng thái Đã trả)
Get dict all returns frm API
    [Arguments]    ${list_jsonpath}    ${thoi_gian}=today    ${is_phieu_tra}=True    ${is_phieu_huy}=False    ${so_ban_ghi}=${EMPTY}
    ${filter_status}    KV Get Filter Status Return    ${is_phieu_tra}    ${is_phieu_huy}
    ${data_filter}   Set Variable    BranchId+eq+${BRANCH_ID}+and+ReturnDate+eq+'${thoi_gian}'+and+(${filter_status})
    ${input_dict}    Create Dictionary    so_ban_ghi=${so_ban_ghi}    data_filter=${data_filter}
    ${result_dict}   API Call From Template    /tra-hang/all_phieu_tra_hang.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

KV Get Filter Status Return
    [Arguments]    ${is_phieu_tra}    ${is_phieu_huy}
    ${list_filter}    Create List
    Run Keyword If    '${is_phieu_tra}' == 'True'    Append To List    ${list_filter}    Status+eq+1
    Run Keyword If    '${is_phieu_huy}' == 'True'    Append To List    ${list_filter}    Status+eq+2
    ${list_filter}     Evaluate    "+or+".join(${list_filter})
    Return From Keyword    ${list_filter}

Get dict detail returns frm API
    [Arguments]    ${id_phieu}    ${list_jsonpath}
    ${input_dict}    Create Dictionary    id_phieu=${id_phieu}
    ${result_dict}    API Call From Template    /tra-hang/detail_phieu_tra_hang.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get dict info detail returns frm API
    [Arguments]    ${id_phieu_tra}    ${list_jsonpath}
    ${input_dict}    Create Dictionary    id_phieu_tra=${id_phieu_tra}
    ${result_dict}    API Call From Template    /tra-hang/chi_tiet_phieu_tra_hang.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get dict info chi tiet returns frm API
    [Arguments]    ${id_phieu_tra}    ${list_jsonpath}
    ${input_dict}    Create Dictionary    id_phieu=${id_phieu_tra}
    ${result_dict}    API Call From Template    /tra-hang/detail_phieu_tra_hang.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

# Lấy thông tin để so sánh với file export Tổng quan phiếu trả hàng
Get info to export all returns
    ${list_jsonpath}   Create List    $.Data[?(@.Id!=-1)].["Code","ReturnDate","CustomerName","ReturnTotal","TotalPayment","Status"]
    ${result_dict}     Get dict all returns frm API    ${list_jsonpath}
    ${result_dict.ReturnDate}     KV Convert DateTime To String    ${result_dict.ReturnDate}    result_format=%d/%m/%Y %H:%M:%S
    ${result_dict.TotalPayment}   KV Swap between negative number and positive number    ${result_dict.TotalPayment}
    ${result_dict.Status}         Convert the return value's status to a string    ${result_dict.Status}
    ${result_dict.CustomerName}   Standardized customer information on returns    ${result_dict.CustomerName}
    Return From Keyword    ${result_dict}

# CHuẩn hóa thông tin tên khách hàng để khớp với file excel
Standardized customer information on returns
    [Arguments]    ${customer_name}
    ${type}    Evaluate    type($customer_name).__name__
    ${list_customername}    Run Keyword If    '${type}'=='list'    Set Variable    ${customer_name}    ELSE    Create List    ${customer_name}
    ${result_customername}    Create List
    FOR    ${item_customername}    IN    @{list_customername}
        ${customername}    Run Keyword If    '${item_customername}'=='${EMPTY}' or '${item_customername}'=='0'    Set Variable    Khách lẻ    ELSE    Set Variable    ${item_customername}
        Append To List    ${result_customername}    ${customername}
    END
    ${result}    Run Keyword If    '${type}'=='list'    Set Variable    ${result_customername}    ELSE    Set Variable    ${result_customername[0]}
    Return From Keyword    ${result}

# Convert giá trị trạng thái sang string
Convert the return value's status to a string
    [Arguments]    ${status}
    ${type}    Evaluate    type($status).__name__
    ${list_status}    Run Keyword If    '${type}'=='list'    Set Variable    ${status}    ELSE    Create List    ${status}
    ${list_status_str}    Create List
    FOR    ${item_status}    IN    @{list_status}
        ${status_string}    Run Keyword If    '${item_status}'=='1'    Set Variable    Đã trả    ELSE IF    '${item_status}'=='2'    Set Variable    Đã hủy
        Append To List    ${list_status_str}    ${status_string}
    END
    ${result}    Run Keyword If    '${type}'=='list'    Set Variable    ${list_status_str}    ELSE    Set Variable    ${list_status_str[0]}
    Return From Keyword    ${result}

# Lấy thông tin để so sánh với file export Chi tiết nhiều phiếu trả hàng
Get info to export detail returns
    ${list_jsonpath}    Create List    $.Data[?(@.Id!=-1)].["Id","Branch.Name","Code","ReturnDate","CustomerCode","CustomerName","ReceivedBy.GivenName","User.GivenName","Description","TotalReturn","ReturnDiscount","Surcharge","ReturnTotal","TotalPayment","Status"]
    ${dict_all}    Get dict all returns frm API    ${list_jsonpath}

    ${dict_all.CustomerCode}    Set Variable Return From Dict    ${dict_all.CustomerCode}
    ${dict_all.CustomerName}    Set Variable Return From Dict    ${dict_all.CustomerName}
    ${dict_all.Description}     Set Variable Return From Dict    ${dict_all.Description}
    ${dict_all.ReturnDiscount}  Set Variable Return From Dict    ${dict_all.ReturnDiscount}
    ${dict_all.Surcharge}       Set Variable Return From Dict    ${dict_all.Surcharge}
    ${dict_all.ReturnDate}      KV Convert DateTime To String    ${dict_all.ReturnDate}    result_format=%d/%m/%Y %H:%M:%S
    ${dict_all.Status}          Convert the return value's status to a string    ${dict_all.Status}
    ${dict_all.CustomerName}    Standardized customer information on returns    ${dict_all.CustomerName}
    ${dict_all.TotalPayment}    KV Swap between negative number and positive number    ${dict_all.TotalPayment}

    ${result_dict}    Create Dictionary   unique_key=@{EMPTY}   chi_nhanh=@{EMPTY}       ma_tra_hang=@{EMPTY}          thoi_gian=@{EMPTY}     ma_kh=@{EMPTY}   ten_kh=@{EMPTY}
    ...    nguoi_nhan_tra=@{EMPTY}      nguoi_tao=@{EMPTY}      ghi_chu=@{EMPTY}         tong_tien_hang_tra=@{EMPTY}   GG_phieu_tra=@{EMPTY}
    ...    thu_khac_hoan_lai=@{EMPTY}   can_tra_khach=@{EMPTY}  da_tra_khach=@{EMPTY}    tien_mat=@{EMPTY}             the=@{EMPTY}
    ...    chuyen_khoan=@{EMPTY}        diem=@{EMPTY}           trang_thai=@{EMPTY}      ma_hang=@{EMPTY}              ten_hang=@{EMPTY}       dvt=@{EMPTY}
    ...    ghi_chu_hh=@{EMPTY}          sl=@{EMPTY}             gia_ban=@{EMPTY}         gia_nhap_lai=@{EMPTY}

    FOR   ${id_pt}    IN    @{dict_all.Id}
        ${index_pt}    Get Index From List    ${dict_all.Id}    ${id_pt}
        ${dict_detail}    Get dict full info of product in Return    ${id_pt}
        Returns mix data from API    ${dict_all.Code[${index_pt}]}    ${result_dict}    ${dict_all}    ${dict_detail}    ${index_pt}
    END
    Return From Keyword    ${result_dict}

Returns mix data from API
    [Arguments]    ${ma_pt}    ${result_dict}    ${dict_all}    ${dict_detail}    ${index_pt}
    ${tien_mat}    ${the}    ${chuyen_khoan}    ${diem}    Run Keyword If    '${dict_detail.Method[0]}'=='0'    Set Variable    0    0    0    0
    ...    ELSE IF    '${dict_detail.Method[0]}'=='Cash'       Set Variable    ${dict_detail.Amount[0]}    0    0    0
    ...    ELSE IF    '${dict_detail.Method[0]}'=='Card'       Set Variable    0   ${dict_detail.Amount[0]}   0    0
    ...    ELSE IF    '${dict_detail.Method[0]}'=='Transfer'   Set Variable    0   0   ${dict_detail.Amount[0]}   0
    ...    ELSE IF    '${dict_detail.Method[0]}'=='Point'      Set Variable    0   0   0   ${dict_detail.Amount[0]}
    FOR    ${product_code}    IN    @{dict_detail.ProductCode}
        ${index}    Get Index From List    ${dict_detail.ProductCode}    ${product_code}
        ${unique_value}    Set Variable    ${ma_pt}-${product_code}
        Append To List    ${result_dict.unique_key}           ${unique_value}
        Append To List    ${result_dict.chi_nhanh}            ${dict_all.Name[${index_pt}]}
        Append To List    ${result_dict.ma_tra_hang}          ${dict_all.Code[${index_pt}]}
        Append To List    ${result_dict.thoi_gian}            ${dict_all.ReturnDate[${index_pt}]}
        Append To List    ${result_dict.ma_kh}                ${dict_all.CustomerCode[${index_pt}]}
        Append To List    ${result_dict.ten_kh}               ${dict_all.CustomerName[${index_pt}]}
        Append To List    ${result_dict.nguoi_nhan_tra}       ${dict_all.GivenName[${index_pt}]}
        Append To List    ${result_dict.nguoi_tao}            ${dict_all.GivenName1[${index_pt}]}
        Append To List    ${result_dict.ghi_chu}              ${dict_all.Description[${index_pt}]}
        Append To List    ${result_dict.tong_tien_hang_tra}   ${dict_all.TotalReturn[${index_pt}]}
        Append To List    ${result_dict.GG_phieu_tra}         ${dict_all.ReturnDiscount[${index_pt}]}
        Append To List    ${result_dict.thu_khac_hoan_lai}    ${dict_all.Surcharge[${index_pt}]}
        Append To List    ${result_dict.can_tra_khach}        ${dict_all.ReturnTotal[${index_pt}]}
        Append To List    ${result_dict.da_tra_khach}         ${dict_all.TotalPayment[${index_pt}]}
        Append To List    ${result_dict.tien_mat}             ${tien_mat}
        Append To List    ${result_dict.the}                  ${the}
        Append To List    ${result_dict.chuyen_khoan}         ${chuyen_khoan}
        Append To List    ${result_dict.diem}                 ${diem}
        Append To List    ${result_dict.trang_thai}           ${dict_all.Status[${index_pt}]}
        Append To List    ${result_dict.ma_hang}              ${dict_detail.ProductCode[${index}]}
        Append To List    ${result_dict.ten_hang}             ${dict_detail.ProductName[${index}]}
        Append To List    ${result_dict.dvt}                  ${dict_detail.Unit[${index}]}
        Append To List    ${result_dict.ghi_chu_hh}           ${dict_detail.Note[${index}]}
        Append To List    ${result_dict.sl}                   ${dict_detail.Quantity[${index}]}
        Append To List    ${result_dict.gia_ban}              ${dict_detail.SellPrice[${index}]}
        Append To List    ${result_dict.gia_nhap_lai}         ${dict_detail.Price[${index}]}
    END

Get dict full info of product in Return
    [Arguments]    ${id_pt}
    ${list_jsonpath}    Create List    $.Payments[0].["Method","Amount"]    $.ReturnDetails[*].["ProductCode","ProductName","Product.Unit","Note","Quantity","SellPrice","Price"]
    ${dict_detail}    Get dict detail returns frm API    ${id_pt}    ${list_jsonpath}
    FOR    ${ProductCode}    IN    @{dict_detail.ProductCode}
        ${index}    Get Index From List    ${dict_detail.ProductCode}    ${ProductCode}
        ${name_with_attr}    Get product name with attribute    ${dict_detail.ProductCode[${index}]}    ${dict_detail.ProductName[${index}]}    ${dict_detail.Unit[${index}]}
        Set List Value    ${dict_detail.ProductName}    ${index}    ${name_with_attr}
    END
    ${dict_detail.Unit}    Set Variable Return From Dict    ${dict_detail.Unit}
    ${dict_detail.Note}    Set Variable Return From Dict    ${dict_detail.Note}
    ${dict_detail.Amount}    KV Swap between negative number and positive number    ${dict_detail.Amount}
    Return From Keyword    ${dict_detail}

#Hai
Get total of product in return note frm API
    [Arguments]    ${id_phieu_tra}
    ${jsonpath}    Set Variable    $.Total
    ${result_dict}    Get dict info detail returns frm API    ${id_phieu_tra}    ${jsonpath}
    ${tong_so_hang}    Set Variable Return From Dict    ${result_dict.Total[0]}
    Return From Keyword    ${tong_so_hang}

Get payment code in return note
    [Arguments]    ${return_code}
    ${dict_payment}    Get dict all returns frm API    $.Data[?(@.Code\=\="${return_code}")].PaymentCode
    ${payment_code}    Set Variable Return From Dict    ${dict_payment.PaymentCode[0]}
    Return From Keyword    ${payment_code}

Get detail info in product return note
    [Arguments]    ${id_phieu_tra}
    ${list_jsonpath}    Create List    $.Data[*].["Product.Code","ProductName","Quantity","Product.Unit","SellPrice","Price"]
    ${dict_detail}    Get dict info detail returns frm API    ${id_phieu_tra}    ${list_jsonpath}

    ${list_ma_hang}         Set Variable Return From Dict    ${dict_detail.Code}
    ${list_ten_hang}        Set Variable Return From Dict    ${dict_detail.ProductName}
    ${list_dvt}             Set Variable Return From Dict    ${dict_detail.Unit}
    ${list_so_luong}        Set Variable Return From Dict    ${dict_detail.Quantity}
    ${list_gia_ban}         Set Variable Return From Dict    ${dict_detail.SellPrice}
    ${list_gia_nhap_lai}    Set Variable Return From Dict    ${dict_detail.Price}

    FOR    ${code}    IN    @{list_ma_hang}
        ${index}    Get Index From List    ${list_ma_hang}    ${code}
        ${name_with_attr}    Get product name with attribute    ${list_ma_hang[${index}]}    ${list_ten_hang[${index}]}    ${list_dvt[${index}]}
        Set List Value    ${list_ten_hang}    ${index}    ${name_with_attr}
    END

    ${dict_api_ctth}    Create Dictionary    ma_hang=${list_ma_hang}    ten_hang=${list_ten_hang}    don_vi_tinh=${list_dvt}    so_luong=${list_so_luong}
    ...    gia_ban=${list_gia_ban}    gia_nhap_lai=${list_gia_nhap_lai}

    Log    ${dict_api_ctth}
    Return From Keyword    ${dict_api_ctth}

Get dict summary data in product return note
    [Arguments]    ${ma_phieu_tra}
    ${list_jsonpath}    Create List    $.Data[?(@.Code\=\="${ma_phieu_tra}")].["TotalQuantity","TotalReturn","ReturnDiscount","ReturnFee",TotalPayment"]
    ${result_dict}    Get dict all returns frm API    ${list_jsonpath}
    ${result_dict.TotalPayment}    KV Swap between negative number and positive number    ${result_dict.TotalPayment}

    ${dict_summary_data}    Create Dictionary    tong_so_luong=${result_dict["TotalQuantity"]}    tong_tien_hang_tra=${result_dict["TotalReturn"]}
    ...    giam_gia=${result_dict["ReturnDiscount"]}    phi_tra_hang=${result_dict["ReturnFee"]}    da_tra_khach=${result_dict["TotalPayment"]}
    Log   ${dict_summary_data}
    Return From Keyword    ${dict_summary_data}

Get return id by invoice id
    [Arguments]    ${invoice_id}
    ${dict_payment}    Get dict all returns frm API    $.Data[?(@.InvoiceId\=\=${invoice_id})].Id
    ${return_id}    Set Variable Return From Dict    ${dict_payment.Id[0]}
    Return From Keyword    ${return_id}

Get code return moi nhat
    ${list_jsonpath}   Create List    $.Data[?(@.Id!=-1)].["Code"]
    ${result_dict}     Get dict all returns frm API    ${list_jsonpath}
    ${return_order}    Set Variable Return From Dict    ${result_dict.Code[0]}
    Return From Keyword    ${return_order}

Get return id by return code
    [Arguments]    ${return_code}
    ${result_dict}    Get dict all returns frm API    $.Data[?(@.Code\=\=${return_code})].Id
    ${return_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${return_id}
#........................................... Assert dữ liêu .........................................
Assert thong tin phieu tra hang tren UI va API tra hang
    [Arguments]    ${return_id}    ${list_pr_name}    ${list_pr_sl}    ${list_pr_price}

    ${list_jsonpath}    Create List    $.ReturnDetails[*].["ProductName","Quantity","Price"]
    ${dict_detail}    Get dict info chi tiet returns frm API    ${return_id}    ${list_jsonpath}

    KV Lists Should Be Equal         ${list_pr_name}        ${dict_detail.ProductName}           msg=Lưu sai thông tin tên hàng hóa
    KV Lists Should Be Equal         ${list_pr_sl}          ${dict_detail.Quantity}              msg=Lưu sai thông tin SL hàng hóa
    KV Lists Should Be Equal         ${list_pr_price}       ${dict_detail.Price}                 msg=Lưu sai thông tin giá hàng hóa

Assert thong tin tong tren man hinh tra hang va API
    [Arguments]    ${text_tong_tien}    ${text_giam_gia}    ${text_tong_sau_GG}    ${text_tong_phi_trahang}
    ...    ${text_thu_khac_hoan_lai}    ${text_cantra_khach}    ${text_datra_khach}

    ${result_dict}    Get dict all returns frm API    $.["Total1Value","Total2Value","Total5Value"]
    ${cantra_khach}    Evaluate    ${result_dict.Total1Value[0]} + ${result_dict.Total5Value[0]}

    KV Should Be Equal As Numbers     ${text_tong_tien}               ${result_dict.Total1Value[0]}    msg=Sai thông tin tổng tiền hàng trả
    KV Should Be Equal As Numbers     ${text_tong_sau_GG}             ${result_dict.Total1Value[0]}    msg=Sai thông tin tổng sau giảm giá
    KV Should Be Equal As Numbers     ${text_giam_gia}                0                                msg=Sai thông tin tổng giảm giá
    KV Should Be Equal As Numbers     ${text_tong_phi_trahang}        0                                msg=Sai thông tin tổng phí trả hàng
    KV Should Be Equal As Numbers     ${text_thu_khac_hoan_lai}       ${result_dict.Total5Value[0]}    msg=Sai thông tin thu khác hoàn lại
    KV Should Be Equal As Numbers     ${text_cantra_khach}            ${cantra_khach}                  msg=Sai thông tin cần trả khách
    KV Should Be Equal As Numbers     ${text_datra_khach}             ${result_dict.Total2Value[0]}    msg=Sai thông tin đã trả khách

Assert thong tin tong tren man hinh tra hang va API cua mot don
    [Arguments]    ${id_phieu_tra_nhanh}    ${text_tong_tien}    ${text_giam_gia}    ${text_tong_sau_GG}    ${text_tong_phi_trahang}
    ...    ${text_thu_khac_hoan_lai}    ${text_cantra_khach}    ${text_datra_khach}

    ${result_dict}    Get dict info chi tiet returns frm API    ${id_phieu_tra_nhanh}    $.["TotalReturn","Surcharge","TotalPayment","ReturnTotal"]
    ${datra_khach}     minus    0    ${result_dict.TotalPayment[0]}

    KV Should Be Equal As Numbers     ${text_tong_tien}               ${result_dict.TotalReturn[0]}    msg=Sai thông tin tổng tiền hàng trả
    KV Should Be Equal As Numbers     ${text_tong_sau_GG}             ${result_dict.TotalReturn[0]}    msg=Sai thông tin tổng sau giảm giá
    KV Should Be Equal As Numbers     ${text_giam_gia}                0                                msg=Sai thông tin tổng giảm giá
    KV Should Be Equal                ${text_tong_phi_trahang}        ${EMPTY}                         msg=Sai thông tin tổng phí trả hàng
    KV Should Be Equal As Numbers     ${text_thu_khac_hoan_lai}       ${result_dict.Surcharge[0]}      msg=Sai thông tin thu khác hoàn lại
    KV Should Be Equal As Numbers     ${text_cantra_khach}            ${result_dict.ReturnTotal[0]}    msg=Sai thông tin cần trả khách
    KV Should Be Equal As Numbers     ${text_datra_khach}             ${datra_khach}                   msg=Sai thông tin đã trả khách

Assert thong tin tong tren chi tiet tra hang va API
    [Arguments]    ${id_phieu_tra_nhanh}    ${text_tong_tien}    ${text_giam_gia}    ${text_tong_phi_trahang}
    ...    ${text_cantra_khach}    ${text_datra_khach}    ${text_thukhac}
    ${jsonpath}    Create List    $.["TotalReturn","Surcharge","TotalPayment","ReturnTotal"]     $.InvoiceOrderSurcharges[*].["SurValue"]
    ${result_dict}    Get dict info chi tiet returns frm API    ${id_phieu_tra_nhanh}    ${jsonpath}
    ${datra_khach}     minus    0    ${result_dict.TotalPayment[0]}

    KV Should Be Equal As Numbers     ${text_tong_tien}               ${result_dict.TotalReturn[0]}    msg=Sai thông tin tổng tiền hàng trả
    KV Should Be Equal As Numbers     ${text_giam_gia}                0                                msg=Sai thông tin tổng giảm giá
    KV Should Be Equal As Numbers     ${text_tong_phi_trahang}        0                                msg=Sai thông tin tổng phí trả hàng
    KV Should Be Equal As Numbers     ${text_thukhac}                 ${result_dict.SurValue[0]}       msg=Sai thông tin thu khác hoàn lại
    KV Should Be Equal As Numbers     ${text_cantra_khach}            ${result_dict.ReturnTotal[0]}    msg=Sai thông tin cần trả khách
    KV Should Be Equal As Numbers     ${text_datra_khach}             ${datra_khach}                   msg=Sai thông tin đã trả khách
