*** Settings ***
Resource          ../../api_access.robot
Resource          ../../../share/utils.robot
Library           ../../../../custom-library/UtilityLibrary.py

*** Keywords ***
Get dict all promotion frm API
    [Arguments]    ${list_jsonpath}    ${branch_id}=${BRANCH_ID}
    ${input_dict}    Create Dictionary    branch_id=${branch_id}
    ${result_dict}    API Call From Template    /khuyen-mai/all_khuyen_mai.txt    ${input_dict}    ${list_jsonpath}    session_alias=session_kmapi
    Return From Keyword    ${result_dict}

Get promotion id by promotion code
    [Arguments]    ${promotion_code}
    ${dict_promotion}    Get dict all promotion frm API    $.Data[?(@.Code\=\="${promotion_code}")].Id
    ${promotion_id}    Set Variable Return From Dict    ${dict_promotion.Id[0]}
    Return From Keyword    ${promotion_id}
