*** Settings ***
Resource          ../../api_access.robot
Resource          ../../../share/list_dictionary.robot
Resource          ../../../share/utils.robot
Library           String
Library           Collections
Library           JSONLibrary

*** Keywords ***
Get dict filter product template
    [Arguments]    ${search_param}    ${list_key}    ${master_product_id}=${EMPTY}    ${status}=${EMPTY}
    ${list_json_path}    Create List    $..Data[?(@.Id!=-1)].${list_key}
    ${find_dict}    Create Dictionary    branch_id=${BRANCH_ID}    master_product_id=${master_product_id}    is_active=${status}
    ${result_dict}    API Call From Template    /hang-hoa/master_hh.txt    ${find_dict}    ${list_json_path}    ${search_param}
    Return From Keyword    ${result_dict}

# Lấy dict tất cả hàng hóa theo filter search mặc định
Get dict filter product template by no keyword
    [Arguments]    ${list_key}
    ${search_param}    KV Make Filter HangHoa Params
    ${result_dict}    Get dict filter product template    ${search_param}    ${list_key}
    KV Log    ${result_dict}
    Return From Keyword    ${result_dict}

# Lấy dict hàng hóa theo từ khóa mã hàng
Get dict filter product by keyword product code
    [Arguments]    ${product_code}    ${list_key}
    ${search_param}    KV Make Filter HangHoa Params    ten_ma_hang_hoa=${product_code}   so_ban_ghi=100
    ${result_dict}    Get dict filter product template    ${search_param}    ${list_key}
    KV Log    ${result_dict}
    Return From Keyword    ${result_dict}

# Lấy dict hàng hóa theo số bản ghi trên 1 trang và trạng thái kinh doanh
Get dict filter product by keyword page size and status
    [Arguments]    ${page_size}    ${status}    ${list_key}    ${prefix_mahh}=${EMPTY}
    ${search_param}    KV Make Filter HangHoa Params    ten_ma_hang_hoa=${prefix_mahh}    so_ban_ghi=${page_size}    tinh_trang_kinh_doanh=${status}
    ${result_dict}    Get dict filter product template    ${search_param}    ${list_key}
    KV Log    ${result_dict}
    Return From Keyword    ${result_dict}

# Lấy dict hàng hóa theo master product id và is_active
Get dict master product info
    [Arguments]    ${json_path}    ${master_product_id}=${EMPTY}    ${status}=${EMPTY}
    ${find_dict}    Create Dictionary    branch_id=${BRANCH_ID}    master_product_id=${master_product_id}    is_active=${status}
    ${result_dict}    API Call From Template    /hang-hoa/master_hh.txt    ${find_dict}    ${json_path}
    Return From Keyword    ${result_dict}

# Lấy dict hàng hóa (cả cùng loại) theo jsonpath
Get dict all field product info by product code
    [Arguments]    ${product_code}    ${list_key}     ${json_path}=${EMPTY}    ${category_id}=${EMPTY}    ${is_return_response}=False    ${branch_id}=${BRANCH_ID}
    ${list_json_path}    Get List JSONPath    ${list_key}     ${json_path}    $.Data[?(@.Code\=\="${product_code}")]
    ${find_dict}    Create Dictionary    branch_id=${branch_id}    categoryId=${category_id}
    ${result_dict}    API Call From Template    /hang-hoa/hh_all_field.txt    ${find_dict}    ${list_json_path}    is_return_response=${is_return_response}
    KV Log    ${result_dict}
    Return From Keyword    ${result_dict}

# Lấy all dict hàng hóa (cả cùng loại) theo jsonpath
Get all dict all field product info
    [Arguments]    ${list_key}     ${json_path}=${EMPTY}    ${category_id}=${EMPTY}    ${is_return_response}=False
    ${list_json_path}    Get List JSONPath    ${list_key}     ${json_path}    $..Data[*]
    ${find_dict}    Create Dictionary    branch_id=${BRANCH_ID}    categoryId=${category_id}
    ${result_dict}    API Call From Template    /hang-hoa/hh_all_field.txt    ${find_dict}    ${list_json_path}    is_return_response=${is_return_response}
    KV Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get dict the kho info by document code
    [Arguments]    ${product_id}    ${document_code}    ${list_key}     ${json_path}=${EMPTY}    ${list_key_path}=$..Data[?(@.DocumentCode\=\="${document_code}")]
    ${list_json_path}    Get List JSONPath    ${list_key}     ${json_path}    ${list_key_path}
    ${find_dict}    Create Dictionary    branch_id=${BRANCH_ID}    product_id=${product_id}
    ${result_dict}    API Call From Template    /hang-hoa/the_kho_hh.txt    ${find_dict}    ${list_json_path}
    KV Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get dict ton kho info by document code
    [Arguments]    ${product_id}    ${list_key}
    ${find_dict}    Create Dictionary    product_id=${product_id}
    ${json_path}    Format String    $..Data[?(@.BranchId\=\={0})].${list_key}    ${BRANCH_ID}
    ${result_dict}    API Call From Template    /hang-hoa/ton_kho_hh.txt    ${find_dict}    ${json_path}
    KV Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get dict material info
    [Arguments]    ${product_id}    ${list_key}
    ${find_dict}    Create Dictionary    product_id=${product_id}
    ${json_path}    Set Variable    $..Data..${list_key}
    ${result_dict}    API Call From Template    /hang-hoa/thanh_phan_hh.txt    ${find_dict}    ${json_path}
    KV Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get dict toping info
    [Arguments]    ${product_id}    ${type_mt}    ${json_path}
    ${type_Id}    Run Keyword If    '${type_mt}'=='Topping'    Set Variable    ProductId    ELSE IF    '${type_mt}'=='Product'    Set Variable    ToppingId
    ...    ELSE    Set Variable    Fail
    Should Not Be True    '${type_Id}'=='Fail'
    ${find_dict}    Create Dictionary    product_id=${product_id}    type_mt=${type_mt}    type_Id=${type_Id}
    ${result_dict}    API Call From Template    /hang-hoa/toping_hh.txt    ${find_dict}    ${json_path}
    KV Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get dict unit detail info
    [Arguments]    ${product_id}    ${list_key}     ${json_path}=${EMPTY}    ${unitname}=${EMPTY}    ${status_code_api}=200
    ${list_json_path}    Get List JSONPath    ${list_key}     ${json_path}    $..ProductUnits[?(@.Unit=="${unitname}")]
    ${find_dict}    Create Dictionary    product_id=${product_id}
    ${result_dict}    API Call From Template    /hang-hoa/unit_detail_hh.txt    ${find_dict}    ${list_json_path}    ${EMPTY}    ${status_code_api}
    KV Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get dict image info
    [Arguments]    ${product_id}    ${list_key}
    ${find_dict}    Create Dictionary    product_id=${product_id}
    ${json_path}    Set Variable    $..Data..${list_key}
    ${result_dict}    API Call From Template    /hang-hoa/image_hh.txt    ${find_dict}    ${json_path}
    KV Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get dict shelves info
    [Arguments]    ${shelves_name}   ${list_key}    ${json_path}=${EMPTY}
    ${list_json_path}    Get List JSONPath    ${list_key}     ${json_path}    $..Data[?(@.Name=="${shelves_name}")]
    KV Log    ${list_json_path}
    ${result_dict}    API Call From Template    /hang-hoa/shelves_hh.txt    ${EMPTY}    ${list_json_path}
    KV Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get dict attributes info
    [Arguments]    ${list_key}     ${json_path}=${EMPTY}    ${attributeId}=${EMPTY}
    ${list_json_path}    Get List JSONPath    ${list_key}     ${json_path}    $..Data[?(@.Id=="${attributeId}")]
    ${result_dict}    API Call From Template    /hang-hoa/attributes_hh.txt    ${EMPTY}    ${list_json_path}
    KV Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get dict category info
    [Arguments]    ${list_key}     ${json_path}=${EMPTY}    ${category_name}=${EMPTY}
    ${list_json_path}    Get List JSONPath    ${list_key}     ${json_path}    $..Data[?(@.Name=="${category_name}")]
    ${result_dict}    API Call From Template    /hang-hoa/category_hh.txt    ${EMPTY}    ${list_json_path}
    KV Log    ${result_dict}
    Return From Keyword    ${result_dict}

# Lay tong SL ma hang dang kinh doanh trong danh muc
Get tong so ma hang
    ${dict_data}    Get dict master product info    $.TotalProduct    status=true
    ${soluong_mahang}    Set Variable Return From Dict    ${dict_data.TotalProduct[0]}
    Return From Keyword    ${soluong_mahang}

Get tong so luong hang hoa
    ${dict_data}    Get dict master product info    $.Total    status=true
    ${tong_hang_hoa}    Set Variable Return From Dict    ${dict_data.Total[0]}
    Return From Keyword    ${tong_hang_hoa}

# Số lượng HH của 1 nhóm hàng
Get number of product by category
    [Arguments]   ${category_name}
    ${categoryId}   Get category ID by category name    ${category_name}
    ${dict_data}    Get dict all field product info by product code    ${EMPTY}    ${EMPTY}    json_path=$.Total    category_id=${categoryId}
    ${number_of_pro}    Set Variable Return From Dict    ${dict_data.Total[0]}
    Return From Keyword    ${number_of_pro}

# Số list id HH của 1 nhóm hàng
Get list Id of product by category
    [Arguments]   ${category_name}
    ${categoryId}   Get category ID by category name    ${category_name}
    ${dict_data}    Get dict all field product info by product code    ${EMPTY}    ${EMPTY}    json_path=$..Data[*].Id    category_id=${categoryId}
    ${list_id}    Set Variable Return From Dict    ${dict_data.Id}
    Return From Keyword    ${list_id}

Get category ID by category name
    [Arguments]    ${category_name}
    ${dict_category}    Get dict category info    ["Id"]    category_name=${category_name}
    ${category_id}    Set Variable Return From Dict    ${dict_category.Id[0]}
    Return From Keyword    ${category_id}

Get list product code in category
    [Arguments]   ${category_name}
    ${categoryId}   Get category ID by category name    ${category_name}
    ${dict_data}    Get dict all field product info by product code    ${EMPTY}    ${EMPTY}    json_path=$..Data..Code    category_id=${categoryId}
    ${list_ma_hh}   Set Variable Return From Dict    ${dict_data.Code}
    Return From Keyword    ${list_ma_hh}

Get Gia ban Gia von Ton kho frm API
    [Arguments]    ${input_mahang}
    ${dict_data}    Get dict all field product info by product code    ${input_mahang}    ["BasePrice","Cost","OnHand"]
    ${giaban}    Set Variable Return From Dict    ${dict_data.BasePrice[0]}
    ${giavon}    Set Variable Return From Dict    ${dict_data.Cost[0]}
    ${ton}    Set Variable Return From Dict    ${dict_data.OnHand[0]}
    ${ton}    Convert To Number    ${ton}
    ${ton}    Evaluate    round(${ton}, 3)
    Return From Keyword    ${giaban}    ${giavon}    ${ton}

Get Gia von va Ton kho from API
    [Arguments]    ${input_mahang}
    ${dict_data}    Get dict all field product info by product code    ${input_mahang}    ["Cost","OnHand"]
    ${giavon}    Set Variable Return From Dict    ${dict_data.Cost[0]}
    ${ton}    Set Variable Return From Dict    ${dict_data.OnHand[0]}
    ${ton}    Convert To Number    ${ton}
    ${ton}    Evaluate    round(${ton}, 3)
    Return From Keyword    ${giavon}    ${ton}

# Lấy list product id theo mã hàng bằng index
Get list product id frm API by index
    [Arguments]    ${input_list_mahang}    ${check_found}=true
    ${dict_product}    Get dict all field product info by product code    ${EMPTY}    ${EMPTY}    $..Data[*].["Id","Code"]
    ${list_product_id}    Create List
    #Log To Console    ${dict_product.Code}
    FOR    ${item_mahang}    IN ZIP    ${input_list_mahang}
        ${index}    Get Index From List    ${dict_product.Code}    ${item_mahang}
        ${found}=    Evaluate    ${index}>-1
        Run Keyword If    '${check_found}' == 'true'    Should Be True    ${found}
        Continue For Loop If	'${found}'=='False'
        #Log To Console    ${index}|${dict_product.Id[${index}]}+${dict_product.Code[${index}]}|${item_mahang}
        ${product_id}    Set Variable Return From Dict    ${dict_product.Id[${index}]}
        Append To List    ${list_product_id}    ${product_id}
    END
    Return From Keyword    ${list_product_id}

Get list id and base price by list code
    [Arguments]    ${input_list_mahang}    ${branch_id}=${BRANCH_ID}
    ${result_dict}    Get dict all field product info by product code    ${EMPTY}    ${EMPTY}    ${EMPTY}    is_return_response=True    branch_id=${branch_id}
    ${get_pr_id}      Get Value From Json    ${result_dict}    $.Data[*].Id
    ${get_pr_price}   Get Value From Json    ${result_dict}    $.Data[*].BasePrice
    ${get_pr_code}    Get Value From Json    ${result_dict}    $.Data[*].Code
    ${list_pr_price}   Create List
    ${list_pr_id}      Create List
    FOR    ${item_mahang}    IN ZIP   ${input_list_mahang}
        ${index}    Get Index From List    ${get_pr_code}    ${item_mahang}
        ${pr_price}    Set Variable Return From Dict    ${get_pr_price[${index}]}
        ${pr_id}       Set Variable Return From Dict    ${get_pr_id[${index}]}
        Append To List    ${list_pr_price}   ${pr_price}
        Append To List    ${list_pr_id}      ${pr_id}
    END
    Return From Keyword    ${list_pr_id}    ${list_pr_price}

Get list id by list code
        [Arguments]    ${input_list_mahang}    ${branch_id}=${BRANCH_ID}
        ${result_dict}    Get dict all field product info by product code    ${EMPTY}    ${EMPTY}    ${EMPTY}    is_return_response=True    branch_id=${branch_id}
        ${get_pr_id}      Get Value From Json    ${result_dict}    $.Data[*].Id
        ${get_pr_price}   Get Value From Json    ${result_dict}    $.Data[*].BasePrice
        ${get_pr_code}    Get Value From Json    ${result_dict}    $.Data[*].Code
        ${list_pr_price}   Create List
        ${list_pr_id}      Create List
        FOR    ${item_mahang}    IN ZIP   ${input_list_mahang}
            ${index}    Get Index From List    ${get_pr_code}    ${item_mahang}
            ${pr_price}    Set Variable Return From Dict    ${get_pr_price[${index}]}
            ${pr_id}       Set Variable Return From Dict    ${get_pr_id[${index}]}
            Append To List    ${list_pr_price}   ${pr_price}
            Append To List    ${list_pr_id}      ${pr_id}
        END
        Return From Keyword    ${list_pr_id}    ${list_pr_price}
# Lấy product id theo mã hàng
Get product unit id frm API
    [Arguments]    ${input_mahang}
    ${product_ids}    Get list product unit id frm API    ${input_mahang}
    Return From Keyword    ${product_ids[0]}

# Lấy danh sách product id theo mã hàng
Get list product unit id frm API
    [Arguments]    ${input_mahang}
    ${dict_product}    Get dict all field product info by product code    ${input_mahang}    ["Id"]
    ${product_ids}    Set Variable Return From Dict    ${dict_product.Id}
    Return From Keyword    ${product_ids}

# Lấy giá vốn theo mã hàng
Get Gia von of product by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["Cost"]
    ${giavon}    Set Variable Return From Dict    ${dict_data.Cost[0]}
    Return From Keyword    ${giavon}

# Lấy list giá vốn theo list mã hàng
Get list cost by list product code
    [Arguments]    ${list_pr_code}
    ${dict_data}    Get dict all field product info by product code    ${EMPTY}    ${EMPTY}    $.Data[*].["Code","Cost"]
    ${list_cost}      Set Variable Return From Dict    ${dict_data.Cost}
    ${list_code}      Set Variable Return From Dict    ${dict_data.Code}
    ${list_result_cost}    Create List
    FOR    ${item_code}    IN    @{list_pr_code}
        ${index}    Get Index From List    ${list_code}    ${item_code}
        Append To List    ${list_result_cost}    ${list_cost[${index}]}
    END
    Return From Keyword    ${list_result_cost}

# Lấy list tồn kho theo list mã hàng
Get list onHand by list product code
    [Arguments]    ${list_pr_code}
    ${dict_data}    Get dict all field product info by product code    ${EMPTY}    ${EMPTY}    $.Data[*].["OnHand","Code"]
    ${list_onHand}    Set Variable Return From Dict    ${dict_data.OnHand}
    ${list_code}      Set Variable Return From Dict    ${dict_data.Code}
    ${list_result_onhand}    Create List
    FOR    ${item_code}    IN    @{list_pr_code}
        ${index}    Get Index From List    ${list_code}    ${item_code}
        Append To List    ${list_result_onhand}    ${list_onHand[${index}]}
    END
    Return From Keyword    ${list_result_onhand}

# Lấy list giá vốn và tồn kho theo list mã hàng
Get list onHand and cost by list product code
    [Arguments]    ${list_pr_code}
    ${dict_data}    Get dict all field product info by product code    ${EMPTY}    ${EMPTY}    $.Data[*].["OnHand","Code","Cost"]
    ${list_onHand}    Set Variable Return From Dict    ${dict_data.OnHand}
    ${list_cost}      Set Variable Return From Dict    ${dict_data.Cost}
    ${list_code}      Set Variable Return From Dict    ${dict_data.Code}
    ${list_result_onhand}    Create List
    ${list_result_cost}    Create List
    FOR    ${item_code}    IN    @{list_pr_code}
        ${index}    Get Index From List    ${list_code}    ${item_code}
        Append To List    ${list_result_onhand}    ${list_onHand[${index}]}
        Append To List    ${list_result_cost}    ${list_cost[${index}]}
    END
    Return From Keyword    ${list_result_onhand}    ${list_result_cost}

Get list gia ban frm API by list ma hang
    [Arguments]    ${list_pr_code}
    ${dict_data}    Get dict all field product info by product code    ${EMPTY}    ${EMPTY}    $.Data[*].["BasePrice","Code"]
    ${list_baseprice}    Set Variable Return From Dict    ${dict_data.BasePrice}
    ${list_code}      Set Variable Return From Dict    ${dict_data.Code}
    ${list_result_baseprice}    Create List
    FOR    ${item_code}    IN    @{list_pr_code}
        ${index}    Get Index From List    ${list_code}    ${item_code}
        Append To List    ${list_result_baseprice}    ${list_baseprice[${index}]}
    END
    Return From Keyword    ${list_result_baseprice}

# Lấy giá bán theo mã hàng
Get Gia ban of product by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["BasePrice"]
    ${giaban}    Set Variable Return From Dict    ${dict_data.BasePrice[0]}
    Return From Keyword    ${giaban}

# Lấy loại hàng theo mã hàng
Get Type of product by code
    [Arguments]    ${product_code}    ${is_return_IsTimeType}=False
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["ProductType","IsProcessedGoods","IsTimeType"]
    ${get_product_type}    Set Variable Return From Dict    ${dict_data.ProductType[0]}
    ${get_IsProcessedGoods}    Set Variable Return From Dict    ${dict_data.IsProcessedGoods[0]}
    ${get_IsTimeType}    Set Variable Return From Dict    ${dict_data.IsTimeType[0]}
    Run Keyword If    '${get_IsProcessedGoods}'=='True' and '${get_product_type}'=='1'      Set Suite Variable    ${loai_hang}    Chế biến
    ...    ELSE IF    '${get_IsProcessedGoods}'=='0' and '${get_product_type}'=='1'    Set Suite Variable    ${loai_hang}    Combo - đóng gói
    ...    ELSE IF    '${get_product_type}'=='3'    Set Suite Variable    ${loai_hang}    Dịch vụ
    ...    ELSE    Set Suite Variable    ${loai_hang}    Hàng hóa
    Run Keyword If    '${loai_hang}'=='Dịch vụ' and '${is_return_IsTimeType}'=='True'    Return From Keyword    ${loai_hang}    ${get_IsTimeType}
    ...    ELSE    Return From Keyword    ${loai_hang}

Get list type of product by list product id
    [Arguments]    ${input_list_id}
    ${dict_data}    Get all dict all field product info    ${EMPTY}    $.Data[*].["Id","ProductType","IsTimeType"]
    ${list_pr_id}      Set Variable Return From Dict    ${dict_data.Id}
    ${list_pr_type}    Set Variable Return From Dict    ${dict_data.ProductType}
    ${list_pr_is_timetype}    Set Variable Return From Dict    ${dict_data.IsTimeType}
    ${list_result}    Create List
    FOR    ${pr_id}    IN    @{input_list_id}
        ${index}    Get Index From List    ${list_pr_id}    ${pr_id}
        ${is_time_type_pr}    Run Keyword If    '${list_pr_is_timetype[${index}]}'=='True' and '${list_pr_type[${index}]}'=='3'    Set Variable    True
        ...    ELSE    Set Variable    False
        Append To List    ${list_result}    ${is_time_type_pr}
    END
    Return From Keyword    ${list_result}

# Lấy loại thực đơn theo mã hàng
Get Product group of product by code
    [Arguments]    ${product_code}
    ${product_id}    Get product unit id frm API    ${product_code}
    ${dict_data}    Get dict unit detail info    ${product_id}    ${EMPTY}    $..Product.ProductGroup
    ${Product_Group}    Set Variable Return From Dict    ${dict_data.ProductGroup[0]}
    Run Keyword If    '${Product_Group}'=='1'    Set Suite Variable    ${loai_thuc_don}    Đồ ăn
    ...    ELSE IF    '${Product_Group}'=='2'    Set Suite Variable    ${loai_thuc_don}    Đồ uống
    ...    ELSE IF    '${Product_Group}'=='3'    Set Suite Variable    ${loai_thuc_don}    Khác
    ...    ELSE    KV Log    Ignore Case
    Return From Keyword    ${loai_thuc_don}

# Lấy tên nhóm hàng theo mã hàng
Get Category name of product by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["CategoryName"]
    ${Category_Name}    Set Variable Return From Dict    ${dict_data.CategoryName[0]}
    Return From Keyword    ${Category_Name}

# Lấy tên nhóm hàng (đủ 3 cấp) theo mã hàng
Get Category tree name of product by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict filter product by keyword product code    ${product_code}    CategoryNameTree
    ${category_name_tree}    Set Variable Return From Dict    ${dict_data.CategoryNameTree[0]}
    Return From Keyword    ${category_name_tree}

# Lấy tên của hàng
Get Product name by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["Name"]
    ${product_name}    Set Variable Return From Dict    ${dict_data.Name[0]}
    Return From Keyword    ${product_name}

# Lấy tên của hàng hóa kèm thuộc tính (nếu có) và cắt bỏ đơn vị tính
Get product name with attribute
    [Arguments]    ${product_code}    ${full_name}    ${dvt}=${EMPTY}
    ${dvt}    Run Keyword If    '${dvt}'=='${EMPTY}'   Get base unit of product by code    ${product_code}    ELSE    Set Variable    ${dvt}
    ${suffix_name}    Run Keyword If    '${dvt}' != '0'    Set Variable     (${dvt})
    ...    ELSE    Set Variable    ${EMPTY}
    ${suffix_name_length}    Get length    ${suffix_name}
    ${full_name_length}      Get length    ${full_name}
    ${name_length}           Evaluate      ${full_name_length}-${suffix_name_length}
    ${name}                  Get Substring    ${full_name}   0   ${name_length}
    Return From Keyword    ${name}

# Lấy full tên của hàng
Get Product full name by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["FullName"]
    ${product_full_name}    Set Variable Return From Dict    ${dict_data.FullName[0]}
    Return From Keyword    ${product_full_name}

Get attribute id by attribute name
    [Arguments]    ${attr_name}
    ${attr_name}    Convert To Uppercase    ${attr_name}
    ${jsonpath}    Set Variable    $..Data[?(@.Name=="${attr_name}")].Id
    ${result_dict}    Get dict attributes info    ${EMPTY}    ${jsonpath}
    Return From Keyword    ${result_dict.Id[0]}

# Lấy số lượng đặt hàng
Get Reserved of product by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["Reserved"]
    ${dat_hang}    Set Variable Return From Dict    ${dict_data.Reserved[0]}
    Return From Keyword   ${dat_hang}

# Lấy tồn ít nhất và nhiều nhất
Get MinQuantity and MaxQuantity of product by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["MinQuantity","MaxQuantity"]
    ${ton_min}    Set Variable Return From Dict    ${dict_data.MinQuantity[0]}
    ${ton_max}    Set Variable Return From Dict    ${dict_data.MaxQuantity[0]}
    Return From Keyword    ${ton_min}    ${ton_max}

# Lấy mã hàng đơn vị tính quy đổi theo mã hàng cơ bản và tên DVT
Get code unit of product by code and unitname
    [Arguments]    ${product_code}    ${unitname}
    ${pr_id_coban}    Get product unit id frm API    ${product_code}
    ${dict_data}    Get dict unit detail info    ${pr_id_coban}    ["Code"]    ${EMPTY}    ${unitname}
    ${mahang_unit}    Set Variable Return From Dict    ${dict_data.Code[0]}
    Return From Keyword    ${mahang_unit}

# Lấy mã hàng đơn vị tính cơ bản theo id
Get base unit code of product by master unit id
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["MasterUnitId"]
    ${master_unit_id}    Set Variable Return From Dict    ${dict_data.MasterUnitId[0]}
    ${dict_unit}    Get dict all field product info by product code    ${EMPTY}    ${EMPTY}    $..Data[?(@.Id==${master_unit_id})].Code
    ${base_unit_code}    Set Variable Return From Dict    ${dict_unit.Code[0]}
    Return From Keyword    ${base_unit_code}

# Lấy tên đơn vị tính
Get base unit of product by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["Unit"]
    ${don_vi_tinh}    Set Variable Return From Dict    ${dict_data.Unit[0]}
    Return From Keyword    ${don_vi_tinh}

# Lấy giá trị quy đổi
Get DVQD of product by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["ConversionValue"]
    ${donvi_quydoi}    Set Variable Return From Dict    ${dict_data.ConversionValue[0]}
    Return From Keyword    ${donvi_quydoi}

# Lấy mã hàng liên quan
Get relate code of product by master product id
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["MasterProductId"]
    ${master_product_id}    Set Variable Return From Dict    ${dict_data.MasterProductId[0]}
    ${dict_relate}    Get dict all field product info by product code    ${EMPTY}    ${EMPTY}    $..Data[?(@.Id==${master_product_id})].Code
    ${relate_code}    Set Variable Return From Dict    ${dict_relate.Code[0]}
    Return From Keyword    ${relate_code}

# Lấy url ảnh
Get url image of product by code
    [Arguments]    ${product_code}
    ${product_id}    Get product unit id frm API    ${product_code}
    ${dict_data}    Get dict image info    ${product_id}    ["Image"]
    ${list_image}    Set Variable Return From Dict    ${dict_data.Image}
    ${url_image}=    Evaluate    ",".join(${list_image})
    Return From Keyword    ${url_image}

# Lấy trọng lượng
Get weight of product by code
    [Arguments]    ${product_code}
    ${product_id}    Get product unit id frm API    ${product_code}
    ${dict_data}    Get dict unit detail info    ${product_id}    ${EMPTY}    $..Product.Weight
    ${weight}    Set Variable Return From Dict    ${dict_data.Weight[0]}
    Return From Keyword    ${weight}

# Lấy giá trị tích điểm?
Get IsRewardPoint of product by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["IsRewardPoint"]
    ${tichdiem}    Set Variable Return From Dict    ${dict_data.IsRewardPoint[0]}
    ${tich_diem}    Convert boolean value to number and return value    ${tichdiem}
    Return From Keyword    ${tich_diem}

# Lấy giá trị Đang kinh doanh?
Get IsActive of product by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["isActive"]
    ${dang_kd}    Set Variable Return From Dict    ${dict_data.isActive[0]}
    ${dang_kinh_doanh}    Convert boolean value to number and return value    ${dang_kd}
    Return From Keyword    ${dang_kinh_doanh}

# Lấy giá trị bán trực tiếp?
Get AllowSale of product by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["AllowsSale"]
    ${ban_tt}    Set Variable Return From Dict    ${dict_data.AllowsSale[0]}
    ${ban_truc_tiep}    Convert boolean value to number and return value    ${ban_tt}
    Return From Keyword   ${ban_truc_tiep}

# Lấy giá trị là món thêm?
Get IsTopping of product by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["IsTopping"]
    ${get_IsTopping}    Set Variable Return From Dict    ${dict_data.IsTopping[0]}
    ${la_mon_them}    Convert boolean value to number and return value    ${get_IsTopping}
    Return From Keyword    ${la_mon_them}

# Lấy giá trị Hàng DV tính giờ
Get IsTimeType of product by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["IsTimeType"]
    ${get_IsTimeType}    Set Variable Return From Dict    ${dict_data.IsTimeType[0]}
    ${la_dv_time}    Convert boolean value to number and return value    ${get_IsTimeType}
    Return From Keyword    ${la_dv_time}

# Lấy mô tả
Get mo ta of product by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["Description"]
    ${mo_ta}    Set Variable Return From Dict    ${dict_data.Description[0]}
    Return From Keyword    ${mo_ta}

# Lấy ghi chú
Get mau ghi chu of product by code
    [Arguments]    ${product_code}
    ${product_id}    Get product unit id frm API    ${product_code}
    ${dict_data}    Get dict unit detail info    ${product_id}    ${EMPTY}    $..Product.OrderTemplate
    ${mau_ghi_chu}    Set Variable Return From Dict    ${dict_data.OrderTemplate[0]}
    Return From Keyword    ${mau_ghi_chu}

# Lấy danh sách tên và giá trị thuộc tính
Get list attribute name and value of product by code
    [Arguments]    ${product_code}
    ${product_id}    Get product unit id frm API    ${product_code}
    ${dict_attr_product}    Get dict unit detail info    ${product_id}    ${EMPTY}    $..Product..ProductAttributes..["AttributeId","Value"]
    ${list_attrId}    Set Variable Return From Dict    ${dict_attr_product.AttributeId}
    ${list_attrValue}    Set Variable Return From Dict    ${dict_attr_product.Value}
    ${list_attrName}    Create List
    ${dict_all_thuoctinh}    Get dict attributes info    ${EMPTY}    $.Data[*].["Id","Name"]
    FOR    ${item_attrId}    IN ZIP    ${list_attrId}
        ${index}    Get Index From List    ${dict_all_thuoctinh.Id}    ${item_attrId}
        ${found}=    Evaluate    ${index}>-1
        Should Be True    ${found}
        ${attr_name}    Set Variable Return From Dict    ${dict_all_thuoctinh.Name[${index}]}
        Append To List    ${list_attrName}    ${attr_name}
    END
    Return From Keyword    ${list_attrName}    ${list_attrValue}

# Lấy string chứa thuộc tính của sản phẩm
Get thuoc tinh of product
    [Arguments]    ${product_code}
    ${list_attrName}    ${list_attrValue}    Get list attribute name and value of product by code    ${product_code}
    ${list_attr}    Create List
    FOR    ${item_attrName}    ${item_attrValue}    IN ZIP    ${list_attrName}    ${list_attrValue}
        ${item_attr}=    Catenate    SEPARATOR=:    ${item_attrName}    ${item_attrValue}
        Append To List    ${list_attr}    ${item_attr}
    END
    ${thuoc_tinh}=    Evaluate    "|".join(${list_attr})
    Return From Keyword    ${thuoc_tinh}

Get thuoc tinh of product by code
    [Arguments]    ${input_thuoc_tinh}    ${input_ma_hang}
    ${thuoc_tinh}=    Run Keyword If    '${input_thuoc_tinh}'!='0'    Run Keyword And Return    Get thuoc tinh of product    ${input_ma_hang}
        ...    ELSE    Set Variable    0
    Return From Keyword    ${thuoc_tinh}

# Lấy danh sách hàng thành phần và số lượng
Get list materialCode and quantity of product by code
    [Arguments]    ${product_code}
    ${product_id}    Get product unit id frm API    ${product_code}
    ${dict_data}    Get dict material info    ${product_id}    ["MaterialCode","Quantity"]
    ${list_materialCode}    Set Variable Return From Dict    ${dict_data.MaterialCode}
    ${list_quantity}    Set Variable Return From Dict    ${dict_data.Quantity}
    Return From Keyword    ${list_materialCode}    ${list_quantity}

# Lấy danh sách hàng thành phần số lượng va giá của hàng thành phần
Get list materialCode and quantity of product by id
    [Arguments]    ${product_id}
    ${dict_data}    Get dict material info    ${product_id}    ["MaterialCode","Quantity","BasePrice"]
    Log    ${dict_data}
    ${list_materialCode}    Set Variable Return From Dict    ${dict_data.MaterialCode}
    Log    ${dict_data.MaterialCode}
    ${list_quantity}    Set Variable Return From Dict    ${dict_data.Quantity}
    ${list_price}    Set Variable Return From Dict    ${dict_data.BasePrice}
    Return From Keyword    ${list_materialCode}    ${list_quantity}    ${list_price}

# Lấy String chứa hàng thành phần và số lượng của sản phẩm
Get thanh phan of product
    [Arguments]    ${product_code}
    ${list_materialCode}    ${list_quantity}    Get list materialCode and quantity of product by code    ${product_code}
    ${list_material}    Create List
    FOR    ${item_materialCode}    ${item_quantity}    IN ZIP    ${list_materialCode}    ${list_quantity}
        ${item_material}=    Catenate    SEPARATOR=:    ${item_materialCode}    ${item_quantity}
        Append To List    ${list_material}    ${item_material}
    END
    ${hang_tp}=    Evaluate    "|".join(${list_material})
    Return From Keyword    ${hang_tp}

Get thanh phan of product by code
    [Arguments]    ${input_hang_tp}    ${input_ma_hang}
    ${hang_tp}=    Run Keyword If    '${input_hang_tp}'!='0'    Run Keyword And Return    Get thanh phan of product    ${input_ma_hang}
        ...    ELSE    Set Variable    0
    Return From Keyword    ${hang_tp}

# Lấy danh sách hàng món thêm
Get list topingCode of product by code
    [Arguments]    ${product_code}
    ${product_id}    Get product unit id frm API    ${product_code}
    ${dict_data}    Get dict toping info    ${product_id}    Topping    $..Data[*].Topping.Code
    ${list_topingCode}    Set Variable Return From Dict    ${dict_data.Code}
    Return From Keyword    ${list_topingCode}

# Lấy string chứa món thêm của sản phẩm
Get mon them of product
    [Arguments]    ${product_code}
    ${list_topingCode}    Get list topingCode of product by code    ${product_code}
    ${hang_mon_them}=    Evaluate    "|".join(${list_topingCode})
    Return From Keyword    ${hang_mon_them}

Get mon them of product by code
    [Arguments]    ${input_hang_mt}    ${input_ma_hang}
    ${hang_mon_them}=    Run Keyword If    '${input_hang_mt}'!='0'    Run Keyword And Return    Get mon them of product    ${input_ma_hang}
        ...    ELSE    Set Variable    0
    Return From Keyword    ${hang_mon_them}

# Lấy ra danh sách hàng sử dụng món thêm
Get list product use topping by code
    [Arguments]    ${product_code}
    ${product_id}   Get product unit id frm API    ${product_code}
    ${dict_data}    Get dict toping info    ${product_id}    Product    $..Data[*].Product.Code
    ${list_pr_use_topping_code}    Set Variable Return From Dict    ${dict_data.Code}
    Return From Keyword    ${list_pr_use_topping_code}

# Lấy ra vị trí của hàng hóa dưới dạng string
Get string vi tri of product by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict filter product by keyword product code    ${product_code}    ["ProductShelvesStr"]
    ${pr_shelves}    Set Variable Return From Dict    ${dict_data.ProductShelvesStr[0]}
    Return From Keyword    ${pr_shelves}

# lấy ra vị trí của hàng hóa dưới dạng list
Get list vi tri by code
    [Arguments]   ${product_code}
    ${product_id}   Get product unit id frm API    ${product_code}
    ${dict_data}    Get dict unit detail info    ${product_id}    ${EMPTY}    $..Product..ProductShelves..Shelves..Name
    ${list_vitri}    Set Variable Return From Dict    ${dict_data.Name}
    Return From Keyword    ${list_vitri}

# lấy danh sách all nhóm hàng của shop
Get danh sach nhom hang from API
    [Arguments]
    ${dict_data}    Get dict category info    ${EMPTY}    $..Data..Name
    ${list_nhomhang}    Set Variable Return From Dict    ${dict_data.Name}
    Return From Keyword    ${list_nhomhang}

# lấy danh sách all vi tri của shop
Get danh sach vi tri from API
    ${dict_data}    Get dict shelves info    ${EMPTY}    ${EMPTY}    $..Data..["Name"]
    ${list_vitri}    Set Variable Return From Dict    ${dict_data.Name}
    Return From Keyword    ${list_vitri}

# Lấy id của vị trí
Get shelves id by name
    [Arguments]    ${shelves_name}
    ${result_dict}    Get dict shelves info    ${shelves_name}    ["Id"]
    ${shelves_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${shelves_id}

# lấy danh sách all thuộc tính của shop
Get danh sach thuoc tinh from API
    ${dict_data}    Get dict attributes info    ${EMPTY}    $..Data..["Name"]
    ${list_thuoctinh}    Set Variable Return From Dict    ${dict_data.Name}
    ${last_item}   Remove From List    ${list_thuoctinh}    -1
    KV Log    ${list_thuoctinh}
    Return From Keyword    ${list_thuoctinh}

Get The kho gia von va so luong frm API
    [Arguments]    ${input_mahang}
    ${product_id}    Get product unit id frm API    ${input_mahang}
    ${dict_thekho}    Get dict the kho info by document code    ${product_id}    ${EMPTY}    ${EMPTY}    $..Data..["Cost","Quantity"]
    ${list_gia_von}    Set Variable Return From Dict    ${dict_thekho.Cost}
    ${list_soluong}    Set Variable Return From Dict    ${dict_thekho.Quantity}
    ${get_gia_von}    Get From List    ${list_gia_von}    1
    ${get_soluong}   Get From List    ${list_soluong}    0
    Return From Keyword    ${get_gia_von}    ${get_soluong}

Get The kho so luong frm API
    [Arguments]    ${input_sochungtu}    ${input_mahang}
    ${product_id}    Get product unit id frm API    ${input_mahang}
    ${dict_data}    Get dict the kho info by document code    ${product_id}    ${input_sochungtu}    ["Quantity"]
    ${soluong_in_chungtu}    Set Variable Return From Dict    ${dict_data.Quantity[0]}
    ${soluong_in_chungtu}    Convert To String    ${soluong_in_chungtu}
    ${string_soluong_in_chungtu}    Replace String    ${soluong_in_chungtu}    -    ${EMPTY}
    ${num_soluong_in_chungtu}    Convert To Number    ${string_soluong_in_chungtu}
    Return From Keyword    ${num_soluong_in_chungtu}

Get The kho so luong hang thanh phan
    [Arguments]    ${input_sochungtu}    ${input_list_mahangtp}
    ${list_soluong_thekho}    Create List
    FOR    ${item_mahangtp}    IN ZIP    ${input_list_mahangtp}
        ${soluong_thekho}    Get The kho so luong frm API    ${input_sochungtu}    ${item_mahangtp}
        Append To List    ${list_soluong_thekho}    ${soluong_thekho}
    END
    Return From Keyword    ${list_soluong_thekho}

# lấy dữ liệu số lượng và tồn cuối được ghi nhật trên mã chứng từ ... Không xóa dấu âm của số lượng
Get Stock Card info frm API
    [Arguments]    ${input_sochungtu}    ${input_mahang}
    ${product_id}    Get product unit id frm API    ${input_mahang}
    ${dict_thekho}    Get dict the kho info by document code    ${product_id}    ${input_sochungtu}    ["Quantity","EndingStocks"]
    ${num_soluong_in_chungtu}    Set Variable Return From Dict    ${dict_thekho.Quantity[0]}
    ${num_soluong_in_chungtu}    Convert To Number    ${num_soluong_in_chungtu}
    ${toncuoi_in_chungtu}    Set Variable Return From Dict    ${dict_thekho.EndingStocks[0]}
    ${toncuoi_in_chungtu}    Convert to Number    ${toncuoi_in_chungtu}
    Return From Keyword    ${num_soluong_in_chungtu}    ${toncuoi_in_chungtu}

# lấy dữ liệu số lượng và tồn cuối được ghi nhật trên mã chứng từ ... Có xóa dấu âm của số lượng
Get Stock Card info exclude negative frm API
    [Arguments]    ${input_sochungtu}    ${input_mahang}
    ${product_id}    Get product unit id frm API    ${input_mahang}
    ${dict_thekho}    Get dict the kho info by document code    ${product_id}    ${input_sochungtu}    ["Quantity","EndingStocks"]
    ${num_soluong_in_chungtu}    Set Variable Return From Dict    ${dict_thekho.Quantity[0]}
    ${string_soluong_in_chungtu}    Convert To String    ${num_soluong_in_chungtu}
    ${string_soluong_in_chungtu}    Replace String    ${string_soluong_in_chungtu}    -    ${EMPTY}
    ${num_soluong_in_chungtu}    Convert To Number    ${string_soluong_in_chungtu}
    ${toncuoi_in_chungtu}    Set Variable Return From Dict    ${dict_thekho.EndingStocks[0]}
    ${toncuoi_in_chungtu}    Convert to Number    ${toncuoi_in_chungtu}
    Return From Keyword    ${num_soluong_in_chungtu}    ${toncuoi_in_chungtu}

# lấy tất cả danh sách document trong thẻ kho
Get all documents in Stock Card
    [Arguments]    ${input_mahang}
    ${product_id}   Get product unit id frm API    ${input_mahang}
    ${dict_data}    Get dict the kho info by document code    ${product_id}    ${EMPTY}    ${EMPTY}    $..DocumentCode
    ${list_docs}    Set Variable Return From Dict    ${dict_data.DocumentCode}
    Return From Keyword    ${list_docs}

# Lấy tất cả thông tin thẻ kho trong API
Get all stockcard data frm API
    [Arguments]    ${ma_hang_hoa}

    ${product_id}    Get product unit id frm API    ${ma_hang_hoa}

    ${dict_the_kho}    Get dict the kho info by document code    ${product_id}    ${EMPTY}
    ...    ["DocumentCode","DocumentType","TransDate","Cost","Quantity","EndingStocks"]    $..Total    $..Data[*]

    ${total_chungtu}    Set Variable Return From Dict    ${dict_the_kho.Total[0]}

    ${dict_api_gttk}    Create Dictionary    chung_tu=@{EMPTY}
    ...     phuong_thuc=@{EMPTY}
    ...     thoi_gian=@{EMPTY}
    ...     gia_von=@{EMPTY}
    ...     so_luong=@{EMPTY}
    ...     ton_cuoi=@{EMPTY}

    TheKho Data API    ${total_chungtu}    ${dict_the_kho}    ${dict_api_gttk}

    KV Log    ${dict_api_gttk}
    Return From Keyword    ${dict_api_gttk}

# Lấy ra và lưu tất cả các trường thông tin của thẻ kho trong API dưới dạng dictionary
TheKho Data API
    [Arguments]    ${total_chungtu}    ${dict_the_kho}    ${dict_api_gttk}
    #1

    ${dict_phuong_thuc}    Create Dictionary    1=Bán hàng    2=Nhập hàng    3=Kiểm hàng    4=Chuyển hàng    5=Nhận hàng    6=Trả hàng    7=Bán hàng [Combo - Đóng gói]
    ...    8=Trả hàng [Combo - Đóng gói]    9=Trả hàng nhà cung cấp    10=Sản xuất    11=Sản xuất [Giảm thành phần]    12=Xuất hủy    13=Cập nhật giá vốn
    ...    14=Không giao được hàng    15=Không giao được hàng [Combo - Đóng gói]    16=Đặt hàng nhà cung cấp    17=Đặt hàng

    FOR    ${index}    IN RANGE    0    ${total_chungtu}
        ${chung_tu}    Set Variable Return From Dict    ${dict_the_kho["DocumentCode"][${index}]}
        ${gia_von}    Set Variable Return From Dict    ${dict_the_kho["Cost"][${index}]}
        ${so_luong}    Set Variable Return From Dict    ${dict_the_kho["Quantity"][${index}]}
        ${ton_cuoi}    Set Variable Return From Dict    ${dict_the_kho["EndingStocks"][${index}]}
        ${thoi_gian}    KV Convert DateTime From API To 12h Format String    ${dict_the_kho["TransDate"][${index}]}    is_VnText=True    zero_in_hour=False
        ${phuong_thuc}    Set Variable Return From Dict    ${dict_phuong_thuc["${dict_the_kho["DocumentType"][${index}]}"]}
        Append To List    ${dict_api_gttk.chung_tu}    ${chung_tu}
        Append To List    ${dict_api_gttk.gia_von}    ${gia_von}
        Append To List    ${dict_api_gttk.so_luong}    ${so_luong}
        Append To List    ${dict_api_gttk.ton_cuoi}    ${ton_cuoi}
        Append To List    ${dict_api_gttk.thoi_gian}    ${thoi_gian}
        Append To List    ${dict_api_gttk.phuong_thuc}    ${phuong_thuc}
    END

Get Ton kho theo chi nhanh frm API
    [Arguments]    ${ma_hh}
    ${product_id}   Get product unit id frm API    ${ma_hh}
    ${dict_data}    Get dict ton kho info by document code    ${product_id}    ["OnHand"]
    ${tonkho_theo_CN}    Set Variable Return From Dict    ${dict_data.OnHand[0]}
    Return From Keyword    ${tonkho_theo_CN}

Get list ton kho theo chi nhanh by index
    [Arguments]    ${input_list_mahang}
    ${dict_product}    Get dict all field product info by product code    ${EMPTY}    ${EMPTY}    $..Data[*].["Id","Code"]
    ${list_tonkho_CN}    Create List
    #Log To Console    ${dict_product.Code}
    FOR    ${item_mahang}    IN ZIP    ${input_list_mahang}
        ${index}    Get Index From List    ${dict_product.Code}    ${item_mahang}
        ${found}=    Evaluate    ${index}>-1
        Run Keyword If    '${check_found}' == 'true'    Should Be True    ${found}
        Continue For Loop If	'${found}'=='False'
        ${product_id}    Set Variable Return From Dict    ${dict_product.Id[${index}]}
        ${dict_data}    Get dict ton kho info by document code    ${product_id}    ["OnHand"]
        ${tonkho_theo_CN}    Set Variable Return From Dict    ${dict_data.OnHand[0]}
        Append To List    ${list_tonkho_CN}    ${tonkho_theo_CN}
    END
    Return From Keyword    ${list_tonkho_CN}

Get list DVQD by product code
    [Arguments]    ${product_code}
    ${id_unit_coban}    Get product unit id frm API    ${product_code}
    ${dict_data}    Get dict unit detail info    ${id_unit_coban}    ${EMPTY}    $..ProductUnits..Code
    ${list_dvqd}    Set Variable Return From Dict    ${dict_data.Code}
    Return From Keyword    ${list_dvqd}

Get list ma hang hoa quy doi theo id hang co ban
    [Arguments]   ${product_id}
    ${dict_data}    Get dict master product info    $..Data[?(@.Id==${product_id})].UnitList..Code   ${product_id}
    ${list_ma_DVTQD}    Set Variable Return From Dict    ${dict_data.Code}
    Return From Keyword    ${list_ma_DVTQD}

Get list ma hang cung loai va co ban theo id hang co ban
    [Arguments]   ${product_id}
    ${dict_mahang_coban}    Get dict all field product info by product code    ${EMPTY}    ${EMPTY}    $..Data[?(@.Id==${product_id})].Code
    ${ma_hang_coban}    Set Variable Return From Dict    ${dict_mahang_coban.Code[0]}
    ${dict_mahang_cungloai}    Get dict all field product info by product code    ${EMPTY}    ${EMPTY}    $..Data[?(@.MasterProductId==${product_id})].Code
    ${list_ma_hang_cungloai}    Set Variable Return From Dict    ${dict_mahang_cungloai.Code}
    Append To List    ${list_ma_hang_cungloai}    ${ma_hang_coban}
    Return From Keyword    ${list_ma_hang_cungloai}

Get list product id by list product code
    [Arguments]   ${list_product_code}
    ${list_product_id}    Create List
    FOR    ${item_product_code}   IN    @{list_product_code}
        ${item_id}   Get product unit id frm API    ${item_product_code}
        Append To List    ${list_product_id}    ${item_id}
    END
    Return From Keyword    ${list_product_id}

Get danh sach id hang hoa theo trang
    [Arguments]   ${page_size}    ${status}    ${prefix_mahh}=${EMPTY}
    ${dict_data}    Get dict filter product by keyword page size and status    ${page_size}    ${status}    ["Id"]    ${prefix_mahh}
    ${list_product_id}    Set Variable Return From Dict    ${dict_data.Id}
    Return From Keyword    ${list_product_id}

# Lấy danh sách mã hàng đã chọn bao gồm cả hàng đơn vị tính quy đổi và hàng cùng loại
Get full ma hang khi chon nhieu hang hoa
    [Arguments]   ${list_product_id}    ${page_size}
    ${list_full_ma_hang}   Create List
    ${dict_data}    Get dict filter product by keyword page size and status    ${page_size}    All    ["Id","Code","UnitListStr","VariantCount"]
    FOR    ${item_product_id}   IN    @{list_product_id}
        ${index}    Get Index From List    ${dict_data.Id}    ${item_product_id}
        ${item_ma_hang}    Set Variable Return From Dict    ${dict_data.Code[${index}]}
        ${UnitListStr_value}    Set Variable Return From Dict    ${dict_data.UnitListStr[${index}]}
        ${VariantCount_value}    Set Variable Return From Dict    ${dict_data.VariantCount[${index}]}
        ${sub_list_product_code}   Create List
        ${sub_list_product_code}=   Run Keyword If    '${UnitListStr_value}'=='0' and ${VariantCount_value} > 0
        ...    Get list ma hang cung loai va co ban theo id hang co ban    ${item_product_id}
        ...    ELSE IF    '${UnitListStr_value}'!='0' and ${VariantCount_value} > 0    Get list ma hang hoa quy doi theo id hang co ban    ${item_product_id}
        ...    ELSE IF    '${VariantCount_value}' =='0'    Create List    ${item_ma_hang}
        KV Log    ${sub_list_product_code}
        ${list_full_ma_hang}   Combine Lists    ${list_full_ma_hang}   ${sub_list_product_code}
        KV Log    ${list_full_ma_hang}
    END
    Return From Keyword    ${list_full_ma_hang}

# Get tất cả các trường thông tin của hàng hóa trong API
Get product data frm API
    [Arguments]    ${list_ma_hang}
    ${dict_af_product}    Get all dict all field product info    ["Id","Code","ProductType","IsProcessedGoods","Name","Cost","BasePrice","OnHand","Reserved","MinQuantity","MaxQuantity","MasterUnitId","ConversionValue","MasterProductId","Unit","IsRewardPoint","isActive","AllowsSale","Description","IsTopping","IsTimeType"]
    ${dict_attribute}    Get dict attributes info    ${EMPTY}    $..Data[*].["Id","Name"]
    ${dict_filter_product}    Get dict filter product by keyword product code    ${EMPTY}    ["Id","ProductShelvesStr","CategoryNameTree"]

    ${dict_api_value}    Create Dictionary    loai_hang=@{EMPTY}
    ...     ten_hang=@{EMPTY}
    ...     gia_von=@{EMPTY}
    ...     gia_ban=@{EMPTY}
    ...     ton_kho=@{EMPTY}
    ...     dat_hang=@{EMPTY}
    ...     ton_min=@{EMPTY}
    ...     ton_max=@{EMPTY}
    ...     ma_dvt_coban=@{EMPTY}
    ...     donvi_quydoi=@{EMPTY}
    ...     ma_hh_lqan=@{EMPTY}
    ...     don_vi_tinh=@{EMPTY}
    ...     tich_diem=@{EMPTY}
    ...     dang_kd=@{EMPTY}
    ...     ban_tt=@{EMPTY}
    ...     mo_ta=@{EMPTY}
    ...     la_mon_them=@{EMPTY}
    ...     la_dv_tinhgio=@{EMPTY}
    ...     loai_thuc_don=@{EMPTY}
    ...     trong_luong=@{EMPTY}
    ...     ghi_chu=@{EMPTY}
    ...     hang_thanh_phan=@{EMPTY}
    ...     mon_them=@{EMPTY}
    ...     nhom_hang=@{EMPTY}
    ...     vi_tri=@{EMPTY}
    ...     hinh_anh=@{EMPTY}
    ...     thuoc_tinh=@{EMPTY}
    ...     ma_hang=@{EMPTY}
    FOR    ${input_ma_hang}    IN ZIP    ${list_ma_hang}
        Run Keyword If    '${input_ma_hang}'=='0'    Continue For Loop    #ma hang =0 thi bo qua
        HH Data API    ${input_ma_hang}    ${dict_af_product}    ${dict_attribute}    ${dict_filter_product}    ${dict_api_value}
    END
    KV Log    ${dict_api_value}
    Return From Keyword    ${dict_api_value}

# Lấy ra và lưu tất cả các trường thông tin của hàng hóa trong API dưới dạng dictionary
HH Data API
    [Arguments]    ${input_ma_hang}    ${dict_af_product}    ${dict_attribute}    ${dict_filter_product}    ${dict_api_value}
    #1
    ${index}    Get Index From List    ${dict_af_product.Code}    ${input_ma_hang}

    ${dict_loai_hang}    Create Dictionary    2&0=Hàng hóa    1&True=Chế biến    1&0=Combo - đóng gói    3&0=Dịch vụ    2&False=Hàng hóa
    ${key_loai_hang}    Set Variable Return From Dict   ${dict_af_product["ProductType"][${index}]}&${dict_af_product["IsProcessedGoods"][${index}]}

    ${gia_von}    Set Variable Return From Dict    ${dict_af_product["Cost"][${index}]}
    ${gia_ban}    Set Variable Return From Dict    ${dict_af_product["BasePrice"][${index}]}

    ${ton_kho}    Set Variable Return From Dict    ${dict_af_product["OnHand"][${index}]}
    ${dat_hang}    Set Variable Return From Dict    ${dict_af_product["Reserved"][${index}]}

    ${ton_min}    Set Variable Return From Dict    ${dict_af_product["MinQuantity"][${index}]}
    ${ton_max}    Set Variable Return From Dict    ${dict_af_product["MaxQuantity"][${index}]}

    ${index_master_unit}    Get Index From List    ${dict_af_product.Id}    ${dict_af_product["MasterUnitId"][${index}]}
    ${ma_dvt_co_ban}    Run KeyWord If    ${index_master_unit}<0    Set Variable    ${0}
    ...    ELSE    Set Variable Return From Dict    ${dict_af_product["Code"][${index_master_unit}]}

    ${index_master_product}    Get Index From List    ${dict_af_product.Id}    ${dict_af_product["MasterProductId"][${index}]}
    ${ma_hh_lien_quan}    Run KeyWord If    ${index_master_product}<0    Set Variable    ${0}
    ...    ELSE    Set Variable Return From Dict    ${dict_af_product["Code"][${index_master_product}]}

    ${mo_ta}    Run Keyword If    '${dict_af_product["Description"][${index}]}'==''    Set Variable    ${0}
    ...    ELSE    Set Variable Return From Dict    ${dict_af_product["Description"][${index}]}

    ${tich_diem}    Run KeyWord If    '${dict_af_product["IsRewardPoint"][${index}]}'=='True'    Set Variable    ${1}    ELSE    Set Variable    ${0}
    ${dang_kinh_doanh}    Run KeyWord If    '${dict_af_product["isActive"][${index}]}'=='True'    Set Variable    ${1}    ELSE    Set Variable    ${0}
    ${ban_truc_tiep}    Run KeyWord If    '${dict_af_product["AllowsSale"][${index}]}'=='True'    Set Variable    ${1}    ELSE    Set Variable    ${0}
    ${la_mon_them}    Run KeyWord If    '${dict_af_product["IsTopping"][${index}]}'=='True'    Set Variable    ${1}    ELSE    Set Variable    ${0}
    ${la_dich_vu_tinh_gio}    Run KeyWord If    '${dict_af_product["IsTimeType"][${index}]}'=='True'    Set Variable    ${1}    ELSE    Set Variable    ${0}

    #2
    ${dict_unit_detail}    Get dict unit detail info    ${dict_af_product["Id"][${index}]}    ${EMPTY}    $.Product..["ProductGroup","Weight","OrderTemplate","AttributeId","Value"]

    ${dict_loai_thuc_don}    Create Dictionary    1=Đồ ăn    2=Đồ uống    3=Khác
    ${loai_thuc_don}    Set Variable Return From Dict    ${dict_loai_thuc_don["${dict_unit_detail["ProductGroup"][0]}"]}

    ${ghi_chu}    Run Keyword If    '${dict_unit_detail["OrderTemplate"][0]}'==''    Set Variable    ${0}
    ...    ELSE    Set Variable Return From Dict    ${dict_unit_detail["OrderTemplate"][0]}

    #3
    ${list_giatri_tt}    Create List
    ${thuoc_tinh}    Set Variable    ${0}
    ${len_thuoc_tinh}    Get Length    ${dict_unit_detail.AttributeId}
    FOR    ${i}    IN RANGE    ${len_thuoc_tinh}
        Run Keyword If    ${dict_unit_detail.AttributeId[${i}]}==0    Continue For Loop
        ${index_thuoc_tinh}    Get Index From List    ${dict_attribute.Id}    ${dict_unit_detail.AttributeId[${i}]}
        ${name_thuoc_tinh}    Set Variable Return From Dict    ${dict_attribute.Name[${index_thuoc_tinh}]}
        Append To List    ${list_giatri_tt}    ${dict_unit_detail.Value[${i}]}
        ${thuoc_tinh}    Run KeyWord If    ${i}>0    Set Variable Return From Dict    ${thuoc_tinh}|${name_thuoc_tinh}:${dict_unit_detail.Value[${i}]}
        ...    ELSE    Set Variable Return From Dict    ${name_thuoc_tinh}:${dict_unit_detail.Value[${i}]}
    END

    # Cách lấy name
    #fullname: name[suffix_name]
    #suffix_name: [-TT1-TT2][ (dvt)]
    ${full_name}    Set Variable Return From Dict    ${dict_af_product["Name"][${index}]}
    ${don_vi_tinh}    Run Keyword If    '${dict_af_product["Unit"][${index}]}'!='${EMPTY}'    Set Variable Return From Dict    ${dict_af_product["Unit"][${index}]}
    ...    ELSE    Set Variable    ${0}
    ${gt_thuoc_tinh}    Set Variable    ${EMPTY}
    FOR    ${value_tt}    IN ZIP    ${list_giatri_tt}
        ${gt_thuoc_tinh}    Set Variable    ${gt_thuoc_tinh}-${value_tt}
    END

    ${ten_dvt}    Run Keyword If    '${don_vi_tinh}'!='0'    Set Variable    ${SPACE}(${don_vi_tinh})
    ...    ELSE    Set Variable    ${EMPTY}

    ${suffix_name}    Set Variable    ${gt_thuoc_tinh}${ten_dvt}
    ${suffix_name_length}    Get length    ${suffix_name}
    ${full_name_length}    Get length    ${full_name}
    ${name_length}    Evaluate    ${full_name_length}-${suffix_name_length}
    ${ten_hang_hoa}    Get Substring    ${full_name}   0   ${name_length}

    #4
    ${dict_material}    Get dict material info    ${dict_af_product["Id"][${index}]}    ["MaterialCode","Quantity"]
    ${thanh_phan}    Set Variable    ${0}
    ${len_thanh_phan}    Get Length    ${dict_material.MaterialCode}
    FOR    ${i}    IN RANGE    ${len_thanh_phan}
        ${thanh_phan}    Run KeyWord If    ${i}>0    Set Variable Return From Dict    ${thanh_phan}|${dict_material.MaterialCode[${i}]}:${dict_material.Quantity[${i}]}
        ...    ELSE    Set Variable Return From Dict    ${dict_material.MaterialCode[${i}]}:${dict_material.Quantity[${i}]}
    END
    ${thanh_phan}    Run Keyword If    '${thanh_phan}'=='0:0'    Set Variable    ${0}
    ...    ELSE    Set Variable    ${thanh_phan}

    #5
    ${dict_toping}    Get dict toping info    ${dict_af_product["Id"][${index}]}    Topping    $..Data[*].Topping.Code
    ${mon_them}    Set Variable    ${0}
    ${len_mon_them}    Get Length    ${dict_toping.Code}
    FOR    ${i}    IN RANGE    ${len_mon_them}
        ${mon_them}    Run KeyWord If    ${i}>0    Set Variable Return From Dict    ${mon_them}|${dict_toping.Code[${i}]}
        ...    ELSE    Set Variable Return From Dict    ${dict_toping.Code[${i}]}
    END
    ${mon_them}    Run Keyword If    '${mon_them}'=='0:0'    Set Variable    ${0}
    ...    ELSE    Set Variable    ${mon_them}

    #6
    # Thực hiện kiểm tra dict_filter_product có chứa Id mong muốn không? CÓ => result_id=True, KHÔNG => result_id=False
    # Ở đây True, False không làm testcase dừng lại mà sử dụng cho logic tiếp theo nên KHÔNG sử dụng KV List Should Contain Value
    ${result_id}    Run Keyword And Return Status    List Should Contain Value    ${dict_filter_product.Id}     ${dict_af_product["Id"][${index}]}
    # result_id=False thực hiện request API lấy thông tin vị trí, nhóm hàng theo chính xác mã hàng
    ${dict_unique_product}    Run Keyword If    '${result_id}'=='False'    Get dict filter product by keyword product code    ${input_ma_hang}    ["Id","ProductShelvesStr","CategoryNameTree"]
    ...    ELSE    Set Variable    ${dict_filter_product}
    ${index_nhomhang_vitri}    Get Index From List    ${dict_unique_product.Id}    ${dict_af_product["Id"][${index}]}
    ${vi_tri}    Set Variable Return From Dict    ${dict_unique_product.ProductShelvesStr[${index_nhomhang_vitri}]}
    ${nhom_hang}    Set Variable Return From Dict    ${dict_unique_product.CategoryNameTree[${index_nhomhang_vitri}]}

    #7
    ${dict_image}    Get dict image info    ${dict_af_product["Id"][${index}]}    ["Image"]
    ${len_hinh_anh}    Get Length    ${dict_image.Image}
    ${hinh_anh}    Run Keyword If    ${len_hinh_anh}>0 and '${dict_image.Image[0]}'!='0'    Catenate    SEPARATOR=,    @{dict_image.Image}
    ...    ELSE    Set Variable    ${0}

    Append To List    ${dict_api_value.loai_hang}    ${dict_loai_hang["${key_loai_hang}"]}
    Append To List    ${dict_api_value.loai_thuc_don}    ${loai_thuc_don}
    Append To List    ${dict_api_value.nhom_hang}    ${nhom_hang}
    Append To List    ${dict_api_value.ma_hang}    ${input_ma_hang}
    Append To List    ${dict_api_value.ten_hang}    ${ten_hang_hoa}
    Append To List    ${dict_api_value.gia_von}    ${gia_von}
    Append To List    ${dict_api_value.gia_ban}    ${gia_ban}
    Append To List    ${dict_api_value.ton_kho}    ${ton_kho}
    Append To List    ${dict_api_value.dat_hang}    ${dat_hang}
    Append To List    ${dict_api_value.ton_min}    ${ton_min}
    Append To List    ${dict_api_value.ton_max}    ${ton_max}
    Append To List    ${dict_api_value.ma_dvt_coban}    ${ma_dvt_co_ban}
    Append To List    ${dict_api_value.donvi_quydoi}    ${dict_af_product["ConversionValue"][${index}]}
    Append To List    ${dict_api_value.thuoc_tinh}    ${thuoc_tinh}
    Append To List    ${dict_api_value.ma_hh_lqan}    ${ma_hh_lien_quan}
    Append To List    ${dict_api_value.don_vi_tinh}    ${don_vi_tinh}
    Append To List    ${dict_api_value.hinh_anh}    ${hinh_anh}
    Append To List    ${dict_api_value.trong_luong}    ${dict_unit_detail["Weight"][0]}
    Append To List    ${dict_api_value.tich_diem}    ${tich_diem}
    Append To List    ${dict_api_value.dang_kd}    ${dang_kinh_doanh}
    Append To List    ${dict_api_value.ban_tt}    ${ban_truc_tiep}
    Append To List    ${dict_api_value.mo_ta}    ${mo_ta}
    Append To List    ${dict_api_value.ghi_chu}    ${ghi_chu}
    Append To List    ${dict_api_value.la_mon_them}    ${la_mon_them}
    Append To List    ${dict_api_value.la_dv_tinhgio}    ${la_dich_vu_tinh_gio}
    Append To List    ${dict_api_value.hang_thanh_phan}    ${thanh_phan}
    Append To List    ${dict_api_value.mon_them}    ${mon_them}
    Append To List    ${dict_api_value.vi_tri}    ${vi_tri}

Get response message delete frm API
    [Arguments]   ${input_product_id}
    ${dict_data}    Get dict unit detail info    ${input_product_id}    ${EMPTY}    $..Message    status_code_api=420
    ${resp_message}    Set Variable Return From Dict    ${dict_data.Message[0]}
    Return From Keyword    ${resp_message}

Check product is created successfully
    [Arguments]    ${product_code}
    ${pr_id}    Get product unit id frm API    ${product_code}
    ${result}    Run Keyword If    ${pr_id}>0    Set Variable    True    ELSE    Set Variable    False
    Return From Keyword    ${result}

# Assert danh sách hàng sử dụng món thêm
Assert thong tin tab Hang su dung mon them
    [Arguments]   ${ma_hh}    ${list_hang_use_topping}
    ${get_list_ma_hang}   Get list product use topping by code   ${ma_hh}
    KV Lists Should Be Equal    ${list_hang_use_topping}    ${get_list_ma_hang}    msg=Lỗi không tồn tại mã hàng trong Danh sách hàng sử dụng món thêm

# Assert danh sách món thêm
Assert thong tin tab Mon them
    [Arguments]   ${ma_hh}    ${list_hang_topping}
    ${get_list_ma_hang}    Get list topingCode of product by code   ${ma_hh}
    KV Lists Should Be Equal    ${list_hang_topping}    ${get_list_ma_hang}    msg=Lỗi không tồn tại mã hàng trong danh sách hàng topping

Kiem tra tong hang hoa va ma hang trong API
    [Arguments]    ${count_tong_hh}    ${count_tong_ma_hang}
    ${get_tong_hang_hoa}    Get tong so luong hang hoa
    ${get_tong_ma_hang}   Get tong so ma hang
    KV Should Be Equal As Integers    ${get_tong_hang_hoa}    ${count_tong_hh}    msg=Lỗi sai tổng hàng hóa
    KV Should Be Equal As Integers    ${get_tong_ma_hang}    ${count_tong_ma_hang}    msg=Lỗi sai tổng mã hàng

Kiem tra tong hang hoa va ma hang tren UI
    [Arguments]    ${get_text_tong_HH}    ${get_text_tong_ma_hang}    ${count_tong_hh}    ${count_tong_ma_hang}
    KV Should Be Equal As Integers    ${get_text_tong_HH}    ${count_tong_hh}    msg=Lỗi sai tổng hh trên UI
    Run Keyword If    ${get_text_tong_ma_hang} > 0    KV Should Be Equal As Integers    ${get_text_tong_ma_hang}    ${count_tong_ma_hang}    msg=Lỗi sai tổng mã hàng trên UI

Assert thong tin tong hang hoa va ma hang
    [Arguments]   ${count_tong_hh_sau_them_moi}    ${count_tong_ma_hang_sau_them_moi}
    ${get_text_tong_HH}    ${get_text_tong_ma_hang}   Get text tong hang hoa va tong ma hang
    Run Keyword If    ${get_text_tong_HH} > 0    Kiem tra tong hang hoa va ma hang tren UI    ${get_text_tong_HH}    ${get_text_tong_ma_hang}
    ...    ${count_tong_hh_sau_them_moi}    ${count_tong_ma_hang_sau_them_moi}
    ...   ELSE   Kiem tra tong hang hoa va ma hang trong API    ${count_tong_hh_sau_them_moi}    ${count_tong_ma_hang_sau_them_moi}

Assert tab The kho va Ton kho sau khi them moi hang hoa thuong
    [Arguments]   ${ma_hh}    ${input_ton_kho}    ${input_gia_von}
    ${get_gia_von}    ${get_SL}    Get The kho gia von va so luong frm API    ${ma_hh}
    KV Should Be Equal As Numbers    ${input_ton_kho}    ${get_SL}    msg=Lỗi sai tồn kho
    KV Should Be Equal As Numbers    ${input_gia_von}    ${get_gia_von}    msg=Lỗi sai giá vốn
    Assert tab Ton kho sau khi them moi hang thuong    ${ma_hh}    ${input_ton_kho}

Assert tab Ton kho sau khi them moi hang thuong
    [Arguments]   ${ma_hh}    ${input_ton_kho}
    ${tonkho_theo_CN}    Get Ton kho theo chi nhanh frm API    ${ma_hh}
    KV Should Be Equal As Numbers    ${input_ton_kho}    ${tonkho_theo_CN}    msg=Lỗi sai tồn kho theo chi nhánh

Assert The kho so luong hang san xuat
    [Arguments]    ${input_sochungtu}    ${input_mahang}    ${input_soluong_sx}
    ${soluong_thekho}    Get The kho so luong frm API    ${input_sochungtu}    ${input_mahang}
    KV Should Be Equal As Numbers    ${soluong_thekho}    ${input_soluong_sx}    msg=Lỗi sai số lượng trong bản ghi thẻ kho

Assert The kho so luong hang thanh phan
    [Arguments]    ${input_sochungtu}    ${input_list_mahangtp}    ${input_list_soluongtpsx}
    ${list_soluong_thekho}    Get The kho so luong hang thanh phan    ${input_sochungtu}    ${input_list_mahangtp}
    KV Lists Should Be Equal    ${input_list_soluongtpsx}    ${list_soluong_thekho}    msg=Lỗi sai số lượng trong bản ghi thẻ kho

Assert Ton kho theo chi nhanh
    [Arguments]    ${ma_hh}    ${input_ton_kho}
    ${ton_kho_CN}    Get Ton kho theo chi nhanh frm API    ${ma_hh}
    KV Should Be Equal As Numbers    ${input_ton_kho}    ${ton_kho_CN}    msg=Lỗi sai tồn kho theo chi nhánh

Assert Ton kho hang thanh phan theo chi nhanh
    [Arguments]    ${input_list_mahangtp}    ${input_list_tonkhotp}
    FOR    ${item_ma_hangtp}    ${item_tonkhotp}    IN ZIP    ${input_list_mahangtp}    ${input_list_tonkhotp}
        ${ton_kho_tp}    Get Ton kho theo chi nhanh frm API    ${item_ma_hangtp}
        KV Should Be Equal As Numbers    ${item_tonkhotp}    ${ton_kho_tp}    msg=Lỗi sai tồn kho
    END

Assert thong tin tao moi nhom hang
    [Arguments]   ${ten_nhom_hang}
    ${list_all_nhom_hang}   Get danh sach nhom hang from API
    KV List Should Contain Value    ${list_all_nhom_hang}    ${ten_nhom_hang}    msg=Lỗi nhóm hàng mới tạo không tồn tại trong hệ thống

Assert thong tin tao moi vi tri
    [Arguments]   ${ten_vi_tri}
    ${list_all_vi_tri}   Get danh sach vi tri from API
    KV List Should Contain Value    ${list_all_vi_tri}    ${ten_vi_tri}    msg=Lỗi vị trí mới tạo không tồn tại trong hệ thống

Assert thong tin tao moi thuoc tinh
    [Arguments]   ${ten_thuoc_tinh}
    ${ten_thuoc_tinh}   Convert To Uppercase    ${ten_thuoc_tinh}
    ${list_all_thuoc_tinh}   Get danh sach thuoc tinh from API
    KV List Should Contain Value    ${list_all_thuoc_tinh}    ${ten_thuoc_tinh}    msg=Lỗi thuộc tính mới tạo không tồn tại trong hệ thống

# Assert các trường require thêm mới hàng hóa bao gồm tên, loại thực đơn, nhóm hàng, giá bán
Assert data tab thong tin in case create product required field
    [Arguments]    ${input_ma_hang}    ${input_ten_sp}    ${input_loai_thucdon}    ${input_nhom_hang}    ${input_gia_ban}
    ${result_dict}    Get dict all field product info by product code    ${input_ma_hang}    ["Name","CategoryName","BasePrice"]
    ${ten_sp}      Set Variable Return From Dict    ${result_dict.Name[0]}
    ${nhom_hang}   Set Variable Return From Dict    ${result_dict.CategoryName[0]}
    ${gia_ban}     Set Variable Return From Dict    ${result_dict.BasePrice[0]}
    ${loai_thuc_don}   Get Product group of product by code    ${input_ma_hang}
    KV Should Contain    ${ten_sp}    ${input_ten_sp}    msg=Lỗi sai tên hàng hóa
    KV Should Be Equal As Strings    ${loai_thuc_don}    ${input_loai_thucdon}    msg=Lỗi sai thông tin Loại thực đơn
    KV Should Be Equal As Strings    ${nhom_hang}    ${input_nhom_hang}    msg=Lỗi sai thông tin Nhóm hàng
    KV Should Be Equal As Numbers    ${gia_ban}    ${input_gia_ban}    msg=Lỗi sai thông tin Giá bán

# Assert các trường require thêm mới hàng hóa bao gồm tên, loại thực đơn, nhóm hàng, giá bán và giá vốn
Assert data tab thong tin in case create service product required field
    [Arguments]    ${input_ma_hang}    ${input_ten_sp}    ${input_loai_thucdon}    ${input_nhom_hang}    ${input_gia_von}    ${input_gia_ban}
    ${result_dict}    Get dict all field product info by product code    ${input_ma_hang}    ["Name","CategoryName","BasePrice","Cost"]
    ${ten_sp}      Set Variable Return From Dict    ${result_dict.Name[0]}
    ${nhom_hang}   Set Variable Return From Dict    ${result_dict.CategoryName[0]}
    ${gia_ban}     Set Variable Return From Dict    ${result_dict.BasePrice[0]}
    ${gia_von}     Set Variable Return From Dict    ${result_dict.Cost[0]}
    ${loai_thuc_don}    Get Product group of product by code    ${input_ma_hang}
    KV Should Contain    ${ten_sp}    ${input_ten_sp}    msg=Lỗi sai tên hàng hóa
    KV Should Be Equal As Strings    ${loai_thuc_don}    ${input_loai_thucdon}    msg=Lỗi sai thông tin Loại thực đơn
    KV Should Be Equal As Strings    ${nhom_hang}    ${input_nhom_hang}    msg=Lỗi sai thông tin Nhóm hàng
    KV Should Be Equal As Numbers    ${gia_von}    ${input_gia_von}    msg=Lỗi sai thông tin Giá vốn
    KV Should Be Equal As Numbers    ${gia_ban}    ${input_gia_ban}    msg=Lỗi sai thông tin Giá bán

# Assert các trường require thêm mới hàng hóa bao gồm tên, loại thực đơn, nhóm hàng, giá bán và giá vốn
Assert create time service product required field
    [Arguments]    ${input_ma_hang}
    [Timeout]    3 minutes
    ${IsTimeType}    Get IsTimeType of product by code    ${input_ma_hang}
    KV Should Be Equal As Numbers    ${IsTimeType}    1    msg=Lỗi hàng hóa không phải hàng dịch vụ tính giờ

# Assert tạo hàng có list nhiều thành phần
Assert data in case create material of product
    [Arguments]    ${input_ma_hang}    ${input_dict_hangtp}
    ${list_hangtp}    ${list_soluong_tp}    Get list materialCode and quantity of product by code    ${input_ma_hang}
    KV Lists Should Be Equal    ${list_hangtp}    ${input_dict_hangtp.list_ma_hangtp}    msg=Lỗi sai danh sách mã hàng thành phần
    KV Lists Should Be Equal    ${list_soluong_tp}    ${input_dict_hangtp.list_soluong_tp}    msg=Lỗi sai số lượng hàng thành phần

Assert gia tri thuoc tinh
    [Arguments]   ${ma_hh}   ${ten_thuoctinh}    ${gia_tri_thuoc_tinh}
    ${get_list_ten_thuoctinh}    ${get_list_gia_tri_thuoc_tinh}   Get list attribute name and value of product by code    ${ma_hh}
    ${get_gia_tri_thuoc_tinh}   Get From List    ${get_list_gia_tri_thuoc_tinh}    0
    ${get_ten_thuoc_tinh}   Get From List    ${get_list_ten_thuoctinh}    0
    Run Keyword If    '${ten_thuoctinh}' != ''    KV Should Be Equal As Strings    ${get_ten_thuoc_tinh}    ${ten_thuoctinh}    msg=Lỗi sai tên thuộc tính    ignore_case=True
    KV Should Be Equal As Strings    ${get_gia_tri_thuoc_tinh}    ${gia_tri_thuoc_tinh}    msg=Lỗi sai tên giá trị thuộc tính    ignore_case=True

Assert thong tin don vi tinh
    [Arguments]   ${ma_hh}   ${ten_dvt}   ${gia_tri_quy_doi}
    ${get_ten_dvt}    Get base unit of product by code    ${ma_hh}
    ${get_gia_tri_quy_doi}    Get DVQD of product by code    ${ma_hh}
    KV Should Be Equal As Strings    ${ten_dvt}    ${get_ten_dvt}    msg=Lỗi sai tên đơn vị tính
    KV Should Be Equal As Integers    ${gia_tri_quy_doi}    ${get_gia_tri_quy_doi}    msg=Lỗi sai giá trị quy đổi

Assert danh sach hang thanh phan
    [Arguments]   ${ma_hh}    ${input_list_hang_TP}   ${input_list_SL_hang_TP}
    ${list_hangtp}    ${list_soluong_tp}    Get list materialCode and quantity of product by code    ${ma_hh}
    ${list_number_SL_hang_TP}   Create List
    FOR   ${item_SL}    IN    @{input_list_SL_hang_TP}
        ${SL_convert}    Convert To Number    ${item_SL}
        Append To List    ${list_number_SL_hang_TP}    ${SL_convert}
        KV Log    ${list_number_SL_hang_TP}
    END
    KV Lists Should Be Equal    ${list_hangtp}    ${input_list_hang_TP}    msg=Lỗi sai danh sách mã hàng thành phần
    KV Lists Should Be Equal    ${list_soluong_tp}    ${list_number_SL_hang_TP}    msg=Lỗi sai số lượng hàng thành phần

Assert thong tin topping
    [Arguments]   ${ma_hh}    ${ten_hh}   ${loai_thuc_don}    ${ten_nhom_hang}    ${gia_ban}    ${list_hang_use_topping}
    ${isTopping_value}    Get IsTopping of product by code    ${ma_hh}
    KV Should Be Equal As Integers    ${isTopping_value}    1     msg=Lỗi không phải hàng topping
    Assert data tab thong tin in case create product required field    ${ma_hh}    ${ten_hh}   ${loai_thuc_don}    ${ten_nhom_hang}    ${gia_ban}
    Assert thong tin tab Hang su dung mon them    ${ma_hh}    ${list_hang_use_topping}

Assert thong tin topping la hang che bien
    [Arguments]   ${ma_hh}    ${ten_hh}   ${loai_thuc_don}    ${ten_nhom_hang}    ${gia_ban}    ${list_hang_use_topping}    ${list_hang_TP}   ${list_SL_hang_TP}
    ${isTopping_value}    Get IsTopping of product by code    ${ma_hh}
    KV Should Be Equal As Integers    ${isTopping_value}    1    msg=Lỗi không phải hàng topping
    Assert data tab thong tin in case create product required field    ${ma_hh}    ${ten_hh}   ${loai_thuc_don}
    ...    ${ten_nhom_hang}    ${gia_ban}
    Assert thong tin tab Hang su dung mon them    ${ma_hh}    ${list_hang_use_topping}
    Assert danh sach hang thanh phan    ${ma_hh}    ${list_hang_TP}   ${list_SL_hang_TP}

Assert thong tin sau khi them moi hang hoa
    [Arguments]   ${ma_hh}    ${ten_hh}   ${loai_thuc_don}   ${nhom_hang}    ${vitri}    ${giavon}   ${giaban}   ${tonkho}   ${trongluong}   ${hinhanh}
    ...   ${ten_thuoctinh}    ${gia_tri_thuoc_tinh}   ${ten_dvt}   ${gia_tri_quy_doi}    ${ton_NN}   ${ton_LN}   ${mota}   ${mau_ghichu}
    ${result_dict}   Get dict all field product info by product code    ${ma_hh}    ["Name","CategoryName","BasePrice","Cost","OnHand","MinQuantity","MaxQuantity","Description"]
    ${get_ten_sp}        Set Variable Return From Dict    ${result_dict.Name[0]}
    ${get_nhom_hang}     Set Variable Return From Dict    ${result_dict.CategoryName[0]}
    ${get_giaban}    Set Variable Return From Dict    ${result_dict.BasePrice[0]}
    ${get_giavon}    Set Variable Return From Dict    ${result_dict.Cost[0]}
    ${get_tonkho}    Set Variable Return From Dict    ${result_dict.OnHand[0]}
    ${get_ton_NN}    Set Variable Return From Dict    ${result_dict.MinQuantity[0]}
    ${get_ton_LN}    Set Variable Return From Dict    ${result_dict.MaxQuantity[0]}
    ${get_mota}      Set Variable Return From Dict    ${result_dict.Description[0]}

    ${get_loai_thuc_don}   Get Product group of product by code    ${ma_hh}
    ${get_list_vitri}      Get list vi tri by code    ${ma_hh}
    ${get_trongluong}      Get weight of product by code    ${ma_hh}
    ${get_mau_ghichu}      Get mau ghi chu of product by code    ${ma_hh}

    ${tonkho}=    Run Keyword If    '${tonkho}' != ''   Convert To Number    ${tonkho}    ELSE    Set Variable    ${EMPTY}
    KV Should Contain    ${get_ten_sp}    ${ten_hh}    msg=Lỗi sai tên hàng hóa
    KV Should Be Equal As Strings    ${get_loai_thuc_don}    ${loai_thuc_don}    msg=Lỗi sai thông tin Loại thực đơn
    KV Should Be Equal As Strings    ${get_nhom_hang}    ${nhom_hang}    msg=Lỗi sai thông tin Nhóm hàng
    KV Should Be Equal As Numbers    ${get_giaban}    ${giaban}    msg=Lỗi sai thông tin Giá bán
    KV Should Be Equal As Strings    ${get_mota}    ${mota}    msg=Lỗi sai thông tin mô tả
    KV Should Be Equal As Strings    ${get_mau_ghichu}    ${mau_ghichu}    msg=Lỗi sai thông tin mẫu ghi chú
    KV Should Be Equal As Numbers    ${get_trongluong}    ${trongluong}    msg=Lỗi sai trọng lượng
    KV List Should Contain Value    ${get_list_vitri}    ${vitri}    msg=Lỗi không tồn tại vị trí trong hệ thống
    Run Keyword If    '${giavon}' != ''    KV Should Be Equal As Numbers    ${get_giavon}    ${giavon}    msg=Lỗi sai giá vốn
    Run Keyword If    '${tonkho}' != ''    KV Should Be Equal As Numbers    ${get_tonkho}    ${tonkho}    msg=lỗi sai tồn kho
    Run Keyword If    '${ten_dvt}' != ''   Assert thong tin don vi tinh     ${ma_hh}    ${ten_dvt}   ${gia_tri_quy_doi}
    Run Keyword If    '${ton_NN}' != ''    KV Should Be Equal As Numbers    ${get_ton_NN}    ${ton_NN}    msg=Lỗi sai giá trị tồn nhỏ nhất
    Run Keyword If    '${ton_LN}' != ''    KV Should Be Equal As Numbers    ${get_ton_LN}    ${ton_LN}    msg=Lỗi sai giá trị tồn lớn nhất
    Run Keyword If    '${ten_thuoctinh}' != ''    Assert gia tri thuoc tinh   ${ma_hh}    ${ten_thuoctinh}    ${gia_tri_thuoc_tinh}

# Assert data các trường không bắt buộc + thuộc tính trong thêm mới hàng sản xuất
Assert data tab thong tin in case create product minor field attribute
    [Arguments]    ${ma_hh}    ${vitri}    ${trongluong}    ${hinhanh}    ${ten_thuoctinh}    ${gia_tri_thuoc_tinh}    ${ton_min}    ${ton_max}
    ...    ${mota}    ${mau_ghichu}
    ${get_ton_NN}    ${get_ton_LN}    Get MinQuantity and MaxQuantity of product by code    ${ma_hh}
    KV Should Be Equal As Numbers    ${get_ton_NN}    ${ton_min}    msg=Lỗi sai giá trị tồn nhỏ nhất
    KV Should Be Equal As Numbers    ${get_ton_LN}    ${ton_max}    msg=Lỗi sai giá trị tồn lớn nhất
    Assert data tab thong tin in case create product no minmaxquant minor field attribute    ${ma_hh}    ${vitri}    ${trongluong}   ${hinhanh}
    ...    ${ten_thuoctinh}    ${gia_tri_thuoc_tinh}    ${mota}    ${mau_ghichu}

# Assert data các trường không bắt buộc + đơn vị tính trong thêm mới hàng sản xuất
Assert data tab thong tin in case create product minor field unit
    [Arguments]    ${ma_hh}    ${vitri}    ${trongluong}    ${hinhanh}    ${don_vi_tinh}    ${ton_min}    ${ton_max}    ${mota}    ${mau_ghichu}
    ${get_ton_NN}    ${get_ton_LN}    Get MinQuantity and MaxQuantity of product by code    ${ma_hh}
    KV Should Be Equal As Numbers    ${get_ton_NN}    ${ton_min}    msg=Lỗi sai giá trị tồn nhỏ nhất
    KV Should Be Equal As Numbers    ${get_ton_LN}    ${ton_max}    msg=Lỗi sai giá trị tồn lớn nhất
    Assert data tab thong tin in case create product no minmaxquant minor field unit    ${ma_hh}    ${vitri}    ${trongluong}    ${hinhanh}    ${don_vi_tinh}
    ...    ${mota}    ${mau_ghichu}

# Assert data các trường không bắt buộc + thuộc tính trong thêm mới hàng chế biến
Assert data tab thong tin in case create product no minmaxquant minor field attribute
    [Arguments]    ${ma_hh}    ${vitri}    ${trongluong}    ${hinhanh}    ${ten_thuoctinh}    ${gia_tri_thuoc_tinh}    ${mota}    ${mau_ghichu}
    ${get_list_vitri}    Get list vi tri by code    ${ma_hh}
    ${get_trongluong}   Get weight of product by code    ${ma_hh}
    KV List Should Contain Value    ${get_list_vitri}    ${vitri}    msg=Lỗi vị trí không tồn tại trong hệ thống
    KV Should Be Equal As Numbers    ${get_trongluong}    ${trongluong}    msg=Lỗi sai trọng lượng
    Assert data tab thong tin in case create product no shelves weight minor field attribute    ${ma_hh}   ${hinhanh}    ${ten_thuoctinh}    ${gia_tri_thuoc_tinh}
    ...    ${mota}    ${mau_ghichu}

# Assert data các trường không bắt buộc + đơn vị tính trong thêm mới hàng chế biến
Assert data tab thong tin in case create product no minmaxquant minor field unit
    [Arguments]    ${ma_hh}    ${vitri}    ${trongluong}    ${hinhanh}    ${don_vi_tinh}    ${mota}    ${mau_ghichu}
    ${get_list_vitri}    Get list vi tri by code    ${ma_hh}
    ${get_trongluong}   Get weight of product by code    ${ma_hh}
    KV List Should Contain Value    ${get_list_vitri}    ${vitri}    msg=Lỗi vị trí không tồn tại trong hệ thống
    KV Should Be Equal As Numbers    ${get_trongluong}    ${trongluong}    msg=Lỗi sai trọng lượng
    Assert data tab thong tin in case create product no shelves weight minor field unit    ${ma_hh}   ${hinhanh}    ${don_vi_tinh}    ${mota}    ${mau_ghichu}

# Assert data các trường không bắt buộc + thuộc tính trong thêm mới hàng dịch vụ
Assert data tab thong tin in case create product no shelves weight minor field attribute
    [Arguments]    ${ma_hh}    ${hinhanh}    ${ten_thuoctinh}    ${gia_tri_thuoc_tinh}    ${mota}    ${mau_ghichu}
    # ${get_hinhanh}
    ${get_list_ten_thuoctinh}    ${get_list_gia_tri_thuoc_tinh}   Get list attribute name and value of product by code    ${ma_hh}
    ${get_mota}    Get mo ta of product by code    ${ma_hh}
    ${get_mau_ghichu}   Get mau ghi chu of product by code    ${ma_hh}
    ${get_ten_thuoc_tinh}   Get From List    ${get_list_ten_thuoctinh}    0
    ${get_gia_tri_thuoc_tinh}   Get From List    ${get_list_gia_tri_thuoc_tinh}    0
    KV Should Be Equal As Strings    ${get_ten_thuoc_tinh}    ${ten_thuoctinh}    msg=Lỗi sai tên thuộc tính    ignore_case=True
    KV Should Be Equal As Strings    ${get_gia_tri_thuoc_tinh}    ${gia_tri_thuoc_tinh}    msg=Lỗi sai giá trị thuộc tính    ignore_case=True
    KV Should Be Equal As Strings    ${get_mota}    ${mota}     msg=Lỗi sai thông tin mô tả
    KV Should Be Equal As Strings    ${get_mau_ghichu}    ${mau_ghichu}    msg=Lỗi sai thông tin mẫu ghi chú

# Assert data các trường không bắt buộc + đơn vị tính trong thêm mới hàng dịch vụ
Assert data tab thong tin in case create product no shelves weight minor field unit
    [Arguments]    ${ma_hh}    ${hinhanh}    ${don_vi_tinh}    ${mota}    ${mau_ghichu}
    # ${get_hinhanh}
    ${get_don_vi_tinh}    Get base unit of product by code    ${ma_hh}
    ${get_mota}    Get mo ta of product by code    ${ma_hh}
    ${get_mau_ghichu}   Get mau ghi chu of product by code    ${ma_hh}
    KV Should Be Equal As Strings    ${get_don_vi_tinh}    ${don_vi_tinh}    msg=Lỗi sai đơn vị tính    ignore_case=True
    KV Should Be Equal As Strings    ${get_mota}    ${mota}     msg=Lỗi sai thông tin mô tả
    KV Should Be Equal As Strings    ${get_mau_ghichu}    ${mau_ghichu}    msg=Lỗi sai thông tin mẫu ghi chú

Assert thong tin chuyen nhom hang cho nhieu hang hoa
    [Arguments]   ${list_full_ma_hang}    ${ten_nhom_hang}
    Assert thong tin tao moi nhom hang    ${ten_nhom_hang}
    FOR   ${item_ma_hang}   IN    @{list_full_ma_hang}
        ${item_nhom_hang}   Get Category name of product by code    ${item_ma_hang}
        KV Should Be Equal As Strings    ${ten_nhom_hang}    ${item_nhom_hang}    msg=Lỗi sai tên nhóm hàng    ignore_case=True
    END

Assert thong tin doi loai thuc don cho nhieu hang hoa
    [Arguments]   ${list_full_ma_hang}   ${ten_loai_thuc_don}
    FOR   ${item_ma_hang}   IN    @{list_full_ma_hang}
        ${item_loai_thuc_don}   Get Product group of product by code    ${item_ma_hang}
        KV Should Be Equal As Strings    ${ten_loai_thuc_don}    ${item_loai_thuc_don}    msg=Lỗi sai Loại thực đơn    ignore_case=True
    END

Assert thong tin trang thai kinh doanh cho nhieu hang hoa
    [Arguments]   ${list_full_ma_hang}    ${status}
    FOR    ${item_ma_hang}   IN    @{list_full_ma_hang}
        ${item_status}    Get IsActive of product by code    ${item_ma_hang}
        KV Should Be Equal As Integers    ${status}    ${item_status}    msg=Lỗi sai trạng thái hàng hóa
    END

Assert thong tin sau khi xoa nhieu hang hoa
    [Arguments]   ${list_full_id}    ${input_message}
    FOR    ${item_id_hang}    IN    @{list_full_id}
        ${resp_message}    Get response message delete frm API   ${item_id_hang}
        KV Should Be Equal As Strings    ${input_message}    ${resp_message}    msg=Lỗi sai message khi xóa HH    ignore_case=True
    END

Assert thong tin trang thai kinh doanh mot hang hoa
    [Arguments]   ${input_ma_hang}    ${input_status}
    ${tt_kinh_doanh}   Get IsActive of product by code    ${input_ma_hang}
    KV Should Be Equal As Numbers    ${tt_kinh_doanh}    ${input_status}    msg=Lỗi sai tình trạng kinh doanh

Assert thong tin sau khi xoa mot hang hoa
    [Arguments]   ${input_product_id}    ${input_message}
    ${resp_message}    Get response message delete frm API   ${input_product_id}
    KV Should Be Equal As Strings    ${input_message}    ${resp_message}    msg=Lỗi sai message khi xóa HH     ignore_case=True

Assert thong tin gia von va ton kho sau giao dich
    [Arguments]    ${ma_phieu}    ${ma_hh}    ${input_toncuoi}    ${input_num}    ${input_giavon}    ${count_giavon}
    Assert values in Stock Card    ${ma_phieu}    ${ma_hh}    ${input_toncuoi}    ${input_num}
    KV Should Be Equal As Numbers    ${input_giavon}    ${count_giavon}    msg=Lỗi sai giá vốn

Assert values in Stock Card
    [Arguments]    ${ma_phieu}    ${ma_hh}    ${input_toncuoi}    ${input_num}
    ${soluong_in_thekho}    ${toncuoi_in_thekho}    Get Stock Card info frm API    ${ma_phieu}    ${ma_hh}
    KV Should Be Equal As Numbers    ${toncuoi_in_thekho}    ${input_toncuoi}    msg=Lỗi sai tồn cuối trong thẻ kho HH
    KV Should Be Equal As Numbers    ${soluong_in_thekho}    ${input_num}    msg=Lỗi sai số lượng trong thẻ kho HH

Assert values in Stock Card exclude negative
    [Arguments]    ${ma_phieu}    ${ma_hh}    ${input_toncuoi}    ${input_num}
    ${soluong_in_thekho}    ${toncuoi_in_thekho}    Get Stock Card info exclude negative frm API    ${ma_phieu}    ${ma_hh}
    KV Should Be Equal As Numbers    ${toncuoi_in_thekho}    ${input_toncuoi}    Lỗi tồn cuối input và trong API khác nhau
    KV Should Be Equal As Numbers    ${soluong_in_thekho}    ${input_num}    Lỗi số lượng input và trong API khác nhau

Assert values not avaiable in Stock Card
    [Arguments]    ${input_ma_chungtu}    ${ma_hh}
    ${all_docs}    Get all documents in Stock Card    ${ma_hh}
    KV List Should Not Contain Value    ${all_docs}    ${input_ma_chungtu}    Lỗi danh sách vẫn chứa mã chứng từ đã hủy

# Lấy list tên của hàng
Get list product name by code
    [Arguments]    ${list_pr_code}
    ${list_result_name}    Create List
    FOR    ${item_code}    IN ZIP    ${list_pr_code}
        ${dict_data}    Get dict all field product info by product code    ${item_code}    ["Name"]
        ${product_name}    Set Variable Return From Dict    ${dict_data.Name[0]}
        Append To List    ${list_result_name}      ${product_name}
    END
    Return From Keyword    ${list_result_name}

Get name va gia ban product by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["BasePrice","Name"]
    ${giaban}    Set Variable Return From Dict    ${dict_data.BasePrice[0]}
    ${name}    Set Variable Return From Dict    ${dict_data.Name[0]}
    Return From Keyword    ${name}    ${giaban}

Get list name va gia ban product by code
    [Arguments]    ${list_pr_code}
    ${list_name}    Create List
    ${list_price}    Create List
    FOR    ${pr_code}    IN ZIP    ${list_pr_code}
        ${name}    ${giaban}    Get name va gia ban product by code    ${pr_code}
        Append To List    ${list_name}   ${name}
        Append To List    ${list_price}   ${giaban}
    END
    Return From Keyword    ${list_name}    ${list_price}

Get name ton kho va so luong dat product by code
    [Arguments]    ${product_code}
    ${dict_data}    Get dict all field product info by product code    ${product_code}    ["OnHand","Name","Reserved"]
    ${tonkho}    Set Variable Return From Dict    ${dict_data.OnHand[0]}
    ${name}    Set Variable Return From Dict    ${dict_data.Name[0]}
    ${sl_dat}    Set Variable Return From Dict    ${dict_data.Reserved[0]}
    Return From Keyword    ${name}    ${tonkho}    ${sl_dat}

Get list name ton kho va so luong dat product by code
    [Arguments]    ${list_product_code}
    ${list_name}    Create List
    ${list_tonkho}    Create List
    ${list_sl_dat}    Create List
    FOR    ${pr_code}    IN ZIP    ${list_product_code}
        ${name}    ${tonkho}    ${sl_dat}    Get name ton kho va so luong dat product by code    ${pr_code}
        Append To List    ${list_name}    ${name}
        Append To List    ${list_tonkho}    ${tonkho}
        Append To List    ${list_sl_dat}    ${sl_dat}
    END
    Return From Keyword    ${list_name}    ${list_tonkho}    ${list_sl_dat}

Assert thong tin ve tien cua hang hoa theo api
    [Arguments]    ${ma_hang_hoa}    ${text_giaban}    ${text_giavon}    ${text_tonkho}
    ${result_dict}    Get dict filter product by keyword product code    ${ma_hang_hoa}    ["BasePrice","Cost","OnHand"]

    KV Should Be Equal As Numbers    ${text_giaban}    ${result_dict.BasePrice[0]}    msg=Hiển thị sai thông tin giá bán của hàng hóa
    KV Should Be Equal As Numbers    ${text_giavon}    ${result_dict.Cost[0]}         msg=Hiển thị sai thông tin giá vốn của hàng hóa
    KV Should Be Equal As Numbers    ${text_tonkho}    ${result_dict.OnHand[0]}       msg=Hiển thị sai thông tin tồn kho của hàng hóa

Assert thong tin ve tien cua chi tiet hang hoa theo api
    [Arguments]    ${ma_hang_hoa}    ${text_giaban}    ${text_giavon}
    ${result_dict}    Get dict filter product by keyword product code    ${ma_hang_hoa}    ["BasePrice","Cost"]

    KV Should Be Equal As Numbers    ${text_giaban}    ${result_dict.BasePrice[0]}    msg=Hiển thị sai thông tin giá bán của hàng hóa
    KV Should Be Equal As Numbers    ${text_giavon}    ${result_dict.Cost[0]}         msg=Hiển thị sai thông tin giá vốn của hàng hóa
