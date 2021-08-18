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
FNB AND WaitVisible HD Header Title Hoa Don
    [Arguments]    ${wait_time_out}=20s
    ${locator}    Set Variable    //section[contains(@class,'mainRight')]//h1//span[text()='{0}']
    ${lang_str}    KV Get Language Text    Hóa đơn    None
    ${locator}    Format String    ${locator}    ${lang_str}
    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}

FNB AND WaitNotVisible HD Header Title Hoa Don
    [Arguments]    ${wait_time_out}=20s    ${visible_time_out}=0.5
    ${locator}    Set Variable    //section[contains(@class,'mainRight')]//h1//span[text()='{0}']
    ${lang_str}    KV Get Language Text    Hóa đơn    None
    ${locator}    Format String    ${locator}    ${lang_str}
    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    timeout=${visible_time_out}
    Wait Until Page Does Not Contain Element    ${locator}    timeout=${wait_time_out}

FNB AND GetLocator HD Sidebar Textbox Search Ma PhieuNhap
    ${locator}    Set Variable    //article[contains(@class,'boxLeft')]//input[contains(@placeholder,'{0}')]
    ${lang_str}    KV Get Language Text    Theo mã hóa đơn    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD Sidebar Textbox Search Ma PhieuNhap
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD Sidebar Textbox Search Ma PhieuNhap
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD Sidebar Textbox Search Ma Ten HangHoa
    ${locator}    Set Variable    //article[contains(@class,'boxLeft')]//input[contains(@placeholder,'{0}')]
    ${lang_str}    KV Get Language Text    Theo mã, tên hàng    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD Sidebar Textbox Search Ma Ten HangHoa
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD Sidebar Textbox Search Ma Ten HangHoa
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD Header Button Tao HoaDon
    ${locator}    Set Variable    //article[contains(@class,'headerContent')]//a[./span[contains(text(),'{0}')]]
    ${lang_str}    KV Get Language Text    Nhận gọi món    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD Header Button Tao HoaDon
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD Header Button Tao HoaDon
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD Header Button XuatFile
    ${locator}    Set Variable    //div[contains(@class,'addProductBtn')]/a[./span[contains(text(),'file')]]
    ${lang_str}    KV Get Language Text    file    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD Header Button XuatFile
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD Header Button XuatFile
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD Header Button XuatFile TongQuan
    ${locator}    Set Variable    //article[contains(@class,'headerContent ')]//div[contains(@class,'addProductBtn')]//ul/li[1]/a
    [Return]    ${locator}

FNB AND HD Header Button XuatFile TongQuan
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD Header Button XuatFile TongQuan
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD Header Button XuatFile ChiTiet
    ${locator}    Set Variable    //article[contains(@class,'headerContent ')]//div[contains(@class,'addProductBtn')]//ul/li[2]/a
    [Return]    ${locator}

FNB AND HD Header Button XuatFile ChiTiet
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD Header Button XuatFile ChiTiet
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD Header Text Tong Tat Ca Tien Hang
    ${locator}    Set Variable    //table//tr[contains(@class,'cssSummaryRow')]/td[contains(@class,'invoiceSummarySubTotal')]
    [Return]    ${locator}

FNB AND GetLocator HD Header Text Tong Tat Ca Giam Gia
    ${locator}    Set Variable    //table//tr[contains(@class,'cssSummaryRow')]/td[contains(@class,'invoiceSummaryDiscount')]
    [Return]    ${locator}

FNB AND GetLocator HD Header Text Tong Tat Ca Sau GG
    ${locator}    Set Variable    //table//tr[contains(@class,'cssSummaryRow')]/td[contains(@class,'invoiceSummaryTotalAfterDiscount')]
    [Return]    ${locator}

FNB AND GetLocator HD Header Text Tong Tat Ca Khach Da Tra
    ${locator}    Set Variable    //table//tr[contains(@class,'cssSummaryRow')]/td[contains(@class,'invoiceSummaryTotalPayment')]
    [Return]    ${locator}

FNB AND GetLocator HD Header Text Tong Tat Ca Thu Khac
    ${locator}    Set Variable    //table//tr[contains(@class,'cssSummaryRow')]/td[contains(@class,'invoiceSummarySurcharge')]
    [Return]    ${locator}

FNB AND GetLocator HD Header Text Tong Tat Ca Khach Can Tra
    ${locator}    Set Variable    //table//tr[contains(@class,'cssSummaryRow')]/td[contains(@class,'invoiceSummaryTotal')][2]
    [Return]    ${locator}

FNB AND GetLocator HD Header Text Tong Tat Ca Can Thu Ho
    ${locator}    Set Variable    //table//tr[contains(@class,'cssSummaryRow')]/td[contains(@class,'invoiceSummaryCodNeedPayment')]
    [Return]    ${locator}

FNB AND GetLocator HD Header Text Tong Tat Ca Phi Tra ĐTGH
    ${locator}    Set Variable    //table//tr[contains(@class,'cssSummaryRow')]/td[contains(@class,'invoiceSummaryInvoiceDeliveryPrice')]
    [Return]    ${locator}

FNB AND GetLocator HD Header Icon Menu Hien Thi Cac Truong
    ${locator}    Set Variable    //div[contains(@class,'columnView')]/li[1]
    [Return]    ${locator}

FNB AND HD Header Icon Menu Hien Thi Cac Truong
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD Header Icon Menu Hien Thi Cac Truong
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD Header Column Thu Khac
    ${locator}    Set Variable    //label[contains(text(),'{0}')]
    ${lang_str}    KV Get Language Text    Thu khác    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD Header Column Thu Khac
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD Header Column Thu Khac
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD Header Column Can Thu Ho
    ${locator}    Set Variable    //label[contains(text(),'{0}')]
    ${lang_str}    KV Get Language Text    Còn cần thu (COD)    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD Header Column Can Thu Ho
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD Header Column Can Thu Ho
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD Header Column Khach Can Tra
    ${locator}    Set Variable    //label[contains(text(),'{0}')]
    ${lang_str}    KV Get Language Text    Khách cần trả    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD Header Column Khach Can Tra
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD Header Column Khach Can Tra
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD Header Column Phi Tra DTGH
    ${locator}    Set Variable    //label[contains(text(),'{0}')]
    ${lang_str}    KV Get Language Text    Phí trả ĐTGH    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD Header Column Phi Tra DTGH
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD Header Column Phi Tra DTGH
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD Header Column So Dien Thoai
    ${locator}    Set Variable    //label[contains(text(),'{0}')]
    ${lang_str}    KV Get Language Text    Số điện thoại    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD Header Column So Dien Thoai
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD Header Column So Dien Thoai
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD Header Text Tong Tien Hang
    ${locator}    Set Variable    //table//tr[not(contains(@class,'cssSummaryRow'))]/td[contains(@class,'invoiceSummarySubTotal')]
    [Return]    ${locator}

FNB AND GetLocator HD Header Text Tong Giam Gia
    ${locator}    Set Variable    //table//tr[not(contains(@class,'cssSummaryRow'))]/td[contains(@class,'invoiceSummaryDiscount')]
    [Return]    ${locator}

FNB AND GetLocator HD Header Text Tong Sau GG
    ${locator}    Set Variable    //table//tr[not(contains(@class,'cssSummaryRow'))]/td[contains(@class,'invoiceSummaryTotalAfterDiscount')]
    [Return]    ${locator}

FNB AND GetLocator HD Header Text Tong Khach Da Tra
    ${locator}    Set Variable    //table//tr[not(contains(@class,'cssSummaryRow'))]/td[contains(@class,'invoiceSummaryTotalPayment')]
    [Return]    ${locator}

FNB AND GetLocator HD Header Text Tong Thu Khac
    ${locator}    Set Variable    //table//tr[not(contains(@class,'cssSummaryRow'))]/td[contains(@class,'invoiceSummarySurcharge')]
    [Return]    ${locator}

FNB AND GetLocator HD Header Text Tong Khach Can Tra
    ${locator}    Set Variable    //table//tr[not(contains(@class,'cssSummaryRow'))]/td[contains(@class,'invoiceSummaryTotal')][2]
    [Return]    ${locator}

FNB AND GetLocator HD Header Text Tong Can Thu Ho
    ${locator}    Set Variable    //table//tr[not(contains(@class,'cssSummaryRow'))]/td[contains(@class,'invoiceSummaryCodNeedPayment')]
    [Return]    ${locator}

FNB AND GetLocator HD Header Text Tong Phi Tra ĐTGH
    ${locator}    Set Variable    //table//tr[not(contains(@class,'cssSummaryRow'))]/td[contains(@class,'invoiceSummaryInvoiceDeliveryPrice')]
    [Return]    ${locator}

FNB AND GetLocator HD List Text Ma Hoa Don
    [Arguments]    ${Code_hoa_don}
    ${locator}    Set Variable    //span[contains(text(),'{0}')]
    ${locator}    Format String    ${locator}    ${Code_hoa_don}
    [Return]    ${locator}

FNB AND HD List Text Ma Hoa Don
    [Arguments]    ${Code_hoa_don}    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Text Ma Hoa Don    ${Code_hoa_don}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD List Textbox GioDen HoaDon
    ${locator}    Set Variable    //table[not(contains(@style,'display: none'))]//div[contains(@ng-show,'isBarCafe')]//input[contains(@data-role,'datetimepicker')]
    [Return]    ${locator}

FNB AND HD List Textbox GioDen HoaDon
    [Arguments]    ${text}    ${is_clear_text}=True    ${is_wait_visible}=True    ${wait_time_out}=${20}
    ${locator}    FNB AND GetLocator HD List Textbox GioDen HoaDon
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Input Text   ${locator}    ${text}    ${is_clear_text}

FNB AND GetLocator HD List Dropdown List PhongBan
    ${locator}    Set Variable    //table[not(contains(@style,'display: none'))]//label[text()='{0}']//../div/span//span[contains(@class,'k-input')]
    ${lang_str}    KV Get Language Text    Phòng/Bàn:    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD List Dropdown List PhongBan
    [Arguments]    ${cell_locator}    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Dropdown List PhongBan
    KV Select Cell in Dropdown    ${locator}    ${cell_locator}    ${is_wait_visible}    ${wait_time_out}

FNB AND GetLocator HD List Dropdown List NguoiNhanDon
    ${locator}    Set Variable    //table[not(contains(@style,'display: none'))]//label[text()='{0}']//../div/span//span[contains(@class,'k-input')]
    ${lang_str}    KV Get Language Text    Người nhận đơn:    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD List Dropdown List NguoiNhanDon
    [Arguments]    ${cell_locator}    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Dropdown List NguoiNhanDon
    KV Select Cell in Dropdown    ${locator}    ${cell_locator}    ${is_wait_visible}    ${wait_time_out}

FNB AND GetLocator HD List Dropdown List KenhBan
    ${locator}    Set Variable    //table[not(contains(@style,'display: none'))]//label[text()='{0}']//../div/span//span[contains(@class,'k-input')]
    ${lang_str}    KV Get Language Text    Kênh bán:    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD List Dropdown List KenhBan
    [Arguments]    ${cell_locator}    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Dropdown List KenhBan
    KV Select Cell in Dropdown    ${locator}    ${cell_locator}    ${is_wait_visible}    ${wait_time_out}

FNB AND GetLocator HD List Textbox SoKhach HoaDon
    ${locator}    Set Variable    //table[not(contains(@style,'display: none'))]//label[text()='{0}']//../div/input[@type='text']
    ${lang_str}    KV Get Language Text    Số khách:    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD List Textbox SoKhach HoaDon
    [Arguments]    ${text}    ${is_clear_text}=True    ${is_wait_visible}=True    ${wait_time_out}=${20}
    ${locator}    FNB AND GetLocator HD List Textbox SoKhach HoaDon
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Input Text   ${locator}    ${text}    ${is_clear_text}

FNB AND GetLocator HD List Textarea GhiChu
    ${locator}    Set Variable    //table[not(contains(@style,'display: none'))]//invoice-form//textarea[contains(@placeholder,'{0}')]
    ${lang_str}    KV Get Language Text    Ghi chú...    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD List Textarea GhiChu
    [Arguments]    ${text}    ${is_clear_text}=True    ${is_wait_visible}=True    ${wait_time_out}=${20}
    ${locator}    FNB AND GetLocator HD List Textarea GhiChu
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Input Text   ${locator}    ${text}    ${is_clear_text}

FNB AND GetLocator HD List Button Luu HoaDon
    ${locator}    Set Variable    //table[not(contains(@style,'display: none'))]//invoice-form//div[contains(@class,'kv-window-footer')]//a[contains(text(),'{0}')]
    ${lang_str}    KV Get Language Text    Lưu    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD List Button Luu HoaDon
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Button Luu HoaDon
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD List Button In
    ${locator}    Set Variable    //table[not(contains(@style,'display: none'))]//invoice-form//div[contains(@class,'kv-window-footer')]//a[contains(text(),'{0}')]
    ${lang_str}    KV Get Language Text    In    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD List Button In
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Button In
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD List Button XuatFile HoaDon
    ${locator}    Set Variable    //table[not(contains(@style,'display: none'))]//invoice-form//div[contains(@class,'kv-window-footer')]//a[contains(text(),'{0}')]
    ${lang_str}    KV Get Language Text    Xuất${SPACE}${SPACE}file    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD List Button XuatFile HoaDon
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Button XuatFile HoaDon
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD List Button SaoChep HoaDon
    ${locator}    Set Variable    //table[not(contains(@style,'display: none'))]//invoice-form//div[contains(@class,'kv-window-footer')]//a[contains(text(),'{0}')]
    ${lang_str}    KV Get Language Text    Sao chép    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD List Button SaoChep HoaDon
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Button SaoChep HoaDon
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD List Button HuyBo HoaDon
    ${locator}    Set Variable    //table[not(contains(@style,'display: none'))]//invoice-form//div[contains(@class,'kv-window-footer')]//a[contains(text(),'{0}')]
    ${lang_str}    KV Get Language Text    Hủy bỏ    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD List Button HuyBo HoaDon
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Button HuyBo HoaDon
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD List Thanh Scroll Ngang
    ${locator}    Set Variable    //div[@id='grdInvoices']/div[contains(@class,'k-grid-content k-auto-scrollable')]
    [Return]    ${locator}

FNB AND GetLocator HD List Text SDT Khach Hang
    [Arguments]    ${ma_hoadon}
    ${locator}    Set Variable    //span[contains(text(),'{0}')]/../parent::tr//td[@class='cell-phone']/span
    ${locator}    Format String    ${locator}    ${ma_hoadon}
    [Return]    ${locator}

FNB AND GetLocator Chi Tiet HD Gia Tri Tong Tien Hang
    ${locator}    Set Variable    //td[contains(text(),'{0}')]/following::td[1]
    ${lang_str}    KV Get Language Text    Tổng tiền hàng    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND GetLocator Chi Tiet HD Gia Tri Thu Khac
    [Arguments]    ${thu_khac}
    ${locator}    Set Variable    //td[contains(text(),'{0}')]/following::td[1]
    ${locator}    Format String    ${locator}    ${thu_khac}
    [Return]    ${locator}

FNB AND GetLocator Chi Tiet HD Gia Tri Khach Can Tra
    ${locator}    Set Variable    //td[contains(text(),'{0}')]/following::td[1]
    ${lang_str}    KV Get Language Text    Khách cần trả    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND GetLocator Chi Tiet HD Gia Tri Khach Da Tra
    ${locator}    Set Variable    //td[contains(text(),'{0}')]/following::td[1]
    ${lang_str}    KV Get Language Text    Khách đã trả    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND GetLocator Chi Tiet HD Gia Tri Giam Gia HD
    ${locator}    Set Variable    //td[contains(text(),'{0}')]/following::td[1]
    ${lang_str}    KV Get Language Text    Giảm giá hóa đơn    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND GetLocator Chi Tiet HD Gia Tri Con Can Thu
    ${locator}    Set Variable    //invoice-form/div/div[2]/div[3]/div[3]/div[8]/div/span
    ${lang_str}    KV Get Language Text    Còn cần thu (COD)    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND GetLocator Chi Tiet HD Gia Tri Da Thu
    ${locator}    Set Variable    //label[contains(text(),'{0}')]/following::div[1]/span
    ${lang_str}    KV Get Language Text    Đã thu    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND GetLocator Chi Tiet HD Gia Tri Phi Giao Hang
    ${locator}    Set Variable    //label[contains(text(),'{0}')]/following::div[1]/span
    ${lang_str}    KV Get Language Text    Phí giao hàng    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND GetLocator Chi Tiet HD Button TT Voi DTGH
    ${locator}    Set Variable    //a[contains(text(),'{0}')]
    ${lang_str}    KV Get Language Text    Thanh toán với đối tác giao hàng    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND WaitVisible HD List Title Chon Mau In Hoa Don
    [Arguments]    ${wait_time_out}=20s
    ${locator}    Set Variable    //div[contains(@class,'k-header')]/span[text()='{0}']
    ${lang_str}    KV Get Language Text    Chọn mẫu in hóa đơn    None
    ${locator}    Format String    ${locator}    ${lang_str}
    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}

FNB AND WaitNotVisible HD List Title Chon Mau In Hoa Don
    [Arguments]    ${wait_time_out}=20s    ${visible_time_out}=0.5
    ${locator}    Set Variable    //div[contains(@class,'k-header')]/span[text()='{0}']
    ${lang_str}    KV Get Language Text    Chọn mẫu in hóa đơn    None
    ${locator}    Format String    ${locator}    ${lang_str}
    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    timeout=${visible_time_out}
    Wait Until Page Does Not Contain Element    ${locator}    timeout=${wait_time_out}

FNB AND GetLocator HD List Button Ten Mau In
    [Arguments]    ${ten_mau_in}
    ${locator}    Set Variable    //div[contains(@class,'k-window-printpop')]//div[contains(@class,'printBtn ')]/button[text()='{0}']
    ${locator}    Format String    ${locator}    ${ten_mau_in}
    [Return]    ${locator}

FNB AND HD List Button Ten Mau In
    [Arguments]    ${ten_mau_in}    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Button Ten Mau In    ${ten_mau_in}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD List Button Dong Y In
    ${locator}    Set Variable    //div[contains(@class,'k-window-printpop')]//div[contains(@class,'kv-window-footer')]/a[1]
    [Return]    ${locator}

FNB AND HD List Button Dong Y In
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Button Dong Y In
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND WaitVisible HD List Title Popup Huy HoaDon
    [Arguments]    ${wait_time_out}=20s
    ${locator}    Set Variable    //div[contains(@class,'k-window-poup')]/div/span[contains(text(),'{0}')]
    ${lang_str}    KV Get Language Text    Hủy hóa đơn    None
    ${locator}    Format String    ${locator}    ${lang_str}
    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}

FNB AND WaitNotVisible HD List Title Popup Huy HoaDon
    [Arguments]    ${wait_time_out}=20s    ${visible_time_out}=0.5
    ${locator}    Set Variable    //div[contains(@class,'k-window-poup')]/div/span[contains(text(),'{0}')]
    ${lang_str}    KV Get Language Text    Hủy hóa đơn    None
    ${locator}    Format String    ${locator}    ${lang_str}
    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    timeout=${visible_time_out}
    Wait Until Page Does Not Contain Element    ${locator}    timeout=${wait_time_out}

FNB AND GetLocator HD List Button DongY Huy HoaDon
    ${locator}    Set Variable    //div[contains(@class,'k-window-alert')]//div[contains(@class,'kv-window-footer')]//button[1]
    [Return]    ${locator}

FNB AND HD List Button DongY Huy HoaDon
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Button DongY Huy HoaDon
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD List Button BoQua Huy HoaDon
    ${locator}    Set Variable    //div[contains(@class,'k-window-alert')]//div[contains(@class,'kv-window-footer')]//button[2]
    [Return]    ${locator}

FNB AND HD List Button BoQua Huy HoaDon
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Button BoQua Huy HoaDon
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD List Button Close Huy HoaDon
    ${locator}    Set Variable    //div[contains(@class,'k-window-alert')]//span[contains(@class,'k-i-close')]
    [Return]    ${locator}

FNB AND HD List Button Close Huy HoaDon
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Button Close Huy HoaDon
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND WaitVisible HD List Title Popup Huy ChungTuLq
    [Arguments]    ${wait_time_out}=20s
    ${locator}    Set Variable    //div[contains(@class,'k-window-poup')]/div/span[contains(text(),'{0}')]
    ${lang_str}    KV Get Language Text    Hủy hóa đơn    None
    ${locator}    Format String    ${locator}    ${lang_str}
    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}

FNB AND WaitNotVisible HD List Title Popup Huy ChungTuLq
    [Arguments]    ${wait_time_out}=20s    ${visible_time_out}=0.5
    ${locator}    Set Variable    //div[contains(@class,'k-window-poup')]/div/span[contains(text(),'{0}')]
    ${lang_str}    KV Get Language Text    Hủy hóa đơn    None
    ${locator}    Format String    ${locator}    ${lang_str}
    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    timeout=${visible_time_out}
    Wait Until Page Does Not Contain Element    ${locator}    timeout=${wait_time_out}

FNB AND GetLocator HD List Button DongY Huy ChungTuLq
    ${locator}    Set Variable    //div[contains(@class,'k-window-alert')]//div[contains(@class,'kv-window-footer')]//button[1]
    [Return]    ${locator}

FNB AND HD List Button DongY Huy ChungTuLq
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Button DongY Huy ChungTuLq
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD List Button BoQua Huy ChungTuLq
    ${locator}    Set Variable    //div[contains(@class,'k-window-alert')]//div[contains(@class,'kv-window-footer')]//button[2]
    [Return]    ${locator}

FNB AND HD List Button BoQua Huy ChungTuLq
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Button BoQua Huy ChungTuLq
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD List Footer Info
    ${locator}    Set Variable    //div[@id='grdInvoices']/div[@class='paging-box']//span[contains(@class,'k-pager-info')]
    [Return]    ${locator}

FNB AND GetLocator HD List Text Tong HoaDon
    ${locator}    Set Variable    //div[@id='grdInvoices']/div[@class='paging-box']//span[contains(@class,'k-pager-info')]
    [Return]    ${locator}

FNB AND HD List Text Tong HoaDon
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s    ${defaul_value}=${-1}
    ${locator}    FNB AND GetLocator HD List Text Tong HoaDon
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    ${str}    Get Text    ${locator}
    ${number}    KV Extract number from string    ${str}    ${2}    ${defaul_value}
    [Return]    ${number}

FNB AND GetLocator HD List Text So HH Tren Trang
    ${locator}    Set Variable    //div[@id='grdInvoices']/div[@class='paging-box']//span[contains(@class,'k-pager-info')]
    [Return]    ${locator}

FNB AND HD List Text So HH Tren Trang
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s    ${defaul_value}=${-1}
    ${locator}    FNB AND GetLocator HD List Text So HH Tren Trang
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    ${str}    Get Text    ${locator}
    ${number}    KV Extract number from string    ${str}    ${1}    ${defaul_value}
    [Return]    ${number}

FNB AND GetLocator HD List Button First Page
    ${locator}    Set Variable    //div[@id='grdInvoices']/div[@class='paging-box']//a[contains(@class,'k-pager-first')]
    [Return]    ${locator}

FNB AND HD List Button First Page
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Button First Page
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD List Button Next Page
    ${locator}    Set Variable    //div[@id='grdInvoices']/div[contains(@class,'paging-box')]//a[./span[text()='{0}']]
    ${lang_str}    KV Get Language Text    Trang trước    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD List Button Next Page
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Button Next Page
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD List Button Previous Page
    ${locator}    Set Variable    //div[@id='grdInvoices']/div[contains(@class,'paging-box')]//a[./span[text()='{0}']]
    ${lang_str}    KV Get Language Text    Trang sau    None
    ${locator}    Format String    ${locator}    ${lang_str}
    [Return]    ${locator}

FNB AND HD List Button Previous Page
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Button Previous Page
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD List Button Current Page
    ${locator}    Set Variable    //div[@id='grdInvoices']/div[contains(@class,'paging-box')]//ul//li/span[@class='k-state-selected']
    [Return]    ${locator}

FNB AND HD List Button Current Page
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Button Current Page
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD List Button Item Page
    [Arguments]    ${so_trang}
    ${locator}    Set Variable    //div[@id='grdInvoices']/div[contains(@class,'paging-box')]//ul//li/a[@class='k-link' and text()='{0}']
    ${locator}    Format String    ${locator}    ${so_trang}
    [Return]    ${locator}

FNB AND HD List Button Item Page
    [Arguments]    ${so_trang}    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Button Item Page    ${so_trang}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}

FNB AND GetLocator HD List Button Last Page
    ${locator}    Set Variable    //div[@id='grdInvoices']/div[contains(@class,'paging-box')]//a[contains(@class,'k-pager-last')]
    [Return]    ${locator}

FNB AND HD List Button Last Page
    [Arguments]    ${is_wait_visible}=True    ${wait_time_out}=20s
    ${locator}    FNB AND GetLocator HD List Button Last Page
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Page Contains Element    ${locator}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}