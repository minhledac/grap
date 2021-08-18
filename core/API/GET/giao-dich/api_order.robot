*** Settings ***
Resource          ../../api_access.robot
Resource          ../../../share/utils.robot
Resource          ../hang-hoa/api_danhmuc_hanghoa.robot
Resource          ../../../share/computation.robot
Library           String
Library           Collections

*** Keywords ***
Get dict all order frm API
    [Arguments]    ${list_jsonpath}    ${thoi_gian}=alltime    ${is_phieu_tam}=True    ${is_hoan_thanh}=True    ${is_dang_giao}=True    ${is_da_huy}=False    ${branch_id}=${BRANCH_ID}    ${so_ban_ghi}=${EMPTY}
    ${filter_status}    KV Get Filter Status Order    ${is_phieu_tam}    ${is_hoan_thanh}    ${is_dang_giao}    ${is_da_huy}
    ${input_dict}    Create Dictionary    branch_id=${branch_id}    thoi_gian=${thoi_gian}    filter_status=${filter_status}    so_ban_ghi=${so_ban_ghi}
    ${result_dict}    API Call From Template    /order/all_order.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

# Filter theo status của hoa don
KV Get Filter Status Order
    [Arguments]    ${is_phieu_tam}    ${is_hoan_thanh}    ${is_dang_giao}    ${is_da_huy}
    ${list_filter}    Create List
    Run Keyword If    '${is_phieu_tam}' == 'True'    Append To List    ${list_filter}    Status+eq+1
    Run Keyword If    '${is_dang_giao}' == 'True'    Append To List    ${list_filter}    Status+eq+2
    Run Keyword If    '${is_hoan_thanh}' == 'True'   Append To List    ${list_filter}    Status+eq+3
    Run Keyword If    '${is_da_huy}' == 'True'       Append To List    ${list_filter}    Status+eq+4
    ${list_filter}     Evaluate    "+or+".join(${list_filter})
    Return From Keyword    ${list_filter}

Get dict detail order frm API
    [Arguments]    ${order_id}    ${list_jsonpath}
    ${input_dict}    Create Dictionary    order_id=${order_id}
    ${result_dict}    API Call From Template    /order/detail_order.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get order id by order uuid
    [Arguments]    ${order_uuid}    ${branch_id}=${BRANCH_ID}
    ${result_dict}     Get dict all order frm API    $.Data[?(@.Uuid\=\="${order_uuid}")].Id    branch_id=${branch_id}
    ${order_id}    Set Variable    ${result_dict.Id[0]}
    Return From Keyword    ${order_id}

Get list product id and price in order
    [Arguments]    ${order_id}
    ${list_jsonpath}    Create List    $.OrderDetails[*].["Uuid","Price"]
    ${result_dict}      Get dict detail order frm API    ${order_id}    ${list_jsonpath}
    ${list_pr_uuid}     Set Variable Return From Dict    ${result_dict.Uuid}
    ${list_pr_price}    Set Variable Return From Dict    ${result_dict.Price}
    Return From Keyword    ${list_pr_uuid}    ${list_pr_price}

Get order code by order uuid
    [Arguments]    ${order_uuid}    ${branch_id}=${BRANCH_ID}
    ${result_dict}     Get dict all order frm API    $.Data[?(@.Uuid\=\="${order_uuid}")].Code    branch_id=${branch_id}
    ${order_code}    Set Variable    ${result_dict.Code[0]}
    Return From Keyword    ${order_code}

Assert thong tin thu ngan tao don hang voi api Orders
    [Arguments]    ${aggregate_id}    ${table_id}    ${customer_code}    ${pricebook_id}    ${SaleChannel_id}    ${list_pr_code}    ${list_pr_quantity}
    ...    ${list_pr_price}    ${list_pr_note}    ${list_surcharge_id}    ${order_note}    ${discount_order}    ${payment_amount}
    ${order_id}    Get order id by order uuid    ${aggregate_id}
    ${list_jsonpath}    Create List    $.["TableId","Customer.Code","SaleChannelId","Description","Discount","Extra"]    $.OrderDetails[*].["ProductCode","Quantity","Price","Discount","DiscountRatio","Note"]
    ...    $.InvoiceOrderSurcharges.["SurchargeId"]
    ${result_dict}    Get dict detail order frm API    ${order_id}    ${list_jsonpath}
    ${get_table_id}            Set Variable    ${result_dict.TableId[0]}
    ${get_customer_code}       Set Variable Return From Dict    ${result_dict.Code[0]}
    ${get_SaleChannel_id}      Set Variable Return From Dict    ${result_dict.SaleChannelId[0]}
    ${get_order_note}          Set Variable Return From Dict    ${result_dict.Description[0]}
    ${get_discount_order}      Set Variable Return From Dict    ${result_dict.Discount[0]}
    ${get_list_pr_code}        Set Variable    ${result_dict.ProductCode}
    ${get_list_pr_quantity}    Set Variable    ${result_dict.Quantity}
    ${get_list_pr_baseprice}   Set Variable    ${result_dict.Price}
    ${get_list_pr_disc}        Set Variable Return From Dict    ${result_dict.Discount2}
    ${get_list_pr_disc_ratio}  Set Variable Return From Dict    ${result_dict.DiscountRatio}
    ${get_list_pr_note}        Set Variable Return From Dict    ${result_dict.Note}
    ${get_list_surcharge_id}   Set Variable Return From Dict    ${result_dict.SurchargeId}
    ${dict_extra}              KV Convert Json String To Json Object And Return Dict    ${result_dict.Extra[0]}    $.["PriceBookId.Id","Amount"]
    ${get_pricebook_id}        Set Variable Return From Dict    ${dict_extra.Id[0]}
    ${get_payment_amount}      Set Variable Return From Dict    ${dict_extra.Amount[0]}
    # Tính giá mới của HH
    ${get_list_pr_price}    Create List
    FOR    ${pr_code}    IN    @{get_list_pr_code}
        ${index}    Get Index From List    ${get_list_pr_code}    ${pr_code}
        ${new_price}    Minus    ${get_list_pr_baseprice[${index}]}    ${get_list_pr_disc[${index}]}
        Append To List    ${get_list_pr_price}    ${new_price}
        ${pr_note}    Set Variable If    '${get_list_pr_note[${index}]}'=='0'    ${EMPTY}    ${get_list_pr_note[${index}]}
        Run Keyword If    '${get_list_pr_note[${index}]}'=='0'    Set List Value    ${get_list_pr_note}    ${index}    ${pr_note}
    END
    KV Should Be Equal As Integers   ${table_id}           ${get_table_id}           msg=Lỗi sai phòng/bàn
    KV Should Be Equal As Strings    ${customer_code}      ${get_customer_code}      msg=Lỗi sai khách hàng
    KV Should Be Equal As Integers   ${pricebook_id}       ${get_pricebook_id}       msg=Lỗi sai bảng giá
    KV Should Be Equal As Integers   ${SaleChannel_id}     ${get_SaleChannel_id}     msg=Lỗi sai kênh bán
    KV Lists Should Be Equal         ${list_pr_code}       ${get_list_pr_code}       msg=Lỗi sai danh sách mã hàng
    KV Lists Should Be Equal         ${list_pr_quantity}   ${get_list_pr_quantity}   msg=Lỗi sai SL hàng hóa
    KV Lists Should Be Equal         ${list_pr_price}      ${get_list_pr_price}      msg=Lỗi sai giá bán hàng hóa
    KV Lists Should Be Equal         ${list_pr_note}       ${get_list_pr_note}       msg=Lỗi sai ghi chú hàng hóa
    KV Should Be Equal As Strings    ${order_note}         ${get_order_note}         msg=Lỗi sai ghi chú đơn hàng
    KV Should Be Equal As Numbers    ${discount_order}     ${get_discount_order}     msg=Lỗi sai ghi giảm giá đơn hàng
    KV Should Be Equal As Numbers    ${payment_amount}     ${get_payment_amount}     msg=Lỗi sai giá trị khách thanh toán

Assert thong tin trong don hang tao bang vai tro thu ngan
    [Arguments]    ${aggregate_id}    ${table_id}    ${list_pr_code}    ${list_pr_quantity}    ${list_pr_new_price}    ${list_pr_note}    ${customer_code}
    ...    ${pricebook_id}    ${sale_channel_id}    ${order_note}    ${discount_order}    ${list_surcharge_id}    ${payment_amount}
    ${order_id}    Get order id by order uuid    ${aggregate_id}
    ${list_jsonpath}    Create List    $.["TableId","Customer.Code","SaleChannelId","Description","Discount","Extra"]    $.OrderDetails[*].["ProductCode","Quantity","Price","Discount","Note"]
    ...    $.InvoiceOrderSurcharges[*].["SurchargeId"]
    ${result_dict}    Get dict detail order frm API    ${order_id}    ${list_jsonpath}
    ${get_table_id}             Set Variable    ${result_dict.TableId[0]}
    ${get_list_pr_code}         Set Variable    ${result_dict.ProductCode}
    ${get_list_pr_quantity}     Set Variable    ${result_dict.Quantity}
    ${get_list_pr_baseprice}    Set Variable    ${result_dict.Price}
    ${get_list_pr_disc}         Set Variable Return From Dict    ${result_dict.Discount2}
    ${get_list_pr_note}         Set Variable Return From Dict    ${result_dict.Note}
    ${get_customer_code}        Set Variable Return From Dict    ${result_dict.Code[0]}
    ${get_sale_channel_id}      Set Variable Return From Dict    ${result_dict.SaleChannelId[0]}
    ${get_order_note}           Set Variable Return From Dict    ${result_dict.Description[0]}
    ${get_discount_order}       Set Variable Return From Dict    ${result_dict.Discount[0]}
    ${get_list_surcharge_id}    Set Variable Return From Dict    ${result_dict.SurchargeId}
    ${dict_extra}              KV Convert Json String To Json Object And Return Dict    ${result_dict.Extra[0]}    $.["PriceBookId.Id","Amount"]
    ${get_pricebook_id}        Set Variable Return From Dict    ${dict_extra.Id[0]}
    ${get_payment_amount}      Set Variable Return From Dict    ${dict_extra.Amount[0]}

    # Tính giá mới của HH
    ${get_list_pr_price}    Create List
    FOR    ${pr_code}    IN    @{get_list_pr_code}
        ${index}    Get Index From List    ${get_list_pr_code}    ${pr_code}
        ${new_price}    Minus    ${get_list_pr_baseprice[${index}]}    ${get_list_pr_disc[${index}]}
        Append To List    ${get_list_pr_price}    ${new_price}
        ${pr_note}    Set Variable If    '${get_list_pr_note[${index}]}'=='0'    ${EMPTY}    ${get_list_pr_note[${index}]}
        Run Keyword If    '${get_list_pr_note[${index}]}'=='0'    Set List Value    ${get_list_pr_note}    ${index}    ${pr_note}
    END

    KV Should Be Equal As Integers    ${table_id}             ${get_table_id}            msg=Lỗi sai phòng/bàn
    KV Lists Should Be Equal          ${list_pr_code}         ${get_list_pr_code}        msg=Lỗi sai danh sách mã hàng
    KV Lists Should Be Equal          ${list_pr_quantity}     ${get_list_pr_quantity}    msg=Lỗi sai SL hàng hóa
    KV Lists Should Be Equal          ${list_pr_new_price}    ${get_list_pr_price}       msg=Lỗi sai giá bán hàng hóa
    KV Lists Should Be Equal          ${list_pr_note}         ${get_list_pr_note}        msg=Lỗi sai ghi chú hàng hóa
    KV Should Be Equal As Integers    ${pricebook_id}         ${get_pricebook_id}        msg=Lỗi sai bảng giá
    KV Should Be Equal As Strings     ${customer_code}        ${get_customer_code}        msg=Lỗi sai khách hàng
    KV Should Be Equal As Integers    ${sale_channel_id}      ${get_sale_channel_id}      msg=Lỗi sai kênh bán
    KV Should Be Equal As Strings     ${order_note}           ${get_order_note}           msg=Lỗi sai ghi chú đơn hàng
    KV Should Be Equal As Numbers     ${discount_order}       ${get_discount_order}       msg=Lỗi sai ghi giảm giá đơn hàng
    KV Lists Should Be Equal          ${list_surcharge_id}    ${get_list_surcharge_id}    msg=Lỗi sai thu khác
    KV Should Be Equal As Numbers     ${payment_amount}       ${get_payment_amount}       msg=Lỗi sai giá trị khách thanh toán

Assert thong tin trong don hang tao bang vai tro boi ban
    [Arguments]    ${aggregate_id}    ${table_id}    ${list_pr_code}    ${list_pr_quantity}    ${list_pr_price}    ${list_pr_note}
    ...    ${customer_code}    ${sale_channel_id}    ${order_note}
    ${order_id}    Get order id by order uuid    ${aggregate_id}
    ${list_jsonpath}    Create List    $.["TableId","Customer.Code","SaleChannelId","Description"]    $.OrderDetails[*].["ProductCode","Quantity","Price","Note"]
    ${result_dict}    Get dict detail order frm API    ${order_id}    ${list_jsonpath}
    ${get_table_id}             Set Variable    ${result_dict.TableId[0]}
    ${get_list_pr_code}         Set Variable    ${result_dict.ProductCode}
    ${get_list_pr_quantity}     Set Variable    ${result_dict.Quantity}
    ${get_list_pr_baseprice}    Set Variable    ${result_dict.Price}
    ${get_list_pr_note}       Set Variable Return From Dict    ${result_dict.Note}
    ${get_customer_code}      Set Variable Return From Dict    ${result_dict.Code[0]}
    ${get_sale_channel_id}    Set Variable Return From Dict    ${result_dict.SaleChannelId[0]}
    ${get_order_note}         Set Variable Return From Dict    ${result_dict.Description[0]}
    # Set ghi chú của mỗi hàng hóa
    FOR    ${pr_code}    IN    @{get_list_pr_code}
        ${index}    Get Index From List    ${get_list_pr_code}    ${pr_code}
        ${pr_note}    Set Variable If    '${get_list_pr_note[${index}]}'=='0'    ${EMPTY}    ${get_list_pr_note[${index}]}
        Run Keyword If    '${get_list_pr_note[${index}]}'=='0'    Set List Value    ${get_list_pr_note}    ${index}    ${pr_note}
    END

    KV Should Be Equal As Integers    ${table_id}            ${get_table_id}             msg=Lỗi sai phòng/bàn
    KV Lists Should Be Equal          ${list_pr_code}        ${get_list_pr_code}         msg=Lỗi sai danh sách mã hàng
    KV Lists Should Be Equal          ${list_pr_quantity}    ${get_list_pr_quantity}     msg=Lỗi sai SL hàng hóa
    KV Lists Should Be Equal          ${list_pr_price}       ${get_list_pr_baseprice}    msg=Lỗi sai giá bán hàng hóa
    KV Lists Should Be Equal          ${list_pr_note}        ${get_list_pr_note}         msg=Lỗi sai ghi chú hàng hóa
    KV Should Be Equal As Strings     ${customer_code}       ${get_customer_code}        msg=Lỗi sai khách hàng
    KV Should Be Equal As Integers    ${sale_channel_id}     ${get_sale_channel_id}      msg=Lỗi sai kênh bán
    KV Should Be Equal As Strings     ${order_note}          ${get_order_note}           msg=Lỗi sai ghi chú đơn hàng

Assert thong tin boi ban tao don hang voi api Orders
    [Arguments]    ${aggregate_id}    ${table_id}    ${customer_code}    ${SaleChannel_id}    ${list_pr_code}    ${list_pr_quantity}    ${list_pr_note}    ${order_note}
    ${order_id}    Get order id by order uuid    ${aggregate_id}
    ${list_jsonpath}    Create List    $.["TableId","Customer.Code","SaleChannelId","Description"]    $.OrderDetails[*].["ProductCode","Quantity","Note"]
    ${result_dict}    Get dict detail order frm API    ${order_id}    ${list_jsonpath}
    ${get_table_id}            Set Variable    ${result_dict.TableId[0]}
    ${get_customer_code}       Set Variable Return From Dict    ${result_dict.Code[0]}
    ${get_SaleChannel_id}      Set Variable Return From Dict    ${result_dict.SaleChannelId[0]}
    ${get_order_note}          Set Variable Return From Dict    ${result_dict.Description[0]}
    ${get_list_pr_code}        Set Variable    ${result_dict.ProductCode}
    ${get_list_pr_quantity}    Set Variable    ${result_dict.Quantity}
    ${get_list_pr_note}        Set Variable Return From Dict    ${result_dict.Note}
    FOR    ${pr_code}    IN    @{get_list_pr_code}
        ${index}    Get Index From List    ${get_list_pr_code}    ${pr_code}
        ${pr_note}    Set Variable If    '${get_list_pr_note[${index}]}'=='0'    ${EMPTY}    ${get_list_pr_note[${index}]}
        Run Keyword If    '${get_list_pr_note[${index}]}'=='0'    Set List Value    ${get_list_pr_note}    ${index}    ${pr_note}
    END
    KV Should Be Equal As Integers   ${table_id}           ${get_table_id}           msg=Lỗi sai phòng/bàn
    KV Should Be Equal As Strings    ${customer_code}      ${get_customer_code}      msg=Lỗi sai khách hàng
    KV Should Be Equal As Integers   ${SaleChannel_id}     ${get_SaleChannel_id}     msg=Lỗi sai kênh bán
    KV Lists Should Be Equal         ${list_pr_code}       ${get_list_pr_code}       msg=Lỗi sai danh sách mã hàng
    KV Lists Should Be Equal         ${list_pr_quantity}   ${get_list_pr_quantity}   msg=Lỗi sai SL hàng hóa
    KV Lists Should Be Equal         ${list_pr_note}       ${get_list_pr_note}       msg=Lỗi sai ghi chú hàng hóa
    KV Should Be Equal As Strings    ${order_note}         ${get_order_note}         msg=Lỗi sai ghi chú đơn hàng

Get order infomation for payment
    [Arguments]    ${order_id}    ${is_get_delivery}=False
    ${list_jsonpath}    Create List    $.["Code","SaleChannelId","CustomerId","NumberCustomer","TableId","Description","Extra","Total","SubTotal","Surcharge","Discount","DiscountRatio","PurchaseDate"]
    ...    $.OrderDetails[*].["Uuid","ProductId","ProductCode","Price","Discount","DiscountRatio","Note","Quantity"]
    ...    $.InvoiceOrderSurcharges[*].["SurchargeId","Price","SurValueRatio"]
    Run Keyword If    "${is_get_delivery}"=="True"    Append To List    ${list_jsonpath}    $.["DeliveryDetail.Receiver","DeliveryDetail.ContactNumber","DeliveryDetail.Address","DeliveryDetail.WardName","DeliveryDetail.LocationName","DeliveryDetail.LocationId","DeliveryDetail.ExpectedDelivery","DeliveryDetail.DeliveryCode","DeliveryDetail.PartnerDelivery.Id"]
    ${result_dict}    Get dict detail order frm API    ${order_id}    ${list_jsonpath}
    KV Log Dictionary    ${result_dict}
    ${order_code}        Set Variable    ${result_dict.Code[0]}
    ${total}             Set Variable    ${result_dict.Total[0]}
    ${sub_total}         Set Variable    ${result_dict.SubTotal[0]}
    ${salechannel_id}    Set Variable Return From Dict    ${result_dict.SaleChannelId[0]}
    ${customer_id}       Set Variable Return From Dict    ${result_dict.CustomerId[0]}
    ${number_customer}   Set Variable Return From Dict    ${result_dict.NumberCustomer[0]}
    ${table_id}          Set Variable    ${result_dict.TableId[0]}
    ${description}       Set Variable Return From Dict    ${result_dict.Description[0]}
    ${order_discount_VND}      Set Variable Return From Dict    ${result_dict.Discount[0]}
    ${order_discount_ratio}    Set Variable Return From Dict    ${result_dict.DiscountRatio[0]}
    ${dict_extra}    KV Convert Json String To Json Object And Return Dict    ${result_dict.Extra[0]}    $.PriceBookId.Id
    ${pricebook_id}    Set Variable Return From Dict    ${dict_extra.Id[0]}
    ${PurchaseDate}    Set Variable    ${result_dict.PurchaseDate[0]}
    ${PurchaseDate}    Convert string datetime in API to datetime type    ${PurchaseDate}    date_format=%Y-%m-%dT%H:%M:%S.%f
    ${PurchaseDate}    Convert Date    ${PurchaseDate}    result_format=%Y-%m-%dT%H:%M:%S+07:00
    # thong tin hang hoa
    ${list_pr_uuid}      Set Variable    ${result_dict.Uuid}
    ${list_pr_id}        Set Variable    ${result_dict.ProductId}
    ${list_pr_code}      Set Variable    ${result_dict.ProductCode}
    ${list_pr_price}     Set Variable    ${result_dict.Price}
    ${list_pr_quantity}    Set Variable    ${result_dict.Quantity}
    ${list_pr_discount}    Set Variable    ${result_dict.Discount2}
    ${list_pr_discount_ratio}    Set Variable    ${result_dict.DiscountRatio2}
    ${list_pr_note}      Set Variable Return From Dict    ${result_dict.Note}
    # thu khac
    ${total_surchange}        Set Variable Return From Dict    ${result_dict.Surcharge[0]}
    ${list_surcharge_id}      Set Variable Return From Dict    ${result_dict.SurchargeId}
    ${list_surcharge_price}   Set Variable Return From Dict    ${result_dict.Price3}
    ${list_SurValueRatio}     Set Variable Return From Dict    ${result_dict.SurValueRatio}
    # Tính GG đơn hàng theo VND
    ${order_discount}    Run Keyword If    ${order_discount_ratio}==0    Set Variable    ${order_discount_VND}    ELSE    Convert % discount to VND    ${order_discount_ratio}    ${sub_total}
    ${Receiver}    ${ContactNumber}    ${Address}    ${WardName}    ${LocationName}    ${LocationId}    ${ExpectedDelivery}    ${delivery_id}    ${delivery_code}    Run Keyword If    '${is_get_delivery}'=='True'    Get delivery data from response    ${result_dict}
    Run Keyword If    '${is_get_delivery}'=='False'    Return From Keyword    ${order_code}    ${total}    ${sub_total}    ${order_discount}    ${salechannel_id}    ${customer_id}    ${number_customer}    ${table_id}    ${description}    ${pricebook_id}
    ...    ${list_pr_uuid}    ${list_pr_id}    ${list_pr_code}    ${list_pr_price}    ${list_pr_quantity}    ${list_pr_discount}    ${list_pr_discount_ratio}    ${list_pr_note}
    ...    ${total_surchange}    ${list_surcharge_id}    ${list_surcharge_price}    ${list_SurValueRatio}    ${PurchaseDate}
    ...    ELSE IF    '${is_get_delivery}'=='True'    Return From Keyword    ${order_code}    ${total}    ${sub_total}    ${order_discount}    ${salechannel_id}    ${customer_id}    ${number_customer}    ${table_id}    ${description}    ${pricebook_id}
    ...    ${list_pr_uuid}    ${list_pr_id}    ${list_pr_code}    ${list_pr_price}    ${list_pr_quantity}    ${list_pr_discount}    ${list_pr_discount_ratio}    ${list_pr_note}
    ...    ${total_surchange}    ${list_surcharge_id}    ${list_surcharge_price}    ${list_SurValueRatio}    ${PurchaseDate}
    ...    ${Receiver}    ${ContactNumber}    ${Address}    ${WardName}    ${LocationName}    ${LocationId}    ${ExpectedDelivery}    ${delivery_id}    ${delivery_code}

Get delivery data from response
    [Arguments]    ${result_dict}
    ${Receiver}           Set Variable Return From Dict    ${result_dict.Receiver[0]}
    ${ContactNumber}      Set Variable Return From Dict    ${result_dict.ContactNumber[0]}
    ${Address}            Set Variable Return From Dict    ${result_dict.Address[0]}
    ${WardName}           Set Variable Return From Dict    ${result_dict.WardName[0]}
    ${LocationName}       Set Variable Return From Dict    ${result_dict.LocationName[0]}
    ${LocationId}         Set Variable Return From Dict    ${result_dict.LocationId[0]}
    ${ExpectedDelivery}   Set Variable Return From Dict    ${result_dict.ExpectedDelivery[0]}
    ${delivery_id}        Set Variable Return From Dict    ${result_dict.Id[0]}
    ${delivery_code}      Set Variable Return From Dict    ${result_dict.DeliveryCode[0]}
    # chuẩn hóa dữ liệu
    ${Receiver}         Set Variable If    '${Receiver}'!='0'        ${Receiver}         ${EMPTY}
    ${ContactNumber}    Set Variable If    '${ContactNumber}'!='0'   ${ContactNumber}    ${EMPTY}
    ${Address}          Set Variable If    '${Address}'!='0'         ${Address}          ${EMPTY}
    ${WardName}         Set Variable If    '${WardName}'!='0'        ${WardName}         ${EMPTY}
    ${LocationName}     Set Variable If    '${LocationName}'!='0'    "${LocationName}"     null
    ${LocationId}       Set Variable If    '${LocationId}'!='0'      ${LocationId}       ${EMPTY}
    ${ExpectedDelivery}     Set Variable If    '${ExpectedDelivery}'!='0'    ${ExpectedDelivery}     ${EMPTY}
    ${delivery_id}      Set Variable If    '${delivery_id}'!='0'    ${delivery_id}     ${EMPTY}
    ${delivery_code}     Set Variable If    '${delivery_code}'!='0'    ${delivery_code}     ${EMPTY}
    Return From Keyword    ${Receiver}    ${ContactNumber}    ${Address}    ${WardName}    ${LocationName}    ${LocationId}    ${ExpectedDelivery}    ${delivery_id}    ${delivery_code}

Get order uuid by order code
    [Arguments]    ${order_code}    ${is_sleep}=False    ${sleep_time}=10s    ${branch_id}=${BRANCH_ID}
    Run Keyword If    '${is_sleep}'=='True'    Sleep    ${sleep_time}
    ${result_dict}     Get dict all order frm API    $.Data[?(@.Code\=\="${order_code}")].Uuid    branch_id=${branch_id}
    ${order_Uuid}    Set Variable    ${result_dict.Uuid[0]}
    Return From Keyword    ${order_Uuid}

Get list order uuid by order code
    ${list_order_Uuid}    Create List
    ${list_jsonpath}    Create List    $.Data[?(@.Id!=-1)].["Code","Uuid"]
    ${result_dict}    Get dict all order frm API    ${list_jsonpath}     is_hoan_thanh=False    is_dang_giao=False
    ${list_code}    Set Variable    ${result_dict.Code}
    KV Log    ${list_code}
    Remove Values From List    ${list_code}    0
    ${list_uuid}    Set Variable    ${result_dict.Uuid}
    FOR    ${order_code}    IN ZIP     ${list_code}
        ${is_order_old_fnb}    Run Keyword And Return Status    Should Contain    ${order_code}    DH
        Continue For Loop If    '${is_order_old_fnb}'=='True'
        ${index}    Get Index From List    ${list_code}    ${order_code}
        ${order_Uuid}    Set Variable    ${list_uuid[${index}]}
        Append To List    ${list_order_Uuid}    ${order_Uuid}
    END
    KV Log    ${list_order_Uuid}
    Return From Keyword    ${list_order_Uuid}

Get order id by order code
    [Arguments]    ${order_code}    ${branch_id}=${BRANCH_ID}    ${is_da_huy}=False
    ${result_dict}     Get dict all order frm API    $.Data[?(@.Code\=\="${order_code}")].Id    branch_id=${branch_id}    is_da_huy=${is_da_huy}
    ${order_id}    Set Variable    ${result_dict.Id[0]}
    Return From Keyword    ${order_id}

Get thong tin status cua don order frm API
    [Arguments]    ${ma_order}
    ${order_id}    Get order id by order code    ${ma_order}    is_da_huy=True
    ${list_jsonpath}     Create List    $.["StatusValue"]
    ${result_dict}    Get dict detail order frm API    ${order_id}    ${list_jsonpath}
    ${status}    Set Variable Return From Dict    ${result_dict.StatusValue[0]}
    Return From Keyword    ${status}
# ............................................... Assert dữ liệu .............................................
Assert status don trong api orders
    [Arguments]    ${ma_order}    ${order_status}
    ${status}    Get thong tin status cua don order frm API    ${ma_order}
    KV Should Be Equal    ${status}    ${order_status}    msg=Lỗi sai trạng thái hủy đơn hàng
