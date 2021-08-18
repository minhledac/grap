*** Settings ***
Library           SeleniumLibrary
Library           String
Library           BuiltIn
Resource          ../../api_access.robot
Resource          api_danhmuc_hanghoa.robot

*** Variables ***

*** Keywords ***
# Lấy danh sách all bảng giá trong shop
Get dict all pricebook info
    [Arguments]    ${jsonpath_value}
    ${result_dict}    API Call From Template    /bang-gia/all_bang_gia.txt    ${EMPTY}    ${jsonpath_value}
    Return From Keyword    ${result_dict}

Get dict detail pricebook info
    [Arguments]    ${id_bang_gia}    ${jsonpath_value}    ${id_nhom_hang}=${EMPTY}    ${ten_ma_hang_hoa}=${EMPTY}    ${page_size}=${EMPTY}
    ${filter_category_id}    Set Variable If    '${id_nhom_hang}'!='${EMPTY}'    CategoryId+eq+${id_nhom_hang}    ${EMPTY}
    ${filter_pr_name}        Set Variable If    '${ten_ma_hang_hoa}'!='${EMPTY}'    (substringof(%27${ten_ma_hang_hoa}%27%2CFullName)+or+substringof(%27${ten_ma_hang_hoa}%27%2CCode))    ${EMPTY}
    ${data_filter}    Set Variable If    '${filter_pr_name}'=='${EMPTY}'    ${filter_category_id}    ${filter_pr_name}+and+${filter_category_id}
    ${data_filter}    Set Variable If    '${filter_category_id}'=='${EMPTY}' and '${filter_pr_name}'=='${EMPTY}'    ${EMPTY}    ,"%24filter=(${data_filter})"
    ${find_dict}    Create Dictionary    Id_BG=${id_bang_gia}    page_size=${page_size}    data_filter=${data_filter}    ten_ma_hang_hoa=${ten_ma_hang_hoa}
    ${result_dict}    API Call From Template    /bang-gia/detail_bang_gia.txt    ${find_dict}    ${jsonpath_value}
    Return From Keyword    ${result_dict}

Get pricebook id frm API
    [Arguments]    ${input_ten_banggia}
    ${jsonpath}    Set Variable    $.Data[?(@.Name\=\="${input_ten_banggia}")].["Id"]
    ${result_dict}    Get dict all pricebook info    ${jsonpath}
    ${result_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${result_id}

Get list pricebook id
    [Arguments]
    ${jsonpath}    Set Variable    $.Data.["Id"]
    ${result_dict}    Get dict all pricebook info    ${jsonpath}
    ${list_id}    Set Variable Return From Dict    ${result_dict.Id}
    Return From Keyword    ${list_id}

Get PriceBook name by id
    [Arguments]    ${input_id_banggia}
    ${jsonpath}    Set Variable    $.Data[?(@.Id\=\=${input_id_banggia})].["Name"]
    ${result_dict}    Get dict all pricebook info    ${jsonpath}
    ${name}    Set Variable Return From Dict    ${result_dict.Name[0]}
    Return From Keyword    ${name}

Get list Pricebook name frm API
    [Arguments]
    ${jsonpath}    Set Variable    $.Data[*].["Name"]
    ${result_dict}    Get dict all pricebook info    ${jsonpath}
    ${list_name}    Set Variable Return From Dict    ${result_dict.Name}
    Return From Keyword    ${list_name}

Get list id and new price in pricebook by list code
    [Arguments]    ${id_bang_gia}    ${input_list_mahang}
    ${dict_product}    Get dict detail pricebook info    ${id_bang_gia}    $.Data[*].["Id","Price","Code"]
    ${list_pr_price}   Create List
    ${list_pr_id}      Create List
    FOR    ${item_mahang}    IN ZIP    ${input_list_mahang}
        ${index}    Get Index From List    ${dict_product.Code}    ${item_mahang}
        ${pr_price}    Set Variable Return From Dict    ${dict_product.Price[${index}]}
        ${pr_id}       Set Variable Return From Dict    ${dict_product.Id[${index}]}
        Append To List    ${list_pr_price}   ${pr_price}
        Append To List    ${list_pr_id}      ${pr_id}
    END
    Return From Keyword    ${list_pr_id}    ${list_pr_price}

Get total product in Pricebook
    [Arguments]   ${pricebook_id}
    ${jsonpath}    Set Variable    $.["Total"]
    ${result_dict}    Get dict detail pricebook info    ${pricebook_id}    ${jsonpath}
    ${total}    Set Variable Return From Dict    ${result_dict.Total[0]}
    Return From Keyword    ${total}

Get compare value in pricebook
    [Arguments]    ${pricebook_id}    ${compare_key}
    ${jsonpath}    Set Variable    $.Data[*].["${compare_key}"]
    ${result_dict}    Get dict detail pricebook info    ${pricebook_id}    ${jsonpath}
    Return From Keyword    ${result_dict.${compare_key}}

Get list product code in pricebook
    [Arguments]    ${pricebook_id}    ${ten_ma_hang_hoa}=${EMPTY}     ${catorgy_id}=${EMPTY}
    ${jsonpath}    Set Variable    $.Data[*].Code
    ${result_dict}    Get dict detail pricebook info    ${pricebook_id}    ${jsonpath}    ${catorgy_id}    ten_ma_hang_hoa=${ten_ma_hang_hoa}
    ${list_pr_code}    Set Variable Return From Dict    ${result_dict.Code}
    Return From Keyword    ${list_pr_code}

Get dict code and new price in pricebook
    [Arguments]   ${pricebook_id}
    ${list_jsonpath}    Create List    $.Data[*].["Code","Price"]
    ${result_dict}    Get dict detail pricebook info    ${pricebook_id}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get list product code and list new price and compare value in pricebook
    [Arguments]   ${pricebook_id}   ${compare_key}
    ${list_jsonpath}    Create List    $.Data[*].["Code","Price","${compare_key}"]
    ${result_dict}      Get dict detail pricebook info    ${pricebook_id}    ${list_jsonpath}
    ${list_code}          Set Variable Return From Dict    ${result_dict.Code}
    ${list_price}         Set Variable Return From Dict    ${result_dict.Price}
    ${list_compare_key}   Set Variable Return From Dict    ${result_dict.${compare_key}}
    Return From Keyword    ${list_code}    ${list_price}    ${list_compare_key}

# Lấy các thông tin tương ứng với các cột trong excel
Get info product following excel col
    [Arguments]    ${pricebook_id}
    ${list_jsonpath}    Create List    $.Data[*].["Code","Name","Price","Cost","LatestPurchasePrice","BasePrice"]
    ${result_dict}      Get dict detail pricebook info    ${pricebook_id}    ${list_jsonpath}
    ${list_code}    Set Variable Return From Dict    ${result_dict.Code}
    ${list_name}    Set Variable Return From Dict    ${result_dict.Name}
    FOR    ${item_code}    IN    @{list_code}
          ${index}    Get Index From List    ${list_code}    ${item_code}
          ${pr_name_with_attr}     Get product name with attribute    ${item_code}    ${list_name[${index}]}
          Set List Value    ${list_name}    ${index}    ${pr_name_with_attr}
    END
    Return From Keyword    ${result_dict}

Assert gia moi cua hang hoa trong Bang gia
    [Arguments]   ${pricebook_id}   ${compare_key}    ${discount}    ${list_pr_gia_hien_tai}
    ${input_discount}   Replace String    ${discount}    -    ${EMPTY}
    ${discount_number}   Convert To Number    ${input_discount}
    ${list_product_code}    ${list_new_price}   ${list_pr_comparename_value}   Get list product code and list new price and compare value in pricebook    ${pricebook_id}   ${compare_key}
    ${list_pr_comparename_value_lastest}=   Run Keyword If    "${compare_key}"=="Price"    Set Variable    ${list_pr_gia_hien_tai}   ELSE    Set Variable    ${list_pr_comparename_value}
    FOR    ${item_ma_HH}    ${item_new_price}   ${item_pr_comparename_value}    IN ZIP    ${list_product_code}    ${list_new_price}    ${list_pr_comparename_value_lastest}
        ${result_new_price}=    Run Keyword If    0<${discount}<=100    Computation new price - plus - %    ${item_pr_comparename_value}    ${discount_number}
        ...    ELSE IF    ${discount}>100    Computation new price - plus - VND    ${item_pr_comparename_value}    ${discount_number}
        ...    ELSE IF    -100<=${discount}<0    Computation new price - discount - %    ${item_pr_comparename_value}    ${discount_number}
        ...    ELSE IF    ${discount}<-100    Computation new price - discount - VND    ${item_pr_comparename_value}    ${discount_number}
        KV Should Be Equal As Numbers    ${item_new_price}    ${result_new_price}    msg=Lỗi sai giá mới của hàng hóa
    END

Assert thong tin tong hang hoa footer
    [Arguments]   ${count_total_HH_inBG}    ${total_HH_inBG_after}
    ${gettext_tong_hh}    FNB TLG ListHH Text Tong HH
    Run Keyword If    ${gettext_tong_hh} > 0     KV Should Be Equal As Numbers    ${count_total_HH_inBG}    ${gettext_tong_hh}    msg=Lỗi sai tổng SL hàng trong bảng giá
    ...    ELSE    KV Should Be Equal As Numbers    ${count_total_HH_inBG}    ${total_HH_inBG_after}    msg=Lỗi sai tổng SL hàng trong bảng giá

Get list info by id
    [Arguments]    ${pricebook_id}
    ${list_jsonpath}    Create List    $.Data[?(@.Id\=\=${pricebook_id})].["CreatedBy","CreatedDate","CompareIsActive","CompareStartDate","CompareEndDate","Type"]
    ${result_invoice_dict}     Get dict all pricebook info    ${list_jsonpath}
    KV Log   ${result_invoice_dict}
    ${CreatedBy}            Set Variable     ${result_invoice_dict.CreatedBy[0]}
    ${CreatedDate}          Set Variable     ${result_invoice_dict.CreatedDate[0]}
    ${CompareIsActive}      Set Variable     ${result_invoice_dict.CompareIsActive[0]}
    ${CompareStartDate}     Set Variable     ${result_invoice_dict.CompareStartDate[0]}
    ${CompareEndDate}       Set Variable     ${result_invoice_dict.CompareEndDate[0]}
    ${CompareIsActive}    Convert To String    ${CompareIsActive}
    ${CompareIsActive}    Convert To Lower Case    ${CompareIsActive}
    Return From Keyword    ${CreatedBy}    ${CreatedDate}    ${CompareIsActive}    ${CompareStartDate}    ${CompareEndDate}

Assert thong tin danh sach hang hoa cua nhom hang trong BG giua UI va API
    [Arguments]    ${id_BG}    ${ten_nhom_hang}    ${list_ma_hh_ui}    ${list_gia_von_ui}    ${list_gia_ban_ui}
    ${id_nhom_hang}    Get category ID by category name    ${ten_nhom_hang}
    ${list_jsonpath}    Create List    $.Data[*].["Code","Cost","BasePrice"]
    ${result_dict}    Get dict detail pricebook info    ${id_BG}    ${list_jsonpath}    ${id_nhom_hang}
    KV Lists Should Be Equal     ${list_ma_hh_ui}      ${result_dict.Code}        msg=Hiển thị sai danh sách mã HH của nhóm hàng trong BG
    KV Lists Should Be Equal     ${list_gia_von_ui}    ${result_dict.Cost}        msg=Hiển thị sai danh sách giá vốn HH của nhóm hàng trong BG
    KV Lists Should Be Equal     ${list_gia_ban_ui}    ${result_dict.BasePrice}   msg=Hiển thị sai danh sách giá bán HH của nhóm hàng trong BG

Assert thong tin list hang hoa trong bang gia theo API
    [Arguments]    ${id_banggia}    ${list_pr_code}    ${list_name_pr}    ${list_giavon_pr}    ${list_giachung_pr}    ${list_giamoi_pr}
    ${list_jsonpath}    Create List    $.Data[*].["Code","Name","Cost","BasePrice","Price"]
    ${result_dict}    Get dict detail pricebook info    ${id_banggia}    ${list_jsonpath}

    KV Lists Should Be Equal     ${list_pr_code}        ${result_dict.Code}                      msg=Hiển thị sai danh sách mã HH trong bảng trong BG
    KV Lists Should Be Equal     ${list_name_pr}        ${result_dict.Name}                      msg=Hiển thị sai danh sách tên HH trong bảng trong BG
    KV Lists Should Be Equal     ${list_giavon_pr}      ${result_dict.Cost}                      msg=Hiển thị sai danh sách giá vốn của hàng hóa trong bảng giá
    KV Lists Should Be Equal     ${list_giachung_pr}    ${result_dict.BasePrice}                 msg=Hiển thị sai danh sách giá chung của hàng hóa trong bảng giá
    KV Lists Should Be Equal     ${list_giamoi_pr}      ${result_dict.Price}                     msg=Hiển thị sai danh sách giá mới của hàng hóa trong bảng giá

#
