*** Settings ***
Resource          ../../api_access.robot
Resource          ../../../share/utils.robot
Resource          ../giao-dich/api_hoadon.robot
Resource          ../giao-dich/api_order.robot
Library           String
Library           Collections
Library           DateTime

*** Keywords ***
# ============== START LẤY THÔNG TIN CÁC BIỂU ĐỒ ====================

Get dict all thong tin bieu do doanh so
    [Arguments]    ${list_json_path}    ${thoi_gian}=today
    ${input_dict}    Create Dictionary    filter_thoi_gian=${thoi_gian}
    ${result_dict}    API Call From Template    /tong-quan/chart_sale_doanh_so.txt    ${input_dict}    ${list_json_path}    session_alias=session_reportapi
    Return From Keyword    ${result_dict}

Get dict all thong tin bieu do doanh so theo chi nhanh
    [Arguments]    ${list_json_path}    ${thoi_gian}=today
    ${input_dict}    Create Dictionary    filter_thoi_gian=${thoi_gian}
    ${result_dict}    API Call From Template    /tong-quan/chart_sale_branch.txt    ${input_dict}    ${list_json_path}    session_alias=session_reportapi
    Return From Keyword    ${result_dict}

Get dict all thong tin bieu do so luong khach
    [Arguments]    ${list_json_path}    ${thoi_gian}=today
    ${input_dict}    Create Dictionary    filter_thoi_gian=${thoi_gian}
    ${result_dict}    API Call From Template    /tong-quan/chart_sale_SL_khach.txt    ${input_dict}    ${list_json_path}    session_alias=session_reportapi
    Return From Keyword    ${result_dict}

Get dict all thong tin bieu do hang hoa ban chay
    [Arguments]    ${list_json_path}    ${thoi_gian}=7day
    ${input_dict}    Create Dictionary    filter_thoi_gian=${thoi_gian}
    ${result_dict}    API Call From Template    /tong-quan/chart_top_product_by_quantity.txt    ${input_dict}    ${list_json_path}    session_alias=session_reportapi
    Return From Keyword    ${result_dict}

# Lấy thông tin bao gồm các hóa đơn ở trạng thái: Hoàn thành, Chưa giao, Đang giao + mặc định theo hôm nay
Get dict all thong tin hoa don tren tong quan theo chi nhanh
    [Documentation]    today,yester,thisweek,thismonth
    [Arguments]    ${list_jsonpath}    ${branch_id}=${BRANCH_ID}    ${thoi_gian}=today
    ${start_filter_date}    ${end_filter_date}    KV Get Start End Date By Filter    ${thoi_gian}
    ${data_filter}    Set Variable    (BranchId+eq+${branch_id}+and+(Status+eq+1+or+Status+eq+3+or+Status+eq+4)+and+(PurchaseDate+ge+datetime'${start_filter_date}'+and+PurchaseDate+lt+datetime'${end_filter_date}'))
    ${input_dict}    Create Dictionary    data_filter=${data_filter}
    ${result_dict}    API Call From Template    /tong-quan/get_invoice_dashboard.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get Today DateTime Filter
    ${start_filter_date}   Get Current Date    result_format=%Y-%m-%dT00:00:00
    ${end_filter_date}     Add Time To Date    ${start_filter_date}    1 day    result_format=%Y-%m-%dT00:00:00
    Return From Keyword    ${start_filter_date}    ${end_filter_date}

Get doanh thu - SL khach - tong hoa don ban hang hom nay
    [Arguments]    ${input_branch_id}
    ${result_dict}    Get dict all thong tin hoa don tren tong quan theo chi nhanh    $.["Total1Value","TotalCustomer","Total"]    branch_id=${input_branch_id}
    ${doanh_thu}      Set Variable Return From Dict    ${result_dict.Total1Value[0]}
    ${sl_khach}       Set Variable Return From Dict    ${result_dict.TotalCustomer[0]}
    ${tong_hoa_don}   Set Variable Return From Dict    ${result_dict.Total[0]}
    Return From Keyword    ${doanh_thu}    ${sl_khach}    ${tong_hoa_don}

Assert thong tin doanh thu va so luong khach trong ket qua ban hang hom nay
    [Arguments]    ${input_branch_id}    ${count_doanh_thu}    ${count_sl_khach}    ${count_tong_hd}
    ${get_doanh_thu}     ${get_sl_khach}    ${get_tong_hd}    Get doanh thu - SL khach - tong hoa don ban hang hom nay    ${input_branch_id}
    KV Should Be Equal As Numbers    ${get_doanh_thu}   ${count_doanh_thu}   msg=Sai giá trị doanh thu trên màn hình tổng quan - khu vực Kết quả bán hàng hôm nay
    KV Should Be Equal As Numbers    ${get_sl_khach}    ${count_sl_khach}    msg=Sai giá trị SL khách trên màn hình tổng quan - khu vực Kết quả bán hàng hôm nay
    KV Should Be Equal As Numbers    ${get_tong_hd}     ${count_tong_hd}     msg=Sai giá trị số đơn đã xong trên màn hình tổng quan - khu vực Kết quả bán hàng hôm nay

Assert thong tin bieu do danh so theo chi nhanh
    [Arguments]    ${input_branch_name}    ${count_doanh_thu}
    ${result_dict}    Get dict all thong tin bieu do doanh so theo chi nhanh    $..["Subject","Value"]
    ${index}    Get Index From List    ${result_dict.Subject}    ${input_branch_name}
    ${get_doanh_thu}    Set Variable    ${result_dict.Value[${index}]}
    KV Should Be Equal As Numbers    ${get_doanh_thu}    ${count_doanh_thu}    msg=Sai giá trị doanh thu của CN ${input_branch_name} - khu vực Doanh số theo chi nhánh

Assert thong tin bieu do SL khach
    [Arguments]    ${branch_name}    ${total_branch}    ${purchaseDate_invoice}    ${count_timeline_sl_khach}
    ${get_timeline_sl_khach}    Get SL khach theo chi nhanh tai 1 moc thoi gian    ${branch_name}    ${total_branch}    ${purchaseDate_invoice}
    KV Should Be Equal As Numbers    ${get_timeline_sl_khach}    ${count_timeline_sl_khach}    msg=Sai giá trị SL khách của CN ${branch_name} tại mốc thời gian tạo hóa đơn

Assert thong tin bieu do doanh so
    [Arguments]    ${branch_name}    ${total_branch}    ${purchaseDate_invoice}    ${count_timeline_doanh_thu}
    ${get_timeline_doanh_thu}    Get doanh thu theo chi nhanh tai 1 moc thoi gian     ${branch_name}    ${total_branch}    ${purchaseDate_invoice}
    KV Should Be Equal As Numbers    ${get_timeline_doanh_thu}    ${count_timeline_doanh_thu}    msg=Sai giá trị doanh thu của CN ${branch_name} tại mốc thời gian tạo hóa đơn

Get SL khach theo chi nhanh tai 1 moc thoi gian
    [Arguments]    ${branch_name}    ${total_branch}    ${input_thoi_gian}
    ${result_dict}    Get dict all thong tin bieu do so luong khach    $..["Group","Subject","Value"]
    ${length_timeline}    Template get length timeline by branch    ${branch_name}    ${result_dict}
    ${get_timeline_sl_khach}    Run Keyword If    ${length_timeline}>0    Template get value in chart by timeline from API    ${branch_name}    ${total_branch}    ${input_thoi_gian}    ${result_dict}
    ...    ELSE    Set Variable    0
    Return From Keyword    ${get_timeline_sl_khach}

Get doanh thu theo chi nhanh tai 1 moc thoi gian
    [Arguments]    ${branch_name}    ${total_branch}    ${input_thoi_gian}
    ${result_dict}    Get dict all thong tin bieu do doanh so    $..["Group","Subject","Value"]
    ${length_timeline}    Template get length timeline by branch    ${branch_name}    ${result_dict}
    ${get_timeline_doanh_thu}    Run Keyword If    ${length_timeline}>0    Template get value in chart by timeline from API    ${branch_name}    ${total_branch}    ${input_thoi_gian}    ${result_dict}
    ...    ELSE    Set Variable    0
    Return From Keyword    ${get_timeline_doanh_thu}

Template get length timeline by branch
    [Arguments]    ${branch_name}    ${result_dict}
    ${list_timeline_by_branch}    Create List
    FOR    ${timeline}    ${branch}    IN ZIP    ${result_dict.Subject}    ${result_dict.Group}
        ${timeline_by_branch}     Set Variable If    '${branch}'=='${branch_name}'    ${timeline}
        Run Keyword If    '${branch}'=='${branch_name}'    Append To List    ${list_timeline_by_branch}    ${timeline_by_branch}
    END
    ${length_timeline}    Get Length    ${list_timeline_by_branch}
    Return From Keyword    ${length_timeline}

Template get value in chart by timeline from API
    [Arguments]    ${input_branch_name}    ${total_branch}    ${input_thoi_gian}    ${result_dict}
    ${list_ten_CN}     Set Variable Return From Dict    ${result_dict.Group}
    ${list_timeline}   Set Variable Return From Dict    ${result_dict.Subject}
    ${list_value}      Set Variable Return From Dict    ${result_dict.Value}
    # Lấy mốc thời gian
    ${get_gio}    ${moc_thoi_gian}    ${is_timeline_visible}    Get moc thoi gian    ${input_thoi_gian}
    # Kiểm tra xem mốc thời gian cần lấy dữ liệu có phải là mốc thời gian đầu tiên phát sinh giao dịch trong ngày hay không
    ${is_first_timeline}    Run Keyword And Return Status    Should Be True    '${moc_thoi_gian}'=='${list_timeline[0]}'
    # fake_moc_tg là mốc thời gian đang cần lấy giá trị - 1 giờ
    ${fake_gio}    Run Keyword If    '${is_timeline_visible}'=='True'    Set Variable    ${get_gio}    ELSE    Evaluate    ${get_gio}-1
    ${fake_moc_tg}    Set Variable If    ${fake_gio} < 10    0${fake_gio}:00    ${fake_gio}:00

    ${result_value}     Run Keyword If    '${is_timeline_visible}'=='True' or ('${is_timeline_visible}'=='False' and '${is_first_timeline}'=='True')    Get gia tri theo moc thoi gian visible    ${input_branch_name}
    ...    ${moc_thoi_gian}    ${list_ten_CN}    ${list_timeline}    ${list_value}
    ...    ELSE IF    '${is_timeline_visible}'=='False' and '${is_first_timeline}'=='False'    Get gia tri theo moc thoi gian Invisible    ${input_branch_name}    ${total_branch}
    ...    ${fake_moc_tg}    ${list_ten_CN}    ${list_timeline}    ${list_value}
    Return From Keyword    ${result_value}

# Lấy giá trị giờ, mốc thời gian theo format như mốc thời gian trên biểu đồ ở màn hình tổng quan: ví dụ: 06:00
Get moc thoi gian
    [Arguments]    ${thoi_gian}
    ${get_hour}    Set Variable    ${thoi_gian.hour}
    ${type}    Evaluate    type($get_hour).__name__
    ${so_du}    Evaluate    ${get_hour}%2
    ${is_timeline_visible}    Set Variable If    ${so_du}==0    True    False
    ${timeline}    Set Variable If    ${get_hour} < 10    0${get_hour}:00    ${get_hour}:00
    Return From Keyword    ${get_hour}    ${timeline}    ${is_timeline_visible}

# Lấy giá trị theo mốc thời gian hiển thị trên UI (là những mốc thời gian chẵn: 00:00, 02:00, 04:00,.... và mốc thời gian đầu tiên có giá trị (có thể là chẵn hoặc lẻ))
Get gia tri theo moc thoi gian visible
    [Documentation]    list_key_api: là list giá trị với mỗi phần tử là trường trong api mà muốn lấy thông tin. VD: Subject, Total
    [Arguments]   ${branch_name}    ${moc_thoi_gian}    ${list_ten_CN}    ${list_timeline}    ${list_api_key}
    ${result_value}    Set Variable    0
    FOR    ${timeline}    ${ten_CN}    ${value}    IN ZIP    ${list_timeline}    ${list_ten_CN}    ${list_api_key}
        ${result_value}    Set Variable If    '${ten_CN}'=='${branch_name}' and '${timeline}'=='${moc_thoi_gian}'    ${value}
        Exit For Loop If    '${ten_CN}'=='${branch_name}' and '${timeline}'=='${moc_thoi_gian}'
    END
    Return From Keyword    ${result_value}

# Lấy giá trị theo mốc thời gian KHÔNG hiển thị trên UI (là những mốc thời gian lẻ: 01:00, 03:00, 05:00,....)
Get gia tri theo moc thoi gian Invisible
    [Documentation]    key_api: là trường trong api mà muốn lấy thông tin. VD: Subject, Total
    [Arguments]   ${branch_name}    ${total_branch}    ${fake_moc_tg}    ${list_ten_CN}    ${list_timeline}    ${list_api_key}
    ${count_CN}      Set Variable    0
    ${result_value}  Set Variable    0
    ${index}         Set Variable    0
    # Lấy tổng số lượng CN đang hiển thị trên biểu đồ
    FOR    ${item_index}    IN RANGE    0    ${total_branch}
        ${count_CN}    Run Keyword If    '${list_timeline[0]}'=='${list_timeline[${item_index}]}'    Evaluate    ${count_CN}+1    ELSE    Set Variable    ${count_CN}
    END
    # Giải thích: ${index} là vị trí của bàn ghi đầu tiên thỏa mãn ĐK có mốc thời gian = fake_moc_tg
    FOR    ${timeline}    IN ZIP    ${list_timeline}
        ${index}    Run Keyword If    '${fake_moc_tg}'=='${timeline}'    Set Variable    ${index}    ELSE    Evaluate    ${index}+1
        Exit For Loop If    '${fake_moc_tg}'=='${timeline}'
    END
    # Vị trí đầu tiên của mốc thời gian cần lấy dữ liệu
    ${start_find}    Evaluate    ${index}+${count_CN}
    ${length_moc_tg}    Get Length    ${list_timeline}
    FOR    ${find_index}    IN RANGE    ${start_find}    ${length_moc_tg}+1
        ${result_value}    Run Keyword If    '${list_ten_CN[${find_index}]}'=='${branch_name}'    Set Variable    ${list_api_key[${find_index}]}
        Exit For Loop If    '${list_ten_CN[${find_index}]}'=='${branch_name}'
    END
    Return From Keyword    ${result_value}

Get list code and quantity of top 10 product
    ${result_dict}     Get dict all thong tin bieu do hang hoa ban chay    $..["Extra1","Value"]
    ${list_code}       Set Variable Return From Dict    ${result_dict.Extra1}
    ${list_quantity}   Set Variable Return From Dict    ${result_dict.Value}
    Return From Keyword    ${list_code}    ${list_quantity}

Assert thong tin top 10 hang hoa ban chay
    [Arguments]    ${list_code_top_ex}
    ${get_list_code}    ${get_list_SL}    Get list code and quantity of top 10 product
    KV Lists Should Be Equal    ${get_list_code}    ${list_code_top_ex}    msg=Sai thứ tự top 10 hàng bán chạy

Assert thong tin ve tien tren UI va API man hinh Tong quan
    [Arguments]    ${tong_don_hn}    ${value_don_hn}    ${value_don_hom_qua}    ${phan_tram_don}
    ...    ${tong_don_pv}    ${value_don_pv}    ${tong_kh_hn}    ${tong_kh_hom_qua}    ${phan_tram_kh}
    ...    ${tong_ds_hn}    ${tong_ds_cn}    ${tong_SL_kh}
    ${result_dict_1}       Get dict all thong tin hoa don tren tong quan theo chi nhanh    $.["Total","Total1Value","TotalCustomer"]    thoi_gian=today
    ${result_dict_2}       Get dict all thong tin hoa don tren tong quan theo chi nhanh    $.["Total","Total1Value","TotalCustomer"]    thoi_gian=yesterday
    ${get_tong_don_hn}     Set Variable    ${result_dict_1.Total[0]}
    ${get_value_don_hn}    Set Variable    ${result_dict_1.Total1Value[0]}
    ${get_kh_hn_invoice}   Set Variable    ${result_dict_1.TotalCustomer[0]}    # Tổng SL khách hàng của các đơn đã hoàn thành ngày hôm nay

    ${get_value_don_hom_qua}   Set Variable    ${result_dict_2.Total1Value[0]}
    ${get_kh_hq_invoice}       Set Variable    ${result_dict_2.TotalCustomer[0]}    # Tổng SL khách hàng của các đơn đã hoàn thành ngày hôm qua
    # Lấy thông tin Kết quả bán hàng hôm nay - đơn hàng
    ${result_dict_3}      Get dict all order frm API    $.["Total","Total1Value","TotalCustomer"]    thoi_gian=today     is_hoan_thanh=False    is_dang_giao=False
    ${get_tong_don_pv}    Set Variable    ${result_dict_3.Total[0]}
    ${get_value_don_pv}   Set Variable    ${result_dict_3.Total1Value[0]}
    ${get_kh_hn_order}    Set Variable    ${result_dict_3.TotalCustomer[0]}     # Tổng SL khách hàng của các đơn đang phục vụ ngày hôm nay
    # Lấy thông tin SL khách hàng ngày hôm qua (tính cả đơn đã hoàn thành và đơn tạm)
    ${result_dict_5}      Get dict all order frm API    $.["TotalCustomer"]    thoi_gian=yesterday     is_hoan_thanh=False     is_dang_giao=False
    ${get_kh_hq_order}    Set Variable    ${result_dict_5.TotalCustomer[0]}     # Tổng SL khách hàng của các đơn đang phục vụ ngày hôm qua
    # Lấy thông tin biểu đồ doanh số Hôm nay
    ${result_dict_4}      Get dict all thong tin bieu do doanh so    $..Value
    ${list_item_value}    Set Variable    ${result_dict_4.Value}
    ${get_doanh_so_hn}    Sum values in list    ${list_item_value}
    # TÍnh tổng KH = tổng KH của order ở trạng thái hoàn thành + order ở trạng thái phiếu tạm
    ${get_tong_kh_hn}        SUM    ${get_kh_hn_invoice}    ${get_kh_hn_order}
    ${get_tong_kh_hom_qua}   SUM    ${get_kh_hq_invoice}    ${get_kh_hq_order}

    KV Should Be Equal As Numbers    ${tong_don_hn}         ${get_tong_don_hn}        msg=Hiển thị sai thông tin tổng hóa đơn khu vực Kết quả bán hàng hôm nay
    KV Should Be Equal As Numbers    ${value_don_hn}        ${get_value_don_hn}       msg=Hiển thị sai thông tin tổng doanh thu hôm nay khu vực Kết quả bán hàng hôm nay
    KV Should Be Equal As Numbers    ${value_don_hom_qua}   ${get_value_don_hom_qua}  msg=Hiển thị sai thông tin tổng doanh thu hôm qua khu vực Kết quả bán hàng hôm nay
    KV Should Be Equal As Numbers    ${tong_don_pv}         ${get_tong_don_pv}        msg=Hiển thị sai thông tin tổng đơn đang phục vụ khu vực Kết quả bán hàng hôm nay
    KV Should Be Equal As Numbers    ${value_don_pv}        ${get_value_don_pv}       msg=Hiển thị sai thông tin tổng giá trị đơn đang phục vụ khu vực Kết quả bán hàng hôm nay
    KV Should Be Equal As Numbers    ${tong_kh_hn}          ${get_tong_kh_hn}         msg=Hiển thị sai thông tin tổng khách hàng hôm nay khu vực Kết quả bán hàng hôm nay
    KV Should Be Equal As Numbers    ${tong_kh_hom_qua}     ${get_tong_kh_hom_qua}    msg=Hiển thị sai thông tin tổng khách hàng hôm qua khu vực Kết quả bán hàng hôm nay
    KV Should Be Equal As Numbers    ${tong_ds_hn}          ${get_doanh_so_hn}        msg=Hiển thị sai thông tin giá trị tổng của biểu đồ Doanh số hôm nay
    KV Should Be Equal As Numbers    ${tong_ds_cn}          ${get_doanh_so_hn}        msg=Hiển thị sai thông tin giá trị tổng của biểu đồ Doanh số theo chi nhánh
    KV Should Be Equal As Numbers    ${tong_SL_kh}          ${get_tong_kh_hn}         msg=Hiển thị sai thông tin giá trị tổng của biểu đồ Số lượng khách hôm nay

#======================== END assert API các Biểu đồ ===========================
# Lấy all bản ghi các hoạt động gần đây
Get dict all activities recently
    [Arguments]    ${list_json_path}
    ${result_dict}    API Call From Template    /tong-quan/all_activities.txt     ${EMPTY}    ${list_json_path}
    Return From Keyword    ${result_dict}

Assert thong tin hoat dong giao dich tren UI va API
    [Arguments]    ${ma_hoa_don}    ${text_ten_user}    ${text_ten_act}    ${text_gia_tri}
    ${list_json_path}    Create List    $..["SubjectCode","UserName","SubjectLabel","Value"]
    ${result_dict}    Get dict all activities recently    ${list_json_path}
    ${index}    Get Index From List    ${result_dict.SubjectCode}    ${ma_hoa_don}
    ${get_ten_user}   Set Variable    ${result_dict.UserName[${index}]}
    ${get_ten_act}    Set Variable    ${result_dict.SubjectLabel[${index}]}
    ${get_gia_tri}    Set Variable    ${result_dict.Value[${index}]}
    ${get_gia_tri}    Evaluate    "{:,}".format(${get_gia_tri})
    KV Should Be Equal As Strings    ${text_ten_user}   ${get_ten_user}   msg=Sai tên người thực hiện giao dịch
    KV Should Be Equal As Strings    ${text_ten_act}    ${get_ten_act}    msg=Sai tên hoạt động
    KV Should Be Equal As Strings    ${text_gia_tri}    ${get_gia_tri}    msg=Sai giá trị giao dịch
#
