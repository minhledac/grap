*** Settings ***
Library           SeleniumLibrary
Library           String
Library           BuiltIn
Library           Collections
Resource           ../../api_access.robot
Resource           ../../../share/computation.robot
Resource           ../../../share/list_dictionary.robot
Resource           ../../GET/hang-hoa/api_danhmuc_hanghoa.robot
Resource           ../../GET/giao-dich/api_chuyenhang.robot
Resource           ../../GET/chi-nhanh/api_chi_nhanh.robot
Resource          ../../../../config/envi.robot

*** Keywords ***
Them moi phieu chuyen hang
    [Documentation]    Status=1 => Phieu tam
    ...                Status=2 => Phieu dang chuyen
    [Arguments]    ${ma_phieu_chuyen}    ${dict_hang_hoa}    ${chi_nhanh_toi}    ${status}    ${ghi_chu}=${EMPTY}
    ${id_phieu_chuyen}    Get id product transfer note by code    ${ma_phieu_chuyen}
    ${id_to_branch}    Get branch id by name    ${chi_nhanh_toi}
    ${user_id}    Get User ID
    ${retailer_id}    Get RetailerID
    # Dictionary hàng hóa bao gồm key mã hàng và key số lượng chuyển
    ${list_ma_hang}    Set Variable    ${dict_hang_hoa.ma_hh}
    ${list_sl_chuyen}    Set Variable    ${dict_hang_hoa.sl_chuyen}
    ${list_ton_kho}    ${list_gia_von}    Get list onHand and cost by list product code    ${list_ma_hang}
    ${list_id}    Get list product id by list product code    ${list_ma_hang}
    # Set thong tin cua hang hoa
    ${data_product}    KV Set Data Product Transfer    ${list_id}    ${list_ma_hang}    ${list_ton_kho}    ${list_sl_chuyen}    ${list_gia_von}
    # Set jsonpath để lấy ra id của mã phiếu sau khi tạo
    ${jsonpath}    Set Variable    $.Id
    ${input_dict}    Create Dictionary     ma_phieu_chuyen=${ma_phieu_chuyen}    from_branch=${BRANCH_ID}    to_branch=${id_to_branch}    user_id=${user_id}    retailer_id=${retailer_id}
    ...    data_product=${data_product}    ghi_chu=${ghi_chu}    status=${status}

    ${result_id}    Run Keyword If    ${id_phieu_chuyen} == 0    API Call From Template    /chuyen-hang/add_phieu_chuyen_hang.txt    ${input_dict}    ${jsonpath}
    ${id_phieu_chuyen}    Run Keyword If    ${id_phieu_chuyen} == 0     Set Variable Return From Dict    ${result_id.Id[0]}    ELSE    Set Variable    ${id_phieu_chuyen}
    Return From Keyword    ${id_phieu_chuyen}

KV Set Data Product Transfer
    [Arguments]    ${list_id}    ${list_ma_hang}    ${list_ton_kho}    ${list_SL}    ${list_gia_von}
    ${list_data}    Create List
    ${length}    Get Length    ${list_ma_hang}
    ${view_index}    ${order_by_number}    Set Variable    ${length}    ${length}
    FOR    ${index}    IN RANGE    ${length}
        ${order_by_number}    Evaluate    ${length}-1
        Append To List    ${list_data}    {"ProductId": ${list_id[${index}]},"OnHand": ${list_ton_kho[${index}]},"Product":{"Name": "","Code": "${list_ma_hang[${index}]}","IsLotSerialControl": false,"ProductShelvesStr": ""},"SendQuantity": ${list_SL[${index}]},"ReceiveQuantity": 1,"Price": ${list_gia_von[${index}]},"ProductName": "${list_ma_hang[${index}]}","ProductSerials": [],"ShowUnit": false,"Unit": "","SelectedUnit": 0,"ConversionValue": 1,"rowNumber": 0,"viewIndex": ${view_index},"NextBranchQuantity": 0,"OrderByNumber": ${order_by_number}}
        ${view_index}    Evaluate    ${length}-1
    END
    ${list_data}    Reverse List one    ${list_data}
    ${join_str}    Evaluate    ",".join($list_data)
    KV Log    ${join_str}
    Return From Keyword    ${join_str}

Cap nhat phieu chuyen hang ve trang thai da nhan
    [Documentation]    Status=3 => Phieu da nhan
    [Arguments]    ${ma_phieu_chuyen}    ${dict_hang_hoa}    ${chi_nhanh_toi}    ${status}    ${ghi_chu}=${EMPTY}
    ${id_phieu_chuyen}    Get id product transfer note by code    ${ma_phieu_chuyen}
    ${id_to_branch}    Get branch id by name    ${chi_nhanh_toi}
    ${user_id}    Get User ID
    ${retailer_id}    Get RetailerID
    # Dictionary hàng hóa bao gồm key mã hàng và key số lượng chuyển
    ${list_ma_hang}    Set Variable    ${dict_hang_hoa.ma_hh}
    ${list_sl_chuyen}    Set Variable    ${dict_hang_hoa.sl_chuyen}
    ${list_ton_kho}    ${list_gia_von}    Get list onHand and cost by list product code    ${list_ma_hang}
    ${list_id}    Get list product id by list product code    ${list_ma_hang}
    # Set thong tin cua hang hoa
    ${data_detail}    KV Set Data Transfer Detail    ${id_phieu_chuyen}    ${retailer_id}    ${list_id}    ${list_ma_hang}    ${list_ton_kho}    ${list_sl_chuyen}    ${list_gia_von}
    ${input_dict}    Create Dictionary    id_phieu_chuyen=${id_phieu_chuyen}     ma_phieu_chuyen=${ma_phieu_chuyen}    from_branch=${BRANCH_ID}    to_branch=${id_to_branch}
    ...    user_id=${user_id}    retailer_id=${retailer_id}    data_detail=${data_detail}    ghi_chu=${ghi_chu}    status=${status}

    Run Keyword If    ${id_phieu_chuyen} != 0    API Call From Template    /chuyen-hang/update_tt_nhan_hang.txt    ${input_dict}
    Return From Keyword    ${id_phieu_chuyen}

KV Set Data Transfer Detail
    [Arguments]    ${transfer_id}    ${retailer_id}    ${list_id}    ${list_ma_hang}    ${list_ton_kho}    ${list_SL}    ${list_gia_von}
    ${list_data}    Create List
    ${length}    Get Length    ${list_ma_hang}
    ${view_index}    ${order_by_number}    Set Variable    ${length}    ${length}
    FOR    ${index}    IN RANGE    ${length}
        ${order_by_number}    Evaluate    ${length}-1
        Append To List    ${list_data}    {"ProductCode": "${list_ma_hang[${index}]}","ProductName": "","OnHand": ${list_ton_kho},"SendPrice": 0,"ReceivePrice": 0,"ProductImage": "","ProductAttributeLabel": "","CategoryTree": "","ProductShelvesStr": "","Id": 0,"TransferId": ${transfer_id},"ProductId": ${list_id[${index}]},"SendQuantity": ${list_SL[${index}]},"ReceiveQuantity": ${list_SL[${index}]},"Price": ${list_gia_von[${index}]},"OrderByNumber": ${order_by_number},"Product": {"Id": ${list_id[${index}]},"Code": "${list_ma_hang[${index}]}","Name": "","CategoryId": 0,"AllowsSale": true,"BasePrice": 0,"Tax": 0,"RetailerId": ${retailer_id},"isActive": true,"CreatedDate": "","ProductType": 2,"HasVariants": false,"Unit": "","ConversionValue": 1,"OrderTemplate": "","FullName": "","IsLotSerialControl": false,"Weight": 0,"IsRewardPoint": false,"isDeleted": false,"IsTopping": false,"ProductGroup": 2,"MasterCode": "","Revision": "AAAAAAy1epY=","Formula": [],"ProductImages": [],"PurchaseReturnDetails": [],"ProductChild": [],"ProductAttributes": [],"ProductChildUnit": [],"PriceBookDetails": [],"ProductBranches": [],"TableAndRooms": [],"Manufacturings": [],"ManufacturingDetails": [],"DamageDetails": [],"ProductSerials": [],"ProductFormulaHistories": [],"ProductToppings": [],"Topping": [],"ProductNoteTemplates": [],"ProductProcessingSector": [],"CancelDishReasonDetails": [],"NotifyDishes": [],"ProductShelves": []},"IsLotSerialControl": false,"rowNumber": 0,"viewIndex": ${view_index},"NextBranchQuantity": 0}
        ${view_index}    Evaluate    ${length}-1
    END
    ${list_data}    Reverse List one    ${list_data}
    ${join_str}    Evaluate    ",".join($list_data)
    KV Log    ${join_str}
    Return From Keyword    ${join_str}

Count gia tri phieu chuyen hang
    [Arguments]    ${list_sl_chuyen}    ${list_gia_von}
    ${length}    Get Length    ${list_sl_chuyen}
    ${tong_thanh_tien}    Set Variable    0
    FOR    ${index}    IN RANGE    ${length}
        ${giatri_huy}    Multiplication and round 2    ${list_sl_chuyen[${index}]}    ${list_gia_von[${index}]}
        ${tong_thanh_tien}    Sum    ${tong_thanh_tien}    ${giatri_huy}
    END
    Return From Keyword    ${tong_thanh_tien}

Them moi list phieu chuyen hang
    [Arguments]    @{list_data}
    ${list_id_phieu_chuyen}    Create List
    FOR    ${data_ch}    IN    @{list_data}
        ${id_phieu_chuyen}    Them moi phieu chuyen hang    @{data_ch}
        Append To List    ${list_id_phieu_chuyen}    ${id_phieu_chuyen}
    END
    Return From Keyword    ${list_id_phieu_chuyen}

Delete phieu chuyen hang
    [Arguments]    ${id_phieu_chuyen}
    ${input_dict}   Create Dictionary    id_phieu_chuyen=${id_phieu_chuyen}
    Run Keyword If    ${id_phieu_chuyen} != 0    API Call From Template    /chuyen-hang/delete_phieu_chuyen_hang.txt    ${input_dict}    ELSE    KV Log    Phieu chuyen hang khong ton tai

Delete list phieu chuyen hang
    [Arguments]    ${list_id}
    FOR   ${id_phieu_chuyen}    IN    @{list_id}
        Delete phieu chuyen hang    ${id_phieu_chuyen}
    END
