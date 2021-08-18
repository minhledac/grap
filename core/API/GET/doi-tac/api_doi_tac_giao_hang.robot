*** Settings ***
Resource          ../../api_access.robot
Resource          ../../../share/utils.robot
Library           Collections

*** Variable ***
&{dict_loai_phieu}    0=Thanh toán    1=Điều chỉnh    3=Bán hàng

*** Keywords ***
Get dict all delivery partner frm API
    [Arguments]    ${list_jsonpath}    ${so_ban_ghi}=${EMPTY}
    ${input_dict}    Create Dictionary    so_ban_ghi=${so_ban_ghi}
    ${result_dict}    API Call From Template    /doi-tac-giao-hang/all_doi_tac_giao_hang.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get dict all group delivery partner frm API
    [Arguments]    ${list_jsonpath}
    ${result_dict}    API Call From Template    /doi-tac-giao-hang/all_nhom_doitac_giaohang.txt    ${EMPTY}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get dict delivery history frm API
    [Arguments]    ${delivery_partner_id}    ${invoice_code}    ${list_key}     ${json_path}=${EMPTY}    ${list_key_path}=$..Data[?(@.Code=="${invoice_code}")]
    ${list_json_path}    Get List JSONPath    ${list_key}     ${json_path}    ${list_key_path}
    ${find_dict}    Create Dictionary    delivery_partner_id=${delivery_partner_id}
    ${result_dict}    API Call From Template    /doi-tac-giao-hang/lich_su_giao_hang.txt    ${find_dict}    ${list_json_path}
    Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get dict detail update debt delivery partner frm API
    [Arguments]    ${document_id}     ${json_path}
    ${find_dict}    Create Dictionary    document_id=${document_id}
    ${result_dict}    API Call From Template    /doi-tac-giao-hang/detail_dieu_chinh_no.txt    ${find_dict}    ${json_path}
    Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get dict debt delivery partner info frm API
    [Arguments]    ${delivery_partner_id}    ${invoice_code}    ${list_key}     ${json_path}=${EMPTY}    ${list_key_path}=$..Data[?(@.Code=="${invoice_code}")]
    ${list_json_path}    Get List JSONPath    ${list_key}     ${json_path}    ${list_key_path}
    ${find_dict}    Create Dictionary    delivery_partner_id=${delivery_partner_id}
    ${result_dict}    API Call From Template    /doi-tac-giao-hang/no_can_tra_dt_gh.txt    ${find_dict}    ${list_json_path}
    Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get dict detail purchase payment debt delivery partner frm API
    [Arguments]    ${document_id}     ${json_path}
    ${find_dict}    Create Dictionary    document_id=${document_id}
    ${result_dict}    API Call From Template    /doi-tac-giao-hang/detail_thanh_toan_no.txt    ${find_dict}    ${json_path}
    Log    ${result_dict}
    Return From Keyword    ${result_dict}

Get delivery id by code
    [Arguments]    ${delivery_code}
    ${result_dict}    Get dict all delivery partner frm API    $.Data[?(@.Code\=\="${delivery_code}")].Id
    ${delivery_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${delivery_id}

Get list delivery id by list code
    [Arguments]    ${list_delivery_code}
    ${list_delivery_id}    Create List
    FOR    ${delivery_code}    IN ZIP     ${list_delivery_code}
        ${result_dict}    Get dict all delivery partner frm API    $.Data[?(@.Code\=\="${delivery_code}")].Id
        ${delivery_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
        Append To List    ${list_delivery_id}    ${delivery_id}
    END
    Return From Keyword    ${list_delivery_id}

Get delivery name by code
    [Arguments]    ${delivery_code}
    ${result_dict}    Get dict all delivery partner frm API    $.Data[?(@.Code\=\="${delivery_code}")].Name
    ${delivery_name}    Set Variable Return From Dict    ${result_dict.Name[0]}
    Return From Keyword    ${delivery_name}

Get list delivery id by list name
    [Arguments]    ${list_gr_name}
    ${type_input}    Evaluate    type($list_gr_name).__name__
    ${list_gr_name}    Run Keyword If    '${type_input}'=='list'    Set Variable    ${list_gr_name}    ELSE    Create List    ${list_gr_name}
    ${list_delivery_id}    Create List
    ${result_dict}    Get dict all group delivery partner frm API    $.Data[*].["Id","Name"]
    FOR    ${gr_name}     IN    @{list_gr_name}
        ${index}    Get Index From List    ${result_dict.Name}    ${gr_name}
        ${delivery_id}    Set Variable    ${result_dict.Id[${index}]}
        Append To List    ${list_delivery_id}    ${delivery_id}
    END
    Return From Keyword    ${list_delivery_id}

Get all delivery partner code
    ${dict_partner}    Get dict all delivery partner frm API    $.Data[*].Code
    ${list_partner_code}    Set Variable Return From Dict    ${dict_partner.Code}
    Return From Keyword    ${list_partner_code}

Get delivery partner name and phone by code
    [Arguments]    ${ma_doi_tac}
    ${result_dict}    Get dict all delivery partner frm API    $.Data[?(@.Code\=\="${ma_doi_tac}")].["Name","ContactNumber"]
    ${ten_doi_tac}    Set Variable Return From Dict    ${result_dict.Name[0]}
    ${sdt_doi_tac}    Set Variable Return From Dict    ${result_dict.ContactNumber[0]}
    Return From Keyword    ${ten_doi_tac}    ${sdt_doi_tac}

Get status name of invoice code in delivery history
    [Arguments]    ${delivery_partner_id}    ${invoice_code}
    ${dict_history}    Get dict delivery history frm API    ${delivery_partner_id}    ${invoice_code}    ["Status","StatusName"]
    ${status_name}    Set Variable Return From Dict    ${dict_history.StatusName[0]}
    Return From Keyword    ${status_name}

Get all invoice code in debt delivery partner
    [Arguments]    ${delivery_partner_id}
    ${dict_debt}    Get dict debt delivery partner info frm API    ${delivery_partner_id}    ${EMPTY}    ${EMPTY}    $..Data[*].Code
    ${list_invoice_code}    Set Variable Return From Dict    ${dict_debt.Code}
    Return From Keyword    ${list_invoice_code}

# lấy dữ liệu đối tác giao hàng ra đưa vào dict
Get all partner data frm API
    [Arguments]    ${list_ma_doitac}

    ${dict_delivery_partner}    Get dict all delivery partner frm API
    ...    $.Data[?(@.Id!=-1)].["Code","Name","Email","ContactNumber","Address","LocationName","WardName","TotalInvoices","TotalWeight","TotalDebt","TotalCost","Groups","Comments","isActive"]

    ${dict_api_dtgh}    Create Dictionary    ma_doitac=@{EMPTY}    ten_doitac=@{EMPTY}    email_doitac=@{EMPTY}    sdt_doitac=@{EMPTY}    dia_chi=@{EMPTY}
    ...    khu_vuc=@{EMPTY}    phuong_xa=@{EMPTY}    tong_don_hang=@{EMPTY}    tong_trong_luong=@{EMPTY}    no_can_tra_ht=@{EMPTY}    tong_phi_gh=@{EMPTY}
    ...    nhom_doitac=@{EMPTY}    ghi_chu=@{EMPTY}    trang_thai=@{EMPTY}

    FOR    ${input_ma_doitac}    IN ZIP    ${list_ma_doitac}
        Run Keyword If    '${input_ma_doitac}'=='0'    Continue For Loop    #ma doi tac =0 thi bo qua
        Doi Tac Giao Hang Data API    ${input_ma_doitac}    ${dict_delivery_partner}    ${dict_api_dtgh}
    END
    KV Log    ${dict_api_dtgh}
    Return From Keyword    ${dict_api_dtgh}

# lấy ra dict chứa tất cả thông tin đối tác giao hàng
Doi Tac Giao Hang Data API
    [Arguments]    ${input_ma_doitac}    ${dict_delivery_partner}    ${dict_api_dtgh}

    ${index}    Get Index From List    ${dict_delivery_partner.Code}    ${input_ma_doitac}

    ${ten_dtgh}    Set Variable Return From Dict    ${dict_delivery_partner.Name[${index}]}
    ${sdt_dtgh}    Set Variable Return From Dict    ${dict_delivery_partner.ContactNumber[${index}]}
    ${email_dtgh}    Set Variable Return From Dict    ${dict_delivery_partner.Email[${index}]}
    ${diachi_dtgh}    Set Variable Return From Dict    ${dict_delivery_partner.Address[${index}]}
    ${khuvuc_dtgh}    Set Variable Return From Dict    ${dict_delivery_partner.LocationName[${index}]}
    ${phuongxa_dtgh}    Set Variable Return From Dict    ${dict_delivery_partner.WardName[${index}]}
    ${tong_don_hang_dtgh}       Set Variable Return From Dict    ${dict_delivery_partner.TotalInvoices[${index}]}
    ${tong_trong_luong_dtgh}    Set Variable Return From Dict    ${dict_delivery_partner.TotalWeight[${index}]}
    ${no_can_tra_ht_dtgh}       Set Variable Return From Dict    ${dict_delivery_partner.TotalDebt[${index}]}
    ${tong_phi_gh_dtgh}         Set Variable Return From Dict    ${dict_delivery_partner.TotalCost[${index}]}
    ${nhom_dtgh}    Set Variable Return From Dict    ${dict_delivery_partner.Groups[${index}]}
    ${ghichu_dtgh}    Set Variable Return From Dict    ${dict_delivery_partner.Comments[${index}]}

    ${dict_trang_thai}    Create Dictionary    True=1    False=0
    ${trangthai_dtgh}    Set Variable Return From Dict    ${dict_trang_thai["${dict_delivery_partner["isActive"][${index}]}"]}

    Append To List    ${dict_api_dtgh.ma_doitac}    ${input_ma_doitac}
    Append To List    ${dict_api_dtgh.ten_doitac}    ${ten_dtgh}
    Append To List    ${dict_api_dtgh.email_doitac}    ${email_dtgh}
    Append To List    ${dict_api_dtgh.sdt_doitac}    ${sdt_dtgh}
    Append To List    ${dict_api_dtgh.dia_chi}    ${diachi_dtgh}
    Append To List    ${dict_api_dtgh.khu_vuc}    ${khuvuc_dtgh}
    Append To List    ${dict_api_dtgh.phuong_xa}    ${phuongxa_dtgh}
    Append To List    ${dict_api_dtgh.tong_don_hang}    ${tong_don_hang_dtgh}
    Append To List    ${dict_api_dtgh.tong_trong_luong}    ${tong_trong_luong_dtgh}
    Append To List    ${dict_api_dtgh.no_can_tra_ht}    ${no_can_tra_ht_dtgh}
    Append To List    ${dict_api_dtgh.tong_phi_gh}    ${tong_phi_gh_dtgh}
    Append To List    ${dict_api_dtgh.nhom_doitac}    ${nhom_dtgh}
    Append To List    ${dict_api_dtgh.ghi_chu}    ${ghichu_dtgh}
    Append To List    ${dict_api_dtgh.trang_thai}    ${trangthai_dtgh}

Get invoice data in delivery history frm API
    [Arguments]    ${id_doi_tac}
    ${dict_data}    Get dict delivery history frm API    ${id_doi_tac}    ${EMPTY}    ${EMPTY}
    ...    $.Data[*].["Code","CustomerName","PurchaseDate","TotalPrice","Price","StatusName"]
    ${dict_data.PurchaseDate}    KV Convert DateTime To String    ${dict_data.PurchaseDate}
    Return From Keyword    ${dict_data}

Get document data in debt delivery partner frm API
    [Arguments]    ${id_doi_tac}
    ${dict_data}    Get dict debt delivery partner info frm API    ${id_doi_tac}    ${EMPTY}    ${EMPTY}
    ...    $.Data[*].["DocumentCode","TransDate","DocumentType","Value","Balance"]
    ${dict_data.TransDate}    KV Convert DateTime To String    ${dict_data.TransDate}
    # Convert loại phiếu từ dạng number sang string
    ${dict_data.DocumentType}    KV Convert List Type From Number To VN String    ${dict_data.DocumentType}    ${dict_loai_phieu}
    # Convert dấu dương -> âm, âm -> dương của các giá trị trong API để phục vụ so sánh
    ${dict_data.Value}      KV Swap between negative number and positive number    ${dict_data.Value}
    ${dict_data.Balance}    KV Swap between negative number and positive number    ${dict_data.Balance}
    Return From Keyword    ${dict_data}

Get id group delivery partner by name
    [Arguments]    ${group_name}
    ${dict_id}    Get dict all group delivery partner frm API    $.Data[?(@.Name\=\="${group_name}")].Id
    ${id_group}    Set Variable Return From Dict    ${dict_id.Id[0]}
    Return From Keyword    ${id_group}

Get list delivery partner id by index
    [Arguments]    ${list_partner_code}
    ${dict_partner}    Get dict all delivery partner frm API    $.Data[?(@.Id!=-1)].["Id","Code"]
    ${list_partner_id}    Create List
    FOR    ${item_partnercode}    IN ZIP    ${list_partner_code}
        ${index}    Get Index From List    ${dict_partner.Code}    ${item_partnercode}
        ${partner_id}    Set Variable Return From Dict    ${dict_partner.Id[${index}]}
        Append To List    ${list_partner_id}    ${partner_id}
    END
    Return From Keyword    ${list_partner_id}

Get list group delivery partner id by index
    [Arguments]    ${list_group_name}
    ${dict_group}    Get dict all group delivery partner frm API    $.Data[?(@.Id!=0)].["Id","Name"]
    ${list_group_id}    Create List
    FOR    ${item_groupname}    IN ZIP    ${list_group_name}
        ${index}    Get Index From List    ${dict_group.Name}    ${item_groupname}
        ${group_id}    Set Variable Return From Dict    ${dict_group.Id[${index}]}
        Append To List    ${list_group_id}    ${group_id}
    END
    Return From Keyword    ${list_group_id}

Get total document in debt delivery partner
    [Arguments]    ${delivery_partner_id}
    ${dict_total}    Get dict debt delivery partner info frm API    ${delivery_partner_id}    ${EMPTY}    ${EMPTY}    $.Total
    ${total_document}    Set Variable Return From Dict    ${dict_total.Total[0]}
    Return From Keyword    ${total_document}

Get the first document in debt delivery partner
    [Arguments]    ${delivery_partner_id}
    ${dict_data}    Get dict debt delivery partner info frm API    ${delivery_partner_id}    ${EMPTY}    ${EMPTY}
    ...    $.Data[0].["DocumentId","DocumentCode","DocumentType","Balance","Value"]
    ${document_id}      Set Variable Return From Dict    ${dict_data.DocumentId[0]}
    ${document_code}    Set Variable Return From Dict    ${dict_data.DocumentCode[0]}
    ${document_type}    Set Variable Return From Dict    ${dict_data.DocumentType[0]}
    ${balance}          Set Variable Return From Dict    ${dict_data.Balance[0]}
    ${value}            Set Variable Return From Dict    ${dict_data.Value[0]}
    ${balance}    Run Keyword If    ${balance} < 0    Minus    0    ${balance}    ELSE    Set Variable    ${balance}
    ${value}      Run Keyword If    ${value} < 0      Minus    0    ${value}      ELSE    Set Variable    ${value}
    Return From Keyword    ${document_id}    ${document_code}    ${document_type}    ${balance}    ${value}

Get detail document in update debt delivery partner
    [Arguments]    ${document_id}
    ${dict_detail}    Get dict detail update debt delivery partner frm API    ${document_id}    $.["Code","Balance","Description"]
    ${ma_phieu}      Set Variable Return From Dict    ${dict_detail.Code[0]}
    ${mo_ta}         Set Variable Return From Dict    ${dict_detail.Description[0]}
    ${gia_tri_no}    Set Variable Return From Dict    ${dict_detail.Balance[0]}
    ${gia_tri_no}    Minus    0    ${gia_tri_no}
    Return From Keyword    ${ma_phieu}    ${gia_tri_no}    ${mo_ta}

Get detail document in purchase payment debt delivery partner
    [Arguments]    ${document_id}
    ${dict_detail}    Get dict detail purchase payment debt delivery partner frm API    ${document_id}    $.Data[*].["Code","Amount","BankAccount.Account","SupplierDebt","Method","Description"]
    ${ma_phieu}       Set Variable Return From Dict    ${dict_detail.Code[0]}
    ${ghi_chu}        Set Variable Return From Dict    ${dict_detail.Description[0]}
    ${tien_tra}       Set Variable Return From Dict    ${dict_detail.Amount[0]}
    ${no_sau}         Set Variable Return From Dict    ${dict_detail.SupplierDebt[0]}
    ${phuong_thuc}    Set Variable Return From Dict    ${dict_detail.Method[0]}
    ${so_tk}          Set Variable Return From Dict    ${dict_detail.Account[0]}
    Return From Keyword    ${ma_phieu}    ${tien_tra}    ${no_sau}    ${phuong_thuc}    ${so_tk}    ${ghi_chu}

Get No Can Tra Hien Tai DTGH
    [Arguments]    ${id_doi_tac}
    ${result_dict}    Get dict all delivery partner frm API    $.Data[?(@.Id\=\=${id_doi_tac})].TotalDebt
    ${no_can_tra_dt}    Set Variable Return From Dict    ${result_dict.TotalDebt[0]}
    Return From Keyword    ${no_can_tra_dt}

Assert trang thai da huy cua hoa don trong lich su giao hang
    [Arguments]    ${id_doitac_giaohang}    ${ma_hoa_don}
    ${status_name}    Get status name of invoice code in delivery history    ${id_doitac_giaohang}    ${ma_hoa_don}
    KV Should Be Equal As Strings    ${status_name}    Đã hủy    Lỗi trạng thái của hóa đơn khác đã hủy

Assert invoice code not avaiable in debt delivery partner
    [Arguments]    ${input_ma_chungtu}    ${id_doitac_giaohang}
    ${all_invos}    Get all invoice code in debt delivery partner   ${id_doitac_giaohang}
    KV List Should Not Contain Value    ${all_invos}    ${input_ma_chungtu}    Lỗi danh sách vẫn chứa mã chứng từ đã hủy

Assert data update delivery partner require field
    [Arguments]    ${input_ma_doitac}    ${input_ten_doitac}    ${input_sdt_doitac}
    ${ten_doitac_gh}    ${sdt_doitac_gh}    Get delivery partner name and phone by code    ${input_ma_doitac}
    KV Compare Scalar Values    ${input_ten_doitac}    ${ten_doitac_gh}    Lỗi tên đối tác giao hàng input và trong API khác nhau
    KV Compare Scalar Values    ${input_sdt_doitac}    ${sdt_doitac_gh}    Lỗi SĐT đối tác giao hàng input và trong API khác nhau

Assert delivery partner not available in list
    [Arguments]    ${input_partner_code}
    ${list_partner_code}    Get all delivery partner code
    KV List Should Not Contain Value    ${list_partner_code}    ${input_partner_code}    Lỗi danh sách vẫn chứa mã đối tác giao hàng đã xóa

Assert data update debt delivery partner
    [Arguments]    ${input_id_doitac}    ${input_gt_no_dieuchinh}    ${input_mo_ta}
    # Lấy ra các thông tin id phiếu, mã phiếu, loại phiếu, giá trị cân bằng của phiếu đầu tiên
    ${document_id}    ${document_code}    ${document_type}    ${balance}    ${value}    Get the first document in debt delivery partner    ${input_id_doitac}
    # Kiểm tra thông tin của phiếu đầu tiên có giống với phiếu điều chỉnh nợ vừa thực hiện
    KV Should Contain           ${document_code}    CB    Lỗi phiếu đầu tiên có mã không đúng
    KV Should Be Equal As Strings    ${document_type}    1     Lỗi phiếu đầu tiên không phải là loại Điều chỉnh
    KV Should Be Equal As Numbers    ${balance}    ${input_gt_no_dieuchinh}    Lỗi phiếu đầu tiên có giá trị điều chỉnh nợ khác với input
    # Kiểm tra thông tin chi tiết của phiếu điều chỉnh nợ
    ${get_ma_phieu}    ${get_gt_no_dieuchinh}    ${get_mo_ta}    Get detail document in update debt delivery partner    ${document_id}
    KV Should Be Equal As Strings    ${get_ma_phieu}           ${document_code}            Lỗi mã phiếu không đúng
    KV Should Be Equal As Numbers    ${get_gt_no_dieuchinh}    ${input_gt_no_dieuchinh}    Lỗi giá trị nợ điều chỉnh không đúng
    KV Should Be Equal As Strings    ${get_mo_ta}              ${input_mo_ta}              Lỗi mô tả phiếu không đúng
    # Kiểm tra giá trị nợ hiện tại có bằng với giá trị điều chỉnh
    ${no_can_tra_dt}    Get No Can Tra Hien Tai DTGH    ${input_id_doitac}
    KV Should Be Equal As Numbers    ${no_can_tra_dt}          ${input_gt_no_dieuchinh}    Lỗi sai giá trị nợ cần trả ĐTGH sau khi điều chỉnh

Assert data purchase payments debt delivery partner
    [Arguments]    ${input_id_doitac}    ${input_gt_tra_doitac}    ${input_ghi_chu}    ${input_no_sau}    ${input_phuong_thuc}=${EMPTY}    ${input_so_tai_khoan}=${EMPTY}
    # Lấy ra các thông tin id phiếu, mã phiếu, loại phiếu, giá trị thanh toán của phiếu đầu tiên
    ${document_id}    ${document_code}    ${document_type}    ${balance}    ${value}    Get the first document in debt delivery partner    ${input_id_doitac}
    # Kiểm tra thông tin của phiếu đầu tiên có giống với phiếu thanh toán nợ vừa thực hiện
    KV Should Contain                ${document_code}    PC    Lỗi phiếu đầu tiên có mã không đúng
    KV Should Be Equal As Strings    ${document_type}    0     Lỗi phiếu đầu tiên không phải là loại Thanh Toán
    KV Should Be Equal As Numbers    ${value}    ${input_gt_tra_doitac}    Lỗi phiếu đầu tiên có giá trị thanh toán nợ khác với input
    # Kiểm tra thông tin chi tiết của phiếu thanh toán nợ
    ${get_ma_phieu}    ${get_gt_tra}    ${get_no_sau}    ${get_phuong_thuc}    ${get_so_tk}    ${get_ghi_chu}    Get detail document in purchase payment debt delivery partner    ${document_id}
    ${get_phuong_thuc}    Convert EN Method To VI    ${get_phuong_thuc}
    KV Should Be Equal As Strings    ${get_ma_phieu}    ${document_code}          Lỗi mã phiếu không đúng
    KV Should Be Equal As Numbers    ${get_gt_tra}      ${input_gt_tra_doitac}    Lỗi giá trị trả nợ trong API và input khác nhau
    KV Should Be Equal As Numbers    ${get_no_sau}      ${input_no_sau}           Lỗi giá trị nợ sau trong API và input khác nhau
    KV Should Be Equal As Strings    ${get_ghi_chu}     ${input_ghi_chu}          Lỗi ghi chú trong API và input khác nhau
    Run Keyword If    '${input_phuong_thuc}'!='${EMPTY}'     KV Should Be Equal As Strings    ${get_phuong_thuc}    ${input_phuong_thuc}    Lỗi phương thức trả nợ trong API và input khác nhau
    ...    ELSE    KV Should Be Equal As Strings     ${get_phuong_thuc}    Tiền mặt    Lỗi phương thức trả nợ không phải là tiền mặt
    Run Keyword If    '${input_so_tai_khoan}'!='${EMPTY}'    KV Should Be Equal As Strings    ${get_so_tk}    ${input_so_tai_khoan}    Lỗi số tài khoản trong API và input khác nhau
    # Kiểm tra giá trị nợ hiện tại có bằng với giá trị thanh toán
    ${no_can_tra_dt}    Get No Can Tra Hien Tai DTGH    ${input_id_doitac}
    KV Should Be Equal As Numbers    ${no_can_tra_dt}    ${input_no_sau}    Lỗi sai giá trị nợ cần trả ĐTGH sau khi thanh toán
    Return From Keyword    ${document_code}

Assert thong tin tong tat ca cac doi tac tren ui va API
    [Arguments]    ${text_tong_cpgh}    ${text_can_thuho}
    ${result_dict}    Get dict all delivery partner frm API    $.["Total2Value","Total5Value"]
    ${get_tong_cpgh}       Set Variable    ${result_dict.Total2Value[0]}
    ${get_can_thuho}       Set Variable    ${result_dict.Total5Value[0]}

    KV Should Be Equal As Numbers    ${text_tong_cpgh}        ${get_tong_cpgh}        msg=Sai Tổng tiền phí giao hàng của tất cả các đối tác
    KV Should Be Equal As Numbers    ${text_can_thuho}        ${get_can_thuho}        msg=Sai Tổng tiền cần thu hộ của tất cả các đối tác

Assert thong tin tong cua doi tac tren ui va API
    [Arguments]    ${id_dtgh}    ${text_tong_cpgh}    ${text_can_thuho}
    ${result_dict}    Get dict all delivery partner frm API     $.Data[?(@.Id\=\=${id_dtgh})].["TotalCost","TotalCodNeedPayment"]
    ${get_tong_cpgh}       Set Variable    ${result_dict.TotalCost[0]}
    ${get_can_thuho}       Set Variable    ${result_dict.TotalCodNeedPayment[0]}

    KV Should Be Equal As Numbers    ${text_tong_cpgh}        ${get_tong_cpgh}        msg=Sai Tổng tiền phí giao hàng của đối tác
    KV Should Be Equal As Numbers    ${text_can_thuho}        ${get_can_thuho}        msg=Sai Tổng tiền cần thu hộ của đối tác
