*** Settings ***
Library           SeleniumLibrary
Resource          ../../_common_keywords/common_menu_screen.robot
Resource          ../../share/toast_message.robot
Resource          ../../../config/envi.robot
Resource          ../../API/GET/chi-nhanh/api_chi_nhanh.robot
Resource          ../../API/api_access.robot

*** Keywords ***
Go To Chi Nhanh Khac
    [Arguments]    ${alias}    ${branch_name}
    # Mở trình duyệt truyền vào alias, đăng nhập vào quản lý
    Before Test Quan ly    alias=${alias}
    # Chuyển chi nhánh trên UI
    Switch to branch name    ${branch_name}
    # Get id chi nhánh và set lại branh_id
    ${id_chi_nhanh}    Get branch id by name    ${branch_name}
    Set Test Variable    ${BRANCH_ID}    ${id_chi_nhanh}
    # Set Cookies mới cho branch
    # ${cookies_other}    API Change Branch And Get Branch Cookies    ${BRANCH_ID}
    ${cookies_other}    Set Branch Cookies    ${BRANCH_ID}
    KV Log    ${cookies_other}
    # Tạo lại session với cookies mới của chi nhanh ${branch_name}
    Create Session    session_api    ${API_URL}    cookies=${cookies_other}    verify=True    disable_warnings=1    debug=1

Switch to branch name
    [Arguments]    ${branch_name}
    FNB Menu Header DropDown List ChiNhanh    is_wait_visible=True
    FNB Menu Header Input Search ChiNhanh    ${branch_name}    is_wait_visible=True
    FNB Menu Header Cell Item ChiNhanh
    Select branch message success validation    ${branch_name}
    ${locator}    FNB GetLocator Menu Header DropDown List ChiNhanh
    ${get_text}    Get Text    ${locator}
    KV Should Be Equal As Strings    ${get_text}    ${branch_name}    Lỗi sai chi nhánh

Before Test Tong Quan
    [Timeout]    3 minutes
    Before Test Quan ly
    FNB Menu TongQuan

Before Test Danh Muc Hang Hoa
    [Timeout]    3 minutes
    Before Test Quan ly
    Go To Danh Muc Hang Hoa

Before Test Thiet Lap Gia
    [Timeout]    3 minutes
    Before Test Quan ly
    Go to Thiet lap gia

Before Test Khach Hang
    [Timeout]    3 minutes
    Before Test Quan ly
    Go to Khach Hang

Before Test Nha Cung Cap
    [Timeout]    3 minutes
    Before Test Quan ly
    Go to Nha Cung Cap

Before Test Kiem Kho
    [Timeout]    3 minutes
    Before Test Quan ly
    Go to Kiem kho

Before Test San Xuat
    [Timeout]    3 minutes
    Before Test Quan ly
    Go To San Xuat

Before Test Nhap Hang
    [Timeout]    3 minutes
    Before Test Quan ly
    Go To Nhap Hang

Before Test Tra Hang Nhap
    [Timeout]    3 minutes
    Before Test Quan ly
    Go To Tra Hang Nhap

Before Test Hoa Don
    [Timeout]    3 minutes
    Before Test Quan ly
    Go To Hoa Don

Before Test Tra Hang
    [Timeout]    3 minutes
    Before Test Quan ly
    Go To Tra Hang

Before Test So Quy
    [Timeout]    3 minutes
    Before Test Quan ly
    Go To So Quy

Before Test Phong Ban
    [Timeout]    3 minutes
    Before Test Quan ly
    Go To Phong Ban

Before Test Doi Tac Giao Hang
    [Timeout]    3 minutes
    Before Test Quan ly
    Go To Doi Tac Giao Hang

Before Test Xuat Huy
    [Timeout]    3 minutes
    Before Test Quan ly
    Go To Xuat Huy

Before Test Chuyen Hang
    [Timeout]    3 minutes
    Before Test Quan ly
    Go To Chuyen Hang
