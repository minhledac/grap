*** Settings ***
Library           BuiltIn
Resource           ../../api_access.robot
Resource           ../../GET/chi-nhanh/api_chi_nhanh.robot
Resource           ../../../../config/envi.robot

*** Keywords ***
Them moi chi nhanh
    [Arguments]    ${ten_chi_nhanh}    ${sdt_cn}    ${email_cn}    ${dia_chi_cn}    ${location_id}=0
    ${id_chi_nhanh}    Get branch id by name    ${ten_chi_nhanh}
    ${jsonpath_id}    Set Variable    $.Id
    ${input_dict}    Create Dictionary    ten_chi_nhanh=${ten_chi_nhanh}    sdt_cn=${sdt_cn}    email_cn=${email_cn}    dia_chi_cn=${dia_chi_cn}    location_id=${location_id}
    ${dict_id}      Run Keyword If    ${id_chi_nhanh} == 0    API Call From Template    /chi-nhanh/add_chi_nhanh.txt    ${input_dict}    ${jsonpath_id}
    ${result_id}    Run Keyword If    ${id_chi_nhanh} == 0    Set Variable Return From Dict    ${dict_id.Id[0]}    ELSE    Set Variable    ${id_chi_nhanh}
    Return From Keyword    ${result_id}

Them moi list chi nhanh
    [Arguments]    @{list_data}
    FOR    ${item_data}     IN    @{list_data}
        Them moi chi nhanh    @{item_data}
    END

Delete chi nhanh
    [Arguments]    ${id_chi_nhanh}
    ${input_dict}   Create Dictionary    id_chi_nhanh=${id_chi_nhanh}
    Run Keyword If    ${id_chi_nhanh} != 0    API Call From Template    /chi-nhanh/delete_chi_nhanh.txt    ${input_dict}    ELSE    KV Log    Chi nhanh khong ton tai

Delete list chi nhanh
    [Arguments]    ${list_id_chi_nhanh}
    FOR    ${id_chi_nhanh}    IN    @{list_id_chi_nhanh}
        Delete chi nhanh    ${id_chi_nhanh}
    END

Delete list ten chi nhanh
    [Arguments]    ${list_ten_chi_nhanh}
    ${list_id_chi_nhanh}    Get list branch id by index    ${list_ten_chi_nhanh}
    Delete list chi nhanh    ${list_id_chi_nhanh}
