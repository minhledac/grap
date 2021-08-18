*** Settings ***
Library            BuiltIn
Library            Collections
Resource           ../../api_access.robot
Resource           ../../GET/thiet-lap/api_thu_khac.robot
Resource           ../../../../config/envi.robot
Resource           ../../../share/utils.robot
Resource           ../../../share/list_dictionary.robot

*** Keywords ***
Bat Tat thiet lap nhan goi mon khi het ton kho
    [Documentation]   Thiết lập cho phép gọi món khi hết tồn kho (chon true or false)
    [Arguments]    ${AllowOrderWhenOutStock}
    ${input_dict}   Create Dictionary   AllowOrderWhenOutStock=${AllowOrderWhenOutStock}
    API Call From Template   thiet-lap/nhan_goi_mon_het_ton_kho.txt   ${input_dict}
