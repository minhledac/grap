*** Settings ***
Resource          ../../../share/utils.robot
Resource          ../../api_access.robot
Resource          set_event_payload.robot

*** Keyword ***
Post Event Sync Create Order And Add An Item
    [Documentation]    pricebook_id =-1 => BGC
    ...    dining_option =1 (giao đi), =2 (ngồi tại bàn), =3 (mang về)
    ...    is_other_pr=False: dùng trong trường hợp các HH add vào đơn không có HH tính giờ và Ngược lại
    [Arguments]    ${table_id}    ${list_pr_id}    ${list_pr_price}    ${pricebook_id}=-1    ${dining_option}=2    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}    ${is_other_pr}=False
    ${primary_event}    ${aggregate_id}    Get data payload create order    ${table_id}    ${pricebook_id}    ${dining_option}    ${branch_id}    ${user_id}    ${retailer_id}
    #---------
    ${secondary_event}    ${list_order_item_id}    Get data payload of add order item    ${aggregate_id}    ${list_pr_id}    ${list_pr_price}    ${branch_id}    ${user_id}    ${retailer_id}    ${is_other_pr}
    ${secondary_event}    Set Variable    ,${secondary_event}
    ${template_input_dict}    Create Dictionary    primary_event=${primary_event}    secondary_event=${secondary_event}
    Event Call From Template    ${template_input_dict}    ${branch_id}
    Return From Keyword    ${aggregate_id}    ${list_order_item_id}

Post Event Sync Add Order Item
    [Documentation]    is_other_pr=False: dùng trong trường hợp các HH add vào đơn không có HH tính giờ và Ngược lại
    [Arguments]    ${aggregate_id}    ${list_pr_id}    ${list_pr_price}     ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}    ${is_other_pr}=False
    ${result_data}    ${list_order_item_id}    Get data payload of add order item    ${aggregate_id}    ${list_pr_id}    ${list_pr_price}     ${branch_id}    ${user_id}    ${retailer_id}    ${is_other_pr}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}
    Return From Keyword    ${list_order_item_id}

Post Event Sync Change Pricebook
    [Arguments]    ${aggregate_id}    ${pricebook_id}    ${list_pr_uuid}   ${list_pr_price}     ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${primary_event}    Get data payload change pricebook    ${aggregate_id}    ${pricebook_id}    ${branch_id}    ${user_id}    ${retailer_id}
    #-----------------------
    ${secondary_event}    Get data payload of change price item    ${aggregate_id}    ${list_pr_uuid}    ${list_pr_price}
    ${secondary_event}    Set Variable    ,${secondary_event}
    ${template_input_dict}    Create Dictionary    primary_event=${primary_event}    secondary_event=${secondary_event}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Change Price Item
    [Arguments]    ${aggregate_id}    ${list_pr_uuid}    ${list_pr_price}     ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${result_data}    Get data payload of change price item    ${aggregate_id}    ${list_pr_uuid}    ${list_pr_price}     ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}

#loan

Post Event Sync Complete Order
    [Arguments]    ${aggregate_id}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${result_data}    Get data payload complete order    ${aggregate_id}    ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Change Customer
    [Documentation]    customer_id =null => khách lẻ
    [Arguments]    ${aggregate_id}    ${customer_id}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${result_data}    Get data payload change customer    ${aggregate_id}    ${customer_id}    ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Change Sale Channel
    [Documentation]    SaleChannel_id =0 => kênh bán trực tiếp
    [Arguments]    ${aggregate_id}    ${SaleChannel_id}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${result_data}    Get data payload change sale channel    ${aggregate_id}    ${SaleChannel_id}    ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Change Order Note
    [Arguments]    ${aggregate_id}    ${order_note}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${result_data}    Get data payload change order note    ${aggregate_id}    ${order_note}    ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Add Payment
    [Arguments]    ${aggregate_id}    ${payment_amount}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${result_data}    Get data payload add payment    ${aggregate_id}    ${payment_amount}    ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Remove And Add Payment
    [Arguments]    ${aggregate_id}     ${remove_amount}    ${payment_amount}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${primary_event}      Get data payload remove payment    ${aggregate_id}    ${remove_amount}     ${branch_id}    ${user_id}    ${retailer_id}
    ${secondary_event}    Get data payload add payment       ${aggregate_id}    ${payment_amount}    ${branch_id}    ${user_id}    ${retailer_id}
    ${secondary_event}    Set Variable    ,${secondary_event}
    ${template_input_dict}    Create Dictionary    primary_event=${primary_event}    secondary_event=${secondary_event}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Change Over Payment Type
    [Documentation]    payment_type=1 => tiền thừa trả khách
    ...                payment_type=2 => tính vào công nợ
    [Arguments]    ${aggregate_id}    ${payment_type}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${result_data}    Get data payload change over payment type    ${aggregate_id}    ${payment_type}    ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}

# Action: Đơn đã báo bếp, thực hiện chuyển loại order sang Ngồi tại bàn hoặc mang về
Post Event Sync Change Order Type - Other Table
    [Documentation]    dining_option=2 => ngoi tai ban
    ...                dining_option=3 => mang ve
    [Arguments]    ${aggregate_id}    ${table_id}    ${dining_option}
    ${change_delivery_event}         Get data payload change delivery info    ${aggregate_id}    false
    ${change_dining_option_event}    Get data payload change dining option    ${aggregate_id}    ${dining_option}
    ${change_table_event}   Run Keyword If    '${dining_option}'=='2'    Get data payload change table    ${aggregate_id}    ${table_id}    ELSE    Set Variable    ${EMPTY}
    ${secondary_event}      Run Keyword If    '${dining_option}'=='2'    Set Variable    ,${change_delivery_event},${change_table_event}    ELSE    Set Variable    ,${change_delivery_event}
    ${primary_event}        Set Variable    ${change_dining_option_event}
    ${template_input_dict}    Create Dictionary    primary_event=${primary_event}    secondary_event=${secondary_event}
    Event Call From Template    ${template_input_dict}    ${branch_id}

# Action: Đơn đã báo bếp, thực hiện chuyển loại order sang Giao đi
Post Event Sync Change Order Type - Delivery
    [Arguments]    ${aggregate_id}     ${ward}=${EMPTY}     ${status}=3    ${receiver}=${EMPTY}    ${contact_number}=${EMPTY}   ${address}=${EMPTY}    ${location_id}=${EMPTY}
    ...    ${delivery_code}=${EMPTY}   ${price}=${EMPTY}    ${delvery_date}=${EMPTY}    ${delivery_by}=${EMPTY}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${change_delivery_event}    Get data payload change delivery info    ${aggregate_id}    true    false    ${ward}    ${status}    ${receiver}    ${contact_number}   ${address}    ${location_id}
    ...    ${delivery_code}   ${price}    ${delvery_date}    ${delivery_by}    ${branch_id}    ${user_id}    ${retailer_id}
    ${change_dining_option_event}    Get data payload change dining option    ${aggregate_id}    1
    ${primary_event}      Set Variable    ${change_delivery_event}
    ${secondary_event}    Set Variable    ,${change_dining_option_event}
    ${template_input_dict}    Create Dictionary    primary_event=${primary_event}    secondary_event=${secondary_event}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Change Delivery Info
    [Arguments]     ${aggregate_id}     ${ward}=${EMPTY}     ${status}=3    ${receiver}=${EMPTY}    ${contact_number}=${EMPTY}   ${address}=${EMPTY}    ${location_id}=${EMPTY}
    ...    ${delivery_code}=${EMPTY}   ${price}=${EMPTY}    ${delvery_date}=${EMPTY}    ${delivery_by}=${EMPTY}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ...    ${is_has_delivery_info}=true    ${is_cod}=false
    ${change_delivery_event}    Get data payload change delivery info    ${aggregate_id}    ${is_has_delivery_info}    ${is_cod}    ${ward}    ${status}    ${receiver}    ${contact_number}   ${address}    ${location_id}
    ...    ${delivery_code}   ${price}    ${delvery_date}    ${delivery_by}    ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${change_delivery_event}
    Event Call From Template    ${template_input_dict}    ${branch_id}

#hai
Post Event Sync Notified Kitchen
    [Arguments]    ${aggregate_id}    ${table_id}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${result_data}    Get data payload notify kitchen    ${aggregate_id}    ${table_id}    branch_id=${branch_id}    user_id=${user_id}    retailer_id=${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Change Note And Toppings Item
    [Documentation]    Không muốn update item_note, dict_topping thì truyền vào $EMPTY
    [Arguments]    ${aggregate_id}    ${order_item_id}    ${item_note}    ${dict_topping}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${payload_note}    Get data payload change note item    ${aggregate_id}    ${order_item_id}    ${item_note}    ${branch_id}    ${user_id}    ${retailer_id}
    ${payload_toppings}    Get data payload change toppings item    ${aggregate_id}    ${order_item_id}    ${dict_topping}    ${branch_id}    ${user_id}    ${retailer_id}
    ${payload_toppings}    Set Variable    ,${payload_toppings}
    ${template_input_dict}    Create Dictionary    primary_event=${payload_note}    secondary_event=${payload_toppings}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Change SoldBy
    [Arguments]    ${aggregate_id}    ${soldBy_id}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${result_data}    Get data payload change soldBy    ${aggregate_id}    ${soldBy_id}    ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Remove Order Item
    [Documentation]    cancelReason=null
    [Arguments]    ${aggregate_id}    ${list_order_item_id}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${result_data}    Get data payload remove order item    ${aggregate_id}    ${list_order_item_id}    branch_id=${branch_id}    user_id=${user_id}    retailer_id=${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Remove Order Item And Notify Kitchen
    [Documentation]    cancel_reason_id =0 => Lý do hủy =Khác, Chi tiết lý do =reason_detail
    ...    cancel_reason_id !0 => Lý do hủy =Danh sách lý do hủy, Chi tiết lý do =Khác
    [Arguments]    ${aggregate_id}    ${order_item_id}    ${table_id}    ${cancel_reason_id}=0    ${reason_detail}=Khác    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${payload_remove_item}    Get data payload remove order item    ${aggregate_id}    ${order_item_id}    ${cancel_reason_id}    ${reason_detail}    ${branch_id}    ${user_id}    ${retailer_id}
    ${payload_notify}    Get data payload notify kitchen    ${aggregate_id}    ${table_id}    ${order_item_id}
    ${payload_notify}    Set Variable    ,${payload_notify}
    ${template_input_dict}    Create Dictionary    primary_event=${payload_remove_item}    secondary_event=${payload_notify}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Cancel Order
    [Arguments]    ${aggregate_id}    ${cancel_reason_id}=0    ${reason_detail}=Khác    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${result_data}    Get data payload cancel order    ${aggregate_id}    ${cancel_reason_id}    ${reason_detail}    ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Applied Surcharge
    [Documentation]
    [Arguments]    ${aggregate_id}    ${list_surcharge_id}    ${list_value}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${result_data}    Get data payload applied surcharge    ${aggregate_id}    ${list_surcharge_id}    ${list_value}
    ...    branch_id=${branch_id}    user_id=${user_id}    retailer_id=${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Change Item Priority
    [Arguments]    ${aggregate_id}    ${order_item_id}    ${is_prioritize}=true    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${result_data}    Get data payload change item priority    ${aggregate_id}    ${order_item_id}    ${is_prioritize}    ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Payment Request
    [Arguments]    ${aggregate_id}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${result_data}    Get data payload payment request    ${aggregate_id}    ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Change Number Customer
    [Arguments]    ${aggregate_id}    ${number_customer}=null    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${result_data}    Get data payload change number customer    ${aggregate_id}    ${number_customer}    ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Process Item
    [Arguments]    ${aggregate_id}    ${list_order_item_id}    ${list_quantity}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${result_data}    Get data payload process item    ${aggregate_id}    ${list_order_item_id}    ${list_quantity}    ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Post Event Sync Delivery Item
    [Arguments]    ${aggregate_id}    ${list_order_item_id}    ${list_quantity}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${result_data}    Get data payload delivery item    ${aggregate_id}    ${list_order_item_id}    ${list_quantity}    ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}

#hanh

Post Event Sync Adjust Item Quantity
    [Arguments]    ${aggregate_id}    ${list_quantity_new}    ${list_order_item_id}    ${list_quantity_old}=${EMPTY}    ${id_branch}=${BRANCH_ID}    ${id_user}=${USER_ID}    ${id_retailer}=${RETAILER_ID}
    ${result_data}    Get data payload of adjust item quantity    ${aggregate_id}    ${list_quantity_new}    ${list_order_item_id}    ${list_quantity_old}    ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${id_branch}

Post Event Discount Order Event
    [Documentation]    Nếu truyền discount_value <=100 thì là discount theo %. Lớn hơn 100 thì sẽ là discount theo VND
    [Arguments]    ${aggregate_id}    ${discount_value}    ${id_branch}=${BRANCH_ID}    ${id_user}=${USER_ID}    ${id_retailer}=${RETAILER_ID}
    ${result_data}    Get data payload of discount order event    ${aggregate_id}    ${discount_value}    ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${id_branch}

Post Event Discount Item Order Event
    [Documentation]    pr_ratio=0 => Giảm giá theo VND. pr_ratio!=0 thì sẽ giảm giá theo %
    ...    list_pr_price_old là giá của hàng hóa theo bảng giá khi được add vào đơn
    [Arguments]     ${aggregate_id}    ${list_order_item_id}     ${list_pr_price_new}        ${list_pr_price_old}    ${list_pr_ratio}    ${id_branch}=${BRANCH_ID}    ${id_user}=${USER_ID}    ${id_retailer}=${RETAILER_ID}
    ${result_data}    Get data payload of discount item order event   ${aggregate_id}    ${list_order_item_id}     ${list_pr_price_new}    ${list_pr_price_old}    ${list_pr_ratio}    ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${id_branch}

Post Event Change Purchase Date Event
    [Arguments]    ${aggregate_id}    ${purchaseDate}=null    ${id_branch}=${BRANCH_ID}    ${id_user}=${USER_ID}    ${id_retailer}=${RETAILER_ID}
    ${result_data}    Get data payload change purchase date    ${aggregate_id}    ${purchaseDate}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${id_branch}

#===============================================================================
# ---------- loan.nt: Chỉ sử dụng keyword này cho phần prepare-data xóa đơn hàng ở MHTN
Post Event Sync Cancel Order for prepare-data
    [Arguments]    ${aggregate_id}    ${cancel_reason_id}=0    ${reason_detail}=Khác    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${result_data}    Get data payload cancel order for prepare-data    ${aggregate_id}    ${cancel_reason_id}    ${reason_detail}    ${branch_id}    ${user_id}    ${retailer_id}
    ${template_input_dict}    Create Dictionary    primary_event=${result_data}
    Event Call From Template    ${template_input_dict}    ${branch_id}

Get data payload cancel order for prepare-data
    [Arguments]    ${aggregate_id}    ${cancel_reason_id}=0    ${reason_detail}=Khác    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${str_cancel_reason}    Set Variable    {\\"cancelReasonId\\":${cancel_reason_id},\\"reason\\":\\"${reason_detail}\\"}
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}    cancel_reason=${str_cancel_reason}   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ...    event_ver=100    track_ver=100
    ${template_str}    Get File    ${template_event_dir}/cancel_order_event.txt
    ${payload_data}    KV Set Data For Input Dict Events for prepare-data    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

KV Set Data For Input Dict Events for prepare-data
    [Arguments]    ${input_dict}    ${key_ver}    ${str_data}
    ${type_input_dict}    Evaluate    type($input_dict).__name__
    ${input_dict}    Run Keyword If    '${type_input_dict}'!='DotDict'    Create Dictionary    ELSE    Set Variable    ${input_dict}
    # Set các key event_id, replica_id, version...
    Set To Dictionary    ${input_dict}    replica_id        ${replica_id}
    Set To Dictionary    ${input_dict}    firebase_token    ${firebase_token}
    ${gen_event_id}    Generate Random UUID
    Set To Dictionary    ${input_dict}    event_id_${key_ver}     ${gen_event_id}
    Set Test Variable    ${local_ver}    100
    # Convert datetime sang dạng epoch time và set key local_time luôn xuất hiện trong dictionary
    ${date_time}    Get Current Date
    ${result_time}    KV Convert DateTime To Epoch Time    ${date_time}
    Set To Dictionary    ${input_dict}    local_time    ${result_time}
    KV Log    ${input_dict}
    ${str_data}    Format String    ${str_data}    ${input_dict}
    KV Log    ${str_data}
    Return From Keyword    ${str_data}
