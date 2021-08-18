*** Settings ***
Resource          ../../api_access.robot
Resource          ../../../share/utils.robot
Library           String
Library           Collections
Library           DateTime

*** Keywords ***
# lấy danh sách lịch sử thao tác Filter theo CN đang đăng nhập + Hôm nay
Get dict all AuditTrail frm API
    [Documentation]    from_date và to_date với format: %Y-%m-%d
    [Arguments]    ${list_jsonpath}    ${from_date}=${EMPTY}    ${to_date}=${EMPTY}    ${so_ban_ghi}=100
    ${current_date}    Get Current Date    result_format=%Y-%m-%d
    ${end_date}    Add Time To Date    ${current_date}    1 day    date_format=%Y-%m-%d
    ${from_date}    Set Variable If    '${from_date}'!='${EMPTY}'    ${from_date}    ${current_date}
    ${to_date}      Set Variable If    '${to_date}'!='${EMPTY}'    ${to_date}    ${end_date}
    ${input_dict}    Create Dictionary    branch_id=${BRANCH_ID}    from_date=${from_date}    to_date=${to_date}    so_ban_ghi=${so_ban_ghi}
    ${result_dict}    API Call From Template     /lich-su-thao-tac/all_audit_trail.txt    ${input_dict}    ${list_jsonpath}
    Return From Keyword    ${result_dict}

Assert lich su thao tac tao moi hang hoa
    [Arguments]    ${ma_hh}    ${ten_hh}    ${nhom_hh}    ${gia_ban}
    ${list_jsonpath}    Create List    $.Data[?(@.ActionName\=\="Thêm mới")].["ActionName","FunctionName","SubContent"]
    ${result_dict}    Get dict all AuditTrail frm API    ${list_jsonpath}
    ${gia_ban}    Evaluate    "{:,}".format(${gia_ban})
    ${input_subcontent}    Set Variable    Thêm mới sản phẩm: ${ma_hh}, tên: ${ten_hh}, nhóm hàng: ${nhom_hh}, giá bán: ${gia_ban}
    ${index}   Get index of item in audit log    ${ma_hh}    ${result_dict.SubContent}
    KV Should Be Equal As Strings    ${result_dict.ActionName[${index}]}      Thêm mới               msg=Sai thông tin Thao tác
    KV Should Be Equal As Strings    ${result_dict.FunctionName[${index}]}    Danh mục hàng hóa      msg=Sai thông tin Chức năng
    KV Should Contain    ${result_dict.SubContent[${index}]}      ${input_subcontent}    msg=Sai nội dung bản ghi LSTT

Assert lich su thao tac khi thanh toan don hang
    [Arguments]    ${invoice_code}    ${ten_ban}
    ${list_jsonpath}    Create List    $.Data[?(@.ActionName\=\="Thêm mới")].["ActionName","FunctionName","SubContent"]
    ${result_dict}    Get dict all AuditTrail frm API    ${list_jsonpath}
    ${input_subcontent}    Set Variable    Tạo hóa đơn: ${invoice_code} ${ten_ban}
    ${index}   Get index of item in audit log    ${input_subcontent}    ${result_dict.SubContent}
    KV Should Be Equal As Strings    ${result_dict.ActionName[${index}]}      Thêm mới    msg=Sai thông tin Thao tác
    KV Should Be Equal As Strings    ${result_dict.FunctionName[${index}]}    Hóa đơn     msg=Sai thông tin Chức năng
    KV Should Contain     ${result_dict.SubContent[${index}]}      ${input_subcontent}    msg=Sai nội dung bản ghi LSTT

Get index of item in audit log
    [Arguments]    ${find_str}    ${list_SubContent}
    ${index}   Set Variable    -1
    FOR    ${item_content}    IN    @{list_SubContent}
        ${index}    Evaluate    ${index}+1
        ${is_contain}    Run Keyword And Return Status    Should Contain    ${item_content}   ${find_str}
        Exit For Loop If    '${is_contain}'=='True'
    END
    Return From Keyword    ${index}

Assert lich su thao tac huy mon MHTN va ly do huy mon
    [Arguments]    ${ma_order}    ${ten_ban}   ${ly_do_huy_mon}
    ${list_jsonpath}    Create List    $.Data[?(@.ActionName\=\="Cập nhật")].["ActionName","FullContent","SubContent","FunctionName"]
    ${result_dict}    Get dict all AuditTrail frm API    ${list_jsonpath}
    ${input_subcontent}    Set Variable    Hủy/Giảm số lượng trong đơn hàng ${ma_order} ${ten_ban}
    ${index}   Get index of item in audit log    ${input_subcontent}    ${result_dict.SubContent}
    KV Should Be Equal As Strings    ${result_dict.ActionName[${index}]}      Cập nhật    msg=Sai thông tin Thao tác
    KV Should Be Equal As Strings    ${result_dict.FunctionName[${index}]}    Gọi món     msg=Sai thông tin Chức năng
    KV Should Contain     ${result_dict.SubContent[${index}]}    ${input_subcontent}      msg=Sai nội dung bản ghi LSTT
    KV Should Contain     ${result_dict.FullContent[${index}]}    ${ly_do_huy_mon}        msg=Sai nội dung lý do hủy món

    #
