*** Settings ***
Resource          ../../api_access.robot
Resource          api_danhmuc_hanghoa.robot
Library           String
Library           Collections

*** Keywords ***
# Lấy danh sách phiếu kiểm kho (all trạng thái) mặc định theo Tháng này
Get dict all stocktake info
    [Arguments]    ${jsonpath_value}    ${so_ban_ghi}=${EMPTY}    ${thoi_gian}=thismonth    ${is_phieu_tam}=True    ${is_phieu_hoan_thanh}=True    ${is_phieu_huy}=True    ${search_ma_phieu}=${EMPTY}
    ${filter_status}    KV Get Filter Status Inventory    ${is_phieu_tam}    ${is_phieu_hoan_thanh}    ${is_phieu_huy}
    ${result_filter}    Set Variable    (CreatedDate+eq+'${thoi_gian}'+and+(${filter_status}))

    ${find_dict}    Create Dictionary    so_ban_ghi=${so_ban_ghi}    thoi_gian=${thoi_gian}     filter=${result_filter}    search_ma_phieu=${search_ma_phieu}
    ${result_dict}    API Call From Template    /kiem-kho/all_phieu_kiem.txt    ${find_dict}    ${jsonpath_value}
    Return From Keyword    ${result_dict}

# Filter theo status của giao dịch kiểm kho
KV Get Filter Status Inventory
    [Arguments]    ${is_phieu_tam}    ${is_phieu_hoan_thanh}    ${is_phieu_huy}
    ${list_filter}    Create List
    Run Keyword If    '${is_phieu_tam}' == 'True'           Append To List    ${list_filter}    Status+eq+0
    Run Keyword If    '${is_phieu_hoan_thanh}' == 'True'    Append To List    ${list_filter}    Status+eq+1
    Run Keyword If    '${is_phieu_huy}' == 'True'           Append To List    ${list_filter}    Status+eq+2
    ${list_filter}     Evaluate    "+or+".join(${list_filter})
    Return From Keyword    ${list_filter}

Get dict update detail stocktake info
    [Arguments]    ${id_phieu_kiem}    ${jsonpath_value}
    ${find_dict}    Create Dictionary    id_phieu_kiem=${id_phieu_kiem}
    ${result_dict}    API Call From Template    /kiem-kho/detail_update_phieu_kiem.txt    ${find_dict}     ${jsonpath_value}
    Return From Keyword    ${result_dict}

Get dict detail stocktake info
    [Arguments]    ${id_phieu_kiem}    ${jsonpath_value}
    ${find_dict}    Create Dictionary    id_phieu_kiem=${id_phieu_kiem}
    ${result_dict}    API Call From Template    /kiem-kho/detail_phieu_kiem.txt    ${find_dict}     ${jsonpath_value}
    Return From Keyword    ${result_dict}

Get id phieu kiem theo ma phieu
    [Arguments]    ${inventory_code}
    ${jsonpath}    Set Variable    $.Data[?(@.Code\=\="${inventory_code}")].["Id"]
    ${result_dict}    Get dict all stocktake info    ${jsonpath}
    Return From Keyword    ${result_dict.Id[0]}

Get list ma hang hoa trong phieu kiem Kho
    [Arguments]    ${inventory_code}
    ${id_phieu_kiem}   Get id phieu kiem theo ma phieu    ${inventory_code}
    ${jsonpath}        Set Variable    $.Data[*].["ProductCode"]
    ${result_dict}     Get dict detail stocktake info    ${id_phieu_kiem}    ${jsonpath}
    ${list_ma_hh}      Set Variable Return From Dict    ${result_dict.ProductCode}
    Return From Keyword    ${list_ma_hh}

Get tong so luong thuc te cua phieu kiem kho
    [Arguments]   ${inventory_code}
    ${jsonpath}       Set Variable    $.Data[?(@.Code\=\="${inventory_code}")].["TotalActualCount"]
    ${result_dict}    Get dict all stocktake info    ${jsonpath}
    ${tong_SL_thucte}    Set Variable Return From Dict    ${result_dict.TotalActualCount[0]}
    Return From Keyword    ${tong_SL_thucte}

Get ActualCount of product in inventory
    [Arguments]   ${inventory_code}    ${product_code}
    ${inventory_id}    Get id phieu kiem theo ma phieu    ${inventory_code}
    ${jsonpath}        Set Variable    $.StockTakeItems[?(@.ProductCode\=\="${product_code}")].["ActualCount"]
    ${result_dict}     Get dict update detail stocktake info    ${inventory_id}    ${jsonpath}
    ${SL_thuc_te}      Set Variable Return From Dict    ${result_dict.ActualCount[0]}
    Return From Keyword    ${SL_thuc_te}

Get ActualCount and Cost of product in inventory
    [Arguments]   ${inventory_code}    ${product_code}
    ${inventory_id}    Get id phieu kiem theo ma phieu    ${inventory_code}
    ${list_jsonpath}    Create List    $.StockTakeItems[?(@.ProductCode\=\="${product_code}")].["ActualCount","Cost"]
    ${result_dict}    Get dict update detail stocktake info    ${inventory_id}    ${list_jsonpath}
    Return From Keyword    ${result_dict.ActualCount[0]}    ${result_dict.Cost[0]}

Get danh sach phieu kiem thuoc chi nhanh
    [Arguments]
    [Documentation]    Lấy danh sach phieu kiem kho thuoc chi nhanh, bao gồm phiếu hoàn thành, đã hủy, phiếu tạm
    ${jsonpath}       Set Variable    $.Data[*].["Code"]
    ${result_dict}    Get dict all stocktake info    ${jsonpath}
    ${list_ma_pk}     Set Variable Return From Dict    ${result_dict.Code}
    Return From Keyword    ${list_ma_pk}

Get ghi chu cua phieu kiem
    [Arguments]    ${ma_phieu_kiem}
    [Documentation]    Lay thong tin ghi chu cua phieu kiem
    ${jsonpath}    Set Variable    $.Data[*].["Description"]
    ${result_dict}    Get dict all stocktake info    ${jsonpath}
    ${ghi_chu}    Set Variable Return From Dict    ${result_dict.Description[0]}
    Return From Keyword    ${ghi_chu}

Get tong phieu kiem kho
    [Arguments]
    ${jsonpath}    Set Variable    $.["Total"]
    ${result_dict}    Get dict all stocktake info    ${jsonpath}
    ${tong_pk}    Set Variable Return From Dict    ${result_dict.Total[0]}
    Return From Keyword    ${tong_pk}

# Lấy danh sách mã hàng, SL thực tế, SL lệch, Giá trị lệch  của hàng hóa trong phiếu kiểm kho
Get list thong tin hang hoa trong phieu kiem Kho
    [Arguments]    ${inventory_code}
    ${inventory_id}    Get id phieu kiem theo ma phieu    ${inventory_code}
    ${list_jsonpath}    Create List    $.Data[*].["ProductCode","SystemCount","ActualCount","AdjustmentValue","Cost"]
    ${result_dict}    Get dict detail stocktake info    ${inventory_id}    ${list_jsonpath}
    ${list_ma_hh}          Set Variable Return From Dict    ${result_dict.ProductCode}
    ${list_SystemCount}    Set Variable Return From Dict    ${result_dict.SystemCount}
    ${list_ActualCount}    Set Variable Return From Dict    ${result_dict.ActualCount}
    ${list_SL_lech}        Set Variable Return From Dict    ${result_dict.AdjustmentValue}
    ${list_giatri_lech}    Set Variable Return From Dict    ${result_dict.Cost}
    Return From Keyword    ${list_ma_hh}    ${list_SystemCount}    ${list_ActualCount}   ${list_SL_lech}   ${list_giatri_lech}

Assert thong tin hang hoa trong phieu kiem
    [Arguments]    ${ma_phieu_kiem}    ${list_ma_hang}    ${list_SL_thucte}    ${list_count_SL_lech}    ${list_count_gia_tri_lech}
    ${list_ma_hang}    ${list_SL_thucte}    ${list_count_SL_lech}    ${list_count_gia_tri_lech}    Reverse four lists    ${list_ma_hang}    ${list_SL_thucte}    ${list_count_SL_lech}    ${list_count_gia_tri_lech}
    ${get_list_ma_hh}    ${get_list_SystemCount}    ${get_list_ActualCount}   ${get_list_SL_lech}   ${get_list_giatri_lech}    Get list thong tin hang hoa trong phieu kiem Kho    ${ma_phieu_kiem}
    KV Lists Should Be Equal    ${list_ma_hang}    ${get_list_ma_hh}    msg=Lỗi sai danh sách mã hàng trong phiếu
    KV Lists Should Be Equal    ${list_SL_thucte}    ${get_list_ActualCount}    msg=Lỗi sai SL thực tế của HH trong phiếu
    KV Lists Should Be Equal    ${list_count_SL_lech}    ${get_list_SL_lech}    msg=Lỗi sai SL lệch của HH trong phiếu
    KV Lists Should Be Equal    ${list_count_gia_tri_lech}    ${get_list_giatri_lech}    msg=Lỗi sai giá trị lệch của HH trong phiếu

Assert status of inventory
    [Arguments]    ${inventory_code}    ${status}
    ${get_status}    Get status of inventory by code    ${inventory_code}
    KV Should Be Equal As Numbers    ${status}    ${get_status}    msg=Lỗi sai trạng thái phiếu

Get status of inventory by code
    [Arguments]    ${inventory_code}
    ${jsonpath}    Set Variable    $.Data[?(@.Code\=\="${inventory_code}")].["Status"]
    ${result_dict}    Get dict all stocktake info    ${jsonpath}
    ${status_inventorycode}   Set Variable Return From Dict    ${result_dict.Status[0]}
    Return From Keyword    ${status_inventorycode}

Assert trang thai phieu kiem kho sau khi xoa
    [Arguments]   ${inventory_code}
    ${status_inventorycode}   Get status of inventory by code    ${inventory_code}
    KV Should Be Equal As Integers    ${status_inventorycode}    2    msg=Lỗi sai trạng thái phiếu

Assert phieu kiem kho hoan thanh sau khi xoa
    [Arguments]   ${inventory_code}
    Assert trang thai phieu kiem kho sau khi xoa    ${inventory_code}
    ${list_product_code}    Get list ma hang hoa trong phieu kiem Kho    ${inventory_code}
    FOR   ${item_product_code}    IN    @{list_product_code}
         Assert values not avaiable in Stock Card    ${inventory_code}    ${item_product_code}
    END

Assert thong tin trang thai phieu kiem kho
    [Arguments]    ${ma_phieu_kiem}    ${value_status_draft}
    ${list_jsonpath}    Create List    $.Data[?(@.Code\=\="${ma_phieu_kiem}")].Status
    ${result_dict}    Get dict all stocktake info    ${list_jsonpath}
    ${get_status}    Set Variable Return From Dict    ${result_dict.Status[0]}
    KV Should Be Equal As Numbers    ${value_status_draft}    ${get_status}    msg=Lỗi sai trạng thái phiếu

# Lấy thông tin để so sánh với file export tong quan
Get info to export all inventory
    [Arguments]    ${search_ma_phieu}    ${input_thoi_gian}=today
    ${list_jsonpath}    Create List    $.Data[*].["Code","CreatedDate","AdjustmentDate","TotalAdjustmentValue","TotalQuantityIncrease","TotalQuantityReduced","Description","Status"]
    ${result_dict}    Get dict all stocktake info    ${list_jsonpath}    thoi_gian=${input_thoi_gian}    is_phieu_huy=False    search_ma_phieu=${search_ma_phieu}
    Convert status number of inventory to string    ${result_dict}
    ${result_dict.Description}    Set Variable Return From Dict    ${result_dict.Description}
    # Convert giá trị thời gian và ngày cân bằng sang định dạng string để so sánh
    ${result_dict.CreatedDate}        KV Convert DateTime To String    ${result_dict.CreatedDate}
    ${result_dict.AdjustmentDate}    KV Convert DateTime To String    ${result_dict.AdjustmentDate}
    Return From Keyword    ${result_dict}

Convert status number of inventory to string
    [Arguments]    ${result_dict}
    ${index}    Set Variable    -1
    FOR    ${item}    IN    @{result_dict.Status}
        ${index}    Evaluate    ${index}+1
        ${status_num}    Run Keyword If    '${item}' == '0'   Set Variable    Phiếu tạm
        ...    ELSE IF   '${item}' == '1'   Set Variable    Đã cân bằng kho
        ...    ELSE IF   '${item}' == '2'   Set Variable    Đã hủy
        Set List Value    ${result_dict.Status}    ${index}    ${status_num}
    END

# Lấy thông tin để so sánh với file export chi tiết
Get info to export detail all inventory
    [Arguments]    ${search_ma_phieu}    ${input_thoi_gian}=today
    # Lấy thông tin từ API all phiếu kiểu
    ${list_jsonpath}    Create List    $.Data[*].["Id","Code","CreatedDate","AdjustmentDate","TotalActualCount","TotalPriceActual","TotalAdjustmentPrice","TotalQuantityIncrease","TotalPriceIncrease","TotalQuantityReduced","TotalPriceReduced","Description","Status"]
    ...    $.Data[*].["UserCreate.CompareGivenName","User.GivenName"]
    ${dict_all}    Get dict all stocktake info    ${list_jsonpath}    thoi_gian=${input_thoi_gian}    is_phieu_huy=False    search_ma_phieu=${search_ma_phieu}

    ${list_inventory_id}    Set Variable Return From Dict    ${dict_all.Id}
    Convert status number of inventory to string    ${dict_all}
    ${dict_all.Description}    Set Variable Return From Dict    ${dict_all.Description}

    ${dict_all.CreatedDate}       KV Convert DateTime To String    ${dict_all.CreatedDate}
    ${dict_all.AdjustmentDate}    KV Convert DateTime To String    ${dict_all.AdjustmentDate}

    ${result_dict}    Create Dictionary    unique_key=@{EMPTY}             Code=@{EMPTY}                   CreatedDate=@{EMPTY}              AdjustmentDate=@{EMPTY}     TotalActualCount=@{EMPTY}
    ...                                    TotalPriceActual=@{EMPTY}       TotalAdjustmentPrice=@{EMPTY}   TotalQuantityIncrease=@{EMPTY}    TotalPriceIncrease=@{EMPTY}
    ...                                    TotalQuantityReduced=@{EMPTY}   TotalPriceReduced=@{EMPTY}      Description=@{EMPTY}               Status=@{EMPTY}
    ...                                    UserCreateName=@{EMPTY}         UserName=@{EMPTY}
    ...                                    ProductCode=@{EMPTY}            ProductName=@{EMPTY}            SystemCount=@{EMPTY}               ActualCount=@{EMPTY}
    ...                                    AdjustmentValue=@{EMPTY}        Cost=@{EMPTY}

    FOR   ${inventory_id}    IN ZIP    ${list_inventory_id}
          ${index_inventory}    Get Index From List    ${list_inventory_id}    ${inventory_id}
          ${dict_detail}    Get dict full info of product in inventory    ${inventory_id}
          Inventory mix data from API    ${dict_all.Code[${index_inventory}]}    ${result_dict}    ${dict_all}    ${dict_detail}    ${index_inventory}
    END
    Return From Keyword    ${result_dict}

Inventory mix data from API
    [Arguments]    ${inventory_code}    ${result_dict}    ${dict_all}    ${dict_detail}    ${index_inventory}
    FOR    ${product_code}    IN    @{dict_detail.ProductCode}
          ${index_product}    Get Index From List    ${dict_detail.ProductCode}    ${product_code}
          ${unique_value}    Set Variable    ${inventory_code}-${product_code}
          Append To List    ${result_dict.unique_key}    ${unique_value}
          Append To List    ${result_dict.Code}                     ${dict_all.Code[${index_inventory}]}
          Append To List    ${result_dict.CreatedDate}              ${dict_all.CreatedDate[${index_inventory}]}
          Append To List    ${result_dict.AdjustmentDate}           ${dict_all.AdjustmentDate[${index_inventory}]}
          Append To List    ${result_dict.TotalActualCount}         ${dict_all.TotalActualCount[${index_inventory}]}
          Append To List    ${result_dict.TotalPriceActual}         ${dict_all.TotalPriceActual[${index_inventory}]}
          Append To List    ${result_dict.TotalAdjustmentPrice}     ${dict_all.TotalAdjustmentPrice[${index_inventory}]}
          Append To List    ${result_dict.TotalQuantityIncrease}    ${dict_all.TotalQuantityIncrease[${index_inventory}]}
          Append To List    ${result_dict.TotalPriceIncrease}       ${dict_all.TotalPriceIncrease[${index_inventory}]}
          Append To List    ${result_dict.TotalQuantityReduced}     ${dict_all.TotalQuantityReduced[${index_inventory}]}
          Append To List    ${result_dict.TotalPriceReduced}        ${dict_all.TotalPriceReduced[${index_inventory}]}
          Append To List    ${result_dict.Description}              ${dict_all.Description[${index_inventory}]}
          Append To List    ${result_dict.Status}                   ${dict_all.Status[${index_inventory}]}
          Append To List    ${result_dict.UserCreateName}           ${dict_all.CompareGivenName[${index_inventory}]}
          Append To List    ${result_dict.UserName}                 ${dict_all.GivenName[${index_inventory}]}
          #
          Append To List    ${result_dict.ProductCode}              ${dict_detail.ProductCode[${index_product}]}
          Append To List    ${result_dict.ProductName}              ${dict_detail.ProductName[${index_product}]}
          Append To List    ${result_dict.SystemCount}              ${dict_detail.SystemCount[${index_product}]}
          Append To List    ${result_dict.ActualCount}              ${dict_detail.ActualCount[${index_product}]}
          Append To List    ${result_dict.AdjustmentValue}          ${dict_detail.AdjustmentValue[${index_product}]}
          Append To List    ${result_dict.Cost}                     ${dict_detail.Cost[${index_product}]}
    END

Get dict full info of product in inventory
    [Arguments]    ${inventory_id}
    ${list_jsonpath}    Create List    $.Data[*].["ProductCode","ProductName","SystemCount","ActualCount","AdjustmentValue","Cost"]
    ${dict_detail}    Get dict detail stocktake info    ${inventory_id}    ${list_jsonpath}
    Return From Keyword    ${dict_detail}

Assert thong tin chung ve tien giua UI va API
    [Arguments]    ${ma_pk}    ${text_tong_chenh_lech}   ${text_tong_gtri_lech}   ${text_sl_lech_tang}   ${text_tong_gtri_tang}   ${text_sl_lech_giam}   ${text_tong_gtri_giam}
    ${list_jsonpath}    Create List    $.Data[?(@.Code\=\="${ma_pk}")].["TotalAdjustmentValue","TotalAdjustmentPrice","TotalQuantityIncrease","TotalPriceIncrease","TotalQuantityReduced","TotalPriceReduced"]
    ${result_dict}    Get dict all stocktake info    ${list_jsonpath}    is_phieu_huy=False
    KV Should Be Equal As Numbers    ${text_tong_chenh_lech}    ${result_dict.TotalAdjustmentValue[0]}    msg=Hiển thị sai Tổng chênh lệch ở dòng thông tin chung
    KV Should Be Equal As Numbers    ${text_tong_gtri_lech}     ${result_dict.TotalAdjustmentPrice[0]}    msg=Hiển thị sai Tổng giá trị lệch ở dòng thông tin chung
    KV Should Be Equal As Numbers    ${text_sl_lech_tang}       ${result_dict.TotalQuantityIncrease[0]}   msg=Hiển thị sai SL lệch tăng ở dòng thông tin chung
    KV Should Be Equal As Numbers    ${text_tong_gtri_tang}     ${result_dict.TotalPriceIncrease[0]}      msg=Hiển thị sai Tổng giá trị tăng ở dòng thông tin chung
    KV Should Be Equal As Numbers    ${text_sl_lech_giam}       ${result_dict.TotalQuantityReduced[0]}    msg=Hiển thị sai SL lệch giảm ở dòng thông tin chung
    KV Should Be Equal As Numbers    ${text_tong_gtri_giam}     ${result_dict.TotalPriceReduced[0]}       msg=Hiển thị sai Tổng giá trị giảm ở dòng thông tin chung

Assert thong tin tong cua chi tiet phieu kiem
    [Arguments]    ${ma_pk}    ${text_tong_thuc_te}    ${text_tong_lech_tang}    ${text_tong_lech_giam}    ${text_tong_chenh_lech}
    ${list_jsonpath}    Create List    $.Data[?(@.Code\=\="${ma_pk}")].["TotalPriceActual","TotalPriceIncrease","TotalPriceReduced","TotalAdjustmentPrice"]
    ${result_dict}    Get dict all stocktake info    ${list_jsonpath}    is_phieu_huy=False
    KV Should Be Equal As Numbers    ${text_tong_thuc_te}       ${result_dict.TotalPriceActual[0]}       msg=Hiển thị sai Tổng thực tế trong chi tiết phiếu kiểm kho
    KV Should Be Equal As Numbers    ${text_tong_lech_tang}     ${result_dict.TotalPriceIncrease[0]}     msg=Hiển thị sai Tổng lệch tăng trong chi tiết phiếu kiểm kho
    KV Should Be Equal As Numbers    ${text_tong_lech_giam}     ${result_dict.TotalPriceReduced[0]}      msg=Hiển thị sai Tổng lệch giảm trong chi tiết phiếu kiểm kho
    KV Should Be Equal As Numbers    ${text_tong_chenh_lech}    ${result_dict.TotalAdjustmentPrice[0]}   msg=Hiển thị sai Tổng chênh lệch trong chi tiết phiếu kiểm kho

#
