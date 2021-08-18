*** Settings ***
Library           SeleniumLibrary
Library           String
Library           BuiltIn
Library           Collections
Resource           ../../api_access.robot
Resource          ../../../../config/envi.robot
Resource          ../../../share/utils.robot
Resource          ../../../API/GET/giao-dich/api_hoadon.robot

*** Keywords ***
Them moi kenh ban frm API
    [Documentation]    is_active=1     => trang thai kich hoat
    ...                is_active=false => trang thai ngung hoat dong
    [Arguments]    ${SaleChannel_name}    ${SaleChannel_des}   ${is_active}=1
    ${find_id}    Get sale channel id by name    ${SaleChannel_name}
    Return From Keyword If    ${find_id}!=0    ${find_id}
    ${input_dict}    Create Dictionary    SaleChannel_name=${SaleChannel_name}    SaleChannel_des=${SaleChannel_des}    is_active=${is_active}
    ${result_dict}    API Call From Template    /kenh-ban/add_kenh_ban.txt    ${input_dict}    $.SaleChannel.Id
    ${result_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${result_id}
    
Them moi list kenh ban
    [Arguments]    @{list_data}
    FOR    ${data}    IN ZIP    ${list_data}
        Them moi kenh ban frm API    @{data}
    END

Delete kenh ban
    [Arguments]    ${SaleChannel_id}
    ${input_dict}    Create Dictionary    SaleChannel_id=${SaleChannel_id}
    API Call From Template    /kenh-ban/delete_kenh_ban.txt    ${input_dict}
