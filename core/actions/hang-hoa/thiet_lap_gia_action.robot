*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Library           BuiltIn
Resource          ../../share/constants.robot
Resource          ../../_common_keywords/common_pricebook_screen.robot
Resource          ../../_common_keywords/common_menu_screen.robot
Resource          ../../share/computation.robot
Resource          ../../share/toast_message.robot

*** Keywords ***
Select bang gia
    [Arguments]   ${ten_BG}
    ${cel_item_BG}    FNB GetLocator TLG Sidebar Cell Item BangGia    ${ten_BG}
    FNB TLG Sidebar Dropdown DanhSach BangGia    ${cel_item_BG}    True

Remove list product in pricebook
    [Arguments]
    Run Keyword And Return Status    FNB TLG ListHH Button Xoa HH TheoTrang
    Run Keyword And Return Status    FNB TLG ListHH Button Xoa HH TheoTrang
    Run Keyword And Return Status    FNB TLG ListHH Button Xoa HH TheoTrang

    FNB WaitVisible TLG ListHH Title Popup Xoa HangHoa
    FNB TLG ListHH Button DongY Xoa HangHoa    True
    Delete data success validation
    FNB WaitNotVisible Menu Loading Icon

Remove product in pricebook
    [Arguments]    ${ma_hh}    ${is_delete}=True
    # 4. Nhập mã HH vào ô searchbox -> Enter
    FNB TLG Sidebar Textbox Search HH    ${ma_hh}
    FNB WaitNotVisible Menu Loading Icon
    # 5. Click icon [x] cạnh mã HH
    Run Keyword And Return Status    FNB TLG ListHH Button Xoa HH Trong BangGia    ${ma_hh}    True
    Run Keyword And Return Status    FNB TLG ListHH Button Xoa HH Trong BangGia    ${ma_hh}    True
    Run Keyword And Return Status    FNB TLG ListHH Button Xoa HH Trong BangGia    ${ma_hh}    True

    FNB WaitVisible TLG ListHH Title Popup Xoa HangHoa
    # 6. Click button [Đồng ý]
    Run Keyword If    '${is_delete}'=='True'    Dong y xoa hang hoa va assert toast message

Dong y xoa hang hoa va assert toast message
    [Arguments]
    FNB TLG ListHH Button DongY Xoa HangHoa    True
    Delete data success validation
    FNB WaitNotVisible Menu Loading Icon

Add list hang hoa vao Bang gia
    [Arguments]   ${list_HH}
    FOR    ${item_HH}   IN    @{list_HH}
        FNB TLG ListHH Textbox Search HH BangGia    ${item_HH}    is_autocomplete=True
    END

Input thay doi gia cho danh sach hang hoa
    [Arguments]   ${compare_name}   ${discount}
    Set Selenium Speed    0.6
    ${textbox_gia_moi_1}    FNB GetLocator TLG ListHH Textbox GiaMoi DauTien
    ${checkbox_apdung_CT}   FNB GetLocator TLG ListHH Checkbox ApDung CongThuc
    Wait Until Element Is Visible    ${textbox_gia_moi_1}
    Set Focus To Element    ${textbox_gia_moi_1}
    FNB WaitVisible TLG ListHH Popup Title
    # 4. Chọn các giá trị (*) để hoàn thành công thức tính giá mới
    ${cell_item_loai_gia}   FNB GetLocator TLG ListHH Cell Item Chon Loai Gia    ${compare_name}
    FNB TLG ListHH Dropdown Chon Loai Gia    ${cell_item_loai_gia}
    Check and input data of product in pop-up    ${discount}
    # 5. Tích chọn checkbox áp dụng công thức cho các sản phẩm trong bảng giá
    Click Element    ${checkbox_apdung_CT}
    Sleep    1s
    Set Selenium Speed    ${SELENIUM_SPEED}

Check and input data of product in pop-up
    [Arguments]    ${input_discount}
    [Timeout]    1 minute
    Run Keyword If    0<${input_discount}<=100    Input product - price plus - % in popup    ${input_discount}
    ...    ELSE IF    ${input_discount}>100    Input product - price plus - VND in popup    ${input_discount}
    ...    ELSE IF    -100<=${input_discount}<0    Input product discount - % in popup    ${input_discount}
    ...    ELSE IF    ${input_discount}<-100    Input product discount - VND in popup    ${input_discount}

Get key by compare name
    [Arguments]    ${input_comparename}
    ${compare_key}=    Set Variable If    '${input_comparename}' == 'Giá chung'    BasePrice    '${input_comparename}' == 'Giá vốn'    Cost    '${input_comparename}' == 'Giá hiện tại'
    ...    Price    '${input_comparename}' == 'Giá nhập lần cuối'    LatestPurchasePrice
    Return From Keyword    ${compare_key}

Input product discount - VND in popup
    [Arguments]    ${input_discount}
    [Timeout]    2 minutes
    ${discount}    Replace String    ${input_discount}    -    ${EMPTY}
    #${discount_value}    Convert To Number    ${discount}
    FNB TLG ListHH Button Minus    is_wait_visible=True
    FNB TLG ListHH Button Vnd    is_wait_visible=True
    FNB TLG ListHH Textbox GiaTri Gia    ${discount}

Input product discount - % in popup
    [Arguments]    ${input_discount}
    [Timeout]    2 minutes
    ${discount}    Replace String    ${input_discount}    -    ${EMPTY}
    #${discount_value}    Convert To Number    ${discount}
    FNB TLG ListHH Button Minus    is_wait_visible=True
    FNB TLG ListHH Button PhanTram    is_wait_visible=True
    FNB TLG ListHH Textbox GiaTri Gia    ${discount}

Input product - price plus - VND in popup
    [Arguments]    ${input_discount}
    [Timeout]    2 minutes
    FNB TLG ListHH Button Plus    is_wait_visible=True
    FNB TLG ListHH Button Vnd    is_wait_visible=True
    FNB TLG ListHH Textbox GiaTri Gia    ${input_discount}

Input product - price plus - % in popup
    [Arguments]    ${input_discount}
    [Timeout]    2 minutes
    FNB TLG ListHH Button Plus    is_wait_visible=True
    FNB TLG ListHH Button PhanTram    is_wait_visible=True
    FNB TLG ListHH Textbox GiaTri Gia    ${input_discount}

Lay danh sach ma hang chua co trong bang gia
    [Arguments]   ${list_ma_hh_inBG}    ${input_list_ma_hh}
    ${list_ma_hh_new}   Create List
    FOR    ${item_input_ma_hh}    IN    @{input_list_ma_hh}
        ${status}=   Run Keyword And Return Status    List Should Not Contain Value    ${list_ma_hh_inBG}    ${item_input_ma_hh}
        Run Keyword If    '${status}'=='True'    Append To List    ${list_ma_hh_new}    ${item_input_ma_hh}
    END
    Return From Keyword    ${list_ma_hh_new}

Chon nhom hang vao bang gia
    [Arguments]   ${ten_nhom_hang}
    FNB TLG Sidebar Textbox Timkiem NhomHang    ${ten_nhom_hang}
    ${locator_cell_item_nhomhang}   FNB GetLocator TLG Sidebar Cell Item NhomHang    ${ten_nhom_hang}
    Mouse Over    ${locator_cell_item_nhomhang}
    FNB TLG Sidebar Icon Them NhomHang VaoBG    ${ten_nhom_hang}    True
    Update data success validation

Get thong tin danh sach hang hoa cua nhom hang trong BG tren UI
    ${list_ma_hh_ui}     Create List
    ${list_gia_von_ui}   Create List
    ${list_gia_ban_ui}   Create List
    FOR    ${index}    IN RANGE    1    16
        ${loc_ma_hh}    FNB GetLocator TLG ListHH Ma HH By Index    ${index}
        ${is_exist}   Run Keyword And Return Status    Page Should Contain Element    ${loc_ma_hh}
        Exit For Loop If    '${is_exist}'=='False'
        ${loc_gia_von}    FNB GetLocator TLG ListHH Gia Von HH By Index    ${index}
        ${loc_gia_ban}    FNB GetLocator TLG ListHH Gia Ban HH By Index    ${index}
        ${text_ma_hh}     Get Text    ${loc_ma_hh}
        ${text_gia_von}   Convert text to number frm locator    ${loc_gia_von}
        ${text_gia_ban}   Get Element Attribute    ${loc_gia_ban}    innerHTML
        ${text_gia_ban}    Replace String    ${text_gia_ban}    ,    ${EMPTY}
        ${text_gia_ban}   Convert To Number    ${text_gia_ban}
        Append To List    ${list_ma_hh_ui}      ${text_ma_hh}
        Append To List    ${list_gia_von_ui}    ${text_gia_von}
        Append To List    ${list_gia_ban_ui}    ${text_gia_ban}
    END
    Return From Keyword    ${list_ma_hh_ui}    ${list_gia_von_ui}    ${list_gia_ban_ui}

#
