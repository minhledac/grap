*** Settings ***
Library           SeleniumLibrary
Resource          ../../_common_keywords/common_deliverypartner_screen.robot
Resource          ../../_common_keywords/common_menu_screen.robot
Resource          ../../_common_keywords/common_customers_screen.robot
Resource          ../../_common_keywords/common_Supplier_screen.robot

*** Keywords ***
Go To Doi Tac Giao Hang
    [Timeout]
    FNB Menu DoiTac    True
    FNB Menu DT GiaoHang    True
    FNB WaitVisible DTGH Title Doi Tac    wait_time_out=1 minute

Go to Khach Hang
    [Timeout]
    FNB Menu DoiTac    is_wait_visible=True
    FNB Menu DT KhachHang    is_wait_visible=True
    FNB WaitVisible KH Title KhachHang      wait_time_out=1 minute
    FNB WaitNotVisible Menu Loading Icon    wait_time_out=1 minute

Go to Nha Cung Cap
    [Timeout]
    FNB Menu DoiTac    is_wait_visible=True
    FNB Menu DT NhaCungCap   is_wait_visible=True
    FNB WaitVisible NCC Title NhaCungCap    wait_time_out=1 minute
    FNB WaitNotVisible Menu Loading Icon    wait_time_out=1 minute

Go To Them Moi Doi Tac Giao Hang
    [Timeout]
    FNB DTGH Header Button Them Moi DoiTac    is_wait_visible=True
    FNB WaitVisible DTGH AddDTGH Title Them DoiTac
