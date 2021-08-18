*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Resource          ../../_common_keywords/common_Return_screen.robot
Resource          ../../_common_keywords/common_menu_screen.robot
Resource          Giao_Dich_Navigation.robot
Resource          ../../share/toast_message.robot
Resource          ../../../config/envi.robot

*** Keywords ***
Chon hien thi cac truong lien quan den tien page tra hang
    FNB HD Header Icon Menu Hien Thi Cac Truong
    FNB Column Giam Gia
    FNB Column Tong Sau Giam Gia
    FNB Column Phi Tra Hang
    FNB Column Thu Khac Hoan Lai
    FNB Column Tong Tien Hang Tra
    FNB HD Header Icon Menu Hien Thi Cac Truong
