*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Resource          ../../_common_keywords/common_invoice_screen.robot
Resource          ../../_common_keywords/common_products_screen.robot
Resource          giao_dich_navigation.robot
Resource          ../../share/toast_message.robot
Resource          ../../share/list_dictionary.robot
Resource          ../../share/computation.robot
Resource          ../../share/constants.robot
Resource          ../../../config/envi.robot
Resource          ../hang-hoa/hang_hoa_add_action.robot

*** Keywords ***
Set gia tri khach thanh toan va expect tien thua tra khach
    [Documentation]    Set giá trị khách thanh toán trong các trường hợp:
    ...     TH1: Khách thanh toán > Khách cần trả thì Khách thanh toán =Khách cần trả + 50000
    ...     TH1: Khách thanh toán < Khách cần trả thì Khách thanh toán =Khách cần trả - 50000
    ...     TH1: Khách thanh toán =Khách cần trả thì Khách thanh toán =Khách cần trả
    [Arguments]     ${compare_value}    ${khach_can_tra}    ${option_tien_thua}
    ${khach_thanh_toan}    Run Keyword If    '${compare_value}' == 'Greater'    Sum    ${khach_can_tra}   50000
    ...                           ELSE IF    '${compare_value}' == 'Less'       Minus    ${khach_can_tra}   50000
    ...                           ELSE IF    '${compare_value}' == 'Equal'      Set Variable    ${khach_can_tra}
    ${ex_tien_thua}    Run Keyword If    '${compare_value}'=='Greater' and '${option_tien_thua}'!='False'    Minus    ${khach_thanh_toan}   ${khach_can_tra}
    ...                       ELSE     Set Variable    0
    Return From Keyword    ${khach_thanh_toan}    ${ex_tien_thua}

Chon hien thi cac truong lien quan den tien
    FNB HD Header Icon Menu Hien Thi Cac Truong
    FNB HD Header Column Thu Khac
    FNB HD Header Column Can Thu Ho
    FNB HD Header Column Khach Can Tra
    FNB HD Header Column Phi Tra DTGH
    FNB HD Header Icon Menu Hien Thi Cac Truong

Chon hien thi truong so dien thoai
    FNB HD Header Icon Menu Hien Thi Cac Truong
    FNB HD Header Column So Dien Thoai
    FNB HD Header Icon Menu Hien Thi Cac Truong
