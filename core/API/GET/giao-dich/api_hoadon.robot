*** Settings ***
Resource          ../../api_access.robot
Resource          ../hang-hoa/api_danhmuc_hanghoa.robot
Resource          ../hang-hoa/api_thiet_lap_gia.robot
Resource          ../giao-dich/api_order.robot
Resource          ../../../share/computation.robot
Resource          ../../../share/utils.robot
Library           String
Library           Collections
Library           BuiltIn

*** Keywords ***
# ================== Mobile ===============
Get dict detail invoice from mobile api
    [Arguments]    ${invoice_id}    ${list_jsonpath}
    ${input_dict}    Create Dictionary    invoice_id=${invoice_id}
    ${result_dict}    Android API Call From Template    /hoa-don/get_detaile_invoice_from_android.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

# ================= Web ===================
# Lấy danh sách hóa đơn mặc định theo 1 chi nhánh - ngày hôm nay và theo trạng thái: Đang giao hàng + Chưa giao hàng + Hoàn thành
Get dict all invoice frm API
    [Arguments]    ${list_jsonpath}    ${thoi_gian}=today    ${branch_id}=${BRANCH_ID}    ${so_ban_ghi}=${EMPTY}
    ...       ${is_hoan_thanh}=True    ${is_da_huy}=False    ${is_chua_giao}=True         ${is_dang_giao}=True    ${is_khong_giao_duoc}=False

    ${filter_status}    KV Get Filter Status Invoice    ${is_hoan_thanh}    ${is_da_huy}    ${is_chua_giao}    ${is_dang_giao}    ${is_khong_giao_duoc}
    ${data_filter}    Set Variable    (BranchId+eq+${branch_id}+and+PurchaseDate+eq+'${thoi_gian}'+and+PurchaseDate+eq+'${thoi_gian}'+and+(${filter_status}))

    ${input_dict}    Create Dictionary    branch_id=${branch_id}    so_ban_ghi=${so_ban_ghi}    data_filter=${data_filter}
    ${result_dict}    API Call From Template    /hoa-don/all_hoa_don.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get dict detail invoice frm API
    [Arguments]    ${invoice_id}    ${list_jsonpath}
    ${input_dict}    Create Dictionary    invoice_id=${invoice_id}
    ${result_dict}    API Call From Template    /hoa-don/detail_hoa_don.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get dict summary info invoice frm api
    [Arguments]    ${list_jsonpath}    ${thoi_gian}=today    ${branch_id}=${BRANCH_ID}    ${so_ban_ghi}=${EMPTY}
    ...       ${is_hoan_thanh}=True    ${is_da_huy}=False    ${is_chua_giao}=True         ${is_dang_giao}=True    ${is_khong_giao_duoc}=False
    ${filter_status}    KV Get Filter Status Invoice    ${is_hoan_thanh}    ${is_da_huy}    ${is_chua_giao}    ${is_dang_giao}    ${is_khong_giao_duoc}
    ${data_filter}    Set Variable    (BranchId+eq+${branch_id}+and+PurchaseDate+eq+'${thoi_gian}'+and+PurchaseDate+eq+'${thoi_gian}'+and+(${filter_status}))
    ${input_dict}    Create Dictionary    data_filter=${data_filter}
    ${result_dict}    API Call From Template    /hoa-don/summary_invoice.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

# Filter theo status của hoa don
KV Get Filter Status Invoice
    [Arguments]   ${is_hoan_thanh}    ${is_da_huy}    ${is_chua_giao}    ${is_dang_giao}    ${is_khong_giao_duoc}
    ${list_filter}    Create List
    Run Keyword If    '${is_hoan_thanh}' == 'True'        Append To List    ${list_filter}    Status+eq+1
    Run Keyword If    '${is_da_huy}' == 'True'            Append To List    ${list_filter}    Status+eq+2
    Run Keyword If    '${is_chua_giao}' == 'True'         Append To List    ${list_filter}    Status+eq+3
    Run Keyword If    '${is_dang_giao}' == 'True'         Append To List    ${list_filter}    Status+eq+4
    Run Keyword If    '${is_khong_giao_duoc}' == 'True'   Append To List    ${list_filter}    Status+eq+5
    ${list_filter}     Evaluate    "+or+".join(${list_filter})
    Return From Keyword    ${list_filter}

Get dict invoice order uuid
    [Arguments]    ${order_uuid}    ${list_jsonpath}    ${thoi_gian}=today    ${branch_id}=${BRANCH_ID}
    ...       ${is_hoan_thanh}=True    ${is_da_huy}=False    ${is_chua_giao}=True         ${is_dang_giao}=True    ${is_khong_giao_duoc}=False

    ${filter_status}    KV Get Filter Status Invoice    ${is_hoan_thanh}    ${is_da_huy}    ${is_chua_giao}    ${is_dang_giao}    ${is_khong_giao_duoc}
    ${data_filter}    Set Variable    (BranchId+eq+${branch_id}+and+PurchaseDate+eq+'${thoi_gian}'+and+PurchaseDate+eq+'${thoi_gian}'+and+(${filter_status}))

    ${input_dict}    Create Dictionary    order_uuid=${order_uuid}    branch_id=${branch_id}    data_filter=${data_filter}
    ${result_dict}    API Call From Template    /hoa-don/get_invoice_by_uuid.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get invoice id of invoice by order uuid
    [Arguments]    ${order_uuid}
    ${result_dict}    Get dict invoice order uuid    ${order_uuid}    $.Id
    ${invoice_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${invoice_id}

Get customer id of invoice
    [Arguments]    ${id_invoice}
    ${result_dict}    Get dict all invoice frm API    $.Data[?(@.Id\=\=${id_invoice})].CustomerId
    ${customer_id}    Set Variable Return From Dict    ${result_dict.CustomerId[0]}
    Return From Keyword    ${customer_id}

Convert Value To Order Type - Service Type - Table Name
    [Arguments]    ${DiningOption_value}    ${TableAndRoom_value}
    ${order_type}    ${service_type}    ${table_name}    Run Keyword If    '${DiningOption_value}' == '1'    Set Variable    Giao đi    Giao thường    0
    ...                     ELSE IF    '${DiningOption_value}' == '2'    Set Variable    Ngồi tại bàn    0    ${TableAndRoom_value}
    ...                     ELSE IF    '${DiningOption_value}' == '3'    Set Variable    Mang về    0    0
    Return From Keyword    ${order_type}    ${service_type}    ${table_name}

Get PurchaseDate va tong tien hang sau giam gia
    [Arguments]    ${id_hd}
    ${result_dict}    Get dict all invoice frm API    $.Data[?(@.Id\=\=${id_hd})].["Total","PurchaseDate"]
    ${tong_tien_hang}    Set Variable Return From Dict    ${result_dict.Total[0]}
    ${purchaseDate_invoice}    Set Variable Return From Dict    ${result_dict.PurchaseDate[0]}
    Return From Keyword    ${purchaseDate_invoice}    ${tong_tien_hang}

#Get thông tin export chi tiết nhiều hóa đơn
Get info to export detail invoice
    [Arguments]
    ${list_jsonpath}    Create List    $.Data[?(@.Id!=-1)].["Id","SaleChannel.Id","BranchName","Code","PurchaseDate","InvoiceDeliveryCode","EntryDate","CustomerCode","CustomerName","CustomerEmail","Customer.SearchNumber","CustomerAddress","CustomerLocationName","CustomerWardName","CustomerBirthDate","SaleChannel.Name","CreatedByGivenName","PartnerDeliveryName","Description","Discount","Surcharge","Total","TotalPayment","InvoiceDeliveryPrice","StatusValue","DiningOption","TableAndRoomName","NumberCustomer"]
    # ...    $.Data[?(@.Id!=-1)].InvoiceDeliveries[*].["Receiver","ContactNumber","ExpectedDelivery"]     # check later
    ${dict_all}    Get dict all invoice frm API    ${list_jsonpath}

    ${dict_all.CustomerCode}          Set Variable Return From Dict    ${dict_all.CustomerCode}
    ${dict_all.CustomerAddress}       Set Variable Return From Dict    ${dict_all.CustomerAddress}
    ${dict_all.CustomerEmail}         Set Variable Return From Dict    ${dict_all.CustomerEmail}
    ${dict_all.CustomerBirthDate}     Set Variable Return From Dict    ${dict_all.CustomerBirthDate}
    ${dict_all.CustomerLocationName}  Set Variable Return From Dict    ${dict_all.CustomerLocationName}
    ${dict_all.CustomerWardName}      Set Variable Return From Dict    ${dict_all.CustomerWardName}
    ${dict_all.PartnerDeliveryName}   Set Variable Return From Dict    ${dict_all.PartnerDeliveryName}
    ${dict_all.InvoiceDeliveryCode}   Set Variable Return From Dict    ${dict_all.InvoiceDeliveryCode}

    # Chuẩn hóa dữ liệu trong api để khớp với file excel
    FOR    ${invoice_code}    IN    @{dict_all.Code}
        ${index}    Get Index From List    ${dict_all.Code}    ${invoice_code}
        ${customer_name}    Set Variable If    '${dict_all.CustomerName[${index}]}'=='${EMPTY}'    Khách lẻ    ${dict_all.CustomerName[${index}]}
        Set List Value    ${dict_all.CustomerName}    ${index}    ${customer_name}
        ${SaleChannel_name}    Set Variable If    ${dict_all.Id1[${index}]}==0    Bán trực tiếp    ${dict_all.Name[${index}]}
        Set List Value    ${dict_all.Name}    ${index}    ${SaleChannel_name}
    END
    ${dict_all.CustomerBirthDate}   KV Convert DateTime To String    ${dict_all.CustomerBirthDate}    result_format=%Y-%m-%d %H:%M:%S
    ${dict_all.PurchaseDate}        KV Convert DateTime To String    ${dict_all.PurchaseDate}         result_format=%Y-%m-%d %H:%M:%S
    ${dict_all.EntryDate}           KV Convert DateTime To String    ${dict_all.EntryDate}            result_format=%Y-%m-%d %H:%M:%S

    ${result_dict}    Create Dictionary     unique_key=@{EMPTY}          BranchName=@{EMPTY}            Code=@{EMPTY}                 EntryDate=@{EMPTY}
    ...    OrderCode=@{EMPTY}            CustomerCode=@{EMPTY}           CustomerName=@{EMPTY}          CustomerEmail=@{EMPTY}        SearchNumber=@{EMPTY}
    ...    CustomerAddress=@{EMPTY}      CustomerLocationName=@{EMPTY}   CustomerWardName=@{EMPTY}      CustomerBirthDate=@{EMPTY}    SoldByGivenName=@{EMPTY}
    ...    SaleChannelName=@{EMPTY}      CreatedByGivenName=@{EMPTY}     PartnerDeliveryName=@{EMPTY}
    ...    Address=@{EMPTY}              LocationName=@{EMPTY}           WardName=@{EMPTY}              ServiceType=@{EMPTY}          PurchaseDate=@{EMPTY}
    ...    Description=@{EMPTY}          InvoiceDeliveryCode=@{EMPTY}
    ...    OrderTotal=@{EMPTY}           Discount=@{EMPTY}               Surcharge=@{EMPTY}             Total=@{EMPTY}                TotalPayment=@{EMPTY}
    ...    CashAmount=@{EMPTY}           CardAmount=@{EMPTY}             TransferAmount=@{EMPTY}        PointAmount=@{EMPTY}          InvoiceDeliveryPrice=@{EMPTY}
    ...    StatusValue=@{EMPTY}            ProductCode=@{EMPTY}           ProductName=@{EMPTY}          ProductUnit=@{EMPTY}
    ...    ProductNote=@{EMPTY}          ProductQuantity=@{EMPTY}        ProductPrice=@{EMPTY}          ProductDiscountVND=@{EMPTY}   ProductDiscount_phan_tram=@{EMPTY}
    ...    PriceAfterDiscount=@{EMPTY}   SubTotal=@{EMPTY}               OrderType=@{EMPTY}             TableAndRoom=@{EMPTY}         NumberCustomer=@{EMPTY}
    ...    ReceiverName=@{EMPTY}         ReceiverPhone=@{EMPTY}       ExpectedDelivery=@{EMPTY}

    FOR    ${invoice_id}    IN    @{dict_all.Id}
        ${index}    Get Index From List    ${dict_all.Id}    ${invoice_id}
        Invoice mix data from api    ${invoice_id}    ${dict_all}    ${result_dict}    ${index}
    END
    Return From Keyword    ${result_dict}

Invoice mix data from api
    [Arguments]    ${invoice_id}    ${dict_all}    ${result_dict}    ${invoice_index}
    ${list_jsonpath}    Create List    $.Payments[?(@.Method=="Cash")].Amount    $.Payments[?(@.Method=="Card")].Amount    $.Payments[?(@.Method=="Transfer")].Amount    $.Payments[?(@.Method=="Point")].Amount
    ...    $.Order[*].["Code","Total"]    $.InvoiceDetails[*].["ProductCode","ProductName","Product.Unit","Note","Quantity","Price","DiscountRatio","Discount","SubTotal"]
    ...    $.InvoiceDelivery[*].["Receiver","ContactNumber","ExpectedDelivery","Address","LocationName","WardName"]
    ...    $.SoldByGivenName

    ${dict_detail}    Get dict detail invoice frm API    ${invoice_id}    ${list_jsonpath}
    ${order_code}     Set Variable Return From Dict    ${dict_detail.Code[0]}
    # Tính tổng tiền hàng của hóa đơn
    ${count_total}    Sum values in list    ${dict_detail.SubTotal}

    ${amount_cash}       Set Variable Return From Dict    ${dict_detail.Amount[0]}
    ${amount_card}       Set Variable Return From Dict    ${dict_detail.Amount2[0]}
    ${amount_transfer}   Set Variable Return From Dict    ${dict_detail.Amount3[0]}
    ${amount_point}      Set Variable Return From Dict    ${dict_detail.Amount4[0]}
    ${dict_detail.ProductNote}   Set Variable Return From Dict    ${dict_detail.Note}
    ${dict_detail.ProductUnit}   Set Variable Return From Dict    ${dict_detail.Unit}
    ${delivery_Receiver}         Set Variable Return From Dict    ${dict_detail.Receiver[0]}
    ${delivery_Address}          Set Variable Return From Dict    ${dict_detail.Address[0]}
    ${delivery_LocationName}     Set Variable Return From Dict    ${dict_detail.LocationName[0]}
    ${delivery_WardName}         Set Variable Return From Dict    ${dict_detail.WardName[0]}
    ${delivery_ContactNumber}    Set Variable Return From Dict    ${dict_detail.ContactNumber[0]}
    ${dict_detail.ExpectedDelivery}   Set Variable Return From Dict    ${dict_detail.ExpectedDelivery}
    ${dict_detail.ExpectedDelivery}   KV Convert DateTime To String    ${dict_detail.ExpectedDelivery}    result_format=%Y-%m-%d %H:%M:%S

    # Convert data from api to 'Loai don hang' column in excel
    ${order_type}    ${service_type}    ${table_name}   Convert Value To Order Type - Service Type - Table Name    ${dict_all.DiningOption[${invoice_index}]}    ${dict_all.TableAndRoomName[${invoice_index}]}

    FOR    ${pr_code}    IN    @{dict_detail.ProductCode}
        ${index}    Get Index From List    ${dict_detail.ProductCode}    ${pr_code}
        # Tinh gia ban sau GG cua hang hoa
        ${price_af_discount}    Minus    ${dict_detail.Price[${index}]}    ${dict_detail.Discount[${index}]}
        # Get tên HH kèm thuộc tính
        ${name_with_attr}    Get product name with attribute    ${dict_detail.ProductCode[${index}]}    ${dict_detail.ProductName[${index}]}    ${dict_detail.Unit[${index}]}
        # ${name_with_attr}    Strip String    ${name_with_attr}
        # Set unique key
        ${unique_value}    Set Variable    ${dict_all.Code[${invoice_index}]}-${dict_detail.ProductCode[${index}]}

        Append To List    ${result_dict.unique_key}            ${unique_value}
        Append To List    ${result_dict.BranchName}            ${dict_all.BranchName[${invoice_index}]}
        Append To List    ${result_dict.Code}                  ${dict_all.Code[${invoice_index}]}
        Append To List    ${result_dict.PurchaseDate}          ${dict_all.PurchaseDate[${invoice_index}]}
        Append To List    ${result_dict.InvoiceDeliveryCode}   ${dict_all.InvoiceDeliveryCode[${invoice_index}]}
        Append To List    ${result_dict.OrderCode}             ${order_code}
        Append To List    ${result_dict.CustomerCode}          ${dict_all.CustomerCode[${invoice_index}]}
        Append To List    ${result_dict.CustomerName}          ${dict_all.CustomerName[${invoice_index}]}
        Append To List    ${result_dict.CustomerEmail}         ${dict_all.CustomerEmail[${invoice_index}]}
        Append To List    ${result_dict.SearchNumber}          ${dict_all.SearchNumber[${invoice_index}]}
        Append To List    ${result_dict.CustomerAddress}       ${dict_all.CustomerAddress[${invoice_index}]}
        Append To List    ${result_dict.CustomerLocationName}  ${dict_all.CustomerLocationName[${invoice_index}]}
        Append To List    ${result_dict.CustomerWardName}      ${dict_all.CustomerWardName[${invoice_index}]}
        Append To List    ${result_dict.CustomerBirthDate}     ${dict_all.CustomerBirthDate[${invoice_index}]}
        Append To List    ${result_dict.SoldByGivenName}       ${dict_detail.SoldByGivenName[0]}
        Append To List    ${result_dict.SaleChannelName}       ${dict_all.Name[${invoice_index}]}
        Append To List    ${result_dict.CreatedByGivenName}    ${dict_all.CreatedByGivenName[${invoice_index}]}
        Append To List    ${result_dict.PartnerDeliveryName}   ${dict_all.PartnerDeliveryName[${invoice_index}]}
        Append To List    ${result_dict.ReceiverName}          ${delivery_Receiver}
        Append To List    ${result_dict.ReceiverPhone}         ${delivery_ContactNumber}
        Append To List    ${result_dict.Address}               ${delivery_Address}
        Append To List    ${result_dict.LocationName}          ${delivery_LocationName}
        Append To List    ${result_dict.WardName}              ${delivery_WardName}
        Append To List    ${result_dict.ServiceType}           ${service_type}
        Append To List    ${result_dict.EntryDate}             ${dict_all.EntryDate[${invoice_index}]}
        Append To List    ${result_dict.Description}           ${dict_all.Description[${invoice_index}]}
        Append To List    ${result_dict.OrderTotal}            ${count_total}
        Append To List    ${result_dict.Discount}              ${dict_all.Discount[${invoice_index}]}
        Append To List    ${result_dict.Surcharge}             ${dict_all.Surcharge[${invoice_index}]}
        Append To List    ${result_dict.Total}                 ${dict_all.Total[${invoice_index}]}
        Append To List    ${result_dict.TotalPayment}          ${dict_all.TotalPayment[${invoice_index}]}
        Append To List    ${result_dict.CashAmount}            ${amount_cash}
        Append To List    ${result_dict.CardAmount}            ${amount_card}
        Append To List    ${result_dict.TransferAmount}        ${amount_transfer}
        Append To List    ${result_dict.PointAmount}           ${amount_point}
        Append To List    ${result_dict.InvoiceDeliveryPrice}  ${dict_all.InvoiceDeliveryPrice[${invoice_index}]}
        Append To List    ${result_dict.ExpectedDelivery}      ${dict_detail.ExpectedDelivery[0]}
        Append To List    ${result_dict.StatusValue}           ${dict_all.StatusValue[${invoice_index}]}
        Append To List    ${result_dict.ProductCode}           ${dict_detail.ProductCode[${index}]}
        Append To List    ${result_dict.ProductName}           ${name_with_attr}
        Append To List    ${result_dict.ProductUnit}           ${dict_detail.Unit[${index}]}
        Append To List    ${result_dict.ProductNote}           ${dict_detail.Note[${index}]}
        Append To List    ${result_dict.ProductQuantity}       ${dict_detail.Quantity[${index}]}
        Append To List    ${result_dict.ProductPrice}          ${dict_detail.Price[${index}]}
        Append To List    ${result_dict.ProductDiscount_phan_tram}      ${dict_detail.DiscountRatio[${index}]}
        Append To List    ${result_dict.ProductDiscountVND}    ${dict_detail.Discount[${index}]}
        Append To List    ${result_dict.PriceAfterDiscount}    ${price_af_discount}
        Append To List    ${result_dict.SubTotal}              ${dict_detail.SubTotal[${index}]}
        Append To List    ${result_dict.OrderType}             ${order_type}
        Append To List    ${result_dict.TableAndRoom}          ${table_name}
        Append To List    ${result_dict.NumberCustomer}        ${dict_all.NumberCustomer[${invoice_index}]}
    END

# Get thông tin export tổng quan hóa đơn
Get info to export all invoice
    [Arguments]
    ${list_jsonpath_all}    Create List    $.Data[?(@.Id!=-1)].["Id","Code","PurchaseDate","CustomerName","Discount","TotalPayment"]
    ${dict_all}    Get dict all invoice frm API    ${list_jsonpath_all}
    # Chuẩn hóa dữ liệu trong api để khớp với file excel
    FOR    ${invoice_code}    IN    @{dict_all.Code}
        ${index}    Get Index From List    ${dict_all.Code}    ${invoice_code}
        ${customer_name}    Set Variable If    '${dict_all.CustomerName[${index}]}'=='${EMPTY}'    Khách lẻ    ${dict_all.CustomerName[${index}]}
        Set List Value    ${dict_all.CustomerName}    ${index}    ${customer_name}
    END
    ${dict_all.PurchaseDate}    KV Convert DateTime To String    ${dict_all.PurchaseDate}    result_format=%d/%m/%Y %H:%M
    # Tính tổng tiền hàng của hóa đơn
    ${list_jsonpath_detail}    Create List     $.InvoiceDetails[*].["SubTotal"]
    ${list_tong_tien}    Create List
    FOR    ${invoice_id}    IN    @{dict_all.Id}
        ${dict_detail}    Get dict detail invoice frm API    ${invoice_id}    ${list_jsonpath_detail}
        ${count_total}    Sum values in list    ${dict_detail.SubTotal}
        Append To List    ${list_tong_tien}    ${count_total}
    END
    Set To Dictionary    ${dict_all}    OrderTotal    ${list_tong_tien}
    Remove From Dictionary    ${dict_all}    Id
    Return From Keyword    ${dict_all}

# Get thông tin export chi tiết 1 hóa đơn
Get info to export one invoice
    [Arguments]    ${id_hd}
    ${list_jsonpath}    Create List    $.InvoiceDetails[*].["ProductCode","ProductName","Product.Unit","Quantity","Price","Discount","DiscountRatio","SubTotal"]
    ...    $.["TotalQuantity","SubTotal","DiscountRatio","Discount","Total"]
    ${dict_detail}    Get dict detail invoice frm API    ${id_hd}    ${list_jsonpath}
    ${dict_detail.Unit}    Set Variable Return From Dict    ${dict_detail.Unit}
    ${result_dict}    Create Dictionary     ma_hang=@{EMPTY}    ten_hang=@{EMPTY}    dvt=@{EMPTY}   sl=@{EMPTY}   don_gia=@{EMPTY}   GG_phantram=@{EMPTY}
    ...    giam_gia=@{EMPTY}    gia_ban=@{EMPTY}    thanh_tien=@{EMPTY}

    FOR    ${pr_code}    IN    @{dict_detail.ProductCode}
        ${index}    Get Index From List    ${dict_detail.ProductCode}    ${pr_code}
        # Tinh gia ban sau GG cua hang hoa
        ${price_af_discount}    Minus    ${dict_detail.Price[${index}]}    ${dict_detail.Discount[${index}]}
        # Get tên HH kèm thuộc tính
        ${name_with_attr}    Get product name with attribute    ${dict_detail.ProductCode[${index}]}    ${dict_detail.ProductName[${index}]}    ${dict_detail.Unit[${index}]}
        Append To List    ${result_dict.ma_hang}        ${pr_code}
        Append To List    ${result_dict.ten_hang}       ${name_with_attr}
        Append To List    ${result_dict.dvt}            ${dict_detail.Unit[${index}]}
        Append To List    ${result_dict.sl}             ${dict_detail.Quantity[${index}]}
        Append To List    ${result_dict.don_gia}        ${dict_detail.Price[${index}]}
        Append To List    ${result_dict.GG_phantram}    ${dict_detail.DiscountRatio[${index}]}
        Append To List    ${result_dict.giam_gia}       ${dict_detail.Discount[${index}]}
        Append To List    ${result_dict.gia_ban}        ${price_af_discount}
        Append To List    ${result_dict.thanh_tien}     ${dict_detail.SubTotal[${index}]}
    END
    ${dict_summary}    Create Dictionary    tong_sl=@{EMPTY}    tong_tien_hang=@{EMPTY}    GG_phantram=@{EMPTY}    GG_VND=@{EMPTY}    tong_cong=@{EMPTY}
    Append To List    ${dict_summary.tong_sl}          ${dict_detail.TotalQuantity[0]}
    Append To List    ${dict_summary.tong_tien_hang}   ${dict_detail.SubTotal2[0]}
    Append To List    ${dict_summary.GG_phantram}      ${dict_detail.DiscountRatio2[0]}
    Append To List    ${dict_summary.GG_VND}           ${dict_detail.Discount2[0]}
    Append To List    ${dict_summary.tong_cong}        ${dict_detail.Total[0]}
    ${tong_hh}    Get Length    ${dict_detail.ProductCode}
    Return From Keyword    ${dict_summary}    ${result_dict}    ${tong_hh}

Assert thong tin hoa don sau khi thanh toan
    [Arguments]    ${order_code}    ${input_list_pr}
    ${order_uuid}    Get order uuid by order code    ${order_code}    True
    ${list_jsonpath}    Create List    $.["Code","Id","Total"]    $.InvoiceDetails[*].ProductCode
    ${result_dict}     Get dict invoice order uuid    ${order_uuid}    ${list_jsonpath}
    ${invoice_code}    Set Variable    ${result_dict.Code[0]}
    ${invoice_id}      Set Variable    ${result_dict.Id[0]}
    ${total}           Set Variable    ${result_dict.Total[0]}
    ${get_list_pr}     Set Variable    ${result_dict.ProductCode}
    KV Lists should Be Equal    ${input_list_pr}    ${get_list_pr}    msg=Thông tin hóa đơn lưu không đúng danh sách hàng hóa
    Return From Keyword    ${invoice_id}    ${invoice_code}    ${total}

Assert thong tin hoa don tu android api
    [Arguments]    ${invoice_id}    ${input_list_pr}
    ${list_jsonpath}    Create List    $.InvoiceDetails[*].ProductCode
    ${result_dict}     Get dict detail invoice from mobile api    ${invoice_id}    ${list_jsonpath}
    ${get_list_pr}     Set Variable    ${result_dict.ProductCode}
    KV Lists should Be Equal    ${input_list_pr}    ${get_list_pr}    msg=Thông tin hóa đơn lưu không đúng danh sách hàng hóa trên android

Assert info customer in Invoice
    [Arguments]    ${order_uuid}    ${customer_code}
    ${result_dict}    Get dict invoice order uuid    ${order_uuid}    $.["CustomerCode","Id"]
    ${get_invoice_id}    Set Variable    ${result_dict.Id[0]}
    ${get_cus_code}    Set Variable Return From Dict    ${result_dict.CustomerCode[0]}
    KV Should Be Equal As Strings    ${customer_code}    ${get_cus_code}    msg=Sai thông tin khách hàng
    Return From Keyword    ${get_invoice_id}

Assert PhoneNumber customer in Invoice
    [Arguments]    ${order_uuid}    ${customer_SDT}
    ${result_dict}    Get dict invoice order uuid    ${order_uuid}    $.["Id","CustomerContactNumber"]
    ${get_invoice_id}    Set Variable    ${result_dict.Id[0]}
    ${get_cus_phoneNumber}    Set Variable Return From Dict    ${result_dict.CustomerContactNumber[0]}
    KV Should Be Equal As Strings    ${customer_SDT}    ${get_cus_phoneNumber}    msg=Sai thông tin số điện thoại khách hàng
    Return From Keyword    ${get_invoice_id}

Assert Name customer in Invoice
    [Arguments]    ${order_uuid}    ${customer_Name}
    ${result_dict}    Get dict invoice order uuid    ${order_uuid}    $.["Id","CustomerName"]
    ${get_invoice_id}    Set Variable    ${result_dict.Id[0]}
    ${get_cus_Name}    Set Variable Return From Dict    ${result_dict.CustomerName[0]}
    KV Should Be Equal As Strings    ${customer_Name}    ${get_cus_Name}    msg=Sai thông tin tên khách hàng
    Return From Keyword    ${get_invoice_id}

# Hai
Get dict payment history info frm API
    [Arguments]    ${invoice_id}    ${payment_code}    ${list_key}     ${json_path}=${EMPTY}    ${list_key_path}=$..Data[?(@.Code\=\="${payment_code}")]
    ${list_json_path}    Get List JSONPath    ${list_key}     ${json_path}    ${list_key_path}
    ${find_dict}    Create Dictionary    invoice_id=${invoice_id}
    ${result_dict}    API Call From Template    /hoa-don/lich_su_thanh_toan.txt    ${find_dict}    ${list_json_path}
    Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get payment code in payment history
    [Arguments]    ${invoice_id}
    ${dict_payment}    Get dict payment history info frm API    ${invoice_id}    ${EMPTY}    ${EMPTY}    $..Data[*].Code
    ${payment_code}    Set Variable Return From Dict    ${dict_payment.Code[0]}
    Return From Keyword    ${payment_code}

Get list phuong thuc thanh toan trong hoa don
    [Arguments]    ${invoice_id}
    ${dict_method}    Get dict detail invoice frm API    ${invoice_id}    $..Payments[*].Method
    ${get_list_method}    Set Variable    ${dict_method.Method}
    Return From Keyword    ${get_list_method}

Get thu khac trong hoa don
    [Arguments]    ${invoice_id}
    ${dict_surcharge}    Get dict detail invoice frm API    ${invoice_id}    $.Surcharge
    ${get_thu_khac}    Set Variable    ${dict_surcharge.Surcharge[0]}
    Return From Keyword    ${get_thu_khac}

Get list ma va SL hang hoa trong hoa don
    [Arguments]    ${invoice_id}
    ${result_dict}    Get dict detail invoice frm API    ${invoice_id}    $.InvoiceDetails[*].["Code","Quantity"]
    Return From Keyword    ${result_dict.Code}    ${result_dict.Quantity}

Assert phuong thuc thanh toan trong hoa don
    [Arguments]    ${invoice_id}    ${input_list_method}
    ${type_input_list_method}    Evaluate    type($input_list_method).__name__
    ${input_list_method}    Run Keyword If    '${type_input_list_method}'=='list'    Set Variable    ${input_list_method}    ELSE    Create List    ${input_list_method}
    ${get_list_method}    Get list phuong thuc thanh toan trong hoa don    ${invoice_id}
    ${get_list_method}    Convert EN Method To VI    ${get_list_method}
    KV Lists Should Be Equal    ${input_list_method}    ${get_list_method}    msg=Lỗi sai phương thức thanh toán

Assert thu khac trong hoa don
    [Arguments]    ${invoice_id}    ${input_surcharge}
    ${get_thu_khac}    Get thu khac trong hoa don    ${invoice_id}
    KV Should Be Equal     ${input_surcharge}    ${get_thu_khac}    msg=Lỗi sai thu khác

# hạnh
Get dict Sale Channel by name
    [Arguments]    ${list_json_path}
    ${result_dict}    API Call From Template    /kenh-ban/all_kenh_ban_hang.txt    json_path=${list_json_path}
    Return From Keyword    ${result_dict}

Get list sale channel id by name
    [Arguments]    ${list_salechannel_name}
    ${type_data}    Evaluate    type($list_salechannel_name).__name__
    ${list_salechannel_name}   Run Keyword If    '${type_data}'=='list'    Set Variable    ${list_salechannel_name}    ELSE    Create List    ${list_salechannel_name}
    ${result_dict}    Get dict Sale Channel by name    $.Data[*].["Id","Name"]
    ${list_id}    Create List
    FOR    ${salechannel_name}    IN ZIP    ${list_salechannel_name}
        ${index}    Get Index From List    ${result_dict.Name}    ${salechannel_name}
        Append To List    ${list_id}    ${result_dict.Id[${index}]}
    END
    Run Keyword If    '${type_data}'=='list'   Return From Keyword    ${list_id}    ELSE    Return From Keyword    ${list_id[0]}

Get sale channel id by name
    [Arguments]    ${salechannel_name}
    ${result_dict}    Get dict Sale Channel by name    $.Data[?(@.Name\=\="${salechannel_name}")].Id
    ${salechannel_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${salechannel_id}

Get Infomation Invoice By id
    [Arguments]    ${invoice_id}
    ${list_jsonpath}     Create List    $.InvoiceDetails[*].["Product.Code","Quantity","Discount","Price","Note"]    $.PriceBook.Name    $.SaleChannel.Id
    ...    $.["TableId","Total","Description","CustomerId","TotalPayment","User.GivenName"]    $.InvoiceOrderSurcharges[*].["SurchargeId"]
    ${result_invoice_dict}    Get dict detail invoice frm API    ${invoice_id}    ${list_jsonpath}
    KV Log   ${result_invoice_dict}
    ${list_invoice_SurchargeId}     Set Variable Return From Dict    ${result_invoice_dict.SurchargeId}
    ${list_invoice_code}    Set Variable Return From Dict    ${result_invoice_dict.Code}
    ${list_invoice_quantity}     Set Variable Return From Dict    ${result_invoice_dict.Quantity}
    ${list_invoice_Discount}    Set Variable Return From Dict    ${result_invoice_dict.Discount}
    ${list_invoice_Price}    Set Variable Return From Dict    ${result_invoice_dict.Price}
    ${list_invoice_note}    Set Variable Return From Dict    ${result_invoice_dict.Note}
    ${invoice_priceBook}    Set Variable Return From Dict    ${result_invoice_dict.Name[0]}
    ${invoice_saleChannel}    Set Variable Return From Dict    ${result_invoice_dict.Id[0]}
    ${invoice_table_id}    Set Variable Return From Dict    ${result_invoice_dict.TableId[0]}
    ${invoice_Description}    Set Variable Return From Dict    ${result_invoice_dict.Description[0]}
    ${invoice_CustomerId}    Set Variable Return From Dict    ${result_invoice_dict.CustomerId[0]}
    ${invoice_Total_payment}    Set Variable Return From Dict    ${result_invoice_dict.TotalPayment[0]}
    ${invoice_CreatByName}    Set Variable Return From Dict    ${result_invoice_dict.GivenName[0]}
    Return From Keyword    ${list_invoice_code}    ${list_invoice_quantity}    ${list_invoice_Discount}    ${list_invoice_Price}    ${list_invoice_note}
    ...    ${invoice_priceBook}    ${invoice_saleChannel}    ${invoice_table_id}    ${invoice_Description}    ${invoice_CustomerId}
    ...    ${list_invoice_SurchargeId}    ${invoice_Total_payment}    ${invoice_CreatByName}

Get invoice id by order code
    [Arguments]    ${order_code}    ${branch_id}=${BRANCH_ID}
    ${order_uuid}    Get order uuid by order code    ${order_code}    branch_id=${branch_id}
    ${result_dict}    Get dict invoice order uuid    ${order_uuid}    $.Id    branch_id=${branch_id}
    ${invoice_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${invoice_id}

Get invoice code by order code
    [Arguments]    ${order_code}
    ${order_uuid}    Get order uuid by order code    ${order_code}
    ${result_dict}    Get dict invoice order uuid    ${order_uuid}    $.Code
    ${invoice_code}    Set Variable Return From Dict    ${result_dict.Code[0]}
    Return From Keyword    ${invoice_code}

Get invoice code by invoice id
    [Arguments]    ${invoice_id}
    ${dict_method}    Get dict detail invoice frm API    ${invoice_id}    $.Data[?(@.Id\=\="${invoice_id}")].Code
    ${invoice_code}    Set Variable    ${dict_method.Code[0]}
    Return From Keyword    ${invoice_code}

Get list invoice code by invoice id
    [Arguments]    ${list_invoice_id}
    ${list_invoice_code}    Create List
    FOR   ${invoice_id}    IN ZIP    ${list_invoice_id}
        ${invoice_code}    Get invoice code by invoice id    ${invoice_id}
        Append To List    ${list_invoice_code}    ${invoice_code}
    END
    Return From Keyword    ${list_invoice_code}

Get invoice id frm API by order code
    [Arguments]    ${order_code}    ${time_filter}=today   ${branch_id}=${BRANCH_ID}
    Sleep    3s
    ${start_date}    ${end_date}    KV Get Start End Date By Filter    ${time_filter}
    ${list_jsonpath_invoices}    Create List    $.Data[?(@.Id!=-1)].Id
    ${dict_invoice_id}    Get dict all invoice frm API    ${list_jsonpath_invoices}    branch_id=${branch_id}
    ${list_invoice_id}    Set Variable    ${dict_invoice_id.Id}
    ${list_jsonpath_detail}    Create List    $.OrderCode
    FOR    ${item_invoice_id}    IN ZIP    ${list_invoice_id}
        ${result_dict}    Get dict detail invoice frm API   ${item_invoice_id}    ${list_jsonpath_detail}
        ${get_order_code}    Set Variable    ${result_dict.OrderCode[0]}
        Run Keyword If    '${order_code}'=='${get_order_code}'    Run Keywords    Set Test Variable    ${invoice_id}    ${item_invoice_id}    AND    Exit For Loop
        ...    ELSE    Set Test Variable    ${invoice_id}    ${0}
    END
    Return From Keyword    ${invoice_id}

Assert Infomation Don Tao Tu Thu Ngan
    [Arguments]    ${invoice_id}    ${list_input_pr_code}    ${list_input_pr_quantity}    ${list_input_pr_Price}   ${list_input_pr_note}    ${input_pr_priceBook}
    ...    ${input_pr_saleChannel}    ${input_pr_table_id}    ${input_pr_Description}    ${input_pr_CustomerId}    ${list_ip_surcharge_id}
    ...    ${ip_invoice_Total_payment}   ${input_CreatByName}

    ${list_invoice_code}   ${list_invoice_quantity}    ${list_invoice_Discount}    ${list_invoice_price}    ${list_invoice_note}
    ...    ${invoice_priceBook}    ${invoice_saleChannel}    ${invoice_table_id}    ${invoice_Description}    ${invoice_CustomerId}
    ...    ${list_surcharge_id}    ${invoice_Total_payment}    ${invoice_CreatByName}    Get Infomation Invoice By id    ${invoice_id}

    ${list_iv_price_discount}    Create List
    ${ip_invoice_Total_payment}    Convert To Number    ${ip_invoice_Total_payment}
    FOR   ${invoice_note}    ${invoice_price}    ${invoice_Discount}    ${input_pr_Price}    IN ZIP    ${list_invoice_note}    ${list_invoice_price}    ${list_invoice_Discount}    ${list_input_pr_Price}
        ${invoice_note}    Set Variable If    "${invoice_note}"=="0"    ${EMPTY}    ${invoice_note}
        ${index}    Get Index From List    ${list_input_pr_Price}    ${input_pr_Price}
        ${in_price_discount}    Computation new price - discount - VND    ${invoice_price}    ${invoice_Discount}
        ${in_price_discount}    Convert To Number    ${in_price_discount}
        ${input_pr_Price}     Convert To Number    ${input_pr_Price}
        Set List Value    ${list_invoice_note}    ${index}    ${invoice_note}
        Set List Value    ${list_input_pr_Price}    ${index}    ${input_pr_Price}
        Append To List    ${list_iv_price_discount}    ${in_price_discount}
    END
    KV Lists Should Be Equal    ${list_input_pr_code}    ${list_invoice_code}               Lỗi sai thông tin code của hàng hóa input và thông tin trên hóa đơn
    KV Lists Should Be Equal    ${list_input_pr_quantity}    ${list_invoice_quantity}       Lỗi sai thông tin số lượng của hàng hóa input và thông tin trên hóa đơn
    KV Lists Should Be Equal    ${list_input_pr_Price}    ${list_iv_price_discount}         Lỗi sai thông tin giá của hàng hóa và thông tin trên hóa đơn
    KV Lists Should Be Equal    ${list_ip_surcharge_id}    ${list_surcharge_id}             Lỗi sai thông tin id thu khác và thông tin trên hóa đơn
    KV Should Be Equal          ${list_input_pr_note}    ${list_invoice_note}               Lỗi sai thông tin ghi chú của hàng hóa input và thông tin trên hóa đơn
    KV Should Be Equal          ${input_pr_priceBook}    ${invoice_priceBook}               Lỗi sai thông tin bảng giá của hàng hóa input và thông tin trên hóa đơn
    KV Should Be Equal          ${input_pr_saleChannel}    ${invoice_saleChannel}           Lỗi sai thông tin kênh bán hàng của hàng hóa input và thông tin trên hóa đơn
    KV Should Be Equal          ${input_pr_table_id}    ${invoice_table_id}                 Lỗi sai thông tin bàn của đơn và thông tin trên hóa đơn
    KV Should Be Equal          ${input_pr_Description}    ${invoice_Description}           Lỗi sai thông tin ghi chú của đơn input và thông tin trên hóa đơn
    KV Should Be Equal          ${input_pr_CustomerId}    ${invoice_CustomerId}             Lỗi sai thông tin khách hàng của đơn input và thông tin trên hóa đơn
    KV Should Be Equal          ${ip_invoice_Total_payment}    ${invoice_Total_payment}     Lỗi sai thông tin số tiền khách hàng thanh toán và thông tin trên hóa đơn
    KV Should Be Equal          ${input_CreatByName}    ${invoice_CreatByName}              Lỗi sai thông tin số tiền khách hàng thanh toán và thông tin trên hóa đơn

Assert Infomation Don Tao Tu Boi Ban
    [Arguments]    ${invoice_id}    ${list_input_pr_code}    ${list_input_pr_quantity}    ${list_input_pr_Price}   ${list_input_pr_note}
    ...    ${input_pr_saleChannel}    ${input_pr_table_id}    ${input_pr_Description}    ${input_pr_CustomerId}  ${input_CreatByName}

    ${list_invoice_code}   ${list_invoice_quantity}    ${list_invoice_Discount}    ${list_invoice_price}    ${list_invoice_note}
    ...    ${invoice_priceBook}    ${invoice_saleChannel}    ${invoice_table_id}    ${invoice_Description}    ${invoice_CustomerId}
    ...    ${list_surcharge_id}    ${invoice_Total_payment}    ${invoice_CreatByName}    Get Infomation Invoice By id    ${invoice_id}

    FOR   ${invoice_note}    ${invoice_price}    ${input_pr_Price}    IN ZIP    ${list_invoice_note}    ${list_invoice_price}    ${list_input_pr_Price}
        ${invoice_note}    Set Variable If    "${invoice_note}"=="0"    ${EMPTY}    ${invoice_note}
        ${index}    Get Index From List    ${list_input_pr_Price}    ${input_pr_Price}
        ${input_pr_Price}     Convert To Number    ${input_pr_Price}
        Set List Value    ${list_invoice_note}    ${index}    ${invoice_note}
    END
    KV Lists Should Be Equal    ${list_input_pr_code}    ${list_invoice_code}               Lỗi sai thông tin code của hàng hóa input và thông tin trên hóa đơn
    KV Lists Should Be Equal    ${list_input_pr_Price}    ${list_invoice_price}             Lỗi sai thông tin giá của hàng hóa và thông tin trên hóa đơn
    KV Lists Should Be Equal    ${list_input_pr_quantity}    ${list_invoice_quantity}       Lỗi sai thông tin số lượng của hàng hóa input và thông tin trên hóa đơn
    KV Should Be Equal          ${list_input_pr_note}    ${list_invoice_note}               Lỗi sai thông tin ghi chú của hàng hóa input và thông tin trên hóa đơn
    KV Should Be Equal          ${input_pr_saleChannel}    ${invoice_saleChannel}           Lỗi sai thông tin kênh bán hàng của hàng hóa input và thông tin trên hóa đơn
    KV Should Be Equal          ${input_pr_table_id}    ${invoice_table_id}                 Lỗi sai thông tin bàn của đơn và thông tin trên hóa đơn
    KV Should Be Equal          ${input_pr_Description}    ${invoice_Description}           Lỗi sai thông tin ghi chú của đơn input và thông tin trên hóa đơn
    KV Should Be Equal          ${input_pr_CustomerId}    ${invoice_CustomerId}             Lỗi sai thông tin khách hàng của đơn input và thông tin trên hóa đơn
    KV Should Be Equal          ${input_CreatByName}    ${invoice_CreatByName}              Lỗi sai thông tin số tiền khách hàng thanh toán và thông tin trên hóa đơn

Assert info name pricebook in invoice
    [Arguments]    ${order_code}    ${pricebook}
    ${order_uuid}    Get order uuid by order code    ${order_code}
    ${result_dict}    Get dict invoice order uuid    ${order_uuid}    $.PriceBook.CompareName
    ${name_pricebook}    Set Variable Return From Dict     ${result_dict.CompareName[0]}
    KV Should Be Equal As Strings    ${name_pricebook}    ${pricebook}    msg=Sai thông tin bảng giá

Assert list text ghi chu in invoice
    [Arguments]    ${order_code}    ${list_text_ghichu}
    ${order_uuid}    Get order uuid by order code    ${order_code}
    ${result_dict}    Get dict invoice order uuid    ${order_uuid}    $.InvoiceDetails[*].["Note"]
    ${list_ghichu}    Set Variable Return From Dict    ${result_dict.Note}
    KV Lists Should Be Equal    ${list_text_ghichu}    ${list_ghichu}    msg=Sai thông tin list ghi chú

Assert text ghi chu don in invoice
    [Arguments]    ${order_code}    ${text_ghichu}
    ${order_uuid}    Get order uuid by order code    ${order_code}
    ${result_dict}    Get dict invoice order uuid    ${order_uuid}    $.["Description"]
    ${ghichu}    Set Variable Return From Dict    ${result_dict.Description[0]}
    KV Should Be Equal    ${text_ghichu}    ${ghichu}    msg=Sai thông tin ghi chú đơn

Assert ten giaban soluong hang hoa tren invoice
    [Arguments]    ${order_code}    ${list_name_order}    ${list_price_order}    ${list_soluong_order}    ${branch_id}=${BRANCH_ID}
    ${list_jsonpath}    Create List    $.InvoiceDetails[*].["Product.Name","Quantity","Price","Discount"]
    ${order_uuid}    Get order uuid by order code    ${order_code}    branch_id=${branch_id}
    ${result_dict}    Get dict invoice order uuid    ${order_uuid}    ${list_jsonpath}     branch_id=${branch_id}
    ${list_name}    Set Variable Return From Dict    ${result_dict.Name}
    ${list_quantity}    Set Variable Return From Dict    ${result_dict.Quantity}
    ${list_price}    Set Variable Return From Dict    ${result_dict.Price}
    ${list_discount}    Set Variable Return From Dict    ${result_dict.Discount}

    ${list_iv_price_discount}    Create List
    FOR    ${price}   ${discount}    IN ZIP    ${list_price}    ${list_discount}
          ${price_discount}    Computation new price - discount - VND    ${price}    ${discount}
          ${price_discount}    Convert To Number    ${price_discount}
          Append To List    ${list_iv_price_discount}    ${price_discount}
    END
    KV Lists Should Be Equal         ${list_name_order}       ${list_name}                 msg=Sai tên hàng hóa
    KV Lists Should Be Equal         ${list_soluong_order}    ${list_quantity}             msg=Sai số lượng hàng hóa
    KV Lists Should Be Equal         ${list_price_order}      ${list_iv_price_discount}    msg=Sai giá bán hàng hóa

Assert doi tac va nguoi nhan tren man hinh thu ngan va invoice
    [Arguments]    ${order_code}    ${name_dtgh}    ${name_nguoinhan}    ${name_sdt}    ${name_diachi}    ${name_khuvuc}    ${name_phuongxa}
    ${order_uuid}    Get order uuid by order code    ${order_code}
    ${result_dict}    Get dict invoice order uuid    ${order_uuid}    $.DeliveryDetail[*].["Receiver","ContactNumber","Address","LocationName","WardName","PartnerName"]
    ${invoice_dtgh}    Set Variable Return From Dict         ${result_dict.PartnerName[0]}
    ${invoice_nguoinhan}    Set Variable Return From Dict    ${result_dict.Receiver[0]}
    ${invoice_sdt}    Set Variable Return From Dict          ${result_dict.ContactNumber[0]}
    ${invoice_diachi}    Set Variable Return From Dict       ${result_dict.Address[0]}
    ${invoice_khuvuc}    Set Variable Return From Dict       ${result_dict.LocationName[0]}
    ${invoice_phuongxa}    Set Variable Return From Dict     ${result_dict.WardName[0]}
    KV Should Be Equal    ${name_dtgh}         ${invoice_dtgh}         msg=Sai tên đối tác giao hàng
    KV Should Be Equal    ${name_nguoinhan}    ${invoice_nguoinhan}    msg=Sai tên người nhận
    KV Should Be Equal    ${name_sdt}          ${invoice_sdt}          msg=Sai tên thông tin điện thoại
    KV Should Be Equal    ${name_diachi}       ${invoice_diachi}       msg=Sai thông tin địa chỉ
    KV Should Be Equal    ${name_khuvuc}       ${invoice_khuvuc}       msg=Sai thông tin khu vực
    KV Should Be Equal    ${name_phuongxa}     ${invoice_phuongxa}     msg=Sai thông tin phường xã

Assert thong tin tong tren man hinh hoa don
    [Arguments]    ${text_tong_tien}    ${text_giam_gia}    ${text_tong_sau_GG}    ${text_khach_datra}    ${text_tong_thu_khac}    ${text_khach_cantra}    ${text_can_thu_ho}    ${text_phitra_dtgh}
    ${result_dict}    Get dict summary info invoice frm api    $.["Discount","TotalPayment","Surcharge","Total","NewInvoiceTotal","CodNeedPayment","InvoiceDeliveryPrice"]
    ${get_giam_gia}       Set Variable    ${result_dict.Discount[0]}
    ${get_khach_datra}    Set Variable    ${result_dict.TotalPayment[0]}
    ${get_khach_cantra}    Set Variable    ${result_dict.NewInvoiceTotal[0]}
    ${get_tong_thukhac}    Set Variable    ${result_dict.Surcharge[0]}
    ${get_tong_sau_GG}    Evaluate    ${result_dict.Total[0]} - ${result_dict.Surcharge[0]}
    ${get_tong_tien}      Evaluate    ${result_dict.Total[0]} - ${result_dict.Surcharge[0]} + ${get_giam_gia}
    ${get_can_thuho}      Set Variable    ${result_dict.CodNeedPayment[0]}
    ${get_phitra_dtgh}      Set Variable    ${result_dict.InvoiceDeliveryPrice[0]}

    KV Should Be Equal As Numbers    ${text_tong_tien}       ${get_tong_tien}       msg=Sai Tổng tiền ở dòng thông tin tổng tất cả các hóa đơn
    KV Should Be Equal As Numbers    ${text_giam_gia}        ${get_giam_gia}        msg=Sai Giảm giá ở dòng thông tin tổng tất cả các hóa đơn
    KV Should Be Equal As Numbers    ${text_tong_sau_GG}     ${get_tong_sau_GG}     msg=Sai Tổng sau GG ở dòng thông tin tổng tất cả các hóa đơn
    KV Should Be Equal As Numbers    ${text_khach_datra}     ${get_khach_datra}     msg=Sai Khách đã trả ở dòng thông tin tổng tất cả các hóa đơn
    KV Should Be Equal As Numbers    ${text_khach_cantra}    ${get_khach_cantra}    msg=Sai Khách cần trả ở dòng thông tin tổng tất cả các hóa đơn
    KV Should Be Equal As Numbers    ${text_tong_thu_khac}   ${get_tong_thukhac}    msg=Sai Thu khác ở dòng thông tin tổng tất cả các hóa đơn
    KV Should Be Equal As Numbers    ${text_can_thu_ho}      ${get_can_thuho}       msg=Sai Cần thu hộ ở dòng thông tin tổng hóa đơn
    KV Should Be Equal As Numbers    ${text_phitra_dtgh}     ${get_phitra_dtgh}     msg=Sai Phí trả ĐTGH ở dòng thông tin tổng hóa đơn

Assert thong tin hoa don sau khi chuyen loai order
    [Arguments]    ${ma_order}    ${loai_ban}    ${list_pr_code}    ${list_SL}    ${list_price_bg}    ${pricebook}    ${sl_khach}    ${cus_code}    ${kenh_ban}    ${ghi_chu_don}
    ${order_uuid}    Get order uuid by order code    ${ma_order}
    ${list_jsonpath}    Create List    $.["Customer.Code","SaleChannel.Name","Description","PriceBook.Id","NumberCustomer","DiningOption"]
    ...    $.InvoiceDetails[*].["ProductCode","Quantity","Price"]
    ${result_dict}    Get dict invoice order uuid      ${order_uuid}    ${list_jsonpath}
    KV Lists Should Be Equal    ${list_pr_code}        ${result_dict.ProductCode}           msg=Lưu sai thông tin mã hàng hóa
    KV Lists Should Be Equal    ${list_SL}             ${result_dict.Quantity}              msg=Lưu sai thông tin SL hàng hóa
    KV Lists Should Be Equal    ${list_price_bg}       ${result_dict.Price}                 msg=Lưu sai thông tin giá hàng hóa
    KV Should Be Equal As Strings    ${cus_code}       ${result_dict.Code[0]}               msg=Lưu sai thông tin khách hàng
    KV Should Be Equal As Strings    ${kenh_ban}       ${result_dict.Name[0]}               msg=Lưu sai thông tin khách hàng
    KV Should Be Equal As Strings    ${ghi_chu_don}    ${result_dict.Description[0]}        msg=Lưu sai thông tin khách hàng
    KV Should Be Equal As Strings    ${pricebook}   ${result_dict.Id[0]}                 msg=Lưu sai thông tin bảng giá
    KV Should Be Equal As Numbers    ${sl_khach}       ${result_dict.NumberCustomer[0]}     msg=Lưu sai thông tin SL khách
    KV Should Be Equal As Strings    ${loai_ban}       ${result_dict.DiningOption[0]}       msg=Lưu sai thông tin loại phòng bàn

Assert thong tin hoa don sau khi chuyen ngoi tai ban sang ngoi tai ban
    [Arguments]    ${ma_order}    ${loai_ban}    ${list_pr_code}    ${list_SL}    ${list_price_bg}    ${pricebook_id}    ${sl_khach}    ${cus_code}    ${kenh_ban}    ${ghi_chu_don}
    ...    ${table_id}
    ${order_uuid}    Get order uuid by order code    ${ma_order}
    ${list_jsonpath}    Create List    $.["Customer.Code","SaleChannel.Name","Description","PriceBook.Id","NumberCustomer","DiningOption","TableId"]
    ...    $.InvoiceDetails[*].["ProductCode","Quantity","Price"]
    ${result_dict}    Get dict invoice order uuid      ${order_uuid}    ${list_jsonpath}
    KV Lists Should Be Equal    ${list_pr_code}        ${result_dict.ProductCode}           msg=Lưu sai thông tin mã hàng hóa
    KV Lists Should Be Equal    ${list_SL}             ${result_dict.Quantity}              msg=Lưu sai thông tin SL hàng hóa
    KV Lists Should Be Equal    ${list_price_bg}       ${result_dict.Price}                 msg=Lưu sai thông tin giá hàng hóa
    KV Should Be Equal As Strings    ${cus_code}       ${result_dict.Code[0]}               msg=Lưu sai thông tin khách hàng
    KV Should Be Equal As Strings    ${kenh_ban}       ${result_dict.Name[0]}               msg=Lưu sai thông tin khách hàng
    KV Should Be Equal As Strings    ${ghi_chu_don}    ${result_dict.Description[0]}        msg=Lưu sai thông tin khách hàng
    KV Should Be Equal As Strings    ${pricebook_id}   ${result_dict.Id[0]}                 msg=Lưu sai thông tin bảng giá
    KV Should Be Equal As Numbers    ${sl_khach}       ${result_dict.NumberCustomer[0]}     msg=Lưu sai thông tin SL khách
    KV Should Be Equal As Strings    ${loai_ban}     ${result_dict.DiningOption[0]}         msg=Lưu sai thông tin loại phòng bàn
    KV Should Be Equal As Strings    ${table_id}     ${result_dict.TableId[0]}              msg=Lưu sai thông tin tên phòng bàn

Assert thong tin chi tiet trong hoa don ghep ban
    [Arguments]    ${invoice_id}    ${in_name_table}    ${in_customer_code}    ${in_number_customer}    ${in_order_note}    ${in_salechannel_id}
    ${list_jsonpath}    Create List    $.Data[?(@.Id\=\=${invoice_id})].["TableAndRoomName","CustomerCode","NumberCustomer","Description","SaleChannelId"]
    ${result_dict}    Get dict all invoice frm API    ${list_jsonpath}
    ${name_table}         Set Variable Return From Dict    ${result_dict.TableAndRoomName[0]}
    ${customer_code}      Set Variable Return From Dict    ${result_dict.CustomerCode[0]}
    ${number_customer}    Set Variable Return From Dict    ${result_dict.NumberCustomer[0]}
    ${order_note}         Set Variable Return From Dict    ${result_dict.Description[0]}
    ${salechannel_id}     Set Variable Return From Dict    ${result_dict.SaleChannelId[0]}
    KV Should Be Equal    ${name_table}         ${in_name_table}         msg=Sai thông tin bàn thanh toán trong hóa đơn
    KV Should Be Equal    ${customer_code}      ${in_customer_code}      msg=Sai thông tin khách hàng trong hóa đơn
    KV Should Be Equal    ${number_customer}    ${in_number_customer}    msg=Sai thông tin số lượng khách trong hóa đơn
    KV Should Be Equal    ${order_note}         ${in_order_note}         msg=Sai thông tin ghi chú trong hóa đơn
    KV Should Be Equal    ${salechannel_id}     ${in_salechannel_id}     msg=Sai thông tin kênh bán trong hóa đơn

Get list name thu khac trong hoa don
    [Arguments]    ${invoice_id}
    ${dict_surcharge}    Get dict detail invoice frm API    ${invoice_id}    $.InvoiceOrderSurcharges[*].["SurchargeName","Price"]
    ${list_name_TK}    Set Variable    ${dict_surcharge.SurchargeName}
    ${list_giatri_TK}    Set Variable    ${dict_surcharge.Price}
    Return From Keyword    ${list_name_TK}    ${list_giatri_TK}

Assert thong tin list thu khac trong invoice
    [Arguments]    ${invoice_id}    ${in_list_name_tk}    ${in_list_giatri_tk}
    ${list_name_tk}    ${list_giatri_tk}    Get list name thu khac trong hoa don    ${invoice_id}
    KV Lists Should Be Equal    ${list_name_tk}    ${in_list_name_tk}    msg=Lỗi sai tên thu khác
    KV Lists Should Be Equal    ${list_giatri_tk}    ${in_list_giatri_tk}    msg=Lỗi sai giá trị thu khác

Assert thong tin hoa don ngoi tai ban
    [Arguments]    ${ma_order}    ${list_pr_code}    ${list_SL}    ${list_price_bg}    ${pricebook_id}    ${sl_khach}    ${cus_code}    ${kenh_ban}    ${ghi_chu_don}
    ...    ${table_name}
    ${order_uuid}    Get order uuid by order code    ${ma_order}
    ${list_jsonpath}    Create List    $.["Customer.Code","SaleChannel.Name","Description","PriceBook.Id","NumberCustomer","DiningOption","TableAndRoom.Name"]
    ...    $.InvoiceDetails[*].["ProductCode","Quantity","Price"]
    ${result_dict}    Get dict invoice order uuid      ${order_uuid}    ${list_jsonpath}
    KV Lists Should Be Equal         ${list_pr_code}        ${result_dict.ProductCode}           msg=Lưu sai thông tin mã hàng hóa
    KV Lists Should Be Equal         ${list_SL}             ${result_dict.Quantity}              msg=Lưu sai thông tin SL hàng hóa
    KV Lists Should Be Equal         ${list_price_bg}       ${result_dict.Price}                 msg=Lưu sai thông tin giá hàng hóa
    KV Should Be Equal     ${cus_code}            ${result_dict.Code[0]}               msg=Lưu sai thông tin khách hàng
    KV Should Be Equal     ${kenh_ban}            ${result_dict.Name[0]}               msg=Lưu sai thông tin kênh bán
    KV Should Be Equal     ${ghi_chu_don}         ${result_dict.Description[0]}        msg=Lưu sai thông tin ghi chú đơn
    KV Should Be Equal     ${pricebook_id}        ${result_dict.Id[0]}                 msg=Lưu sai thông tin bảng giá
    KV Should Be Equal     ${sl_khach}            ${result_dict.NumberCustomer[0]}     msg=Lưu sai thông tin SL khách
    KV Should Be Equal     ${table_name}          ${result_dict.Name1[0]}              msg=Lưu sai thông tin tên phòng bàn

Assert ten giaban soluong hang hoa tren detail invoice
    [Arguments]    ${invoice_id}   ${list_name_order}    ${list_price_order}    ${list_sl_order}
    ${list_jsonpath}    Create List    $.InvoiceDetails[*].["Product.Name","Quantity","Price","Discount"]
    ${result_dict}    Get dict detail invoice frm API     ${invoice_id}    ${list_jsonpath}
    ${list_name}    Set Variable Return From Dict    ${result_dict.Name}
    ${list_quantity}    Set Variable Return From Dict    ${result_dict.Quantity}
    ${list_price}    Set Variable Return From Dict    ${result_dict.Price}
    ${list_discount}    Set Variable Return From Dict    ${result_dict.Discount}
    ${list_iv_price_discount}    Create List
    FOR    ${price}   ${discount}    IN ZIP    ${list_price}    ${list_discount}
          ${price_discount}    Computation new price - discount - VND    ${price}    ${discount}
          ${price_discount}    Convert To Number    ${price_discount}
          Append To List    ${list_iv_price_discount}    ${price_discount}
    END
    KV Lists Should Be Equal    ${list_name_order}       ${list_name}                 msg=Sai tên hàng hóa
    KV Lists Should Be Equal    ${list_sl_order}         ${list_quantity}             msg=Sai số lượng hàng hóa
    KV Lists Should Be Equal    ${list_price_order}      ${list_iv_price_discount}    msg=Sai giá bán hàng hóa

Assert ten giaban soluong hang hoa va kenh ban tren invoice
    [Arguments]    ${order_code}    ${list_name_order}    ${list_price_order}    ${list_soluong_order}    ${kenh_ban}    ${branch_id}=${BRANCH_ID}
    ${list_jsonpath}    Create List    $.InvoiceDetails[*].["Product.Name","Quantity","Price","Discount"]    $.["SaleChannel.Name"]
    ${order_uuid}    Get order uuid by order code    ${order_code}    branch_id=${branch_id}
    ${result_dict}    Get dict invoice order uuid    ${order_uuid}    ${list_jsonpath}     branch_id=${branch_id}
    ${list_name}    Set Variable Return From Dict    ${result_dict.Name}
    ${list_quantity}    Set Variable Return From Dict    ${result_dict.Quantity}
    ${list_price}    Set Variable Return From Dict    ${result_dict.Price}
    ${list_discount}    Set Variable Return From Dict    ${result_dict.Discount}
    ${ten_kenhban}    Set Variable Return From Dict    ${result_dict.Name2[0]}

    ${list_iv_price_discount}    Create List
    FOR    ${price}   ${discount}    IN ZIP    ${list_price}    ${list_discount}
          ${price_discount}    Computation new price - discount - VND    ${price}    ${discount}
          ${price_discount}    Convert To Number    ${price_discount}
          Append To List    ${list_iv_price_discount}    ${price_discount}
    END
    KV Lists Should Be Equal         ${list_name_order}       ${list_name}                 msg=Sai tên hàng hóa
    KV Lists Should Be Equal         ${list_soluong_order}    ${list_quantity}             msg=Sai số lượng hàng hóa
    KV Lists Should Be Equal         ${list_price_order}      ${list_iv_price_discount}    msg=Sai giá bán hàng hóa
    KV Should Be Equal As Strings    ${kenh_ban}               ${ten_kenhban}              msg=Sai thông tin kênh bán

Assert ten giaban soluong hang hoa va giam gia tren invoice
    [Arguments]    ${order_code}    ${list_name_order}    ${list_price_order}    ${list_soluong_order}    ${tong_tien_hang}    ${tien_GG}    ${branch_id}=${BRANCH_ID}
    ${list_jsonpath}    Create List    $.InvoiceDetails[*].["Product.Name","Quantity","Price","Discount"]    $.["Discount","SubTotal"]
    ${order_uuid}    Get order uuid by order code    ${order_code}    branch_id=${branch_id}
    ${result_dict}    Get dict invoice order uuid    ${order_uuid}    ${list_jsonpath}     branch_id=${branch_id}
    ${list_name}    Set Variable Return From Dict    ${result_dict.Name}
    ${list_quantity}    Set Variable Return From Dict    ${result_dict.Quantity}
    ${list_price}    Set Variable Return From Dict    ${result_dict.Price}
    ${list_discount}    Set Variable Return From Dict    ${result_dict.Discount}
    ${discount_order}    Set Variable Return From Dict    ${result_dict.Discount2[0]}
    ${Total_order}    Set Variable Return From Dict    ${result_dict.SubTotal[0]}

    ${list_iv_price_discount}    Create List
    FOR    ${price}   ${discount}    IN ZIP    ${list_price}    ${list_discount}
          ${price_discount}    Computation new price - discount - VND    ${price}    ${discount}
          ${price_discount}    Convert To Number    ${price_discount}
          Append To List    ${list_iv_price_discount}    ${price_discount}
    END
    KV Lists Should Be Equal         ${list_name_order}       ${list_name}                 msg=Sai tên hàng hóa
    KV Lists Should Be Equal         ${list_soluong_order}    ${list_quantity}             msg=Sai số lượng hàng hóa
    KV Lists Should Be Equal         ${list_price_order}      ${list_iv_price_discount}    msg=Sai giá bán hàng hóa
    KV Should Be Equal As Strings    ${tien_GG}               ${discount_order}            msg=Sai số tiền giảm giá đơn theo %
    KV Should Be Equal As Strings    ${tong_tien_hang}        ${Total_order}               msg=Sai tổng tiền hàng

Assert ten giaban soluong hang hoa va tong tien thanh toan tren invoice
    [Arguments]    ${order_code}    ${list_name_order}    ${list_price_order}    ${list_soluong_order}    ${tong_tien_hang}    ${branch_id}=${BRANCH_ID}
    ${list_soluong_convert}    Create List
    FOR    ${soluong_order}     IN ZIP    ${list_soluong_order}
          ${soluong_order}    Convert To Number    ${soluong_order}
          Append To List    ${list_soluong_convert}    ${soluong_order}
    END
    ${list_jsonpath}    Create List    $.InvoiceDetails[*].["Product.Name","Quantity","Price","Discount"]    $.["SubTotal"]
    ${order_uuid}    Get order uuid by order code    ${order_code}    branch_id=${branch_id}
    ${result_dict}    Get dict invoice order uuid    ${order_uuid}    ${list_jsonpath}     branch_id=${branch_id}
    ${list_name}    Set Variable Return From Dict    ${result_dict.Name}
    ${list_quantity}    Set Variable Return From Dict    ${result_dict.Quantity}
    ${list_price}    Set Variable Return From Dict    ${result_dict.Price}
    ${list_discount}    Set Variable Return From Dict    ${result_dict.Discount}
    ${Total_order}    Set Variable Return From Dict    ${result_dict.SubTotal[0]}

    ${list_iv_price_discount}    Create List
    FOR    ${price}   ${discount}    IN ZIP    ${list_price}    ${list_discount}
          ${price_discount}    Computation new price - discount - VND    ${price}    ${discount}
          ${price_discount}    Convert To Number    ${price_discount}
          Append To List    ${list_iv_price_discount}    ${price_discount}
    END
    KV Lists Should Be Equal         ${list_name_order}       ${list_name}                 msg=Sai tên hàng hóa
    KV Lists Should Be Equal         ${list_soluong_convert}    ${list_quantity}           msg=Sai số lượng hàng hóa
    KV Lists Should Be Equal         ${list_price_order}      ${list_iv_price_discount}    msg=Sai giá bán hàng hóa
    KV Should Be Equal As Strings    ${tong_tien_hang}        ${Total_order}               msg=Sai tổng tiền hàng

# Assert thong tin thanh toan tren invoice cua giam gia hang topping
Assert thong tin thanh toan cua giam gia hang topping tren invoice
    [Arguments]    ${order_code}    ${length_pr}    ${list_so_topping}    ${list_dict_topping}
    ...    ${list_name_order}    ${list_price_order}    ${list_soluong_order}    ${tong_tien_hang}    ${branch_id}=${BRANCH_ID}

    ${length_pr}    Convert To String    ${length_pr}
    ${list_soluong_convert}    Create List
    FOR    ${soluong_order}     IN ZIP    ${list_soluong_order}
          ${soluong_order}    Convert To Number    ${soluong_order}
          Append To List    ${list_soluong_convert}    ${soluong_order}
    END
    ${list_jsonpath}    Create List    $.InvoiceDetails[*].["Product.Name","Quantity","Price","Discount"]    $.["SubTotal"]
    ${order_uuid}    Get order uuid by order code    ${order_code}    branch_id=${branch_id}
    ${result_dict}    Get dict invoice order uuid    ${order_uuid}    ${list_jsonpath}     branch_id=${branch_id}
    ${list_name}    Set Variable Return From Dict    ${result_dict.Name}
    ${list_quantity}    Set Variable Return From Dict    ${result_dict.Quantity}
    ${list_price}    Set Variable Return From Dict    ${result_dict.Price}
    ${list_discount}    Set Variable Return From Dict    ${result_dict.Discount}
    ${Total_order}    Set Variable Return From Dict    ${result_dict.SubTotal[0]}
    ${list_iv_price_discount}    Create List
    FOR    ${price}   ${discount}    IN ZIP    ${list_price}    ${list_discount}
          ${price_discount}    Computation new price - discount - VND    ${price}    ${discount}
          ${price_discount}    Convert To Number    ${price_discount}
          Append To List    ${list_iv_price_discount}    ${price_discount}
    END
    # Tính giá hàng hóa sau khi giảm giá từ các giá trị của API trả về
    ${list_copy_price_discount}    Copy List    ${list_iv_price_discount}
    ${length}    Get Length    ${list_copy_price_discount}
    ${length}    Convert To String    ${length}
    ${start}    Evaluate   ${length_pr}
    ${end}    Evaluate   ${length}
    ${list_price_topping}     Get Slice From List    ${list_copy_price_discount}    ${start}     ${end}
    ${end_topping}    Evaluate    ${list_so_topping[0]} + ${list_so_topping[1]}
    ${list_iv_price_discount}    Get Slice From List    ${list_iv_price_discount}   end=${start}
    ${list_price_topping1}    Get Slice From List    ${list_price_topping}    0     ${list_so_topping[0]}
    ${list_price_topping2}    Get Slice From List    ${list_price_topping}    ${list_so_topping[0]}     ${end_topping}
    ${sum_price_topping1}     Evaluate    sum(${list_price_topping1})
    ${sum_price_topping2}     Evaluate    sum(${list_price_topping2})
    ${list_full_price_discount}    Create List
    ${index}     Get Index From List     ${list_dict_topping}    ${EMPTY}
    ${list_sum_price_tp}    Set Variable    ${sum_price_topping1}    ${sum_price_topping2}
    Insert Into List    ${list_sum_price_tp}    ${index}    ${0}
    FOR    ${price_discount}    ${sum_price_tp}    IN ZIP    ${list_iv_price_discount}    ${list_sum_price_tp}
        ${full_price_discount}    Evaluate    ${price_discount} + ${sum_price_tp}
        ${full_price_discount}    Evaluate     round(${full_price_discount},1)
        Append To List    ${list_full_price_discount}    ${full_price_discount}
    END

    KV Lists Should Be Equal         ${list_name_order}         ${list_name}                   msg=Sai tên hàng hóa
    KV Lists Should Be Equal         ${list_soluong_convert}    ${list_quantity}               msg=Sai số lượng hàng hóa
    KV Lists Should Be Equal         ${list_price_order}        ${list_full_price_discount}    msg=Sai giá bán hàng hóa
    KV Should Be Equal As Strings    ${tong_tien_hang}          ${Total_order}                 msg=Sai tổng tiền hàng

Assert thong tin tong tren man hinh hoa don va API
    [Arguments]    ${id_hoa_don}    ${text_tong_tien}    ${text_giam_gia}    ${text_tong_sau_GG}    ${text_khach_datra}    ${text_tong_thu_khac}    ${text_khach_cantra}
    ...    ${text_can_thu_ho}    ${text_phitra_dtgh}
    ${json_path}    Create List    $.["Discount","InvoiceDelivery.Price","Surcharge","TotalPayment","Total","CodNeedPayment"]    $.InvoiceDetails[*].["Price"]
    ${result_dict}    Get dict detail invoice frm API     ${id_hoa_don}    ${json_path}

    ${get_giam_gia}       Set Variable    ${result_dict.Discount[0]}
    ${get_khach_datra}    Set Variable    ${result_dict.TotalPayment[0]}
    ${get_khach_cantra}    Set Variable    ${result_dict.Total[0]}
    ${get_tong_thukhac}    Set Variable    ${result_dict.Surcharge[0]}
    ${get_tong_sau_GG}    Evaluate    ${result_dict.Total[0]} - ${result_dict.Surcharge[0]}
    ${get_can_thuho}      Set Variable    ${result_dict.CodNeedPayment[0]}
    ${get_phitra_dtgh}    Set Variable    ${result_dict.Price[0]}
    ${get_tong_tien}     Evaluate    sum(${result_dict.Price2})
    KV Should Be Equal As Numbers    ${text_tong_tien}       ${get_tong_tien}       msg=Sai Tổng tiền ở dòng thông tin tổng hóa đơn
    KV Should Be Equal As Numbers    ${text_giam_gia}        ${get_giam_gia}        msg=Sai Giảm giá ở dòng thông tin tổng hóa đơn
    KV Should Be Equal As Numbers    ${text_tong_sau_GG}     ${get_tong_sau_GG}     msg=Sai Tổng sau GG ở dòng thông tin tổng hóa đơn
    KV Should Be Equal As Numbers    ${text_khach_datra}     ${get_khach_datra}     msg=Sai Khách đã trả ở dòng thông tin tổng hóa đơn
    KV Should Be Equal As Numbers    ${text_khach_cantra}    ${get_khach_cantra}    msg=Sai Khách cần trả ở dòng thông tin tổng hóa đơn
    KV Should Be Equal As Numbers    ${text_tong_thu_khac}   ${get_tong_thukhac}    msg=Sai Thu khác ở dòng thông tin tổng hóa đơn
    KV Should Be Equal As Numbers    ${text_can_thu_ho}      ${get_can_thuho}       msg=Sai Cần thu hộ ở dòng thông tin tổng hóa đơn
    KV Should Be Equal As Numbers    ${text_phitra_dtgh}     ${get_phitra_dtgh}     msg=Sai Phí trả ĐTGH ở dòng thông tin tổng hóa đơn

Assert thong tin tong trong chi tiet man hinh hoa don
    [Arguments]    ${id_hoa_don}    ${text_tong_tien}    ${list_text_thukhac}    ${text_khach_cantra}    ${text_khach_datra}    ${text_giamgia_hoadon}
    ${json_path}    Create List    $.["Discount","TotalPayment","Total"]    $.InvoiceDetails[*].["Price"]    $.InvoiceOrderSurcharges[*].["Price"]
    ${result_dict}    Get dict detail invoice frm API     ${id_hoa_don}    ${json_path}

    ${get_tong_tien}         Evaluate        sum(${result_dict.Price})
    ${get_khach_datra}       Set Variable    ${result_dict.TotalPayment[0]}
    ${get_khach_cantra}      Set Variable    ${result_dict.Total[0]}
    ${get_list_thukhac}      Set Variable    ${result_dict.Price3}
    ${get_giamgia_hoadon}    Set Variable    ${result_dict.Discount[0]}

    KV Should Be Equal As Numbers    ${text_tong_tien}           ${get_tongtien}            msg=Sai Tổng tiền ở dòng thông tin tổng hóa đơn
    KV Should Be Equal As Numbers    ${text_khach_cantra}        ${get_khach_cantra}        msg=Sai khách cần trả ở dòng thông tin tổng hóa đơn
    KV Should Be Equal As Numbers    ${text_giamgia_hoadon}      ${get_giamgia_hoadon}      msg=Sai Tổng sau GG ở dòng thông tin tổng hóa đơn
    KV Should Be Equal As Numbers    ${text_khach_datra}         ${get_khach_datra}         msg=Sai Khách đã trả ở dòng thông tin tổng hóa đơn
    KV Lists Should Be Equal         ${list_text_thukhac}        ${get_list_thukhac}        msg=Sai Khách thu khác ở dòng thông tin tổng hóa đơn

Assert thong tin tong trong chi tiet man hinh hoa don cua don giao di
    [Arguments]    ${id_hoa_don}    ${text_tong_tien}    ${list_text_thukhac}    ${text_khach_cantra}    ${text_khach_datra}    ${text_giamgia_hoadon}
    ...    ${text_phigiaohang}    ${text_dathu}    ${text_con_canthu}
    ${json_path}    Create List    $.["Discount","TotalPayment","Total","PaidAmount","CodNeedPayment"]    $.InvoiceDetails[*].["Price"]    $.InvoiceOrderSurcharges[*].["Price"]    $.InvoiceDelivery[*].["TotalPrice"]
    ${result_dict}    Get dict detail invoice frm API     ${id_hoa_don}    ${json_path}

    ${get_tong_tien}         Evaluate        sum(${result_dict.Price})
    ${get_khach_datra}       Set Variable    ${result_dict.TotalPayment[0]}
    ${get_khach_cantra}      Set Variable    ${result_dict.Total[0]}
    ${get_list_thukhac}      Set Variable    ${result_dict.Price3}
    ${get_giamgia_hoadon}    Set Variable    ${result_dict.Discount[0]}
    ${get_con_canthu}        Set Variable    ${result_dict.CodNeedPayment[0]}
    ${get_phigiaohang}       Set Variable    ${result_dict.TotalPrice[0]}
    ${get_dathu}             Set Variable    ${result_dict.PaidAmount[0]}

    KV Should Be Equal As Numbers    ${text_tong_tien}           ${get_tongtien}            msg=Sai Tổng tiền ở dòng thông tin tổng hóa đơn
    KV Should Be Equal As Numbers    ${text_khach_cantra}        ${get_khach_cantra}        msg=Sai khách cần trả ở dòng thông tin tổng hóa đơn
    KV Should Be Equal As Numbers    ${text_giamgia_hoadon}      ${get_giamgia_hoadon}      msg=Sai Tổng sau GG ở dòng thông tin tổng hóa đơn
    KV Should Be Equal As Numbers    ${text_khach_datra}         ${get_khach_datra}         msg=Sai Khách đã trả ở dòng thông tin tổng hóa đơn
    KV Lists Should Be Equal         ${list_text_thukhac}        ${get_list_thukhac}        msg=Sai Khách thu khác ở dòng thông tin tổng hóa đơn
    KV Should Be Equal As Numbers    ${text_con_canthu}          ${get_con_canthu}          msg=Sai Số tiền còn cần trả ở dòng thông tin tổng hóa đơn
    KV Should Be Equal As Numbers    ${text_phigiaohang}         ${get_phigiaohang}         msg=Sai Phí giao hàng ở dòng thông tin tổng hóa đơn
    KV Should Be Equal As Numbers    ${text_dathu}               ${get_dathu}               msg=Sai Số tiền đã thu ở dòng thông tin tổng hóa đơn
