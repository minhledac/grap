*** Settings ***
Resource          ../../api_access.robot
Resource          api_danhmuc_hanghoa.robot
Resource          ../../../share/utils.robot
Library           String
Library           Collections

*** Keywords ***
Get dict manufacturing note info
    [Arguments]    ${manufacturing_code}    ${list_key}     ${json_path}=${EMPTY}    ${list_key_path}=$..Data[?(@.Code=="${manufacturing_code}")]
    ...    ${filter_time}=alltime    ${is_phieu_tam}=True    ${is_phieu_hoan_thanh}=True    ${is_phieu_huy}=True

    ${filter_status}    KV Get Filter Status Manufacturing Note    ${is_phieu_tam}    ${is_phieu_hoan_thanh}    ${is_phieu_huy}

    ${filter_data}    Set Variable    (BranchId+eq+${BRANCH_ID}+and+(${filter_status})+and+ManufacturingDate+eq+'${filter_time}')

    ${list_json_path}    Get List JSONPath    ${list_key}     ${json_path}    ${list_key_path}
    ${find_dict}    Create Dictionary    filter_data=${filter_data}
    ${result_dict}    API Call From Template    /san-xuat/get_phieu_sx.txt    ${find_dict}    ${list_json_path}
    KV Log    ${result_dict}

    Return From Keyword    ${result_dict}

Get dict manufacturing detail
    [Arguments]    ${manufacturing_code}    ${list_key}     ${json_path}=${EMPTY}    ${list_key_path}=$..Data[*]
    ${manufacturing_id}    Get id manufacturing note by code    ${manufacturing_code}
    ${list_json_path}    Get List JSONPath    ${list_key}     ${json_path}    ${list_key_path}
    ${find_dict}    Create Dictionary    manufacturing_id=${manufacturing_id}
    ${result_dict}    API Call From Template    /san-xuat/get_chitiet_phieusx.txt    ${find_dict}    ${list_json_path}
    KV Log    ${result_dict}
    Return From Keyword    ${result_dict}

# Filter theo status của giao dịch sản xuất
KV Get Filter Status Manufacturing Note
    [Arguments]    ${is_phieu_tam}    ${is_phieu_hoan_thanh}    ${is_phieu_huy}
    ${list_filter}    Create List
    Run Keyword If    '${is_phieu_tam}' == 'True'           Append To List    ${list_filter}    Status+eq+0
    Run Keyword If    '${is_phieu_hoan_thanh}' == 'True'    Append To List    ${list_filter}    Status+eq+1
    Run Keyword If    '${is_phieu_huy}' == 'True'           Append To List    ${list_filter}    Status+eq+2
    ${list_filter}     Evaluate    "+or+".join(${list_filter})
    Return From Keyword    ${list_filter}

# Lấy ra mã hàng và số lượng trong phiếu sản xuất
Get product code and quantity of product in manufacturing note
    [Arguments]    ${input_maphieu}
    ${dict_data}    Get dict manufacturing note info    ${input_maphieu}    ["Product.Code","Quantity"]
    ${mahang_sx}    Set Variable Return From Dict    ${dict_data.Code[0]}
    ${soluong_sx}    Set Variable Return From Dict    ${dict_data.Quantity[0]}
    Return From Keyword    ${mahang_sx}    ${soluong_sx}

# Lấy ra dict chứa mã hàng, tên hàng và số lượng trong phiếu sản xuất - thông tin tổng hợp
Get dict product code name and quantity of product in manufacturing note
    [Arguments]    ${input_maphieu}
    ${dict_data}    Get dict manufacturing note info    ${input_maphieu}    ["Product.Code","Product.Name","Quantity"]
    ${dict_summary_data}    Create Dictionary    ma_hang=${dict_data["Code"]}    ten_hang=${dict_data["Name"]}    so_luong=${dict_data["Quantity"]}
    Log   ${dict_summary_data}
    Return From Keyword    ${dict_summary_data}

# Lấy ra id của phiếu sản xuất
Get id manufacturing note by code
    [Arguments]    ${input_maphieu}
    ${dict_data}    Get dict manufacturing note info    ${input_maphieu}    ["Id"]
    ${id_phieu_sx}    Set Variable Return From Dict    ${dict_data.Id[0]}
    Return From Keyword    ${id_phieu_sx}

# Lấy ra danh sách tất cả mã phiếu sản xuất
Get list manufacturing code frm API
    ${dict_data}    Get dict manufacturing note info    ${EMPTY}    ${EMPTY}    $..Data[*].Code
    ${list_ma_phieu}    Set Variable Return From Dict    ${dict_data.Code}
    Return From Keyword    ${list_ma_phieu}

# Lấy ra thời gian và ghi chú sản xuất
Get manufacturing date and description in manufacturing note
    [Arguments]    ${input_maphieu}
    ${dict_data}    Get dict manufacturing note info    ${input_maphieu}    ["ManufacturingDate","Description"]
    ${thoigian_sx}    Set Variable Return From Dict    ${dict_data.ManufacturingDate[0]}
    ${ghichu_sx}    Set Variable Return From Dict    ${dict_data.Description[0]}
    Return From Keyword    ${thoigian_sx}    ${ghichu_sx}

# Lấy ra trạng thái sản xuất
Get status of manufacturing note
    [Arguments]    ${input_maphieu}
    ${dict_data}    Get dict manufacturing note info    ${input_maphieu}    ["Status"]
    ${trangthai_sx}    Set Variable Return From Dict    ${dict_data.Status[0]}
    Return From Keyword    ${trangthai_sx}

# lấy tất cả các phiếu sản xuất theo filter tháng này
Get all data in manufacturing note frm API
    [Arguments]    ${list_ma_phieu}

    ${dict_manufacturing}    Get dict manufacturing note info    ${EMPTY}    ["Code","Product.Code","Product.Name","ManufacturingDate","Description","Quantity","Status"]
    ...    list_key_path=$..Data[*]    filter_time=thismonth    is_phieu_huy=False

    ${dict_api_sx}    Create Dictionary    ma_san_xuat=@{EMPTY}
    ...     thoi_gian=@{EMPTY}
    ...     ma_hang=@{EMPTY}
    ...     ten_hang=@{EMPTY}
    ...     so_luong=@{EMPTY}
    ...     ghi_chu=@{EMPTY}
    ...     trang_thai=@{EMPTY}

    FOR    ${input_ma_phieu}    IN ZIP    ${list_ma_phieu}
        Run Keyword If    '${input_ma_phieu}'=='0'    Continue For Loop    #ma phieu =0 thi bo qua
        San Xuat Data API    ${input_ma_phieu}    ${dict_manufacturing}    ${dict_api_sx}
    END
    KV Log    ${dict_api_sx}
    Return From Keyword    ${dict_api_sx}

# lấy ra dict chứa tất cả thông tin phiếu sản xuất
San Xuat Data API
    [Arguments]    ${input_ma_phieu}    ${dict_manufacturing}    ${dict_api_sx}

    ${index}    Get Index From List    ${dict_manufacturing.Code}    ${input_ma_phieu}

    ${mahang_sx}    Set Variable Return From Dict    ${dict_manufacturing.Code1[${index}]}
    ${tenhang_sx}    Set Variable Return From Dict    ${dict_manufacturing.Name[${index}]}
    ${thoigian_sx}    KV Convert DateTime From API To 24h Format String    ${dict_manufacturing.ManufacturingDate[${index}]}    result_format=%Y-%m-%d %H:%M:%S.%f

    ${ghichu_sx}    Set Variable Return From Dict    ${dict_manufacturing.Description[${index}]}
    ${soluong_sx}    Set Variable Return From Dict    ${dict_manufacturing.Quantity[${index}]}

    ${dict_trang_thai}    Create Dictionary    0=Phiếu tạm    1=Hoàn thành    2=Đã hủy
    ${trangthai_sx}    Set Variable Return From Dict    ${dict_trang_thai["${dict_manufacturing["Status"][${index}]}"]}

    Append To List    ${dict_api_sx.ma_san_xuat}    ${input_ma_phieu}
    Append To List    ${dict_api_sx.ma_hang}    ${mahang_sx}
    Append To List    ${dict_api_sx.ten_hang}    ${tenhang_sx}
    Append To List    ${dict_api_sx.thoi_gian}    ${thoigian_sx}
    Append To List    ${dict_api_sx.ghi_chu}    ${ghichu_sx}
    Append To List    ${dict_api_sx.so_luong}    ${soluong_sx}
    Append To List    ${dict_api_sx.trang_thai}    ${trangthai_sx}

Get so luong hang thanh phan trong phieu san xuat
    [Arguments]    ${input_maphieu}
    ${dict_data}    Get dict manufacturing detail    ${input_maphieu}    ${EMPTY}    $..Total
    ${so_luong_tp}    Set Variable Return From Dict    ${dict_data.Total[0]}
    Return From Keyword    ${so_luong_tp}

# Lấy ra dict chứa mã, tên, số lượng, tồn kho hiện tại thành phần của phiếu sản xuất
Get manufacturing info frm API
    [Arguments]    ${input_maphieu}
    ${dict_detail}    Get dict manufacturing detail    ${input_maphieu}    ["Code","Name","Quantity"]
    ${list_product_code}    Set Variable Return From Dict    ${dict_detail.Code}
    ${list_product_name}    Set Variable Return From Dict    ${dict_detail.Name}
    ${list_product_quantity}    Set Variable Return From Dict    ${dict_detail.Quantity}
    ${list_onhand_now}    Create List
    FOR    ${product_code}    IN ZIP    ${list_product_code}
        ${product_id}    Get product unit id frm API    ${product_code}
        ${dict_onhand}    Get dict the kho info by document code    ${product_id}    ${input_maphieu}    ["EndingStocks"]
        Append To List    ${list_onhand_now}    ${dict_onhand.EndingStocks[0]}
    END
    ${dict_api_ctsx}    Create Dictionary    ma_thanh_phan=${list_product_code}
    ...     ten_thanh_phan=${list_product_name}
    ...     ton_kho_hien_tai=${list_onhand_now}
    ...     su_dung=${list_product_quantity}

    KV Log    ${dict_api_ctsx}
    Return From Keyword    ${dict_api_ctsx}

# Kiểm tra phiếu sản xuất đã bị hủy
Assert manufacturing note should be removed
    [Arguments]    ${input_maphieu}
    ${list_ma_phieu}    Get list manufacturing code frm API
    KV List Should Not Contain Value    ${list_ma_phieu}    ${input_maphieu}    Lỗi danh sách vẫn chứa mã phiếu sản xuất đã hủy

# Kiểm tra so sánh mã hàng, số lượng sản xuất
Assert require data in case create manufacturing order
    [Arguments]    ${input_maphieu}    ${input_mahang_sx}    ${input_soluong_sx}
    ${mahang_sx}    ${soluong_sx}    Get product code and quantity of product in manufacturing note    ${input_maphieu}
    KV Compare Scalar Values    ${mahang_sx}    ${input_mahang_sx}    Lỗi mã hàng sản xuất input và trong API khác nhau
    KV Compare Scalar Values    ${soluong_sx}    ${input_soluong_sx}    Lỗi số lượng sản xuất input và trong API khác nhau

# Kiểm tra so sánh thời gian, ghi chú sản xuất
Assert minor data in case create manufacturing order
    [Arguments]    ${input_maphieu}    ${input_thoigian_sx}    ${input_ghichu_sx}
    ${thoigian_sx}    ${ghichu_sx}    Get manufacturing date and description in manufacturing note    ${input_maphieu}
    KV Compare DateTime    ${input_thoigian_sx}    ${thoigian_sx}
    KV Should Be Equal As Strings    ${ghichu_sx}    ${input_ghichu_sx}    Lỗi ghi chú sản xuất input và trong API khác nhau

# Kiểm tra so sánh trạng thái sản xuất
Assert status in case create manufacturing order
    [Arguments]    ${input_maphieu}    ${input_trangthai}
    ${trangthai_sx}    Get status of manufacturing note    ${input_maphieu}
    KV Should Be Equal As Strings    ${trangthai_sx}    ${input_trangthai}    Lỗi trạng thái sản xuất input và trong API khác nhau

# Kiểm tra so sánh tất cả thông tin trong phiếu sản xuất
Assert full data in case create manufacturing order
    [Arguments]    ${input_maphieu}    ${input_mahang_sx}    ${input_thoigian_sx}    ${input_soluong_sx}    ${input_ghichu_sx}    ${input_trangthai}
    Assert require data in case create manufacturing order    ${input_maphieu}    ${input_mahang_sx}    ${input_soluong_sx}
    Assert minor data in case create manufacturing order    ${input_maphieu}    ${input_thoigian_sx}    ${input_ghichu_sx}
    Assert status in case create manufacturing order    ${input_maphieu}    ${input_trangthai}
