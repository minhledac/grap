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
FNB AND GetLocator BCHH Loc Title Bao Cao HangHoa
    ${locator}    Set Variable    //android.widget.TextView[@text='{0}']
    ${lang_str}    KV Get Language Text    Báo cáo hàng hóa    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND GetLocator BCHH Icon Next Detail Bao Cao
    ${locator}    Set Variable    id=net.citigo.kiotviet.fnb.manager:id/imv_show_more_profit
    [Return]    ${locator}

FNB AND BCHH Icon Next Detail Bao Cao
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator BCHH Icon Next Detail Bao Cao
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator BCHH Text Filter Theo Doanh Thu - Loi Nhuan
    ${locator}    Set Variable    id=net.citigo.kiotviet.fnb.manager:id/tv_top_profit_filter
    [Return]    ${locator}

FNB AND GetLocator BCHH Icon Switch Theo Doanh Thu Va Loi Nhuan
    ${locator}    Set Variable    id=net.citigo.kiotviet.fnb.manager:id/img_top_profit_filter
    [Return]    ${locator}

FNB AND BCHH Icon Switch Theo Doanh Thu Va Loi Nhuan
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator BCHH Icon Switch Theo Doanh Thu Va Loi Nhuan
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator BCHH List Hang Theo Doanh Thu
    ${locator}    Set Variable    //android.view.ViewGroup[./android.widget.TextView[@text='{0}']]/following-sibling::androidx.recyclerview.widget.RecyclerView//android.widget.TextView[1]
    ${lang_str}    KV Get Language Text    theo doanh thu    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND GetLocator BCHH List Gia Tri Theo Doanh Thu
    ${locator}    Set Variable    //android.view.ViewGroup[./android.widget.TextView[@text='{0}']]/following-sibling::androidx.recyclerview.widget.RecyclerView//android.widget.TextView[2]
    ${lang_str}    KV Get Language Text    theo doanh thu    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND GetLocator BCHH List Hang Theo Loi Nhuan
    ${locator}    Set Variable    //android.view.ViewGroup[./android.widget.TextView[@text='{0}']]/following-sibling::androidx.recyclerview.widget.RecyclerView//android.widget.TextView[1]
    ${lang_str}    KV Get Language Text    theo lợi nhuận    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND GetLocator BCHH List Gia Tri Theo Loi Nhuan
    ${locator}    Set Variable    //android.view.ViewGroup[./android.widget.TextView[@text='{0}']]/following-sibling::androidx.recyclerview.widget.RecyclerView//android.widget.TextView[2]
    ${lang_str}    KV Get Language Text    theo lợi nhuận    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND WaitVisible BCHH Title Ton Kho
    [Arguments]    ${wait_time_out}=20s
    ${locator}    Set Variable    //*[contains(@text,'{0}')]
    ${lang_str}    KV Get Language Text    Tồn kho    None
    ${locator}    Format String    ${locator}    ${lang_str}
    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}

FNB AND WaitNotVisible BCHH Title Ton Kho
    [Arguments]    ${wait_time_out}=20s    ${visible_time_out}=0.5
    ${locator}    Set Variable    //*[contains(@text,'{0}')]
    ${lang_str}    KV Get Language Text    Tồn kho    None
    ${locator}    Format String    ${locator}    ${lang_str}
    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    timeout=${visible_time_out}
    Wait Until Page Does Not Contain Element    ${locator}    timeout=${wait_time_out}

FNB AND GetLocator BCHH Tong Ton Cuoi Ky
    ${locator}    Set Variable    //*[contains(@text,'{0}')]/following-sibling::android.widget.TextView
    ${lang_str}    KV Get Language Text    Tồn kho    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND GetLocator BCHH Tong Hang Cuoi Ky
    ${locator}    Set Variable    //*[contains(@text,'{0}')]/following-sibling::android.widget.TextView[2]
    ${lang_str}    KV Get Language Text    Tồn kho    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND WaitVisible BCHH Title San Pham
    [Arguments]    ${wait_time_out}=20s
    ${locator}    Set Variable    //*[contains(@text,'{0}')]
    ${lang_str}    KV Get Language Text    sản phẩm    None
    ${locator}    Format String    ${locator}    ${lang_str}
    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}

FNB AND WaitNotVisible BCHH Title San Pham
    [Arguments]    ${wait_time_out}=20s    ${visible_time_out}=0.5
    ${locator}    Set Variable    //*[contains(@text,'{0}')]
    ${lang_str}    KV Get Language Text    sản phẩm    None
    ${locator}    Format String    ${locator}    ${lang_str}
    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    timeout=${visible_time_out}
    Wait Until Page Does Not Contain Element    ${locator}    timeout=${wait_time_out}

FNB AND GetLocator BCHH List Hang Theo Gia Tri Kho
    ${locator}    Set Variable    //android.view.ViewGroup[./android.widget.TextView[@text='{0}']]/following-sibling::androidx.recyclerview.widget.RecyclerView//android.widget.TextView[1]
    ${lang_str}    KV Get Language Text    theo giá trị kho    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND GetLocator BCHH List Gia Tri Theo Gia Tri Kho
    ${locator}    Set Variable    //android.view.ViewGroup[./android.widget.TextView[@text='{0}']]/following-sibling::androidx.recyclerview.widget.RecyclerView//android.widget.TextView[2]
    ${lang_str}    KV Get Language Text    theo giá trị kho    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND GetLocator BCHH Icon Next Detail TopHang TheoDoanhThu
    ${locator}    Set Variable    //android.view.ViewGroup[./android.widget.TextView[@text='{0}']]/android.widget.ImageView[2]
    ${lang_str}    KV Get Language Text    theo doanh thu    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND BCHH Icon Next Detail TopHang TheoDoanhThu
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator BCHH Icon Next Detail TopHang TheoDoanhThu
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator BCHH Icon Next Detail TopHang TheoGiaTriKho
    ${locator}    Set Variable    //android.view.ViewGroup[./android.widget.TextView[@text='{0}']]/android.widget.ImageView[2]
    ${lang_str}    KV Get Language Text    theo giá trị kho    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND BCHH Icon Next Detail TopHang TheoGiaTriKho
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator BCHH Icon Next Detail TopHang TheoGiaTriKho
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator BCHH List Hang Detail Theo Doanh Thu
    ${locator}    Set Variable    //androidx.recyclerview.widget.RecyclerView//android.view.ViewGroup//android.widget.TextView[1]
    [Return]    ${locator}

FNB AND GetLocator BCHH List Gia Tri Detail Theo Doanh Thu
    ${locator}    Set Variable    //androidx.recyclerview.widget.RecyclerView//android.view.ViewGroup//android.widget.TextView[2]
    [Return]    ${locator}

FNB AND GetLocator BCHH Icon Back List Hang Theo Doanh Thu
    ${locator}    Set Variable    //android.widget.ImageButton
    [Return]    ${locator}

FNB AND BCHH Icon Back List Hang Theo Doanh Thu
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator BCHH Icon Back List Hang Theo Doanh Thu
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator BCHH List Hang Detail Theo Gia Tri Kho
    ${locator}    Set Variable    //androidx.recyclerview.widget.RecyclerView//android.view.ViewGroup//android.widget.TextView[1]
    [Return]    ${locator}

FNB AND GetLocator BCHH List Gia Tri Detail Theo Gia Tri Kho
    ${locator}    Set Variable    //androidx.recyclerview.widget.RecyclerView//android.view.ViewGroup//android.widget.TextView[2]
    [Return]    ${locator}

FNB AND GetLocator BCHH Icon Back List Hang Theo Gia Tri Kho
    ${locator}    Set Variable    //android.widget.ImageButton
    [Return]    ${locator}

FNB AND BCHH Icon Back List Hang Theo Gia Tri Kho
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator BCHH Icon Back List Hang Theo Gia Tri Kho
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator BCHH Icon Chon Chi Nhanh
    ${locator}    Set Variable    id=net.citigo.kiotviet.fnb.manager:id/imv_action_branches_filter
    [Return]    ${locator}

FNB AND BCHH Icon Chon Chi Nhanh
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator BCHH Icon Chon Chi Nhanh
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator BCHH Icon Chon Tat Ca Chi Nhanh
    ${locator}    Set Variable    //* [contains(@text,'{0}')]/following-sibling::android.widget.CheckBox[@checked='false']
    ${lang_str}    KV Get Language Text    Tất cả chi nhánh    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND BCHH Icon Chon Tat Ca Chi Nhanh
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator BCHH Icon Chon Tat Ca Chi Nhanh
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator BCHH Cell Item Chon Chi Nhanh
    [Arguments]    ${ten_chi_nhanh}
    ${locator}    Set Variable    //*[contains(@text,'{0}')]
    ${locator}    Format String    ${locator}    ${ten_chi_nhanh}
    [Return]    ${locator}

FNB AND BCHH Cell Item Chon Chi Nhanh
    [Arguments]    ${ten_chi_nhanh}    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator BCHH Cell Item Chon Chi Nhanh    ${ten_chi_nhanh}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator BCHH Icon Ap Dung Chi Nhanh
    ${locator}    Set Variable    id=net.citigo.kiotviet.fnb.manager:id/action_apply
    [Return]    ${locator}

FNB AND BCHH Icon Ap Dung Chi Nhanh
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator BCHH Icon Ap Dung Chi Nhanh
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator BCHH Dropdown Loc ThoiGian
    ${locator}    Set Variable    id=net.citigo.kiotviet.fnb.manager:id/tv_time_range
    [Return]    ${locator}

FNB AND BCHH Dropdown Loc ThoiGian
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator BCHH Dropdown Loc ThoiGian
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator BCHH Cell Item Loc ThoiGian
    [Arguments]    ${thoi_gian}
    ${locator}    Set Variable    //*[contains(@text,'{0}')]
    ${locator}    Format String    ${locator}    ${thoi_gian}
    [Return]    ${locator}

FNB AND BCHH Cell Item Loc ThoiGian
    [Arguments]    ${thoi_gian}    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator BCHH Cell Item Loc ThoiGian    ${thoi_gian}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator BCHH Icon Filter
    ${locator}    Set Variable    id=net.citigo.kiotviet.fnb.manager:id/imv_filter_advanced
    [Return]    ${locator}

FNB AND BCHH Icon Filter
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator BCHH Icon Filter
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator BCHH Texbox Loc Theo Ten Hoac Ma Hang
    ${locator}    Set Variable    class=android.widget.EditText
    [Return]    ${locator}

FNB AND BCHH Texbox Loc Theo Ten Hoac Ma Hang
    [Arguments]    ${text}    ${is_clear_text}=True    ${is_wait_visible}=True    ${wait_time_out}=${20}
    ${locator}    FNB AND GetLocator BCHH Texbox Loc Theo Ten Hoac Ma Hang
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Input Text   ${locator}    ${text}    ${is_clear_text}

FNB AND GetLocator BCHH Button Ap Dung
    ${locator}    Set Variable    net.citigo.kiotviet.fnb.manager:id/tv_search_apply
    [Return]    ${locator}

FNB AND BCHH Button Ap Dung
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator BCHH Button Ap Dung
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}