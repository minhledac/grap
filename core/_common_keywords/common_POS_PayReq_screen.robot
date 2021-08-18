*** Settings ***
Documentation     A resource file with reusable keywords and variables.
...
...               ====================================================
...               Generated by update_common_keyworks.py - DO NOT EDIT
...               ====================================================
...
Library           AppiumLibrary
Resource          ../../core/share/utils.robot

*** Keywords ***
FNB AND WaitVisible Payment Request Header Title
    [Arguments]    ${wait_time_out}=20s
    ${locator}    Set Variable    //android.widget.TextView[@text='{0}']
    ${lang_str}    KV Get Language Text    Yêu cầu thanh toán    None
    ${locator}    Format String    ${locator}    ${lang_str}
    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}

FNB AND WaitNotVisible Payment Request Header Title
    [Arguments]    ${wait_time_out}=20s    ${visible_time_out}=0.5
    ${locator}    Set Variable    //android.widget.TextView[@text='{0}']
    ${lang_str}    KV Get Language Text    Yêu cầu thanh toán    None
    ${locator}    Format String    ${locator}    ${lang_str}
    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    timeout=${visible_time_out}
    Wait Until Page Does Not Contain Element    ${locator}    timeout=${wait_time_out}

FNB AND GetLocator Payment Request Summary Text
    ${locator}    Set Variable    id=net.citigo.kiotviet.pos.fnb:id/textTitle
    [Return]    ${locator}

FNB AND GetLocator Payment Request Noti Message
    [Arguments]    ${index}
    ${locator}    Set Variable    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[{0}]/android.widget.TextView[1]
    ${locator}    Format String    ${locator}    ${index}
    [Return]    ${locator}

FNB AND Payment Request Noti Message
    [Arguments]    ${index}    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator Payment Request Noti Message    ${index}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}