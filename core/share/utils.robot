*** Settings ***
Documentation     A resource file with reusable keywords and variables.
Library           String
Library           DateTime
Library           SeleniumLibrary
Library           ExcelLibrary
Library           Collections
Library           ../../custom-library/UtilityLibrary.py
Resource          constants.robot
Resource          computation.robot
Resource          list_dictionary.robot
Resource          javascript.robot

*** Variables ***
${pre_locator}    ${EMPTY}
${autocomplete_locator}    //div[@class='output-complete']//li[text()[contains(.,'{0}')] or .//p[text()[contains(.,'{0}')]] or .//span[text()='{0}']][1]
&{hanghoa_excel_col_names}   loai_hang=Loại hàng    loai_thuc_don=Loại thực đơn    nhom_hang=Nhóm hàng(3 Cấp)    ma_hang=Mã hàng    ten_hang=Tên hàng hóa
...    gia_von=Giá vốn    gia_ban=Giá bán    ton_kho=Tồn kho    dat_hang=Đặt hàng    ton_min=Tồn nhỏ nhất    ton_max=Tồn lớn nhất    ma_dvt_coban=Mã ĐVT Cơ bản
...    donvi_quydoi=Quy đổi    thuoc_tinh=Thuộc tính    ma_hh_lqan=Mã HH Liên quan    don_vi_tinh=ĐVT    hinh_anh=Hình ảnh (url1,url2...)    trong_luong=Trọng lượng
...    tich_diem=Tích điểm    dang_kd=Đang kinh doanh    ban_tt=Được bán trực tiếp    mo_ta=Mô tả    ghi_chu=Mẫu ghi chú    la_mon_them=Là món thêm
...    la_dv_tinhgio=Là hàng dịch vụ tính theo thời gian sử dụng    hang_thanh_phan=Hàng thành phần    mon_them=Món thêm    vi_tri=Vị trí
&{hanghoa_key_convert_api_to_excel}
...    ProductType=ma_hang
...    BasePrice=gia_ban
...    OnHand=ton_kho
...    OrderTemplate=dat_hang
...    MinQuantity=ton_nho_nhat

*** Keywords ***
KV Log
    [Arguments]    ${data}
    Run Keyword If    '${ENABLE_LOG}'=='True'    Log    ${data}

KV Log Dictionary
    [Arguments]    ${data}
    Run Keyword If    '${ENABLE_LOG}'=='True'    Log Dictionary    ${data}

KV Report Bug
    ${error_message}    Catenate    SEPARATOR=${SPACE}${SPACE}~${SPACE}${SPACE}    @{LIST_ERROR}
    Run Keyword If    '${error_message}'!='${EMPTY}'    Fail    [List Bugs] ${error_message}

KV Convert Key Name Dictionary
    [Arguments]    ${dict}    ${keys_convert_dict}
    &{values_dict}    Create Dictionary
    FOR    ${key}    IN    @{dict}
        ${new_key}    Set Variable    ${keys_convert_dict["${key}"]}
        Set To Dictionary    ${values_dict}    ${new_key}    ${dict["${key}"]}
    END
    [Return]    ${values_dict}

KV Load Excel And Return Key Col Index
    [Arguments]    ${excel_path}    ${col_names_dict}=${hanghoa_excel_col_names}    ${percision_number}=${3}    ${normalize_data}=True    ${title_row}=1   ${sheet_name}=${EMPTY}
    &{values_dict}    Create Dictionary
    FOR    ${key}    IN    @{col_names_dict}
        ${value}    Create List
        Set To Dictionary    ${values_dict}    ${key}    ${value}
    END
    #open excel file and create col_index dict
    Open Excel Document    ${excel_path}    doc_id
    &{keys_col_index_dict}    Create Dictionary
    FOR    ${col_index}    IN RANGE    1    9999
        ${cell_value}   Run Keyword If    '${sheet_name}'=='${EMPTY}'    Read Excel Cell     ${title_row}    ${col_index}
        ...    ELSE     Read Excel Cell     ${title_row}    ${col_index}    ${sheet_name}
        Run Keyword If    '${cell_value}' == 'None'    Exit For Loop
        Excel Column Name to Index    ${cell_value}    ${col_index}    ${keys_col_index_dict}    ${col_names_dict}
    END
    KV Log    ${keys_col_index_dict}
    #read all values by col_index
    ${start_row}    Sum    ${title_row}    1
    FOR    ${row_index}    IN RANGE    ${start_row}    9999
        ${count_not_none}    Excel Column Index to Value    ${row_index}    ${keys_col_index_dict}    ${values_dict}    ${normalize_data}    ${percision_number}    ${sheet_name}
        Run Keyword If    ${count_not_none} == 0    Exit For Loop
    END
    [Return]    ${values_dict}    ${keys_col_index_dict}

KV Load Excel As Dictionary
    [Arguments]    ${excel_path}    ${col_names_dict}=${hanghoa_excel_col_names}    ${normalize_data}=True    ${percision_number}=${3}    ${title_row}=1    ${sheet_name}=${EMPTY}
    ${values_dict}    ${keys_col_index_dict}    KV Load Excel And Return Key Col Index    ${excel_path}    ${col_names_dict}    ${percision_number}    ${normalize_data}    ${title_row}    ${sheet_name}
    #remove last index (last row is empty)
    FOR    ${key}    IN    @{values_dict}
        Remove From List    ${values_dict["${key}"]}    -1
    END
    KV Log    ${values_dict}
    #close excel and return values dict
    Close Current Excel Document
    [Return]    ${values_dict}

KV Edit Data In Excel
    [Arguments]    ${values_dict}    ${keys_col_index_dict}    ${list_modf_dict}    ${input_unique_key}

    FOR    ${modf_dict}    IN ZIP    ${list_modf_dict}
        KV Update Value To Cell    ${values_dict}    ${keys_col_index_dict}    ${modf_dict}    ${input_unique_key}
    END

KV Update Value To Cell
    [Arguments]    ${values_dict}    ${keys_col_index_dict}    ${modf_dict}    ${input_unique_key}
    # index_in_list là index được lấy từ list value tương ứng với key ma_hang
    ${index_in_list}=    Get Index From List    ${values_dict["${input_unique_key}"]}    ${modf_dict["${input_unique_key}"]}
    # Trong excel row được đếm bắt đầu từ 1 và ta cần bỏ qua hàng đầu tiên là tên các cột nên row = index + 2
    ${row}=    Evaluate    ${index_in_list}+2

    FOR    ${key}    IN    @{modf_dict}
       Run Keyword If    '${key}'=='ma_hang'    Continue For Loop    #bỏ qua key mã hàng
       ${col}    Set Variable    ${keys_col_index_dict["${key}"]}
       Write Excel Cell    ${row}    ${col}    ${modf_dict["${key}"]}
    END

# Load các thông tin tổng hợp ra summary_info_dict và update lại export_values_dict chỉ chứa dữ liệu trong phiếu
KV Load Summary Info And Update Excel Data Dict
    [Arguments]    ${export_values_dict}    ${key_to_key}    ${key_to_val}    ${col_names_dict}    ${item_quantity}    ${key_quantity}=${3}
    # Get tổng số dòng dữ liệu trong file excel
    ${length}    Get Length    ${export_values_dict["${key_to_key}"]}
    # item_quantity là số dòng về dữ liệu, key_quantity là số dòng về thông tin tổng hợp
    ${item_count}    Evaluate    ${length}-${key_quantity}
    # Check file excel có đầy đủ dữ liệu không
    KV Should Be Equal As Numbers    ${item_quantity}    ${item_count}    Lỗi số dòng dữ liệu trong excel và số lượng dữ liệu trong phiếu khác nhau

    # Cắt ra các thông tin tổng hợp và đưa vào summary_info_dict
    ${list_key_to_key}    Get Slice From List    ${export_values_dict["${key_to_key}"]}    -${key_quantity}
    ${list_key_to_val}    Get Slice From List    ${export_values_dict["${key_to_val}"]}    -${key_quantity}

    ${summary_info_dict}    Create Dictionary
    FOR    ${key}    ${val}    IN ZIP    ${list_key_to_key}    ${list_key_to_val}
        ${list_val}    Create List
        Insert Into List    ${list_val}    0    ${val}
        Set To Dictionary    ${summary_info_dict}    ${col_names_dict["${key}"]}=${list_val}
    END
    KV Log    ${summary_info_dict}

    # Xóa bỏ các thông tin tổng hợp, export_values_dict chỉ còn chứa dữ liệu chi tiết
    FOR    ${key}    IN    @{export_values_dict}
        ${list_new_val}    Get Slice From List    ${export_values_dict["${key}"]}    0    ${item_count}
        Set To Dictionary    ${export_values_dict}    ${key}=${list_new_val}
    END
    KV Log    ${export_values_dict}

    Return From Keyword    ${summary_info_dict}    ${export_values_dict}

Excel Column Name to Index
    [Arguments]    ${cell_value}    ${col_index}    ${keys_col_index_dict}    ${col_names_dict}
    FOR    ${key}    IN    @{col_names_dict}
        Run Keyword If    '${col_names_dict["${key}"]}' == '${cell_value}'    Set To Dictionary    ${keys_col_index_dict}    ${key}    ${col_index}
        Run Keyword If    '${col_names_dict["${key}"]}' == '${cell_value}'    Exit For Loop
    END

Excel Column Index to Value
    [Arguments]    ${row_index}    ${keys_col_index_dict}    ${values_dict}    ${normalize_data}    ${percision_number}    ${sheet_name}
    ${count_not_none}    Set Variable    ${0}
    FOR    ${key}    IN    @{keys_col_index_dict}
        ${cell_value}    Run Keyword If    '${sheet_name}'=='${EMPTY}'    Read Excel Cell     ${row_index}    ${keys_col_index_dict["${key}"]}
        ...    ELSE     Read Excel Cell     ${row_index}    ${keys_col_index_dict["${key}"]}    ${sheet_name}
        ${type_cell_value}    Evaluate    type($cell_value).__name__

        ${cell_value}    Run Keyword If    '${type_cell_value}' == 'float'    Evaluate    round(${cell_value},${percision_number})
        ...    ELSE IF    '${type_cell_value}' == 'datetime'    Convert To String    ${cell_value}
        ...    ELSE IF    '${type_cell_value}' == 'str'    Strip String    ${cell_value}    characters=\n
        ...    ELSE    Set Variable    ${cell_value}
        # loan.nt: sử dung 3 dấu nháy ''' để so sánh long string (text trên nhiều dòng) với giá trị string khác
        ${count_not_none}    Run Keyword If    '''${cell_value}''' !="None" and '''${cell_value}''' !='${SPACE}'    Evaluate    ${count_not_none}+1    ELSE    Set Variable    ${count_not_none}
        ${cell_value}    Run Keyword If    '${normalize_data}' == 'True'    Excel Normalize Data    ${cell_value}    ELSE    Set Variable    ${cell_value}
        Append To List    ${values_dict["${key}"]}    ${cell_value}
    END
    [Return]    ${count_not_none}

Excel Normalize Data
    [Arguments]    ${cell_value}
    Run Keyword If    '''${cell_value}''' == 'None'       Return From Keyword    ${0}
    Run Keyword If    '''${cell_value}''' == '${EMPTY}'   Return From Keyword    ${0}
    Run Keyword If    '''${cell_value}''' == '${SPACE}'   Return From Keyword    ${0}
    Run Keyword If    '''${cell_value}''' == 'True'       Return From Keyword    ${1}
    Run Keyword If    '''${cell_value}''' == 'TRUE'       Return From Keyword    ${1}
    Run Keyword If    '''${cell_value}''' == 'False'      Return From Keyword    ${0}
    Run Keyword If    '''${cell_value}''' == 'FALSE'      Return From Keyword    ${0}
    [Return]    ${cell_value}

Normal Number To Excel String
    [Arguments]    ${number}    ${is_float_number}=False
    ${str}    Run KeyWord If    '${is_float_number}'=='False'    Evaluate    '${number}'    ELSE    Evaluate    '${number}'.split('.')[0]
    ${str}    Evaluate    ','.join(['${str}'[::-1][i:i+3] for i in range(0, len('${str}'.split('.')[0]), 3)])[::-1]
    [Return]    ${str}

# input_unique_key là 1 trường xác định việc so sánh VD: mã hàng
KV Compare Dictionary Values by Key
    [Arguments]    ${input_dict}    ${input_unique_key}    ${target_dict}
    FOR    ${key}    IN    @{input_dict}
        KV Dictionary Should Contain Key    ${target_dict}    ${key}    Lỗi Dictionary không chứa key truyền vào
    END
    ${length}    Get Length    ${input_dict["${input_unique_key}"]}
    FOR    ${index}    IN RANGE    0    ${length}
        KV Compare Dictionary Values by Key and Index    ${input_dict}    ${input_unique_key}    ${index}    ${target_dict}
    END

KV Compare Dictionary Values by Key and Index
    [Arguments]    ${input_dict}    ${input_unique_key}    ${input_index}    ${target_dict}
    ${target_index}    Get Index From List    ${target_dict["${input_unique_key}"]}    ${input_dict["${input_unique_key}"][${input_index}]}
    FOR    ${key}    IN    @{input_dict}
        KV Compare Scalar Values     ${input_dict["${key}"][${input_index}]}     ${target_dict["${key}"][${target_index}]}    Lỗi dữ liệu trong hai dictionary (excel và API) khác nhau
    END

KV Compare Dictionary Values by Key and Value
    [Arguments]    ${input_dict}    ${input_unique_key}    ${input_key_value}    ${target_dict}
    ${input_index}    Get Index From List    ${input_dict["${input_unique_key}"]}    ${input_key_value}
    ${target_index}    Get Index From List    ${target_dict["${input_unique_key}"]}    ${input_key_value}
    FOR    ${key}    IN    @{input_dict}
        KV Compare Scalar Values     ${input_dict["${key}"][${input_index}]}     ${target_dict["${key}"][${target_index}]}    Lỗi dữ liệu trong hai dictionary (excel và API) khác nhau
    END

KV Compare Scalar Values
    [Arguments]    ${val_1}    ${val_2}    ${msg}=${default_error_msg}    ${values}=True    ${ignore_case}=False    ${formatter}=str
    ${type_val_1}=    Evaluate    type($val_1).__name__
    ${type_val_2}=    Evaluate    type($val_2).__name__
    ${val_1}    Run Keyword If    '${type_val_1}'=='str'    KV Normalize String    ${val_1}    ELSE    Set Variable    ${val_1}
    ${val_2}    Run Keyword If    '${type_val_2}'=='str'    KV Normalize String    ${val_2}    ELSE    Set Variable    ${val_2}
    Run Keyword If    '${type_val_1}'=='str' or '${type_val_2}'=='str'    KV Should Be Equal As Strings    ${val_1}    ${val_2}    ${msg}    ${values}    ${ignore_case}    ${formatter}
    ...    ELSE    KV Should Be Equal    ${val_1}    ${val_2}    ${msg}    ${values}    ${ignore_case}    ${formatter}

KV Should Be Equal As Strings
    [Arguments]    ${val_1}    ${val_2}    ${msg}    ${values}=True    ${ignore_case}=False    ${formatter}=str
    KV Compare Template    Should Be Equal As Strings    ${val_1}    ${val_2}    ${msg}    ${values}    ${ignore_case}    ${formatter}

KV Should Be Equal
    [Arguments]    ${val_1}    ${val_2}    ${msg}    ${values}=True    ${ignore_case}=False    ${formatter}=str
    KV Compare Template    Should Be Equal    ${val_1}    ${val_2}    ${msg}    ${values}    ${ignore_case}    ${formatter}

KV Should Be Equal As Numbers
    [Arguments]    ${val_1}    ${val_2}    ${msg}    ${values}=True    ${precision}=3
    KV Compare Template    Should Be Equal As Numbers    ${val_1}    ${val_2}    ${msg}    ${values}    ${precision}

KV Should Be Equal As Integers
    [Arguments]    ${val_1}    ${val_2}    ${msg}    ${values}=True    ${base}=None
    KV Compare Template    Should Be Equal As Integers    ${val_1}    ${val_2}    ${msg}    ${values}    ${base}

KV List Should Contain Value
    [Arguments]    ${list}    ${value}    ${msg}
    KV Compare Template    List Should Contain Value    ${list}    ${value}    ${msg}

KV List Should Not Contain Value
    [Arguments]    ${list}    ${value}    ${msg}
    KV Compare Template    List Should Not Contain Value    ${list}    ${value}    ${msg}

KV Lists Should Be Equal
    [Arguments]    ${list_1}    ${list_2}    ${msg}    ${values}=True     ${names}=None
    KV Compare Template    Lists Should Be Equal    ${list_1}    ${list_2}    ${msg}    ${values}     ${names}

KV Dictionary Should Contain Key
    [Arguments]    ${dict}    ${key}    ${msg}
    KV Compare Template    Dictionary Should Contain Key    ${dict}    ${key}    ${msg}

KV Dictionaries Should Be Equal
    [Arguments]    ${dict1}    ${dict2}    ${msg}    ${value}=True
    KV Compare Template    Dictionaries Should Be Equal    ${dict1}    ${dict2}    ${msg}    ${value}

KV Should Be True
    [Arguments]    ${condition}    ${msg}
    KV Compare Template    Should Be True    ${condition}    ${msg}

KV Should Not Be True
    [Arguments]    ${condition}    ${msg}
    KV Compare Template    Should Not Be True    ${condition}    ${msg}

KV Element Should Contain
    [Arguments]    ${locator}    ${expected}    ${message}    ${ignore_case}=False
    KV Compare Template    Element Should Contain    ${locator}    ${expected}    ${message}    ${ignore_case}

KV Should Contain
    [Arguments]    ${container}    ${item}    ${msg}    ${values}=True    ${ignore_case}=False
    KV Compare Template    Should Contain    ${container}    ${item}    ${msg}    ${values}    ${ignore_case}

KV Compare Template
    [Arguments]    @{list_arg}
    ${status}    ${error}    Run Keyword And Ignore Error    @{list_arg}
    Run Keyword If    '${status}'=='FAIL'    Run Keywords    Append To List    ${LIST_ERROR}    ${error}   AND   Log    [${TEST NAME}]: ${error}    ERROR
    Set Test Variable    ${LIST_ERROR}

KV Normalize String
    [Arguments]    ${str}
    ${str}    Replace String    ${str}    ${SPACE}|    |
    ${str}    Replace String    ${str}    |${SPACE}    |
    ${list_str}    Split String    ${str}    |
    Sort List    ${list_str}
    ${str}    Catenate    SEPARATOR=|    @{list_str}
    [Return]    ${str}

KV Get Language Text
    [Arguments]    ${vi_str}    ${en_str}
    ${text} =   Run Keyword If    '${language}' == 'Vi'    Set Variable    ${vi_str}
    ...    ELSE IF    '${language}' == 'En'    Set Variable    ${en_str}
    ...    ELSE    ${text} = ${vi_str}
    [Return]    ${text}

KV Check isdigit
    [Arguments]    ${str}
    ${isdigit} =    Evaluate    $str.replace('.','',1).replace('-','',1).isdigit()
    [Return]    ${isdigit}

KV Extract number from string
    [Arguments]    ${str}    ${index}    ${defaul_value}
    ${str}=    Replace String    ${str}    ,    ${EMPTY}
    ${nums}=    Get Regexp Matches    ${str}    [-]?\\d+(?:\\.\\d+)?
    ${length}    Get Length    ${nums}
    ${number}    Run Keyword If    ${length}>${index}    Set Variable    ${nums[${index}]}    ELSE    Set Variable    ${defaul_value}
    [Return]    ${number}

KV Check IsVisible
    [Arguments]    ${locator}
    ${visible} =    Run Keyword And Return Status    Element Should Be Visible    ${locator}
    [Return]    ${visible}

KV Input Text
    [Arguments]    ${locator}    ${text}    ${is_clear_text}=True    ${is_autocomplete}=False
    ${length}    Get Length    ${text}${EMPTY}
    ${speed}    Evaluate    ${length}*0.02
    ${l_text}    Convert To Lowercase    ${text}${EMPTY}
    ${input_success}    Set Variable    False
    FOR    ${i}    IN RANGE    0    20
        Run Keyword If    '${is_clear_text}'=='True'    Clear Element Text    ${locator}
        KV Click Element    ${locator}
        ${has_focus}    Execute JavaScript    return (window.document.activeElement === window.document.evaluate("${locator}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue)
        Continue For Loop If    '${has_focus}'!='True'
        Input text    ${locator}   ${text}    False
        Set Selenium Speed    ${speed}
        ${is_iFrame_body}    Evaluate    $locator=='//body'
        ${inserted_text}    Run Keyword If    '${is_iFrame_body}'=='False'    Get Element Attribute    ${locator}    value    ELSE    Get Element Attribute    ${locator}    innerHTML
        ${l_inserted_text}    Convert To Lowercase    ${inserted_text}${EMPTY}
        ${l_inserted_text}    Evaluate    $l_inserted_text.replace(',','')
        Set Selenium Speed    ${SELENIUM_SPEED}
        #Run Keyword If    ${i}>0    Log To Console    ${l_inserted_text}|${l_text}
        ${input_success}    Evaluate    $l_inserted_text == $l_text
        Exit For Loop If    '${input_success}' == 'True'
    END
    Should Be True    '${input_success}' == 'True'    Lỗi input text!
    Run Keyword If    '${is_autocomplete}' == 'True'    KV Click Autocomplete Element    ${text}

KV Pos Input Text
    [Arguments]    ${locator}    ${text}    ${is_clear_text}=True    ${is_autocomplete}=False
    ${length}    Get Length    ${text}${EMPTY}
    ${speed}    Evaluate    ${length}*0.02
    ${l_text}    Convert To Lowercase    ${text}${EMPTY}
    ${input_success}    Set Variable    False
    FOR    ${i}    IN RANGE    0    5
        Run Keyword If    '${is_clear_text}'=='True'    Clear Element Text    ${locator}
        Input text    ${locator}   ${text}    False
        Sleep    0.5s
        Set Selenium Speed    ${speed}
        ${is_iFrame_body}    Evaluate    $locator=='//body'
        ${inserted_text}    Run Keyword If    '${is_iFrame_body}'=='False'    Get Element Attribute    ${locator}    value    ELSE    Get Element Attribute    ${locator}    innerHTML
        ${l_inserted_text}    Convert To Lowercase    ${inserted_text}${EMPTY}
        ${l_inserted_text}    Evaluate    $l_inserted_text.replace(',','')
        Set Selenium Speed    ${SELENIUM_SPEED}
        ${input_success}    Evaluate    $l_inserted_text == $l_text
        Exit For Loop If    '${input_success}' == 'True'
    END
    Should Be True    '${input_success}' == 'True'    Lỗi input text!
    Run Keyword If    '${is_autocomplete}' == 'True'    KV Click Autocomplete Element JS    ${text}

KV Click Autocomplete Element
    [Arguments]    ${text}
    ${locator}    Format String    ${autocomplete_locator}    ${text}
    KV Wait Until Element Is Visible    ${locator}    5 s
    KV Click Element    ${locator}

KV Click Autocomplete Element JS
    [Arguments]    ${text}
    ${locator}    Format String    ${autocomplete_locator}    ${text}
    KV Wait Until Element Is Visible    ${locator}    5 s
    KV Click Element JS    ${locator}

KV Wait Until Element Is Visible
    [Arguments]    ${locator}    ${wait_time_out}
    Set Selenium Speed    0
    Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    Set Selenium Speed    ${SELENIUM_SPEED}

KV Wait Until Element Is Stable
    [Arguments]    ${locator}
    Set Selenium Speed    0
    # Wait Until Keyword Succeeds    50 times    0.2    KV Check Element Is Stable    ${locator}
    Set Selenium Speed    ${SELENIUM_SPEED}

#son.nd: các kw Get Horizontal Position,Get Vertical Position... sẽ khiến webdriver bị lỗi khi check với 1 locator đã bị remove khỏi web page
#khiến test case bị fail (và thường là kéo theo các test case khác fail theo)
#=>Cần check position bằng JavaScript trước
KV Check Element Is Stable
    [Arguments]    ${locator}
    ${is_repeate}    Evaluate    $pre_locator==$locator
    Run KeyWord If    '${is_repeate}'=='True'    Set Selenium Speed    0.1
    KV Safe Check Element Is Stable    ${locator}
    Set Selenium Speed    ${SELENIUM_SPEED}
    ${h_pos_old}    Get Horizontal Position    ${locator}
    ${v_pos_old}    Get Vertical Position    ${locator}
    ${h_pos_new}    Get Horizontal Position    ${locator}
    ${v_pos_new}    Get Vertical Position    ${locator}
    Should Be Equal As Numbers    ${h_pos_old}    ${h_pos_new}    Lỗi tọa độ ngang cũ và mới khác nhau
    Should Be Equal As Numbers    ${v_pos_old}    ${v_pos_new}    Lỗi tọa độ dọc cũ và mới khác nhau
    Set Global Variable    ${pre_locator}    ${locator}

KV Safe Check Element Is Stable
    [Arguments]    ${locator}
    ${pos_old}    KV Get Position    ${locator}
    ${pos_new}    KV Get Position    ${locator}
    Should Be Equal As Numbers    ${pos_old["x"]}    ${pos_new["x"]}    Lỗi tọa độ x cũ và mới khác nhau
    Should Be Equal As Numbers    ${pos_old["y"]}    ${pos_new["y"]}    Lỗi tọa độ y cũ và mới khác nhau

KV Get Position
    [Arguments]    ${xpath}
    ${pos}    Execute JavaScript    return window.document.evaluate("${xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.getBoundingClientRect();
    [Return]    ${pos}

KV Scroll to Element
    [Arguments]    ${xpath}    ${is_wait_loading}=True
    Run Keyword If    '${is_wait_loading}' == 'True'    FNB WaitNotVisible Menu Loading Icon
    Execute JavaScript    window.document.evaluate("${xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView(true);

KV Scroll Element Into View
    [Arguments]    ${xpath}    ${is_wait_loading}=True
    Run Keyword If    '${is_wait_loading}' == 'True'    FNB WaitNotVisible Menu Loading Icon
    Scroll Element Into View    ${xpath}

KV Upload Files
    [Arguments]    ${locator}    ${files}    ${is_wait_visible}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    Wait Until Element Is Visible    ${locator}    timeout=${wait_time_out}
    ${string_file_paths}=    Create List
    ${is_list}=    Evaluate    isinstance($files, list)
    ${string_file_paths}=    Run Keyword If    '${is_list}' == 'True'    Combine Lists    ${string_file_paths}    ${files}
    Run Keyword If    '${is_list}' == 'False'    Append To List    ${string_file_paths}    ${files}
    ${length}=    Get Length    ${string_file_paths}
    Set Selenium Speed    0
    FOR    ${i}    IN RANGE    ${length}
        ${file_path}=    Catenate    SEPARATOR=    ${EXECDIR}/prepare-data    ${string_file_paths[${i}]}
        # Run Keyword If    '${i}' != '0'    Clear Element Text    ${locator}
        Choose File    ${locator}    ${file_path}
    END
    Set Selenium Speed    ${SELENIUM_SPEED}

KV Select Cell in Dropdown
    [Arguments]    ${locator}    ${cell_locator}    ${is_wait_visible}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}
    KV Wait Until Element Is Stable    ${cell_locator}
    ${visible}    KV Check IsVisible    ${cell_locator}
    Run Keyword If    '${visible}' == 'True'    Run Keywords    KV Click Element    ${cell_locator}    AND    Return From Keyword    1
    #go up
    Set Selenium Speed    0
    FOR    ${i}    IN RANGE    10
        Exit For Loop If    '${visible}' == 'True'
        Press Keys    ${locator}   ${ARROW_UP_KEY}
    END
    #search for cell
    FOR    ${i}    IN RANGE    10
        ${visible}    KV Check IsVisible    ${cell_locator}
        Exit For Loop If    '${visible}' == 'True'
        Press Keys    ${locator}   ${ARROW_DOWN_KEY}
        Set Selenium Speed    ${SELENIUM_SPEED}
    END
    KV Click Element    ${cell_locator}

KV Select Cell in Dropdown JS
    [Arguments]    ${locator}    ${cell_locator}    ${is_wait_visible}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element JS    ${locator}
    KV Wait Until Element Is Stable    ${cell_locator}
    ${visible}    KV Check IsVisible    ${cell_locator}
    Run Keyword If    '${visible}' == 'True'    Run Keywords    KV Click Element JS    ${cell_locator}    AND    Return From Keyword    1
    #go up
    Set Selenium Speed    0
    FOR    ${i}    IN RANGE    10
        Exit For Loop If    '${visible}' == 'True'
        Press Keys    ${locator}   ${ARROW_UP_KEY}
    END
    #search for cell
    FOR    ${i}    IN RANGE    10
        ${visible}    KV Check IsVisible    ${cell_locator}
        Exit For Loop If    '${visible}' == 'True'
        Press Keys    ${locator}   ${ARROW_DOWN_KEY}
        Set Selenium Speed    ${SELENIUM_SPEED}
    END
    KV Click Element JS    ${cell_locator}

KV Input Text and Select Cell in Dropdown
    [Arguments]    ${locator}    ${textbox_locator}    ${text}    ${cell_locator}    ${is_clear_text}    ${is_wait_visible}    ${wait_time_out}
    Run Keyword If    '${is_wait_visible}' == 'True'    KV Wait Until Element Is Visible    ${locator}    ${wait_time_out}
    KV Click Element    ${locator}
    KV Wait Until Element Is Visible    ${textbox_locator}    15s
    KV Input Text   ${textbox_locator}    ${text}    ${is_clear_text}
    KV Wait Until Element Is Visible    ${cell_locator}    ${wait_time_out}
    KV Click Element    ${cell_locator}

KV Click Element
    [Arguments]    ${locator}
    KV Wait Until Element Is Stable    ${locator}
    Wait Until Keyword Succeeds    3 times    0s    Click Element    ${locator}

KV Click Element JS
    [Arguments]    ${locator}
    KV Wait Until Element Is Stable    ${locator}
    Wait Until Keyword Succeeds    3 times    0s    Click Element JS    ${locator}

KV Check Hien Thi Popup TinhNangMoi
    ${show_newfeed}=    Execute Javascript    var show_newfeed = true; for (var key in window.localStorage) { if(key.indexOf("kv_noDisplay")>=0) { show_newfeed = window.localStorage.getItem(key); break; } } return show_newfeed;
    [Return]    ${show_newfeed}

KV Get Cookies Value
    [Arguments]    ${key_name}
    ${value}    Execute Javascript    var name="${key_name}="; var decodedCookie=decodeURIComponent(document.cookie); var ca=decodedCookie.split(';');for(var i=0; i<ca.length; i++) {var c=ca[i];while(c.charAt(0) == ' '){c = c.substring(1);}if (c.indexOf(name) == 0) {return c.substring(name.length, c.length);}}return "";
    [Return]    ${value}

#Full format example: %Y[separator]%m[separator]%d[separator]%H[separator]%M[separator]%S[separator]%f
KV Compare DateTime
    [Arguments]    ${input_date_str}   ${display_date_str}    ${input_format}=%d/%m/%Y %H:%M     ${display_format}=%Y-%m-%dT%H:%M:%S.%f
    ${input_date_str_len}=    Get Length    ${input_date_str}
    ${display_date_str_len}=    Get Length    ${display_date_str}
    ${input_date_str}=    Run Keyword If    ${input_date_str_len}>26    Get Substring    ${input_date_str}    0    -1    ELSE    Set Variable    ${input_date_str}
    ${display_date_str}=    Run Keyword If    ${display_date_str_len}>26    Get Substring    ${display_date_str}    0    -1    ELSE    Set Variable    ${display_date_str}
    ${input_date_str}=    Convert Date    ${input_date_str}    date_format=${input_format}    exclude_millis=True
    ${display_date_str}=    Convert Date    ${display_date_str}    date_format=${display_format}    exclude_millis=True
    ${input_date}=    Convert Date    ${input_date_str}    datetime
    ${display_date}=    Convert Date    ${display_date_str}    datetime
    KV Should Be Equal As Integers    ${input_date.year}    ${display_date.year}    Lỗi input year và display year khác nhau
    KV Should Be Equal As Integers    ${input_date.month}    ${display_date.month}    Lỗi input month và display month khác nhau
    KV Should Be Equal As Integers    ${input_date.day}    ${display_date.day}    Lỗi input day và display day khác nhau
    KV Should Be Equal As Integers    ${input_date.hour}    ${display_date.hour}    Lỗi input hour và display hour khác nhau
    KV Should Be Equal As Integers    ${input_date.minute}    ${display_date.minute}    Lỗi input minute và display minute khác nhau

# Kết hợp giữa value one và value two để tạo Unique Key, trong trường hợp file excel không có cột nào là Unique VD: kết hợp giữa mã phiếu và mã hàng
KV Set Unique Key
    [Arguments]    ${list_key_to_val_one}    ${list_key_to_val_two}
    ${list_unique_key}    Create List
    FOR    ${val_one}    ${val_two}    IN ZIP    ${list_key_to_val_one}    ${list_key_to_val_two}
        ${unique_key}    Set Variable    ${val_one}-${val_two}
        Append To List    ${list_unique_key}    ${unique_key}
    END
    Return From Keyword    ${list_unique_key}

# Convert thoi gian dang string sang datetime
Convert string datetime in API to datetime type
    [Arguments]    ${input_datetime}    ${date_format}=%Y-%m-%dT%H:%M:%S.%f
    ${length}=    Get Length    ${input_datetime}
    ${input_datetime}=    Run Keyword If    ${length}>26    Get Substring    ${input_datetime}    0    -1    ELSE    Set Variable    ${input_datetime}
    ${result_datetime}=   Convert Date    ${input_datetime}    result_format=datetime    date_format=${date_format}
    Return From Keyword    ${result_datetime}

# Convert list datetime sang dạng string
KV Convert DateTime To String
    [Arguments]    ${list_datetime}    ${date_format}=%Y-%m-%dT%H:%M:%S.%f    ${result_format}=%Y-%m-%d %H:%M:%S.%f
    ${result_list}    Create List
    FOR    ${input_datetime}    IN    @{list_datetime}
        ${str_datetime}    KV Convert DateTime From API To 24h Format String    ${input_datetime}    ${date_format}    ${result_format}
        Append To List    ${result_list}    ${str_datetime}
    END
    Return From Keyword    ${result_list}

KV Convert DateTime From API To 24h Format String
    [Arguments]    ${input_datetime}    ${date_format}=%Y-%m-%d %H:%M:%S.%f    ${result_format}=%d/%m/%Y %H:%M:%S

    ${input_datetime}=       Convert To String    ${input_datetime}
    ${length}=    Get Length    ${input_datetime}
    ${input_datetime}=    Run Keyword If    ${length}>26    Get Substring    ${input_datetime}    0    -1    ELSE    Set Variable    ${input_datetime}
    ${result_datetime}=   Run Keyword If    '${input_datetime}' !='0'   Convert Date    ${input_datetime}    result_format=${result_format}    date_format=${date_format}
    ...    ELSE    Convert To Integer    ${input_datetime}

    ${str_datetime}=       Convert To String    ${result_datetime}
    Return From Keyword    ${str_datetime}

KV Convert DateTime From API To 12h Format String
    [Arguments]    ${input_datetime}    ${is_VnText}=False    ${zero_in_hour}=True

    ${input_datetime}=       Convert To String    ${input_datetime}
    ${length}=    Get Length    ${input_datetime}
    ${input_datetime}=    Run Keyword If    ${length}>26    Get Substring    ${input_datetime}    0    -1    ELSE    Set Variable    ${input_datetime}
    ${result_datetime}=   Run Keyword If    '${input_datetime}' !='0'   Convert Date    ${input_datetime}    datetime

    ${midday_text}    Run Keyword If    ${result_datetime.hour}>=12 and '${is_VnText}'=='False'    Set Variable    PM
    ...    ELSE IF    ${result_datetime.hour}>=12 and '${is_VnText}'=='True'    Set Variable    CH
    ...    ELSE IF    ${result_datetime.hour}<12 and '${is_VnText}'=='False'    Set Variable    AM
    ...    ELSE    Set Variable    SA

    ${midday_datetime}    Run Keyword If    ${result_datetime.hour}>12 and ('${midday_text}'=='PM' or '${midday_text}'=='CH')    Subtract Time From Date    ${input_datetime}    12 hour
    ...    ELSE    Set Variable    ${input_datetime}

    ${inject_string}    Run KeyWord If    '${zero_in_hour}'=='False'    Set Variable    _    ELSE    Set Variable    ${EMPTY}
    ${result_excel}=   Run Keyword If    '${input_datetime}' !='0'   Convert Date   ${midday_datetime}    result_format=%d/%m/%Y ${inject_string}%H:%M:%S
    ...    ELSE    Convert To Integer    ${input_datetime}

    ${result_excel}=    Run KeyWord If    '${zero_in_hour}'=='False'    Replace String    ${result_excel}    ${inject_string}0    ${EMPTY}    ELSE    Set Variable    ${result_excel}
    ${result_excel}=    Run KeyWord If    '${zero_in_hour}'=='False'    Replace String    ${result_excel}    ${inject_string}    ${EMPTY}    ELSE    Set Variable    ${result_excel}

    ${str_datetime}=       Convert To String    ${result_excel} ${midday_text}
    Return From Keyword    ${str_datetime}

KV Convert DateTime To Epoch Time
    [Arguments]    ${date_time}
    ${result_time}    Convert Date    ${date_time}    epoch
    ${result_time}    Multiplication    ${result_time}    1000
    ${result_time}    Convert To Integer    ${result_time}
    Log    ${result_time}
    Return From Keyword    ${result_time}

KV Make Filter HangHoa Params
    [Arguments]    ${loai_hang}=${EMPTY}    #All - tất cả loại hang; HHT - HH thường; HHSX - HH SanXuat; HHDV - HH DichVu; HHCBDG - HH Combo; HHCB - HH CheBien
    ...            ${ten_ma_hang_hoa}=${EMPTY}    #ten_ma_hang
    ...            ${id_nhom_hang}=${EMPTY}    #Id nhom hang
    ...            ${loai_thuc_don}=${EMPTY}    #Loai Thuc Don:  ALL - Tất cả; FOOD - Đồ ăn; DRINK - Đồ uống; OTHER - Khác
    ...            ${thuoc_tinh}=[]    #[{"Id":1470,"Name":"bbb"},{"Id":1471,"Name":"RRR"}]
    ...            ${vi_tri}=${EMPTY}    #Id vi tri cach nhau boi dau phay vi du 1141,1139
    ...            ${tinh_trang_kinh_doanh}=True    #False ngung kinh doanh; True dang kinh doanh; All tat ca
    ...            ${ton_kho}=0    #3: còn hàng trong kho       1: dưới định mức tồn    4: hết hàng trong kho    2:  vượt định mức tồn
    ...            ${trang}=1
    ...            ${so_ban_ghi}=1
    ...            ${master_product_id}=${EMPTY}
    ${params}    Create List    format=json    Includes=ProductAttributes
    Run Keyword If    '${master_product_id}'!='${EMPTY}'    Append To List    ${params}    MasterProductId=${master_product_id}
    ...    ELSE    Append To List    ${params}    ForSummaryRow=true
    #Nhom Hang
    Append To List    ${params}    CategoryId=${id_nhom_hang}
    #Thuoc Tinh
    ${thuoc_tinh_encode}    Evaluate    urllib.parse.quote('${thuoc_tinh}')    urllib
    Append To List    ${params}    AttributeFilter=${thuoc_tinh_encode}
    #Tim kiem theo ten/ma
    Run Keyword If    '${ten_ma_hang_hoa}'!='${EMPTY}'    Append To List    ${params}    KeyWord=${ten_ma_hang_hoa}
    #Nhóm Hàng
    Run Keyword If    '${loai_thuc_don}'=='ALL'    Append To List    ${params}    ProductGroups=%5B1%2C2%2C3%5D
    ...    ELSE If    '${loai_thuc_don}'=='FOOD'    Append To List    ${params}    ProductGroups=%5B1%5D
    ...    ELSE If    '${loai_thuc_don}'=='DRINK'    Append To List    ${params}    ProductGroups=%5B2%5D
    ...    ELSE If    '${loai_thuc_don}'=='OTHER'    Append To List    ${params}    ProductGroups=%5B3%5D
    #Loai Hang
    Run Keyword If    '${loai_hang}'=='HHT'    Append To List    ${params}    ProductTypes=2
    ...    ELSE If    '${loai_hang}'=='HHSX'    Append To List    ${params}    ProductTypes=%2C2
    ...    ELSE If    '${loai_hang}'=='HHDV'    Append To List    ${params}    ProductTypes=3
    ...    ELSE If    '${loai_hang}'=='HHCBDG'    Append To List    ${params}    ProductTypes=1
    ...    ELSE If    '${loai_hang}'=='HHCB'    Append To List    ${params}    ProductTypes=%2C1
    ...    ELSE IF    '${loai_hang}'=='ALL'    Append To List    ${params}    ProductTypes=1%2C2%2C3
    ...    ELSE    Append To List    ${params}    ProductTypes=

    Append To List    ${params}    IsImei=2

    Run Keyword If    '${loai_hang}'=='HHT'    Append To List    ${params}    IsFormulas=0
    ...    ELSE If    '${loai_hang}'=='HHSX'    Append To List    ${params}    IsFormulas=1
    ...    ELSE If    '${loai_hang}'=='HHDV'    Append To List    ${params}    IsFormulas=2
    ...    ELSE If    '${loai_hang}'=='HHCBDG'    Append To List    ${params}    IsFormulas=2
    ...    ELSE If    '${loai_hang}'=='HHCB'    Append To List    ${params}    IsFormulas=2
    ...    ELSE IF    '${loai_hang}'=='ALL'    Append To List    ${params}    IsFormulas=2

    Run Keyword If    '${loai_hang}'=='HHCBDG'    Append To List    ${params}    IsProcessedGoods=false
    ...    ELSE If    '${loai_hang}'=='HHCB'    Append To List    ${params}    IsProcessedGoods=true
    #Vi Tri
    ${vi_tri_encode}    Evaluate    urllib.parse.quote('${vi_tri}')    urllib
    Append To List    ${params}    ShelvesIds=${vi_tri_encode}
    #Tinh Trang Kinh Doanh
    Run Keyword If    '${tinh_trang_kinh_doanh}'=='False'    Append To List    ${params}    IsActive=false
    ...    ELSE IF    '${tinh_trang_kinh_doanh}'=='True'    Append To List    ${params}    IsActive=true
    #Ton Kho
    Run Keyword If    ${ton_kho}>0    Append To List    ${params}    OnhandFilter=${ton_kho}
    #So Ban Ghi
    Append To List    ${params}    take=${so_ban_ghi}
    Append To List    ${params}    skip=0
    #Trang
    Append To List    ${params}    page=${trang}
    #So Ban Ghi
    Append To List    ${params}    pageSize=${so_ban_ghi}
    Append To List    ${params}    filter%5Blogic%5D=and
    [Return]    ${params}

KV Download Should Be Done
    [Arguments]    ${directory}=${global_download_dir}
    [Documentation]    Verifies that the directory has only one folder and it is not a temp file and returns path to the file
    ${files} =    List Files In Directory    ${directory}
    Length Should Be    ${files}    1    Lỗi thư mục có ít hoặc nhiều hơn 1 file
    Should Not Match Regexp    ${files[0]}    (?i).*\\.tmp           Lỗi folder chứa file có đuôi .tmp
    Should Not Match Regexp    ${files[0]}    (?i).*\\.crdownload    Lỗi folder chứa file có đuôi .crdownload
    ${file}    Join Path    ${directory}    ${files[0]}
    KV Log    File was successfully downloaded to ${file}
    [Return]    ${file}

KV Wait Until File Download is Finished
    [Timeout]    3 mins
    [Arguments]    ${directory}=${global_download_dir}
    ${fileName} =    Wait Until Keyword Succeeds    10 times    3s    KV Download Should Be Done    ${directory}
    [Return]    ${fileName}

KV Choose Import Excel File And Assert UI Successfully
    [Arguments]    ${import_filepath}    ${import_file}    ${is_has_notiboard}=False
    ${button_chon_file}    FNB GetLocator Menu Button Chon File DuLieu
    Choose File    ${button_chon_file}    ${import_filepath}
    FNB Menu Button ThucHien Import    True
    Wait Until Element Is Not Visible    ${button_chon_file}
    Run Keyword If    '${is_has_notiboard}' == 'True'    KV Assert UI Import Successfully    ${import_file}

KV Assert UI Import Successfully
    [Arguments]    ${import_file}
    FNB WaitVisible Menu Import Export NotiBoard
    ${loc_filename}    FNB GetLocator Menu ImEx FileName Firstitem
    ${gettext_filename}    Get Text    ${loc_filename}
    KV Should Be Equal As Strings    ${import_file}    ${gettext_filename}    Lỗi tên file import prepare và tên file hiển thị trên UI khác nhau
    Import Product success validation
    FNB Menu Icon Close NotiBoard

Get a value in one line
    [Documentation]    Lấy ra nội dung dòng dữ liệu mà chứa giá trị lable_line truyền vào, sau đó remove string lable_line
    ...    ví dụ: lable_line là: Tiền khách đưa, Dòng dữ liệu trong content_pdf là: Tiền khách đưa 600,000
    ...    Kết quả sẽ trả ra: 600000
    [Arguments]    ${content_pdf}    ${lable_line}
    ${line_content}    Get Lines Containing String    ${content_pdf}    ${lable_line}
    ${value_string}    Remove String     ${line_content}    ${lable_line}
    ${value_string}    Replace String    ${value_string}    ,    ${EMPTY}
    ${value_string}    Strip String      ${value_string}
    Return From Keyword    ${value_string}

#====================================================================================
Close Popup Mo ban Nhap
    ${loc_title_mo_bannhap}    FNB GetLocator Menu Title Popup Mo Ban Nhap
    ${count}    Get Element Count    ${loc_title_mo_bannhap}
    Run Keyword If    ${count} > 0    FNB Menu Button BoQua Mo Ban Nhap

# Tạo mã phiếu với prefix truyền vào
Set Code With Current Date
    [Arguments]    ${prefix_code}    ${is_milli_second}=False
    ${date}    Get Current Date
    ${date}    Run Keyword If    '${is_milli_second}'=='False'    Convert Date    ${date}    result_format=%d%m%y%H%M%S
    ...    ELSE    Convert Date    ${date}    result_format=%d%m%y%H%M%S%MS
    ${result_code}    Set Variable    ${prefix_code}${date}
    Return From Keyword    ${result_code}

# UUid là chuỗi số gồm 17 kí tự: lấy ngày tháng năm, giờ phút giây hiện tại + 3 con số random
Set Uuid With Current Date
    ${date}    Get Current Date
    ${date}    Convert Date    ${date}    result_format=%d%m%Y%H%M%S
    ${date}    Convert To String    ${date}
    ${random_num}    Generate Random String    3    [NUMBERS]
    ${result_uuid}    Set Variable    ${date}${random_num}
    Return From Keyword    ${result_uuid}

# Get số lượng hiển thị trên 1 trang
Get page size number
    ${page_size}    FNB HH ListHH Text So HH Tren Trang
    ${page_size}    Set Variable If    ${page_size} > 0    ${page_size}    15
    Return From Keyword    ${page_size}

# Check export thành công và trả về đường dẫn file
Check export successfully and return file path
    [Arguments]    ${directory}=${global_download_dir}
    # Nếu hiển thị icon tích xanh tức là file excel ready for downloading
    FNB WaitVisible Menu Import Export Icon Success    wait_time_out=2 mins
    # Nếu file download xuất hiện trong thư mục thì sẽ trả về true, ngược lại là false
    ${status_export}    Run Keyword And Return Status    KV Wait Until File Download is Finished    ${directory}
    # Nếu status khác true thì bấm vào "Click để tải xuống"
    Run Keyword If    '${status_export}'!='True'    FNB Menu Export NotiContent Firstitem
    # lấy ra đường dẫn đến file đã được export thành công trong folder
    ${export_filepath}    KV Wait Until File Download is Finished    ${directory}
    # Lấy ra tên file được export trên NotiBoard
    ${locator_filename}    FNB GetLocator Menu ImEx FileName Firstitem
    ${notiboard_filename}=    Get Text    ${locator_filename}
    ${notiboard_filepath}    Set Variable    ${global_download_dir}${/}${notiboard_filename}
    KV Compare Scalar Values    ${export_filepath}    ${notiboard_filepath}    Lỗi tên file downloaded và tên file trên NotiBoard khác nhau
    [Return]    ${export_filepath}

Convert text to number and assert
    [Arguments]    ${locator_item}    ${count_item}
    ${gettext_item}    Convert text to number frm locator    ${locator_item}
    KV Should Be Equal As Numbers    ${gettext_item}    ${count_item}    Lỗi dữ liệu hiển thị trên UI và dữ liệu tính toán khác nhau

Convert text to number frm locator
    [Arguments]    ${locator_item}
    KV Wait Until Element Is Stable    ${locator_item}
    ${gettext_item}    Get Text    ${locator_item}
    ${gettext_item}    Replace String    ${gettext_item}    ,    ${EMPTY}
    ${gettext_item}    Convert To Number    ${gettext_item}
    [Return]    ${gettext_item}

Convert text to string frm locator
    [Arguments]    ${locator_item}
    KV Wait Until Element Is Stable    ${locator_item}
    ${gettext_item}    Get Text    ${locator_item}
    ${gettext_item}    Strip String     ${gettext_item}
    ${gettext_item}    Replace String    ${gettext_item}    ,    ${EMPTY}
    [Return]    ${gettext_item}

KV Convert List Type From Number To VN String
    [Arguments]    ${list_type_num}    ${dict_num_str}
    ${result_list}    Create List
    FOR    ${item_type_num}    IN    @{list_type_num}
        ${result_type}    Set Variable    ${dict_num_str["${item_type_num}"]}
        Append To List    ${result_list}    ${result_type}
    END
    Log    ${result_list}
    Return From Keyword    ${result_list}

KV Swap between negative number and positive number
    [Arguments]    ${list_number}
    ${result_list}    Create List
    FOR    ${item_number}    IN ZIP    ${list_number}
        ${result_number}    Minus    0    ${item_number}
        Append To List    ${result_list}    ${result_number}
    END
    Log    ${result_list}
    Return From Keyword    ${result_list}

Convert EN Method To VI
    [Arguments]   ${method}
    ${type_method}    Evaluate    type($method).__name__
    ${list_method}    Run Keyword If    '${type_method}'=='list'    Set Variable    ${method}    ELSE    Create List    ${method}
    ${list_method_convert}    Create List
    FOR    ${item}    IN    @{list_method}
        ${result_method}    Run Keyword If    '${item}'=='Card'       Set Variable    Thẻ
        ...                        ELSE IF    '${item}'=='Transfer'   Set Variable    Chuyển khoản
        ...                        ELSE IF    '${item}'=='Cash'       Set Variable    Tiền mặt
        ...                        ELSE IF    '${item}'=='Point'      Set Variable    Điểm
        Append To List    ${list_method_convert}    ${result_method}
    END
    ${return_method}    Run Keyword If    '${type_method}'=='list'    Set Variable    ${list_method_convert}    ELSE    Set Variable    ${list_method_convert[0]}
    Return From Keyword    ${return_method}

Convert VI Method To EN
    [Arguments]   ${method}
    ${type_method}    Evaluate    type($method).__name__
    ${list_method}    Run Keyword If    '${type_method}'=='list'    Set Variable    ${method}    ELSE    Create List    ${method}
    ${list_method_convert}    Create List
    FOR    ${item}    IN    @{list_method}
        ${result_method}    Run Keyword If    '${item}'=='Thẻ'            Set Variable    Card
        ...                        ELSE IF    '${item}'=='Chuyển khoản'   Set Variable    Transfer
        ...                        ELSE IF    '${item}'=='Tiền mặt'       Set Variable    Cash
        ...                        ELSE IF    '${item}'=='Điểm'           Set Variable    Point
        Append To List    ${list_method_convert}    ${result_method}
    END
    ${return_method}    Run Keyword If    '${type_method}'=='list'    Set Variable    ${list_method_convert}    ELSE    Set Variable    ${list_method_convert[0]}
    Return From Keyword    ${return_method}

KV Convert String Null To Number Zero
    [Arguments]    ${list_string}
    ${result_list}    Create List
    FOR    ${item_string}    IN    @{list_string}
        ${item_string}    Run Keyword If     '${item_string}'=='${EMPTY}'    Set Variable    ${0}
        ...    ELSE    Set Variable    ${item_string}
        Append To List    ${result_list}    ${item_string}
    END
    Log    ${result_list}
    Return From Keyword    ${result_list}

KV Get data Filter Of Report
    [Arguments]    ${id_chi_nhanh}
    ${selected_date}    Get Current Date
    ${trans_date}    Subtract Time From Date    ${selected_date}    1 day
    ${selected_date}    Convert Date    ${selected_date}    %Y-%m-%dT17:00:00.000Z
    ${trans_date}       Convert Date    ${trans_date}       %Y-%m-%dT17:00:00.000Z
    ${filter_data}    Set Variable    {"MethodPay":[],"currentBranchIds":[${id_chi_nhanh}],"BranchIds":[${id_chi_nhanh}],"TimeRange":"other","CashGroupTypeIds":[],"TableIds":[],"TempTableIds":[],"DiningOptions":[],"TableBranchIds":[${id_chi_nhanh}],"ForAllBranch":false,"CurrentDeliveryMethods":[],"FilterDataRefreshPromiseQueue":[],"TransDate":"${trans_date}","selectDay":"${trans_date}","EndDate":"${selected_date}","StartDate":"${trans_date}","dateLable":"Lựa chọn khác ","typeDate":"choose","timeStamp":"0"}
    Return From Keyword    ${filter_data}

API Get Report Data
    [Arguments]    ${filter_data}    ${report_type}
    # API Post lấy client id
    ${client_dict}    API Call From Template    /bao-cao/report_client.txt    json_path=$.clientId    session_alias=session_reportapi
    ${client_id}    Set Variable Return From Dict    ${client_dict.clientId[0]}

    # API Post gửi parameter lên server
    ${parameter_values}    Create Dictionary    filter=${filter_data}
    ${data_dict}    Create Dictionary    report=${report_type}    parameterValues=${parameter_values}
    ${header}    Create Dictionary    Authorization=${bearertoken}    Content-Type=application/json    kv-version=${kv_version}    retailer=${RETAILER}
    ${response}    Post Request    session_reportapi    /report/reports/clients/${client_id}/parameters    data=${data_dict}    headers=${header}
    KV Should Be Equal As Strings    ${response.status_code}    200    Lỗi response status code expected và actual khác nhau
    Log    ${response.json()}

    # API Post lấy instance id
    ${res_instances}    Post Request    session_reportapi    /report/reports/clients/${client_id}/instances    data=${data_dict}    headers=${header}
    KV Should Be Equal As Strings    ${res_instances.status_code}    201    Lỗi response status code expected và actual khác nhau
    ${val_instance}    Get Value From Json    ${res_instances.json()}    $.instanceId
    ${instance_id}    Set Variable    ${val_instance[0]}

    # API Post lấy document id
    ${doc_payload}    Set Variable    {"format":"HTML5Interactive","deviceInfo":{"ContentOnly":true,"UseSVG":true,"BasePath":"/reportapi/report/reports"},"useCache":true}
    ${res_documents}    Post Request    session_reportapi    /report/reports/clients/${client_id}/instances/${instance_id}/documents    data=${doc_payload}    headers=${header}
    KV Should Be Equal As Strings    ${res_documents.status_code}    202    Lỗi response status code expected và actual khác nhau
    ${val_document}    Get Value From Json    ${res_documents.json()}    $.documentId
    ${document_id}    Set Variable    ${val_document[0]}

    # API Get info
    FOR    ${i}    IN RANGE    10
        ${res_info}=    Get Request    session_reportapi
        ...    /report/reports/clients/${client_id}/instances/${instance_id}/documents/${document_id}/info    headers=${header}
        # Sleep để có đủ thời gian request lại - phù hợp với behavior của web
        Sleep    1s
        Log    ${res_info.status_code}
        # Không dùng KV Should Be Equal As Strings ở đây để check điều kiện lặp
        ${status_request}    Run Keyword And Return Status    Should Be Equal As Strings    ${res_info.status_code}    200
        Exit For Loop If    '${status_request}'=='True'
    END

    KV Should Be Equal As Strings    ${res_info.status_code}    200    Lỗi response status code expected và actual khác nhau

    ${val_info}    Get Value From Json    ${res_info.json()}    $.["documentReady","pageCount"]
    ${document_ready}    Set Variable    ${val_info[0]}
    ${page_count}        Set Variable    ${val_info[1]}

    # API Get dữ liệu của báo cáo theo page
    ${list_pageContent}    Create List
    FOR    ${page_item}    IN RANGE    1    ${page_count}+1
        ${input_data_report}    Create Dictionary    client_id=${client_id}    instance_id=${instance_id}    document_id=${document_id}    page=${page_item}
        ${info_dict}    API Call From Template    /bao-cao/report_page.txt    ${input_data_report}    json_path=$.["pageReady","pageNumber","pageContent"]    session_alias=session_reportapi
        ${pageReady}    Set Variable Return From Dict    ${info_dict.pageReady[0]}
        ${pageNumber}    Set Variable Return From Dict    ${info_dict.pageNumber[0]}
        ${pageContent}    Set Variable    ${info_dict.pageContent[0]}
        KV Should Be Equal As Strings    ${pageReady}    True    Lỗi pageReady khác True
        Append To List    ${list_pageContent}    ${pageContent}
    END
    Log    ${list_pageContent}
    Return From Keyword    ${list_pageContent}

KV Read Excel As List Data Row
    [Arguments]     ${excel_path}    ${sheet_name}
    Open Excel Document    ${excel_path}    doc_id
    ${excel_data}    Create List
    ${list_title}    Read Excel Row    1    sheet_name=${sheet_name}
    Remove Values From List    ${list_title}    None
    ${total_col}    Get Length    ${list_title}
    ${total_col}    Evaluate    ${total_col}+1
    FOR    ${row}    IN RANGE    2    10000
        ${first_cell_item}    Read Excel Cell    ${row}    1    ${sheet_name}
        Exit For Loop If    '${first_cell_item}'=='None'
        ${is_comment_row}    Run Keyword And Return Status    Should Contain    ${first_cell_item}    \#
        Continue For Loop If    '${is_comment_row}'=='True'
        ${data_item}    KV Read Each Cell In Excel File    ${sheet_name}    ${row}    ${total_col}
        Append To List    ${excel_data}    ${data_item}
    END
    Close All Excel Documents
    ${length}    Get Length    ${excel_data}
    Return From Keyword    ${excel_data}    ${length}

KV Read Each Cell In Excel File
    [Arguments]    ${sheet_name}    ${row}    ${total_col}
    ${list_row_data}    Create List
    FOR    ${coll}    IN RANGE    1    ${total_col}
        ${title_coll}    Read Excel Cell    1    ${coll}    ${sheet_name}
        Continue For Loop If    '${title_coll}'=='None'
        ${cell_data}    Read Excel Cell    ${row}    ${coll}    ${sheet_name}
        ${type_value}    Evaluate    type($cell_data).__name__
        ${cell_data}    Run Keyword If    '${type_value}'=='str'    Strip String    ${cell_data}    ELSE    Set Variable    ${cell_data}
        ${is_empty_value}    Run Keyword And Return Status    Should Be Equal As Strings    ${cell_data}    \${EMPTY}
        ${real_value}    Run Keyword If    '${is_empty_value}'=='False'    KV Get Real Value In Excel Coll    ${title_coll}    ${cell_data}
        ...    ELSE    Set Variable    \${EMPTY}
        Append To List    ${list_row_data}    ${real_value}
    END
    Return From Keyword    ${list_row_data}

KV Get Real Value In Excel Coll
    [Arguments]    ${title_coll}    ${cell_data}
    ${sub_title}    Split String    ${title_coll}    separator=_
    ${result_value}    Run Keyword If    '${sub_title[0]}'=='LIST'    KV Convert Excel Text To List    ${cell_data}
    ...    ELSE IF    '${sub_title[0]}'=='DICT'         KV Convert Excel Text To Dictionary    ${cell_data}
    ...    ELSE IF    '${sub_title[0]}'=='LIST DICT'    KV Convert Excel Text To List Dictionary    ${cell_data}
    ...    ELSE IF    '${sub_title[0]}'=='DICT LIST'    KV Convert Excel Text To Dictionary-List Value    ${cell_data}
    ...    ELSE    Set Variable    ${cell_data}
    ${type}    Evaluate    type($result_value).__name__
    Return From Keyword    ${result_value}

KV Set Data For Input Dict Events
    [Arguments]    ${input_dict}    ${key_ver}    ${str_data}
    ${type_input_dict}    Evaluate    type($input_dict).__name__
    ${input_dict}    Run Keyword If    '${type_input_dict}'!='DotDict'    Create Dictionary    ELSE    Set Variable    ${input_dict}
    # Set các key event_id, replica_id, version...
    Set To Dictionary    ${input_dict}    replica_id        ${replica_id}
    Set To Dictionary    ${input_dict}    firebase_token    ${firebase_token}
    ${gen_event_id}    Generate Random UUID
    Set To Dictionary    ${input_dict}    event_id_${key_ver}     ${gen_event_id}
    ${event_ver_item}    Evaluate    ${event_ver}+1
    Set Test Variable    ${event_ver}    ${event_ver_item}
    Set To Dictionary    ${input_dict}    event_${key_ver}    ${event_ver}
    ${ver_temp_exist}    Run Keyword And Return Status    Variable Should Exist    ${ver_temp}
    ${track_ver}    Run Keyword If    '${ver_temp_exist}'=='True'    Evaluate    ${ver_temp}+1
    ...    ELSE    Evaluate    ${version}+1
    Set To Dictionary    ${input_dict}    track_${key_ver}    ${track_ver}
    Set Test Variable    ${local_ver}    ${track_ver}
    Set Test Variable    ${ver_temp}    ${local_ver}
    # Convert datetime sang dạng epoch time và set key local_time luôn xuất hiện trong dictionary
    ${date_time}    Get Current Date
    ${result_time}    KV Convert DateTime To Epoch Time    ${date_time}
    Set To Dictionary    ${input_dict}    local_time    ${result_time}
    KV Log    ${input_dict}
    ${str_data}    Format String    ${str_data}    ${input_dict}
    KV Log    ${str_data}
    Return From Keyword    ${str_data}

KV Android Set Data For Input Dict Events
    [Arguments]    ${input_dict}    ${key_ver}    ${str_data}
    ${type_input_dict}    Evaluate    type($input_dict).__name__
    ${input_dict}    Run Keyword If    '${type_input_dict}'!='DotDict'    Create Dictionary    ELSE    Set Variable    ${input_dict}
    # Set các key event_id, replica_id, version...
    Set To Dictionary    ${input_dict}    replica_id        ${replica_id}
    ${gen_event_id}    Generate Random UUID
    Set To Dictionary    ${input_dict}    event_id_${key_ver}     ${gen_event_id}
    ${event_ver_item}    Evaluate    ${event_ver}+1
    Set Test Variable    ${event_ver}    ${event_ver_item}
    Set To Dictionary    ${input_dict}    event_${key_ver}    ${event_ver}
    ${ver_temp_exist}    Run Keyword And Return Status    Variable Should Exist    ${ver_temp}
    ${track_ver}    Run Keyword If    '${ver_temp_exist}'=='True'    Evaluate    ${ver_temp}+1
    ...    ELSE    Evaluate    ${version}+1
    Set To Dictionary    ${input_dict}    track_${key_ver}    ${track_ver}
    Set Test Variable    ${local_ver}    ${track_ver}
    Set Test Variable    ${ver_temp}    ${local_ver}
    # Convert datetime sang dạng epoch time và set key local_time luôn xuất hiện trong dictionary
    ${date_time}    Get Current Date
    ${result_time}    KV Convert DateTime To Epoch Time    ${date_time}
    Set To Dictionary    ${input_dict}    local_time    ${result_time}
    KV Log    ${input_dict}
    ${str_data}    Format String    ${str_data}    ${input_dict}
    KV Log    ${str_data}
    Return From Keyword    ${str_data}

KV Set Common Key Version
    [Arguments]    ${key_ver}
    ${cus_event_id_ver}   Set Variable    {0.event_id_${key_ver}}
    ${cus_track_ver}      Set Variable    {0.track_${key_ver}}
    ${cus_event_ver}      Set Variable    {0.event_${key_ver}}
    ${cus_local_time}     Set Variable    {0.local_time}
    Return From Keyword    ${cus_event_id_ver}    ${cus_track_ver}    ${cus_event_ver}    ${cus_local_time}

KV Set List Key Version
    [Arguments]    ${list_item}    ${start_index}=1
    ${list_key_ver}    Create List
    ${length}    Get Length    ${list_item}
    FOR    ${index}    IN RANGE    ${start_index}    ${length}+1
        ${key_item}    Set Variable If    ${index}==1    ver    ver${index}
        Append To List    ${list_key_ver}    ${key_item}
    END
    Return From Keyword    ${list_key_ver}

KV Convert Json String To Json Object And Return Dict
    [Documentation]    Nếu json_path==EMPTY thì sẽ trả về json Object
    ...                Nếu json_path!=EMPTY thì sẽ trả về dictionary
    [Arguments]    ${json_string}    ${json_path}=${EMPTY}
    @{json_str_split}   Split String    ${json_string}    \\"
    ${template_str}     Catenate    SEPARATOR=\\\\"    @{json_str_split}
    ${json_obj}         Evaluate     json.loads('''${template_str}''')    json
    ${type_json_path}   Evaluate    type($json_path).__name__
    ${json_paths}    Run Keyword If    '${type_json_path}'=='list'    Set Variable    ${json_path}    ELSE    Create List    ${json_path}
    ${return_data}   Run Keyword If    '${json_paths[0]}'!='${EMPTY}'    KV Get Data From Json by List Xpath    ${json_obj}    ${json_paths}    ELSE    Set Variable    ${json_obj}
    Return From Keyword    ${return_data}

# ============== KW Set Data ===============
KV Set Data Discount Type
    [Arguments]    ${discount_type}    ${gia_tri}
    ${data_discount}    Run Keyword If    '${discount_type}' == 'VND'    Set Variable    "DiscountType": "${discount_type}","Value": ${gia_tri},
    ...    ELSE IF    '${discount_type}' == '%'    Set Variable    "DiscountType": "${discount_type}","ValueRatio": ${gia_tri},
    Return From Keyword    ${data_discount}

Set startdate and end_date for filter in today
    ${StartDate}    Get Current Date     result_format=%Y-%m-%dT00:00:00
    ${end_date}    Add Time To Date	   ${StartDate}     1 days    exclude_millis=yes
    Return From Keyword    ${StartDate}    ${end_date}

Set startdate and end_date for filter in yesterday
    ${current_date}    Get Current Date     result_format=%Y-%m-%dT%H:%M:%S
    ${yesterday}    Add Time To Date	   ${current_date}     -1 days    exclude_millis=yes
    ${StartDate}    Convert Date    ${yesterday}    result_format=%Y-%m-%dT00:00:00
    ${end_date}    Add Time To Date	   ${StartDate}     1 days    exclude_millis=yes
    Return From Keyword    ${StartDate}    ${end_date}

KV Get Start End Date By Filter
    [Arguments]    ${time_filter}
    ${current_date}    Get Current Date    result_format=%Y/%m/%d
    ${start_date}    ${end_date}    Run Keyword If    '${time_filter}'=='today'       Set startdate and end_date for filter in today
    ...                                    ELSE IF    '${time_filter}'=='yesterday'   Set startdate and end_date for filter in yesterday
    ...                                    ELSE IF    '${time_filter}'=='thisweek'    KV Get This Week Range    ${current_date}
    ...                                    ELSE IF    '${time_filter}'=='thismonth'    KV Get This Month Range    ${current_date}
    ...                                    ELSE IF    '${time_filter}'=='alltime'    Set Variable    ${EMPTY}    ${EMPTY}
    ${start_date}    Run Keyword If    "${start_date}"!="${EMPTY}"    Convert Date    ${start_date}    result_format=%Y-%m-%dT00:00:00    ELSE    Set Variable    ${EMPTY}
    ${end_date}      Run Keyword If    "${end_date}"!="${EMPTY}"    Convert Date    ${end_date}      result_format=%Y-%m-%dT00:00:00    ELSE    Set Variable    ${EMPTY}
    Return From Keyword    ${start_date}    ${end_date}
