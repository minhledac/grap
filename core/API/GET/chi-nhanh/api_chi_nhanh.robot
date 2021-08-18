*** Settings ***
Resource          ../../api_access.robot
Library           Collections

*** Keywords ***
Get dict all branch info frm API
    [Arguments]   ${list_jsonpath}    ${so_ban_ghi}=${EMPTY}
    ${input_dict}    Create Dictionary    so_ban_ghi=${so_ban_ghi}
    ${result_dict}    API Call From Template    /chi-nhanh/get_all_chi_nhanh.txt    ${input_dict}   ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get all branch name
    ${result_dict}    Get dict all branch info frm API    $.Data[*].Name
    ${list_branch_name}    Set Variable Return From Dict    ${result_dict.Name}
    Return From Keyword    ${list_branch_name}

Get branch id by name
    [Arguments]    ${branch_name}
    ${result_dict}    Get dict all branch info frm API    $.Data[?(@.Name\=\="${branch_name}")].Id
    ${branch_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${branch_id}

Get list all branch id
    ${result_dict}    Get dict all branch info frm API    $.Data[*].Id
    ${list_branch_id}    Set Variable Return From Dict    ${result_dict.Id}
    Return From Keyword    ${list_branch_id}

Get branch name by id and total branch
    [Arguments]    ${branch_id}
    ${list_jsonpath}    Create List    $.Total    $.Data[?(@.Id\=\=${branch_id})].Name
    ${result_dict}    Get dict all branch info frm API    ${list_jsonpath}
    ${branch_name}    Set Variable Return From Dict    ${result_dict.Name[0]}
    ${total_branch}    Set Variable Return From Dict    ${result_dict.Total[0]}
    Return From Keyword    ${branch_name}   ${total_branch}

Get list branch id by index
    [Arguments]    ${list_branch_name}
    ${dict_branch}    Get dict all branch info frm API    $.Data[*].["Id","Name"]
    ${list_branch_id}    Create List
    FOR    ${item_branchname}    IN ZIP    ${list_branch_name}
        ${index}    Get Index From List    ${dict_branch.Name}    ${item_branchname}
        ${branch_id}    Set Variable Return From Dict    ${dict_branch.Id[${index}]}
        Append To List    ${list_branch_id}    ${branch_id}
    END
    Return From Keyword    ${list_branch_id}

Get branch status by name
    [Arguments]    ${branch_name}
    ${result_dict}    Get dict all branch info frm API    $.Data[?(@.Name\=\="${branch_name}")].LimitAccess
    ${branch_is_active}    Set Variable Return From Dict    ${result_dict.LimitAccess[0]}
    ${branch_status}    Run Keyword If    '${branch_is_active}'=='True'    Set Variable    Đang hoạt động
    ...    ELSE    Set Variable    Ngừng hoạt động
    Return From Keyword    ${branch_status}
