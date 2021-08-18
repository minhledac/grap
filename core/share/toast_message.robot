*** Settings ***
Library           SeleniumLibrary
Library           String
Resource          ../_common_keywords/common_menu_screen.robot
Resource          utils.robot

*** Variables ***
${toast_message}    //div[@id='toast-container']//div[contains(@class, 'toast-message')][1]

*** Keywords ***
Assert toast message
    [Arguments]    ${expected_message}
    Wait Until Page Contains Element    ${toast_message}    20 seconds
    Wait Until Keyword Succeeds    10 times   0.5s    Page Should Contain    ${expected_message}
    # loan.nt remove multiple space in string
    ${expected_message}    Evaluate    " ".join($expected_message.split())
    KV Element Should Contain    ${toast_message}    ${expected_message}    Lỗi toast message hiển thị sai

Select branch message success validation
    [Arguments]    ${branch_name}
    ${message_full}    Format String    Bạn vừa chuyển sang chi nhánh: {0}, màn hình bán hàng sẽ được tải lại theo chi nhánh mới.    ${branch_name}
    Assert toast message    ${message_full}

Delete return message success validation
    [Arguments]    ${ma_phieu_tra}
    ${message_full}    Format String    Hủy trả hàng: {0} thành công    ${ma_phieu_tra}
    Assert toast message    ${message_full}

Delete invoice message success validation
    [Arguments]    ${ma_hoa_don}
    ${message_full}    Format String    Hủy hóa đơn: {0} thành công    ${ma_hoa_don}
    Assert toast message    ${message_full}

Order message success validation
    Assert toast message    Thông tin đơn hàng được cập nhật thành công

Create product success validation
    Assert toast message    Hàng hóa đã được tạo thành công

Create supplier success validation
    Assert toast message    Thông tin nhà cung cấp được cập nhật thành công

Create partner delivery group success validation
    Assert toast message    Thêm mới nhóm đối tác giao hàng thành công

Update delivery partner success validation
    Assert toast message    Thông tin đối tác giao hàng được cập nhật thành công

Delete delivery partner success validation
    [Arguments]    ${ten_doi_tac}
    ${message_full}    Format String    Xóa đối tác giao hàng {0} thành công    ${ten_doi_tac}
    Assert toast message    ${message_full}

Update damage items data success validation
    [Arguments]    ${ma_phieu_xh}
    ${message_full}    Format String    Phiếu xuất hủy {0}${SPACE} được cập nhật thành công    ${ma_phieu_xh}
    Assert toast message    ${message_full}

Update product transfer data success validation
    Assert toast message    Cập nhật phiếu chuyển hàng thành công

Delete damage items message success validation
    [Arguments]    ${ma_phieu_xh}
    ${message_full}    Format String    Hủy phiếu {0} thành công    ${ma_phieu_xh}
    Assert toast message    ${message_full}

Delete product transfer message success validation
    [Arguments]    ${ma_phieu_chuyen}
    ${message_full}    Format String    Hủy phiếu chuyển hàng: {0} thành công    ${ma_phieu_chuyen}
    Assert toast message    ${message_full}

Update info success validation
    ${message_full}    Set Variable    ${SPACE}Cập nhật thông tin thành công${SPACE}
    Assert toast message    ${message_full}

Update data success validation
    Assert toast message    Cập nhật dữ liệu thành công

Delete data success validation
    Assert toast message    Xóa dữ liệu thành công

Product exchange message success validation
    Assert toast message    Trả hàng được cập nhật thành công

Update invoice success validation
    [Arguments]    ${ma_hoa_don}
    ${message_full}    Format String    Hóa đơn {0} được cập nhật thành công    ${ma_hoa_don}
    Assert toast message    ${message_full}

Delete multiple product message
    Assert toast message    Xóa thành công danh sách hàng hóa đã chọn

Delete a product message
    [Arguments]    ${ma_hang}
    ${message_full}    Format String    Xóa hàng hóa: {0} thành công    ${ma_hang}
    Assert toast message    ${message_full}

Delete a manufacturing note message
    [Arguments]    ${ma_phieu_sx}
    ${message_full}    Format String    Hủy phiếu sản xuất: {0} thành công    ${ma_phieu_sx}
    Assert toast message    ${message_full}

Delete pricebook message success validation
    Assert toast message    Xóa dữ liệu thành công

Delete stocktak message success validation
    [Arguments]   ${ma_phieu_kiem}
    ${message_full}    Format String    Hủy phiếu kiểm kho: {0} thành công    ${ma_phieu_kiem}
    Assert toast message    ${message_full}

Update stocktak message success validation
    [Arguments]   ${ma_phieu_kiem}
    ${message_full}    Format String    {0} ${EMPTY} được cập nhật thành công    ${ma_phieu_kiem}
    Assert toast message    ${message_full}

Create purchase order message success validation
    [Arguments]    ${ma_phieu_nhap}
    ${message_full}    Set Variable    Phiếu nhập hàng ${ma_phieu_nhap} ${EMPTY} được cập nhật thành công
    Assert toast message    ${message_full}

Delete purchase order message success validation
    [Arguments]   ${ma_phieu_nhap}
    ${message_full}    Format String    Hủy phiếu nhập {0} thành công    ${ma_phieu_nhap}
    Assert toast message    ${message_full}

Create purchase return message success validation
    [Arguments]    ${ma_phieu_THN}
    ${message_full}    Set Variable    Phiếu trả hàng nhập ${ma_phieu_THN} ${EMPTY} được cập nhật thành công
    Assert toast message    ${message_full}

Delete purchase return message success validation
    [Arguments]   ${ma_phieu_THN}
    ${message_full}    Format String    Hủy phiếu trả hàng nhập: {0} thành công    ${ma_phieu_THN}
    Assert toast message    ${message_full}

Create customer message success validation
    Assert toast message    Thông tin khách hàng được cập nhật thành công

Create customer group message success validation
    Assert toast message    Thêm mới nhóm khách hàng thành công

Delete customer message success validation
    [Arguments]    ${ten_kh}
    ${message_full}    Format String    Xóa khách hàng {0} thành công    ${ten_kh}
    Assert toast message    ${message_full}

Create supplier group message success validation
    Assert toast message    Thêm mới nhóm nhà cung cấp thành công

Create supplier message success validation
    Assert toast message    Thông tin nhà cung cấp được cập nhật thành công

Delete supplier message success validation
    [Arguments]    ${ten_ncc}
    ${message_full}    Format String    Xóa nhà cung cấp {0} thành công    ${ten_ncc}
    Assert toast message    ${message_full}

OFF Auto Print message success validation
    ${message_full}    Set Variable     ${SPACE}Không tự động in hóa đơn${SPACE}
    Assert toast message    ${message_full}

ON Auto Print message success validation
    ${message_full}    Set Variable     ${SPACE}Tự động in hóa đơn${SPACE}
    Assert toast message    ${message_full}

Create Invoice message success validation
    ${message_full}    Set Variable     ${SPACE}Giao dịch được cập nhật thành công${SPACE}
    Assert toast message    ${message_full}

Notified Kitchen message success validation
    ${message_full}    Set Variable     ${SPACE}Bếp đã nhận được thông báo${SPACE}
    Assert toast message    ${message_full}

Send YCTT message success validation
    [Arguments]    ${order_code}
    ${message_full}    Set Variable    ${SPACE}Gửi yêu cầu thanh toán cho ${order_code} thành công${SPACE}
    Assert toast message    ${message_full}

Recieve YCTT message success validation
    [Arguments]    ${order_code}    ${table_name}    ${table_group}
    ${message_full}    Set Variable If    '${table_group}'=='0'    ${SPACE}${order_code} - ${table_name} - yêu cầu thanh toán.${SPACE}
    ...    ${SPACE}${order_code} - ${table_name} - ${table_group} - yêu cầu thanh toán.${SPACE}
    Assert toast message    ${message_full}

Import Product success validation
    [Timeout]    3 minutes
    FNB WaitVisible Menu Import Export Icon Success    wait_time_out=2 mins
    ${import_NotiContent_firstitem}    FNB GetLocator Menu Import NotiContent Firstitem
    Wait Until Keyword Succeeds    30 times    0.5s    KV Element Should Contain    ${import_NotiContent_firstitem}    Import thành công    Lỗi hiển thị sai thông báo import

Tao phieu thu message success validation
    ${message_full}    Set Variable     Tạo Phiếu thu Thành công
    Assert toast message    ${message_full}

Create Invoice return offline message success validation
    ${message_full}    Set Variable     ${SPACE}Không có kết nối internet. Giao dịch được lưu offline${SPACE}
    Wait Until Page Contains Element    ${toast_message}    20 seconds
    ${expected_message}    Evaluate    " ".join($message_full.split())
    KV Element Should Contain    ${toast_message}    ${expected_message}    Lỗi toast message hiển thị sai

Create message wait sync data
    ${message_full}    Set Variable     ${SPACE}Bạn vui lòng đợi ít phút để hệ thống ổn định trước khi đồng bộ!${SPACE}
    Assert toast message    ${message_full}

Notified qua so luong ton
    ${message_full}    Set Variable     ${SPACE}Đặt hàng quá số lượng cho phép${SPACE}
    Assert toast message    ${message_full}

Create message loading sync data
    ${message_full}    Set Variable     ${SPACE}Đang đồng bộ...${SPACE}
    Assert toast message    ${message_full}
