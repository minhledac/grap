*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Resource          ../../_common_keywords/common_dashboard_screen.robot
Resource          ../../_common_keywords/common_menu_screen.robot
Resource          ../../share/utils.robot
Resource          ../../../config/envi.robot

*** Keywords ***
Get text tren khu vuc hoat dong gan day
    [Arguments]    ${ma_hoa_don}
    FNB WaitVisible TQ Act Title Hoat Dong Gan Day
    ${loc_ten_user}   FNB GetLocator TQ Act Ten Nguoi Thuc Hien    ${ma_hoa_don}
    ${loc_ten_act}    FNB GetLocator TQ Act Ten Hoat Dong    ${ma_hoa_don}
    ${loc_gia_tri}    FNB GetLocator TQ Act Text Gia Tri Giao Dich    ${ma_hoa_don}
    Wait Until Element Is Visible    ${loc_ten_user}
    Wait Until Element Is Visible    ${loc_ten_act}
    Wait Until Element Is Visible    ${loc_gia_tri}
    ${text_ten_user}   Get Text    ${loc_ten_user}
    ${text_ten_act}    Get Text    ${loc_ten_act}
    ${text_gia_tri}    Get Text    ${loc_gia_tri}
    Return From Keyword    ${text_ten_user}    ${text_ten_act}    ${text_gia_tri}

Get text thong tin ket qua ban hang hom nay
    ${tong_don_hn}        FNB TQ KQHN TongSo Don DaXong
    ${value_don_hn}       FNB TQ KQHN DoanhThu HomNay
    ${value_don_hom_qua}  FNB TQ KQHN DoanhThu HomQua
    ${phan_tram_don}      FNB TQ KQHN PhanTram TangGiam DoanhThu
    #
    ${tong_don_pv}        FNB TQ KQHN TongSo Don Dang PhucVu
    ${value_don_pv}       FNB TQ KQHN Doanh Thu Dang PhucVu
    #
    ${tong_kh_hn}         FNB TQ KQHN KhachHang HomNay
    ${tong_kh_hom_qua}    FNB TQ KQHN KhachHang HomQua
    ${phan_tram_kh}       FNB TQ KQHN PhanTram TangGiam KhachHang
    Return From Keyword    ${tong_don_hn}    ${value_don_hn}    ${value_don_hom_qua}    ${phan_tram_don}
    ...    ${tong_don_pv}    ${value_don_pv}    ${tong_kh_hn}    ${tong_kh_hom_qua}    ${phan_tram_kh}

#
