*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Library           DateTime
Library           BuiltIn
Resource           ../../api_access.robot
Resource           ../../../share/list_dictionary.robot
Resource          ../../../../config/envi.robot
Resource          ../../GET/hang-hoa/api_danhmuc_hanghoa.robot
Resource          ../../GET/hang-hoa/api_kiemkho.robot

*** Keywords ***
Them moi phieu kiem kho
    [Arguments]    ${ma_phieu}    ${dict_hang_hoa}    ${is_adjust}    ${ghi_chu}=${EMPTY}    ${thoi_gian}=${EMPTY}
    # Phieu tam: is_adjust = false. Phieu hoan thanh: is_adjust=true
    ${list_product_code}    Get Dictionary Keys    ${dict_hang_hoa}
    ${list_SL_kiem}    Get Dictionary Values    ${dict_hang_hoa}
    ${id_phieu_kiem}    Get id phieu kiem theo ma phieu    ${ma_phieu}
    ${user_id}    Get User ID
    ${list_product_id}   Get list product id by list product code    ${list_product_code}
    ${data_hang_hoa}    KV set data product    ${list_product_id}    ${list_SL_kiem}
    ${data_recent_history}    KV set data RecentHistory    ${list_product_id}    ${list_SL_kiem}    ${list_product_code}
    ${thoi_gian}    Run Keyword If    '${thoi_gian}' != '${EMPTY}'    Convert Date    ${thoi_gian}    date_format=%d/%m/%Y %H:%M    exclude_millis=True    ELSE    Set Variable    ${EMPTY}
    ${input_dict}    Create Dictionary    ma_phieu_kiem=${ma_phieu}    user_id=${user_id}    branch_id=${BRANCH_ID}    thoi_gian=${thoi_gian}    is_adjust=${is_adjust}
    ...    data_hang_hoa=${data_hang_hoa}    data_recent_history=${data_recent_history}    ghi_chu=${ghi_chu}
    # Set jsonpath_id để get id phiếu kiểm sau khi thêm mới
    ${jsonpath_id}    Set Variable    $.Data[*].Id
    ${result_id}    Run Keyword If    ${id_phieu_kiem} == 0    API Call From Template    /kiem-kho/add_phieu_kiem_kho.txt    ${input_dict}    ${jsonpath_id}
    ...    ELSE    Set Variable    ${id_phieu_kiem}
    ${result_id}    Set Variable Return From Dict    ${result_id.Id[0]}
    Return From Keyword    ${result_id}

Them moi list phieu kiem kho
    [Arguments]    @{list_data_pk}
    ${list_id}    Create List
    FOR    ${data}    IN    @{list_data_pk}
        ${id_pk}    Them moi phieu kiem kho    @{data}
        Append To List    ${list_id}    ${id_pk}
    END
    Return From Keyword    ${list_id}

KV set data product
    [Arguments]    ${list_product_id}    ${list_SL_kiem}
    ${length}    Get Length    ${list_product_id}
    ${list_product}    Create List
    FOR    ${index}    IN RANGE    ${length}
        Append To List    ${list_product}    {"Id": 0,"ProductId": ${list_product_id[${index}]},"ActualCount": ${list_SL_kiem[${index}]},"ProductName": "","ProductCode": "","IsDraft": false,"OrderByNumber": 0}
    END
    ${join_str}     Convert List to String    ${list_product}
    ${data_product}    Set Variable    "StockTakeDetail": [${join_str}],
    KV Log    ${data_product}
    Return From Keyword    ${data_product}

KV set data RecentHistory
    [Arguments]    ${list_product_id}    ${list_SL_kiem}    ${list_product_code}
    ${length}    Get Length    ${list_product_id}
    ${list_data}    Create List
    FOR    ${index}    IN RANGE    ${length}
        ${product_name}    Get Product full name by code    ${list_product_code[${index}]}
        Append To List    ${list_data}    {\\"ProductName\\":\\"${product_name}\\",\\"ProductId\\":0,\\"Count\\":${list_SL_kiem[${index}]},\\"Icon\\":\\"fa-edit\\",\\"Serials\\":\\"\\",\\"ActionName\\":\\"typ\\"},{\\"ProductName\\":\\"${product_name}\\",\\"ProductId\\":${list_product_id[${index}]},\\"Count\\":1,\\"Icon\\":\\"fa-add\\",\\"Serials\\":\\"\\",\\"ActionName\\":\\"add\\"}
    END
    ${join_str}    Convert List to String    ${list_data}
    KV Log    ${join_str}
    Return From Keyword    ${join_str}

Delete phieu kiem kho theo ma
    [Arguments]    ${ma_phieu_kiem}
    ${id_phieu_kiem}    Get id phieu kiem theo ma phieu    ${ma_phieu_kiem}
    Delete phieu kiem kho theo id    ${id_phieu_kiem}

Delete phieu kiem kho theo id
    [Arguments]    ${id_phieu_kiem}
    ${input_dict}    Create Dictionary    id_phieu_kiem=${id_phieu_kiem}
    Run Keyword If    ${id_phieu_kiem} != 0    API Call From Template    /kiem-kho/delete_phieu_kiem.txt    ${input_dict}
    ...    ELSE    KV Log    Phieu kiem khong khong ton tai

Delete list phieu kiem
    [Arguments]    ${list_id}
    FOR     ${id}   IN    @{list_id}
        Delete phieu kiem kho theo id    ${id}
    END
