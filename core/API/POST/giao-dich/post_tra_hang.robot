*** Settings ***
Library           SeleniumLibrary
Library           String
Library           BuiltIn
Library           Collections
Library           ../../../../custom-library/UtilityLibrary.py
Resource          ../../api_access.robot
Resource          ../../../share/computation.robot
Resource          ../../../share/list_dictionary.robot
Resource          ../../GET/hang-hoa/api_danhmuc_hanghoa.robot
Resource          ../../GET/giao-dich/api_hoadon.robot
Resource          ../../GET/doi-tac/api_khachhang.robot
Resource          ../../../../config/envi.robot

*** Keywords ***
Them moi phieu tra hang
    [Documentation]    Phiếu trả nhanh => không input invoice_id
    ...    Phiếu trả hàng theo hóa đơn => không input customer_id
    ...    thoi_gian_phieu: thời gian tạo phiếu, định dạng: %Y-%m-%dT%H:%M:%S+07:00
    [Arguments]    ${dict_product}    ${customer_id}=${EMPTY}    ${invoice_id}=${EMPTY}    ${da_tra_khach}=${EMPTY}    ${ghi_chu}=${EMPTY}    ${is_return_id}=True
    ...    ${thoi_gian_phieu}=${EMPTY}    ${branch_id}=${BRANCH_ID}    ${surcharge}=0    ${surcharge_id}=${EMPTY}    ${surcharge_code}=${EMPTY}    ${surcharge_name}=${EMPTY}
    ${retailer_id}    ${sold_by_id}    KV Get RetailerId And UserId
    ${uuid_return}    Generate Random UUID
    ${get_cus_id}    Run Keyword If    '${invoice_id}'!='${EMPTY}'    Get customer id of invoice    ${invoice_id}    ELSE    Set Variable    ${EMPTY}

    ${result_customer_id}   Run Keyword If    ('${customer_id}'=='${EMPTY}' and '${get_cus_id}'=='${EMPTY}') or ('${customer_id}'=='${EMPTY}' and '${get_cus_id}'=='0')    Set Variable   ${EMPTY}
    ...     ELSE IF    ('${customer_id}'!='${EMPTY}' and '${get_cus_id}'=='${EMPTY}')    Set Variable    ${customer_id}
    ...     ELSE IF    ('${customer_id}'=='${EMPTY}' and '${get_cus_id}'!='0')    Set Variable    ${get_cus_id}
    ${data_customer}    KV Set Data Customer in Return    ${result_customer_id}

    ${data_invoice}    Set Variable If   '${invoice_id}'!='${EMPTY}'     "InvoiceId": ${invoice_id},"InvoiceSubTotal": 0,"InvoiceCode": "","CustomerPoint": 0,"CustomerOldPoint": 0,     ${EMPTY}
    ${data_ghi_chu}    Set Variable If   '${ghi_chu}'!='${EMPTY}'        "Description": "${ghi_chu}",    ${EMPTY}

    ${data_product}    ${tong_tien_hang_tra}    KV Set Data Product Of Return    ${dict_product}    ${invoice_id}    ${branch_id}
    ${da_tra_khach}    Set Variable If    '${da_tra_khach}'=='${EMPTY}'    ${tong_tien_hang_tra}    ${da_tra_khach}

    ${data_thoi_gian}    Set Variable If    '${thoi_gian_phieu}'=='${EMPTY}'    ${EMPTY}     "ReturnDate": "${thoi_gian_phieu}",
    ${returnSurcharges}    Set Variable If    "${surcharge}"!="0"   {"SurchargeId": ${surcharge_id},"SurValue": ${surcharge},"Price": ${surcharge},"Name": "${surcharge_name}","Code": "${surcharge_code}","RetailerId":${retailer_id},"isAuto": false,"isReturnAuto": true,"isActive": true}
    ...    ${EMPTY}

    ${InvoiceOrderSurcharges}    Set Variable If    "${surcharge}"!="0"   {"SurchargeId": ${surcharge_id},"SurValue": ${surcharge},"Price": ${surcharge},"Name": "${surcharge_name}","Code": "${surcharge_code}","RetailerId":${retailer_id},"isAuto": false,"isReturnAuto": true,"InvoiceId": null,"isActive": true}
    ...    ${EMPTY}

    ${input_dict}    Create Dictionary    branch_id=${branch_id}    retailer_id=${retailer_id}    data_invoice=${data_invoice}    data_customer=${data_customer}
    ...    id_nguoi_tra=${sold_by_id}    data_product=${data_product}    da_tra_khach=${da_tra_khach}    uuid=${uuid_return}    data_ghi_chu=${data_ghi_chu}    data_thoi_gian=${data_thoi_gian}
    ...    surcharge=${surcharge}     returnSurcharges=${returnSurcharges}    InvoiceOrderSurcharges=${InvoiceOrderSurcharges}
    ${result_dict}    API Call From Template    /tra-hang/add_phieu_tra_hang.txt    ${input_dict}    $.["Id","Code"]
    Run Keyword If    '${is_return_id}'=='True'    Return From Keyword    ${result_dict.Id[0]}
    ...    ELSE IF    '${is_return_id}'=='False'   Return From Keyword    ${result_dict.Code[0]}
    ...    ELSE IF    '${is_return_id}'=='All'     Return From Keyword    ${result_dict.Id[0]}    ${result_dict.Code[0]}

KV Set Data Customer in Return
    [Arguments]    ${result_customer_id}
    Return From Keyword If    '${result_customer_id}'=='${EMPTY}'    "Customer": null,
    ${data_customer}    Set Variable    "CustomerId": ${result_customer_id},"Customer": {"Id": ${result_customer_id},"Type": 0,"Code": "KHTQ02","Name": "Thanh Hà","ContactNumber": "0975588001","Email": "","Address": "Số 1","RetailerId": 744079,"Debt": 0,"ModifiedDate": "2020-12-31T11:07:11.3970000","CreatedDate": "2020-09-10T11:54:54.1230000","CreatedBy": 69197,"LocationId": 251,"LocationName": "Hà Nội - Quận Bắc Từ Liêm","RewardPoint": 39,"Uuid": "5ea4d72e-c452-4fbc-8b2b-c1be49f01f8f","BranchId": 29663,"WardName": "Phường Cổ Nhuế 2","LastTradingDate": "2020-12-31T11:07:55.0200000","IsActive": true,"isDeleted": false,"Revision": "AAAAACWD9jk=","Location": {"Id": 251,"Name": "Hà Nội - Quận Bắc Từ Liêm","ModifiedDate": "2017-05-24T00:16:42.9400000","NormalName": "Ha Noi - Quan Bac Tu Liem","Customers": [],"InvoiceDeliveries": [],"Wards": []},"Reservation": [],"CompareCode": "KHTQ02","CompareName": "Thanh Hà","MustUpdateDebt": false,"MustUpdatePoint": false,"InvoiceCount": 0,"SumQuantity": 0,"NormalizedName": "Thanh Ha"},
    Return From Keyword    ${data_customer}

KV Set Data Product Of Return
    [Arguments]    ${dict_product}    ${invoice_id}    ${branch_id}
    ${list_ma_hh}  Get Dictionary Keys      ${dict_product}
    ${list_sl}     Get Dictionary Values    ${dict_product}
    ${type}    Evaluate    type($list_ma_hh).__name__
    Run Keyword If    '${type}' !='list'   Create List    ${list_ma_hh}
    ${list_pr_id}    ${list_pr_price}    Get list id and base price by list code      ${list_ma_hh}    ${branch_id}
    ${list_data_product}    Create List
    ${tong_tien_hang_tra}   Set Variable    0
    ${length}    Get Length    ${list_pr_id}
    ${list_SL_max}    Get list max quantity in return by invoice     ${invoice_id}    ${list_ma_hh}
    FOR    ${index}    IN RANGE    0    ${length}
        ${pr_uuid}    Generate Random UUID
        ${data_item}    Set Variable If    '${invoice_id}'!='${EMPTY}'    {"Uuid": "${pr_uuid}","Note": "","Price": ${list_pr_price[${index}]},"ProductId": ${list_pr_id[${index}]},"Quantity": ${list_sl[${index}]},"UsePoint": false,"SellPrice": ${list_pr_price[${index}]},"ProductName": "Gạo 1","Rank": 0,"MaxQuantity": ${list_SL_max[${index}]},"Toppings": []}
        ...    {"Uuid": "${pr_uuid}","BasePrice": ${list_pr_price[${index}]},"Price": ${list_pr_price[${index}]},"ProductId": ${list_pr_id[${index}]},"Quantity": ${list_sl[${index}]},"SellPrice": ${list_pr_price[${index}]},"ProductName": "Gạo 1","Discount": 0,"DiscountRatio": null,"Rank": 0,"MaxQuantity": null,"Discounts": [],"QuantityType": 1,"Toppings": []}

        Append To List    ${list_data_product}    ${data_item}
        ${thanh_tien}    Multiplication    ${list_pr_price[${index}]}    ${list_sl[${index}]}
        ${tong_tien_hang_tra}    Sum    ${tong_tien_hang_tra}    ${thanh_tien}
    END
    KV Log    ${list_data_product}
    ${join_str}    Evaluate    ",".join($list_data_product)
    Return From Keyword    ${join_str}    ${tong_tien_hang_tra}

# Lấy danh sách max số lượng của các hàng hóa muốn trả: chính bắng SL hàng hóa đó trong hóa đơn tương ứng
Get list max quantity in return by invoice
    [Arguments]     ${invoice_id}    ${list_ma_hh_tra}
    ${list_ma_hh_in_HD}    ${list_SL_in_HD}    Get list ma va SL hang hoa trong hoa don    ${invoice_id}
    ${list_SL_max}    Create List
    FOR    ${ma_hh}    IN    @{list_ma_hh_tra}
        ${index}    Get Index From List    ${list_ma_hh_in_HD}    ${ma_hh}
        ${sl_max}    Set Variable    ${list_SL_in_HD[${index}]}
        Append To List    ${list_SL_max}    ${sl_max}
    END
    Return From Keyword    ${list_SL_max}

Delete phieu tra hang
    [Arguments]    ${id_phieu}   ${is_void_payment}=True
    ${input_dict}    Create Dictionary    id_phieu=${id_phieu}    is_void_payment=${is_void_payment}
    API Call From Template    /tra-hang/delete_phieu_tra_hang.txt    ${input_dict}

Delete list phieu tra hang
    [Arguments]    ${list_id_phieu}   ${is_void_payment}=True
    FOR    ${id_phieu}    IN ZIP    ${list_id_phieu}
        Delete phieu tra hang    ${id_phieu}    ${is_void_payment}
    END
#
