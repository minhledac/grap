*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Library           BuiltIn
Resource           ../../api_access.robot
Resource           ../../../share/list_dictionary.robot
Resource          ../../../../config/envi.robot
Resource          ../../GET/hang-hoa/api_danhmuc_hanghoa.robot

*** Keywords ***
Them moi hang che bien
    [Arguments]    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${ten_nhom_hang}    ${gia_ban}    ${dict_hangtp}    ${dict_thuoc_tinh}=${EMPTY}
	  ...    ${is_topping}=false    ${list_product_code}=${EMPTY}
    ${find_id}    Get product unit id frm API    ${ma_hh}
    Return From Keyword If    ${find_id}!=0    HH da ton tai
    ${id_nhom_hang}    Get category ID by category name    ${ten_nhom_hang}
    ${list_ma_hangtp}    Set Variable    ${dict_hangtp.list_ma_hangtp}
    ${list_soluong_tp}   Set Variable    ${dict_hangtp.list_soluong_tp}
    # Kiểm tra type là dictionary
    ${type_dict_thuoc_tinh}=    Evaluate    type($dict_thuoc_tinh).__name__
    ${list_attr_id}    ${list_attr_value}    Run Keyword If    '${type_dict_thuoc_tinh}'=='DotDict'    Get list attribute id by name    ${dict_thuoc_tinh}
    ${list_product_id}    Get list product id frm API by index    ${list_ma_hangtp}
    # Set data attribute cần truyền vào
    ${data_thuoc_tinh}    Run Keyword If    '${type_dict_thuoc_tinh}'=='DotDict'   KV set data attribute    ${list_attr_id}    ${list_attr_value}
    ...    ELSE    Set Variable    ${EMPTY}
    ${data_hangtp}    KV set data formula    ${list_product_id}    ${list_soluong_tp}
    # Set data topping
    ${type_list_hh}    Evaluate    type($list_product_code).__name__
    ${data_topping}=    Run Keyword If    '${type_list_hh}' == 'list'    KV set data topping    ${list_product_code}    ${is_topping}    ELSE    Set Variable    ${EMPTY}

    ${input_dict}    KV Create Input Dict for Hang hoa    ${ten_hh}    ${loai_thuc_don}    ${id_nhom_hang}    ${gia_ban}    ma_hh=${ma_hh}
    ...    data_thuoc_tinh=${data_thuoc_tinh}    data_hangtp=${data_hangtp}    data_topping=${data_topping}    is_topping=${is_topping}
    API Call From Template    /hang-hoa/add_hang_chebien.txt    ${input_dict}

Them moi hang che bien cung loai
    [Arguments]    ${prefix_ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${ten_nhom_hang}    ${gia_ban}    ${dict_hangtp}    ${dict_thuoc_tinh}
    ...    ${unit_name}=${EMPTY}
    ${id_nhom_hang}    Get category ID by category name    ${ten_nhom_hang}
    ${list_ma_hangtp}     Set Variable    ${dict_hangtp.list_ma_hangtp}
    ${list_soluong_tp}    Set Variable    ${dict_hangtp.list_soluong_tp}
    ${list_product_id}    Get list product id frm API by index    ${list_ma_hangtp}
    ${data_hangtp}    KV set data formula    ${list_product_id}    ${list_soluong_tp}
    ${input_dict}     KV Create Input Dict for Hang hoa    ${ten_hh}    ${loai_thuc_don}    ${id_nhom_hang}    ${gia_ban}    data_hangtp=${data_hangtp}
    ${don_vi_coban}    Create Dictionary    unit_name=${unit_name}
    ${list_dict_donvitinh}    Create List    ${don_vi_coban}
    API Add Hang Hoa Cung Loai From Template    hang-hoa/add_hang_chebien_cung_loai.txt    ${input_dict}    ${prefix_ma_hh}
    ...    ${dict_thuoc_tinh}    ${list_dict_donvitinh}

Them moi hang san xuat
    [Arguments]    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${ten_nhom_hang}    ${gia_ban}    ${dict_hangtp}    ${dict_thuoc_tinh}=${EMPTY}
    ${find_id}    Get product unit id frm API    ${ma_hh}
    Return From Keyword If    ${find_id}!=0    HH da ton tai
    ${id_nhom_hang}    Get category ID by category name    ${ten_nhom_hang}
    ${list_ma_hangtp}     Set Variable    ${dict_hangtp.list_ma_hangtp}
    ${list_soluong_tp}    Set Variable    ${dict_hangtp.list_soluong_tp}
    # Kiểm tra type là dictionary
    ${type_dict_thuoc_tinh}=    Evaluate    type($dict_thuoc_tinh).__name__
    ${list_attr_id}    ${list_attr_value}    Run Keyword If    '${type_dict_thuoc_tinh}'=='DotDict'    Get list attribute id by name    ${dict_thuoc_tinh}
    ${list_product_id}    Get list product id frm API by index    ${list_ma_hangtp}
    # Set data attribute cần truyền vào
    ${data_thuoc_tinh}    Run Keyword If    '${type_dict_thuoc_tinh}'=='DotDict'   KV set data attribute    ${list_attr_id}    ${list_attr_value}
    ...    ELSE    Set Variable    ${EMPTY}
    ${data_hangtp}    KV set data formula    ${list_product_id}    ${list_soluong_tp}

    ${input_dict}    KV Create Input Dict for Hang hoa    ${ten_hh}    ${loai_thuc_don}    ${id_nhom_hang}    ${gia_ban}    ma_hh=${ma_hh}
    ...    data_thuoc_tinh=${data_thuoc_tinh}    data_hangtp=${data_hangtp}
    API Call From Template    /hang-hoa/add_hang_sanxuat.txt    ${input_dict}    tao_hang_sx=True

Them moi hang san xuat cung loai
    [Arguments]    ${prefix_ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${ten_nhom_hang}    ${gia_ban}    ${dict_hangtp}    ${dict_thuoc_tinh}
    ...    ${list_dict_donvitinh}=${EMPTY}
    ${id_nhom_hang}    Get category ID by category name    ${ten_nhom_hang}
    ${list_ma_hangtp}    Set Variable    ${dict_hangtp.list_ma_hangtp}
    ${list_soluong_tp}    Set Variable    ${dict_hangtp.list_soluong_tp}

    ${list_product_id}    Get list product id frm API by index    ${list_ma_hangtp}
    ${data_hangtp}    KV set data formula    ${list_product_id}    ${list_soluong_tp}
    ${input_dict}    KV Create Input Dict for Hang hoa    ${ten_hh}    ${loai_thuc_don}    ${id_nhom_hang}    ${gia_ban}    data_hangtp=${data_hangtp}
    API Add Hang Hoa Cung Loai From Template    hang-hoa/add_hang_sanxuat_cung_loai.txt    ${input_dict}    ${prefix_ma_hh}
    ...    ${dict_thuoc_tinh}    ${list_dict_donvitinh}    tao_hang_sx=True

Them moi hang dich vu
    [Arguments]    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${ten_nhom_hang}    ${gia_ban}    ${gia_von}    ${dict_thuoc_tinh}=${EMPTY}
    ${find_id}    Get product unit id frm API    ${ma_hh}
    Return From Keyword If    ${find_id}!=0    HH da ton tai
    ${id_nhom_hang}    Get category ID by category name    ${ten_nhom_hang}
    # Kiểm tra type là dictionary
    ${type_dict_thuoc_tinh}=    Evaluate    type($dict_thuoc_tinh).__name__
    ${list_attr_id}    ${list_attr_value}    Run Keyword If    '${type_dict_thuoc_tinh}'=='DotDict'    Get list attribute id by name    ${dict_thuoc_tinh}

    # Set data attribute cần truyền vào
    ${data_thuoc_tinh}    Run Keyword If    '${type_dict_thuoc_tinh}'=='DotDict'   KV set data attribute    ${list_attr_id}    ${list_attr_value}
    ...    ELSE    Set Variable    ${EMPTY}

    ${input_dict}    KV Create Input Dict for Hang hoa    ${ten_hh}    ${loai_thuc_don}    ${id_nhom_hang}    ${gia_ban}    ${gia_von}
    ...    ma_hh=${ma_hh}    data_thuoc_tinh=${data_thuoc_tinh}
    API Call From Template    /hang-hoa/add_hang_dichvu.txt    ${input_dict}

Them moi hang dich vu cung loai
    [Arguments]    ${prefix_ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${ten_nhom_hang}    ${gia_ban}    ${gia_von}    ${dict_thuoc_tinh}
    ...    ${unit_name}=${EMPTY}
    ${id_nhom_hang}    Get category ID by category name    ${ten_nhom_hang}

    ${input_dict}    KV Create Input Dict for Hang hoa    ${ten_hh}    ${loai_thuc_don}    ${id_nhom_hang}    ${gia_ban}    ${gia_von}
    ${don_vi_coban}    Create Dictionary    unit_name=${unit_name}
    ${list_dict_donvitinh}    Create List    ${don_vi_coban}
    API Add Hang Hoa Cung Loai From Template    hang-hoa/add_hang_dichvu_cung_loai.txt    ${input_dict}    ${prefix_ma_hh}
    ...    ${dict_thuoc_tinh}    ${list_dict_donvitinh}

Them moi hang tinh gio
    [Arguments]    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${ten_nhom_hang}    ${gia_ban}    ${gia_von}    ${dict_thuoc_tinh}=${EMPTY}
    ${find_id}    Get product unit id frm API    ${ma_hh}
    Return From Keyword If    ${find_id}!=0    HH da ton tai
    ${id_nhom_hang}    Get category ID by category name    ${ten_nhom_hang}
    # Kiểm tra type là dictionary
    ${type_dict_thuoc_tinh}=    Evaluate    type($dict_thuoc_tinh).__name__
    ${list_attr_id}    ${list_attr_value}    Run Keyword If    '${type_dict_thuoc_tinh}'=='DotDict'    Get list attribute id by name    ${dict_thuoc_tinh}

    # Set data attribute cần truyền vào
    ${data_thuoc_tinh}    Run Keyword If    '${type_dict_thuoc_tinh}'=='DotDict'   KV set data attribute    ${list_attr_id}    ${list_attr_value}
    ...    ELSE    Set Variable    ${EMPTY}

    ${input_dict}    KV Create Input Dict for Hang hoa    ${ten_hh}    ${loai_thuc_don}    ${id_nhom_hang}    ${gia_ban}    ${gia_von}
    ...    ma_hh=${ma_hh}    data_thuoc_tinh=${data_thuoc_tinh}
    API Call From Template    /hang-hoa/add_hang_tinhgio.txt    ${input_dict}

Them moi hang tinh gio cung loai
    [Arguments]    ${prefix_ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${ten_nhom_hang}    ${gia_ban}    ${gia_von}    ${dict_thuoc_tinh}
    ...    ${unit_name}=${EMPTY}
    ${id_nhom_hang}    Get category ID by category name    ${ten_nhom_hang}
    ${input_dict}    KV Create Input Dict for Hang hoa    ${ten_hh}    ${loai_thuc_don}    ${id_nhom_hang}    ${gia_ban}    ${gia_von}
    ${don_vi_coban}    Create Dictionary    unit_name=${unit_name}
    ${list_dict_donvitinh}    Create List    ${don_vi_coban}
    API Add Hang Hoa Cung Loai From Template    hang-hoa/add_hang_tinhgio_cung_loai.txt    ${input_dict}    ${prefix_ma_hh}
    ...    ${dict_thuoc_tinh}    ${list_dict_donvitinh}

#Ngừng/Cho phép kinh doanh hàng hóa
Ngung kinh doanh hang hoa
    [Arguments]    ${ma_hh}
    ${product_id}    Get product unit id frm API    ${ma_hh}
    ${is_active}    Get IsActive of product by code    ${ma_hh}
    ${input_dict}    Create Dictionary    product_id=${product_id}
    Run Keyword If    ${is_active}==1    API Call From Template    /hang-hoa/active_hh.txt    ${input_dict}
    ...    ELSE    KV Log    Hang da co trang thai ngung kinh doanh

Cho phep kinh doanh hang hoa
    [Arguments]    ${ma_hh}
    ${product_id}    Get product unit id frm API    ${ma_hh}
    ${is_active}    Get IsActive of product by code    ${ma_hh}
    ${input_dict}    Create Dictionary    product_id=${product_id}
    Run Keyword If    ${is_active}==0    API Call From Template    /hang-hoa/active_hh.txt    ${input_dict}
    ...    ELSE    KV Log    Hang da co trang thai dang kinh doanh

Active list hang hoa
    [Arguments]    ${list_ma_hh}    ${status}
    ${list_id}    Get list product id frm API by index    ${list_ma_hh}
    ${length}    Get Length    ${list_ma_hh}
    ${list_data}    Create List
    FOR    ${index}    IN RANGE    ${length}
        Append To List    ${list_data}    {"Id": ${list_id[${index}]},"Code": ""}
    END
    ${join_str}    Evaluate    ",".join($list_data)
    ${input_dict}    Create Dictionary    data_id=${join_str}    status=${status}
    API Call From Template    /hang-hoa/active_nhieu_hh.txt    ${input_dict}

Get list attribute id by name
    [Arguments]    ${dict_attribute}
    ${list_attr_name}    Get Dictionary Keys    ${dict_attribute}
    ${list_attr_value}    Get Dictionary Values    ${dict_attribute}
    ${dict_all_attr}    Get dict attributes info    ${EMPTY}    $.Data[*].["Id","Name"]
    ${list_attr_id}    Create List
    FOR    ${item_attr_name}    IN    @{list_attr_name}
        ${item_attr_name}    Convert To Uppercase    ${item_attr_name}
        ${index}    Get Index From List    ${dict_all_attr.Name}    ${item_attr_name}
        ${found}    Evaluate    ${index}>-1
        Should Be True    ${found}
        ${item_id}    Set Variable    ${dict_all_attr.Id[${index}]}
        Append To List    ${list_attr_id}    ${item_id}
    END
    Return From Keyword    ${list_attr_id}    ${list_attr_value}

Them moi hang thuong
    [Arguments]    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${ten_nhom_hang}    ${gia_ban}    ${gia_von}    ${ton_kho}
    ...    ${dict_thuoc_tinh}=${EMPTY}     ${is_topping}=false    ${list_product_code}=${EMPTY}
    ${find_id}    Get product unit id frm API    ${ma_hh}
    Return From Keyword If    ${find_id}!=0    HH da ton tai
    ${id_nhom_hang}    Get category ID by category name    ${ten_nhom_hang}

    ${type_dict_thuoc_tinh}    Evaluate    type($dict_thuoc_tinh).__name__
    ${list_attr_id}    ${list_attr_value}    Run Keyword If    '${type_dict_thuoc_tinh}' == 'DotDict'    Get list attribute id by name    ${dict_thuoc_tinh}
    ${data_thuoc_tinh}=    Run Keyword If    '${type_dict_thuoc_tinh}' == 'DotDict'   KV set data attribute    ${list_attr_id}    ${list_attr_value}    ELSE    Set Variable    ${EMPTY}

    ${type_list_hh}    Evaluate    type($list_product_code).__name__
    ${data_topping}=    Run Keyword If    '${type_list_hh}' == 'list'    KV set data topping    ${list_product_code}    ${is_topping}    ELSE    Set Variable    ${EMPTY}

    ${input_dict}    KV Create Input Dict for Hang hoa    ${ten_hh}    ${loai_thuc_don}    ${id_nhom_hang}    ${gia_ban}    ${gia_von}    ${ton_kho}    ma_hh=${ma_hh}
    ...    data_thuoc_tinh=${data_thuoc_tinh}    data_topping=${data_topping}    is_topping=${is_topping}
    API Call From Template    /hang-hoa/add_hang_thuong.txt    ${input_dict}

Them moi hang thuong cung loai
    [Arguments]    ${prefix_ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${ten_nhom_hang}    ${gia_ban}    ${gia_von}    ${ton_kho}    ${dict_thuoc_tinh}
    ...    ${list_dict_donvitinh}=${EMPTY}
    ${id_nhom_hang}    Get category ID by category name    ${ten_nhom_hang}
    ${input_dict}    KV Create Input Dict for Hang hoa    ${ten_hh}    ${loai_thuc_don}    ${id_nhom_hang}    ${gia_ban}    ${gia_von}    ${ton_kho}
    # ${don_vi_coban}    Create Dictionary    unit_name=${unit_name}
    # ${list_dict_donvitinh}    Create List    ${don_vi_coban}
    ${json_path}    Set Variable    $..Data[*].["Id"]
    ${result_id}    API Add Hang Hoa Cung Loai From Template    hang-hoa/add_hang_thuong_cung_loai.txt    ${input_dict}    ${prefix_ma_hh}
    ...    ${dict_thuoc_tinh}    ${list_dict_donvitinh}    ${json_path}
    ${list_id}    Set Variable Return From Dict    ${result_id.Id}
    Return From Keyword    ${list_id}

Them moi hang thuong all field
    [Arguments]    ${prefix_ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${ten_nhom_hang}    ${gia_ban}    ${gia_von}    ${ton_kho}    ${list_vi_tri}    ${trong_luong}
    ...    ${mo_ta}    ${ghi_chu}    ${list_hinh_anh}    ${dict_thuoc_tinh}    ${list_dict_donvitinh}    ${tich_diem}=false    ${ban_truc_tiep}=true

    ${id_nhom_hang}    Get category ID by category name    ${ten_nhom_hang}
    #Lấy ra list id vị trí
    ${list_shelves_id}    Create List
    FOR    ${item_vi_tri}    IN    @{list_vi_tri}
        ${id_vi_tri}    Get shelves id by name    ${item_vi_tri}
        Append To List    ${list_shelves_id}    ${id_vi_tri}
    END
    ${data_vi_tri}    KV set data shelves    ${list_shelves_id}

    ${input_dict}    KV Create Input Dict for All Fields Product    ${ten_hh}    ${loai_thuc_don}    ${id_nhom_hang}    ${gia_ban}
    ...    ${data_vi_tri}    ${trong_luong}    ${mo_ta}    ${ghi_chu}    ${list_hinh_anh}    ${gia_von}    ${ton_kho}    ${tich_diem}    ${ban_truc_tiep}

    ${json_path}    Set Variable    $..Data[*].["Id"]
    ${result_id}    API Add Hang Hoa Cung Loai From Template    hang-hoa/add_hang_thuong_all_field.txt    ${input_dict}    ${prefix_ma_hh}
    ...    ${dict_thuoc_tinh}    ${list_dict_donvitinh}    ${json_path}

    ${list_id}    Set Variable Return From Dict    ${result_id.Id}
    Return From Keyword    ${list_id}

Them moi hang combo
    [Arguments]    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${ten_nhom_hang}    ${gia_ban}    ${dict_hangtp}    ${dict_thuoc_tinh}=${EMPTY}
    ${find_id}    Get product unit id frm API    ${ma_hh}
    Return From Keyword If    ${find_id}!=0    HH da ton tai
    ${list_ma_hangtp}     Set Variable    ${dict_hangtp.list_ma_hangtp}
    ${list_soluong_tp}    Set Variable    ${dict_hangtp.list_soluong_tp}
    ${list_product_id}    Get list product id frm API by index    ${list_ma_hangtp}
    ${data_formula}    KV set data formula    ${list_product_id}    ${list_soluong_tp}

    ${id_nhom_hang}    Get category ID by category name    ${ten_nhom_hang}
    ${type_dict_thuoc_tinh}    Evaluate    type($dict_thuoc_tinh).__name__
    ${list_attr_id}    ${list_attr_value}    Run Keyword If    '${type_dict_thuoc_tinh}' == 'DotDict'    Get list attribute id by name    ${dict_thuoc_tinh}
    ${data_thuoc_tinh}    Run Keyword If    '${type_dict_thuoc_tinh}' == 'DotDict'    KV set data attribute    ${list_attr_id}    ${list_attr_value}    ELSE    Set Variable    ${EMPTY}

    ${input_dict}    KV Create Input Dict for Hang hoa    ${ten_hh}    ${loai_thuc_don}    ${id_nhom_hang}    ${gia_ban}    ma_hh=${ma_hh}
    ...    data_thuoc_tinh=${data_thuoc_tinh}    data_hangtp=${data_formula}

    API Call From Template    /hang-hoa/add_hang_combo.txt    ${input_dict}

Them moi hang combo cung loai
    [Arguments]    ${prefix_ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${ten_nhom_hang}    ${gia_ban}    ${dict_hangtp}    ${dict_thuoc_tinh}
    ...    ${unit_name}=${EMPTY}
    ${id_nhom_hang}    Get category ID by category name    ${ten_nhom_hang}
    ${list_ma_hangtp}     Set Variable    ${dict_hangtp.list_ma_hangtp}
    ${list_soluong_tp}    Set Variable    ${dict_hangtp.list_soluong_tp}
    ${list_product_id}    Get list product id frm API by index    ${list_ma_hangtp}
    ${data_hangtp}    KV set data formula    ${list_product_id}    ${list_soluong_tp}
    ${input_dict}    KV Create Input Dict for Hang hoa    ${ten_hh}    ${loai_thuc_don}    ${id_nhom_hang}    ${gia_ban}    data_hangtp=${data_hangtp}
    ${don_vi_coban}    Create Dictionary    unit_name=${unit_name}
    ${list_dict_donvitinh}    Create List    ${don_vi_coban}
    ${json_path}    Set Variable    $..Data[*].["Id"]
    ${result_id}    API Add Hang Hoa Cung Loai From Template    hang-hoa/add_hang_combo_cung_loai.txt    ${input_dict}    ${prefix_ma_hh}
    ...    ${dict_thuoc_tinh}    ${list_dict_donvitinh}    ${json_path}
    ${list_id}    Set Variable Return From Dict    ${result_id.Id}
    Return From Keyword    ${list_id}

Them moi list hang thuong
    [Arguments]    @{list_data}
    FOR    ${item_data}     IN    @{list_data}
        Them moi hang thuong    @{item_data}
    END

Them moi list hang dich vu
    [Arguments]    @{list_data}
    FOR    ${item_data}     IN    @{list_data}
        Them moi hang dich vu    @{item_data}
    END

Them moi list hang san xuat
    [Arguments]    @{list_data}
    FOR    ${item_data}     IN    @{list_data}
        Them moi hang san xuat    @{item_data}
    END

Delete hang hoa
    [Arguments]    ${ma_hh}
    ${find_ids}    Get list product unit id frm API    ${ma_hh}
    Delete list hang hoa    ${find_ids}

Delete list hang hoa
    [Arguments]    ${list_id}
    Remove Values From List    ${list_id}    0    -1    ${0}    ${-1}
    ${length}    Get Length    ${list_id}
    ${join_str}    Catenate    SEPARATOR=,    @{list_id}
    Run Keyword If    ${length} == 1    API Call From Template    /hang-hoa/delete_hh.txt    ${join_str}
    ...    ELSE IF    ${length} > 1    API Call From Template    /hang-hoa/delete_nhieu_hh.txt    ${join_str}
    ...    ELSE    KV Log    Hang hoa khong ton tai

Delete hang hoa su dung nhom hang
    [Arguments]    ${ten_nhom_hang}
    ${list_id}    Get list Id of product by category    ${ten_nhom_hang}
    Delete list hang hoa    ${list_id}

Delete list Ma hang hoa
    [Arguments]    ${list_ma_hh}    ${check_found}=true
    ${find_ids}    Get list product id frm API by index    ${list_ma_hh}    ${check_found}
    Remove Values From List    ${find_ids}    0    -1
    ${length}    Get Length    ${find_ids}
    ${join_str}    Catenate    SEPARATOR=,    @{find_ids}
    Run Keyword If    ${length} > 1    API Call From Template    /hang-hoa/delete_nhieu_hh.txt    ${join_str}

# ======================= SET DATA ==============================
KV set data topping
    [Arguments]    ${list_product_code}    ${is_topping}
    ${list_product_id}    Get list product id frm API by index    ${list_product_code}
    ${list_data}    Create List
    ${length}    Get Length    ${list_product_id}
    FOR    ${index}    IN RANGE    ${length}
        Append To List    ${list_data}    {"ProductId": ${list_product_id[${index}]},"ProductName": "","ProductCode": "","BasePrice": 0,"isActive": true,"$$hashKey": ""}
    END
    ${join_str}    Convert List to String    ${list_data}
    ${data_topping}    Set Variable If    '${is_topping}' == 'true'    "ProductToppings": [${join_str}],    "ToppingsOfProduct": [${join_str}],
    Return From Keyword    ${data_topping}

KV set data attribute
    [Arguments]    ${list_attr_id}    ${list_attr_value}    ${list_unit_detail}=null
    ${length}    Get Length    ${list_attr_id}
    ${list_data}    Create List
    FOR   ${index}   IN RANGE    ${length}
        Append To List    ${list_data}    {"AttributeId": ${list_attr_id[${index}]},"ProductId": 0,"Value": "${list_attr_value[${index}]}"}
    END
    ${join_str}    Convert List to String    ${list_data}
    ${join_str_value}    Evaluate    "-".join($list_attr_value)
    ${data_attribute}    Set Variable    "ProductAttributes": [${join_str}],"FullName": "${join_str_value}","MasterCode": "${join_str_value}","ListUnitPriceBookDetail": ${list_unit_detail},
    KV Log    ${data_attribute}
    Return From Keyword    ${data_attribute}

KV set data don vi tinh
    [Arguments]    ${list_dict_don_vi_tinh}    ${start}    ${end}
    ${list_data}    Create List
    FOR   ${index}   IN RANGE    ${start}    ${end}
        ${don_vi}    Set Variable    ${list_dict_don_vi_tinh[${index}]}
        Append To List    ${list_data}    {"Id": 0,"Unit": "${don_vi.unit_name}","Code": "","ConversionValue": 1,"BasePrice": 0,"AllowsSale": true}
    END
    ${join_str}    Convert List to String    ${list_data}
    ${data_units}    Set Variable    "ProductUnits": [${join_str}],
    KV Log    ${data_units}
    Return From Keyword    ${data_units}

KV set data formula
    [Arguments]    ${list_material_id}    ${list_material_quantity}
    ${length}    Get Length    ${list_material_id}
    ${list_data}    Create List
    FOR   ${index}   IN RANGE    ${length}
        Append To List    ${list_data}    {"MaterialId": ${list_material_id[${index}]},"MaterialName": "","MaterialCode": "","Quantity": ${list_material_quantity[${index}]},"Cost": 0,"BasePrice": 0,"$$hashKey": ""}
    END
    ${join_str}    Convert List to String    ${list_data}
    ${data_formula}    Set Variable    "ProductFormulas": [${join_str}],
    KV Log    ${data_formula}
    Return From Keyword    ${data_formula}

KV set data shelves
    [Arguments]    ${list_shelves_id}
    ${length}    Get Length    ${list_shelves_id}
    ${list_data}    Create List
    FOR   ${index}   IN RANGE    ${length}
        Append To List    ${list_data}    {"ProductId": 0,"ShelvesId": ${list_shelves_id[${index}]}}
    END
    ${join_str}    Convert List to String    ${list_data}
    ${data_shelves}    Set Variable    "ProductShelves": [${join_str}],
    KV Log    ${data_shelves}
    Return From Keyword    ${data_shelves}

# ======================= THUỘC TÍNH ==============================
Them moi thuoc tinh
    [Arguments]    ${ten_thuoc_tinh}
    ${id_thuoc_tinh}    Get attribute id by attribute name    ${ten_thuoc_tinh}
    ${input_dict}    Create Dictionary    ten_thuoc_tinh=${ten_thuoc_tinh}
    Run Keyword If    ${id_thuoc_tinh} == 0    API Call From Template    /hang-hoa/add_thuoc_tinh.txt    ${input_dict}    ELSE    KV Log    Thuoc tinh da ton tai

Them moi list thuoc tinh
    [Arguments]    @{list_attr_name}
    FOR    ${item_attr_name}    IN    @{list_attr_name}
        Them moi thuoc tinh    ${item_attr_name}
    END

Delete thuoc tinh
    [Arguments]    ${ten_thuoc_tinh}
    ${find_id}    Get attribute id by attribute name    ${ten_thuoc_tinh}
    Run Keyword If    ${find_id} != 0    API Call From Template    /hang-hoa/delete_thuoc_tinh.txt    ${find_id}    ELSE    KV Log    Thuoc tinh khong ton tai

Delete list thuoc tinh
    [Arguments]    @{list_attr_name}
    FOR    ${item_attr_name}    IN    @{list_attr_name}
        Delete thuoc tinh    ${item_attr_name}
    END
# ======================= VI TRI ==============================
Them moi vi tri frm API
    [Arguments]    ${ten_vi_tri}
    ${find_id}    Get shelves id by name    ${ten_vi_tri}
    Run Keyword If    ${find_id} == 0    API Call From Template    /hang-hoa/add_shelves.txt    ${ten_vi_tri}    ELSE    KV Log    Vi tri da ton tai

Them moi list vi tri
    [Arguments]    @{list_vi_tri}
    FOR    ${item_vi_tri}    IN    @{list_vi_tri}
        Them moi vi tri frm API    ${item_vi_tri}
    END

Delete vi tri
    [Arguments]    ${ten_vi_tri}
    ${find_id}    Get shelves id by name    ${ten_vi_tri}
    Run Keyword If    ${find_id} != 0    API Call From Template    /hang-hoa/delete_shelves.txt    ${find_id}    ELSE    KV Log    Khong tim thay vi tri

Delete list vi tri
    [Arguments]    @{list_vi_tri}
    FOR    ${item_vi_tri}    IN    @{list_vi_tri}
        Delete vi tri    ${item_vi_tri}
    END

# ======================= NHÓM HÀNG ==============================
Them moi nhom hang
    [Arguments]    ${ten_nhom_hang}    ${ten_nhom_cha}=${EMPTY}
    ${find_id}    Get category ID by category name    ${ten_nhom_hang}
    Return From Keyword If    ${find_id}!=0    Nhom hang da ton tai
    ${parent_id}    Run Keyword If    '${ten_nhom_cha}'!='${EMPTY}'    Get category ID by category name    ${ten_nhom_cha}    ELSE    Set Variable    0
    # ${find_id}    Get category ID by category name    ${ten_nhom_hang}
    ${find_dict}    Create Dictionary    ten_nhom=${ten_nhom_hang}    id_nhom_cha=${parent_id}
    API Call From Template    /hang-hoa/add_nhom_hang.txt    ${find_dict}

Them moi list nhom hang
    [Arguments]    @{list_ten_nhom_hang}
    FOR    ${item_ten_nhom_hang}    IN    @{list_ten_nhom_hang}
        Them moi nhom hang    ${item_ten_nhom_hang}
    END

Delete nhom hang
    [Arguments]    ${ten_nhom_hang}
    ${find_id}    Get category ID by category name    ${ten_nhom_hang}
    Run Keyword If    ${find_id} !=0    Delete hang hoa su dung nhom hang    ${ten_nhom_hang}
    Run Keyword If    ${find_id} !=0    API Call From Template    /hang-hoa/delete_nhom_hang.txt    ${find_id}    ELSE    KV Log    Nhom hang khong ton tai

Delete list nhom hang
    [Arguments]    @{list_ten_nhom_hang}
    FOR    ${item_ten_nhom_hang}    IN    @{list_ten_nhom_hang}
        Delete nhom hang    ${item_ten_nhom_hang}
    END

#==========================Add HH cung loai============================
API Add Hang Hoa Cung Loai From Template
    [Arguments]    ${template_file}    ${input_data}    ${prefix_ma_hh}    ${dict_thuoc_tinh}    ${list_dict_don_vi_tinh}=${EMPTY}    ${json_path}=${EMPTY}
    ...    ${status_code_should_be}=200    ${tao_hang_sx}=False    ${session_alias}=session_api
    ${type_list_dict_dvt}=    Evaluate    type($list_dict_don_vi_tinh).__name__
    ${list_dict_don_vi_tinh}    Run Keyword If    '${type_list_dict_dvt}'=='list'    Set Variable    ${list_dict_don_vi_tinh}
    ...    ELSE    KV Create Default DonViTinh Dict
    Log   ${list_dict_don_vi_tinh}
    #đảm bảo giá trị quy đổi của dvt đơn vị luôn là 1
    Set To Dictionary    ${list_dict_don_vi_tinh[0]}    conversion_value    1
    Set To Dictionary    ${list_dict_don_vi_tinh[0]}    price    ${input_data.gia_ban}
    Set To Dictionary    ${list_dict_don_vi_tinh[0]}    allows_sale    ${input_data.ban_truc_tiep}
    ${list_product_string}    KV Create Files Data Add HH    ${template_file}    ${input_data}    ${prefix_ma_hh}    ${dict_thuoc_tinh}    ${list_dict_don_vi_tinh}
    ${list_products}    Evaluate    (None, '[${list_product_string}]')
    ${files}    Create Dictionary

    ${have_images}    Set Variable    false
    # Truyền image vào template file
    FOR    ${key}    IN    @{input_data}
        ${length}    Get Length    ${key}${EMPTY}
        Continue For Loop If    ${length}>1
        ${val}    Sub KeyWord Open File To API    ${input_data["${key}"]}
        Set To Dictionary    ${files}    ${key}    ${val}
        ${have_images}    Set Variable    true
    END

    Set To Dictionary    ${files}    ListProducts    ${list_products}

    ${value_save_img}    Evaluate    (None, 'true')
    Run Keyword If    '${have_images}'=='true'    Set To Dictionary    ${files}    SaveImagesForAllProducts    ${value_save_img}
    ${header}    Create Dictionary    Authorization=${bearertoken}    kv-version=${kv_version}    retailer=${RETAILER}
    ${res}=    Post Request    ${session_alias}    /products/addmany    files=${files}    headers=${header}

    KV Log    ${res.request.body}
    KV Log    ${res.json()}
    KV Log    ${res.status_code}

    ${lst_resp_msg}    Get Value From JSON    ${res.json()}    $..Message
    ${resp_msg}=    Evaluate    ''.join(${lst_resp_msg})
    # Log To Console    ${resp_msg}

    ${api_str}    Evaluate    None
    ${data}       Evaluate    None

    # Nếu api post tạo hàng sản xuất trả về code 420 và msg Có lỗi khi cập nhật dữ liệu thì sẽ bypass
    ${res}    Run Keyword If    '${tao_hang_sx}'=='True' and '${res.status_code}'=='420' and '${resp_msg}'=='Có lỗi khi cập nhật dữ liệu'
    ...    KV Check Send Request Error    ${res}    ${input_data.ma_hang_hoa}    ${api_str}    ${data}    ${files}    ${session_alias}
    ...    ELSE    Set Variable    ${res}

    Should Be Equal As Strings    ${res.status_code}    ${status_code_should_be}    Lỗi response status code expected và actual khác nhau

    ${type_json_path}=    Evaluate    type($json_path).__name__
    ${json_paths}    Run Keyword If    '${type_json_path}'=='list'    Set Variable    ${json_path}    ELSE    Create List    ${json_path}
    KV Log    ${json_paths}
    ${return_data}    Run Keyword If    '${json_paths[0]}'!='${EMPTY}'    KV Get Data From Json by List Xpath    ${res.json()}    ${json_paths}    ELSE    Set Variable    ${res.status_code}
    KV Log    ${return_data}
    Return From Keyword    ${return_data}

KV Create Default DonViTinh Dict
    ${don_vi_0}    Create Dictionary    unit_name=${EMPTY}
    ${list_dict_donvitinh}    Create List    ${don_vi_0}
    [Return]    ${list_dict_donvitinh}

KV Create Files Data Add HH
    [Arguments]    ${template_file}    ${input_dict}    ${prefix_ma_hh}    ${dict_thuoc_tinh}    ${list_dict_don_vi_tinh}
    ${template_str}    Get File    ${EXECDIR}/api-data/${template_file}
    ${combin}    KV Get Thuoc Tinh Combination    ${dict_thuoctinh}
    @{combin_split}    Split String    ${combin}    ||
    Remove From List    ${combin_split}    -1
    ${list_attr_id}    ${list_attr_value}    Get list attribute id by name    ${dict_thuoc_tinh}
    Set To Dictionary    ${input_dict}    co_thuoc_tinh    true
    Log To Console    Start add hang hoa:
    ${list_data}    Create List
    FOR    ${index}    ${combin_value}    IN ENUMERATE    @{combin_split}
        ${zfill_index}    Evaluate    str(${index}+1).zfill(2)
        ${file_data}    KV Create Files Loop DonViTinh Value    ${input_dict}    ${prefix_ma_hh}${zfill_index}    ${list_attr_id}    ${combin_value}    ${list_dict_don_vi_tinh}    ${template_str}
        Append To List    ${list_data}    ${file_data}
    END
    ${join_str}    Convert List to String    ${list_data}
    [Return]    ${join_str}

KV Create Files Loop DonViTinh Value
    [Arguments]    ${input_dict}    ${prefix_ma_hh}    ${list_attr_id}    ${combin_value}    ${list_dict_don_vi_tinh}    ${template_str}
    ${list_data}    Create List
    FOR    ${index}    ${don_vi}    IN ENUMERATE    @{list_dict_don_vi_tinh}
        ${zfill_index}    Run Keyword If    ${index}>0    Set Variable    -${index}    ELSE    Set Variable    ${EMPTY}
        Log To Console    Ma hang hoa = ${prefix_ma_hh}${zfill_index} | thuoc tinh = ${combin_value} | don vi tinh = ${don_vi.unit_name}
        ${input_data}    Copy Dictionary    ${input_dict}
        Set To Dictionary    ${input_data}    ma_hang_hoa    ${prefix_ma_hh}${zfill_index}
        ${list_attr_value}    Split String    ${combin_value}    __
        ${list_unit_detail}    Run Keyword If    ${index}==0    Set Variable    null    ELSE    Set Variable    []
        ${data_thuoc_tinh}    KV set data attribute    ${list_attr_id}    ${list_attr_value}    ${list_unit_detail}
        Set To Dictionary    ${input_data}    data_thuoc_tinh    ${data_thuoc_tinh}
        ${end}    Evaluate    ${index}+1
        ${data_don_vi_tinh}    Run Keyword If    ${index}>0    KV set data don vi tinh    ${list_dict_don_vi_tinh}    1    ${end}    ELSE    Set Variable    ${EMPTY}
        Set To Dictionary    ${input_data}    data_don_vi_tinh    ${data_don_vi_tinh}
        Set To Dictionary    ${input_data}    don_vi_tinh    ${don_vi.unit_name}
        Set To Dictionary    ${input_data}    gia_ban    ${don_vi.price}
        Set To Dictionary    ${input_data}    gia_tri_qui_doi    ${don_vi.conversion_value}
        Set To Dictionary    ${input_data}    ban_truc_tiep    ${don_vi.allows_sale}
        ${clone_template_str}    Format String    '${template_str}'    ${input_data}
        @{json_str_split}    Split String    ${clone_template_str}    \\"
        ${clone_template_str}    Catenate    SEPARATOR=\\\\"    @{json_str_split}
        ${api_json}    Evaluate     json.loads(''${clone_template_str}'')    json
        ${files_json}    Get Value From Json    ${api_json}    $..ListProducts[0]
        ${file_string}    Evaluate    json.dumps(${files_json[0]}, separators=(',',':'))    json
        Append To List    ${list_data}    ${file_string}
    END
    ${join_str}    Convert List to String    ${list_data}
    [Return]    ${join_str}

KV Get Thuoc Tinh Combination
    [Arguments]    ${dict_thuoc_tinh}    ${thuoc_tinh}=${EMPTY}
    ${str_combin}    Set Variable    ${EMPTY}
    ${list_key}    Get Dictionary Keys    ${dict_thuoc_tinh}
    ${length}    Get Length    ${list_key}
    ${str_combin}    Run Keyword If    ${length}==0    Set Variable    ${thuoc_tinh}||    ELSE    Set Variable    ${str_combin}

    ${dict_sub_thuoc_tinh}    Copy Dictionary    ${dict_thuoc_tinh}
    FOR    ${key}    IN    @{dict_thuoc_tinh}
        Remove From Dictionary    ${dict_sub_thuoc_tinh}    ${key}
        ${str_combin}    KV Loop Thuoc Tinh Value    ${dict_thuoc_tinh["${key}"]}    ${dict_sub_thuoc_tinh}    ${thuoc_tinh}
        Exit For Loop
    END
    [Return]    ${str_combin}

KV Loop Thuoc Tinh Value
    [Arguments]    ${list_thuoc_tinh}    ${dict_sub_thuoc_tinh}    ${thuoc_tinh}=${EMPTY}
    ${str_combin}    Set Variable    ${EMPTY}
    ${separator}    Run Keyword If    '${thuoc_tinh}'=='${EMPTY}'    Set Variable    ${EMPTY}    ELSE    Set Variable    __
    FOR    ${sub_thuoc_tinh}    IN    @{list_thuoc_tinh}
        ${str_sub_combin}    KV Get Thuoc Tinh Combination    ${dict_sub_thuoc_tinh}    ${thuoc_tinh}${separator}${sub_thuoc_tinh}
        ${str_combin}    Run Keyword If    '${str_combin}'!='${EMPTY}'    Catenate    SEPARATOR=${EMPTY}    ${str_combin}    ${str_sub_combin}    ELSE    Set Variable    ${str_sub_combin}
    END
    [Return]    ${str_combin}
#==========================End Add HH cung loai============================
# Tạo nhiều hàng thành phần và trả về list mã + số lượng của thành phần đó
KV Tao Hang Thanh Phan va Return Dict
    [Arguments]    ${list_data_hangtp}
    ${list_ma_hangtp}   Create List
    ${list_soluong_tp}   Create List
    ${dict_hangtp}    Create Dictionary
    Set To Dictionary    ${dict_hangtp}     list_ma_hangtp    ${list_ma_hangtp}
    Set To Dictionary    ${dict_hangtp}     list_soluong_tp    ${list_soluong_tp}
    FOR    ${data_hang_tp}    IN    @{list_data_hangtp}
        Append To List    ${dict_hangtp.list_ma_hangtp}     ${data_hang_tp[0]}
        Append To List    ${dict_hangtp.list_soluong_tp}     ${data_hang_tp[-1]}
        Remove From List    ${data_hang_tp}    -1
        Them moi hang thuong    @{data_hang_tp}
    END
    [Return]    ${dict_hangtp}

#Tạo input dictionary để truyền vào template cho tất cả loại hàng hóa
KV Create Input Dict for Hang hoa
    [Arguments]    ${ten_hh}    ${loai_thuc_don}    ${id_nhom_hang}    ${gia_ban}    ${gia_von}=${0}    ${ton_kho}=${0}
    ...    ${ban_truc_tiep}=true    ${gia_tri_qui_doi}=${1}    ${ma_hh}=${EMPTY}    ${data_thuoc_tinh}=${EMPTY}
    ...    ${don_vi_tinh}=${EMPTY}    ${data_don_vi_tinh}=${EMPTY}    ${data_topping}=${EMPTY}    ${data_hangtp}=${EMPTY}    ${is_topping}=false

    ${co_thuoc_tinh}    Run Keyword If    '${data_thuoc_tinh}'!='${EMPTY}'    Set Variable    true
    ...    ELSE    Set Variable    false

    ${input_dict}    Create Dictionary    ma_hang_hoa=${ma_hh}    ten_hang_hoa=${ten_hh}    loai_thuc_don=${loai_thuc_don}
    ...    id_nhom_hang=${id_nhom_hang}    gia_ban=${gia_ban}    gia_von=${gia_von}    ton_kho=${ton_kho}
    ...    ban_truc_tiep=${ban_truc_tiep}    data_hangtp=${data_hangtp}    co_thuoc_tinh=${co_thuoc_tinh}    data_thuoc_tinh=${data_thuoc_tinh}
    ...    don_vi_tinh=${don_vi_tinh}    data_don_vi_tinh=${data_don_vi_tinh}    gia_tri_qui_doi=${gia_tri_qui_doi}    data_topping=${data_topping}    is_topping=${is_topping}
    [Return]    ${input_dict}

#Tạo input dictionary để truyền vào template cho hàng hóa all field
KV Create Input Dict for All Fields Product
    [Arguments]    ${ten_hh}    ${loai_thuc_don}    ${id_nhom_hang}    ${gia_ban}    ${data_vi_tri}    ${trong_luong}    ${mo_ta}    ${ghi_chu}    ${list_hinh_anh}
    ...    ${gia_von}=${0}    ${ton_kho}=${0}    ${tich_diem}=false    ${ban_truc_tiep}=true    ${gia_tri_qui_doi}=${1}    ${ton_min}=${10}    ${ton_max}=${90000}
    ...    ${ma_hh}=${EMPTY}    ${data_thuoc_tinh}=${EMPTY}    ${don_vi_tinh}=${EMPTY}    ${data_don_vi_tinh}=${EMPTY}
    ...    ${data_topping}=${EMPTY}    ${data_hangtp}=${EMPTY}    ${is_topping}=false

    ${co_thuoc_tinh}    Run Keyword If    '${data_thuoc_tinh}'!='${EMPTY}'    Set Variable    true
    ...    ELSE    Set Variable    false

    ${input_dict}    Create Dictionary    ma_hang_hoa=${ma_hh}    ten_hang_hoa=${ten_hh}    loai_thuc_don=${loai_thuc_don}
    ...    id_nhom_hang=${id_nhom_hang}    data_vi_tri=${data_vi_tri}    gia_ban=${gia_ban}    gia_von=${gia_von}    ton_kho=${ton_kho}    trong_luong=${trong_luong}
    ...    tich_diem=${tich_diem}    ban_truc_tiep=${ban_truc_tiep}    ton_min=${ton_min}    ton_max=${ton_max}    mo_ta=${mo_ta}    ghi_chu=${ghi_chu}
    ...    data_hangtp=${data_hangtp}    co_thuoc_tinh=${co_thuoc_tinh}    data_thuoc_tinh=${data_thuoc_tinh}    don_vi_tinh=${don_vi_tinh}
    ...    data_don_vi_tinh=${data_don_vi_tinh}    gia_tri_qui_doi=${gia_tri_qui_doi}    data_topping=${data_topping}    is_topping=${is_topping}

    FOR    ${index}    ${item_hinh_anh}    IN ENUMERATE    @{list_hinh_anh}
        Set To Dictionary    ${input_dict}    ${index}${EMPTY}    ${item_hinh_anh}
    END
    KV Log    ${input_dict}
    [Return]    ${input_dict}

# Tạo data prepare cho hàng hóa
KV Create Data Formula Product Prepare
    [Arguments]    @{data}
    ${data_hh}    Set Variable    ${data}
    Insert Into List    ${data_hh}    0    ${pool_mahh_pp[${so_ma_hh_pp}]}
    ${so_ma_hh_pp}    Evaluate    ${so_ma_hh_pp}+1
    Set Test Variable    ${so_ma_hh_pp}    ${so_ma_hh_pp}
    [Return]    ${data_hh}

# Tạo data prepare cho hàng hóa
KV Create Data Updating Product Prepare
    [Arguments]    @{data}
    ${data_hh}    Set Variable    ${data}
    Set Test Variable    ${ma_hh_tc}    ${pool_mahh_tc[${so_ma_hh_chinh}]}
    Insert Into List    ${data_hh}    0    ${ma_hh_tc}
    ${so_ma_hh_chinh}    Evaluate    ${so_ma_hh_chinh}+1
    Set Test Variable    ${so_ma_hh_chinh}
    [Return]    ${data_hh}

# Tạo data prepare cho hàng hóa
KV Create Data Updating SameType Prepare
    [Arguments]    @{data}
    ${data_hh}    Set Variable    ${data}
    Set Test Variable    ${prefix_hh_cungloai}    ${prefix_hh_testcase}CL
    Set Test Variable    ${ma_hh_tc}    ${prefix_hh_cungloai}
    Insert Into List    ${data_hh}    0    ${ma_hh_tc}
    ${dict_thuoctinh}    Set Variable    ${data[-1]}
    Set Test Variable    ${count_hh_cungloai}    ${1}
    FOR    ${key}    IN    @{dict_thuoctinh}
        ${list_giatri_thuoctinh}    Set Variable    ${dict_thuoctinh["${key}"]}
        ${length}    Get Length    ${list_giatri_thuoctinh}
        ${count_hh_cungloai}    Evaluate    ${count_hh_cungloai}*${length}
    END
    Set Test Variable    ${count_hh_cungloai}    ${count_hh_cungloai}
    ${so_ma_hh_chinh}    Evaluate    ${so_ma_hh_chinh}+${count_hh_cungloai}
    Set Test Variable    ${so_ma_hh_chinh}
    [Return]    ${data}
