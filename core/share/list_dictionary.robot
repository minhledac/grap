*** Settings ***
Library           SeleniumLibrary
Library           String
Library           BuiltIn
Library           Collections
Resource          computation.robot

*** Keywords ***
Reverse List one
    [Arguments]    ${list_one}
    ${copied_list_one}    Copy List    ${list_one}
    Reverse List    ${copied_list_one}
    Return From Keyword    ${copied_list_one}

Reverse two lists
    [Arguments]    ${list_one}    ${list_two}
    ${copied_list_one}    Copy List    ${list_one}
    ${copied_list_two}    Copy List    ${list_two}
    Reverse List    ${copied_list_one}
    Reverse List    ${copied_list_two}
    Return From Keyword    ${copied_list_one}    ${copied_list_two}

Reverse three lists
    [Arguments]    ${list_one}    ${list_two}    ${list_three}
    ${copied_list_one}      Copy List    ${list_one}
    ${copied_list_two}      Copy List    ${list_two}
    ${copied_list_three}    Copy List    ${list_three}
    Reverse List    ${copied_list_one}
    Reverse List    ${copied_list_two}
    Reverse List    ${copied_list_three}
    Return From Keyword    ${copied_list_one}    ${copied_list_two}    ${copied_list_three}

Reverse four lists
    [Arguments]    ${list_one}    ${list_two}    ${list_three}    ${list_four}
    ${copied_list_one}      Copy List    ${list_one}
    ${copied_list_two}      Copy List    ${list_two}
    ${copied_list_three}    Copy List    ${list_three}
    ${copied_list_four}     Copy List    ${list_four}
    Reverse List    ${copied_list_one}
    Reverse List    ${copied_list_two}
    Reverse List    ${copied_list_three}
    Reverse List    ${copied_list_four}
    Return From Keyword    ${copied_list_one}    ${copied_list_two}    ${copied_list_three}    ${copied_list_four}

Reverse five lists
    [Arguments]    ${list_one}    ${list_two}    ${list_three}    ${list_four}    ${list_five}
    ${copied_list_one}      Copy List    ${list_one}
    ${copied_list_two}      Copy List    ${list_two}
    ${copied_list_three}    Copy List    ${list_three}
    ${copied_list_four}     Copy List    ${list_four}
    ${copied_list_five}     Copy List    ${list_five}
    Reverse List    ${copied_list_one}
    Reverse List    ${copied_list_two}
    Reverse List    ${copied_list_three}
    Reverse List    ${copied_list_four}
    Reverse List    ${copied_list_five}
    Return From Keyword    ${copied_list_one}    ${copied_list_two}    ${copied_list_three}    ${copied_list_four}    ${copied_list_five}

Reverse six lists
    [Arguments]    ${list_one}    ${list_two}    ${list_three}    ${list_four}    ${list_five}    ${list_six}
    ${copied_list_one}      Copy List    ${list_one}
    ${copied_list_two}      Copy List    ${list_two}
    ${copied_list_three}    Copy List    ${list_three}
    ${copied_list_four}     Copy List    ${list_four}
    ${copied_list_five}     Copy List    ${list_five}
    ${copied_list_six}      Copy List    ${list_six}
    Reverse List    ${copied_list_one}
    Reverse List    ${copied_list_two}
    Reverse List    ${copied_list_three}
    Reverse List    ${copied_list_four}
    Reverse List    ${copied_list_five}
    Reverse List    ${copied_list_six}
    Return From Keyword    ${copied_list_one}    ${copied_list_two}    ${copied_list_three}    ${copied_list_four}    ${copied_list_five}    ${copied_list_six}

Reverse seven lists
    [Arguments]    ${list_one}    ${list_two}    ${list_three}    ${list_four}    ${list_five}    ${list_six}
    ...    ${list_seven}
    ${copied_list_one}      Copy List    ${list_one}
    ${copied_list_two}      Copy List    ${list_two}
    ${copied_list_three}    Copy List    ${list_three}
    ${copied_list_four}     Copy List    ${list_four}
    ${copied_list_five}     Copy List    ${list_five}
    ${copied_list_six}      Copy List    ${list_six}
    ${copied_list_seven}    Copy List    ${list_seven}
    Reverse List    ${copied_list_one}
    Reverse List    ${copied_list_two}
    Reverse List    ${copied_list_three}
    Reverse List    ${copied_list_four}
    Reverse List    ${copied_list_five}
    Reverse List    ${copied_list_six}
    Reverse List    ${copied_list_seven}
    Return From Keyword    ${copied_list_one}    ${copied_list_two}    ${copied_list_three}    ${copied_list_four}    ${copied_list_five}    ${copied_list_six}    ${copied_list_seven}

Convert List to String
    [Arguments]    ${list}    ${separator}=,
    ${string}    Evaluate    "${separator}".join($list)
    Return From Keyword    ${string}

Convert item in List to String
    [Arguments]    ${input_list}
    FOR    ${item}    IN    @{input_list}
        ${index}    Get Index From List    ${input_list}    ${item}
        ${str_item}    Convert To String    ${item}
        Set List Value    ${input_list}    ${index}    ${str_item}
    END
    Return From Keyword    ${input_list}

KV Convert Excel Text To List
    [Arguments]    ${cell_data}
    ${type_cell_data}    Evaluate    type($cell_data).__name__
    ${cell_data}=    Run Keyword If    '${type_cell_data}' == 'int'    Convert To String    ${cell_data}    ELSE    Set Variable    ${cell_data}
    ${list_value}    Split String    ${cell_data}    separator=;
    ${list_value}    Run Keyword If    '${type_cell_data}' == 'int'    Covert list string to number    ${list_value}    ELSE    Set Variable    ${list_value}
    Return From Keyword    ${list_value}

Covert list string to number
    [Arguments]    ${list_value}
    ${list_convert}    Create List
    FOR    ${value}    IN ZIP    ${list_value}
        Convert To Number    ${value}
        Append To List    ${list_convert}     ${value}
    END
    Return From Keyword    ${list_convert}

KV Convert Excel Text To Dictionary-List Value
    [Arguments]    ${cell_data}
    ${result_dict}    Create Dictionary
    ${list_cell_value}    Split String    ${cell_data}    separator=|
    FOR    ${value}    IN    @{list_cell_value}
        ${list_item}    Split String    ${value}    separator=:
        ${list_value}    KV Convert Excel Text To List    ${list_item[1]}
        Set To Dictionary    ${result_dict}    ${list_item[0]}    ${list_value}
    END
    Return From Keyword    ${result_dict}

KV Convert Excel Text To Dictionary
    [Arguments]    ${cell_data}
    ${result_dict}    Create Dictionary
    ${list_cell_value}    Split String    ${cell_data}    separator=|
    FOR    ${value}    IN    @{list_cell_value}
        ${list_item}    Split String    ${value}    separator=:
        Set To Dictionary    ${result_dict}    ${list_item[0]}    ${list_item[1]}
    END
    Return From Keyword    ${result_dict}

KV Convert Excel Text To List Dictionary
    [Arguments]    ${cell_data}
    ${result_list}    Create List
    ${tem_dict}    Create Dictionary
    ${list_cell_value}    Split String    ${cell_data}    separator=;
    FOR    ${value}    IN    @{list_cell_value}
        ${dict_item}    KV Convert String To Dictionary    ${value}
        Append To List    ${result_list}    ${dict_item}
    END
    Return From Keyword    ${result_list}

KV Convert String To Dictionary
    [Arguments]    ${input_str}
    ${result_dict}    Create Dictionary
    ${list_value}    Split String    ${input_str}    separator=|
    FOR    ${value}    IN    @{list_value}
        ${list_item}    Split String    ${value}    separator=:
        Set To Dictionary    ${result_dict}    ${list_item[0]}    ${list_item[1]}
    END
    Return From Keyword    ${result_dict}
