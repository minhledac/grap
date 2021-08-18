*** Settings ***
Library           SeleniumLibrary
Resource          ../../_common_keywords/common_menu_screen.robot
Resource          ../../_common_keywords/common_purchaseOrder_screen.robot
Resource          ../../_common_keywords/common_purchaseReturn_screen.robot
Resource          ../../_common_keywords/common_invoice_screen.robot
Resource          ../../_common_keywords/common_damageItems_screen.robot
Resource          ../../_common_keywords/common_transfer_screen.robot


*** Keywords ***
Go To Tra Hang Nhap
    FNB Menu GiaoDich    True
    FNB Menu GD TraHangNhap    True
    FNB WaitVisible THN Title Phieu Tra Hang Nhap    wait_time_out=1 minute

Go To Them Phieu Tra Hang Nhap
    FNB THN Header Button Tao Phieu Tra Hang Nhap
    FNB WaitNotVisible Menu Loading Icon
    FNB WaitVisible THN Add Title Tra Hang Nhap

Go To Nhap Hang
    FNB Menu GiaoDich    True
    FNB Menu GD NhapHang    True
    FNB WaitVisible PNH Title Phieu NhapHang    wait_time_out=1 minute

Go To Them Phieu Nhap Hang
    FNB PNH Header Button Tao PhieuNhap
    FNB WaitVisible PNH AddPN Title PhieuNhap

Go To Hoa Don
    [Timeout]
    FNB Menu GiaoDich    True
    FNB Menu GD HoaDon    True
    FNB WaitVisible HD Header Title Hoa Don    wait_time_out=1 minute

Go To Xuat Huy
    [Timeout]
    FNB Menu GiaoDich    True
    FNB Menu GD XuatHuy    True
    FNB WaitVisible PXH Header Title Phieu XuatHuy    wait_time_out=1 minute

Go To Them Phieu Xuat Huy
    [Timeout]
    FNB PXH Header Button Tao PhieuXuatHuy
    FNB WaitVisible PXH AddPXH Title PhieuXuatHuy

Go To Chuyen Hang
    [Timeout]
    FNB Menu GiaoDich    True
    FNB Menu GD ChuyenHang    True
    FNB WaitVisible PCH Header Title Phieu Chuyen    wait_time_out=1 minute

Go To Them Phieu Chuyen Hang
    [Timeout]
    FNB PCH Header Button Tao PhieuChuyen
    FNB WaitVisible PCH AddPCH Title PhieuChuyen

Go To Tra Hang
    FNB Menu GiaoDich
    FNB Menu GD TraHang    True
    FNB WaitVisible TH Title Phieu Tra Hang    wait_time_out=1 minute
