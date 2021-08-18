*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Library           BuiltIn
Library           DateTime
Resource           ../../api_access.robot
Resource           ../../GET/hang-hoa/api_thiet_lap_gia.robot
Resource           ../../GET/hang-hoa/api_danhmuc_hanghoa.robot
Resource           ../../GET/phong-ban/api_phong_ban.robot
Resource           ../../GET/doi-tac/api_khachhang.robot
Resource           ../../GET/chi-nhanh/api_chi_nhanh.robot
Resource           ../../GET/thiet-lap/api_nguoi_dung.robot
Resource          ../../../../config/envi.robot
Resource          ../../../share/list_dictionary.robot

*** Keywords ***
Them moi bang gia frm API
    [Documentation]    dict_table_name : dictionary với Key là Tên CN, Value là List tên phòng/bàn
    [Arguments]    ${ten_BG}    ${start_date}    ${end_date}    ${weekOfmonth}=0    ${list_thang}=${EMPTY}    ${list_ngay}=${EMPTY}    ${list_dayOfweek}=${EMPTY}    ${dict_time_range}=${EMPTY}    ${IsActive}=true
    ...    ${list_branch_name}=${EMPTY}    ${list_username}=${EMPTY}    ${list_cus_group_name}=${EMPTY}    ${dict_table_name}=${EMPTY}    ${list_salechannel_name}=${EMPTY}
    ${find_id}    Get pricebook id frm API    ${ten_BG}
    Return From Keyword If    ${find_id}!=0    ${find_id}
    ${type_list_thang}         Evaluate    type($list_thang).__name__
    ${type_list_ngay}          Evaluate    type($list_ngay).__name__
    ${type_list_dayOfweek}     Evaluate    type($list_dayOfweek).__name__
    ${type_dict_time_range}    Evaluate    type($dict_time_range).__name__
    ${type_list_branch_name}   Evaluate    type($list_branch_name).__name__
    ${type_list_username}      Evaluate    type($list_username).__name__
    ${type_list_cus_group_name}     Evaluate    type($list_cus_group_name).__name__
    ${type_dict_table_name}         Evaluate    type($dict_table_name).__name__
    ${type_list_salechannel_name}   Evaluate    type($list_salechannel_name).__name__

    ${data_month}        Run Keyword If    '${type_list_thang}' == 'list'        Evaluate    ",".join($list_thang)        ELSE    Set Variable    ${EMPTY}
    ${data_day}          Run Keyword If    '${type_list_ngay}' == 'list'         Evaluate    ",".join($list_ngay)         ELSE    Set Variable    ${EMPTY}
    ${data_dayOfweek}    Run Keyword If    '${type_list_dayOfweek}' == 'list'    Evaluate    ",".join($list_dayOfweek)    ELSE    Set Variable    ${EMPTY}

    ${start_date}    Convert Date    ${start_date}    date_format=%d/%m/%Y %H:%M    exclude_millis=True
    ${end_date}      Convert Date    ${end_date}      date_format=%d/%m/%Y %H:%M    exclude_millis=True
    ${data_timeRange}    Run Keyword If    '${type_dict_time_range}' == 'DotDict'    KV set data time range    ${dict_time_range}
    ...    ELSE    Set Variable    ${EMPTY}

    ${list_branch_id}     Run Keyword If    '${type_list_branch_name}' == 'list'   Get list branch id by index    ${list_branch_name}    ELSE    Get list all branch id
    ${list_branch_name}   Run Keyword If    '${type_list_branch_name}' == 'list'   Set Variable    ${list_branch_name}    ELSE    Get all branch name
    ${select_branch}   ${data_branch}   ${IsGlobal}    Run Keyword If    '${type_list_branch_name}' == 'list'     KV Set Info Branch   ${list_branch_id}    ELSE    Set Variable    ${EMPTY}    ${EMPTY}    true
    ${select_user}     ${data_user}    ${ForAllUser}   Run Keyword If    '${type_list_username}' == 'list'        KV Set Info User     ${list_username}       ELSE    Set Variable    ${EMPTY}    ${EMPTY}    true
    ${select_sale_channel}  ${data_pricebbook_group}    ${ForAllSaleChannel}    Run Keyword If    '${type_list_salechannel_name}' == 'list'    KV Set Info Sale Channel      ${list_salechannel_name}   ELSE    Set Variable    ${EMPTY}    ${EMPTY}    true
    ${select_cus_group}    ${data_cus_group}    ${ForAllCusGroup}    Run Keyword If    '${type_list_cus_group_name}' == 'list'      KV Set Info Customer Group    ${list_cus_group_name}     ELSE    Set Variable    ${EMPTY}    ${EMPTY}    true
    ${select_table}    ${data_table}    ${data_dinning_option}    ${ForAllTableAndRoom}    Run Keyword If    '${type_dict_table_name}' == 'DotDict'   KV Set Info Table    ${dict_table_name}    ${list_branch_id}    ${list_branch_name}
    ...     ELSE    Set Variable    ${EMPTY}    ${EMPTY}    ${EMPTY}    true
    ${type_value}    Set Variable If   '${type_list_salechannel_name}' == 'list'    null    "SC"

    ${input_dict}    Create Dictionary    ten_BG=${ten_BG}    start_date=${start_date}    end_date=${end_date}
    ...    data_month=${data_month}           data_day=${data_day}          data_dayOfweek=${data_dayOfweek}        weekOfmonth=${weekOfmonth}      data_timeRange=${data_timeRange}
    ...    select_branch=${select_branch}     select_user=${select_user}    select_cus_group=${select_cus_group}    select_table=${select_table}    select_sale_channel=${select_sale_channel}
    ...    data_cus_group=${data_cus_group}   data_user=${data_user}        data_branch=${data_branch}              data_table=${data_table}        data_dinning_option=${data_dinning_option}
    ...    data_pricebbook_group=${data_pricebbook_group}                   ForAllTableAndRoom=${ForAllTableAndRoom}    ForAllSaleChannel=${ForAllSaleChannel}
    ...    IsGlobal=${IsGlobal}               IsActive=${IsActive}          ForAllUser=${ForAllUser}                ForAllCusGroup=${ForAllCusGroup}    type=${type_value}

    ${result_dict}   API Call From Template    /bang-gia/add_bang_gia.txt    ${input_dict}    $.Data
    ${result_id}     Set Variable Return From Dict    ${result_dict.Data[0]}
    Return From Keyword    ${result_id}

KV Set Info Branch
    [Arguments]    ${list_branch_id}
    ${IsGlobal}    Set Variable    false
    ${list_branch_id_str}    Convert item in List to String    ${list_branch_id}
    ${result_select}    Convert List to String    ${list_branch_id_str}
    ${list_data}    Create List
    FOR    ${branch_id}    IN    @{list_branch_id}
        ${item_data}    Set Variable    {"BranchId": ${branch_id}}
        Append To List    ${list_data}    ${item_data}
    END
    ${result_data}    Convert List to String    ${list_data}
    Return From Keyword    ${result_select}    ${result_data}    ${IsGlobal}

KV Set Info User
    [Arguments]    ${list_username}
    ${ForAllUser}    Set Variable    false
    ${list_user_id}    Get list user id by list username    ${list_username}
    ${list_user_id_str}    Convert item in List to String    ${list_user_id}
    ${result_select}   Convert List to String    ${list_username_str}
    ${list_data}    Create List
    FOR    ${user_id}    IN    @{list_user_id}
        ${item_data}    Set Variable    {"UserId": ${user_id}}
        Append To List    ${list_data}    ${item_data}
    END
    ${result_data}    Convert List to String    ${list_data}
    Return From Keyword    ${result_select}    ${result_data}    ${ForAllUser}

# ------- Start Set Info Table ----------
KV Set Info Table
    [Arguments]    ${dict_table_name}    ${list_branch_id}    ${list_branch_name}
    ${ForAllTableAndRoom}    Set Variable    false
    ${list_select}        Create List
    ${list_data_table}    Create List
    ${list_data_dinning}  Create List
    ${dict_table_id}      Create Dictionary
    ${list_ten_CN}   Get Dictionary Keys    ${dict_table_name}
    FOR    ${ten_CN}    IN    @{list_ten_CN}
        ${index}    Get Index From List    ${list_branch_name}    ${ten_CN}
        ${id_CN}    Set Variable    ${list_branch_id[${index}]}
        ${list_table_id}    Get list table id by index    ${dict_table_name["${ten_CN}"]}    ${id_CN}
        ${item_select}    KV Set Selected Table And Room    ${id_CN}    ${list_table_id}
        Append To List    ${list_select}    ${item_select}
        Set To Dictionary    ${dict_table_id}    ${id_CN}    ${list_table_id}
    END
    ${result_select}    Convert List to String    ${list_select}
    Log Dictionary    ${dict_table_id}
    FOR    ${id_CN}    IN    @{dict_table_id}
        ${list_table_id_CN}    Get From Dictionary    ${dict_table_id}    ${id_CN}
        ${list_item_table}    ${list_item_dinning}    KV Set Pricebook Table and Pricebook Dinning Option    ${id_CN}    ${list_table_id_CN}
        ${list_data_table}     Combine Lists    ${list_data_table}     ${list_item_table}
        ${list_data_dinning}   Combine Lists    ${list_data_dinning}   ${list_item_dinning}
    END
    ${result_BG_table}      Convert List to String    ${list_data_table}
    ${result_BG_dinning}    Convert List to String    ${list_data_dinning}
    Return From Keyword    ${result_select}    ${result_BG_table}    ${result_BG_dinning}    ${ForAllTableAndRoom}

KV Set Selected Table And Room
    [Arguments]    ${id_CN}    ${list_table_id}
    ${list_data}    Create List
    FOR    ${table_id}    IN    @{list_table_id}
        ${item_data}    Set Variable    "${table_id}|${id_CN}"
        Append To List    ${list_data}    ${item_data}
    END
    ${str_data}    Convert List to String    ${list_data}
    Return From Keyword    ${str_data}

KV Set Pricebook Table and Pricebook Dinning Option
    [Arguments]    ${id_CN}    ${list_table_id}
    ${list_data_table}    Create List
    ${list_data_dinning}    Create List
    FOR    ${table_id}    IN    @{list_table_id}
        Run Keyword If    ${table_id}==-3    Append To List    ${list_data_dinning}    {"DiningOption": 3,"BranchId": ${id_CN}}
        Run Keyword If    ${table_id}==-1    Append To List    ${list_data_dinning}    {"DiningOption": 1,"BranchId": ${id_CN}}
        Run Keyword If    ${table_id} > 0    Append To List    ${list_data_table}      {"TableAndRoomId": ${table_id}}
    END
    Return From Keyword    ${list_data_table}    ${list_data_dinning}

# Cập nhật tất cả giá của hàng hóa đã được add vào bảng giá
Cap nhat gia hang hoa trong bang gia
    [Documentation]    value là giá trị tăng/giảm. Nếu truyền value >100 thì sẽ là tăng/giảm giá theo VND. ngược lại tính theo %
    ...    operator là phép tính: nếu operator=2 là phép trừ, operator=1 là phép cộng.
    ...    price_type là giá gốc đế tính giá mới: 0 là giá vốn, 1 - là giá hiện tại, 2 - giá nhập lần cuối, 3- giá chung
    [Arguments]    ${pricebook_id}    ${value}    ${price_type}=${3}    ${operator}=${2}
    ${pr_quantity}    Get total product in Pricebook    ${pricebook_id}
    ${value_type}   Run Keyword If   0<=${value}<=100    Set Variable    %    ELSE IF    ${value} > 100     Set Variable    VND
    ${input_dict}    Create Dictionary    pricebook_id=${pricebook_id}    price_type=${price_type}    operator=${operator}
    ...    value=${value}    value_type=${value_type}    pr_quantity=${pr_quantity}
    API Call From Template    /bang-gia/update_banggia.txt    ${input_dict}

# ------- End Set Info Table ----------

KV Set Info Sale Channel
    [Arguments]    ${list_salechannel_name}
    ${ForAllSaleChannel}    Set Variable    false
    ${list_salechannel_id}    Get list sale channel id by name    ${list_salechannel_name}
    ${list_salechannel_id_str}    Convert item in List to String    ${list_salechannel_id}
    ${result_select}    Convert List to String    ${list_salechannel_id_str}
    ${list_data}    Create List
    FOR    ${salechannel_id}    IN    @{list_salechannel_id}
        ${item_data}    Set Variable    {"GroupId": ${salechannel_id},"Type": 0}
        Append To List    ${list_data}    ${item_data}
    END
    ${result_data}    Convert List to String    ${list_data}
    Return From Keyword    ${result_select}    ${result_data}    ${ForAllSaleChannel}

KV Set Info Customer Group
    [Arguments]    ${list_cus_group_name}
    ${ForAllCusGroup}    Set Variable    false
    ${list_cus_group_id}    Get list customer group id by list name    ${list_cus_group_name}
    ${list_cus_group_id_str}    Convert item in List to String    ${list_cus_group_id}
    ${result_select}    Convert List to String    ${list_cus_group_id_str}
    ${list_data}    Create List
    FOR    ${cus_group_id}    IN    @{list_cus_group_id}
        ${item_data}    Set Variable    {"CustomerGroupId": ${cus_group_id}}
        Append To List    ${list_data}    ${item_data}
    END
    ${result_data}    Convert List to String    ${list_data}
    Return From Keyword    ${result_select}    ${result_data}    ${ForAllCusGroup}

#----------------
Delete bang gia
    [Arguments]    ${id_BG}
    ${input_dict}    Create Dictionary    id_BG=${id_BG}
    Run Keyword If    '${id_BG}'!='0'    API Call From Template    /bang-gia/delete_bang_gia.txt    ${input_dict}    ELSE    KV Log    Bang gia can xoa khong ton tai trong he thong

Add product category to pricebook
    [Arguments]    ${pricebook_id}    ${ten_nhom_hang}
    ${id_nhom_hang}    Get category ID by category name    ${ten_nhom_hang}
    ${input_dict}    Create Dictionary    id_BG=${pricebook_id}    id_nhom_hang=${id_nhom_hang}
    API Call From Template    /bang-gia/add_nhom_hang_vao_bang_gia.txt    ${input_dict}

KV set data time range
    [Arguments]   ${dict_time_range}
    ${list_time_from}    Get Dictionary Keys    ${dict_time_range}
    ${list_time_to}    Get Dictionary Values    ${dict_time_range}
    ${length}   Get Length    ${list_time_from}
    ${list_data_time}    Create List
    FOR    ${index}    IN RANGE    ${length}
        Append To List    ${list_data_time}    {\\"TimeFrom\\":\\"${list_time_from[${index}]}\\",\\"TimeTo\\":\\"${list_time_to[${index}]}\\"}
    END
    ${data_timeRange}    Evaluate    ",".join($list_data_time)
    Return From Keyword    ${data_timeRange}

#.............................................
Edit bang gia from API
    [Documentation]    dict_table_name : dictionary với Key là Tên CN, Value là List tên phòng/bàn
    [Arguments]    ${ten_BG_old}    ${ten_BG_new}=${EMPTY}    ${start_date}=${EMPTY}    ${end_date}=${EMPTY}    ${weekOfmonth}=0    ${list_thang}=${EMPTY}    ${list_ngay}=${EMPTY}    ${list_dayOfweek}=${EMPTY}    ${dict_time_range}=${EMPTY}    ${IsActive}=true
    ...    ${list_branch_name}=${EMPTY}    ${list_username}=${EMPTY}    ${list_cus_group_name}=${EMPTY}    ${dict_table_name}=${EMPTY}    ${list_salechannel_name}=${EMPTY}
    ${id_BG}    Get pricebook id frm API    ${ten_BG_old}
    ${type_list_thang}         Evaluate    type($list_thang).__name__
    ${type_list_ngay}          Evaluate    type($list_ngay).__name__
    ${type_list_dayOfweek}     Evaluate    type($list_dayOfweek).__name__
    ${type_dict_time_range}    Evaluate    type($dict_time_range).__name__
    ${type_list_branch_name}   Evaluate    type($list_branch_name).__name__
    ${type_list_username}      Evaluate    type($list_username).__name__
    ${type_list_cus_group_name}     Evaluate    type($list_cus_group_name).__name__
    ${type_dict_table_name}         Evaluate    type($dict_table_name).__name__
    ${type_list_salechannel_name}   Evaluate    type($list_salechannel_name).__name__

    # Update tab thông tin phần hiệu lực thời gian
    ${data_month}        Run Keyword If    '${type_list_thang}' == 'list'        Evaluate    ",".join($list_thang)        ELSE    Set Variable    ${EMPTY}
    ${data_day}          Run Keyword If    '${type_list_ngay}' == 'list'         Evaluate    ",".join($list_ngay)         ELSE    Set Variable    ${EMPTY}
    ${data_dayOfweek}    Run Keyword If    '${type_list_dayOfweek}' == 'list'    Evaluate    ",".join($list_dayOfweek)    ELSE    Set Variable    ${EMPTY}

    ${data_timeRange}    Run Keyword If    '${type_dict_time_range}' == 'DotDict'    KV set data time range    ${dict_time_range}
    ...    ELSE    Set Variable    ${EMPTY}

    ${CreatedBy}    ${CreatedDate}    ${CompareIsActive}    ${CompareStartDate}    ${CompareEndDate}    Get list info by id    ${id_BG}
    ${start_date}    Run Keyword If     "${start_date}"!="${EMPTY}"    Convert Date    ${start_date}    date_format=%d/%m/%Y %H:%M    exclude_millis=True
    ...    ELSE    Set Variable    ${CompareStartDate}
    ${end_date}    Run Keyword If    "${end_date}"!="${EMPTY}"    Convert Date    ${end_date}    date_format=%d/%m/%Y %H:%M    exclude_millis=True
    ...    ELSE    Set Variable    ${CompareEndDate}
    ${weekOfmonth}    Set Variable If    "${weekOfmonth}"!="${EMPTY}"    ${weekOfmonth}    ${0}
    ${ten_BG_new}     Set Variable If    "${ten_BG_new}"=="${EMPTY}"    ${ten_BG_old}    ${ten_BG_new}

    # Update tab phạm vi áp dụng
    ${list_branch_id}     Run Keyword If    '${type_list_branch_name}' == 'list'   Get list branch id by index    ${list_branch_name}    ELSE    Get list all branch id
    ${list_branch_name}   Run Keyword If    '${type_list_branch_name}' == 'list'   Set Variable    ${list_branch_name}    ELSE    Get all branch name
    ${select_branch}   ${data_branch}   ${IsGlobal}    Run Keyword If    '${type_list_branch_name}' == 'list'     KV Set Info Branch   ${list_branch_id}    ELSE    Set Variable    ${EMPTY}    ${EMPTY}    true
    ${select_user}     ${data_user}    ${ForAllUser}   Run Keyword If    '${type_list_username}' == 'list'        KV Set Info User     ${list_username}       ELSE    Set Variable    ${EMPTY}    ${EMPTY}    true
    ${select_sale_channel}  ${data_pricebbook_group}    ${ForAllSaleChannel}    Run Keyword If    '${type_list_salechannel_name}' == 'list'    KV Set Info Sale Channel      ${list_salechannel_name}   ELSE    Set Variable    ${EMPTY}    ${EMPTY}    true
    ${select_cus_group}    ${data_cus_group}    ${ForAllCusGroup}    Run Keyword If    '${type_list_cus_group_name}' == 'list'      KV Set Info Customer Group    ${list_cus_group_name}     ELSE    Set Variable    ${EMPTY}    ${EMPTY}    true
    ${select_table}    ${data_table}    ${data_dinning_option}    ${ForAllTableAndRoom}    Run Keyword If    '${type_dict_table_name}' == 'DotDict'   KV Set Info Table    ${dict_table_name}    ${list_branch_id}    ${list_branch_name}
    ...     ELSE    Set Variable    ${EMPTY}    ${EMPTY}    ${EMPTY}    true
    ${type_value}    Set Variable If   '${type_list_salechannel_name}' == 'list'    null    "SC"

    ${input_dict}    Create Dictionary    ten_BG_old=${ten_BG_old}    ten_BG_new=${ten_BG_new}    start_date=${start_date}    end_date=${end_date}
    ...    data_month=${data_month}           data_day=${data_day}          data_dayOfweek=${data_dayOfweek}        weekOfmonth=${weekOfmonth}      data_timeRange=${data_timeRange}
    ...    select_branch=${select_branch}     select_user=${select_user}    select_cus_group=${select_cus_group}    select_table=${select_table}    select_sale_channel=${select_sale_channel}
    ...    data_cus_group=${data_cus_group}   data_user=${data_user}        data_branch=${data_branch}              data_table=${data_table}        data_dinning_option=${data_dinning_option}
    ...    data_pricebbook_group=${data_pricebbook_group}                   ForAllTableAndRoom=${ForAllTableAndRoom}    ForAllSaleChannel=${ForAllSaleChannel}
    ...    IsGlobal=${IsGlobal}               IsActive=${IsActive}          ForAllUser=${ForAllUser}                ForAllCusGroup=${ForAllCusGroup}    type=${type_value}
    ...    id_BG=${id_BG}    CompareIsActive=${CompareIsActive}    CompareStartDate=${CompareStartDate}    CompareEndDate=${CompareEndDate}    CreatedBy=${CreatedBy}    RetailerId=${RETAILER_ID}
    ...    ModifiedBy=${USER_ID}    CreatedDate=${CreatedDate}
    KV Log    ${input_dict}
    ${result_dict}   API Call From Template    /bang-gia/edit_banggia.txt    ${input_dict}    $.Data
    ${result_id}     Set Variable Return From Dict    ${result_dict.Data[0]}
    Return From Keyword    ${result_id}

# list_add_pr_code phải cùng nhóm hàng hóa "${ten_nhom_hang}" truyền vào khi add product
Add hang hoa va cap nhat bang gia
    [Arguments]    ${pricebook_id}    ${ten_nhom_hang}    ${list_add_pr_code}    ${ratio}
    ${list_pr_code}    Get list product code in pricebook    ${pricebook_id}
    ${status}    Run Keyword And Return Status    List Should Contain Sub List     ${list_pr_code}     ${list_add_pr_code}
    Return From Keyword If    "${status}"=="PASS"   ${list_pr_code}
    Add product category to pricebook   ${pricebook_id}    ${ten_nhom_hang}
    Cap nhat gia hang hoa trong bang gia    ${pricebook_id}     ${ratio}
