*** Settings ***
Resource          ../../api_access.robot
Resource          ../hang-hoa/api_danhmuc_hanghoa.robot
Library           String
Library           Collections

*** Keywords ***
# Lấy danh sách all chi phí nhập hàng: Tát cả hình thức + Tất cả trạng thái
Get dict all chi phi nhap hang
    [Arguments]    ${list_jsonpath}    ${so_ban_ghi}=${EMPTY}
    ${find_dict}    Create Dictionary    so_ban_ghi=${so_ban_ghi}
    ${result_dict}    API Call From Template    /chi-phi-nhap-hang/all_chi_phi_nhap_hang.txt    ${find_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get list id and expensesOther value by list code
    [Arguments]    ${list_ma_chi_phi}
    ${type_input}=    Evaluate    type($list_ma_chi_phi).__name__
    ${result_dict}     Get dict all chi phi nhap hang    $.Data[*].["Code","Id","ValueRatio","Value"]
    ${list_valueRatio}    Set Variable Return From Dict    ${result_dict.ValueRatio}
    ${list_value}    Set Variable Return From Dict    ${result_dict.Value}
    ${list_id}    Set Variable Return From Dict    ${result_dict.Id}
    ${list_all_code_exp}    Set Variable Return From Dict    ${result_dict.Code}
    ${result_list_id}    ${result_list_value}    ${result_list_type}    Run Keyword If    '${type_input}' == 'list'    Set list info of expenses    ${list_ma_chi_phi}    ${list_id}    ${list_all_code_exp}    ${list_valueRatio}    ${list_value}
    ...    ELSE    Set Variable    ${EMPTY}    ${EMPTY}    ${EMPTY}
    Return From Keyword    ${result_list_id}    ${result_list_value}    ${result_list_type}

Set list info of expenses
    [Arguments]    ${list_ma_chi_phi}    ${list_id}    ${list_all_code_exp}    ${list_valueRatio}    ${list_value}
    ${result_list_type}    Create List
    ${result_list_value}    Create List
    ${result_list_id}    Create List
    FOR    ${item_ma}    IN ZIP    ${list_ma_chi_phi}
        ${index}    Get Index From List    ${list_all_code_exp}    ${item_ma}
        ${found}    Evaluate    ${index}>-1
        Should Be True    ${found}
        ${result_value}    Set Variable If    ${list_valueRatio[${index}]} != 0    ${list_valueRatio[${index}]}    ${list_value[${index}]}
        ${result_type}    Set Variable If    ${list_valueRatio[${index}]} != 0    ValueRatio    Value
        Append To List    ${result_list_value}    ${result_value}
        Append To List    ${result_list_type}    ${result_type}
        KV Log    ${list_id[${index}]}
        Append To List    ${result_list_id}    ${list_id[${index}]}
    END
    Return From Keyword    ${result_list_id}    ${result_list_value}    ${result_list_type}

Get id expenses by code
    [Arguments]    ${expenses_code}
    ${result_dict}     Get dict all chi phi nhap hang    $.Data[?(@.Code\=\="${expenses_code}")].["Id"]
    ${expenses_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${expenses_id}

Get list expense id by list code
    [Arguments]    ${list_expense_code}
    ${result_dict}     Get dict all chi phi nhap hang    $.Data[*].["Code","Id"]
    ${list_all_code}    Set Variable Return From Dict    ${result_dict.Code}
    ${list_all_id}    Set Variable Return From Dict    ${result_dict.Id}
    ${result_list_id}    Create List
    FOR    ${expenses_code}   IN    @{list_expense_code}
        ${index}    Get Index From List    ${list_all_code}    ${expenses_code}
        ${item_id}    Set Variable    ${list_all_id[${index}]}
        Append To List    ${result_list_id}    ${item_id}
    END
    Return From Keyword    ${result_list_id}

Get list expense name by list code
    [Arguments]    ${list_expense_code}
    ${result_dict}     Get dict all chi phi nhap hang    $.Data[*].["Code","Name"]
    ${list_all_code}    Set Variable Return From Dict    ${result_dict.Code}
    ${list_all_name}    Set Variable Return From Dict    ${result_dict.Name}
    ${result_list_name}    Create List
    FOR    ${expenses_code}   IN    @{list_expense_code}
        ${index}    Get Index From List    ${list_all_code}    ${expenses_code}
        ${item_name}    Set Variable    ${list_all_name[${index}]}
        Append To List    ${result_list_name}    ${item_name}
    END
    Return From Keyword    ${result_list_name}
