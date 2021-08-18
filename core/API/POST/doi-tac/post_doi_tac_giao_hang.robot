*** Settings ***
Resource           ../../api_access.robot
Resource           ../../GET/doi-tac/api_doi_tac_giao_hang.robot
Resource          ../../../../config/envi.robot
Library           DateTime

*** Keywords ***
Them moi doi tac giao hang
    [Arguments]    ${ma_doi_tac}    ${ten_doi_tac}    ${sdt_doi_tac}    ${list_ten_nhom_doitac}=${EMPTY}
    ${id_doi_tac}    Get delivery id by code    ${ma_doi_tac}
    Return From Keyword If    ${id_doi_tac}!=0    ĐTGH đã tồn tại
    ${jsonpath_id}    Set Variable    $.Id
    ${type_group}    Evaluate    type($list_ten_nhom_doitac).__name__
    ${list_ten_nhom_doitac}    Set Variable If    '${type_group}'=='list'     ${list_ten_nhom_doitac}    ${EMPTY}
    ${list_id_nhom_doitac}     Run Keyword If    '${type_group}'=='list'    Get list delivery id by list name    ${list_ten_nhom_doitac}    ELSE    Set Variable    ${EMPTY}
    ${data_nhom_doi_tac}    KV Set data group detail    ${list_id_nhom_doitac}
    ${input_dict}   Create Dictionary    ma_doi_tac=${ma_doi_tac}    ten_doi_tac=${ten_doi_tac}    sdt_doi_tac=${sdt_doi_tac}    data_nhom_doi_tac=${data_nhom_doi_tac}
    ${dict_id}      Run Keyword If    ${id_doi_tac} == 0    API Call From Template    /doi-tac-giao-hang/add_doi_tac_giao_hang.txt    ${input_dict}    ${jsonpath_id}
    ${result_id}    Run Keyword If    ${id_doi_tac} == 0    Set Variable Return From Dict    ${dict_id.Id[0]}    ELSE    Set Variable    ${id_doi_tac}
    Return From Keyword    ${result_id}

KV Set data group detail
    [Arguments]    ${list_group_id}
    ${length}    Get Length    ${list_group_id}
    ${list_data}    Create List
    FOR   ${index}   IN RANGE    ${length}
        Append To List    ${list_data}    {"GroupId": ${list_group_id[${index}]}}
    END
    ${join_str}    Convert List to String    ${list_data}
    ${data_group}    Set Variable    "PartnerDeliveryGroupDetails": [${join_str}],
    KV Log    ${data_group}
    Return From Keyword    ${data_group}

Them moi list doi tac giao hang
    [Arguments]    ${list_ma_doi_tac}    ${list_ten_doi_tac}    ${list_sdt_doi_tac}    ${list_id_nhom_doitac}
    FOR    ${item_ma}    ${item_ten}    ${item_sdt}    ${item_list_id_nhom}    IN ZIP    ${list_ma_doi_tac}    ${list_ten_doi_tac}    ${list_sdt_doi_tac}    ${list_id_nhom_doitac}
        Them moi doi tac giao hang    ${item_ma}    ${item_ten}    ${item_sdt}    ${item_list_id_nhom}
    END

Dieu chinh no by API
    [Arguments]    ${id_doi_tac}    ${gt_no_dieuchinh}    ${mo_ta}
    ${jsonpath}    Set Variable    $.Id
    ${input_dict}   Create Dictionary    id_doi_tac=${id_doi_tac}    gt_no_dieuchinh=${gt_no_dieuchinh}    mo_ta=${mo_ta}
    ${dict_id}    API Call From Template    /doi-tac-giao-hang/update_dieu_chinh_no.txt    ${input_dict}    ${jsonpath}
    ${result_id}    Set Variable Return From Dict    ${dict_id.Id[0]}
    Return From Keyword    ${result_id}

Thanh toan no by API
    [Arguments]    ${id_doi_tac}    ${gt_thanh_toan}    ${ghi_chu}    ${phuong_thuc_tt}=Cash     ${account_id}=${0}
    ${jsonpath}    Set Variable    $.PurchasePayments[*].Id
    ${date}    Get Current Date    increment=-00:00:01.000
    ${trans_date}    Convert Date    ${date}    date_format=%Y-%m-%d %H:%M:%S.%f    result_format=%Y-%m-%dT%H:%M:%S.%f
    ${input_dict}   Create Dictionary    branch_id=${BRANCH_ID}    id_doi_tac=${id_doi_tac}    trans_date=${trans_date}    gt_thanh_toan=${gt_thanh_toan}
    ...    ghi_chu=${ghi_chu}    phuong_thuc_tt=${phuong_thuc_tt}    account_id=${account_id}
    ${dict_id}    API Call From Template    /doi-tac-giao-hang/update_thanh_toan_no.txt    ${input_dict}    ${jsonpath}
    ${result_id}    Set Variable Return From Dict    ${dict_id.Id[0]}
    Return From Keyword    ${result_id}

Cap nhat trang thai giao hang by API
    [Documentation]    status=1 => Hoàn thành    status=2 => Đã hủy    status=3 => Chưa giao hàng    status=4 => Đang giao hàng    status=5 => Không giao được
    [Arguments]    ${invoice_id}    ${status}    ${delivery_charges}=${0}
    ${input_dict}   Create Dictionary    invoice_id=${invoice_id}    status=${status}    delivery_charges=${delivery_charges}
    Run Keyword If    ${invoice_id} != 0    API Call From Template    /doi-tac-giao-hang/update_delivery_status.txt    ${input_dict}
    ...    ELSE    KV Log    Ma hoa don khong ton tai

Delete doi tac giao hang
    [Arguments]    ${id_doi_tac}
    ${input_dict}   Create Dictionary    id_doi_tac=${id_doi_tac}
    Run Keyword If    ${id_doi_tac} != 0    API Call From Template    /doi-tac-giao-hang/delete_doi_tac_giao_hang.txt    ${input_dict}
    ...    ELSE    KV Log    Doi tac giao hang khong ton tai

Delete list doi tac giao hang
    [Arguments]    ${list_id_doi_tac}
    FOR    ${id_doi_tac}    IN    @{list_id_doi_tac}
        Delete doi tac giao hang    ${id_doi_tac}
    END

Delete list ma doi tac giao hang
    [Arguments]    ${list_ma_doi_tac}
    ${list_id_doi_tac}    Get list delivery partner id by index    ${list_ma_doi_tac}
    Delete list doi tac giao hang    ${list_id_doi_tac}

Them moi nhom doi tac giao hang
    [Arguments]    ${ten_nhom_dt}
    ${id_nhom_dt}    Get id group delivery partner by name    ${ten_nhom_dt}
    ${jsonpath_id}    Set Variable    $.Id
    ${input_dict}   Create Dictionary    ten_nhom_dt=${ten_nhom_dt}
    ${dict_id}      Run Keyword If    ${id_nhom_dt} == 0    API Call From Template    /doi-tac-giao-hang/add_nhom_doitac_giaohang.txt    ${input_dict}    ${jsonpath_id}
    ${result_id}    Run Keyword If    ${id_nhom_dt} == 0    Set Variable Return From Dict    ${dict_id.Id[0]}    ELSE    Set Variable    ${id_nhom_dt}
    Return From Keyword    ${result_id}

Them moi list nhom doi tac giao hang
    [Arguments]    ${list_ten_nhom_dt}
    FOR    ${item_ten}    IN ZIP    ${list_ten_nhom_dt}
        Them moi nhom doi tac giao hang    ${item_ten}
    END

Delete nhom doi tac giao hang
    [Arguments]    ${id_nhom_dt}
    ${input_dict}   Create Dictionary    id_nhom_dt=${id_nhom_dt}
    Run Keyword If    ${id_nhom_dt} != 0    API Call From Template    /doi-tac-giao-hang/delete_nhom_doitac_giaohang.txt    ${input_dict}
    ...    ELSE    KV Log    Nhom doi tac giao hang khong ton tai

Delete list nhom doi tac giao hang
    [Arguments]    ${list_id_nhom_dt}
    FOR    ${id_nhom_dt}    IN ZIP    ${list_id_nhom_dt}
        Delete nhom doi tac giao hang    ${id_nhom_dt}
    END

Delete list ten nhom doi tac giao hang
    [Arguments]    ${list_ten_nhom_dt}
    ${list_id_nhom_dt}    Get list group delivery partner id by index    ${list_ten_nhom_dt}
    Delete list nhom doi tac giao hang    ${list_id_nhom_dt}
