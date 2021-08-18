*** Settings ***
Library           SeleniumLibrary
Resource          ../../_common_keywords/common_menu_screen.robot
Resource          ../../_common_keywords/common_cashFlow_screen.robot

*** Keywords ***
Go To So Quy
    FNB Menu SoQuy
    FNB WaitNotVisible Menu Loading Icon    wait_time_out=1 minute
    FNB WaitVisible SQ Title So Quy Tien Mat    wait_time_out=1 minute

Go to Them Moi Phieu Thu Tien Mat
    FNB SQ Sidebar Tab Tien Mat
    FNB SQ Header Button Lap Phieu Thu
    FNB WaitVisible SQ Add Title Lap Phieu Thu Tien Mat

Go to Them Moi Phieu Chi Tien Mat
    FNB SQ Sidebar Tab Tien Mat
    FNB SQ Header Button Lap Phieu Chi
    FNB WaitVisible SQ Add Title Lap Phieu Chi Tien Mat

Go to Them Moi Phieu Thu Ngan Hang
    FNB SQ Sidebar Tab Ngan Hang
    FNB SQ Header Button Lap Phieu Thu
    FNB WaitVisible SQ Add Title Lap Phieu Thu Ngan Hang

Go to Them Moi Phieu Chi Ngan Hang
    FNB SQ Sidebar Tab Ngan Hang
    FNB SQ Header Button Lap Phieu Chi
    FNB WaitVisible SQ Add Title Lap Phieu Chi Ngan Hang
