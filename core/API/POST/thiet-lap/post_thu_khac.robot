*** Settings ***
Library            BuiltIn
Library            Collections
Resource           ../../api_access.robot
Resource           ../../GET/thiet-lap/api_thu_khac.robot
Resource           ../../../../config/envi.robot
Resource           ../../../share/utils.robot
Resource           ../../../share/list_dictionary.robot

*** Keywords ***
Them moi loai thu khac
    [Documentation]    surcharge_type: VND hoac %
    [Arguments]    ${ma_loai_thu}    ${ten_loai_thu}    ${surcharge_type}    ${gia_tri}    ${list_chi_nhanh}=${EMPTY}    ${thu_tu}=${EMPTY}    ${is_auto}=false    ${is_return_auto}=false
    ${id_thu_khac}    Get surcharge id by surcharge code    ${ma_loai_thu}
    ${jsonpath_id}    Set Variable    $.Data[*].Id
    ${data_surcharge}    KV Set Data Discount Type    ${surcharge_type}    ${gia_tri}
    ${order}    Run Keyword If    '${thu_tu}'!='${EMPTY}'    Set Variable    "Order":"${thu_tu}",    ELSE    Set Variable    ${EMPTY}
    ${for_all_branch}    ${surcharge_branches}    KV Set Data Surcharge Branches    ${list_chi_nhanh}
    ${input_dict}    Create Dictionary    surcharge_code=${ma_loai_thu}    surcharge_name=${ten_loai_thu}    data_surcharge=${data_surcharge}    order=${order}
    ...    surcharge_branches=${surcharge_branches}    for_all_branch=${for_all_branch}    retailer_id=${RETAILER_ID}    is_auto=${is_auto}    is_return_auto=${is_return_auto}
    ${dict_id}      Run Keyword If    ${id_thu_khac} == 0    API Call From Template    /thiet-lap/add_surcharge.txt    ${input_dict}    ${jsonpath_id}
    ${result_id}    Run Keyword If    ${id_thu_khac} == 0    Set Variable Return From Dict    ${dict_id.Id[0]}    ELSE    Set Variable    ${id_thu_khac}
    Return From Keyword    ${result_id}

Them moi list loai thu khac
    [Arguments]    @{list_data}
    ${list_id_thu_khac}    Create List
    FOR    ${data}    IN    @{list_data}
        ${id_thu_khac}    Them moi loai thu khac    @{data}
        Append To List    ${list_id_thu_khac}    ${id_thu_khac}
    END
    Return From Keyword    ${list_id_thu_khac}

Update thong tin thu khac
    [Documentation]    surcharge_type: VND hoac %
    [Arguments]    ${surcharge_type}    ${gia_tri}     ${code_old}    ${name_old}   ${code_new}=${EMPTY}    ${name_new}=${EMPTY}    ${list_branch}=${EMPTY}    ${is_auto}=false    ${is_return_auto}=false
    ${id_thu_khac}    Get surcharge id by surcharge code    ${code_old}

    ${data_surcharge}    KV Set Data Discount Type    ${surcharge_type}    ${gia_tri}
    ${for_all_branch}    ${surcharge_branches}    KV Set Data Surcharge Branches    ${list_branch}
    ${CreatedBy}    ${CreatedDate}    ${ModifiedBy}    ${ModifiedDate}   ${Name}    ${Code}     Get info thu khac by id    ${id_thu_khac}

    ${name}     Set Variable If    "${name_new}"=="${EMPTY}"    ${name_old}    ELSE    Set variable    ${name_new}
    ${code}     Set Variable If    "${code_new}"=="${EMPTY}"    ${code_old}    ELSE    Set variable    ${code_new}

    ${input_dict}    Create Dictionary    id=${id_thu_khac}    code=${code}    name=${name}    data_surcharge=${data_surcharge}
    ...    surcharge_branches=${surcharge_branches}    for_all_branch=${for_all_branch}    retailer_id=${RETAILER_ID}    isAuto=${is_auto}    isReturnAuto=${is_return_auto}
    ...    createdDate=${CreatedDate}    createdBy=${CreatedBy}    modifiedDate=${ModifiedDate}    modifiedBy=${ModifiedBy}

    API Call From Template    /thiet-lap/edit_surcharge.txt    ${input_dict}

# ============== KW Set Data ===============
KV Set Data Surcharge Branches
    [Arguments]    ${list_chi_nhanh}
    ${type_list_chi_nhanh}    Evaluate    type($list_chi_nhanh).__name__
    ${for_all_branch}      Run Keyword If    '${type_list_chi_nhanh}'!='list'    Set Variable    true    ELSE    Set Variable    false
    ${str_surcharge_branches}    Set Variable    ${EMPTY}
    Return From Keyword If    '${type_list_chi_nhanh}'!='list'    ${for_all_branch}    ${str_surcharge_branches}
    ${list_str_data}    Create List
    FOR    ${item_chi_nhanh}    IN ZIP    ${list_chi_nhanh}
          Append To List    ${list_str_data}    {"BranchId":${item_chi_nhanh}}
    END
    ${str_surcharge_branches}    Convert List to String    ${list_str_data}
    Log    ${str_surcharge_branches}
    Return From Keyword    ${for_all_branch}    ${str_surcharge_branches}
