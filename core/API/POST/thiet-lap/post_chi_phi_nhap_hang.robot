*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Library           BuiltIn
Resource          ../../api_access.robot
Resource          ../../../share/utils.robot
Resource          ../../../../config/envi.robot
Resource          ../../GET/thiet-lap/api_chi_phi_nhap_hang.robot

*** Keywords ***
Them moi chi phi nhap hang
    [Documentation]    loai_chi_phi=0 => Hinh thuc: Chi phi nhap hang
    ...                loai_chi_phi=1 => Hinh thuc: Chi phi nhap hang khac
    ...                discount_type: VND hoac %
    [Arguments]    ${ma_chi_phi}    ${ten_chi_phi}    ${loai_chi_phi}    ${discount_type}    ${gia_tri}    ${is_auto}=false    ${is_return_auto}=false
    ${id_cp}    Get id expenses by code    ${ma_chi_phi}
    ${retailer_id}    Get RetailerID
    ${data_discount}    KV Set Data Discount Type    ${discount_type}    ${gia_tri}
    ${is_return_auto}   Run Keyword If    ${loai_chi_phi} == 1    Set Variable    false    ELSE IF    ${loai_chi_phi} == 0    Set Variable    ${is_return_auto}
    ${input_dict}    Create Dictionary    ma_chi_phi=${ma_chi_phi}    ten_chi_phi=${ten_chi_phi}    loai_chi_phi=${loai_chi_phi}    data_discount=${data_discount}
    ...    retailer_id=${retailer_id}    is_auto=${is_auto}    is_return_auto=${is_return_auto}
    Run Keyword If    ${id_cp} == 0    API Call From Template    /chi-phi-nhap-hang/add_CP_nhap_hang.txt    ${input_dict}

Them moi list chi phi nhap
    [Arguments]    @{list_data}
    FOR    ${data}    IN    @{list_data}
        Them moi chi phi nhap hang    @{data}
    END

Delete chi phi nhap hang
    [Arguments]    ${ma_chi_phi}
    ${expenses_id}    Get id expenses by code    ${ma_chi_phi}
    ${input_dict}    Create Dictionary    id=${expenses_id}
    API Call From Template    /chi-phi-nhap-hang/delete_CP_nhap_hang.txt    ${input_dict}
