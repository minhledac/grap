*** Settings ***
Library           SeleniumLibrary
Library           String
Library           BuiltIn
Library           Collections
Resource           ../../api_access.robot
Resource           ../../GET/hang-hoa/api_danhmuc_hanghoa.robot
Resource           ../../GET/doi-tac/api_nhacungcap.robot
Resource           ../../GET/giao-dich/api_trahangnhap.robot
Resource          ../../../../config/envi.robot

*** Keywords ***
Them moi phieu tra hang nhap
    [Documentation]    status=false => tao phieu tam
    ...                status=true  => tao phieu hoan thanh
    [Arguments]    ${ma_phieu}    ${ma_ncc}    ${dict_hang_hoa}    ${status}    ${tien_ncc_tra}=0
    ${id_ncc}          Get supplier id by code    ${ma_ncc}
    ${retailer_id}    ${user_id}    KV Get RetailerId And UserId
    ${list_pr_code}    Get Dictionary Keys    ${dict_hang_hoa}
    ${list_SL}         Get Dictionary Values    ${dict_hang_hoa}
    ${list_pr_id}      Get list product id frm API by index    ${list_pr_code}
    ${list_pr_cost}    ${list_pr_price}    Get list onHand and cost by list product code    ${list_pr_code}
    ${data_product}    KV Set Data Product Of PurchaseReturn    ${list_pr_id}    ${list_SL}    ${list_pr_price}
    ${input_dict}   Create Dictionary    ma_phieu=${ma_phieu}    data_product=${data_product}    user_id=${user_id}    retailer_id=${retailer_id}    id_ncc=${id_ncc}
    ...    branch_id=${BRANCH_ID}    tien_ncc_tra=${tien_ncc_tra}    trang_thai=${status}
    ${result_dict}    API Call From Template    /tra-hang-nhap/add_phieu_tra_hang_nhap.txt    ${input_dict}    $.Id
    ${result_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${result_id}

Them moi list phieu tra hang nhap
    [Arguments]   @{list_data}
    ${list_id}    Create List
    FOR    ${data}    IN    @{list_data}
        ${id_phieu}    Them moi phieu tra hang nhap    @{data}
        Append To List    ${list_id}    ${id_phieu}
    END
    Return From Keyword    ${list_id}

Delete phieu tra hang nhap
    [Arguments]    ${id_phieu}    ${is_void_payment}=true
    ${input_dict}    Create Dictionary    id_phieu=${id_phieu}    is_void_payment=${is_void_payment}
    Run Keyword If    ${id_phieu}!=0    API Call From Template    /tra-hang-nhap/delete_phieu_tra_hang_nhap.txt    ${input_dict}    ELSE    KV Log    Phieu tra hang nhap khong ton tai

Delete list phieu tra hang nhap
    [Arguments]   ${list_id_phieu}
    FOR    ${id_phieu}    IN    @{list_id_phieu}
        Delete phieu tra hang nhap    ${id_phieu}
    END

# =============================== KV SET DATA ===============================
KV Set Data Product Of PurchaseReturn
    [Arguments]    ${list_pr_id}    ${list_SL}    ${list_pr_price}
    ${list_data_pr}    Create List
    FOR    ${pr_id}     IN    @{list_pr_id}
        ${index}    Get Index From List    ${list_pr_id}    ${pr_id}
        ${view_index}    Evaluate    ${index}+1
        ${data_pr}    Set Variable    {"PurchaseOrderSerials": "","ProductId": ${pr_id},"Product": {"Id": ${pr_id},"Name": "","Code": "","IsLotSerialControl": false,"ProductShelvesStr": ""},"BuyPrice": ${list_pr_price[${index}]},"suggestedReturnPrice": ${list_pr_price[${index}]},"ReturnPrice": ${list_pr_price[${index}]},"Quantity": ${list_SL[${index}]},"ReturnQuantity": 0,"SellQuantity": null,"ReturnSerials": null,"IsLotSerialControl": false,"ViewIndex": ${view_index},"isOdd": true,"Serials": [],"OrderByNumber": ${index}}
        Append To List    ${list_data_pr}    ${data_pr}
    END
    ${join_str}    Evaluate    ",".join($list_data_pr)
    Return From Keyword    ${join_str}
