*** Settings ***
Resource          ../../api_access.robot
Resource          ../../../share/computation.robot
Resource          ../hang-hoa/api_danhmuc_hanghoa.robot
Library           String
Library           Collections

*** Keywords ***
# Lấy thông tin all phiếu nhập mặc định theo Hôm nay. (bao gồm cả phiếu Đã hủy)
Get dict all purchase order info
    [Arguments]    ${list_jsonpath}    ${filter_time}=today    ${is_phieu_tam}=True    ${is_phieu_hoan_thanh}=True    ${is_phieu_huy}=True
    ${filter_status}    KV Get Filter Status purchase order    ${is_phieu_tam}    ${is_phieu_hoan_thanh}    ${is_phieu_huy}
    ${filter_data}    Set Variable    (BranchId+eq+${BRANCH_ID}+and+PurchaseDate+eq+'${filter_time}'+and+(${filter_status}))
    ${input_dict}    Create Dictionary    filter_data=${filter_data}
    ${result_dict}    API Call From Template    /nhap-hang/all_phieu_nhap_hang.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

# Filter theo status của giao dịch nhap hang
KV Get Filter Status purchase order
    [Arguments]    ${is_phieu_tam}    ${is_phieu_hoan_thanh}    ${is_phieu_huy}
    ${list_filter}    Create List
    Run Keyword If    '${is_phieu_tam}' == 'True'           Append To List    ${list_filter}    Status+eq+1
    Run Keyword If    '${is_phieu_hoan_thanh}' == 'True'    Append To List    ${list_filter}    Status+eq+3
    Run Keyword If    '${is_phieu_huy}' == 'True'           Append To List    ${list_filter}    Status+eq+4
    ${list_filter}     Evaluate    "+or+".join(${list_filter})
    Return From Keyword    ${list_filter}

Get dict update detail purchase order info
    [Arguments]    ${id_phieu_nhap}    ${list_jsonpath}
    ${find_dict}    Create Dictionary    id_phieu_nhap=${id_phieu_nhap}
    ${result_dict}    API Call From Template    /nhap-hang/detail_update_phieu_nhap_hang.txt    ${find_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get dict detail purchase order info
    [Arguments]    ${id_phieu_nhap}    ${list_jsonpath}
    ${find_dict}    Create Dictionary    id_phieu_nhap=${id_phieu_nhap}
    ${result_dict}    API Call From Template    /nhap-hang/detail_phieu_nhap_hang.txt    ${find_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get dict purchase payment
    [Arguments]    ${id_phieu_nhap}    ${list_jsonpath}
    ${find_dict}    Create Dictionary    id_phieu_nhap=${id_phieu_nhap}
    ${result_dict}    API Call From Template    /nhap-hang/get_purchase_payment.txt    ${find_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get id phieu nhap by ma phieu
    [Arguments]    ${ma_phieu_nhap}
    ${jsonpath}    Set Variable    $.Data[?(@.Code\=\="${ma_phieu_nhap}")].["Id"]
    ${result_dict}    Get dict all purchase order info    ${jsonpath}
    ${get_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${get_id}

Get ghi chu phieu nhap by ma phieu
    [Arguments]    ${ma_phieu_nhap}
    ${jsonpath}    Set Variable    $.Data[?(@.Code\=\="${ma_phieu_nhap}")].["Description"]
    ${result_dict}    Get dict all purchase order info    ${jsonpath}
    ${get_ghi_chu}    Set Variable Return From Dict    ${result_dict.Description[0]}
    Return From Keyword    ${get_ghi_chu}

Get ma nha cung cap by ma phieu
    [Arguments]    ${ma_phieu_nhap}
    ${jsonpath}    Set Variable    $.Data[?(@.Code\=\="${ma_phieu_nhap}")].Supplier.CompareCode
    ${result_dict}    Get dict all purchase order info    ${jsonpath}
    Return From Keyword    ${result_dict.CompareCode[0]}

Get tien tra ncc by ma phieu
    [Arguments]    ${ma_phieu_nhap}
    ${jsonpath}    Set Variable    $.Data[?(@.Code\=\="${ma_phieu_nhap}")].PaidAmount
    ${result_dict}    Get dict all purchase order info    ${jsonpath}
    Return From Keyword    ${result_dict.PaidAmount[0]}

Get total of purchase order frm API
    [Timeout]
    ${jsonpath}    Set Variable    $.["Total"]
    ${result_dict}    Get dict all purchase order info    ${jsonpath}
    Return From Keyword    ${result_dict.Total[0]}

Get tong so luong - tong tien hang va tien tra ncc cua phieu nhap
    [Arguments]    ${ma_phieu_nhap}
    ${list_jsonpath}     Create List    $.Data[?(@.Code\=\="${ma_phieu_nhap}")].["SubTotal","TotalQuantity","PaidAmount"]
    ${result_dict}       Get dict all purchase order info    ${list_jsonpath}
    ${tong_tien_hang}    Set Variable Return From Dict    ${result_dict.TotalQuantity[0]}
    ${tong_SL}           Set Variable Return From Dict    ${result_dict.SubTotal[0]}
    ${ten_tra_ncc}       Set Variable Return From Dict    ${result_dict.PaidAmount[0]}
    Return From Keyword    ${tong_tien_hang}    ${tong_SL}    ${ten_tra_ncc}

Get list thong tin cua hang hoa trong phieu nhap
    [Arguments]    ${ma_phieu_nhap}
    ${id_phieu_nhap}    Get id phieu nhap by ma phieu    ${ma_phieu_nhap}
    ${list_jsonpath}    Create List    $.Data[*].["ProductCode","Quantity","Price","SubTotal"]
    ${result_dict}      Get dict detail purchase order info    ${id_phieu_nhap}    ${list_jsonpath}
    ${list_pr_code}        Set Variable Return From Dict    ${result_dict.ProductCode}
    ${list_quantity}       Set Variable Return From Dict    ${result_dict.Quantity}
    ${list_price}          Set Variable Return From Dict    ${result_dict.Price}
    ${list_subtotal}       Set Variable Return From Dict    ${result_dict.SubTotal}
    Return From Keyword    ${list_pr_code}    ${list_quantity}    ${list_price}    ${list_subtotal}

Get list ma hang hoa trong phieu nhap
    [Arguments]    ${ma_phieu_nhap}
    ${id_phieu_nhap}    Get id phieu nhap by ma phieu    ${ma_phieu_nhap}
    ${result_dict}    Get dict detail purchase order info    ${id_phieu_nhap}    $.Data[*].["ProductCode"]
    ${list_pr_code}    Set Variable Return From Dict    ${result_dict.ProductCode}
    Return From Keyword    ${list_pr_code}

Get tong ma phieu chi cua phieu nhap hang
    [Arguments]    ${id_phieu_nhap}
    ${result_dict}    Get dict purchase payment    ${id_phieu_nhap}    $.Total
    ${total}    Set Variable Return From Dict    ${result_dict.Total[0]}
    Return From Keyword    ${total}

Assert thong tin tong tien hang va tien tra nha cung cap cua phieu nhap hang
    [Arguments]    ${ma_phieu_nhap}    ${count_tong_tien_hang}    ${tien_tra_ncc}    ${status}
    ${list_jsonpath}    Create List    $.Data[?(@.Code\=\="${ma_phieu_nhap}")].["SubTotal","PaidAmount","Status"]
    ${result_dict}    Get dict all purchase order info    ${list_jsonpath}
    ${get_tong_tien_hang}    Set Variable Return From Dict    ${result_dict.SubTotal[0]}
    ${get_tien_tra_ncc}      Set Variable Return From Dict    ${result_dict.PaidAmount[0]}
    ${get_status}            Set Variable Return From Dict    ${result_dict.Status[0]}
    KV Should Be Equal As Numbers     ${count_tong_tien_hang}    ${get_tong_tien_hang}    msg=Lỗi sai thông tin tổng tiền hàng
    KV Should Be Equal As Numbers     ${tien_tra_ncc}            ${get_tien_tra_ncc}    msg=Lỗi sai thông tin tiền trả NCC
    KV Should Be Equal As Strings    ${status}                  ${get_status}    msg=Lỗi sai thông tin trạng thái phiếu

Assert thong tin hang hoa trong phieu nhap hang
    [Arguments]    ${id_phieu_nhap}    ${list_ma_hh}    ${list_SL}    ${list_thanh_tien}
    ${list_ma_hh}    ${list_SL}    ${list_thanh_tien}    Reverse three lists    ${list_ma_hh}    ${list_SL}    ${list_thanh_tien}
    ${list_jsonpath}    Create List    $.PurchaseOrderDetails[*].["ProductCode","Quantity","SubTotal"]
    ${result_dict}      Get dict update detail purchase order info    ${id_phieu_nhap}    ${list_jsonpath}
    KV Lists Should Be Equal    ${list_ma_hh}         ${result_dict.ProductCode}    msg=Lỗi thông tin mã hàng trong phiếu
    KV Lists Should Be Equal    ${list_SL}            ${result_dict.Quantity}    msg=Lỗi thông tin số lượng trong phiếu
    KV Lists Should Be Equal    ${list_thanh_tien}    ${result_dict.SubTotal}    msg=Lỗi thông tin thành tiền trong phiếu

Assert trang thai phieu nhap sau khi huy
    [Arguments]    ${ma_phieu_nhap}    ${status}
    ${jsonpath}    Set Variable    $.Data[?(@.Code\=\="${ma_phieu_nhap}")].Status
    ${result_dict}    Get dict all purchase order info    ${jsonpath}
    KV Should Be Equal As Integers    ${status}    ${result_dict.Status[0]}    msg=Lỗi thông tin trạng thái của phiếu

Assert thong tin gia von va ton kho sau khi huy phieu nhap
    [Arguments]    ${ma_phieu_nhap}    ${list_ma_hh}    ${list_ton_kho_bf}    ${list_gia_von_bf}
    ${list_ton_kho_af}    ${list_gia_von_af}    Get list onHand and cost by list product code    ${list_ma_hh}
    KV Lists Should Be Equal    ${list_ton_kho_bf}    ${list_ton_kho_af}    msg=Lỗi danh sách tồn kho của danh sách hàng hóa không đúng
    KV Lists Should Be Equal    ${list_gia_von_bf}    ${list_gia_von_af}    msg=Lỗi danh sách giá vốn của danh sách hàng hóa không đúng

# Lấy thông tin để so sánh với file export tong quan
Get info to export all purchase order
    [Arguments]
    ${list_jsonpath}    Create List    $.Data[*].["Code","PurchaseDate","Supplier.Name","Total","StatusValue"]
    ${result_dict}    Get dict all purchase order info    ${list_jsonpath}
    ${result_dict.PurchaseDate}       KV Convert DateTime To String    ${result_dict.PurchaseDate}
    Return From Keyword    ${result_dict}

# Lấy thông tin để so sánh với file export chi tiết
Get info to export detail purchase order
    [Documentation]    "Code" là mã phiếu nhập
    ...                "Code1" là mã nhà cung cấp (Supplier.Code)
    ${list_jsonpath}    Create List    $.Data[*].["Id","Branch.Name","Code","PurchaseDate","ModifiedDate","ModifiedBy","User.GivenName","Supplier.Code","Supplier.CompareName","Supplier.Phone","User1.GivenName","SubTotal","Discount","ExReturnSuppliers","Total","Supplier.Address","PaidAmount","ExReturnThirdParty","Description","TotalQuantity","StatusValue","TotalProductType"]

    ${dict_all}    Get dict all purchase order info    ${list_jsonpath}    is_phieu_huy=False
    ${dict_all.Code1}         Set Variable Return From Dict    ${dict_all.Code1}     #List ma NCC
    ${dict_all.Description}   Set Variable Return From Dict    ${dict_all.Description}
    ${dict_all.CompareName}   Set Variable Return From Dict    ${dict_all.CompareName}
    ${dict_all.Phone}         Set Variable Return From Dict    ${dict_all.Phone}
    ${dict_all.Address}       Set Variable Return From Dict    ${dict_all.Address}
    ${dict_all.Discount}      Set Variable Return From Dict    ${dict_all.Discount}    percision_number=0
    ${dict_all.ModifiedBy}    Set Variable Return From Dict    ${dict_all.ModifiedBy}
    ${dict_all.ExReturnSuppliers}    Set Variable Return From Dict    ${dict_all.ExReturnSuppliers}    percision_number=0
    ${dict_all.ExReturnThirdParty}   Set Variable Return From Dict    ${dict_all.ExReturnThirdParty}    percision_number=0

    ${dict_all.PurchaseDate}   KV Convert DateTime To String    ${dict_all.PurchaseDate}
    ${dict_all.ModifiedDate}   KV Convert DateTime To String    ${dict_all.ModifiedDate}
    # Chuẩn hóa giá trị để khớp với file excel
    FOR   ${purchase_code}    IN    @{dict_all.Code}
        ${index}    Get Index From List    ${dict_all.Code}    ${purchase_code}
        # Nếu phiếu k có thông tin ModifiedBy thì khi export giá trị ModifiedDate=PurchaseDate
        ${result_ModifiedDate}=    Set Variable If    '${dict_all.ModifiedBy[${index}]}' == '0'    ${dict_all.PurchaseDate[${index}]}    ${dict_all.ModifiedDate[${index}]}
        Set List Value    ${dict_all.ModifiedDate}    ${index}    ${result_ModifiedDate}
        # Nếu phiếu nhập k có nhập Nhà cung cấp thì khi export: mã NCC = "CC lẻ" và Tên NCC = "Nhà cung cấp lẻ"
        ${result_supplier_name}=    Set Variable If    '${dict_all.CompareName[${index}]}' == '0'    Nhà cung cấp lẻ    ${dict_all.CompareName[${index}]}
        ${result_supplier_code}=    Set Variable If    '${dict_all.Code1[${index}]}' == '0'    NCC lẻ    ${dict_all.Code1[${index}]}
        Set List Value    ${dict_all.CompareName}    ${index}    ${result_supplier_name}
        Set List Value    ${dict_all.Code1}    ${index}    ${result_supplier_code}
    END

    ${result_dict}   Create Dictionary   unique_key=@{EMPTY}        Name=@{EMPTY}              Code=@{EMPTY}               PurchaseDate=@{EMPTY}        ModifiedDate=@{EMPTY}       nguoi_tao=@{EMPTY}
    ...    Supplier_Code=@{EMPTY}        Supplier_Name=@{EMPTY}     Phone=@{EMPTY}             nguoi_nhap=@{EMPTY}         SubTotal_PN=@{EMPTY}        Discount_PN=@{EMPTY}
    ...    ExReturnSuppliers=@{EMPTY}    Total=@{EMPTY}             Address=@{EMPTY}           PaidAmount=@{EMPTY}         ExReturnThirdParty=@{EMPTY}
    ...    Description_PN=@{EMPTY}       TotalQuantity=@{EMPTY}     StatusValue=@{EMPTY}       TotalProductType=@{EMPTY}   SubTotal_HH=@{EMPTY}
    ...    ProductCode=@{EMPTY}          ProductName=@{EMPTY}       Unit=@{EMPTY}              Description_HH=@{EMPTY}     Quantity=@{EMPTY}
    ...    Price=@{EMPTY}                Discount_HH=@{EMPTY}       DiscountRatio=@{EMPTY}     Supply_Price=@{EMPTY}

    FOR   ${id_pn}    IN    @{dict_all.Id}
        ${index_pn}    Get Index From List    ${dict_all.Id}    ${id_pn}
        ${dict_detail}    Get dict full info of product in purchase order    ${id_pn}
        Purchase order mix data from API    ${dict_all.Code[${index_pn}]}    ${result_dict}    ${dict_all}    ${dict_detail}    ${index_pn}
    END
    Return From Keyword    ${result_dict}

Purchase order mix data from API
    [Arguments]    ${ma_pn}    ${result_dict}    ${dict_all}    ${dict_detail}    ${index_pn}
    FOR    ${product_code}    IN    @{dict_detail.ProductCode}
        ${index_product}    Get Index From List    ${dict_detail.ProductCode}    ${product_code}
        # Tính toán Giá nhập (Supply_Price) của mỗi hàng hóa
        ${supply_price}    Minus    ${dict_detail.Price[${index_product}]}    ${dict_detail.Discount[${index_product}]}

        ${unique_value}    Set Variable    ${ma_pn}-${product_code}
        Append To List    ${result_dict.unique_key}           ${unique_value}
        Append To List    ${result_dict.Name}                 ${dict_all.Name[${index_pn}]}
        Append To List    ${result_dict.Code}                 ${dict_all.Code[${index_pn}]}
        Append To List    ${result_dict.PurchaseDate}         ${dict_all.PurchaseDate[${index_pn}]}
        Append To List    ${result_dict.ModifiedDate}         ${dict_all.ModifiedDate[${index_pn}]}
        Append To List    ${result_dict.nguoi_tao}            ${dict_all.GivenName[${index_pn}]}
        Append To List    ${result_dict.Supplier_Code}        ${dict_all.Code1[${index_pn}]}
        Append To List    ${result_dict.Supplier_Name}        ${dict_all.CompareName[${index_pn}]}
        Append To List    ${result_dict.Phone}                ${dict_all.Phone[${index_pn}]}
        Append To List    ${result_dict.nguoi_nhap}           ${dict_all.GivenName1[${index_pn}]}
        Append To List    ${result_dict.SubTotal_PN}          ${dict_all.SubTotal[${index_pn}]}
        Append To List    ${result_dict.Discount_PN}          ${dict_all.Discount[${index_pn}]}
        Append To List    ${result_dict.ExReturnSuppliers}    ${dict_all.ExReturnSuppliers[${index_pn}]}
        Append To List    ${result_dict.Total}                ${dict_all.Total[${index_pn}]}
        Append To List    ${result_dict.Address}              ${dict_all.Address[${index_pn}]}
        Append To List    ${result_dict.PaidAmount}           ${dict_all.PaidAmount[${index_pn}]}
        Append To List    ${result_dict.ExReturnThirdParty}   ${dict_all.ExReturnThirdParty[${index_pn}]}
        Append To List    ${result_dict.Description_PN}       ${dict_all.Description[${index_pn}]}
        Append To List    ${result_dict.TotalQuantity}        ${dict_all.TotalQuantity[${index_pn}]}
        Append To List    ${result_dict.StatusValue}          ${dict_all.StatusValue[${index_pn}]}
        Append To List    ${result_dict.TotalProductType}     ${dict_all.TotalProductType[${index_pn}]}
        #
        Append To List    ${result_dict.ProductCode}          ${dict_detail.ProductCode[${index_product}]}
        Append To List    ${result_dict.ProductName}          ${dict_detail.ProductName[${index_product}]}
        Append To List    ${result_dict.Unit}                 ${dict_detail.Unit[${index_product}]}
        Append To List    ${result_dict.Description_HH}       ${dict_detail.Description[${index_product}]}
        Append To List    ${result_dict.Quantity}             ${dict_detail.Quantity[${index_product}]}
        Append To List    ${result_dict.Price}                ${dict_detail.Price[${index_product}]}
        Append To List    ${result_dict.Discount_HH}          ${dict_detail.Discount[${index_product}]}
        Append To List    ${result_dict.DiscountRatio}        ${dict_detail.DiscountRatio[${index_product}]}
        Append To List    ${result_dict.Supply_Price}         ${supply_price}
        Append To List    ${result_dict.SubTotal_HH}          ${dict_detail.SubTotal[${index_product}]}
    END

Get dict full info of product in purchase order
    [Arguments]    ${id_phieu_nhap}
    ${list_jsonpath}    Create List    $.Data[*].["ProductCode","ProductName","Product.Unit","Description","Quantity","Price","Discount","DiscountRatio","SubTotal"]
    ${dict_detail}    Get dict detail purchase order info    ${id_phieu_nhap}    ${list_jsonpath}
    # Lấy tên hàng hóa chỉ gồm tên và thuộc tính
    FOR    ${ProductCode}    IN    @{dict_detail.ProductCode}
        ${index}    Get Index From List    ${dict_detail.ProductCode}    ${ProductCode}
        ${name_with_attr}    Get product name with attribute    ${dict_detail.ProductCode[${index}]}    ${dict_detail.ProductName[${index}]}    ${dict_detail.Unit[${index}]}
        Set List Value    ${dict_detail.ProductName}    ${index}    ${name_with_attr}
    END
    ${dict_detail.Unit}             Set Variable Return From Dict    ${dict_detail.Unit}
    ${dict_detail.Description}      Set Variable Return From Dict    ${dict_detail.Description}
    ${dict_detail.Price}            Set Variable Return From Dict    ${dict_detail.Price}
    ${dict_detail.Discount}         Set Variable Return From Dict    ${dict_detail.Discount}
    ${dict_detail.SubTotal}         Set Variable Return From Dict    ${dict_detail.SubTotal}
    ${dict_detail.DiscountRatio}    Set Variable Return From Dict    ${dict_detail.DiscountRatio}
    Return From Keyword    ${dict_detail}

# Lấy thông tin để so sánh với file export 1 phiếu nhập
Get info to export one purchase order
    [Arguments]    ${id_phieu_nhap}
    ${dict_detail}    Get dict full info of product in purchase order    ${id_phieu_nhap}
    # Quy đổi giảm giá HH theo VND sang %
    FOR    ${ProductCode}     IN    @{dict_detail.ProductCode}
        ${index}    Get Index From List    ${dict_detail.ProductCode}    ${ProductCode}
        ${count_discountRatio}    Run Keyword If    ${dict_detail.DiscountRatio[${index}]} == 0    Convert VND discount to %    ${dict_detail.Discount[${index}]}    ${dict_detail.Price[${index}]}    2
        Run Keyword If    ${dict_detail.DiscountRatio[${index}]} == 0    Set List Value    ${dict_detail.DiscountRatio}    ${index}    ${count_discountRatio}
    END
    Remove From Dictionary    ${dict_detail}    Description
    Remove From Dictionary    ${dict_detail}    SubTotal
    Return From Keyword    ${dict_detail}

Assert thong tin chung ve tien cua danh sach phieu nhap tren UI va API
    [Arguments]    ${text_tong_tien}    ${text_giam_gia}    ${text_CP_nhap}    ${text_can_tra_ncc}    ${text_tien_tra_ncc}    ${text_CP_nhap_khac}
    ${list_jsonpath}    Create List    $.Data[?(@.Id!=-1)].["SubTotal","Discount","ExReturnSuppliers","Total","PaidAmount","ExReturnThirdParty"]
    ${result_dict}      Get dict all purchase order info    ${list_jsonpath}    is_phieu_huy=False
    ${list_discount}    Set Variable Return From Dict    ${result_dict.Discount}
    ${list_ExReturnSuppliers}    Set Variable Return From Dict    ${result_dict.ExReturnSuppliers}
    ${list_ExReturnThirdParty}   Set Variable Return From Dict    ${result_dict.ExReturnThirdParty}
    ${tong_tien}       Sum values in list    ${result_dict.SubTotal}
    ${giam_gia}        Sum values in list    ${list_discount}
    ${CP_nhap}         Sum values in list    ${list_ExReturnSuppliers}
    ${can_tra_ncc}     Sum values in list    ${result_dict.Total}
    ${tien_tra_ncc}    Sum values in list    ${result_dict.PaidAmount}
    ${CP_nhap_khac}    Sum values in list    ${list_ExReturnThirdParty}
    KV Should Be Equal As Numbers    ${text_tong_tien}       ${tong_tien}      msg=Hiển thị sai thông tin Tổng tiền hàng ở dòng thông tin chung
    KV Should Be Equal As Numbers    ${text_giam_gia}        ${giam_gia}       msg=Hiển thị sai thông tin Giảm giá ở dòng thông tin chung
    KV Should Be Equal As Numbers    ${text_CP_nhap}         ${CP_nhap}        msg=Hiển thị sai thông tin CP nhập hàng ở dòng thông tin chung
    KV Should Be Equal As Numbers    ${text_can_tra_ncc}     ${can_tra_ncc}    msg=Hiển thị sai thông tin Cần trả NCC ở dòng thông tin chung
    KV Should Be Equal As Numbers    ${text_tien_tra_ncc}    ${tien_tra_ncc}   msg=Hiển thị sai thông tin Tiền trả NCC ở dòng thông tin chung
    KV Should Be Equal As Numbers    ${text_CP_nhap_khac}    ${CP_nhap_khac}   msg=Hiển thị sai thông tin CP nhập hàng khác ở dòng thông tin chung

Assert thong tin chung ve tien cua mot phieu nhap tren UI va API
    [Arguments]    ${ma_pn}    ${text_tong_tien}    ${text_giam_gia}    ${text_CP_nhap}    ${text_can_tra_ncc}    ${text_tien_tra_ncc}    ${text_CP_nhap_khac}
    ${list_jsonpath}    Create List    $.Data[?(@.Code\=\="${ma_pn}")].["SubTotal","Discount","ExReturnSuppliers","Total","PaidAmount","ExReturnThirdParty"]
    ${result_dict}      Get dict all purchase order info    ${list_jsonpath}    is_phieu_huy=False
    ${giam_gia}       Set Variable Return From Dict    ${result_dict.Discount[0]}
    ${CP_nhap}        Set Variable Return From Dict    ${result_dict.ExReturnSuppliers[0]}
    ${CP_nhap_khac}   Set Variable Return From Dict    ${result_dict.ExReturnThirdParty[0]}
    ${tong_tien}      Set Variable    ${result_dict.SubTotal[0]}
    ${can_tra_ncc}    Set Variable    ${result_dict.Total[0]}
    ${tien_tra_ncc}   Set Variable    ${result_dict.PaidAmount[0]}
    KV Should Be Equal As Numbers    ${text_tong_tien}       ${tong_tien}      msg=Hiển thị sai thông tin Tổng tiền hàng ở dòng thông tin chung của 1 phiếu
    KV Should Be Equal As Numbers    ${text_giam_gia}        ${giam_gia}       msg=Hiển thị sai thông tin Giảm giá ở dòng thông tin chung của 1 phiếu
    KV Should Be Equal As Numbers    ${text_CP_nhap}         ${CP_nhap}        msg=Hiển thị sai thông tin CP nhập hàng ở dòng thông tin chung của 1 phiếu
    KV Should Be Equal As Numbers    ${text_can_tra_ncc}     ${can_tra_ncc}    msg=Hiển thị sai thông tin Cần trả NCC ở dòng thông tin chung của 1 phiếu
    KV Should Be Equal As Numbers    ${text_tien_tra_ncc}    ${tien_tra_ncc}   msg=Hiển thị sai thông tin Tiền trả NCC ở dòng thông tin chung của 1 phiếu
    KV Should Be Equal As Numbers    ${text_CP_nhap_khac}    ${CP_nhap_khac}   msg=Hiển thị sai thông tin CP nhập hàng khác ở dòng thông tin chung của 1 phiếu

Assert thong tin chi tiet ve tien cua 1 phieu nhap
    [Arguments]    ${id_pn}    ${text_tong_tien_hang}    ${text_GG_phieu}    ${list_gtri_cp}    ${text_can_tra_ncc}    ${text_tien_tra_ncc}    ${list_gtri_cp_khac}
    ${list_jsonpath}    Create List    $.["SubTotal","Discount","Total"]    $.PurchaseOrderExpensesOthers[?(@.Form==0)].Price    $.PurchaseOrderExpensesOthers[?(@.Form==1)].Price
    ${result_dict}      Get dict update detail purchase order info    ${id_pn}    ${list_jsonpath}
    ${get_list_gtri_cp}         Set Variable Return From Dict    ${result_dict.Price}
    ${get_list_gtri_cp_khac}    Set Variable Return From Dict    ${result_dict.Price3}
    ${get_tong_tien_hang}    Set Variable    ${result_dict.SubTotal[0]}
    ${get_GG_phieu}          Set Variable    ${result_dict.Discount[0]}
    ${get_can_tra_ncc}       Set Variable    ${result_dict.Total[0]}
    # Lấy thông tin Tiền đã trả NCC từ api/purchaseOrders
    ${result_dict_all}     Get dict all purchase order info    $.Data[?(@.Id==${id_pn})].PaidAmount    is_phieu_huy=False
    ${get_tien_tra_ncc}    Set Variable    ${result_dict_all.PaidAmount[0]}
    # Assert thông tin
    KV Should Be Equal As Numbers    ${text_tong_tien_hang}    ${get_tong_tien_hang}   msg=Hiển thị sai thông tin Tổng tiền hàng ở chi tiết phiếu
    KV Should Be Equal As Numbers    ${text_GG_phieu}          ${get_GG_phieu}         msg=Hiển thị sai thông tin GG phiếu nhập ở chi tiết phiếu
    KV Should Be Equal As Numbers    ${text_can_tra_ncc}       ${get_can_tra_ncc}      msg=Hiển thị sai thông tin Cần trả NCC ở chi tiết phiếu
    KV Should Be Equal As Numbers    ${text_tien_tra_ncc}      ${get_tien_tra_ncc}     msg=Hiển thị sai thông tin Tiền trả NCC ở chi tiết phiếu
    KV Lists Should Be Equal         ${list_gtri_cp}           ${get_list_gtri_cp}     msg=Hiển thị sai thông tin giá trị CP nhập hàng ở chi tiết phiếu
    KV Lists Should Be Equal         ${list_gtri_cp_khac}      ${get_list_gtri_cp_khac}     msg=Hiển thị sai thông tin giá trị CP nhập hàng KHÁC ở chi tiết phiếu


#
