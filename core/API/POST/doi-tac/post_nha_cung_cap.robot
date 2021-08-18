*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Library           BuiltIn
Resource           ../../api_access.robot
Resource          ../../../../config/envi.robot
Resource          ../../GET/doi-tac/api_nhacungcap.robot

*** Keywords ***
Them moi nha cung cap
    [Arguments]    ${ma_ncc}    ${ten_ncc}    ${sdt_ncc}    ${dia_chi}    ${list_nhom_ncc}=${EMPTY}
    ${id_ncc}    Get supplier id by code    ${ma_ncc}
    Return From Keyword If    ${id_ncc} != 0    ${id_ncc}
    ${retailer_id}    Get RetailerID
    ${type_group}    Evaluate    type($list_nhom_ncc).__name__
    ${list_group_id}    Run Keyword If    '${type_group}'=='list'    Get list supplier group id by list name    ${list_nhom_ncc}
    ${data_nhom_ncc}    Run Keyword If    '${type_group}'=='list'    KV Set Data Supplier Group    ${list_group_id}    ELSE    Set Variable    ${EMPTY}

    ${input_dict}    Create Dictionary    ma_ncc=${ma_ncc}    ten_ncc=${ten_ncc}    sdt_ncc=${sdt_ncc}    dia_chi=${dia_chi}    retailer_id=${retailer_id}    data_group=${data_nhom_ncc}
    # Set jsonpat id de get về id NCC sau khi tạo
    ${jsonpath_id}    Set Variable    $.Id
    ${result_id}       API Call From Template    /nha-cung-cap/add_nha_cung_cap.txt    ${input_dict}    ${jsonpath_id}
    Return From Keyword    ${result_id.Id[0]}

Them moi list nha cung cap
    [Arguments]    @{list_data}
    ${list_id_ncc}    Create List
    FOR    ${data}    IN    @{list_data}
        ${id_ncc}    Them moi nha cung cap    @{data}
        Append To List    ${list_id_ncc}    ${id_ncc}
    END
    Return From Keyword    ${list_id_ncc}

Delete nha cung cap
    [Arguments]    ${id_ncc}
    Run Keyword If    ${id_ncc} != 0    API Call From Template    /nha-cung-cap/delete_nha_cung_cap.txt    ${id_ncc}    ELSE    KV Log    Nha cung cap khong ton tai

Delete list nha cung cap
    [Arguments]   ${list_id_ncc}
    FOR    ${id_ncc}    IN    @{list_id_ncc}
        Delete nha cung cap    ${id_ncc}
    END

# ========= Nhóm NCC =================
Them moi nhom nha cung cap
    [Arguments]    ${ten_nhom_ncc}
    ${get_id}    Get supplier group id by name    ${ten_nhom_ncc}
    ${input_dict}    Create Dictionary    ten_nhom_ncc=${ten_nhom_ncc}
    ${result_id}    Run Keyword If    ${get_id}==0    API Call From Template    /nha-cung-cap/add_nhom_NCC.txt    ${input_dict}    $.Id    ELSE    Set Variable    ${get_id}
    ${result_id}    Run Keyword If    ${get_id}==0    Set Variable Return From Dict    ${result_id.Id[0]}    ELSE    Set Variable    ${get_id}
    Return From Keyword    ${result_id}

Them moi list nhom nha cung cap
    [Arguments]   ${list_data}
    ${list_id_group}    Create List
    FOR    ${data}    IN    @{list_data}
        ${id_group}   Them moi nhom nha cung cap    ${data}
        Append To List    ${list_id_group}    ${id_group}
    END
    Return From Keyword    ${list_id_group}

Delete nhom nha cung cap
    [Arguments]    ${id_group}
    ${input_dict}    Create Dictionary    id_group=${id_group}
    Run Keyword If    ${id_group} != 0    API Call From Template    /nha-cung-cap/delete_nhom_NCC.txt    ${input_dict}    ELSE    KV Log    Nhom nha cung cap khong ton tai

Delete list nhom nha cung cap
    [Arguments]   ${list_id_group}
    FOR    ${id_group}    IN    @{list_id_group}
        Delete nhom nha cung cap    ${id_group}
    END

#================== KV SET DATA ===============
KV Set Data Supplier Group
    [Arguments]    ${list_group_id}
    ${list_data}    Create List
    FOR    ${group_id}    IN    @{list_group_id}
        ${item_data}    Set Variable    {"GroupId": ${group_id}}
        Append To List    ${list_data}    ${item_data}
    END
    ${join_str}    Evaluate    ",".join($list_data)
    Return From Keyword    ${join_str}
