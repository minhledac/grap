*** Settings ***
Library           String
Library           DateTime
Library           Collections

*** Keywords ***
Multiplication
    [Arguments]    ${num1}    ${num2}
    ${num1}    Convert To Number    ${num1}    #sl
    ${num2}    Convert To Number    ${num2}    #gia
    ${result_ns}    Create Dictionary    x=${num1}    y=${num2}
    ${result}    Evaluate    x*y    namespace=${result_ns}
    Return From Keyword    ${result}

Multiplication and round 2
    [Arguments]    ${num1}    ${num2}
    [Timeout]    15 seconds
    ${num1}    Convert To Number    ${num1}    #sl
    ${num2}    Convert To Number    ${num2}    #gia
    ${result_ns}    Create Dictionary    x=${num1}    y=${num2}
    ${result_bf_replace}    Evaluate    x*y    namespace=${result_ns}
    ${result}=    Evaluate    round(${result_bf_replace}, 2)
    ${result}     Convert To Number    ${result}    0
    Return From Keyword    ${result}

Multiplication and round 4
    [Arguments]    ${num1}    ${num2}
    [Timeout]    15 seconds
    ${num1}    Convert To Number    ${num1}
    ${num2}    Convert To Number    ${num2}
    ${result_ns}    Create Dictionary    x=${num1}    y=${num2}
    ${result_bf_replace}    Evaluate    x*y    namespace=${result_ns}
    ${result}=    Evaluate    round(${result_bf_replace}, 4)
    ${result}     Convert To Number    ${result}
    Return From Keyword    ${result}

Sum
    [Arguments]    ${num1}    ${num2}    ${is_integer}=False
    ${num1}    Convert To Number    ${num1}
    ${num2}    Convert To Number    ${num2}
    ${result_ns}    Create Dictionary    x=${num1}    y=${num2}
    ${result}    Evaluate    x+y    namespace=${result_ns}
    ${result}    Run Keyword If    '${is_integer}'=='True'    Convert To Integer    ${result}    ELSE    Set Variable    ${result}
    Return From Keyword    ${result}

Sum values in list
    [Arguments]    ${list_values}
    ${indext_to_sum}    Set Variable    -1
    ${result_sum}    Set Variable    0
    FOR    ${item}    IN    @{list_values}
        ${indext_to_sum}    Evaluate    ${indext_to_sum} + 1
        ${item}    Get From List    ${list_values}    ${indext_to_sum}
        ${result_sum}    Sum    ${result_sum}    ${item}
    END
    Return From Keyword    ${result_sum}

Minus
    [Arguments]    ${num1}    ${num2}
    ${num1}    Convert To Number    ${num1}
    ${num2}    Convert To Number    ${num2}
    ${result_ns}    Create Dictionary    x=${num1}    y=${num2}
    ${result}    Evaluate    x-y    namespace=${result_ns}
    Return From Keyword    ${result}

Convert string with comma to number
    [Arguments]    ${param}
    ${param_type}    Evaluate    type($param).__name__
    ${value}    Run Keyword If    '${param_type}' == 'str'    Replace String    ${param}    ,    .    ELSE    Set Variable    ${param}
    ${value}    Convert To Number    ${value}
    Return From Keyword    ${value}

Price after % increase
    [Arguments]    ${num1}    ${num2}
    #loan
    ${num1}    Convert To Number    ${num1}
    ${num2}    Convert To Number    ${num2}
    ${result_ns}    Create Dictionary    x=${num1}    y=${num2}
    ${result}    Evaluate    x+((x*y)/100)    namespace=${result_ns}
    Return From Keyword    ${result}

Price after % discount convert
    [Arguments]    ${num1}    ${num2}
    #loan
    ${num1}    Convert To Number    ${num1}
    ${num2}    Convert To Number    ${num2}
    ${result_ns}    Create Dictionary    x=${num1}    y=${num2}
    ${result}    Evaluate    x-((x*y)/100)    namespace=${result_ns}
    Return From Keyword    ${result}

Computation new price - plus - VND
    [Arguments]    ${input_compare_value}    ${input_discount}
    ${new_price}    Sum    ${input_compare_value}    ${input_discount}
    Return From Keyword    ${new_price}

Computation new price - discount - VND
    [Arguments]    ${input_compare_value}    ${input_discount}
    ${new_price}    Minus    ${input_compare_value}    ${input_discount}
    ${result_new_price}=    Run Keyword If    ${new_price}<0    Set Variable    0   ELSE    Set Variable    ${new_price}
    Return From Keyword    ${result_new_price}

Computation new price - discount - %
    [Arguments]    ${input_compare_value}    ${input_discount}
    ${new_price}      Price after % discount convert    ${input_compare_value}    ${input_discount}
    ${new_price}    Convert To Number    ${new_price}   0
    Return From Keyword    ${new_price}

Computation new price - plus - %
    [Arguments]    ${input_compare_value}    ${input_discount}
    ${new_price}      Price after % increase    ${input_compare_value}    ${input_discount}
    ${new_price}    Convert To Number    ${new_price}   0
    Return From Keyword    ${new_price}

Convert % discount to VND
    [Arguments]    ${num1}    ${num2}
    ${num1}    Convert To Number    ${num1}
    ${num2}    Convert To Number    ${num2}
    ${result_ns}    Create Dictionary    x=${num1}    y=${num2}
    ${result}    Evaluate    (x*y)/100    namespace=${result_ns}
    Return From Keyword    ${result}

Convert VND discount to %
    [Arguments]    ${num1}    ${num2}    ${percision_number}
    ${num1}    Convert To Number    ${num1}
    ${num2}    Convert To Number    ${num2}
    ${result_ns}    Create Dictionary    x=${num1}    y=${num2}
    ${result}    Evaluate    (x*100)/y    namespace=${result_ns}
    ${result}    Evaluate    round(${result},${percision_number})
    Return From Keyword    ${result}

Divide OnHand
    [Arguments]    ${num1}    ${num2}
    ${num1}    Convert To Number    ${num1}
    ${num2}    Convert To Number    ${num2}
    ${result_ns}    Create Dictionary    x=${num1}    y=${num2}
    ${result}    Evaluate    x/y    namespace=${result_ns}
    ${result}=    Evaluate    round(${result}, 3)
    Return From Keyword    ${result}

Divide And Return Residual
    [Arguments]    ${num1}    ${num2}
    ${num1}    Convert To Integer    ${num1}
    ${num2}    Convert To Integer    ${num2}
    ${result_ns}    Create Dictionary    x=${num1}    y=${num2}
    ${result}    Evaluate    x/y    namespace=${result_ns}
    ${result}    Evaluate    round(${result}, 0)
    ${result}    Convert To Integer    ${result}
    ${residual}    Evaluate    x%y    namespace=${result_ns}
    Return From Keyword    ${result}    ${residual}

Generate code automatically
    [Arguments]    ${prefix_code}
    ${hex} =    Generate Random String    4    [NUMBERS]abcdef
    ${code}    Catenate    SEPARATOR=    ${prefix_code}    ${hex}
    Return From Keyword    ${code}

Get Ma Phieu In So quy
    [Arguments]    ${code}    ${prefix}
    ${get_ma_phieu}    Catenate    SEPARATOR=    ${prefix}    ${code}
    Return From Keyword    ${get_ma_phieu}

Convert boolean value to number and return value
    [Arguments]   ${item_data}
    ${item_data}=    Run Keyword If    '${item_data}'=='True'    Set Variable    1
    ...    ELSE    Set Variable    0
    Return From Keyword    ${item_data}

Computation discount allocation value
    [Arguments]    ${gia_nhap}    ${value}    ${tong_tien_hang}
    ${gia_nhap}    Convert To Number    ${gia_nhap}
    ${value}    Convert To Number    ${value}
    ${tong_tien_hang}    Convert To Number    ${tong_tien_hang}
    ${result_ns}    Create Dictionary    x=${gia_nhap}    y=${value}    z=${tong_tien_hang}
    ${result}    Evaluate    (x*y)/z    namespace=${result_ns}
    ${result}=    Evaluate    round(${result}, 4)
    Return From Keyword    ${result}

# Tính giá vốn của HH sau khi nhập hàng theo CT: Kết quả = ((Giá vốn gần nhất * Tồn kho gần nhất )+(Giá nhập cuối* Số lượng nhập))/(Tồn kho gần nhất+Số lượng nhập)
Computaion cost of product after purchase orders
    [Arguments]    ${ton_kho_nearest}    ${gia_von_nearest}    ${SL_nhap}    ${gia_nhap_cuoi}
    ${ton_kho_nearest}    Convert To Number    ${ton_kho_nearest}
    ${gia_von_nearest}    Convert To Number    ${gia_von_nearest}
    ${SL_nhap}            Convert To Number    ${SL_nhap}
    ${gia_nhap_cuoi}      Convert To Number    ${gia_nhap_cuoi}
    ${num1}    Evaluate    ${ton_kho_nearest}*${gia_von_nearest}
    ${num2}    Evaluate    ${SL_nhap}*${gia_nhap_cuoi}
    ${num3}    Sum    ${ton_kho_nearest}    ${SL_nhap}
    ${result_ns}    Create Dictionary    x=${num1}    y=${num2}    z=${num3}
    ${result_gia_von}    Evaluate    (x+y)/z    namespace=${result_ns}
    ${result_gia_von}=    Evaluate    round(${result_gia_von}, 2)
    Return From Keyword    ${result_gia_von}

# Tinh giá vốn ngầm của HH sau khi trả hàng nhập = [(giá vốn gần nhất * Tồn gần nhất) - (giá trả hàng nhập * SL trả)] / (tồn gần nhất - SL trả)
Computaion cost of product after purchase returns
    [Arguments]    ${ton_kho_nearest}    ${gia_von_nearest}    ${SL_tra}    ${gia_tra}
    ${ton_kho_nearest}   Convert To Number    ${ton_kho_nearest}
    ${gia_von_nearest}   Convert To Number    ${gia_von_nearest}
    ${SL_tra}            Convert To Number    ${SL_tra}
    ${gia_tra}           Convert To Number    ${gia_tra}
    ${num1}    Evaluate    ${ton_kho_nearest}*${gia_von_nearest}
    ${num2}    Evaluate    ${SL_tra}*${gia_tra}
    ${num3}    Minus       ${ton_kho_nearest}    ${SL_tra}
    ${result_ns}    Create Dictionary    x=${num1}    y=${num2}    z=${num3}
    ${result_gia_von}    Evaluate    (x-y)/z    namespace=${result_ns}
    ${result_gia_von}=    Evaluate    round(${result_gia_von}, 2)
    Return From Keyword    ${result_gia_von}
