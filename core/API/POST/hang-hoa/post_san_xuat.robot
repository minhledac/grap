*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Library           BuiltIn
Library           JSONLibrary
Library           DateTime
Resource          ../../api_access.robot
Resource          ../../../share/list_dictionary.robot
Resource          ../../../../config/envi.robot
Resource          ../../GET/hang-hoa/api_danhmuc_hanghoa.robot
Resource          ../../GET/hang-hoa/api_sanxuat_hanghoa.robot
Resource          post_hang_hoa.robot
Resource          ../../../share/utils.robot

*** Keywords ***
Them moi phieu san xuat
    [Arguments]    ${ma_phieu_sx}    ${ma_hh}    ${thoi_gian_sx}    ${so_luong_sx}    ${ghi_chu}    ${trangthai_phieu}=${0}
    ${product_id}    Get product unit id frm API    ${ma_hh}
    ${list_materialCode}    ${list_quantity}    Get list materialCode and quantity of product by code    ${ma_hh}
    ${thoigian_sx}=    Convert Date    ${thoi_gian_sx}    date_format=%d/%m/%Y %H:%M    exclude_millis=True
    ${input_dict}    Create Dictionary    ma_phieu_sx=${ma_phieu_sx}    product_id=${product_id}    thoigian_sx=${thoigian_sx}
    ...    so_luong_sx=${so_luong_sx}    ghi_chu=${ghi_chu}    trangthai_phieu=${trangthai_phieu}
    Run Keyword If    '${list_materialCode[0]}' !='0'   API Call From Template    /san-xuat/tao_phieu_sx.txt    ${input_dict}
    ...    ELSE    KV Log    Hang hoa chua duoc thiet lap nguyen lieu

Huy bo phieu san xuat
    [Arguments]    ${ma_phieu_sx}
    ${id_phieu_sx}    Get id manufacturing note by code    ${ma_phieu_sx}
    ${input_dict}    Create Dictionary    id_phieu_sx=${id_phieu_sx}
    Run Keyword If    ${id_phieu_sx} !=0    API Call From Template    /san-xuat/huy_phieu_sx.txt    ${input_dict}
    ...    ELSE    KV Log    Phieu san xuat khong ton tai
