*** Settings ***
Resource          ../../api_access.robot
Resource          ../../../share/utils.robot
Library           ../../../../custom-library/UtilityLibrary.py

*** Keywords ***
Get dict all users frm API
    [Documentation]     is_active=All -> Tất cả      is_active=True -> Đang hoạt động      is_active=False -> Ngừng hoạt động
    [Arguments]    ${list_jsonpath}    ${is_active}=All    ${is_ExcludeMe}=True
    ${filter_status}    KV Get Filter Status Users    ${is_active}
    ${input_dict}    Create Dictionary    filter_data=${filter_status}    is_ExcludeMe=${is_ExcludeMe}
    ${result_dict}    API Call From Template    /thiet-lap/get_all_users.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get dict user by keyword frm API
    [Documentation]     is_active=All -> Tất cả      is_active=True -> Đang hoạt động      is_active=False -> Ngừng hoạt động
    [Arguments]    ${user_name}    ${list_jsonpath}    ${is_active}=All    ${is_ExcludeMe}=True
    ${filter_status}    KV Get Filter Status Users    ${is_active}
    ${encode_str}    URL Encoding Query String    ${user_name}
    # (substringof('${encode_str}',UserName)+or+substringof('${encode_str}',GivenName))
    ${filter_data}    Set Variable    (substringof(%27${encode_str}%27%2CUserName)+or+substringof(%27${encode_str}%27%2CGivenName))
    ${filter_data}    Run Keyword If    '${is_active}'=='All'    Set Variable    ${filter_data}
    ...    ELSE    Set Variable    (${filter_data}+and+${filter_status})
    ${input_dict}    Create Dictionary    filter_data=${filter_data}    is_ExcludeMe=${is_ExcludeMe}
    ${result_dict}    API Call From Template    /thiet-lap/get_all_users.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

# Filter theo status của giao dịch chuyen hang
KV Get Filter Status Users
    [Arguments]    ${is_active}
    ${filter_status}    Run Keyword If    '${is_active}' =='True'    Set Variable    IsActive+eq+true
    ...    ELSE If    '${is_active}' =='False'    Set Variable    IsActive+eq+false
    ...    ELSE    Set Variable    ${EMPTY}
    Return From Keyword    ${filter_status}

Get user id by user name
    [Arguments]    ${user_name}
    ${result_user}    Get dict user by keyword frm API    ${user_name}    $.Data[*].Id    is_ExcludeMe=False
    ${user_id}    Set Variable Return From Dict    ${result_user.Id[0]}
    Return From Keyword    ${user_id}

Get list user id by list username
    [Arguments]    ${list_user_name}
    ${result_dict}    Get dict all users frm API    $.Data[*].["Id","UserName"]
    ${list_user_id}    Create List
    FOR    ${user_name}    IN ZIP    ${list_user_name}
        ${index}    Get Index From List    ${result_dict.UserName}    ${user_name}
        Append To list    ${list_user_id}    ${result_dict.Id[${index}]}
    END
    Return From Keyword    ${list_user_id}

# hanh
Get user name by user login
    [Arguments]    ${user_login}
    ${result_user}    Get dict user by keyword frm API    ${user_name}    $.Data[*].CompareGivenName    is_ExcludeMe=False
    ${user_name}    Set Variable Return From Dict    ${result_user.CompareGivenName[0]}
    Return From Keyword    ${user_name}
