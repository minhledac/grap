*** Settings ***
Library           SeleniumLibrary
Resource          ../../_common_keywords/common_menu_screen.robot
Resource          ../../_common_keywords/common_manufacturing_screen.robot
Resource          ../../_common_keywords/common_products_screen.robot
Resource          ../../_common_keywords/common_pricebook_screen.robot
Resource          ../../_common_keywords/common_stocktakes_screen.robot

*** Keywords ***
Go To Danh Muc Hang Hoa
    [Timeout]
    FNB Menu HangHoa    is_wait_visible=True    wait_time_out=30
    FNB Menu HH DanhMuc    is_wait_visible=True    wait_time_out=30
    FNB WaitNotVisible Menu Loading Icon
    FNB WaitVisible HH Title Danh Muc    wait_time_out=1 minute

Go to Them moi Hang thuong
    [Timeout]
    FNB HH Header Button ThemMoi
    FNB HH Header Button Them HH Thuong
    FNB WaitVisible HH AddHH Text Them HH Thuong

Go to Them moi Hang che bien
    [Timeout]
    FNB HH Header Button ThemMoi
    FNB HH Header Button Them HH CheBien
    FNB WaitVisible HH AddHH Text Them HH CheBien

Go to Them moi Hang Dich vu
    [Timeout]
    FNB HH Header Button ThemMoi
    FNB HH Header Button Them HH DichVu
    FNB WaitVisible HH AddHH Text Them HH DichVu

Go to Them moi Hang Combo
    [Timeout]
    FNB HH Header Button ThemMoi
    FNB HH Header Button Them HH Combo
    FNB WaitVisible HH AddHH Text Them HH Combo

Go to Thiet lap gia
    [Timeout]
    FNB Menu HangHoa    is_wait_visible=True
    FNB Menu HH ThietLapGia    is_wait_visible=True
    FNB WaitNotVisible Menu Loading Icon
    FNB WaitVisible TLG Title Thiet Lap Gia    wait_time_out=1 minute

Go to Them moi bang gia
    [Timeout]
    FNB TLG Sidebar Button Them BangGia
    FNB WaitVisible TLG AddBG Title Them BangGia    wait_time_out=30

Go to Kiem kho
    [Timeout]
    FNB Menu HangHoa    is_wait_visible=True
    FNB Menu HH KiemKho    is_wait_visible=True
    FNB WaitNotVisible Menu Loading Icon      wait_time_out=1 minute
    FNB WaitVisible KK Title Phieu KiemKho    wait_time_out=1 minute

Go to Them moi phieu kiem
    [Timeout]
    FNB KK Header Button Them PhieuKiem
    FNB WaitNotVisible Menu Loading Icon
    FNB WaitVisible KK AddPK Title KiemKho    wait_time_out=30

Go To San Xuat
    [Timeout]
    FNB Menu HangHoa    is_wait_visible=True    wait_time_out=30
    FNB Menu HH SanXuat    is_wait_visible=True    wait_time_out=30
    FNB WaitVisible SX Title San Xuat    wait_time_out=1 minute

Go to Tao moi phieu San xuat
    [Timeout]
    FNB SX Header Button Tao PhieuSanXuat    is_wait_visible=True
    FNB WaitVisible SX AddPSX Title Tao PhieuSX
