*** Settings ***
Library           SeleniumLibrary
Library           String
Library           BuiltIn
Library           Collections
Resource           ../../api_access.robot
Resource           ../../../share/computation.robot
Resource           ../../../share/list_dictionary.robot
Resource           ../../GET/hang-hoa/api_danhmuc_hanghoa.robot
Resource           ../../GET/doi-tac/api_nhacungcap.robot
Resource           ../../GET/thiet-lap/api_chi_phi_nhap_hang.robot
Resource          ../../../../config/envi.robot

*** Keywords ***
Them moi phieu nhap hang
    [Documentation]    Status=false => Phieu tam
    ...                Status=true => Phieu hoan thanh
    [Arguments]    ${ma_phieu_nhap}    ${dict_hang_hoa}    ${dict_don_gia}    ${tien_tra_ncc}    ${status}
    ...    ${ma_ncc}=${EMPTY}    ${dict_giam_gia}=${EMPTY}    ${giam_gia_phieu}=0    ${list_ma_CP_nhap}=${EMPTY}    ${list_ma_CP_khac}=${EMPTY}    ${ghi_chu}=${EMPTY}
    ${retailer_id}    ${user_id}    KV Get RetailerId And UserId
    ${id_ncc}=           Get supplier id by code    ${ma_ncc}
    ${list_ma_hang}=     Get Dictionary Keys    ${dict_hang_hoa}
    ${list_SL}=          Get Dictionary Values    ${dict_hang_hoa}
    ${list_don_gia}=     Get Dictionary Values    ${dict_don_gia}
    ${type_dict_giam_gia}=      Evaluate    type($dict_giam_gia).__name__
    ${type_list_ma_CP_nhap}=    Evaluate    type($list_ma_CP_nhap).__name__
    ${type_list_ma_CP_khac}=    Evaluate    type($list_ma_CP_khac).__name__
    ${list_giam_gia}=     Run Keyword If    '${type_dict_giam_gia}' == 'DotDict'    Get Dictionary Values    ${dict_giam_gia}    ELSE    Set Variable    0
    ${tong_tien_hang}=    Count tong tien hang phieu nhap    ${list_SL}    ${list_don_gia}    ${list_giam_gia}

    # tinh gia tri giam gia phieu nhap (đơn vị VND)
    ${data_discount_purchase}    ${GG_phieu_nhap}    KV set data discount purchaseOrders    ${giam_gia_phieu}    ${tong_tien_hang}

    # Tính tong chi phí nhập hàng, tổng chi phí nhập hàng khác, set data chi phi nhap va chi phi khac
    ${total_af_discount}    Minus    ${tong_tien_hang}    ${GG_phieu_nhap}
    ${list_id_CP_nhap}    ${list_value_CP_nhap}    ${list_type_CP_nhap}=    Get list id and expensesOther value by list code    ${list_ma_CP_nhap}
    ${list_id_CP_khac}    ${list_value_CP_khac}    ${list_type_CP_khac}=    Get list id and expensesOther value by list code    ${list_ma_CP_khac}
    # nếu là Chi phí nhập thì is_CP_nhap=true, nếu là CP nhập khác thì is_CP_nhap=false
    ${total_CP_nhap}    ${data_CP_nhap}    Run Keyword If    '${type_list_ma_CP_nhap}' == 'list'    Count tong chi phi and return data expensesOther    ${list_id_CP_nhap}
    ...    ${list_value_CP_nhap}    ${list_type_CP_nhap}    ${total_af_discount}    true
    ...    ELSE    Set Variable    0    ${EMPTY}
    ${total_CP_khac}    ${data_CP_khac}    Run Keyword If    '${type_list_ma_CP_khac}' == 'list'    Count tong chi phi and return data expensesOther    ${list_id_CP_khac}
    ...    ${list_value_CP_khac}    ${list_type_CP_khac}    ${total_af_discount}    false
    ...    ELSE    Set Variable    0    ${EMPTY}
    ${data_Expenses_full}    Run Keyword If    '${type_list_ma_CP_nhap}' == 'list' and '${type_list_ma_CP_khac}' != 'list'     Set Variable    ${data_CP_nhap}
    ...    ELSE IF    '${type_list_ma_CP_nhap}' != 'list' and '${type_list_ma_CP_khac}' == 'list'    Set Variable    ${data_CP_khac}
    ...    ELSE IF    '${type_list_ma_CP_nhap}' == 'list' and '${type_list_ma_CP_khac}' == 'list'    Set Variable    ${data_CP_nhap},${data_CP_khac}
    ...    ELSE    Set Variable    ${EMPTY}
    KV Log    ${data_Expenses_full}

    # Set thong tin cua hang hoa
    ${data_product}    KV set data PurchaseOrderDetails    ${list_ma_hang}    ${list_SL}    ${list_don_gia}    ${list_giam_gia}    ${GG_phieu_nhap}    ${total_CP_nhap}    ${total_CP_khac}    ${tong_tien_hang}

    # Set data tien tra NCC
    ${data_tra_ncc}    Run Keyword If    ${tien_tra_ncc} > 0    KV set data tra ncc    ${tien_tra_ncc}    ELSE    Set Variable    ${EMPTY}

    # Set jsonpath để lấy ra id của mã phiếu sau khi tạo
    ${jsonpath}    Set Variable    $.Id

    ${input_dict}    Create Dictionary     ma_phieu_nhap=${ma_phieu_nhap}        branch_id=${BRANCH_ID}                user_id=${user_id}              retailer_id=${retailer_id}      ma_ncc=${ma_ncc}    id_ncc=${id_ncc}
    ...    tien_tra_ncc=${tien_tra_ncc}    tong_chi_phi_nhap=${total_CP_nhap}    tong_chi_phi_khac=${total_CP_khac}    data_tra_ncc=${data_tra_ncc}    data_product=${data_product}    data_discount_purchase=${data_discount_purchase}
    ...    data_Expenses_full=${data_Expenses_full}    data_Expenses=${data_CP_nhap}    data_Expenses_other=${data_CP_khac}    ghi_chu=${ghi_chu}      complete=${status}

    ${result_id}    API Call From Template    /nhap-hang/add_phieu_nhap_hang.txt    ${input_dict}    ${jsonpath}
    ${id_pn}    Set Variable Return From Dict    ${result_id.Id[0]}
    Return From Keyword    ${id_pn}

Them moi list phieu nhap hang
    [Arguments]    @{list_data}
    ${list_id_pn}    Create List
    FOR    ${data_pn}    IN    @{list_data}
        ${id_pn}    Them moi phieu nhap hang    @{data_pn}
        Append To List    ${list_id_pn}    ${id_pn}
    END
    Return From Keyword    ${list_id_pn}

# ============== KW Set Data ===============
KV set data PurchaseOrderDetails
    [Arguments]    ${list_ma_hang}    ${list_SL}    ${list_don_gia}    ${list_giam_gia}    ${GG_phieu_nhap}    ${total_CP_nhap}    ${total_CP_khac}    ${tong_tien_hang}
    ${type_list_giam_gia}=    Evaluate    type($list_giam_gia).__name__
    ${list_id}    Get list product id by list product code    ${list_ma_hang}
    ${data_product}    Run Keyword If    '${type_list_giam_gia}' == 'list'    KV set data product with discount    ${list_id}    ${list_ma_hang}    ${list_SL}
    ...    ${list_don_gia}    ${list_giam_gia}    ${GG_phieu_nhap}    ${total_CP_nhap}    ${total_CP_khac}    ${tong_tien_hang}
    ...    ELSE    KV set data product without discount    ${list_id}    ${list_ma_hang}    ${list_SL}    ${list_don_gia}    ${list_giam_gia}    ${GG_phieu_nhap}    ${total_CP_nhap}    ${total_CP_khac}    ${tong_tien_hang}
    KV Log    ${data_product}
    Return From Keyword    ${data_product}

KV set data tra ncc
    [Arguments]    ${tien_tra_ncc}
    ${data_tra_ncc}    Set Variable    "PurchasePayments": [{"Amount": ${tien_tra_ncc},"Method": "Cash"}],
    Return From Keyword    ${data_tra_ncc}

KV set data discount purchaseOrders
    [Arguments]    ${giam_gia_phieu}    ${tong_tien_hang}
    ${discount_value}    Run Keyword If    0 <= ${giam_gia_phieu} <= 100    Convert % discount to VND    ${tong_tien_hang}    ${giam_gia_phieu}    ELSE    Set Variable    ${giam_gia_phieu}
    ${data_discount}    Set Variable If    0 <= ${giam_gia_phieu} <= 100    "Discount": ${discount_value},"CompareDiscount": 0,"DiscountRatio": ${giam_gia_phieu},
    ...    "Discount": ${discount_value},"CompareDiscount": 0,"DiscountRatio": null,
    KV Log    ${data_discount}
    KV Log    ${discount_value}
    Return From Keyword    ${data_discount}    ${discount_value}

# Trường hợp CÓ nhập giảm giá cho hàng hóa
KV set data product with discount
    [Arguments]    ${list_id}    ${list_ma_hang}    ${list_SL}    ${list_don_gia}    ${list_giam_gia}    ${GG_phieu_nhap}    ${total_CP_nhap}    ${total_CP_khac}    ${tong_tien_hang}
    ${list_data}    Create List
    ${length}    Get Length    ${list_ma_hang}
    ${view_index}    ${order_by_number}    Set Variable    ${length}    ${length}
    FOR    ${index}    IN RANGE    ${length}
        ${order_by_number}    Evaluate    ${length}-1
        ${input_discount}   Replace String    ${list_giam_gia[${index}]}    -    ${EMPTY}
        ${discount_number}   Convert To Number    ${input_discount}
        # tinh gia tri giảm giá của hàng hóa (VND)
        ${discount_vnd}    ${info_discount_product}    Count discount VND of product va set info discount product    ${list_don_gia}    ${list_giam_gia}    ${discount_number}    ${index}
        # Tính giá trị field : Allocation, AllocationSuppliers, AllocationThirdParty
        ${gia_nhap}    Minus    ${list_don_gia[${index}]}    ${discount_vnd}
        ${list_data}    Count allocation and return list product info    ${list_data}    ${list_id[${index}]}    ${list_ma_hang[${index}]}    ${list_SL[${index}]}    ${list_don_gia[${index}]}
        ...     ${gia_nhap}    ${GG_phieu_nhap}    ${tong_tien_hang}    ${total_CP_nhap}    ${total_CP_khac}    ${view_index}    ${order_by_number}    ${info_discount_product}
        ${view_index}    Evaluate    ${length}-1
    END
    ${list_data}    Reverse List one    ${list_data}
    ${join_str}    Evaluate    ",".join($list_data)
    KV Log    ${join_str}
    Return From Keyword    ${join_str}

# Trường hợp KHÔNG nhập giảm giá cho hàng hóa
KV set data product without discount
    [Arguments]    ${list_id}    ${list_ma_hang}    ${list_SL}    ${list_don_gia}    ${list_giam_gia}    ${GG_phieu_nhap}    ${total_CP_nhap}    ${total_CP_khac}    ${tong_tien_hang}
    ${list_data}    Create List
    ${length}    Get Length    ${list_ma_hang}
    ${view_index}    ${order_by_number}    Set Variable    ${length}    ${length}
    FOR    ${index}    IN RANGE    ${length}
        ${order_by_number}    Evaluate    ${length}-1
        ${discount_number}   Set Variable    0
        # Tính giá trị field : Allocation, AllocationSuppliers, AllocationThirdParty: công thức: =  giá nhập * giá trị/ tổng tiền hàng
        ${gia_nhap}    Set Variable    ${list_don_gia[${index}]}
        ${list_data}    Count allocation and return list product info    ${list_data}    ${list_id[${index}]}    ${list_ma_hang[${index}]}    ${list_SL[${index}]}    ${list_don_gia[${index}]}
        ...     ${gia_nhap}    ${GG_phieu_nhap}    ${tong_tien_hang}    ${total_CP_nhap}    ${total_CP_khac}    ${view_index}    ${order_by_number}
        ${view_index}    Evaluate    ${length}-1
    END
    ${list_data}    Reverse List one    ${list_data}
    ${join_str}    Evaluate    ",".join($list_data)
    KV Log    ${join_str}
    Return From Keyword    ${join_str}

#================ END Set Data ================================
Count allocation and return list product info
    [Arguments]    ${list_data}    ${item_id}    ${item_ma_hang}    ${item_SL}    ${item_don_gia}     ${gia_nhap}    ${GG_phieu_nhap}    ${tong_tien_hang}    ${total_CP_nhap}    ${total_CP_khac}
    ...    ${view_index}    ${order_by_number}    ${info_discount_product}=${EMPTY}
    ${item_allocation}   Computation discount allocation value    ${gia_nhap}    ${GG_phieu_nhap}    ${tong_tien_hang}
    ${item_AllocationSuppliers}   Computation discount allocation value    ${gia_nhap}    ${total_CP_nhap}    ${tong_tien_hang}
    ${item_AllocationThirdParty}   Computation discount allocation value    ${gia_nhap}    ${total_CP_khac}    ${tong_tien_hang}
    Append To List    ${list_data}    {"ProductId": ${item_id},"Product": {"Name": "","Code": "${item_ma_hang}","IsLotSerialControl": false},"ProductName": "","ProductCode": "${item_ma_hang}","Description": "","Price": ${item_don_gia},"priceAfterDiscount": ${gia_nhap},"Quantity": ${item_SL},"Allocation": "${item_allocation}","AllocationSuppliers": "${item_AllocationSuppliers}","AllocationThirdParty": "${item_AllocationThirdParty}","TotalValue": 0,"ViewIndex": ${view_index},"productGroupCount": 1,"rowNumber": 0,"Id": 0,${info_discount_product}"OrderByNumber": ${order_by_number}}
    Return From Keyword    ${list_data}

Count discount VND of product va set info discount product
    [Arguments]    ${list_don_gia}    ${list_giam_gia}    ${discount_number}    ${index}
    ${discount_vnd}    Run Keyword If    0<=${list_giam_gia[${index}]}<=100    Convert % discount to VND    ${list_don_gia[${index}]}    ${discount_number}
    ...    ELSE IF    ${list_giam_gia[${index}]}>100    Set Variable    ${list_giam_gia[${index}]}
    ${discount_vnd}    Evaluate    round(${discount_vnd},0)
    ${info_discount_product}    Set Variable If    0<${list_giam_gia[${index}]}<=100    "OriginPrice": ${list_don_gia[${index}]},"Discount": ${discount_vnd},"DiscountRatio": ${list_giam_gia[${index}]},
    ...    "OriginPrice": ${list_don_gia[${index}]},"Discount": ${discount_vnd},
    Return From Keyword    ${discount_vnd}    ${info_discount_product}

Count tong chi phi and return data expensesOther
    [Arguments]    ${list_id_CP}    ${list_value}    ${list_type}    ${total_af_discount}    ${is_CP_nhap}
    # nếu là Chi phí nhập thì is_CP_nhap=true, nếu là CP nhập khác thì is_CP_nhap=false
    ${total}    Set Variable    0
    ${list_data}    Create List
    ${length}    Get Length    ${list_value}
    FOR    ${index}    IN RANGE    ${length}
        ${value_VND}    Run Keyword If    '${list_type[${index}]}' == 'ValueRatio'    Convert % discount to VND    ${total_af_discount}    ${list_value[${index}]}    ELSE    Set Variable    ${list_value[${index}]}
        ${total}    Sum    ${total}    ${value_VND}
        ${ExValue_type}    Set Variable If    '${list_type[${index}]}' == 'ValueRatio'    "ExValueRatio": ${list_value[${index}]}    "ExValue": ${list_value[${index}]}
        ${From_value}    Set Variable If    '${is_CP_nhap}' == 'true'    0    1
        Append To List    ${list_data}    {"ExpensesOtherId": ${list_id_CP[${index}]},"Id": ${list_id_CP[${index}]},${ExValue_type},"Price": ${value_VND},"Name": "","Code": "","Form": ${From_value}}
    END
    ${data_ExpensesOther}    Evaluate    ",".join($list_data)
    KV Log    ${data_ExpensesOther}
    Return From Keyword    ${total}    ${data_ExpensesOther}

# Tính giá nhập là giá sau giảm giá
Count gia nhap cua hang hoa
    [Arguments]    ${list_giam_gia}    ${list_don_gia}    ${discount_number}    ${index}
    ${result_price}=    Run Keyword If    0<=${list_giam_gia[${index}]}<=100    Computation new price - discount - %    ${list_don_gia[${index}]}    ${discount_number}
    ...    ELSE IF    ${list_giam_gia[${index}]}>100    Computation new price - discount - VND    ${list_don_gia[${index}]}    ${discount_number}
    Return From Keyword    ${result_price}

Count tong tien hang phieu nhap
    [Arguments]    ${list_SL}    ${list_don_gia}    ${list_giam_gia}
    ${length}    Get Length    ${list_SL}
    ${tong_tien_hang}    Set Variable    0
    ${list_gia_nhap}    Create List
    FOR    ${index}    IN RANGE    ${length}
        ${input_discount}   Run Keyword If    ${list_giam_gia} != 0    Replace String    ${list_giam_gia[${index}]}    -    ${EMPTY}    ELSE    Set Variable    0
        ${discount_number}   Convert To Number    ${input_discount}
        # tinh giá nhập của hàng hóa (result_price = đơn giá - giảm giá.)
        ${result_price}=    Run Keyword If    ${list_giam_gia}!=0    Count gia nhap cua hang hoa    ${list_giam_gia}    ${list_don_gia}    ${discount_number}    ${index}
        ...    ELSE IF    ${list_giam_gia}==0    Set Variable    ${list_don_gia[${index}]}
        ${thanh_tien}    Multiplication and round 2    ${list_SL[${index}]}    ${result_price}
        ${tong_tien_hang}    Sum    ${tong_tien_hang}    ${thanh_tien}
    END
    Return From Keyword    ${tong_tien_hang}

Delete phieu nhap hang
    [Documentation]    is_void_payment=true  nếu có xóa phiếu thanh toán liên quan
    ...                is_void_payment=false nếu không xóa phiếu thanh toán liên quan
    [Arguments]   ${id_pn}    ${is_void_payment}
    ${input_dict}   Create Dictionary    id=${id_pn}    is_void_payment=${is_void_payment}
    Run Keyword If    ${id_pn} != 0    API Call From Template    /nhap-hang/delete_phieu_nhap_hang.txt    ${input_dict}    ELSE    KV Log    Phieu nhap khong ton tai

Delete list phieu nhap hang
    [Arguments]    ${list_id}
    FOR   ${id_pn}    IN    @{list_id}
        Delete phieu nhap hang    ${id_pn}    True
    END
