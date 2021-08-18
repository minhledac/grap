*** Settings ***
Library           SeleniumLibrary
Library           String
Resource          ../../_common_keywords/common_Kitchen_screen.robot
Resource          ../../_common_keywords/common_Cashier_screen.robot
Resource          ../../share/toast_message.robot
Resource          ../../share/list_dictionary.robot
Resource          ../../../config/envi.robot
Resource          ../../../core/share/utils.robot
Resource          ../../../core/share/constants.robot
Library           ../../../custom-library/PdfHandle.py
Resource          ../../share/utils.robot
Library           String
Library           Collections
Library           DateTime
Library           BuiltIn

*** Keywords ***

Get list name hang hoa tren tab cho che bien
    [Arguments]    ${Ten_ban_va_order_code}
    ${loc_list_pr}    FNB GetLocator Tab Cho Che Bien List Hang Hoa Tab Phong Ban    ${Ten_ban_va_order_code}
    ${count}    Get Element Count    ${loc_list_pr}
    ${list_pr}    Create List
    FOR    ${index}    IN RANGE    1    ${count} + 1
        ${name_pr}    Get Text    (${loc_list_pr})[${index}]
        Append To List    ${list_pr}    ${name_pr}
    END
    Return From Keyword    ${list_pr}

Go to page Thu Ngan from man hinh bep
    [Arguments]    ${EMPTY}
    [Documentation]   Di chuyể từ mành bếp sang màn hình thu ngân
    FNB Tab cho cung ung Menu Bar Icon
    FNB Tab cho cung ung Menu Bar Button Thu Ngan
    FNB WaitVisible MHTN Header Text Title Phong Ban
    FNB WaitNotVisible MHTN Header Loading Icon

Assert mau va so luong mon an da cung ung
    [Arguments]   ${table_name}   ${ten_hang_hoa}   ${input_so_luong_mon_an_cung_ung}
    [Documentation]   assert thông tin mã màu và số lượng món ăn giữa màn hìn bếp và màn hinh thu ngân
    FNB MHTN Header Textbox Search Phong Ban   ${table_name}
    Sleep  2
    ${so_luong_mon_an}   FNB GetLocator MHTN TabOrder Text SL Mon Da Tra Toan Phan   ${ten_hang_hoa}
    Should Contain   ${so_luong_mon_an}    ${so_luong_mon_an_cung_ung}

Assert thong tin ban an da gui voi thong tin tren man hinh Bep
   [Arguments]   ${input_ten_ban_an}   ${input_ten_thuc_don}   ${input_so_luong_mon_an}
   ${length}   Get Length   ${input_ten_thuc_don}
   FOR   ${index}   IN RANGE   0    ${length} - 1
         ${locator}  FNB GetLocator Tab Cho Che Bien Ten mon an   ${input_ten_ban_an}  ${input_ten_thuc_don}[${index}]
         ${ten_thuc_don}     Get Text    ${locator}
         ${locator}  FNB GetLocator Tab Cho Che Bien ten ban an   ${input_ten_thuc_don}[${index}]  ${input_ten_ban_an}
         ${ten_ban_an}     Get Text   ${locator}
         ${locator}  FNB GetLocator Tab Cho Che Bien so luong cua mon an   ${input_ten_ban_an}  ${input_ten_thuc_don}[${index}]
         ${so_luong_cua_mon_an}   Get Text   ${locator}
         ${locator}  FNB GetLocator Tab Cho Che Bien ngay thang nam va nguoi gui   ${input_ten_ban_an}  ${input_ten_thuc_don}[${index}]
         ${ngay_thang_nam_nguoi_gui}  Get Text   ${locator}
         #cut space charactor
         ${ten_ban_an}  Strip String  ${ten_ban_an}
         ${ten_thuc_don}  Strip String  ${ten_thuc_don}
         ${so_luong_cua_mon_an}  Strip String  ${so_luong_cua_mon_an}
         ${ngay_thang_nam_nguoi_gui}  Strip String  ${ngay_thang_nam_nguoi_gui}
         #convert fomart current date
         ${current_date_time}  Get Current Date
         ${date_time_string}    KV Convert DateTime From API To 24h Format String   ${current_date_time}
         ${length}   Get Length   ${date_time_string}
         ${length_date}   Evaluate  ${length} - 9
         ${date_string}   Get Substring   ${date_time_string}  0  ${length_date}
         #assert thong tin
         KV Should Be Equal As Strings   ${input_ten_ban_an}  ${ten_ban_an}                         msg=ten ban an input va ten ban an hien thi khac nhau
         KV Should Be Equal As Strings   ${input_ten_thuc_don}[${index}]  ${ten_thuc_don}           msg=ten thuc don input va ten thuc don hien thi khac nhau
         KV Should Be Equal As Strings   ${input_so_luong_mon_an}  ${so_luong_cua_mon_an}           msg=so luong mon an input va so luong mon an hien thi khac nhau
         Should Contain  ${ngay_thang_nam_nguoi_gui}  ${date_string}
         Should Contain  ${ngay_thang_nam_nguoi_gui}  ${RETAILER}
   END
