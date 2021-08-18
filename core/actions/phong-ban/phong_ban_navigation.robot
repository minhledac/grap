*** Settings ***
Library           SeleniumLibrary
Resource          ../../_common_keywords/common_menu_screen.robot
Resource          ../../_common_keywords/common_tableroom_screen.robot

*** Keywords ***
Go To Phong Ban
    [Timeout]
    FNB Menu PhongBan    is_wait_visible=True    wait_time_out=30
    FNB WaitVisible PB Title Phong Ban    wait_time_out=1 minute

Go to Them moi Phong Ban
    [Timeout]
    FNB PB Header Button Them Moi PhongBan    is_wait_visible=True
    FNB WaitVisible PB AddPB Title Them PhongBan    wait_time_out=1 minute
