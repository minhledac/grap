*** Settings ***
Library           SeleniumLibrary
Library           String
Library           BuiltIn
Library           Collections
Resource           ../../api_access.robot
Resource           ../../../share/computation.robot
Resource           ../../../share/list_dictionary.robot
Resource           ../../GET/hang-hoa/api_danhmuc_hanghoa.robot
Resource           ../../GET/giao-dich/api_xuathuy.robot
Resource          ../../../../config/envi.robot

*** Keywords ***
Them moi phieu xuat huy
    [Documentation]    Status=false => Phieu tam
    ...                Status=true => Phieu hoan thanh
    [Arguments]    ${ma_phieu_xh}    ${dict_hang_hoa}    ${status}    ${ghi_chu}=${EMPTY}
    ${id_phieu_xh}    Get id damageitems note by code    ${ma_phieu_xh}
    ${retailer_id}    ${user_id}    KV Get RetailerId And UserId
    ${list_ma_hang}    Set Variable    ${dict_hang_hoa.ma_hh}
    ${list_sl_huy}    Set Variable    ${dict_hang_hoa.sl_huy}
    ${list_ton_kho}    ${list_gia_von}    Get list onHand and cost by list product code    ${list_ma_hang}
    ${tong_giatri_huy}    Count gia tri phieu xuat huy    ${list_sl_huy}    ${list_gia_von}
    ${list_id}    Get list product id by list product code    ${list_ma_hang}
    # Set thong tin cua hang hoa
    ${data_product}    KV Set Data Product Damage Item    ${list_id}    ${list_ma_hang}    ${list_sl_huy}    ${list_gia_von}
    # Set jsonpath để lấy ra id của mã phiếu sau khi tạo
    ${jsonpath}    Set Variable    $.Id
    ${input_dict}    Create Dictionary     ma_phieu_xh=${ma_phieu_xh}    branch_id=${BRANCH_ID}    user_id=${user_id}    retailer_id=${retailer_id}
    ...    data_product=${data_product}    ghi_chu=${ghi_chu}    complete=${status}

    ${result_id}    Run Keyword If    ${id_phieu_xh} == 0    API Call From Template    /xuat-huy/add_phieu_xuat_huy.txt    ${input_dict}    ${jsonpath}
    ${id_phieu_xh}    Set Variable Return From Dict    ${result_id.Id[0]}
    Return From Keyword    ${id_phieu_xh}

KV Set Data Product Damage Item
    [Arguments]    ${list_id}    ${list_ma_hang}    ${list_SL}    ${list_gia_von}
    ${list_data}    Create List
    ${length}    Get Length    ${list_ma_hang}
    ${view_index}    ${order_by_number}    Set Variable    ${length}    ${length}
    FOR    ${index}    IN RANGE    ${length}
        ${order_by_number}    Evaluate    ${length}-1
        Append To List    ${list_data}    {"ProductId": ${list_id[${index}]},"Product": {"Name": "","Code": "${list_ma_hang[${index}]}","IsLotSerialControl": false,"ProductShelvesStr": ""},"ProductCode": "${list_ma_hang[${index}]}","ProductName": "","Description": "","ProductCost": ${list_gia_von[${index}]},"Quantity": ${list_SL[${index}]},"ProductSerials": [],"IsLotSerialControl": false,"totalCost": 0,"rowNumber": 0,"viewIndex": ${view_index},"tempProductSerials": [],"OrderByNumber": ${order_by_number}}
        ${view_index}    Evaluate    ${length}-1
    END
    ${list_data}    Reverse List one    ${list_data}
    ${join_str}    Evaluate    ",".join($list_data)
    KV Log    ${join_str}
    Return From Keyword    ${join_str}

Count gia tri phieu xuat huy
    [Arguments]    ${list_sl_huy}    ${list_gia_von}
    ${length}    Get Length    ${list_sl_huy}
    ${tong_giatri_huy}    Set Variable    0
    FOR    ${index}    IN RANGE    ${length}
        ${giatri_huy}    Multiplication and round 2    ${list_sl_huy[${index}]}    ${list_gia_von[${index}]}
        ${tong_giatri_huy}    Sum    ${tong_giatri_huy}    ${giatri_huy}
    END
    Return From Keyword    ${tong_giatri_huy}

Them moi list phieu xuat huy
    [Arguments]    @{list_data}
    ${list_id_phieu_xh}    Create List
    FOR    ${data_xh}    IN    @{list_data}
        ${id_phieu_xh}    Them moi phieu xuat huy    @{data_xh}
        Append To List    ${list_id_phieu_xh}    ${id_phieu_xh}
    END
    Return From Keyword    ${list_id_phieu_xh}

Delete phieu xuat huy
    [Arguments]    ${id_phieu_xh}
    ${input_dict}   Create Dictionary    id_phieu_xh=${id_phieu_xh}
    Run Keyword If    ${id_phieu_xh} != 0    API Call From Template    /xuat-huy/delete_phieu_xuat_huy.txt    ${input_dict}    ELSE    KV Log    Phieu xuat huy khong ton tai

Delete list phieu xuat huy
    [Arguments]    ${list_id}
    FOR   ${id_phieu_xh}    IN    @{list_id}
        Delete phieu xuat huy    ${id_phieu_xh}
    END
