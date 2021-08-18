*** Settings ***
Resource           ../../api_access.robot
Resource           ../../GET/doi-tac/api_khachhang.robot
Resource          ../../../../config/envi.robot
Library          ../../../../custom-library/UtilityLibrary.py

*** Keywords ***
Them moi khach hang
    [Arguments]    ${ma_kh}    ${ten_kh}    ${sdt}    ${dia_chi}    ${list_nhom_kh}=${EMPTY}
    ${id_kh}    Get customer id by code    ${ma_kh}
    Return From Keyword If    ${id_kh}!=0    ${id_kh}
    ${uuid}    Generate Random UUID
    ${retailer_id}    Get RetailerID
    ${jsonpath_id}    Set Variable    $.Id
    ${type_group}    Evaluate    type($list_nhom_kh).__name__
    ${list_group_id}      Run Keyword If    '${type_group}'=='list'    Get list customer group id by list name    ${list_nhom_kh}
    ${data_nhom_kh}       Run Keyword If    '${type_group}'=='list'    KV Set Data Customer Group    ${list_group_id}    ELSE    Set Variable    ${EMPTY}

    ${input_dict}   Create Dictionary    retailer_id=${retailer_id}    branch_id=${BRANCH_ID}    code=${ma_kh}    name=${ten_kh}    phone_number=${sdt}
    ...    address=${dia_chi}    customer_group=${data_nhom_kh}    uuid=${uuid}
    ${dict_id}      Run Keyword If    ${id_kh} == 0    API Call From Template    /khach-hang/add_khach_hang.txt    ${input_dict}    ${jsonpath_id}
    ${result_id}    Run Keyword If    ${id_kh} == 0    Set Variable Return From Dict    ${dict_id.Id[0]}    ELSE    Set Variable    ${id_kh}
    Return From Keyword    ${result_id}

Them moi list khach hang
    [Arguments]    @{list_data}
    ${list_id_kh}    Create List
    FOR    ${data}    IN    @{list_data}
        ${id_kh}    Them moi khach hang    @{data}
        Append To List    ${list_id_kh}    ${id_kh}
    END
    Return From Keyword    ${list_id_kh}

Delete khach hang
    [Arguments]    ${id_kh}
    ${input_dict}   Create Dictionary    id=${id_kh}
    Run Keyword If    ${id_kh} != 0    API Call From Template    /khach-hang/delete_khach_hang.txt    ${input_dict}    ELSE    KV Log    Khach hang khong ton tai

Delete list khach hang
    [Arguments]    ${list_id_kh}
    FOR    ${id_kh}    IN    @{list_id_kh}
        Delete khach hang    ${id_kh}
    END

# ========== NHÓM KHÁCH HÀNG ==================
Them moi nhom khach hang
    [Arguments]    ${ten_nhom_kh}    ${giam_gia}
    ${get_id}    Get id customer group by name    ${ten_nhom_kh}
    ${giam_gia_VND}    ${giam_gia_%}    ${loai_giam_gia}    Run Keyword If    0<=${giam_gia}<=100    Set Variable    null    ${giam_gia}    %
    ...    ELSE IF    ${giam_gia}>100    Set Variable    ${giam_gia}    null    VND
    ${input_dict}   Create Dictionary   ten_nhom_kh=${ten_nhom_kh}   giam_gia=${giam_gia_VND}   giam_gia_phan_tram=${giam_gia_%}   loai_giam_gia=${loai_giam_gia}   gia_tri_giam_gia=${giam_gia}
    ${result_id}    Run Keyword If    ${get_id}== 0    API Call From Template    /khach-hang/add_nhom_KH.txt    ${input_dict}    $.Id    ELSE    Set Variable    ${get_id}
    ${result_id}    Run Keyword If    ${get_id}== 0    Set Variable Return From Dict    ${result_id.Id[0]}    ELSE    Set Variable    ${get_id}
    Return From Keyword    ${result_id}

Them moi list nhom khach hang
    [Arguments]    @{list_data}
    ${list_id_group}    Create List
    FOR    ${data}    IN    @{list_data}
        ${id_group}   Them moi nhom khach hang    @{data}
        Append To List    ${list_id_group}    ${id_group}
    END
    Return From Keyword    ${list_id_group}

Delete nhom khach hang
    [Arguments]    ${id_group}
    ${input_dict}    Create Dictionary    id_group=${id_group}
    API Call From Template    /khach-hang/delete_nhom_KH.txt    ${input_dict}

Delete list nhom khach hang
    [Arguments]    ${list_id_group}
    FOR    ${id_group}     IN    @{list_id_group}
        Delete nhom khach hang    ${id_group}
    END

Dieu chinh tich diem by API
    [Arguments]    ${id_khach_hang}    ${gt_tich_diem}    ${mo_ta}
    ${jsonpath}    Set Variable    $.Id
    ${input_dict}   Create Dictionary    id_khach_hang=${id_khach_hang}    gt_tich_diem=${gt_tich_diem}    mo_ta=${mo_ta}
    ${dict_id}    API Call From Template    /khach-hang/update_dieu_chinh_diem.txt    ${input_dict}    ${jsonpath}
    ${result_id}    Set Variable Return From Dict    ${dict_id.Id[0]}
    Return From Keyword    ${result_id}

#==================== SET DATA ==================
KV Set Data Customer Group
    [Arguments]    ${list_group_id}
    ${list_data}    Create List
    FOR    ${group_id}    IN    @{list_group_id}
        ${item_data}    Set Variable    {"GroupId": ${group_id}}
        Append To List    ${list_data}    ${item_data}
    END
    ${join_str}    Evaluate    ",".join($list_data)
    Return From Keyword    ${join_str}
