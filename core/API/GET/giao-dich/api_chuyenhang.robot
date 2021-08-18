*** Settings ***
Resource          ../../api_access.robot
Resource          ../hang-hoa/api_danhmuc_hanghoa.robot
Resource          ../../../share/computation.robot
Resource          ../../../share/utils.robot
Library           String
Library           Collections

*** Variable ***
&{dict_trang_thai}    1=Phiếu tạm    2=Đang chuyển    3=Đã nhận    4=Đã chuyển

*** Keywords ***
# Lấy thông tin all phiếu chuyển toàn thời gian và trạng thái phiếu được truyền vào
Get dict all product transfer info
    [Arguments]    ${list_jsonpath}    ${is_phieu_tam}=True    ${is_phieu_dang_chuyen}=True    ${is_phieu_da_nhan}=True    ${is_phieu_huy}=False
    ${filter_status}    KV Get Filter Status Product Transfer    ${is_phieu_tam}    ${is_phieu_dang_chuyen}    ${is_phieu_da_nhan}    ${is_phieu_huy}
    ${filter_data}    Set Variable    ((FromBranchId+eq+${BRANCH_ID}+or+ToBranchId+eq+${BRANCH_ID})+and+(${filter_status}))
    ${input_dict}    Create Dictionary    filter_data=${filter_data}
    ${result_dict}    API Call From Template    /chuyen-hang/all_phieu_chuyen_hang.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

# Filter theo status của giao dịch chuyen hang
KV Get Filter Status Product Transfer
    [Arguments]    ${is_phieu_tam}    ${is_phieu_dang_chuyen}    ${is_phieu_da_nhan}    ${is_phieu_huy}
    ${list_filter}    Create List
    Run Keyword If    '${is_phieu_tam}' == 'True'           Append To List    ${list_filter}    Status+eq+1
    Run Keyword If    '${is_phieu_dang_chuyen}' == 'True'    Append To List    ${list_filter}    Status+eq+2
    Run Keyword If    '${is_phieu_da_nhan}' == 'True'           Append To List    ${list_filter}    Status+eq+3
    Run Keyword If    '${is_phieu_huy}' == 'True'           Append To List    ${list_filter}    Status+eq+4
    ${list_filter}     Evaluate    "+or+".join(${list_filter})
    Return From Keyword    ${list_filter}

Get dict detail product transfer info
    [Arguments]    ${id_phieu_chuyen}    ${list_jsonpath}
    ${find_dict}    Create Dictionary    id_phieu_chuyen=${id_phieu_chuyen}
    ${result_dict}    API Call From Template    /chuyen-hang/detail_phieu_chuyen_hang.txt    ${find_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get total of product transfer note frm API
    ${jsonpath}    Set Variable    $.["Total"]
    ${result_dict}    Get dict all product transfer info    ${jsonpath}
    ${tong_phieu_chuyen}    Set Variable Return From Dict    ${result_dict.Total[0]}
    Return From Keyword    ${tong_phieu_chuyen}

Get id product transfer note by code
    [Arguments]    ${ma_phieu_chuyen}
    ${dict_id}    Get dict all product transfer info    $.Data[?(@.Code\=\="${ma_phieu_chuyen}")].Id
    ${id_phieu_chuyen}    Set Variable Return From Dict    ${dict_id.Id[0]}
    Return From Keyword    ${id_phieu_chuyen}

Get status of product transfer by code
    [Arguments]    ${ma_phieu_chuyen}
    ${result_dict}    Get dict all product transfer info    $.Data[?(@.Code\=\="${ma_phieu_chuyen}")].["Status"]    is_phieu_huy=True
    ${status_product_transfer}    Set Variable Return From Dict    ${result_dict.Status[0]}
    Return From Keyword    ${status_product_transfer}

Get product info in product transfer note
    [Arguments]    ${id_phieu_chuyen}
    ${list_jsonpath}    Create List    $.Data[*].["ProductCode","SendQuantity"]
    ${result_dict}    Get dict detail product transfer info    ${id_phieu_chuyen}    ${list_jsonpath}
    ${list_product_code}   Set Variable Return From Dict    ${result_dict.ProductCode}
    ${list_quantity}   Set Variable Return From Dict    ${result_dict.SendQuantity}
    Return From Keyword    ${list_product_code}    ${list_quantity}

Get list thong tin cua hang hoa trong phieu chuyen hang
    [Arguments]    ${ma_phieu_chuyen}
    ${id_phieu_chuyen}    Get id product transfer note by code    ${ma_phieu_chuyen}
    ${result_dict}      Get dict detail product transfer info    ${id_phieu_chuyen}    $.Data[*].["ProductCode","SendQuantity","SendPrice"]
    ${list_ma_hang}    Set Variable Return From Dict    ${result_dict.ProductCode}
    ${list_so_luong}    Set Variable Return From Dict    ${result_dict.SendQuantity}
    ${list_thanh_tien}    Set Variable Return From Dict    ${result_dict.SendPrice}
    Return From Keyword    ${list_ma_hang}    ${list_so_luong}    ${list_thanh_tien}

Get dict summary data in product transfer note from branch
    [Arguments]    ${id_phieu_chuyen}
    ${list_jsonpath}    Create List    $.["Total","Total1Value","Total3Value"]
    ${result_dict}    Get dict detail product transfer info    ${id_phieu_chuyen}    ${list_jsonpath}
    ${dict_summary_data}    Create Dictionary    tong_mat_hang=${result_dict["Total"]}    tong_sl_chuyen=${result_dict["Total1Value"]}
    ...    tong_giatri_chuyen=${result_dict["Total3Value"]}
    Log   ${dict_summary_data}
    Return From Keyword    ${dict_summary_data}

Get dict summary data in product transfer note to branch
    [Arguments]    ${id_phieu_chuyen}
    ${list_jsonpath}    Create List    $.["Total","Total1Value","Total2Value","Total3Value","Total4Value"]
    ${result_dict}    Get dict detail product transfer info    ${id_phieu_chuyen}    ${list_jsonpath}
    ${dict_summary_data}    Create Dictionary    tong_mat_hang=${result_dict["Total"]}    tong_sl_chuyen=${result_dict["Total1Value"]}
    ...    tong_giatri_chuyen=${result_dict["Total3Value"]}    tong_sl_nhan=${result_dict["Total2Value"]}   tong_giatri_nhan=${result_dict["Total4Value"]}
    Log   ${dict_summary_data}
    Return From Keyword    ${dict_summary_data}

Get list ma hang hoa trong phieu chuyen hang
    [Arguments]    ${ma_phieu_chuyen}
    ${id_phieu_chuyen}    Get id product transfer note by code    ${ma_phieu_chuyen}
    ${result_dict}    Get dict detail purchase order info    ${id_phieu_chuyen}    $.Data[*].["ProductCode"]
    ${list_ma_hang}    Set Variable Return From Dict    ${result_dict.ProductCode}
    Return From Keyword    ${list_ma_hang}

Get tong so luong va tong gia tri chuyen cua phieu chuyen hang
    [Arguments]    ${ma_phieu_chuyen}
    ${result_dict}    Get dict all product transfer info    $.Data[?(@.Code\=\="${ma_phieu_chuyen}")].["SendTotalPrice","TotalSendQuantity"]
    ${tong_giatri_chuyen}    Set Variable Return From Dict    ${result_dict.SendTotalPrice[0]}
    ${tong_sl_chuyen}    Set Variable Return From Dict    ${result_dict.TotalSendQuantity[0]}
    Return From Keyword    ${tong_sl_chuyen}    ${tong_giatri_chuyen}

Get tong gia tri cua tat ca phieu chuyen hang
    [Arguments]    ${is_phieu_tam}=True    ${is_phieu_dang_chuyen}=True    ${is_phieu_da_nhan}=True    ${is_phieu_huy}=True
    ${result_dict}    Get dict all product transfer info    $.Total1Value    is_phieu_tam=${is_phieu_tam}    is_phieu_dang_chuyen=${is_phieu_dang_chuyen}
    ...    is_phieu_da_nhan=${is_phieu_da_nhan}    is_phieu_huy=${is_phieu_huy}
    ${tong_gia_tri}    Set Variable Return From Dict    ${result_dict.Total1Value[0]}
    Return From Keyword    ${tong_gia_tri}

# Lấy thông tin để so sánh với file export tổng quan
Get info to export all product transfer note
    [Arguments]    ${is_phieu_tam}=True    ${is_phieu_dang_chuyen}=True    ${is_phieu_da_nhan}=True    ${is_phieu_huy}=True
    ${list_jsonpath}    Create List    $.Data[?(@.Id!=-1)].["Code","FromBranchName","ToBranchName","DispatchedDate","SendTotalPrice","Status"]
    ${result_dict}    Get dict all product transfer info    ${list_jsonpath}    is_phieu_tam=${is_phieu_tam}    is_phieu_dang_chuyen=${is_phieu_dang_chuyen}
    ...    is_phieu_da_nhan=${is_phieu_da_nhan}    is_phieu_huy=${is_phieu_huy}
    ${result_dict.Status}    KV Convert List Type From Number To VN String    ${result_dict.Status}    ${dict_trang_thai}
    ${result_dict.DispatchedDate}    KV Convert DateTime To String    ${result_dict.DispatchedDate}
    Log    ${result_dict}
    Return From Keyword    ${result_dict}

# Lấy thông tin để so sánh với file export chi tiết
Get info to export all detail product transfer
    [Arguments]    ${is_phieu_tam}=True    ${is_phieu_dang_chuyen}=True    ${is_phieu_da_nhan}=True    ${is_phieu_huy}=True
    ${list_jsonpath}    Create List    $.Data[?(@.Id!=-1)].["Id","FromBranchName","ToBranchName","Code","CreatedDate","DispatchedDate","ReceivedDate","User.GivenName","Description","ReceivedDescription","TotalSendQuantity","SendTotalPrice","TotalReceiveQuantity","ReceiveTotalPrice","TotalProductType","Status"]

    ${dict_all}    Get dict all product transfer info    ${list_jsonpath}    is_phieu_tam=${is_phieu_tam}    is_phieu_dang_chuyen=${is_phieu_dang_chuyen}
    ...    is_phieu_da_nhan=${is_phieu_da_nhan}    is_phieu_huy=${is_phieu_huy}

    ${dict_all.ReceivedDate}           Set Variable Return From Dict    ${dict_all.ReceivedDate}
    ${dict_all.Description}            Set Variable Return From Dict    ${dict_all.Description}
    ${dict_all.ReceivedDescription}    Set Variable Return From Dict    ${dict_all.ReceivedDescription}

    ${dict_all.CreatedDate}       KV Convert DateTime To String    ${dict_all.CreatedDate}
    ${dict_all.DispatchedDate}    KV Convert DateTime To String    ${dict_all.DispatchedDate}
    ${dict_all.ReceivedDate}      KV Convert DateTime To String    ${dict_all.ReceivedDate}

    ${result_dict}    Create Dictionary     unique_key=@{EMPTY}    ma_chuyen_hang=@{EMPTY}    tu_chi_nhanh=@{EMPTY}    toi_chi_nhanh=@{EMPTY}    ngay_chuyen=@{EMPTY}
    ...    ngay_nhan=@{EMPTY}    nguoi_tao=@{EMPTY}    ghi_chu_chuyen=@{EMPTY}    ghi_chu_nhan=@{EMPTY}    tong_sl_chuyen=@{EMPTY}    tong_gt_chuyen=@{EMPTY}
    ...    tong_sl_nhan=@{EMPTY}    tong_gt_nhan=@{EMPTY}    tong_so_mat_hang=@{EMPTY}    trang_thai=@{EMPTY}    ma_hang=@{EMPTY}    ten_hang=@{EMPTY}
    ...    don_vi_tinh=@{EMPTY}    ghi_chu_hh=@{EMPTY}    so_luong_chuyen=@{EMPTY}    so_luong_nhan=@{EMPTY}    gia_chuyen_nhan=@{EMPTY}
    ...    thanh_tien_chuyen=@{EMPTY}    thanh_tien_nhan=@{EMPTY}

    FOR    ${transfer_id}    IN    @{dict_all.Id}
        ${index}    Get Index From List    ${dict_all.Id}    ${transfer_id}

        Transfer mix data from api    ${transfer_id}    ${dict_all}    ${result_dict}    ${index}
    END
    Return From Keyword    ${result_dict}

Transfer mix data from api
    [Arguments]    ${transfer_id}    ${dict_all}    ${result_dict}    ${transfer_index}
    ${list_jsonpath}    Create List    $.Data[*].["ProductCode","ProductName","Product.Unit","Product.Description","SendQuantity","ReceiveQuantity","Price","SendPrice","ReceivePrice"]

    ${dict_detail}    Get dict detail product transfer info    ${transfer_id}    ${list_jsonpath}

    ${dict_detail.Unit}            Set Variable Return From Dict    ${dict_detail.Unit}
    ${dict_detail.Description}    Set Variable Return From Dict    ${dict_detail.Description}

    FOR    ${pr_code}    IN    @{dict_detail.ProductCode}
        ${index}    Get Index From List    ${dict_detail.ProductCode}    ${pr_code}

        # Set unique key
        ${unique_value}    Set Variable    ${dict_all.Code[${transfer_index}]}-${dict_detail.ProductCode[${index}]}
        # Get tên HH kèm thuộc tính
        ${pr_name_attr}    Get product name with attribute    ${dict_detail.ProductCode[${index}]}    ${dict_detail.ProductName[${index}]}    ${dict_detail.Unit[${index}]}

        Append To List    ${result_dict.unique_key}              ${unique_value}
        Append To List    ${result_dict.tu_chi_nhanh}            ${dict_all.FromBranchName[${transfer_index}]}
        Append To List    ${result_dict.toi_chi_nhanh}           ${dict_all.ToBranchName[${transfer_index}]}
        Append To List    ${result_dict.ma_chuyen_hang}          ${dict_all.Code[${transfer_index}]}

        Run Keyword If    '${dict_all.Status[${transfer_index}]}'=='1'    Append To List    ${result_dict.ngay_chuyen}    ${dict_all.CreatedDate[${transfer_index}]}
        ...    ELSE    Append To List    ${result_dict.ngay_chuyen}    ${dict_all.DispatchedDate[${transfer_index}]}

        Append To List    ${result_dict.ngay_nhan}               ${dict_all.ReceivedDate[${transfer_index}]}
        Append To List    ${result_dict.nguoi_tao}               ${dict_all.GivenName[${transfer_index}]}
        Append To List    ${result_dict.ghi_chu_chuyen}          ${dict_all.Description[${transfer_index}]}
        Append To List    ${result_dict.ghi_chu_nhan}            ${dict_all.ReceivedDescription[${transfer_index}]}
        Append To List    ${result_dict.tong_sl_chuyen}          ${dict_all.TotalSendQuantity[${transfer_index}]}
        Append To List    ${result_dict.tong_gt_chuyen}          ${dict_all.SendTotalPrice[${transfer_index}]}

        Run Keyword If    '${dict_all.Status[${transfer_index}]}'=='3'    Run Keywords    Append To List    ${result_dict.tong_sl_nhan}
        ...    ${dict_all.TotalReceiveQuantity[${transfer_index}]}    AND    Append To List    ${result_dict.tong_gt_nhan}    ${dict_all.ReceiveTotalPrice[${transfer_index}]}
        ...    ELSE    Run Keywords    Append To List    ${result_dict.tong_sl_nhan}    ${0}    AND    Append To List    ${result_dict.tong_gt_nhan}    ${0}

        Append To List    ${result_dict.tong_so_mat_hang}        ${dict_all.TotalProductType[${transfer_index}]}
        Append To List    ${result_dict.trang_thai}              ${dict_trang_thai["${dict_all["Status"][${transfer_index}]}"]}

        Append To List    ${result_dict.ma_hang}                 ${dict_detail.ProductCode[${index}]}
        Append To List    ${result_dict.ten_hang}                ${pr_name_attr}
        Append To List    ${result_dict.don_vi_tinh}             ${dict_detail.Unit[${index}]}
        Append To List    ${result_dict.ghi_chu_hh}              ${dict_detail.Description[${index}]}
        Append To List    ${result_dict.so_luong_chuyen}         ${dict_detail.SendQuantity[${index}]}
        Append To List    ${result_dict.gia_chuyen_nhan}         ${dict_detail.Price[${index}]}
        Append To List    ${result_dict.thanh_tien_chuyen}       ${dict_detail.SendPrice[${index}]}
        Run Keyword If    '${dict_all.Status[${transfer_index}]}'=='3'    Run Keywords    Append To List    ${result_dict.so_luong_nhan}    ${dict_detail.ReceiveQuantity[${index}]}
        ...    AND    Append To List    ${result_dict.thanh_tien_nhan}    ${dict_detail.ReceivePrice[${index}]}
        ...    ELSE    Run Keywords    Append To List    ${result_dict.so_luong_nhan}    ${0}    AND    Append To List    ${result_dict.thanh_tien_nhan}    ${0}
    END

Get full product info in product transfer
    [Arguments]    ${id_phieu_chuyen}    ${trang_thai_phieu}

    ${result_dict}    Create Dictionary    ma_hang=@{EMPTY}    ten_hang=@{EMPTY}    don_vi_tinh=@{EMPTY}    sl_chuyen=@{EMPTY}
    ...    sl_nhan=@{EMPTY}    gia_chuyen_nhan=@{EMPTY}    thanh_tien_chuyen=@{EMPTY}    thanh_tien_nhan=@{EMPTY}

    ${list_jsonpath}    Create List    $.Data[*].["ProductCode","ProductName","Product.Unit","SendQuantity","ReceiveQuantity","Price","SendPrice","ReceivePrice"]
    ${dict_detail}    Get dict detail product transfer info    ${id_phieu_chuyen}    ${list_jsonpath}

    ${result_dict.ma_hang}              Set Variable Return From Dict    ${dict_detail.ProductCode}
    ${list_ten_hang}                    Set Variable Return From Dict    ${dict_detail.ProductName}
    ${result_dict.don_vi_tinh}          Set Variable Return From Dict    ${dict_detail.Unit}
    ${result_dict.sl_chuyen}            Set Variable Return From Dict    ${dict_detail.SendQuantity}
    ${list_sl_nhan}                     Set Variable Return From Dict    ${dict_detail.ReceiveQuantity}
    ${result_dict.gia_chuyen_nhan}      Set Variable Return From Dict    ${dict_detail.Price}
    ${result_dict.thanh_tien_chuyen}    Set Variable Return From Dict    ${dict_detail.SendPrice}
    ${list_thanh_tien_nhan}             Set Variable Return From Dict    ${dict_detail.ReceivePrice}

    FOR    ${pr_code}    IN    @{result_dict.ma_hang}
        ${index}    Get Index From List    ${result_dict.ma_hang}    ${pr_code}
        # Get tên HH kèm thuộc tính
        ${pr_name_attr}    Get product name with attribute    ${result_dict.ma_hang[${index}]}    ${list_ten_hang[${index}]}    ${result_dict.don_vi_tinh[${index}]}
        Append To List    ${result_dict.ten_hang}    ${pr_name_attr}
        Run Keyword If    '${trang_thai_phieu}'=='3'    Run Keywords    Append To List    ${result_dict.sl_nhan}    ${list_sl_nhan[${index}]}
        ...    AND    Append To List    ${result_dict.thanh_tien_nhan}    ${list_thanh_tien_nhan[${index}]}
        ...    ELSE    Run Keywords    Append To List    ${result_dict.sl_nhan}    ${0}    AND    Append To List    ${result_dict.thanh_tien_nhan}    ${0}
    END

    Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get total of product in transfer note frm API
    [Arguments]    ${id_phieu_chuyen}
    ${jsonpath}    Set Variable    $.Total
    ${result_dict}    Get dict detail product transfer info    ${id_phieu_chuyen}    ${jsonpath}
    ${tong_so_hang}    Set Variable Return From Dict    ${result_dict.Total[0]}
    Return From Keyword    ${tong_so_hang}

Assert status of product transfer note
    [Arguments]    ${product transfer_code}    ${status}
    ${get_status}    Get status of product transfer by code    ${product transfer_code}
    KV Compare Scalar Values    ${status}    ${get_status}    Lỗi trạng thái của phiếu chuyển hàng không đúng

Assert thong tin hang hoa trong phieu chuyen hang
    [Arguments]    ${ma_phieu_chuyen}    ${input_list_ma_hang}    ${input_list_sl_chuyen}
    ${id_phieu_chuyen}    Get id product transfer note by code    ${ma_phieu_chuyen}
    ${list_product_code}    ${list_quantity}    Get product info in product transfer note    ${id_phieu_chuyen}
    KV Lists Should Be Equal    ${input_list_ma_hang}    ${list_product_code}    Lỗi danh sách mã hàng input và trong API khác nhau
    KV Lists Should Be Equal    ${input_list_sl_chuyen}    ${list_quantity}    Lỗi danh sách số lượng chuyển input và trong API khác nhau

Assert thong tin phieu chuyen hang sau khi them moi
    [Arguments]    ${ma_phieu_chuyen}    ${count_tong_giatri_chuyen}    ${status}    ${ghi_chu_chuyen}=${0}
    ${list_jsonpath}    Create List    $.Data[?(@.Code\=\="${ma_phieu_chuyen}")].["ReceiveTotalPrice","Status","Description"]
    ${result_dict}    Get dict all product transfer info     ${list_jsonpath}
    ${get_tong_thanh_tien}    Set Variable Return From Dict    ${result_dict.ReceiveTotalPrice[0]}
    ${get_status}             Set Variable Return From Dict    ${result_dict.Status[0]}
    ${get_ghi_chu_chuyen}     Set Variable Return From Dict    ${result_dict.Description[0]}
    KV Should Be Equal As Numbers    ${count_tong_giatri_chuyen}    ${get_tong_thanh_tien}    Lỗi tổng giá trị chuyển tính toán trên UI và trong API khác nhau
    KV Compare Scalar Values    ${status}    ${get_status}    Lỗi trạng thái của phiếu chuyển hàng không đúng
    KV Compare Scalar Values    ${ghi_chu_chuyen}    ${get_ghi_chu_chuyen}    Lỗi ghi chú của phiếu chuyển input và trong API khác nhau

Assert thong tin phieu chuyen sau khi da nhan hang
    [Arguments]    ${ma_phieu_chuyen}    ${count_tong_sl_chuyen}    ${count_tong_sl_nhan}    ${count_tong_giatri_chuyen}    ${count_tong_giatri_nhan}
    ...    ${status}    ${ghi_chu_nhan}=${0}
    ${list_jsonpath}    Create List    $.Data[?(@.Code\=\="${ma_phieu_chuyen}")].["ReceiveTotalPrice","SendTotalPrice","TotalSendQuantity","TotalReceiveQuantity","Status","ReceivedDescription"]
    ${result_dict}    Get dict all product transfer info     ${list_jsonpath}
    ${get_tong_tt_nhan}      Set Variable Return From Dict    ${result_dict.ReceiveTotalPrice[0]}
    ${get_tong_tt_chuyen}    Set Variable Return From Dict    ${result_dict.SendTotalPrice[0]}
    ${get_tong_sl_nhan}      Set Variable Return From Dict    ${result_dict.TotalReceiveQuantity[0]}
    ${get_tong_sl_chuyen}    Set Variable Return From Dict    ${result_dict.TotalSendQuantity[0]}
    ${get_status}            Set Variable Return From Dict    ${result_dict.Status[0]}
    ${get_ghi_chu_nhan}      Set Variable Return From Dict    ${result_dict.ReceivedDescription[0]}

    KV Should Be Equal As Numbers    ${count_tong_sl_chuyen}    ${get_tong_sl_chuyen}    Lỗi tổng số lượng chuyển tính toán trên UI và trong API khác nhau
    KV Should Be Equal As Numbers    ${count_tong_sl_nhan}    ${get_tong_sl_nhan}    Lỗi tổng số lượng nhận tính toán trên UI và trong API khác nhau
    KV Should Be Equal As Numbers    ${count_tong_giatri_chuyen}    ${get_tong_tt_chuyen}    Lỗi tổng giá trị chuyển tính toán trên UI và trong API khác nhau
    KV Should Be Equal As Numbers    ${count_tong_giatri_nhan}    ${get_tong_tt_nhan}    Lỗi tổng giá trị nhận tính toán trên UI và trong API khác nhau
    KV Compare Scalar Values    ${status}    ${get_status}    Lỗi trạng thái của phiếu chuyển hàng không đúng
    KV Compare Scalar Values    ${ghi_chu_nhan}    ${get_ghi_chu_nhan}    Lỗi ghi chú của phiếu nhận input và trong API khác nhau

Assert thong tin ton kho sau khi huy phieu chuyen hang
    [Arguments]    ${ma_phieu_chuyen}    ${list_ma_hh}    ${input_list_ton_kho}
    ${list_ton_kho_af}    Get list onHand by list product code    ${list_ma_hh}
    KV Lists Should Be Equal    ${input_list_ton_kho}    ${list_ton_kho_af}    Lỗi danh sách tồn kho input và trong API khác nhau

Assert thong tin tong tat ca cac don trong API và UI
    [Arguments]    ${text_giatri_chuyen}    ${text_giatri_nhan}

    ${result_dict}    Get dict all product transfer info    $.["Total2Value","Total1Value"]

    KV Should Be Equal As Numbers     ${text_giatri_chuyen}           ${result_dict.Total1Value[0]}    msg=Sai thông tin giá trị chuyển
    KV Should Be Equal As Numbers     ${text_giatri_nhan}             ${result_dict.Total2Value[0]}    msg=Sai thông tin giá trị nhận

Assert thong tin tong cua mot don trong API và UI
    [Arguments]    ${id_phieu_chuyen}    ${text_giatri_chuyen}    ${text_giatri_nhan}

    ${result_dict}    Get dict detail product transfer info    ${id_phieu_chuyen}    $.["Total3Value","Total4Value"]

    KV Should Be Equal As Numbers     ${text_giatri_chuyen}           ${result_dict.Total3Value[0]}    msg=Sai thông tin giá trị chuyển
    KV Should Be Equal As Numbers     ${text_giatri_nhan}             ${result_dict.Total4Value[0]}    msg=Sai thông tin giá trị nhận

Assert thong tin tong trong chi tiet dơn tren API và UI
    [Arguments]    ${id_phieu_chuyen}    ${text_giatri_chuyen}    ${text_giatri_nhan}

    ${result_dict}    Get dict detail product transfer info    ${id_phieu_chuyen}    $.["Total3Value","Total4Value"]

    KV Should Be Equal As Numbers     ${text_giatri_chuyen}           ${result_dict.Total3Value[0]}    msg=Sai thông tin giá trị chuyển
    KV Should Be Equal As Numbers     ${text_giatri_nhan}             ${result_dict.Total4Value[0]}    msg=Sai thông tin giá trị nhận
