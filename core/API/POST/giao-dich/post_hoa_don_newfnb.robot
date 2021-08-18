*** Settings ***
Library           SeleniumLibrary
Library           String
Library           BuiltIn
Library           Collections
Resource           ../../api_access.robot
Resource          ../../../../config/envi.robot
Resource          ../../../share/utils.robot
Resource          ../../../share/list_dictionary.robot
Resource          ../../../share/computation.robot
Resource          ../../POST/event/post_event_newfnb.robot
Resource           ../../GET/doi-tac/api_khachhang.robot
Resource           ../../GET/doi-tac/api_doi_tac_giao_hang.robot
Resource           ../../GET/phong-ban/api_phong_ban.robot
Resource           ../../GET/giao-dich/api_order.robot
Resource           ../../GET/hang-hoa/api_thiet_lap_gia.robot
Resource           ../../GET/hang-hoa/api_danhmuc_hanghoa.robot
Resource           ../../GET/giao-dich/api_hoadon.robot

*** Keywords ***
Them moi hoa don ngoi tai ban New Fnb
    [Documentation]    "Ngồi tại bàn" : DiningOption=2 và table_id là id của phòng bàn
    ...    payment_type=1 => Tiền thừa trả khách
    ...    payment_type=2 => Tính vào công nợ
    [Arguments]    ${aggregate_id}    ${customer_payment}=all    ${payment_type}=1    ${branch_id}=${BRANCH_ID}    ${is_return_id}=True
    Sleep    5s
    ${input_dict}    ${jsonpath_id_code}    Set Input Dictionary To Template Invoice New Fnb    ${aggregate_id}    ${branch_id}    ${customer_payment}    ${payment_type}
    ${result_dict}   API Call From Template    /hoa-don/add_hoa_don_newfnb.txt    ${input_dict}    ${jsonpath_id_code}
    ${result_id}     Set Variable Return From Dict    ${result_dict.Id[0]}
    ${result_code}     Set Variable Return From Dict    ${result_dict.Code[0]}
    Run Keyword If    '${is_return_id}'=='True'    Return From Keyword    ${result_id}
    ...    ELSE IF    '${is_return_id}'=='False'    Return From Keyword    ${result_code}
    ...    ELSE IF    '${is_return_id}'=='All'    Return From Keyword    ${result_id}    ${result_code}

Them moi hoa don mang ve New Fnb
    [Documentation]
    ...    payment_type=1 => Tiền thừa trả khách
    ...    payment_type=2 => Tính vào công nợ
    [Arguments]    ${aggregate_id}    ${customer_payment}=all    ${payment_type}=1    ${branch_id}=${BRANCH_ID}    ${is_return_id}=True
    ${input_dict}    ${jsonpath_id_code}    Set Input Dictionary To Template Invoice New Fnb    ${aggregate_id}    ${branch_id}    ${customer_payment}    ${payment_type}    3
    ${result_dict}   API Call From Template    /hoa-don/add_hoa_don_newfnb.txt    ${input_dict}    ${jsonpath_id_code}
    ${result_id}     Set Variable Return From Dict    ${result_dict.Id[0]}
    ${result_code}     Set Variable Return From Dict    ${result_dict.Code[0]}
    Run Keyword If    '${is_return_id}'=='True'    Return From Keyword    ${result_id}
    ...    ELSE IF    '${is_return_id}'=='False'    Return From Keyword    ${result_code}
    ...    ELSE IF    '${is_return_id}'=='All'    Return From Keyword    ${result_id}    ${result_code}

Them moi hoa don giao di New Fnb
    [Documentation]
    ...    payment_type=1 => Tiền thừa trả khách
    ...    payment_type=2 => Tính vào công nợ
    ...    thu_ho_tien=0 : nếu Uncheck vào Checkbox Thu hộ tiền
    ...    thu_ho_tien=1 : nếu Check vào Checkbox Thu hộ tiền
    [Arguments]    ${aggregate_id}    ${customer_payment}=all    ${payment_type}=1    ${delivery_price}=0    ${status}=3    ${branch_id}=${BRANCH_ID}    ${is_return_id}=True    ${thu_ho_tien}=0
    ${input_dict}    ${jsonpath_id_code}    Set Input Dictionary To Template Invoice Delivery New Fnb    ${aggregate_id}    ${branch_id}    ${customer_payment}    ${payment_type}    ${delivery_price}    ${status}    ${thu_ho_tien}
    ${result_dict}   API Call From Template    /hoa-don/add_HD_giao_di_newfnb.txt    ${input_dict}    ${jsonpath_id_code}
    ${result_id}     Set Variable Return From Dict    ${result_dict.Id[0]}
    ${result_code}     Set Variable Return From Dict    ${result_dict.Code[0]}
    Run Keyword If    '${is_return_id}'=='True'    Return From Keyword    ${result_id}
    ...    ELSE IF    '${is_return_id}'=='False'    Return From Keyword    ${result_code}
    ...    ELSE IF    '${is_return_id}'=='All'    Return From Keyword    ${result_id}    ${result_code}

Tao don hang va thay doi chi tiet thong tin
    [Arguments]    ${table_id}    ${list_pr_id}    ${list_pr_price}    ${customer_id}    ${number_customer}    ${order_note}    ${SaleChannel_id}
    ...    ${dining_option}    ${list_quantity}=${EMPTY}    ${branch_id}=${BRANCH_ID}
    ${aggregate_id}    ${list_pr_uuid}    Post Event Sync Create Order And Add An Item    ${table_id}    ${list_pr_id}    ${list_pr_price}    dining_option=${dining_option}    branch_id=${branch_id}
    ${type_list_quantity}=    Evaluate    type($list_quantity).__name__
    Run Keyword If    '${type_list_quantity}' == 'list'    Post Event Sync Adjust Item Quantity    ${aggregate_id}    ${list_quantity}    ${list_pr_uuid}
    Post Event Sync Change Customer    ${aggregate_id}    ${customer_id}
    Post Event Sync Change Number Customer    ${aggregate_id}    ${number_customer}
    Post Event Sync Change Order Note    ${aggregate_id}    ${order_note}
    Post Event Sync Change Sale Channel    ${aggregate_id}    ${SaleChannel_id}
    Sleep    5s
    ${order_code}    Get order code by order uuid    ${aggregate_id}
    Return From Keyword    ${order_code}

# -------------- KV SET DATA ------------------
Set Input Dictionary To Template Invoice Delivery New Fnb
    [Arguments]    ${aggregate_id}    ${branch_id}    ${customer_payment}    ${payment_type}    ${delivery_price}    ${status}    ${thu_ho_tien}
    ${order_id}    Get order id by order uuid    ${aggregate_id}    ${branch_id}
    # Lấy thông tin từ api/orders
    ${order_code}    ${total}    ${sub_total}    ${order_discount}    ${salechannel_id}    ${customer_id}    ${number_customer}    ${table_id}    ${description}    ${pricebook_id}
    ...    ${list_pr_uuid}    ${list_pr_id}    ${list_pr_code}    ${list_pr_price}    ${list_pr_quantity}    ${list_pr_discount}    ${list_pr_discount_ratio}    ${list_pr_note}
    ...    ${total_surchange}    ${list_surcharge_id}    ${list_surcharge_price}    ${list_SurValueRatio}    ${PurchaseDate}
    ...    ${Receiver}    ${ContactNumber}    ${Address}    ${WardName}    ${LocationName}    ${LocationId}    ${ExpectedDelivery}    ${delivery_id}    ${delivery_code}    Get order infomation for payment    ${order_id}     is_get_delivery=True

    ${data_product}      KV Set All Data Product New Fnb    ${list_pr_uuid}    ${list_pr_id}    ${list_pr_code}    ${list_pr_quantity}    ${list_pr_price}    ${list_pr_discount}    ${list_pr_discount_ratio}    ${list_pr_note}
    ${data_customer}     Run Keyword If     ${customer_id}!=0        KV Set Data Customer New Fnb    ${customer_id}    ${USER_ID}    ${branch_id}    ELSE    Set Variable    "Customer":null,
    # data delivery
    ${data_receiver}    ${data_expected_delivery}    ${data_delivery_price}    ${data_delivery_code}    ${data_location}    ${data_partner_delivery}    KV Set Data Delivery New Fnb    ${Receiver}
    ...    ${LocationId}    ${ExpectedDelivery}    ${delivery_id}    ${delivery_code}    ${delivery_price}
    ${data_pricebook}    Set Variable If    ${pricebook_id}!=0       "PriceBookId": ${pricebook_id},       ${EMPTY}
    ${data_salechanel}   Set Variable If    ${SaleChannel_id}!=0     "SaleChannelId": ${SaleChannel_id},   ${EMPTY}
    ${data_description}  Set Variable If    '${description}'!='0'    "Description": "${description}",      ${EMPTY}
    ${PurchaseDate}     Set Variable If    '${PurchaseDate}'!='0'    ${PurchaseDate}    ${EMPTY}
    ${data_surchange}    KV Set Data Surchange    ${list_surcharge_id}    ${list_surcharge_price}    ${list_SurValueRatio}
    ${jsonpath_id_code}    Set Variable    $.["Id","Code"]
    ${customer_payment}    Set Variable If    '${customer_payment}'=='all'    ${total}    ${customer_payment}
    ${payment_type}    Run Keyword If    ${customer_id}==0    Set Variable    1
    ...    ELSE IF    ${customer_id}!=0 and ${customer_payment}<${total}    Set Variable    2
    ...    ELSE IF    ${customer_id}!=0 and ${customer_payment}>=${total}    Set Variable    ${payment_type}
    ${real_payment}    Run Keyword If    ${customer_id}==0    KV Set Customer Payment With Give Change To Customer Option    ${total}    ${customer_payment}
    ...    ELSE    KV Set Customer Payment With Enter Into Account Option    ${total}    ${customer_payment}    ${payment_type}

    ${input_dict}   Create Dictionary     uuid_invoice=${aggregate_id}     branch_id=${branch_id}               order_code=${order_code}              retailer_id=${RETAILER_ID}    SoldBy_id=${USER_ID}
    ...    data_product=${data_product}   data_customer=${data_customer}   data_pricebook=${data_pricebook}     data_salechanel=${data_salechanel}    data_description=${data_description}
    ...    total=${total}                 sub_total=${sub_total}           total_surchange=${total_surchange}   data_surchange=${data_surchange}
    ...    customer_payment=${customer_payment}    real_payment=${real_payment}    order_discount=${order_discount}    PurchaseDate=${PurchaseDate}     status=${status}
    ...    data_receiver=${data_receiver}          data_expected_delivery=${data_expected_delivery}    data_delivery_price=${data_delivery_price}    data_delivery_code=${data_delivery_code}    data_location=${data_location}    data_partner_delivery=${data_partner_delivery}
    ...    receiver_name=${Receiver}     receiver_phone=${ContactNumber}    receiver_address=${Address}    thu_ho_tien=${thu_ho_tien}    ward_name=${WardName}    location_name=${LocationName}
    Return From Keyword    ${input_dict}    ${jsonpath_id_code}

KV Set Data Delivery New Fnb
    [Arguments]    ${Receiver}    ${LocationId}    ${ExpectedDelivery}    ${delivery_id}    ${delivery_code}    ${delivery_price}
    ${data_receiver}            Set Variable If    '${Receiver}'!='${EMPTY}'            ,"Receiver": "${Receiver}"    ${EMPTY}
    ${data_expected_delivery}   Set Variable If    '${ExpectedDelivery}'!='${EMPTY}'    ,"ExpectedDelivery": "${ExpectedDelivery}"     ${EMPTY}
    ${data_delivery_price}      Set Variable If    '${delivery_price}'!='0'             ,"Price": ${delivery_price}     ${EMPTY}
    ${data_delivery_code}       Set Variable If    '${delivery_code}'!='${EMPTY}'       ,"DeliveryCode": "${delivery_code}"     ${EMPTY}
    ${data_location}            Set Variable If    '${LocationId}'!='${EMPTY}'          ,"LocationId": ${LocationId},"Location":{"Id": ${LocationId},"Name": "","ModifiedDate": "","NormalName": "","Customers": [],"InvoiceDeliveries": [],"Wards": []}     ${EMPTY}
    ${data_partner_delivery}    Set Variable If    '${delivery_id}'!='${EMPTY}'         ,"DeliveryBy": ${delivery_id},"PartnerDelivery": {"__type": "KiotViet.Persistence.PartnerDelivery, KiotViet.Persistence","TotalInvoiced": 0,"CompareCode": "TN_DTGH02","CompareName": "ĐTGH TN_GHT02","Id": ${delivery_id},"RetailerId": ${RETAILER_ID},"Type": 0,"Code": "TN_DTGH02","Name": "ĐTGH TN_GHT02","CreatedDate": "2020-11-04T18:31:28.6500000","CreatedBy": 69197,"LocationName": "","WardName": "","isActive": true,"isDeleted": false,"SearchNumber": "","InvoiceDeliveries": [],"PartnerDeliveryGroupDetails": [],"PurchasePayments": [],"DeliveryInfoes": [],"DeliveryPayments": []}    ${EMPTY}
    Return From Keyword    ${data_receiver}    ${data_expected_delivery}    ${data_delivery_price}    ${data_delivery_code}    ${data_location}    ${data_partner_delivery}

Set Input Dictionary To Template Invoice New Fnb
    [Arguments]    ${aggregate_id}    ${branch_id}    ${customer_payment}    ${payment_type}    ${DiningOption}=2    ${using_code}=0
    ${order_id}    Get order id by order uuid    ${aggregate_id}    ${branch_id}
    # Lấy thông tin từ api/orders
    ${order_code}    ${total}    ${sub_total}    ${order_discount}    ${salechannel_id}    ${customer_id}    ${number_customer}    ${table_id}    ${description}    ${pricebook_id}
    ...    ${list_pr_uuid}    ${list_pr_id}    ${list_pr_code}    ${list_pr_price}    ${list_pr_quantity}    ${list_pr_discount}    ${list_pr_discount_ratio}    ${list_pr_note}
    ...    ${total_surchange}    ${list_surcharge_id}    ${list_surcharge_price}    ${list_SurValueRatio}    ${PurchaseDate}    Get order infomation for payment    ${order_id}

    ${data_product}      KV Set All Data Product New Fnb    ${list_pr_uuid}    ${list_pr_id}    ${list_pr_code}    ${list_pr_quantity}    ${list_pr_price}    ${list_pr_discount}    ${list_pr_discount_ratio}    ${list_pr_note}
    ${data_customer}     Run Keyword If     ${customer_id}!=0        KV Set Data Customer New Fnb    ${customer_id}    ${USER_ID}    ${branch_id}    ELSE    Set Variable    "Customer":null,
    ${data_SL_khach}     Set Variable If    ${number_customer}!=0    "NumberCustomer": ${number_customer},     ${EMPTY}
    ${data_pricebook}    Set Variable If    ${pricebook_id}!=0       "PriceBookId": ${pricebook_id},       ${EMPTY}
    ${data_salechanel}   Set Variable If    ${SaleChannel_id}!=0     "SaleChannelId": ${SaleChannel_id},   ${EMPTY}
    ${data_description}  Set Variable If    '${description}'!='0'    "Description": "${description}",   ${EMPTY}
    ${PurchaseDate}     Set Variable If    '${PurchaseDate}'!='0'    ${PurchaseDate}    ${EMPTY}
    ${data_surchange}    KV Set Data Surchange    ${list_surcharge_id}    ${list_surcharge_price}    ${list_SurValueRatio}
    ${jsonpath_id_code}    Set Variable    $.["Id","Code"]
    ${customer_payment}    Set Variable If    '${customer_payment}'=='all'    ${total}    ${customer_payment}
    ${payment_type}    Run Keyword If    ${customer_id}==0    Set Variable    1
    ...    ELSE IF    ${customer_id}!=0 and ${customer_payment}<${total}    Set Variable    2
    ...    ELSE IF    ${customer_id}!=0 and ${customer_payment}>=${total}    Set Variable    ${payment_type}
    ${real_payment}    Run Keyword If    ${customer_id}==0    KV Set Customer Payment With Give Change To Customer Option    ${total}    ${customer_payment}
    ...    ELSE    KV Set Customer Payment With Enter Into Account Option    ${total}    ${customer_payment}    ${payment_type}

    ${input_dict}   Create Dictionary     uuid_invoice=${aggregate_id}     branch_id=${branch_id}              order_code=${order_code}              retailer_id=${RETAILER_ID}    SoldBy_id=${USER_ID}
    ...    data_product=${data_product}   data_customer=${data_customer}   data_pricebook=${data_pricebook}    data_salechanel=${data_salechanel}    data_description=${data_description}
    ...    DiningOption=${DiningOption}   table_id=${table_id}             using_code=${using_code}            data_SL_khach=${data_SL_khach}        customer_payment=${customer_payment}    real_payment=${real_payment}
    ...    total=${total}                 sub_total=${sub_total}           total_surchange=${total_surchange}    data_surchange=${data_surchange}    order_discount=${order_discount}    PurchaseDate=${PurchaseDate}
    Return From Keyword    ${input_dict}    ${jsonpath_id_code}

KV Set Customer Payment With Give Change To Customer Option
    [Arguments]    ${total}    ${customer_payment}
    ${real_payment}    Set Variable If    ${customer_payment}>=${total}    ${total}    ${customer_payment}
    Return From Keyword    ${real_payment}

KV Set Customer Payment With Enter Into Account Option
    [Arguments]    ${total}    ${customer_payment}    ${payment_type}
    ${real_payment}    Run Keyword If    ${payment_type}==1    Set Variable    ${total}
    ...    ELSE IF    ${payment_type}==2    Set Variable    ${customer_payment}
    Return From Keyword    ${real_payment}

# Thông tin chung của các loại hàng hóa
KV Set Common Data Product New Fnb
    [Arguments]    ${pr_uuid}    ${pr_id}    ${pr_quantity}    ${pr_price}    ${pr_discount}    ${pr_discount_ratio}    ${pr_note}    ${index}
    ${pr_note}    Set Variable If    '${pr_note}'!='0'    ${pr_note}    ${EMPTY}
    ${data_common}    Set Variable    {"Uuid": "${pr_uuid}","Note": "${pr_note}","Price": ${pr_price},"ProductId": ${pr_id},"Quantity": ${pr_quantity},"Discount": ${pr_discount},"DiscountRatio": ${pr_discount_ratio},"ProductName": "","Rank": ${index},"Toppings": [],"Formulas": [],
    Return From Keyword    ${data_common}

# Hàng thường, sản xuất
KV Set Data Standar Product New Fnb
    [Arguments]    @{list_param}
    Remove From List    ${list_param}    -1
    ${data_common}    KV Set Common Data Product New Fnb    @{list_param}
    ${data_product}   Set Variable    ${data_common}"QuantityType": 1,"ProductGroup":3}
    Return From Keyword    ${data_product}

# Hàng dịch vụ và dịch vụ tính giờ
KV Set Data Service Product New Fnb
    [Arguments]    @{list_param}
    ${loai_hang}    Set Variable    ${list_param[-1]}
    Remove From List    ${list_param}    -1
    ${data_common}    KV Set Common Data Product New Fnb    @{list_param}
    ${data_product}   Run Keyword If    '${loai_hang[1]}'=='True'    Set Variable    ${data_common}"QuantityType": 2,"ProductGroup":1}
    ...    ELSE IF    '${loai_hang[1]}'=='0'    Set Variable    ${data_common}"QuantityType": 1,"ProductGroup":1}
    Return From Keyword    ${data_product}

# Hàng combo
KV Set Data Combo Product New Fnb
    [Arguments]    @{list_param}
    Remove From List    ${list_param}    -1
    ${data_common}    KV Set Common Data Product New Fnb    @{list_param}
    ${data_product}   Set Variable    ${data_common}"QuantityType": 1,"ProductGroup":1}
    Return From Keyword    ${data_product}

# Hàng chế biến
KV Set Data ProcessedGood Product New Fnb
    [Arguments]    @{list_param}
    Remove From List    ${list_param}    -1
    ${data_common}    KV Set Common Data Product New Fnb    @{list_param}
    ${data_product}   Set Variable    ${data_common}"QuantityType": 1,"ProductGroup":1}
    Return From Keyword    ${data_product}

Get Data Product By Product Type New Fnb
    [Arguments]    @{list_param}
    ${loai_hang}    Set Variable    ${list_param[-1]}
    ${data_product}    Run Keyword If    '${loai_hang}'=='Hàng hóa'           KV Set Data Standar Product New Fnb         @{list_param}
    ...                ELSE IF           '${loai_hang}'=='Chế biến'           KV Set Data ProcessedGood Product New Fnb   @{list_param}
    ...                ELSE IF           '${loai_hang}'=='Combo - đóng gói'   KV Set Data Combo Product New Fnb           @{list_param}
    KV Log    ${data_product}
    Return From Keyword    ${data_product}

KV Set All Data Product New Fnb
    [Arguments]    ${list_pr_uuid}    ${list_pr_id}    ${list_pr_code}    ${list_pr_quantity}    ${list_pr_price}    ${list_pr_discount}    ${list_pr_discount_ratio}    ${list_pr_note}
    ${list_data_product}    Create List
    ${length}    Get Length    ${list_pr_uuid}
    FOR    ${index}    IN RANGE    0    ${length}
        ${loai_hang}    Get Type of product by code    ${list_pr_code[${index}]}     is_return_IsTimeType=True
        ${type}    Evaluate    type($loai_hang).__name__
        # Tạo list param. !!! Rule:  ${loai_hang} luôn ở vị trí cuối cùng trong list
        @{list_param}    Create List    ${list_pr_uuid[${index}]}    ${list_pr_id[${index}]}    ${list_pr_quantity[${index}]}    ${list_pr_price[${index}]}
        ...    ${list_pr_discount[${index}]}    ${list_pr_discount_ratio[${index}]}    ${list_pr_note[${index}]}    ${index}    ${loai_hang}

        ${data_all_product}    Run Keyword If    '${type}'=='list'    KV Set Data Service Product New Fnb    @{list_param}
        ...    ELSE IF    '${type}'=='str'    Get Data Product By Product Type New Fnb    @{list_param}
        Append To List    ${list_data_product}    ${data_all_product}
    END
    KV Log    ${list_data_product}
    ${join_str}    Evaluate    ",".join($list_data_product)
    KV Log    ${join_str}
    Return From Keyword    ${join_str}

# Thong tin khach hang
KV Set Data Customer New Fnb
    [Arguments]    ${customer_id}    ${SoldBy_id}    ${branch_id}
    ${data_customer}    Set Variable    "CustomerId": ${customer_id},"Customer": {"Id": ${customer_id},"Type": 0,"Code": "KHTQ02","Name": "Thanh Hà","ContactNumber": "0975588001","Email": "","Address": "Số 1","RetailerId": ${RETAILER_ID},"Debt": -185000,"CreatedDate": "2020-08-21T15:10:30.1730000","CreatedBy": ${SoldBy_id},"LocationName": "","RewardPoint": 13,"Uuid": "","BranchId": ${branch_id} ,"WardName": "","LastTradingDate": "2020-08-25T16:19:44.1070000","IsActive": true,"isDeleted": false,"Revision": "AAAAABCTInQ=","Reservation": [],"CompareCode": "KHTQ02","CompareName": "Thanh Hà","MustUpdateDebt": false,"MustUpdatePoint": false,"InvoiceCount": 0,"SumQuantity": 0,"NormalizedName": "Thanh Ha","CusDiscountGroups": []},
    Return From Keyword    ${data_customer}

KV Set Data Surchange
    [Arguments]    ${list_surcharge_id}    ${list_surcharge_price}    ${list_SurValueRatio}
    Return From Keyword If    ${list_surcharge_id[0]}==0     ${EMPTY}
    ${list_data}    Create List
    FOR    ${surchange_id}    ${surchange_value}    ${surchange_ratio}    IN ZIP    ${list_surcharge_id}    ${list_surcharge_price}    ${list_SurValueRatio}
        ${type_value}    Run Keyword If    ${surchange_ratio}==0    Set Variable    "SurValue": ${surchange_value},    ELSE    Set Variable    "SurValueRatio": ${surchange_ratio},
        ${data_item}    Set Variable    {"SurchargeId": ${surchange_id},${type_value}"Price": ${surchange_value},"Name": "","Code": "","RetailerId": ${RETAILER_ID},"isAuto": false,"UsageFlag": true,"TextValue": "","isActive": true}
        Append To List    ${list_data}    ${data_item}
    END
    ${str_data}    Evaluate    ",".join($list_data)
    Log    ${str_data}
    Return From Keyword    ${str_data}


#-------------- END KV SET DATA ------------------
Delete hoa don
    [Documentation]    is_void_payment=True  ==> có xóa phiếu thanh toán liên quan
    ...                is_void_payment=False ==> không xóa phiếu thanh toán liên quan
    [Arguments]    ${invoice_id}    ${is_void_payment}=True    ${input_branch_id}=${EMPTY}
    ${input_dict}    Create Dictionary    invoice_id=${invoice_id}    is_void_payment=${is_void_payment}
    Run Keyword If    ${invoice_id} != 0    API Call From Template    /hoa-don/delete_hoa_don.txt    ${input_dict}   input_branch_id=${input_branch_id}    ELSE    KV Log    Hoa don khong ton tai

Delete list hoa don
    [Arguments]    ${list_id}    ${is_void_payment}=True
    FOR   ${invoice_id}    IN    @{list_id}
        Delete hoa don    ${invoice_id}    ${is_void_payment}
    END
