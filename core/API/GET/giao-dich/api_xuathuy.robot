*** Settings ***
Resource          ../../api_access.robot
Resource          ../hang-hoa/api_danhmuc_hanghoa.robot
Resource          ../../../share/computation.robot
Resource          ../../../share/utils.robot
Library           String
Library           Collections

*** Variable ***
&{dict_trang_thai}    1=Phiếu tạm    2=Hoàn thành    3=Đã hủy

*** Keywords ***
# Lấy thông tin all phiếu nhập mặc định theo Hôm nay. (bao gồm cả phiếu Đã hủy)
Get dict all damage items info
    [Arguments]    ${list_jsonpath}    ${filter_time}=today    ${is_phieu_tam}=True    ${is_phieu_hoan_thanh}=True    ${is_phieu_huy}=True
    ${filter_status}    KV Get Filter Status damage items    ${is_phieu_tam}    ${is_phieu_hoan_thanh}    ${is_phieu_huy}
    ${filter_data}    Set Variable    (BranchId+eq+${BRANCH_ID}+and+TransDate+eq+'${filter_time}'+and+(${filter_status}))
    ${input_dict}    Create Dictionary    filter_data=${filter_data}
    ${result_dict}    API Call From Template    /xuat-huy/all_phieu_xuat_huy.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

# Filter theo status của giao dịch xuat huy
KV Get Filter Status Damage Items
    [Arguments]    ${is_phieu_tam}    ${is_phieu_hoan_thanh}    ${is_phieu_huy}
    ${list_filter}    Create List
    Run Keyword If    '${is_phieu_tam}' == 'True'           Append To List    ${list_filter}    Status+eq+1
    Run Keyword If    '${is_phieu_hoan_thanh}' == 'True'    Append To List    ${list_filter}    Status+eq+2
    Run Keyword If    '${is_phieu_huy}' == 'True'           Append To List    ${list_filter}    Status+eq+3
    ${list_filter}     Evaluate    "+or+".join(${list_filter})
    Return From Keyword    ${list_filter}

Get dict detail damage items info
    [Arguments]    ${id_phieu_xh}    ${list_jsonpath}
    ${find_dict}    Create Dictionary    id_phieu_xh=${id_phieu_xh}
    ${result_dict}    API Call From Template    /xuat-huy/detail_phieu_xuat_huy.txt    ${find_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get total of damageitems note frm API
    ${jsonpath}    Set Variable    $.["Total"]
    ${result_dict}    Get dict all damage items info    ${jsonpath}
    ${tong_phieu_huy}    Set Variable Return From Dict    ${result_dict.Total[0]}
    Return From Keyword    ${tong_phieu_huy}

Get id damageitems note by code
    [Arguments]    ${ma_phieu_xh}
    ${dict_id}    Get dict all damage items info    $.Data[?(@.Code\=\="${ma_phieu_xh}")].Id
    ${id_phieu_xh}    Set Variable Return From Dict    ${dict_id.Id[0]}
    Return From Keyword    ${id_phieu_xh}

Get status of damage items by code
    [Arguments]    ${ma_phieu_xh}
    ${result_dict}    Get dict all damage items info    $.Data[?(@.Code\=\="${ma_phieu_xh}")].["Status"]
    ${status_damage_items}   Set Variable Return From Dict    ${result_dict.Status[0]}
    Return From Keyword    ${status_damage_items}

Get product info in damage items note
    [Arguments]    ${id_phieu_xh}
    ${list_jsonpath}    Create List    $.Data[*].["Product.Code","Quantity"]
    ${result_dict}    Get dict detail damage items info    ${id_phieu_xh}    ${list_jsonpath}
    ${list_product_code}   Set Variable Return From Dict    ${result_dict.Code}
    ${list_quantity}   Set Variable Return From Dict    ${result_dict.Quantity}
    Return From Keyword    ${list_product_code}    ${list_quantity}

Get list thong tin cua hang hoa trong phieu xuat huy
    [Arguments]    ${ma_phieu_xh}
    ${id_phieu_xh}    Get id damageitems note by code    ${ma_phieu_xh}
    ${result_dict}      Get dict detail damage items info    ${id_phieu_xh}    $.Data[*].["Product.Code","Quantity","ProductCost"]
    ${list_ma_hang}    Set Variable Return From Dict    ${result_dict.Code}
    ${list_so_luong}    Set Variable Return From Dict    ${result_dict.Quantity}
    ${list_gia_von}    Set Variable Return From Dict    ${result_dict.ProductCost}
    ${list_giatri_huy}    Create List
    FOR    ${item_so_luong}    ${item_gia_von}    IN ZIP    ${list_so_luong}    ${list_gia_von}
        ${count_giatri_huy}    Multiplication and round 2    ${item_so_luong}    ${item_gia_von}
        Append To List    ${list_giatri_huy}    ${count_giatri_huy}
    END
    Return From Keyword    ${list_ma_hang}    ${list_so_luong}    ${list_giatri_huy}

Get full product info in damage items note
    [Arguments]    ${id_phieu_xh}
    ${list_jsonpath}    Create List    $.Data[*].["Product.Code","Product.Name","Quantity","ProductCost","Description"]
    ${result_dict}    Get dict detail damage items info    ${id_phieu_xh}    ${list_jsonpath}
    ${list_ma_hang}    Set Variable Return From Dict    ${result_dict.Code}
    ${list_ten_hang}   Set Variable Return From Dict    ${result_dict.Name}
    ${list_sl_huy}     Set Variable Return From Dict    ${result_dict.Quantity}
    ${list_gia_von}    Set Variable Return From Dict    ${result_dict.ProductCost}
    ${list_ghi_chu}    Set Variable Return From Dict    ${result_dict.Description}

    ${list_giatri_huy}    Create List
    ${length_mh}    Get Length    ${list_ma_hang}

    FOR    ${index}    IN RANGE    0    ${length_mh}
        ${gia_tri_huy}    Multiplication    ${list_gia_von[${index}]}    ${list_sl_huy[${index}]}
        Append To List    ${list_giatri_huy}    ${gia_tri_huy}
    END

    ${dict_api_ctxh}    Create Dictionary    ma_hang=${list_ma_hang}    ten_hang=${list_ten_hang}    sl_huy=${list_sl_huy}    gia_von=${list_gia_von}
    ...    gia_tri_huy=${list_giatri_huy}    ghi_chu=${list_ghi_chu}

    Log    ${dict_api_ctxh}
    Return From Keyword    ${dict_api_ctxh}

Get dict tong so luong huy va tong gia tri huy in damage item note
    [Arguments]    ${ma_phieu_xh}
    ${result_dict}    Get dict all damage items info    $.Data[?(@.Code\=\="${ma_phieu_xh}")].["TotalAmount","TotalQuantity"]
    ${dict_summary_data}    Create Dictionary    tong_sl_huy=${result_dict["TotalQuantity"]}    tong_giatri_huy=${result_dict["TotalAmount"]}
    Log   ${dict_summary_data}
    Return From Keyword    ${dict_summary_data}

Get list ma hang hoa trong phieu xuat huy
    [Arguments]    ${ma_phieu_xh}
    ${id_phieu_huy}    Get id damageitems note by code    ${ma_phieu_xh}
    ${result_dict}    Get dict detail purchase order info    ${id_phieu_huy}    $.Data[*].["Product.Code"]
    ${list_ma_hang}    Set Variable Return From Dict    ${result_dict.ProductCode}
    Return From Keyword    ${list_ma_hang}

Get tong so luong va tong gia tri huy cua phieu xuat huy
    [Arguments]    ${ma_phieu_xh}
    ${result_dict}    Get dict all damage items info    $.Data[?(@.Code\=\="${ma_phieu_xh}")].["TotalAmount","TotalQuantity"]
    ${tong_giatri_huy}    Set Variable Return From Dict    ${result_dict.TotalAmount[0]}
    ${tong_sl_huy}    Set Variable Return From Dict    ${result_dict.TotalQuantity[0]}
    Return From Keyword    ${tong_sl_huy}    ${tong_giatri_huy}

# Lấy thông tin để so sánh với file export
Get info to export all damageitems note
    [Arguments]    ${filter_time}=today    ${is_phieu_tam}=True    ${is_phieu_hoan_thanh}=True    ${is_phieu_huy}=True
    ${list_jsonpath}    Create List    $.Data[*].["Code","TransDate","Branch.Name","TotalAmount","Description","Status"]
    ${result_dict}    Get dict all damage items info    ${list_jsonpath}    filter_time=${filter_time}    is_phieu_tam=${is_phieu_tam}
    ...    is_phieu_hoan_thanh=${is_phieu_hoan_thanh}    is_phieu_huy=${is_phieu_huy}
    ${result_dict.Status}    KV Convert List Type From Number To VN String    ${result_dict.Status}    ${dict_trang_thai}
    ${result_dict.TransDate}    KV Convert DateTime To String    ${result_dict.TransDate}
    ${result_dict.Description}    KV Convert String Null To Number Zero    ${result_dict.Description}
    Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get total of product in damageitems note frm API
    [Arguments]    ${id_phieu_xh}
    ${jsonpath}    Set Variable    $.Total
    ${result_dict}    Get dict detail damage items info    ${id_phieu_xh}    ${jsonpath}
    ${tong_so_hang}    Set Variable Return From Dict    ${result_dict.Total[0]}
    Return From Keyword    ${tong_so_hang}

Assert status of damage items note
    [Arguments]    ${damageitems_code}    ${status}
    ${get_status}    Get status of damage items by code    ${damageitems_code}
    KV Compare Scalar Values    ${status}    ${get_status}    Lỗi trạng thái của phiếu xuất hủy không đúng

Assert thong tin hang hoa trong phieu xuat huy
    [Arguments]    ${ma_phieu_xh}    ${input_list_ma_hang}    ${input_list_sl_huy}
    ${id_phieu_xh}    Get id damageitems note by code    ${ma_phieu_xh}
    ${list_product_code}    ${list_quantity}    Get product info in damage items note    ${id_phieu_xh}
    KV Lists Should Be Equal    ${input_list_ma_hang}    ${list_product_code}    Lỗi danh sách mã hàng input và trong API khác nhau
    KV Lists Should Be Equal    ${input_list_sl_huy}    ${list_quantity}    Lỗi danh sách số lượng hủy input và trong API khác nhau

Assert thong tin tong gia tri huy cua phieu
    [Arguments]    ${ma_phieu_xh}    ${count_tong_giatri_huy}    ${status}
    ${list_jsonpath}    Create List    $.Data[?(@.Code\=\="${ma_phieu_xh}")].["TotalAmount","Status"]
    ${result_dict}    Get dict all damage items info     ${list_jsonpath}
    ${get_tong_giatri_huy}    Set Variable Return From Dict    ${result_dict.TotalAmount[0]}
    ${get_status}             Set Variable Return From Dict    ${result_dict.Status[0]}
    KV Should Be Equal As Numbers    ${count_tong_giatri_huy}    ${get_tong_giatri_huy}    Lỗi tổng giá trị hủy tính toán trên UI và trong API khác nhau
    KV Compare Scalar Values    ${status}    ${get_status}    Lỗi trạng thái của phiếu xuất hủy không đúng

Assert thong tin ton kho sau khi huy phieu xuat huy
    [Arguments]    ${ma_phieu_xh}    ${list_ma_hh}    ${input_list_ton_kho}
    ${list_ton_kho_af}    Get list onHand by list product code    ${list_ma_hh}
    KV Lists Should Be Equal    ${input_list_ton_kho}    ${list_ton_kho_af}    Lỗi danh sách tồn kho input và trong API khác nhau

Assert thong tin tong gia tri huy cua phieu xuat huy
    [Arguments]    ${ma_phieu_xh}    ${text_tong_gia_tri}
    ${result_dict}    Get dict all damage items info    $.Data[?(@.Code\=\="${ma_phieu_xh}")].TotalAmount    is_phieu_huy=False
    KV Should Be Equal As Numbers    ${text_tong_gia_tri}    ${result_dict.TotalAmount[0]}    msg=Hiển thị sai thông tin Tổng giá trị hủy của phiếu xuất hủy

Assert thong tin hang hoa trong phieu xuat huy giua UI va API
    [Arguments]    ${id_phieu_xh}    ${list_sl_huy}    ${list_gia_von}    ${list_gia_tri_huy}
    ${result_dict}    Get dict detail damage items info    ${id_phieu_xh}    $.Data[*].["Quantity","ProductCost"]
    ${get_list_gtri}    Create List
    FOR    ${sl_huy}    ${gia_von}    IN ZIP    ${result_dict.Quantity}    ${result_dict.ProductCost}
        ${gia_tri}    Multiplication    ${sl_huy}    ${gia_von}
        Append To List    ${get_list_gtri}    ${gia_tri}
    END
    ${result_dict.Quantity}       Evaluate    [float(item) for item in ${result_dict.Quantity}]
    ${result_dict.ProductCost}    Evaluate    [float(item) for item in ${result_dict.ProductCost}]
    KV Lists Should Be Equal    ${list_sl_huy}     ${result_dict.Quantity}       msg=Hiển thị sai danh sách SL hủy
    KV Lists Should Be Equal    ${list_gia_von}    ${result_dict.ProductCost}    msg=Hiển thị sai danh sách giá vốn
    KV Lists Should Be Equal         ${list_gia_tri_huy}    ${get_list_gtri}          msg=Hiển thị sai danh sách giá trị hủy

    #
