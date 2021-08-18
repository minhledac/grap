*** Settings ***
Resource          ../../api_access.robot
Library           Collections

*** Keywords ***
# Lấy danh sách all phòng bàn filter: Tất cả trạng thái
Get dict all table info frm API
    [Arguments]   ${list_jsonpath}    ${so_ban_ghi}=${EMPTY}    ${branch_id}=${EMPTY}
    ${input_dict}    Create Dictionary    so_ban_ghi=${so_ban_ghi}
    ${result_dict}    Run Keyword If    '${branch_id}'=='${EMPTY}'    API Call From Template    /phong-ban/all_phong_ban.txt    ${input_dict}   ${list_jsonpath}
    ...    ELSE    API Call From Template    /phong-ban/all_phong_ban.txt    ${input_dict}   ${list_jsonpath}    input_branch_id=${branch_id}
    Return From Keyword    ${result_dict}

Get dict all group table info frm API
    [Arguments]   ${list_jsonpath}
    ${result_dict}    API Call From Template    /phong-ban/all_nhom_phongban.txt    ${EMPTY}   ${list_jsonpath}
    Return From Keyword    ${result_dict}

Get all table name
    ${result_dict}    Get dict all table info frm API    $.Data[*].Name    branch_id=${BRANCH_ID}
    ${list_table_name}    Set Variable Return From Dict    ${result_dict.Name}
    Return From Keyword    ${list_table_name}

Get table id by name
    [Arguments]    ${table_name}    ${branch_id}=${BRANCH_ID}
    ${result_dict}    Get dict all table info frm API    $.Data[?(@.Name\=\="${table_name}")].Id    branch_id=${branch_id}
    ${table_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${table_id}

Get table id and table group by table name
    [Arguments]    ${table_name}
    ${result_dict}    Get dict all table info frm API    $.Data[?(@.Name\=\="${table_name}")].["Id","TableGroup.Name"]    branch_id=${BRANCH_ID}
    ${table_group}    Set Variable Return From Dict    ${result_dict.Name[0]}
    ${table_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${table_id}    ${table_group}

Get list table id by branch id
    [Arguments]    ${branch_id}
    ${dict_table}    Get dict all table info frm API    $.Data[?(@.Id>0)].Id    branch_id=${branch_id}
    ${list_id}    Set Variable Return From Dict    ${dict_table.Id}
    Return From Keyword    ${list_id}

Get list table id by index
    [Arguments]    ${list_table_name}    ${branch_id}=${EMPTY}
    ${dict_table}    Get dict all table info frm API    $.Data[*].["Id","Name"]    branch_id=${branch_id}
    ${list_table_id}    Create List
    FOR    ${item_tablename}    IN ZIP    ${list_table_name}
        ${index}    Get Index From List    ${dict_table.Name}    ${item_tablename}
        Continue For Loop If    ${index}==-1
        ${table_id}    Set Variable Return From Dict    ${dict_table.Id[${index}]}
        Append To List    ${list_table_id}    ${table_id}
    END
    Return From Keyword    ${list_table_id}

Get table group by name
    [Arguments]    ${table_name}
    ${result_dict}    Get dict all table info frm API    $.Data[?(@.Name\=\="${table_name}")].TableGroup.Name
    ${table_group}    Set Variable Return From Dict    ${result_dict.Name[0]}
    Return From Keyword    ${table_group}

Get table status by name
    [Arguments]    ${table_name}
    ${result_dict}    Get dict all table info frm API    $.Data[?(@.Name\=\="${table_name}")].IsActive
    ${table_is_active}    Set Variable Return From Dict    ${result_dict.IsActive[0]}
    ${table_status}    Run Keyword If    '${table_is_active}'=='True'    Set Variable    Đang hoạt động
    ...    ELSE    Set Variable    Ngừng hoạt động
    Return From Keyword    ${table_status}

Get table group id by group name
    [Arguments]    ${group_name}
    ${result_dict}    Get dict all group table info frm API    $.Data[?(@.Name\=\="${group_name}")].Id
    ${group_id}    Set Variable Return From Dict    ${result_dict.Id[0]}
    Return From Keyword    ${group_id}

# lấy dữ liệu phòng bàn ra đưa vào dict, status_text là trạng thái theo kiểu text hoặc số VD: Đang hoạt động hoặc 1
Get all tableroom data frm API
    [Arguments]    ${list_ten_ban}    ${status_text}=False

    ${dict_tableroom}    Get dict all table info frm API    $.Data[*].["Name","Description","TableGroup.Name","NumberSeat","IsActive","Position"]

    ${dict_api_pb}    Create Dictionary    ten_ban=@{EMPTY}
    ...     ghi_chu=@{EMPTY}
    ...     nhom_pb=@{EMPTY}
    ...     so_ghe=@{EMPTY}
    ...     trang_thai=@{EMPTY}
    ...     so_thu_tu=@{EMPTY}

    FOR    ${input_ten_ban}    IN ZIP    ${list_ten_ban}
        Run Keyword If    '${input_ten_ban}'=='0'    Continue For Loop    #ten ban =0 thi bo qua
        Phong Ban Data API    ${input_ten_ban}    ${dict_tableroom}    ${dict_api_pb}    ${status_text}
    END
    KV Log    ${dict_api_pb}
    Return From Keyword    ${dict_api_pb}

# lấy ra dict chứa tất cả thông tin phòng bàn
Phong Ban Data API
    [Arguments]    ${input_ten_ban}    ${dict_tableroom}    ${dict_api_pb}    ${status_text}

    ${index}    Get Index From List    ${dict_tableroom.Name}    ${input_ten_ban}

    ${ghichu_pb}    Set Variable Return From Dict    ${dict_tableroom.Description[${index}]}
    ${nhom_pb}    Set Variable Return From Dict    ${dict_tableroom.Name1[${index}]}
    ${soghe_pb}    Set Variable Return From Dict    ${dict_tableroom.NumberSeat[${index}]}
    ${sothutu_pb}    Set Variable Return From Dict    ${dict_tableroom.Position[${index}]}

    ${dict_trang_thai}    Run Keyword If    '${status_text}'=='True'    Create Dictionary    True=Đang hoạt động    False=Ngừng hoạt động
    ...    ELSE    Create Dictionary    True=1    False=0
    ${trangthai_pb}    Set Variable Return From Dict    ${dict_trang_thai["${dict_tableroom["IsActive"][${index}]}"]}

    Append To List    ${dict_api_pb.ten_ban}    ${input_ten_ban}
    Append To List    ${dict_api_pb.ghi_chu}    ${ghichu_pb}
    Append To List    ${dict_api_pb.nhom_pb}    ${nhom_pb}
    Append To List    ${dict_api_pb.so_ghe}    ${soghe_pb}
    Append To List    ${dict_api_pb.trang_thai}    ${trangthai_pb}
    Append To List    ${dict_api_pb.so_thu_tu}    ${sothutu_pb}

Assert data create a tableroom require field
    [Arguments]    ${input_table_name}    ${input_table_group}
    ${table_group}    Get table group by name    ${input_table_name}
    ${table_status}    Get table status by name    ${input_table_name}
    KV Compare Scalar Values    ${table_group}    ${input_table_group}    Lỗi input nhóm phòng bàn
    KV Compare Scalar Values    ${table_status}    Đang hoạt động    Lỗi trạng thái phòng bàn

Assert data edit tableroom info require field
    [Arguments]    ${input_table_name}    ${input_table_group}
    ${list_table_name}    Get all table name
    KV List Should Contain Value    ${list_table_name}    ${input_table_name}    Lỗi danh sách không chứa tên phòng bàn cần assert
    ${table_group}    Get table group by name    ${input_table_name}
    KV Compare Scalar Values    ${table_group}    ${input_table_group}    Lỗi input nhóm phòng bàn

Assert tableroom name not available in list
    [Arguments]    ${input_table_name}
    ${list_table_name}    Get all table name
    KV List Should Not Contain Value    ${list_table_name}    ${input_table_name}    Lỗi danh sách vẫn chứa tên phòng bàn đã xóa

Get list table id by Name
    [Arguments]    ${list_table_name}    ${branch_id}=${BRANCH_ID}
    ${list_table_id}    Create List
    FOR    ${table_name}    IN ZIP    ${list_table_name}
        ${table_id}     Get table id by name    ${table_name}    ${branch_id}=${BRANCH_ID}
        Append To List    ${list_table_id}    ${table_id}
    END
    Return From Keyword    ${list_table_id}
