*** Settings ***
Library            BuiltIn
Library            Collections
Resource           ../../api_access.robot
Resource           ../../GET/phong-ban/api_phong_ban.robot
Resource           ../../../../config/envi.robot

*** Keywords ***
Them moi phong ban
    [Arguments]    ${ten_ban}   ${nhom_ban}=${EMPTY}    ${branch_id}=${BRANCH_ID}
    ${id_nhom_ban}    Run Keyword If     '${nhom_ban}'!='${EMPTY}'    Get table group id by group name    ${nhom_ban}
    ...    ELSE    Set Variable    ${0}
    ${id_ban}    Get table id by name    ${ten_ban}    ${branch_id}
    ${jsonpath_id}    Set Variable    $.Data[*].Id
    ${input_dict}   Create Dictionary    ten_ban=${ten_ban}    id_nhom_ban=${id_nhom_ban}
    ${dict_id}      Run Keyword If    ${id_ban} == 0    API Call From Template    /phong-ban/add_phong_ban.txt    ${input_dict}    ${jsonpath_id}    input_branch_id=${branch_id}
    ${result_id}    Run Keyword If    ${id_ban} == 0    Set Variable Return From Dict    ${dict_id.Id[0]}    ELSE    Set Variable    ${id_ban}
    Return From Keyword    ${result_id}

Them moi list phong ban
    [Arguments]    @{list_data}
    ${list_id_phong_ban}    Create List
    FOR    ${data}    IN    @{list_data}
        ${id_phong_ban}    Them moi phong ban    @{data}
        Append To List    ${list_id_phong_ban}    ${id_phong_ban}
    END
    Return From Keyword    ${list_id_phong_ban}

Delete phong ban
    [Arguments]    ${id_ban}
    ${input_dict}   Create Dictionary    id_ban=${id_ban}
    Run Keyword If    ${id_ban} != 0    API Call From Template    /phong-ban/delete_phong_ban.txt    ${input_dict}    ELSE    KV Log    Phong ban khong ton tai

Delete list phong ban
    [Arguments]    ${list_id_ban}
    FOR    ${id_ban}    IN    @{list_id_ban}
        Delete phong ban    ${id_ban}
    END

Delete list ten phong ban
    [Arguments]    ${list_ten_ban}
    ${list_id_ban}    Get list table id by index    ${list_ten_ban}
    Delete list phong ban    ${list_id_ban}

Them moi nhom phong ban
    [Arguments]    ${ten_nhom_ban}
    ${id_nhom_ban}    Get table group id by group name    ${ten_nhom_ban}
    ${jsonpath_id}    Set Variable    $.Data[*].Id
    ${input_dict}   Create Dictionary    ten_nhom_ban=${ten_nhom_ban}
    ${dict_id}      Run Keyword If    ${id_nhom_ban} == 0    API Call From Template    /phong-ban/add_nhom_phongban.txt    ${input_dict}    ${jsonpath_id}
    ${result_id}    Run Keyword If    ${id_nhom_ban} == 0    Set Variable Return From Dict    ${dict_id.Id[0]}    ELSE    Set Variable    ${id_nhom_ban}
    Return From Keyword    ${result_id}

Them moi list nhom phong ban
    [Arguments]    @{list_data}
    ${list_id_nhom_ban}    Create List
    FOR    ${data}    IN    @{list_data}
        ${id_nhom_ban}    Them moi nhom phong ban    @{data}
        Append To List    ${list_id_nhom_ban}    ${id_nhom_ban}
    END
    Return From Keyword    ${list_id_nhom_ban}

Delete nhom phong ban
    [Arguments]    ${id_nhom_ban}
    ${input_dict}   Create Dictionary    id_nhom_ban=${id_nhom_ban}
    Run Keyword If    ${id_nhom_ban} != 0    API Call From Template    /phong-ban/delete_nhom_phongban.txt    ${input_dict}    ELSE    KV Log    Nhom phong ban khong ton tai

Delete list nhom phong ban
    [Arguments]    ${list_id_nhom_ban}
    FOR    ${id_nhom_ban}    IN    @{list_id_nhom_ban}
        Delete phong ban    ${id_nhom_ban}
    END
