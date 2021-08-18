*** Settings ***
Resource          ../../api_access.robot
Resource          ../hang-hoa/api_danhmuc_hanghoa.robot
Resource          ../../../share/computation.robot
Library           String
Library           Collections

*** Keywords ***
# Lấy dict danh sách phiếu trả hàng nhập filter: mặc định các phiếu 7 ngày qua, All trạng thái phiếu
Get dict all PurchaseReturn info frm API
    [Arguments]    ${list_json_path}    ${thoi_gian}=7day    ${is_phieu_tam}=True    ${is_hoan_thanh}=True    ${is_phieu_huy}=True    ${so_ban_ghi}=${EMPTY}
    ${data_status}    KV Set Data Filter PurchaseReturn    ${is_phieu_tam}    ${is_hoan_thanh}    ${is_phieu_huy}
    ${data_filter}    Set Variable    "%24filter=(BranchId+eq+${BRANCH_ID}+and+ReturnDate+eq+'${thoi_gian}'+and+(${data_status}))",
    ${input_dict}    Create Dictionary    so_ban_ghi=${so_ban_ghi}    data_filter=${data_filter}
    ${result_dict}    API Call From Template    /tra-hang-nhap/all_phieu_tra_hang_nhap.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get dict detail PurchaseReturn info frm API
    [Arguments]   ${id_phieu}    ${list_jsonpath}
    ${input_dict}    Create Dictionary    id_phieu=${id_phieu}
    ${result_dict}    API Call From Template    /tra-hang-nhap/detail_phieu_tra_hang_nhap.txt    ${input_dict}   ${list_jsonpath}
    Return From Keyword    ${result_dict}

KV Set Data Filter PurchaseReturn
    [Arguments]    ${is_phieu_tam}    ${is_hoan_thanh}    ${is_phieu_huy}
    ${list_filter}    Create List
    Run Keyword If    '${is_phieu_tam}' == 'True'     Append To List    ${list_filter}    Status+eq+3
    Run Keyword If    '${is_hoan_thanh}' == 'True'    Append To List    ${list_filter}    Status+eq+1
    Run Keyword If    '${is_phieu_huy}' == 'True'     Append To List    ${list_filter}    Status+eq+2
    ${list_filter}     Evaluate    "+or+".join(${list_filter})
    Return From Keyword    ${list_filter}

Get purchase return id by code
    [Arguments]    ${input_code}
    ${result_dict}    Get dict all PurchaseReturn info frm API    $.Data[?(@.Code\=\="${input_code}")].Id
    ${result_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${result_id}

Get total of purchase return frm API
    ${result_dict}    Get dict all PurchaseReturn info frm API    $.Total    is_phieu_huy=False
    ${result_total}    Set Variable Return From Dict    ${result_dict.Total[0]}
    Return From Keyword    ${result_total}

Get tong tien hang cua phieu tra hang nhap
    [Arguments]    ${ma_phieu}
    ${list_jsonpath}    Create List    $.Data[?(@.Code\=\="${ma_phieu}")].["SubTotal","TotalQuantity"]
    ${result_dict}    Get dict all PurchaseReturn info frm API    ${list_jsonpath}
    ${tong_tien_hang}    Set Variable Return From Dict    ${result_dict.SubTotal[0]}
    ${tong_SL_HH}    Set Variable Return From Dict    ${result_dict.TotalQuantity[0]}
    Return From Keyword    ${tong_tien_hang}    ${tong_SL_HH}

Get list thong tin cua hang hoa trong phieu tra hang nhap
    [Arguments]    ${id_phieu}    ${is_return_gia}=False
    ${list_jsonpath}    Create List   $.PurchaseReturnDetails[*].["ProductCode","Quantity","SubTotal","ReturnPrice"]
    ${dict_detail}    Get dict detail PurchaseReturn info frm API    ${id_phieu}    ${list_jsonpath}
    ${get_list_ma}    Set Variable Return From Dict    ${dict_detail.ProductCode}
    ${get_list_SL}    Set Variable Return From Dict    ${dict_detail.Quantity}
    ${get_list_gia}   Set Variable Return From Dict    ${dict_detail.ReturnPrice}
    ${get_list_thanh_tien}    Set Variable Return From Dict    ${dict_detail.SubTotal}
    Run Keyword If    '${is_return_gia}'=='True'    Return From Keyword    ${get_list_ma}    ${get_list_SL}    ${get_list_gia}     ${get_list_thanh_tien}
    ...    ELSE IF    '${is_return_gia}'=='False'    Return From Keyword    ${get_list_ma}    ${get_list_SL}   ${get_list_thanh_tien}

Assert thong tin phieu tra hang nhap khi them moi
    [Arguments]    ${id_phieu}    ${list_ma_hh}    ${list_SL_tra}    ${list_thanh_tien}    ${count_total}    ${tien_ncc_tra}    ${status}
    ${list_jsonpath}    Create List   $.Data[?(@.Code\=\="${ma_phieu}")].["SubTotal","TotalPayment","Status"]
    ${result_dict}     Get dict all PurchaseReturn info frm API    ${list_jsonpath}    is_phieu_huy=False
    ${get_tong_tien_hang}    Set Variable Return From Dict    ${result_dict.SubTotal[0]}
    ${get_tien_ncc_tra}      Set Variable Return From Dict    ${result_dict.TotalPayment[0]}
    ${get_tien_ncc_tra}    Minus    0    ${get_tien_ncc_tra}
    ${get_status}            Set Variable Return From Dict    ${result_dict.Status[0]}
    KV Should Be Equal As Numbers    ${count_total}     ${get_tong_tien_hang}    msg=Lỗi sai tổng tiền hàng
    KV Should Be Equal As Numbers    ${tien_ncc_tra}    ${get_tien_ncc_tra}    msg=Lỗi sai tiền ncc trả
    KV Should Be Equal As Numbers    ${status}    ${get_status}    msg=Lỗi sai trạng thái phiếu
    # Assert thong tin hang hoa trong api
    ${get_list_ma}    ${get_list_SL}    ${get_list_thanh_tien}    Get list thong tin cua hang hoa trong phieu tra hang nhap    ${id_phieu}
    KV Lists Should Be Equal    ${list_ma_hh}    ${get_list_ma}    msg=Lỗi danh sách mã hàng trong phiếu không đúng
    KV Lists Should Be Equal    ${list_SL_tra}    ${get_list_SL}    msg=Lỗi danh sách SL trong phiếu không đúng
    KV Lists Should Be Equal    ${list_thanh_tien}    ${get_list_thanh_tien}    msg=Lỗi danh sách thành tiền trong phiếu không đúng

Assert trang thai phieu tra hang nhap sau khi huy
    [Arguments]    ${ma_phieu}    ${status}
    ${list_jsonpath}    Create List    $.Data[?(@.Code\=\="${ma_phieu}")].Status
    ${result_dict}    Get dict all PurchaseReturn info frm API    ${list_jsonpath}
    ${get_status}    Set Variable Return From Dict    ${result_dict.Status[0]}
    KV Should Be Equal As Strings    ${status}    ${get_status}    msg=Lỗi sai trạng thái phiếu
    #
Assert thong tin gia von va ton kho sau khi huy phieu tra hang nhap
    [Arguments]    ${ma_phieu}    ${list_ma}    ${list_ton_kho_bf}    ${list_gia_von_bf}
    ${list_ton_kho_af}    ${list_gia_von_af}    Get list onHand and cost by list product code    ${list_ma}
    KV Lists Should Be Equal    ${list_ton_kho_bf}    ${list_ton_kho_af}    msg=Lỗi sai tồn kho của HH sau khi hủy phiếu trả hàng nhập
    KV Lists Should Be Equal    ${list_gia_von_bf}    ${list_gia_von_af}    msg=Lỗi sai giá vốn của HH sau khi hủy phiếu trả hàng nhập

# Lấy thông tin từ APi để so sánh với file excel khi xuat file TONG QUAN
Get info to export all purchase return
    ${list_jsonpath}    Create List    $.Data[?(@.Id!=-1)].["Code","ReturnDate","Supplier.Name","SubTotal","Discount","TotalReturn","TotalPayment","Status"]
    ${result_dict}      Get dict all PurchaseReturn info frm API    ${list_jsonpath}    is_phieu_huy=False
    ${result_dict.Name}            Set Variable Return From Dict    ${result_dict.Name}
    ${result_dict.TotalPayment}    Set Variable Return From Dict    ${result_dict.TotalPayment}
    ${result_dict.ReturnDate}      KV Convert DateTime To String    ${result_dict.ReturnDate}
    ${list_status_value}    Create List
    # Chuan hoa du lieu de khop voi file excel
    FOR    ${item_code}    IN    @{result_dict.Code}
        ${index}    Get Index From List    ${result_dict.Code}    ${item_code}
        ${status_string}    Convert status value to string    ${result_dict.Status[${index}]}
        Append To List    ${list_status_value}    ${status_string}
        # Giá trị NCC đã trả: trong api lưu là số âm nên cần convert sang số dương như excel
        ${total_return_positive}    Minus    0    ${result_dict.TotalPayment[${index}]}
        Set List Value    ${result_dict.TotalPayment}    ${index}    ${total_return_positive}
    END
    Set To Dictionary    ${result_dict}    StatusValue    ${list_status_value}
    Remove From Dictionary    ${result_dict}    Status
    Return From Keyword    ${result_dict}

Convert status value to string
    [Arguments]    ${status}    ${is_short}=True
    ${type}    Evaluate    type($status).__name__
    ${list_status}    Run Keyword If    '${type}'=='list'    Set Variable    ${status}    ELSE    Create List    ${status}
    ${list_status_str}    Create List
    FOR    ${item_status}    IN    @{list_status}
        ${status_string}    Run Keyword If    '${item_status}'=='1' and '${is_short}'=='True'    Set Variable    Đã trả
        ...                        ELSE IF    '${item_status}'=='1' and '${is_short}'=='False'   Set Variable    Đã trả hàng
        ...                        ELSE IF    '${item_status}'=='3'    Set Variable    Phiếu tạm
        ...                        ELSE IF    '${item_status}'=='2'    Set Variable    Đã hủy
        Append To List    ${list_status_str}    ${status_string}
    END
    ${result}    Run Keyword If    '${type}'=='list'    Set Variable    ${list_status_str}    ELSE    Set Variable    ${list_status_str[0]}
    Return From Keyword    ${result}

# Lấy thông tin từ APi để so sánh với file excel khi xuat file CHI TIET
Get info to export all detail purchase return
    ${list_jsonpath}    Create List    $.Data[?(@.Id!=-1)].["Id","Branch.Name","Code","ReturnDate","Supplier.Code","Supplier.Name","Supplier.Phone","Supplier.Address","User.GivenName","User1.GivenName"]
    ...    $.Data[?(@.Id!=-1)].["SubTotal","Discount","DiscountRatio","TotalReturn","TotalPayment","Description","TotalQuantity","TotalProductType","Status"]
    ${dict_all}    Get dict all PurchaseReturn info frm API    ${list_jsonpath}    is_phieu_huy=False
    ${dict_all.Code}           Set Variable Return From Dict    ${dict_all.Code}     # Mã phiếu trả hàng nhập
    ${dict_all.Code1}          Set Variable Return From Dict    ${dict_all.Code1}    # Mã NCC
    ${dict_all.Name}           Set Variable Return From Dict    ${dict_all.Name}     # Tên CN
    ${dict_all.Name1}          Set Variable Return From Dict    ${dict_all.Name1}    # Tên NCC
    ${dict_all.Address}        Set Variable Return From Dict    ${dict_all.Address}
    ${dict_all.Phone}          Set Variable Return From Dict    ${dict_all.Phone}
    ${dict_all.Description}    Set Variable Return From Dict    ${dict_all.Description}
    ${dict_all.Discount}       Set Variable Return From Dict    ${dict_all.Discount}
    ${dict_all.DiscountRatio}  Set Variable Return From Dict    ${dict_all.DiscountRatio}
    ${dict_all.GivenName}      Set Variable Return From Dict    ${dict_all.GivenName}    # Tên người trả
    ${dict_all.GivenName1}     Set Variable Return From Dict    ${dict_all.GivenName1}    # Tên người tạo
    ${dict_all.ReturnDate}     KV Convert DateTime To String    ${dict_all.ReturnDate}
    ${dict_all.Status}         Convert status value to string   ${dict_all.Status}    is_short=False
    # Chuẩn hóa giá trị để khớp với file excel
    FOR   ${ma_phieu}    IN    @{dict_all.Code}
        ${index}    Get Index From List    ${dict_all.Code}    ${ma_phieu}
        # Nếu phiếu nhập k có nhập Nhà cung cấp thì khi export: mã NCC = "CC lẻ" và Tên NCC = "Nhà cung cấp lẻ"
        ${result_supplier_name}    Set Variable If    '${dict_all.Name1[${index}]}' == '0'    Nhà cung cấp lẻ    ${dict_all.Name1[${index}]}
        ${result_supplier_code}    Set Variable If    '${dict_all.Code1[${index}]}' == '0'    NCC lẻ    ${dict_all.Code1[${index}]}
        Set List Value    ${dict_all.Name1}    ${index}    ${result_supplier_name}
        Set List Value    ${dict_all.Code1}    ${index}    ${result_supplier_code}
        # Convert tiền NCC trả sang số dương
        ${tien_ncc_tra}    Minus    0    ${dict_all.TotalPayment[${index}]}
        Set List Value    ${dict_all.TotalPayment}    ${index}    ${tien_ncc_tra}
    END

    ${result_dict}    Create Dictionary   unique_key=@{EMPTY}    chi_nhanh=@{EMPTY}       ma_THN=@{EMPTY}      thoi_gian=@{EMPTY}      ma_ncc=@{EMPTY}    ten_ncc=@{EMPTY}
    ...      sdt=@{EMPTY}                 dia_chi=@{EMPTY}       nguoi_tra=@{EMPTY}       nguoi_tao=@{EMPTY}   tong_tien_hang_tra=@{EMPTY}   giam_gia=@{EMPTY}
    ...      ncc_can_tra=@{EMPTY}         tien_ncc_tra=@{EMPTY}  ghi_chu=@{EMPTY}         tong_sl=@{EMPTY}     tong_so_mat_hang=@{EMPTY}
    ...      trang_thai=@{EMPTY}          ma_hang=@{EMPTY}       ten_hang=@{EMPTY}        dvt=@{EMPTY}         ghi_chu_HH=@{EMPTY}           gia_tra_lai=@{EMPTY}
    ...      sl=@{EMPTY}                  GG_tra_lai=@{EMPTY}    GG_tra_lai_phantram=@{EMPTY}    thanh_tien=@{EMPTY}
    # ...      giam_gia_phantram=@{EMPTY}

    FOR    ${id_phieu}    IN    @{dict_all.Id}
        ${index_phieu}    Get Index From List    ${dict_all.Id}    ${id_phieu}
        ${dict_detail}    Get dict full info of product in purchase return    ${id_phieu}
        Purchase return mix data from API    ${dict_all.Code[${index_phieu}]}    ${result_dict}    ${dict_all}    ${dict_detail}    ${index_phieu}
    END
    Return From Keyword    ${result_dict}

Purchase return mix data from API
    [Arguments]    ${ma_phieu}    ${result_dict}    ${dict_all}    ${dict_detail}    ${index_phieu}
    FOR    ${product_code}    IN    @{dict_detail.ProductCode}
        ${index_product}    Get Index From List    ${dict_detail.ProductCode}    ${product_code}
        # Get tên HH kèm thuộc tính
        ${name_with_attr}    Get product name with attribute    ${dict_detail.ProductCode[${index_product}]}    ${dict_detail.ProductName[${index_product}]}    ${dict_detail.Unit[${index_product}]}
        ${unique_value}    Set Variable    ${ma_phieu}-${product_code}
        Append To List    ${result_dict.unique_key}    ${unique_value}
        Append To List    ${result_dict.chi_nhanh}             ${dict_all.Name[${index_phieu}]}
        Append To List    ${result_dict.ma_THN}                ${dict_all.Code[${index_phieu}]}
        Append To List    ${result_dict.thoi_gian}             ${dict_all.ReturnDate[${index_phieu}]}
        Append To List    ${result_dict.ma_ncc}                ${dict_all.Code1[${index_phieu}]}
        Append To List    ${result_dict.ten_ncc}               ${dict_all.Name1[${index_phieu}]}
        Append To List    ${result_dict.sdt}                   ${dict_all.Phone[${index_phieu}]}
        Append To List    ${result_dict.dia_chi}               ${dict_all.Address[${index_phieu}]}
        Append To List    ${result_dict.nguoi_tra}             ${dict_all.GivenName[${index_phieu}]}
        Append To List    ${result_dict.nguoi_tao}             ${dict_all.GivenName1[${index_phieu}]}
        Append To List    ${result_dict.tong_tien_hang_tra}    ${dict_all.SubTotal[${index_phieu}]}
        Append To List    ${result_dict.giam_gia}              ${dict_all.Discount[${index_phieu}]}
        # Append To List    ${result_dict.giam_gia_phantram}     ${dict_all.DiscountRatio[${index_phieu}]}
        Append To List    ${result_dict.ncc_can_tra}           ${dict_all.TotalReturn[${index_phieu}]}
        Append To List    ${result_dict.tien_ncc_tra}          ${dict_all.TotalPayment[${index_phieu}]}
        Append To List    ${result_dict.ghi_chu}               ${dict_all.Description[${index_phieu}]}
        Append To List    ${result_dict.tong_sl}               ${dict_all.TotalQuantity[${index_phieu}]}
        Append To List    ${result_dict.tong_so_mat_hang}      ${dict_all.TotalProductType[${index_phieu}]}
        Append To List    ${result_dict.trang_thai}            ${dict_all.Status[${index_phieu}]}
        Append To List    ${result_dict.ma_hang}               ${dict_detail.ProductCode[${index_product}]}
        Append To List    ${result_dict.ten_hang}              ${name_with_attr}
        Append To List    ${result_dict.dvt}                   ${dict_detail.Unit[${index_product}]}
        Append To List    ${result_dict.ghi_chu_HH}            ${dict_detail.ShortDescription[${index_product}]}
        Append To List    ${result_dict.gia_tra_lai}           ${dict_detail.ReturnPrice[${index_product}]}
        Append To List    ${result_dict.sl}                    ${dict_detail.Quantity[${index_product}]}
        Append To List    ${result_dict.GG_tra_lai}            ${dict_detail.Discount[${index_product}]}
        Append To List    ${result_dict.GG_tra_lai_phantram}   ${dict_detail.DiscountRatio[${index_product}]}
        Append To List    ${result_dict.thanh_tien}            ${dict_detail.SubTotal[${index_product}]}
    END

Get dict full info of product in purchase return
    [Arguments]    ${id_phieu}
    ${list_jsonpath}    Create List    $.PurchaseReturnDetails[*].["ProductCode","ProductName","Product.Unit","Product.ShortDescription","BuyPrice","ReturnPrice","Quantity","Discount","DiscountRatio","SubTotal"]
    ${dict_detail}    Get dict detail PurchaseReturn info frm API    ${id_phieu}    ${list_jsonpath}
    ${dict_detail.Unit}               Set Variable Return From Dict    ${dict_detail.Unit}
    ${dict_detail.ShortDescription}   Set Variable Return From Dict    ${dict_detail.ShortDescription}
    ${dict_detail.Discount}           Set Variable Return From Dict    ${dict_detail.Discount}
    ${dict_detail.DiscountRatio}      Set Variable Return From Dict    ${dict_detail.DiscountRatio}
    ${dict_detail.DiscountRatio}    Count DiscountRatio of Product in PurchaseReturn    ${dict_detail.ProductCode}    ${dict_detail.Discount}    ${dict_detail.DiscountRatio}    ${dict_detail.BuyPrice}
    Return From Keyword    ${dict_detail}

Count DiscountRatio of Product in PurchaseReturn
    [Arguments]     ${list_pr_code}    ${list_discount}    ${list_discount_ratio}    ${list_buy_price}
    FOR    ${pr_code}    IN    @{list_pr_code}
        ${index}    Get Index From List    ${list_pr_code}    ${pr_code}
        ${discount_%}    Run Keyword If    ${list_discount_ratio[${index}]}==0 and ${list_discount[${index}]}!=0    Convert VND discount to %    ${list_discount[${index}]}    ${list_buy_price[${index}]}    3
        ...     ELSE     Set Variable    ${list_discount_ratio[${index}]}
        Set List Value    ${list_discount_ratio}    ${index}    ${discount_%}
    END
    Return From Keyword    ${list_discount_ratio}

# Lấy thông tin từ APi để so sánh với file excel khi xuat file CHI TIET 1 PHIẾU TRẢ HÀNG NHẬP
Get info to export one purchase return
    [Arguments]    ${id_phieu}
    # Get gia tri NCC da tra
    ${list_jsonpath}    Create List    $.Data[?(@.Id\=\=${id_phieu})].[TotalPayment","TotalQuantity","TotalProductType","SubTotal","Discount","ExReturnSuppliers","TotalReturn"]
    ${dict_all}    Get dict all PurchaseReturn info frm API    ${list_jsonpath}
    ${dict_all.TotalPayment}    KV Swap between negative number and positive number    ${dict_all.TotalPayment}
    # Get cac gia tri khac trong file excel
    ${list_jsonpath1}    Create List    $.PurchaseReturnDetails[*].["ProductCode","Product.FullName","Product.Unit","Quantity","BuyPrice","ReturnPrice","Discount","DiscountRatio"]    $.ProductCount
    ${result_dict}    Get dict detail PurchaseReturn info frm API    ${id_phieu}    ${list_jsonpath1}
    ${result_dict.Unit}    Set Variable Return From Dict    ${result_dict.Unit}
    ${result_dict.DiscountRatio}    Set Variable Return From Dict    ${result_dict.DiscountRatio}
    ${tong_hh}    Set Variable Return From Dict    ${result_dict.ProductCount[0]}
    ${result_dict.DiscountRatio}    Count DiscountRatio of Product in PurchaseReturn    ${result_dict.ProductCode}    ${result_dict.Discount}    ${result_dict.DiscountRatio}    ${result_dict.BuyPrice}
    # Trong file excel k có trường thông tin này nên remove khỏi dictionary
    Remove From Dictionary    ${result_dict}    ProductCount
    # Get tên HH bao gồm tên + thuộc tính
    FOR    ${pr_code}    IN    @{result_dict.ProductCode}
        ${index}    Get Index From List    ${result_dict.ProductCode}    ${pr_code}
        ${name_with_attr}    Get product name with attribute    ${result_dict.ProductCode[${index}]}    ${result_dict.FullName[${index}]}    ${result_dict.Unit[${index}]}
        ${name_with_attr}    Strip String    ${name_with_attr}    mode=right
        Set List Value    ${result_dict.FullName}    ${index}    ${name_with_attr}
    END
    #----------------------
    ${dict_summary}    Create Dictionary    tong_sl=@{EMPTY}    tong_mat_hang=@{EMPTY}    tong_tien_hang_tra=@{EMPTY}    giam_gia=@{EMPTY}
    ...    CP_nhap_hoan_lai=@{EMPTY}    NCC_can_tra=@{EMPTY}    NCC_da_tra=@{EMPTY}
    Append To List    ${dict_summary.tong_sl}               ${dict_all.TotalQuantity[0]}
    Append To List    ${dict_summary.tong_mat_hang}         ${dict_all.TotalProductType[0]}
    Append To List    ${dict_summary.tong_tien_hang_tra}    ${dict_all.SubTotal[0]}
    Append To List    ${dict_summary.giam_gia}              ${dict_all.Discount[0]}
    Append To List    ${dict_summary.CP_nhap_hoan_lai}      ${dict_all.ExReturnSuppliers[0]}
    Append To List    ${dict_summary.NCC_can_tra}           ${dict_all.TotalReturn[0]}
    Append To List    ${dict_summary.NCC_da_tra}            ${dict_all.TotalPayment[0]}
    Return From Keyword    ${dict_summary}    ${result_dict}    ${tong_hh}

#
