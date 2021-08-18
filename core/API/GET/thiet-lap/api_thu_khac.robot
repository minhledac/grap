*** Settings ***
Resource          ../../api_access.robot
Resource          ../../../share/utils.robot
Library           ../../../../custom-library/UtilityLibrary.py

*** Keywords ***
Get dict all surcharge frm API
    [Documentation]     is_active=All -> Tất cả      is_active=True -> Đang thu      is_active=False -> Ngừng thu
    [Arguments]    ${list_jsonpath}    ${branch_id}=${BRANCH_ID}    ${is_active}=All
    ${filter_status}    KV Get Filter Status Surcharge    ${is_active}
    ${input_dict}    Create Dictionary    branch_id=${branch_id}    filter_data=${filter_status}
    ${result_dict}    API Call From Template    /thiet-lap/get_all_surcharge.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get dict surcharge by keyword frm API
    [Documentation]     is_active=All -> Tất cả      is_active=True -> Đang thu      is_active=False -> Ngừng thu
    [Arguments]    ${surcharge_code}    ${list_jsonpath}    ${branch_id}=${BRANCH_ID}    ${is_active}=All
    ${filter_status}    KV Get Filter Status Surcharge    ${is_active}
    # (isActive+eq+true+and+substringof('${surcharge_code}',Code))
    ${filter_data}    Set Variable    substringof(%27${surcharge_code}%27%2CCode)
    ${filter_data}    Run Keyword If    '${is_active}'=='All'    Set Variable    ${filter_data}
    ...    ELSE    Set Variable    (${filter_data}+and+${filter_status})
    ${input_dict}    Create Dictionary    branch_id=${branch_id}    filter_data=${filter_data}
    ${result_dict}    API Call From Template    /thiet-lap/get_all_surcharge.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

# Filter theo status của giao dịch chuyen hang
KV Get Filter Status Surcharge
    [Arguments]    ${is_active}
    ${filter_status}    Run Keyword If    '${is_active}' =='True'    Set Variable    IsActive+eq+true
    ...    ELSE If    '${is_active}' =='False'    Set Variable    IsActive+eq+false
    ...    ELSE    Set Variable    ${EMPTY}
    Return From Keyword    ${filter_status}

Get list surcharge detail by list surcharge code
    [Arguments]    ${list_surcharge_code}
    ${dict_surcharge}    Get dict all surcharge frm API    $.Data[*].["Code","Id","Value","ValueRatio"]
    ${list_surcharge_id}   Create List
    ${list_value}      Create List
    FOR    ${item_code}    IN ZIP    ${list_surcharge_code}
        ${index}    Get Index From List    ${dict_surcharge.Code}    ${item_code}
        ${surcharge_id}    Set Variable Return From Dict    ${dict_surcharge.Id[${index}]}
        ${value}           Set Variable Return From Dict    ${dict_surcharge.Value[${index}]}
        ${value_ratio}     Set Variable Return From Dict    ${dict_surcharge.ValueRatio[${index}]}
        ${value}    Run Keyword If    '${value}'!='0'    Set Variable    ${value}
        ...    ELSE    Set Variable    ${value_ratio}
        Append To List    ${list_surcharge_id}    ${surcharge_id}
        Append To List    ${list_value}           ${value}
    END
    Return From Keyword    ${list_surcharge_id}    ${list_value}

Get surcharge id by surcharge code
    [Arguments]    ${surcharge_code}
    ${dict_surcharge}    Get dict surcharge by keyword frm API    ${surcharge_code}    $.Data[*].Id
    ${surcharge_id}    Set Variable Return From Dict    ${dict_surcharge.Id[0]}
    Return From Keyword    ${surcharge_id}

Get info thu khac by id
    [Arguments]    ${surcharge_id}
    ${list_jsonpath}    Create List    $.Data[?(@.Id\=\=${surcharge_id})].["CreatedBy","CreatedDate","ModifiedBy","ModifiedDate","Code","Name"]
    ${result_invoice_dict}     Get dict all surcharge frm API    ${list_jsonpath}
    KV Log   ${result_invoice_dict}
    ${Code}                 Set Variable     ${result_invoice_dict.Code[0]}
    ${Name}                 Set Variable     ${result_invoice_dict.Name[0]}
    ${CreatedBy}            Set Variable     ${result_invoice_dict.CreatedBy[0]}
    ${CreatedDate}          Set Variable     ${result_invoice_dict.CreatedDate[0]}
    ${ModifiedBy}           Set Variable     ${result_invoice_dict.ModifiedBy[0]}
    ${ModifiedDate}         Set Variable     ${result_invoice_dict.ModifiedDate[0]}
    Return From Keyword    ${CreatedBy}    ${CreatedDate}    ${ModifiedBy}    ${ModifiedDate}    ${Name}    ${Code}

Get name va gia tri thu khac by code
    [Arguments]    ${surcharge_code}
    ${list_jsonpath}    Create List    $.Data[?(@.Code\=\=${surcharge_code})].["Name","ValueRatio","Value"]
    ${result_invoice_dict}     Get dict all surcharge frm API    ${list_jsonpath}
    ${Name}     Set Variable     ${result_invoice_dict.Name[0]}
    ${valueRatio}     Set Variable     ${result_invoice_dict.ValueRatio[0]}
    ${value}     Set Variable     ${result_invoice_dict.Value[0]}
    ${giatri}    Run Keyword If    "${valueRatio}"=="0"    Set Variable    ${value}    ELSE    Set Variable    ${valueRatio}
    ${loai_giatri}    Run Keyword If    "${valueRatio}"=="0"    Set Variable    VND    ELSE    Set Variable    %
    Return From Keyword    ${name}    ${giatri}    ${loai_giatri}

Get list name va gia tri thu khac by code
    [Arguments]    ${list_surcharge_code}
    ${list_name}    Create List
    ${list_giatri}    Create List
    ${list_loai_giatri}    Create List
    FOR    ${surcharge_code}    IN ZIP    ${list_surcharge_code}
        ${name}    ${giatri}    ${loai_giatri}    Get name va gia tri thu khac by code    ${surcharge_code}
        Append To List      ${list_name}     ${name}
        Append To List      ${list_giatri}     ${giatri}
        Append To List      ${list_loai_giatri}     ${loai_giatri}
    END
    Return From Keyword    ${list_name}    ${list_giatri}    ${list_loai_giatri}

Get surcharge id va surcharge name by surcharge code
    [Arguments]    ${surcharge_code}
    ${dict_surcharge}    Get dict surcharge by keyword frm API    ${surcharge_code}    $.Data[*].["Id","Name"]
    ${surcharge_id}    Set Variable Return From Dict    ${dict_surcharge.Id[0]}
    ${surcharge_name}    Set Variable Return From Dict    ${dict_surcharge.Name[0]}
    Return From Keyword    ${surcharge_id}    ${surcharge_name}

Get list surcharge id va surcharge name by list surcharge code
    [Arguments]    ${list_surcharge_code}
    ${list_name}    Create List
    ${list_id}    Create List
    FOR     ${surcharge_code}    IN ZIP     ${list_surcharge_code}
        ${surcharge_id}    ${surcharge_name}    Get surcharge id va surcharge name by surcharge code    ${surcharge_code}
        Append To List      ${list_name}     ${surcharge_name}
        Append To List      ${list_id}     ${surcharge_id}
    END
    Return From Keyword    ${list_id}    ${list_name}
