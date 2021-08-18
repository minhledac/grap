*** Settings ***
Library           ../../custom-library/JSONLibrary.py
Library           RequestsLibrary
Library           String
Library           Collections
Library           BuiltIn
Resource          ../share/computation.robot
Resource          ../../config/envi.robot
Resource          GET/hang-hoa/api_danhmuc_hanghoa.robot
Resource          ../share/utils.robot

*** Keywords ***
API Get BearerToken&Cookies
    ${credential}=    Create Dictionary      UserName=${USER_NAME}    Password=${PASSWORD}    provider=credentials    UseTokenCookie=true
    ${headers}=    Create Dictionary    Content-Type=application/json; charset=UTF-8   retailer=${RETAILER}    Accept=*/*    X-Requested-With=XMLHttpRequest
    Create Session    login_session    ${API_URL}    headers=${headers}    verify=True    disable_warnings=1
    ${resp}=    Post Request    login_session   /auth/credentials?format=json    data=${credential}
    KV Log    ${resp.json()}
    KV Log    ${resp.cookies}
    Should Be Equal As Strings    ${resp.status_code}    200    Lỗi response status code khác 200
    ${bearertoken}    Get Value From Json    ${resp.json()}    $..BearerToken
    #Log    ${bearertoken}
    ${bearertoken}=    Catenate    Bearer    ${bearertoken[0]}
    #Log    ${bearertoken}
    Return From Keyword    ${bearertoken}    ${resp.cookies}

API Change Branch And Get Branch Cookies
    [Arguments]    ${branch_change_id}
    ${cookies}    Set Variable    ${resp.cookies}
    Evaluate    $cookies.set($LATESTBRANCH,$branch_change_id, domain='fnb.kiotviet.vn')
    Log    ${cookies}
    Return From Keyword    ${cookies}

Set Branch Cookies
    [Arguments]    ${branch_change_id}
    ${ss-tok-r}    Get From Dictionary    ${resp.cookies}    ss-tok
    ${ss-tok}    Catenate    ${ss-tok-r}
    ${ss-id-r}    Get From Dictionary    ${resp.cookies}    ss-id
    ${ss-id}    Catenate    ${ss-id-r}
    ${ss-opt-r}    Get From Dictionary    ${resp.cookies}    ss-opt
    ${ss-opt}    Catenate    ${ss-opt-r}
    ${ss-pid-r}    Get From Dictionary    ${resp.cookies}    ss-pid
    ${ss-pid}    Catenate    ${ss-pid-r}
    ${branch_change_id}    Catenate    ${branch_change_id}
    ${cookies_by_br}    Create Dictionary    ss-id=${ss-id}    ss-opt=${ss-opt}    ss-pid=${ss-pid}    ss-tok=${ss-tok}    ${LATESTBRANCH}=${branch_change_id}
    ...    Retailer=${RETAILER}
    Log    ${cookies_by_br}
    Return From Keyword    ${cookies_by_br}

API Call From Template
    [Documentation]    is_return_response: Nếu bằng True thì keyword sẽ trả về toàn bộ response của request, bỏ qua việc get thông tin theo jsonpath
    [Arguments]    ${template_file}    ${input_data}=${EMPTY}    ${json_path}=${EMPTY}    ${custom_params}=${EMPTY}    ${status_code_should_be}=200
    ...    ${tao_hang_sx}=False    ${session_alias}=session_api    ${input_branch_id}=${EMPTY}    ${is_return_response}=False
    ${template_str}    Get File    ${EXECDIR}/api-data/${template_file}
    ${template_str}    Format String    '${template_str}'    ${input_data}
    @{json_str_split}    Split String    ${template_str}    \\"
    ${template_str}    Catenate    SEPARATOR=\\\\"    @{json_str_split}
    ${api_json}    Evaluate     json.loads(''${template_str}'')    json
    KV Log    ${api_json}
    ${api}    Get Value From Json    ${api_json}    $.api
    ${api_params}    Get Value From Json    ${api_json}    $.api_params
    ${param_lenght}    Get Length    ${api_params[0]}
    ${type_params}=    Evaluate    type($custom_params).__name__
    KV Log    ${custom_params}
    ${api_param_str}    Run Keyword If    '${type_params}'=='list'    Catenate    SEPARATOR=&    @{custom_params}    ELSE    Catenate    SEPARATOR=&    @{api_params[0]}
    ${api_str}    Run Keyword If    ${param_lenght}>0    Set Variable    ${api[0]}?${api_param_str}    ELSE    Set Variable    ${api[0]}
    KV Log    ${api_str}
    ${method}    Get Value From Json    ${api_json}    $.method
    ${data_json}    Get Value From Json    ${api_json}    $.data
    ${type_data_json}=    Evaluate    type($data_json[0]).__name__
    ${data}    Run Keyword If    '${type_data_json}'=='dict'    Evaluate    json.dumps(${data_json[0]}, separators=(',',':'))    json    ELSE    Evaluate    None
    ${files_json}    Get Value From Json    ${api_json}    $.files
    ${type_files_json}=    Evaluate    type($files_json[0]).__name__
    ${files}    Run Keyword If    '${type_files_json}'=='dict'    Sub KeyWord Set Files Data API    ${files_json[0]}    ${input_data}    ELSE    Evaluate    None

    ${input_branch_id}    Run Keyword If    '${input_branch_id}'!='${EMPTY}'    Convert To String    ${input_branch_id}    ELSE    Set Variable    ${input_branch_id}
    ${header}    Run Keyword If    '${input_branch_id}'=='${EMPTY}'    Create Dictionary    Authorization=${bearertoken}    Content-Type=application/json    kv-version=${kv_version}    retailer=${RETAILER}
    ...    ELSE    Create Dictionary    Authorization=${bearertoken}    Content-Type=application/json    kv-version=${kv_version}    retailer=${RETAILER}    branchid=${input_branch_id}
    KV Log    ${header}
    Run Keyword If    '${type_files_json}'=='dict'    Remove From Dictionary    ${header}    Content-Type
    ${params}    Create Dictionary    format=json

    ${res}=    Run Keyword If    '${method[0]}'=='POST' and '${type_files_json}'=='dict'    Post Request    ${session_alias}    ${api_str}    data=${data}    files=${files}    headers=${header}
    ...    ELSE IF    '${method[0]}'=='POST'     Post Request     ${session_alias}    ${api_str}    data=${data}    headers=${header}
    ...    ELSE IF    '${method[0]}'=='DELETE'   Delete Request   ${session_alias}    ${api_str}    data=${data}    headers=${header}
    ...    ELSE IF   '${method[0]}'=='GET'       Get Request      ${session_alias}    ${api_str}    params=${params}    headers=${header}

    KV Log    ${res.request.body}
    KV Log    ${res.json()}
    KV Log    ${res.status_code}
    Return From Keyword If    '${is_return_response}'=='True'    ${res.json()}
    ${lst_resp_msg}    Get Value From JSON    ${res.json()}    $..Message
    ${resp_msg}=    Evaluate    ''.join(${lst_resp_msg})
    # Log To Console    ${resp_msg}

    # Nếu api post tạo hàng sản xuất trả về code 420 và msg Có lỗi khi cập nhật dữ liệu thì sẽ bypass
    ${res}    Run Keyword If    '${tao_hang_sx}'=='True' and '${res.status_code}'=='420' and '${resp_msg}'=='Có lỗi khi cập nhật dữ liệu'
    ...    KV Check Send Request Error    ${res}    ${input_data.ma_hang_hoa}    ${api_str}    ${data}    ${files}    ${session_alias}
    ...    ELSE    Set Variable    ${res}

    Should Be Equal As Strings    ${res.status_code}    ${status_code_should_be}    Lỗi response status code expected và actual khác nhau

    ${type_json_path}=    Evaluate    type($json_path).__name__
    ${json_paths}    Run Keyword If    '${type_json_path}'=='list'    Set Variable    ${json_path}    ELSE    Create List    ${json_path}
    KV Log    ${json_paths}
    ${return_data}    Run Keyword If    '${json_paths[0]}'!='${EMPTY}'    KV Get Data From Json by List Xpath    ${res.json()}    ${json_paths}    ELSE    Set Variable    ${res.status_code}
    KV Log    ${return_data}
    Return From Keyword    ${return_data}

Android API Call From Template
    [Arguments]    ${template_file}    ${input_data}=${EMPTY}    ${json_path}=${EMPTY}    ${custom_params}=${EMPTY}
    ${template_str}    Get File    ${EXECDIR}/api-data/${template_file}
    ${template_str}    Format String    '${template_str}'    ${input_data}
    @{json_str_split}    Split String    ${template_str}    \\"
    ${template_str}    Catenate    SEPARATOR=\\\\"    @{json_str_split}
    ${api_json}    Evaluate     json.loads(''${template_str}'')    json
    ${api}    Get Value From Json    ${api_json}    $.api
    ${api_params}    Get Value From Json    ${api_json}    $.api_params
    ${param_lenght}    Get Length    ${api_params[0]}
    ${type_params}=    Evaluate    type($custom_params).__name__
    KV Log    ${custom_params}
    ${api_param_str}    Run Keyword If    '${type_params}'=='list'    Catenate    SEPARATOR=&    @{custom_params}    ELSE    Catenate    SEPARATOR=&    @{api_params[0]}
    ${api_str}    Run Keyword If    ${param_lenght}>0    Set Variable    ${api[0]}?${api_param_str}    ELSE    Set Variable    ${api[0]}
    KV Log    ${api_str}
    ${method}    Get Value From Json    ${api_json}    $.method
    ${data_json}    Get Value From Json    ${api_json}    $.data
    ${type_data_json}=    Evaluate    type($data_json[0]).__name__
    ${data}    Run Keyword If    '${type_data_json}'=='dict'    Evaluate    json.dumps(${data_json[0]}, separators=(',',':'))    json    ELSE    Evaluate    None
    ${files_json}    Get Value From Json    ${api_json}    $.files
    ${type_files_json}=    Evaluate    type($files_json[0]).__name__
    ${files}    Run Keyword If    '${type_files_json}'=='dict'    Sub KeyWord Set Files Data API    ${files_json[0]}    ${input_data}    ELSE    Evaluate    None

    ${header}    Create Dictionary    Authorization=${bearertoken}    Content-Type=application/json    Retailer=${RETAILER}
    Run Keyword If    '${type_files_json}'=='dict'    Remove From Dictionary    ${header}    Content-Type
    ${params}    Create Dictionary    format=json

    ${res}=    Run Keyword If    '${method[0]}'=='POST' and '${type_files_json}'=='dict'    Post Request    session_mobileapi    ${api_str}    data=${data}    files=${files}    headers=${header}
    ...    ELSE IF    '${method[0]}'=='POST'     Post Request     session_mobileapi    ${api_str}    data=${data}    headers=${header}
    ...    ELSE IF    '${method[0]}'=='DELETE'   Delete Request   session_mobileapi    ${api_str}    data=${data}    headers=${header}
    ...    ELSE IF   '${method[0]}'=='GET'       Get Request      session_mobileapi    ${api_str}    params=${params}    headers=${header}

    KV Log    ${res.request.body}
    KV Log    ${res.json()}
    KV Log    ${res.status_code}
    Should Be Equal As Strings    ${res.status_code}    200    Lỗi response status code expected và actual khác nhau

    ${type_json_path}=    Evaluate    type($json_path).__name__
    ${json_paths}    Run Keyword If    '${type_json_path}'=='list'    Set Variable    ${json_path}    ELSE    Create List    ${json_path}
    KV Log    ${json_paths}
    ${return_data}    Run Keyword If    '${json_paths[0]}'!='${EMPTY}'    KV Get Data From Json by List Xpath    ${res.json()}    ${json_paths}    ELSE    Set Variable    ${res.status_code}
    KV Log    ${return_data}
    Return From Keyword    ${return_data}

# Kiểm tra hàng hóa tồn tại hay không? Nếu không thì thực hiện Set Self Response And Reset Code
KV Check Send Request Error
    [Arguments]    ${response}    ${product_code}    ${api_str}    ${data}    ${files}    ${session_alias}
    # Log    ${product_code}
    ${is_success}    Check product is created successfully    ${product_code}
    ${res_retry}    Run Keyword If     '${is_success}'=='False'    Retry Send Request Post    ${api_str}    ${data}    ${files}    ${session_alias}
    ...    ELSE    Set Self Response And Reset Code    ${response}
    Return From Keyword    ${res_retry}

# Gửi lại request post 3 lần, nếu thành công thì break luôn
Retry Send Request Post
    [Arguments]    ${api_str}    ${data}    ${files}    ${session_alias}
    ${index}    Set Variable    ${0}
    FOR    ${index}    IN RANGE    3
        ${res_retry}=    Post Request    ${session_alias}    ${api_str}    data=${data}    files=${files}
        ${index}    Evaluate    ${index}+1
        Continue For Loop If    ${res_retry.status_code}!=200
    END
    Return From Keyword    ${res_retry}

# Set code = 200, set response = chính nó
Set Self Response And Reset Code
    [Arguments]    ${response}
    ${response.status_code}    Set Variable    ${200}
    ${res_retry}    Set Variable    ${response}
    Return From Keyword    ${res_retry}

# ${percision_number}: hỗ trợ khi cần làm tròn giá trị type=float từ API
Set Variable Return From Dict
    [Arguments]    ${value}    ${percision_number}=${EMPTY}
    ${type_value}=    Evaluate    type($value).__name__
    ${list_value}    Run Keyword If    '${type_value}'=='list'    Set Variable    ${value}    ELSE    Create List    ${value}
    ${length}    Get Length    ${list_value}
    FOR    ${i}    IN RANGE    ${length}
        Run KeyWord If    '${list_value[${i}]}'=='${EMPTY}'   Set List Value    ${list_value}    ${i}    ${0}

        ${item_type}=    Evaluate    type($list_value[${i}]).__name__
        ${item_value}    Run Keyword If    '${item_type}'=='float' and '${percision_number}' !='${EMPTY}'    Evaluate    round(${list_value[${i}]},${percision_number})
        Run Keyword If    '${item_type}'=='float' and '${percision_number}' !='${EMPTY}'    Set List Value    ${list_value}    ${i}    ${item_value}
    END
    ${return_value}    Run Keyword If    '${type_value}'=='list'    Set Variable    ${list_value}    ELSE    Set Variable    ${list_value[0]}
    [Return]    ${return_value}

Get List JSONPath
    [Arguments]    ${list_key}     ${json_path}=${EMPTY}    ${list_key_path}=${EMPTY}
    ${type_json_path}=    Evaluate    type($json_path).__name__
    # Tạo list json path nếu đầu vào không phải là list
    ${list_json_path}    Run Keyword If    '${type_json_path}'=='list'    Set Variable    ${json_path}    ELSE    Create List
    # Nếu json path khác rỗng và chứa 1 biến đơn thì append vào list json path
    Run Keyword If    '${json_path}'!='${EMPTY}'    Append To List    ${list_json_path}    ${json_path}
    # Nếu List key khác thì dùng json path ${list_key_path}.${list_key}
    Run Keyword If    '${list_key}'!='${EMPTY}'    Append To List    ${list_json_path}    ${list_key_path}.${list_key}
    [Return]    ${list_json_path}

KV Get Data From Json by List Xpath
    [Arguments]    ${json}    ${json_paths}
    &{return_data}    Get Dict From List Json    ${json}    ${json_paths}
    Return From Keyword    ${return_data}

Merge Dictionary
    [Arguments]    ${output_dict}    ${input_dict}    ${count}
    ${keys}    Get Dictionary Keys    ${output_dict}
    FOR    ${key}    IN    @{input_dict}
        ${index}    Get Index From List    ${keys}    ${key}
        Run KeyWord If    ${index}<0    Set To Dictionary    ${output_dict}    ${key}    ${input_dict["${key}"]}    ELSE    Set To Dictionary    ${output_dict}    ${key}_${count}    ${input_dict["${key}"]}
    END
    ${length_min}    Run KeyWord If    ${length}==0    Set Variable    ${1}    ELSE    Set Variable    ${length}
    FOR    ${i}    IN RANGE    ${filter_length}
        ${filter}    Set Variable    ${list_filter[${i}]}
        ${filter}    Replace String    ${filter}    "    ${EMPTY}
        ${raw_data_length}    Get Length    ${data_dict["${filter}"]}
        ${zero_data}    Create List Fill With Zero    ${length_min}
        Run KeyWord If    ${raw_data_length}==0    Set To Dictionary    ${data_dict}    ${filter}    ${zero_data}
    END
    [Return]    ${data_dict}    ${length}

Create List Fill With Zero
    [Arguments]    ${length}
    ${list}    Create List
    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${list}    ${0}
    END
    [Return]    ${list}

Extract Data in Multi Value From Json
    [Arguments]    ${raw_data}    ${filter_length}    ${index}
    ${raw_data_length}    Get Length    ${raw_data}
    ${length}    Evaluate    int(${raw_data_length}/${filter_length})
    ${data_list}    Create List
    FOR    ${i}    IN RANGE    ${length}
        ${index_extract}    Evaluate    ${filter_length} * ${i} + ${index}
        ${data}    Set Variable    ${raw_data[${index_extract}]}
        Append To List    ${data_list}    ${data}
    END
    [Return]    ${data_list}

Sub KeyWord Set Files Data API
    [Arguments]    ${files_json}    ${input_dict}
    ${files}    Create Dictionary
    FOR    ${member}    IN    @{files_json}
        ${get_raw_data}    Get Value From Json    ${files_json}    $.'${member}'
        ${raw_data}    Set Variable    ${get_raw_data[0]}
        ${json_string}    Evaluate    json.dumps($raw_data, ensure_ascii=False, separators=(',',':'))    json
        ${json_string}    Run Keyword If    '${json_string[0]}'=='"'    Get Substring    ${json_string}    1    -1    ELSE    Set Variable    ${json_string}
        @{json_str_split}    Split String    ${json_string}    \\"
        ${json_string}    Catenate    SEPARATOR=\\\\"    @{json_str_split}
        ${data}=    Run Keyword If    '${json_string}'!='["File"]'
        ...    Evaluate    (None, '${json_string}')
        ...    ELSE
        ...    Sub KeyWord Open File To API    ${input_dict["${member}"]}
        Set To Dictionary    ${files}    ${member}    ${data}
    END
    [Return]    ${files}

Sub KeyWord Open File To API
    [Arguments]    ${file_dir}
    ${file_name}    Fetch From Right    ${file_dir}    /
    ${file_ext}    Fetch From Right    ${file_dir}    .
    ${dict_media_types}    Create Dictionary    jpg=image/jpeg    jpeg=image/jpeg    png=image/png    xls=application/vnd.ms-excel    xlsx=application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    ${file_dir}    Set Variable    ${EXECDIR}\\prepare-data\\${file_dir}
    ${file}=    Evaluate    ('${file_name}', open($file_dir, 'r+b'), '${dict_media_types["${file_ext}"]}')
    [Return]    ${file}

KV Get Dict All Info Current Session
    [Arguments]    ${list_jsonpath}
    ${result_dict}    API Call From Template    /api-access/current_session.txt    ${EMPTY}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

KV Get Current Branch Id
    ${result_dict}    KV Get Dict All Info Current Session    $.CurrentBranchId
    ${current_branch_id}    Set Variable Return From Dict    ${result_dict.CurrentBranchId[0]}${EMPTY}
    Return From Keyword    ${current_branch_id}

KV Get Current Branch Name
    ${result_dict}    KV Get Dict All Info Current Session    $.CurrentBranch.Name
    ${current_branch_name}    Set Variable    ${result_dict.Name[0]}
    Return From Keyword    ${current_branch_name}

KV Get RetailerId And UserId
    ${list_jsonpath}    Create List    $.Retailer.Id    $.UserId
    ${result_dict}    KV Get Dict All Info Current Session    ${list_jsonpath}
    ${get_retailer_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    ${get_user_id}        Set Variable Return From Dict    ${result_dict.UserId[0]}
    Return From Keyword    ${get_retailer_id}    ${get_user_id}

KV Get RetailerId And UserId And BranchId
    ${list_jsonpath}    Create List    $.Retailer.Id    $.UserId    $.CurrentBranchId    $.CurrentBranch.Name
    ${result_dict}    KV Get Dict All Info Current Session    ${list_jsonpath}
    ${get_retailer_id}     Set Variable Return From Dict    ${result_dict.Id[0]}
    ${get_user_id}         Set Variable Return From Dict    ${result_dict.UserId[0]}
    ${current_branch_id}   Set Variable Return From Dict    ${result_dict.CurrentBranchId[0]}${EMPTY}
    ${current_branch_name}   Set Variable Return From Dict    ${result_dict.Name[0]}
    Return From Keyword    ${get_retailer_id}    ${get_user_id}    ${current_branch_id}    ${current_branch_name}

Get RetailerID
    ${result_dict}    KV Get Dict All Info Current Session    $.Retailer.Id
    ${get_retailer_id}    Set Variable    ${result_dict.Id[0]}
    Return From Keyword    ${get_retailer_id}

Get User ID
    ${result_dict}   KV Get Dict All Info Current Session    $.UserId
    ${get_userid}    Set Variable    ${result_dict.UserId[0]}
    Return From Keyword    ${get_userid}

Get ID nguoi tao frm API
    ${result_dict}    KV Get Dict All Info Current Session    $.CurrentUser.Id
    ${get_id_nguoitao}    Set Variable    ${result_dict.Id[0]}
    Return From Keyword    ${get_id_nguoitao}

Get nguoi tao frm API
    ${result_dict}    KV Get Dict All Info Current Session    $.CurrentUser.GivenName
    ${get_nguoitao}   Set Variable    ${result_dict.GivenName[0]}
    Return From Keyword    ${get_nguoitao}

Event Call From Template
    [Arguments]    ${template_input_dict}    ${id_branch}=${BRANCH_ID}
    # Set các giá trị replica_id, remote_ver, local_ver
    Set Test Variable    ${remote_ver}    ${version}
    Set To Dictionary    ${template_input_dict}    replica_id    ${replica_id}
    Set To Dictionary    ${template_input_dict}    remote_ver    ${remote_ver}
    Set To Dictionary    ${template_input_dict}    local_ver     ${local_ver}
    # Kiểm tra có tồn tại secondary_event ? Nếu không thì add key secondary_event vào dict với value = ${EMPTY}
    ${key_exist}    Run Keyword And Return Status    Dictionary Should Contain Key    ${template_input_dict}    secondary_event
    Run Keyword If    '${key_exist}'!='True'    Set To Dictionary    ${template_input_dict}    secondary_event    ${EMPTY}
    # Format toàn bộ dữ liệu vào template_event để thực hiện POST
    ${template_str}    Get File    ${template_event_dir}/template_event.txt
    ${data}    Format String    ${template_str}    ${template_input_dict}
    KV Log    ${data}
    ${id_branch}    Convert To String    ${id_branch}
    ${header}    Create Dictionary    Authorization=${bearertoken}    BranchId=${id_branch}    Retailer=${RETAILER}    Content-Type=application/json
    ${res}    Post Request    event_sync    /sync    data=${data}    headers=${header}
    KV Log    ${res.request.body}
    KV Log    ${res.json()}
    KV Log    ${res.status_code}
    Should Be Equal As Strings    ${res.status_code}    200    Lỗi response status code expected và actual khác nhau
    ${val_status}    Get Value From Json    ${res.json()}    $.status
    ${status}    Set Variable    ${val_status[0]}
    Should Be Equal As Strings    ${status}    1
    Set Suite Variable    ${version}    ${local_ver}
    sleep    1s

Event Android Call From Template
    [Arguments]    ${template_input_dict}    ${id_branch}=${BRANCH_ID}
    # Set các giá trị replica_id, remote_ver, local_ver
    Set Test Variable    ${remote_ver}    ${version}
    Set To Dictionary    ${template_input_dict}    replica_id    ${replica_id}
    Set To Dictionary    ${template_input_dict}    remote_ver    ${remote_ver}
    Set To Dictionary    ${template_input_dict}    local_ver     ${local_ver}
    # Kiểm tra có tồn tại secondary_event ? Nếu không thì add key secondary_event vào dict với value = ${EMPTY}
    ${key_exist}    Run Keyword And Return Status    Dictionary Should Contain Key    ${template_input_dict}    secondary_event
    Run Keyword If    '${key_exist}'!='True'    Set To Dictionary    ${template_input_dict}    secondary_event    ${EMPTY}
    # Format toàn bộ dữ liệu vào template_event để thực hiện POST
    ${template_str}    Get File    ${template_event_dir}/event_android/template_android_event.txt
    ${data}    Format String    ${template_str}    ${template_input_dict}
    KV Log    ${data}
    ${id_branch}    Convert To String    ${id_branch}
    ${header}    Create Dictionary    Authorization=${bearertoken}    BranchId=${id_branch}    Retailer=${RETAILER}    Content-Type=application/json
    ${res}    Post Request    event_sync    /sync    data=${data}    headers=${header}
    KV Log    ${res.request.body}
    KV Log    ${res.json()}
    KV Log    ${res.status_code}
    Should Be Equal As Strings    ${res.status_code}    200    Lỗi response status code expected và actual khác nhau
    ${val_status}    Get Value From Json    ${res.json()}    $.status
    ${status}    Set Variable    ${val_status[0]}
    Should Be Equal As Strings    ${status}    1
    Set Suite Variable    ${version}    ${local_ver}
    sleep    1s
