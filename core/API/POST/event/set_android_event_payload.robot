*** Settings ***
Resource          ../../../share/utils.robot
Resource          ../../../share/computation.robot
Resource          ../../api_access.robot
Resource          ../../GET/hang-hoa/api_danhmuc_hanghoa.robot
Library           Collections
Library           String
Library           DateTime
Library           OperatingSystem
Library           ../../../../custom-library/UtilityLibrary.py

*** Keyword ***
Get android data payload create order
    [Documentation]    pricebook_id =-1 => BGC
    ...    dining_option =1 (giao đi), =2 (ngồi tại bàn), =3 (mang về)
    [Arguments]    ${table_id}    ${pricebook_id}=-1    ${dining_option}=2    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${aggregate_id}     Generate Random UUID
    ${Version_prefix}    Evaluate    ${Prefix_ver}+1
    ${order_code_gen}     Set Variable   ${PrefixCode}-${Version_prefix}
    Set Test Variable   ${order_code}   ${order_code_gen}
    ${date_time}    Get Current Date
    ${trans_date}   KV Convert DateTime From API To 24h Format String    ${date_time}    date_format=%Y-%m-%d %H:%M:%S.%f   result_format=%Y-%m-%dT%H:%M:%S
    # Set giá trị của input dictionary
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}   retailer_id=${retailer_id}    branch_id=${branch_id}    user_id=${user_id}
    ...    order_code=${order_code}    table_id=${table_id}    pricebook_id=${pricebook_id}   dining_option=${dining_option}   table_id=${table_id}    trans_date=${trans_date}
    ${template_str}    Get File    ${template_event_dir}/event_android/create_order_event.txt
    ${payload_data}    KV Android Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}    ${aggregate_id}

Get android data payload of add order item
    [Arguments]    ${aggregate_id}    ${list_pr_id}    ${list_pr_price}     ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}    ${is_other_pr}=False
    ${type_list_pr_id}    Evaluate    type($list_pr_id).__name__
    ${list_pr_id}      Run Keyword If    '${type_list_pr_id}'=='list'     Set Variable    ${list_pr_id}      ELSE    Create List    ${list_pr_id}
    ${list_pr_price}   Run Keyword If    '${type_list_pr_id}'=='list'     Set Variable    ${list_pr_price}   ELSE    Create List    ${list_pr_price}
    ${list_key_ver}    KV Set List Key Version    ${list_pr_id}
    ${list_data_event}       Create List
    ${list_order_item_id}    Create List
    ${list_is_time_type_pr}    Run Keyword If    '${is_other_pr}'=='True'    Get list type of product by list product id    ${list_pr_id}    ELSE    Set Variable    ${EMPTY}
    ${template_str}    Get File    ${template_event_dir}/event_android/add_order_item_event.txt
    FOR    ${pr_id}    ${pr_price}    ${key_ver}    IN ZIP    ${list_pr_id}    ${list_pr_price}    ${list_key_ver}
        ${index}    Get Index From List    ${list_pr_id}    ${pr_id}
        # Gen theo định dạng UUID
        ${order_item_id}    Generate Random UUID
        ${date_time}    Get Current Date
        ${start_time}   KV Convert DateTime From API To 24h Format String    ${date_time}    date_format=%Y-%m-%d %H:%M:%S.%f   result_format=%Y-%m-%dT%H:%M:%S
        ${quantity_type}    Run Keyword If    '${is_other_pr}'=='True'    KV Set Quantity Type Of Product In Event    ${list_is_time_type_pr[${index}]}    ELSE    Set Variable    ${1}
        ${cus_event_id_ver}    ${cus_track_ver}    ${cus_event_ver}    ${cus_local_time}    KV Set Common Key Version    ${key_ver}
        # Set string formulas
        ${str_formulas}    KV Android Set data formulas    ${pr_id}
        # Set giá trị của input dictionary
                ${input_dict}    Create Dictionary    cus_event_id_ver=${cus_event_id_ver}    cus_track_ver=${cus_track_ver}    cus_event_ver=${cus_event_ver}    cus_local_time=${cus_local_time}
        ...    order_item_id=${order_item_id}    start_time=${start_time}       quantity_type=${quantity_type}    product_id=${pr_id}      price=${pr_price}     formulas=${str_formulas}
        ...    replica_id=${replica_id}         aggregate_id=${aggregate_id}    retailer_id=${retailer_id}        branch_id=${branch_id}   user_id=${user_id}
        ${template_str_copy}   Set Variable    ${template_str}
        ${temp_data_event}     Format String    ${template_str_copy}    ${input_dict}
        ${data_event}    KV Android Set Data For Input Dict Events    ${EMPTY}     ${key_ver}    ${temp_data_event}
        Append To List    ${list_data_event}    ${data_event}
        Append To List    ${list_order_item_id}    ${order_item_id}
    END
    ${result_data}    Evaluate    ",".join($list_data_event)
    Return From Keyword    ${result_data}    ${list_order_item_id}

KV android Set Quantity Type Of Product In Event
    [Arguments]    ${is_time_type_pr}
    ${quantity_type}    Run Keyword If    '${is_time_type_pr}'=='True'    Set Variable    ${2}    ELSE    Set Variable    ${1}
    Return From Keyword    ${quantity_type}

Get android data payload of change price item
    [Arguments]    ${aggregate_id}    ${list_pr_uuid}    ${list_pr_price}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${type_list_pr_uuid}    Evaluate    type($list_pr_uuid).__name__
    ${list_pr_uuid}    Run Keyword If    '${type_list_pr_uuid}'=='list'     Set Variable    ${list_pr_uuid}    ELSE    Create List    ${list_pr_uuid}
    ${list_pr_price}   Run Keyword If    '${type_list_pr_uuid}'=='list'     Set Variable    ${list_pr_price}   ELSE    Create List    ${list_pr_price}
    ${list_key_ver}    KV Set List Key Version    ${list_pr_uuid}
    ${list_data_event}   Create List
    ${template_str}    Get File    ${template_event_dir}/event_android/change_price_item_event.txt
    FOR    ${pr_uuid}    ${pr_price}    ${key_ver}    IN ZIP    ${list_pr_uuid}    ${list_pr_price}    ${list_key_ver}
        ${cus_event_id_ver}    ${cus_track_ver}    ${cus_event_ver}    ${cus_local_time}    KV Set Common Key Version    ${key_ver}
        # Set giá trị của input dictionary
        ${input_dict}    Create Dictionary    cus_event_id_ver=${cus_event_id_ver}    cus_track_ver=${cus_track_ver}    cus_event_ver=${cus_event_ver}    cus_local_time=${cus_local_time}
        ...    replica_id=${replica_id}    aggregate_id=${aggregate_id}    retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
        ...    order_item_id=${pr_uuid}    price=${pr_price}
        ${template_str_copy}   Set Variable    ${template_str}
        ${temp_data_event}     Format String    ${template_str_copy}    ${input_dict}
        ${data_event}    KV Set Data For Input Dict Events    ${EMPTY}     ${key_ver}    ${temp_data_event}
        Append To List    ${list_data_event}    ${data_event}
    END
    ${result_data}    Evaluate    ",".join($list_data_event)
    Log    ${result_data}
    Return From Keyword    ${result_data}

Get android data payload change pricebook
    [Documentation]    pricebook_id =-1 => Bang gia chung
    [Arguments]    ${aggregate_id}    ${pricebook_id}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${input_dict}    Create Dictionary    pricebook_id=${pricebook_id}    aggregate_id=${aggregate_id}   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ${template_str}    Get File    ${template_event_dir}/event_android/change_pricebook_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

#loan
Get android data payload complete order
    [Arguments]    ${aggregate_id}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ${template_str}    Get File    ${template_event_dir}/event_android/complete_order_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

Get android data payload change customer
    [Documentation]    customer_id =null => khách lẻ
    [Arguments]    ${aggregate_id}    ${customer_id}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ...     customer_id=${customer_id}
    ${template_str}    Get File    ${template_event_dir}/event_android/change_customer_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

Get android data payload change sale channel
    [Documentation]    SaleChannel_id =0 => kênh bán trực tiếp
    [Arguments]    ${aggregate_id}    ${SaleChannel_id}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}    SaleChannel_id=${SaleChannel_id}
    ${template_str}    Get File    ${template_event_dir}/event_android/change_SaleChannel_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

Get android data payload change order note
    [Arguments]    ${aggregate_id}    ${order_note}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ...     order_note=${order_note}
    ${template_str}    Get File    ${template_event_dir}/event_android/change_order_note_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

Get android data payload add payment
    [Arguments]    ${aggregate_id}    ${payment_amount}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ...     khach_thanh_toan=${payment_amount}
    ${template_str}    Get File    ${template_event_dir}/event_android/add_payment_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

Get android data payload remove payment
    [Arguments]     ${aggregate_id}    ${remove_amount}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ...     amount=${remove_amount}
    ${template_str}    Get File    ${template_event_dir}/event_android/remove_payment_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

Get android data payload change over payment type
    [Documentation]    payment_type=1 => tiền thừa trả khách
    ...                payment_type=2 => tính vào công nợ
    [Arguments]    ${aggregate_id}    ${payment_type}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ...     payment_type=${payment_type}
    ${template_str}    Get File    ${template_event_dir}/event_android/change_over_payment_type_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

Get android data payload change table
    [Arguments]    ${aggregate_id}    ${table_id}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ...     table_id=${table_id}
    ${template_str}    Get File    ${template_event_dir}/event_android/change_table_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

Get android data payload change dining option
    [Arguments]    ${aggregate_id}    ${dining_option}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ...     dining_option=${dining_option}
    ${template_str}    Get File    ${template_event_dir}/event_android/change_dining_option_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

Get android data payload change delivery info
    [Arguments]    ${aggregate_id}    ${is_has_delivery_info}=true    ${is_cod}=false    ${ward}=${EMPTY}    ${status}=3    ${receiver}=${EMPTY}    ${contact_number}=${EMPTY}   ${address}=${EMPTY}    ${location_id}=${EMPTY}
    ...    ${delivery_code}=${EMPTY}    ${price}=${EMPTY}    ${delvery_date}=${EMPTY}    ${delivery_by}=${EMPTY}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${delivery_info}    Run Keyword If    '${is_has_delivery_info}'=='true'    KV Set Data Delivery Info    ${is_cod}    ${ward}    ${status}    ${receiver}     ${contact_number}    ${address}    ${location_id}    ${delivery_code}    ${price}    ${delvery_date}    ${delivery_by}
    ...    ELSE    Set Variable    null
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ...     delivery_info=${delivery_info}
    ${template_str}    Get File    ${template_event_dir}/event_android/change_delivery_info_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}


#hai
Get android data payload notify kitchen
    [Arguments]    ${aggregate_id}    ${table_id}    ${order_item_id}=${EMPTY}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    # Gen theo định dạng UUID
    ${notify_id}     Generate Random UUID
    ${date_time}    Get Current Date
    ${trans_date}    KV Convert DateTime From API To 24h Format String    ${date_time}    date_format=%Y-%m-%d %H:%M:%S.%f   result_format=%Y-%m-%dT%H:%M:%S
    ${str_notify_item}    Run Keyword If    '${order_item_id}'!='${EMPTY}'    Set Variable    \\"notifyItemIds\\":[\\"${order_item_id}\\"],
    ...    ELSE    Set Variable    ${EMPTY}
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}    table_id=${table_id}    trans_date=${trans_date}    notify_id=${notify_id}
    ...   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}    str_notify_item=${str_notify_item}
    ${template_str}    Get File    ${template_event_dir}/event_android/notify_kitchen_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

Get android data payload change note item
    [Arguments]    ${aggregate_id}    ${order_item_id}    ${item_note}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    # Set string note item
    ${str_note}    KV Set data note item    ${item_note}
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}    order_item_id=${order_item_id}    data_note_item=${str_note}
    ...   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ${template_str}    Get File    ${template_event_dir}/event_android/change_item_note_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

Get android data payload change toppings item
    [Arguments]    ${aggregate_id}    ${order_item_id}    ${dict_topping}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    # Set string note item
    ${str_topping}    KV Set data topping item    ${dict_topping}
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}    order_item_id=${order_item_id}    data_topping=${str_topping}
    ...   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ${template_str}    Get File    ${template_event_dir}/event_android/change_item_toppings_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

Get android data payload change soldBy
    [Arguments]    ${aggregate_id}    ${soldBy_id}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}    soldBy_id=${soldBy_id}   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ${template_str}    Get File    ${template_event_dir}/event_android/change_soldBy_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

Get android data payload remove order item
    [Arguments]    ${aggregate_id}    ${list_order_item_id}    ${list_reason_id}=${EMPTY}    ${list_reason_detail}=${EMPTY}
    ...    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${type_list_order_item_id}    Evaluate    type($list_order_item_id).__name__
    ${type_list_reason_id}        Evaluate    type($list_reason_id).__name__
    ${type_list_reason_detail}    Evaluate    type($list_reason_detail).__name__
    ${list_order_item_id}    Run Keyword If    '${type_list_order_item_id}'=='list'    Set Variable    ${list_order_item_id}    ELSE    Create List    ${list_order_item_id}
    ${length}    Get Length    ${list_order_item_id}
    # Nếu list_reason_id, list_reason_detail truyền vào không phải là list thì sẽ tạo list có length = length of list_order_item_id (value=None)
    ${list_reason_id}    Run Keyword If    '${type_list_reason_id}'=='list'    Set Variable    ${list_reason_id}
    ...    ELSE IF    '${type_list_reason_id}'!='list' and '${list_reason_id}'!='${EMPTY}'    Create List    ${list_reason_id}
    ...    ELSE       Evaluate    [None for _ in range($length)]
    ${list_reason_detail}    Run Keyword If    '${type_list_reason_detail}'=='list'    Set Variable    ${list_reason_detail}
    ...    ELSE IF    '${type_list_reason_detail}'!='list' and '${list_reason_detail}'!='${EMPTY}'    Create List    ${list_reason_detail}
    ...    ELSE    Evaluate    [None for _ in range($length)]
    ${list_key_ver}    KV Set List Key Version    ${list_order_item_id}
    ${list_data_event}   Create List
    ${template_str}    Get File    ${template_event_dir}/event_android/remove_order_item_event.txt
    FOR    ${order_item_id}    ${reason_id}    ${reason_detail}    ${key_ver}    IN ZIP    ${list_order_item_id}    ${list_reason_id}    ${list_reason_detail}    ${list_key_ver}
        ${cus_event_id_ver}    ${cus_track_ver}    ${cus_event_ver}    ${cus_local_time}    KV Set Common Key Version    ${key_ver}
        # Set string cancel reason
        ${str_cancel_reason}    KV Set data cancel reason item    ${reason_id}    ${reason_detail}
        # Set giá trị của input dictionary
        ${input_dict}    Create Dictionary    cus_event_id_ver=${cus_event_id_ver}    cus_track_ver=${cus_track_ver}    cus_event_ver=${cus_event_ver}    cus_local_time=${cus_local_time}
        ...    replica_id=${replica_id}    aggregate_id=${aggregate_id}    retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
        ...    order_item_id=${order_item_id}    cancel_reason=${str_cancel_reason}
        ${template_str_copy}   Set Variable    ${template_str}
        ${temp_data_event}     Format String    ${template_str_copy}    ${input_dict}
        ${data_event}    KV Set Data For Input Dict Events    ${EMPTY}     ${key_ver}    ${temp_data_event}
        Append To List    ${list_data_event}    ${data_event}
    END
    ${result_data}    Evaluate    ",".join($list_data_event)
    Log    ${result_data}
    Return From Keyword    ${result_data}

Get android data payload cancel order
    [Arguments]    ${aggregate_id}    ${cancel_reason_id}=0    ${reason_detail}=Khác    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${str_cancel_reason}    Set Variable    {\\"cancelReasonId\\":${cancel_reason_id},\\"reason\\":\\"${reason_detail}\\"}
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}    cancel_reason=${str_cancel_reason}   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ${template_str}    Get File    ${template_event_dir}/event_android/cancel_order_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

Get android data payload applied surcharge
    [Arguments]    ${aggregate_id}    ${list_surcharge_id}    ${list_value}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${type_list_surcharge_id}    Evaluate    type($list_surcharge_id).__name__
    ${type_list_value}           Evaluate    type($list_value).__name__
    ${list_surcharge_id}    Run Keyword If    '${type_list_surcharge_id}'=='list'    Set Variable    ${list_surcharge_id}    ELSE    Create List    ${list_surcharge_id}
    ${list_value}           Run Keyword If    '${type_list_value}'=='list'           Set Variable    ${list_value}           ELSE    Create List    ${list_value}
    ${list_key_ver}    KV Set List Key Version    ${list_surcharge_id}
    ${list_data_event}   Create List
    ${template_str}    Get File    ${template_event_dir}/event_android/applied_surcharge_event.txt
    FOR    ${surcharge_id}    ${value}    ${key_ver}    IN ZIP    ${list_surcharge_id}    ${list_value}    ${list_key_ver}
        ${cus_event_id_ver}    ${cus_track_ver}    ${cus_event_ver}    ${cus_local_time}    KV Set Common Key Version    ${key_ver}
        # Set string surcharge
        ${str_surcharge}    Run Keyword If    0<${value}<=100     Set Variable    {{\\"surchargeId\\":${surcharge_id},\\"valueRatio\\":${value}}}
        ...    ELSE IF    ${value}>100    Set Variable    {{\\"surchargeId\\":${surcharge_id},\\"value\\":${value}}}
        # Set giá trị của input dictionary
        ${input_dict}    Create Dictionary    cus_event_id_ver=${cus_event_id_ver}    cus_track_ver=${cus_track_ver}    cus_event_ver=${cus_event_ver}    cus_local_time=${cus_local_time}
        ...    replica_id=${replica_id}    aggregate_id=${aggregate_id}    retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
        ...    firebase_token=${firebase_token}    surcharge=${str_surcharge}
        ${template_str_copy}   Set Variable    ${template_str}
        ${temp_data_event}     Format String    ${template_str_copy}    ${input_dict}
        ${data_event}    KV Set Data For Input Dict Events    ${EMPTY}     ${key_ver}    ${temp_data_event}
        Append To List    ${list_data_event}    ${data_event}
    END
    ${result_data}    Evaluate    ",".join($list_data_event)
    Log    ${result_data}
    Return From Keyword    ${result_data}

Get android data payload change item priority
    [Arguments]    ${aggregate_id}    ${order_item_id}    ${is_prioritize}=true    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}    order_item_id=${order_item_id}    is_prioritize=${is_prioritize}
    ...   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ${template_str}    Get File    ${template_event_dir}/event_android/change_item_priority_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

Get android data payload payment request
    [Arguments]    ${aggregate_id}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ${template_str}    Get File    ${template_event_dir}/event_android/payment_request_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

Get android data payload change number customer
    [Arguments]    ${aggregate_id}    ${number_customer}=null    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}    number_customer=${number_customer}   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ${template_str}    Get File    ${template_event_dir}/event_android/change_number_customer_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

Get android data payload process item
    [Arguments]    ${aggregate_id}    ${list_order_item_id}    ${list_quantity}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${type_list_order_item_id}    Evaluate    type($list_order_item_id).__name__
    ${list_order_item_id}    Run Keyword If    '${type_list_order_item_id}'=='list'    Set Variable    ${list_order_item_id}    ELSE    Create List    ${list_order_item_id}
    ${list_quantity}         Run Keyword If    '${type_list_order_item_id}'=='list'    Set Variable    ${list_quantity}         ELSE    Create List    ${list_quantity}
    ${list_key_ver}    KV Set List Key Version    ${list_order_item_id}
    ${list_data_event}   Create List
    ${template_str}    Get File    ${template_event_dir}/event_android/process_item_event.txt
    FOR    ${order_item_id}    ${quantity}    ${key_ver}    IN ZIP    ${list_order_item_id}    ${list_quantity}    ${list_key_ver}
        ${cus_event_id_ver}    ${cus_track_ver}    ${cus_event_ver}    ${cus_local_time}    KV Set Common Key Version    ${key_ver}
        # Gen theo định dạng UUID
        ${notify_id}     Generate Random UUID
        # Set giá trị của input dictionary
        ${input_dict}    Create Dictionary    cus_event_id_ver=${cus_event_id_ver}    cus_track_ver=${cus_track_ver}    cus_event_ver=${cus_event_ver}    cus_local_time=${cus_local_time}
        ...    replica_id=${replica_id}    aggregate_id=${aggregate_id}    retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
        ...    firebase_token=${firebase_token}    notify_id=${notify_id}    order_item_id=${order_item_id}    quantity=${quantity}
        ${template_str_copy}   Set Variable    ${template_str}
        ${temp_data_event}     Format String    ${template_str_copy}    ${input_dict}
        ${data_event}    KV Set Data For Input Dict Events    ${EMPTY}     ${key_ver}    ${temp_data_event}
        Append To List    ${list_data_event}    ${data_event}
    END
    ${result_data}    Evaluate    ",".join($list_data_event)
    Log    ${result_data}
    Return From Keyword    ${result_data}

Get android data payload delivery item
    [Arguments]    ${aggregate_id}    ${list_order_item_id}    ${list_quantity}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${type_list_order_item_id}    Evaluate    type($list_order_item_id).__name__
    ${list_order_item_id}    Run Keyword If    '${type_list_order_item_id}'=='list'    Set Variable    ${list_order_item_id}    ELSE    Create List    ${list_order_item_id}
    ${list_quantity}         Run Keyword If    '${type_list_order_item_id}'=='list'    Set Variable    ${list_quantity}         ELSE    Create List    ${list_quantity}
    ${list_key_ver}    KV Set List Key Version    ${list_order_item_id}
    ${list_data_event}   Create List
    ${template_str}    Get File    ${template_event_dir}/event_android/delivery_item_event.txt
    FOR    ${order_item_id}    ${quantity}    ${key_ver}    IN ZIP    ${list_order_item_id}    ${list_quantity}    ${list_key_ver}
        ${cus_event_id_ver}    ${cus_track_ver}    ${cus_event_ver}    ${cus_local_time}    KV Set Common Key Version    ${key_ver}
        # Gen theo định dạng UUID
        ${notify_id}     Generate Random UUID
        # Set giá trị của input dictionary
        ${input_dict}    Create Dictionary    cus_event_id_ver=${cus_event_id_ver}    cus_track_ver=${cus_track_ver}    cus_event_ver=${cus_event_ver}    cus_local_time=${cus_local_time}
        ...    replica_id=${replica_id}    aggregate_id=${aggregate_id}    retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
        ...    firebase_token=${firebase_token}    notify_id=${notify_id}    order_item_id=${order_item_id}    quantity=${quantity}
        ${template_str_copy}   Set Variable    ${template_str}
        ${temp_data_event}     Format String    ${template_str_copy}    ${input_dict}
        ${data_event}    KV Set Data For Input Dict Events    ${EMPTY}     ${key_ver}    ${temp_data_event}
        Append To List    ${list_data_event}    ${data_event}
    END
    ${result_data}    Evaluate    ",".join($list_data_event)
    Log    ${result_data}
    Return From Keyword    ${result_data}

#hanh

Get android data payload of adjust item quantity
    [Arguments]    ${aggregate_id}    ${list_quantity_new}    ${list_pr_uuid}    ${list_quantity_old}=${EMPTY}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    [Documentation]    Set các giá trị trong payload của adjust item quantity
    ${type_list_pr_uuid}         Evaluate    type($list_pr_uuid).__name__
    ${type_list_quantity_new}    Evaluate    type($list_quantity_new).__name__
    ${type_list_quantity_old}    Evaluate    type($list_quantity_old).__name__
    ${length}    Get Length    ${list_pr_uuid}
    ${list_quantity_new}   Run Keyword If    '${type_list_quantity_new}'=='list'     Set Variable    ${list_quantity_new}   ELSE    Create List    ${list_quantity_new}
    ${list_pr_uuid}        Run Keyword If    '${type_list_pr_uuid}'=='list'          Set Variable    ${list_pr_uuid}        ELSE    Create List    ${list_pr_uuid}
    ${list_quantity_old}   Run Keyword If    '${type_list_quantity_old}'=='list'    Set Variable    ${list_quantity_old}
    ...    ELSE IF    '${type_list_quantity_old}'!='list' and '${list_quantity_old}'!='${EMPTY}'    Create List    ${list_quantity_old}
    ...    ELSE       Evaluate    [1 for _ in range($length)]
    ${list_key_ver}    KV Set List Key Version    ${list_pr_uuid}
    ${list_data_event}       Create List
    ${template_str}    Get File    ${template_event_dir}/event_android/adjust_item_quantity_event.txt
    FOR    ${pr_uuid}    ${quantity_new}    ${quantity_old}    ${key_ver}    IN ZIP    ${list_pr_uuid}    ${list_quantity_new}    ${list_quantity_old}    ${list_key_ver}
        ${cus_event_id_ver}    ${cus_track_ver}    ${cus_event_ver}    ${cus_local_time}    KV Set Common Key Version    ${key_ver}
        # Tính giá trị adjust quantity theo quantity của đơn
        ${quantity_old}    Convert To Number    ${quantity_old}
        ${quantity_new}    Convert To Number    ${quantity_new}
        ${adjust_quantity}=    Evaluate    ${quantity_new} - ${quantity_old}
        ${type}    Evaluate    type($adjust_quantity).__name__
        ${adjust_quantity}    Convert To Number    ${adjust_quantity}
        # Set giá trị của input dictionary
        ${input_dict}    Create Dictionary    cus_event_id_ver=${cus_event_id_ver}    cus_track_ver=${cus_track_ver}    cus_event_ver=${cus_event_ver}    cus_local_time=${cus_local_time}
        ...    order_item_id=${pr_uuid}       adjust_quantity=${adjust_quantity}
        ...    replica_id=${replica_id}       aggregate_id=${aggregate_id}    retailer_id=${retailer_id}        branch_id=${branch_id}   user_id=${user_id}
        ${template_str_copy}   Set Variable    ${template_str}
        ${temp_data_event}     Format String    ${template_str_copy}    ${input_dict}
        ${data_event}    KV Set Data For Input Dict Events    ${EMPTY}     ${key_ver}    ${temp_data_event}
        Log    ${data_event}
        Append To List    ${list_data_event}    ${data_event}
    END
    ${result_data}    Evaluate    ",".join($list_data_event)
    Return From Keyword    ${result_data}

Get android data payload of discount order event
    [Arguments]     ${aggregate_id}    ${discount_value}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    [Documentation]    Set các giá trị trong payload của discount order event
    ${ratio_discounted}   ${value_discounted}    Run Keyword If    0<=${discount_value}<=100    Set Variable    ${discount_value}    ${EMPTY}
    ...    ELSE IF    ${discount_value}>100    Set Variable    ${EMPTY}    ${discount_value}
    # Set string discount
    ${str_discount}    KV Set data discount    ${value_discounted}    ${ratio_discounted}
    # Set giá trị của input dictionary
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ...     discount=${str_discount}
    ${template_str}    Get File    ${EXECDIR}/api-data/test_event/discount_order_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

Get android data payload of discount item order event
    [Arguments]    ${aggregate_id}    ${list_pr_uuid}     ${list_pr_price_new}    ${list_pr_price_old}    ${list_pr_ratio}    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    [Documentation]    Set các giá trị trong payload của discount item order eventType
    ${type_list_pr_uuid}             Evaluate    type($list_pr_uuid).__name__
    ${type_list_pr_ratio}            Evaluate    type($list_pr_ratio).__name__
    ${type_list_pr_price_new}        Evaluate    type($list_pr_price_new).__name__
    ${type_list_pr_price_old}        Evaluate    type($list_pr_price_old).__name__
    ${list_pr_ratio}           Run Keyword If    '${type_list_pr_ratio}'=='list'        Set Variable    ${list_pr_ratio}           ELSE    Create List    ${list_pr_ratio}
    Log    ${list_pr_ratio}
    ${list_pr_uuid}            Run Keyword If    '${type_list_pr_uuid}'=='list'         Set Variable    ${list_pr_uuid}            ELSE    Create List    ${list_pr_uuid}
    ${list_pr_price_new}       Run Keyword If    '${type_list_pr_price_new}'=='list'    Set Variable    ${list_pr_price_new}       ELSE    Create List    ${list_pr_price_new}
    ${list_pr_price_old}       Run Keyword If    '${type_list_pr_price_old}'=='list'    Set Variable    ${list_pr_price_old}       ELSE    Create List    ${list_pr_price_old}
    ${list_key_ver}    KV Set List Key Version    ${list_pr_uuid}
    ${list_data_event}       Create List
    ${template_str}    Get File    ${EXECDIR}/api-data/test_event/discount_item_order_event.txt
    FOR    ${pr_uuid}    ${pr_price_new}     ${pr_price_old}    ${pr_ratio}    ${key_ver}    IN ZIP    ${list_pr_uuid}   ${list_pr_price_new}    ${list_pr_price_old}    ${list_pr_ratio}    ${list_key_ver}
        ${cus_event_id_ver}    ${cus_track_ver}    ${cus_event_ver}    ${cus_local_time}    KV Set Common Key Version    ${key_ver}
        # Tính giá trị của value discount (theo VND và ratio)
        ${pr_value_discount}=      Evaluate    ${pr_price_old} - ${pr_price_new}
        ${pr_ratio_new}=    Evaluate    (${pr_price_old} - ${pr_price_new})*100/${pr_price_old}
        ${pr_ratio}=    Run Keyword If    ${pr_ratio}!=0     Set Variable    ${pr_ratio_new}    ELSE    Set Variable    ${pr_ratio}
        # Set giá trị của string discount
        ${str_discount_item}    KV Set data discount item    ${pr_ratio}    ${pr_value_discount}
        # Set giá trị của input dictionary
        ${input_dict}    Create Dictionary    cus_event_id_ver=${cus_event_id_ver}    cus_track_ver=${cus_track_ver}    cus_event_ver=${cus_event_ver}    cus_local_time=${cus_local_time}
        ...    order_item_id=${pr_uuid}    discount_item=${str_discount_item}
        ...    replica_id=${replica_id}       aggregate_id=${aggregate_id}    retailer_id=${retailer_id}        branch_id=${branch_id}   user_id=${user_id}
        ${template_str_copy}   Set Variable    ${template_str}
        ${temp_data_event}     Format String    ${template_str_copy}    ${input_dict}
        ${data_event}    KV Set Data For Input Dict Events    ${EMPTY}     ${key_ver}    ${temp_data_event}
        Log    ${data_event}
        Append To List    ${list_data_event}    ${data_event}
    END
    ${result_data}    Evaluate    ",".join($list_data_event)
    Return From Keyword    ${result_data}

Get android data payload change purchase date
    [Arguments]    ${aggregate_id}    ${purchaseDate}=null    ${branch_id}=${BRANCH_ID}    ${user_id}=${USER_ID}    ${retailer_id}=${RETAILER_ID}
    ${purchaseDate}=    Run Keyword If    "${purchaseDate}"!="null"    Convert Date    ${purchaseDate}    result_format=%Y-%m-%dT%H:%M:%S+07:00
    ...    ELSE    Set Variable    null
    ${input_dict}    Create Dictionary    aggregate_id=${aggregate_id}    purchaseDate=${purchaseDate}   retailer_id=${retailer_id}    branch_id=${branch_id}   user_id=${user_id}
    ${template_str}    Get File    ${template_event_dir}/event_android/change_purchaseDate_event.txt
    ${payload_data}    KV Set Data For Input Dict Events    ${input_dict}     ver    ${template_str}
    Return From Keyword    ${payload_data}

#------------------------------------------------------- End Get data payload -----------------------------------------------------------------
KV Android Set Data Delivery Info
    [Arguments]    ${is_cod}    ${ward}    ${status}    ${receiver}     ${contact_number}    ${address}    ${location_id}    ${delivery_code}    ${price}    ${delvery_date}    ${delivery_by}
    ${receiver}          Set Variable If    '${receiver}'!='${EMPTY}'          \\"receiver\\":\\"${receiver}\\",    ${EMPTY}
    ${contact_number}    Set Variable If    '${contact_number}'!='${EMPTY}'    \\"contactNumber\\":\\"${contact_number}\\",    ${EMPTY}
    ${address}           Set Variable If    '${address}'!='${EMPTY}'           \\"address\\":\\"${address}\\",    ${EMPTY}
    ${location_id}       Set Variable If    '${location_id}'!='${EMPTY}'       \\"locationId\\":${location_id},    ${EMPTY}
    ${delivery_code}     Set Variable If    '${delivery_code}'!='${EMPTY}'     \\"deliveryCode\\":\\"${delivery_code}\\",    ${EMPTY}
    ${price}             Set Variable If    '${price}'!='${EMPTY}'             \\"price\\":${price},    ${EMPTY}
    ${delvery_date}      Set Variable If    '${delvery_date}'!='${EMPTY}'      \\"deliveryDate\\":\\"${delvery_date}+07:00\\",    ${EMPTY}
    ${delivery_by}       Set Variable If    '${delivery_by}'!='${EMPTY}'       \\"deliveryBy\\":${delivery_by}    ${EMPTY}
    ${data_delivery}     Set Variable    {\\"isCod\\":${is_cod},\\"ward\\":\\"${ward}\\",\\"status\\":${status},${receiver}${contact_number}${address}${location_id}${price}${delivery_code}${delvery_date}${delivery_by}}
    Return From Keyword    ${data_delivery}

Get android list old quantity default
    [Arguments]    ${list_item}
    ${list_result}    Create List
    FOR    ${item}    IN    @{list_item}
        Append To List    ${list_result}    1
    END
    Return From Keyword    ${list_result}

KV Android Set data formulas
    [Arguments]    ${product_id}
    ${list_material_code}    ${list_quantity}    ${list_price}    Get list materialCode and quantity of product by id   ${product_id}
    ${list_material_id}    Create List
    FOR    ${material_code}    IN ZIP     ${list_material_code}
        ${material_id}    Get product unit id frm API    ${material_code}
        Append To List    ${list_material_id}    ${material_id}
    END
    Return From Keyword If    "${list_material_id[0]}"=="0"      \\"formulas\\":null
    ${list_formulas}    Create List
    ${length}    Get Length    ${list_material_id}
    FOR    ${index}    IN RANGE    ${length}
        Append To List    ${list_formulas}    {{\\"productId\\":${product_id},\\"quantity\\":${list_quantity[${index}]},\\"price\\":${list_price[${index}]},\\"materialId\\":${list_material_id[${index}]}}}
    END
    ${join_str}    Convert List to String    ${list_formulas}
    ${str_formulas}    Set Variable    \\"formulas\\":[${join_str}]
    KV Log    ${str_formulas}
    Return From Keyword    ${str_formulas}

KV Android Set data discount
    [Arguments]    ${value_discounted}    ${ratio_discounted}
    ${discount}    Run Keyword If    "${value_discounted}"=="${EMPTY}"    Set Variable    {\\"discountType\\":1,\\"value\\":null,\\"valueRatio\\":${ratio_discounted}}    ELSE    Set Variable    {\\"discountType\\":1,\\"value\\":${value_discounted}}
    ${str_discount}    Set Variable    \\"discount\\":${discount}
    Return From Keyword    ${str_discount}

KV Android Set data discount item
    [Arguments]    ${pr_ratio_discount}    ${pr_value_discount}
    ${discount_item}    Run Keyword If    ${pr_ratio_discount}==0    Set Variable    {{\\"discountType\\":1,\\"value\\":${pr_value_discount},\\"valueRatio\\":0}}
    ...    ELSE    Set Variable    {{\\"discountType\\":1,\\"value\\":${pr_value_discount},\\"valueRatio\\":${pr_ratio_discount}}}
    ${str_discount_item}    Set Variable    \\"discount\\":${discount_item}
    Return From Keyword    ${str_discount_item}

#--------------Hai--------------------
KV Android Set data note item
    [Arguments]    ${item_note}
    ${str_note}    Run Keyword If    '${item_note}'!='${EMPTY}'    Set Variable    \\"note\\":\\"${item_note}\\",
    ...    ELSE    Set Variable    ${EMPTY}
    Return From Keyword    ${str_note}

KV Android Set data topping item
    [Arguments]    ${dict_topping}
    ${type_dict_topping}    Evaluate    type($dict_topping).__name__
    Return From Keyword If    '${type_dict_topping}'!='DotDict'     ${EMPTY}
    ${list_pr_id}       Set Variable Return From Dict    ${dict_topping["product_id"]}
    ${list_price}       Set Variable Return From Dict    ${dict_topping["price"]}
    ${list_quantity}    Set Variable Return From Dict    ${dict_topping["quantity"]}
    ${list_toppings}    Create List
    ${length}    Get Length    ${list_pr_id}
    FOR    ${index}    IN RANGE    ${length}
        Append To List    ${list_toppings}    {\\"productId\\":${list_pr_id[${index}]},\\"productSName\\":\\"\\",\\"price\\":${list_price[${index}]},\\"productAttributeLabel\\":\\"\\",\\"productUnit\\":\\"\\",\\"quantity\\":${list_quantity[${index}]}}
    END
    ${str_toppings}    Convert List to String    ${list_toppings}
    Log    ${str_toppings}
    Return From Keyword    ${str_toppings}

KV Android Set data cancel reason item
    [Arguments]    ${cancel_reason_id}    ${reason_detail}
    # Khi notify kitchen mỗi shop có cancelReasonId khác nhau -> default cancel_reason_id=0 (Khác), reason_detail=Khác
    ${str_cancel_reason}    Run Keyword If    '${cancel_reason_id}'=='None' and '${reason_detail}'=='None'    Set Variable    null
    ...    ELSE IF    ${cancel_reason_id}==0    Set Variable    {{\\"cancelReasonId\\":0,\\"reason\\":\\"${reason_detail}\\"}}
    ...    ELSE    Set Variable    {{\\"cancelReasonId\\":${cancel_reason_id},\\"reason\\":\\"Khác\\"}}
    Return From Keyword    ${str_cancel_reason}
#
