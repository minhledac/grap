*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Resource          ../../_common_keywords/common_products_screen.robot
Resource          ../../_common_keywords/common_menu_screen.robot
Resource          hang_hoa_navigation.robot
Resource          ../../share/toast_message.robot
Resource          ../../share/list_dictionary.robot
Resource          ../../share/utils.robot
Resource          ../../../config/envi.robot

*** Keywords ***
KV Refresh Data Danh Muc HH
    FNB Menu HangHoa
    FNB Menu HH DanhMuc
    ${exist}    Run Keyword And Return Status    Variable Should Exist    ${refresh_filter_hh}
    Run Keyword If    '${exist}'=='True'    FNB HH Sidebar Textbox TimKiem HH    ${refresh_filter_hh}

# Tạo danh sách mã hàng hóa từ pool với số lượng cần tạo là tham số truyền vào
Create list product code in Pool
    [Arguments]    ${so_mahang_tao}
    ${list_mahh_type}    Create List
    FOR    ${index}    IN RANGE    ${so_mahang_da_tao}    ${so_mahang_tao}
        Append to List    ${list_mahh_type}    ${pool_mahh_tc[${index}]}
    END
    Return From Keyword    ${list_mahh_type}

Input data in Them hang hoa che bien hoac san xuat form case required field
    [Arguments]    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}    ${list_hang_tp}    ${list_soluong_tp}
    Input data to required field in Tab thong tin    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB HH AddHH Tab ThanhPhan    True
    Input danh sach hang thanh phan va so luong    ${list_hang_tp}    ${list_soluong_tp}

Input data in Them hang hoa dich vu form case required field
    [Arguments]    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_von}    ${gia_ban}
    FNB WaitVisible HH AddHH Text Them HH DichVu
    Input data to required field in Tab thong tin    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB HH AddHH Textbox Gia Von    ${gia_von}

Input data in Them hang hoa tinh gio form case required field
    [Arguments]    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_von}    ${gia_ban}
    FNB WaitVisible HH AddHH Text Them HH DichVu
    Input data to required field in Tab thong tin    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB HH AddHH Textbox Gia Von    ${gia_von}
    FNB HH AddHH Checkbox DichVu TinhGio

Input data in Them hang hoa che bien form case thuoc tinh all field
    [Arguments]    ${list_mahh_chebien}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${vi_tri}    ${gia_ban}    ${trong_luong}    ${hinh_anh}
    ...    ${ten_thuoctinh}    ${list_giatri_thuoctinh}    ${mo_ta}    ${mau_note}    ${list_hang_tp}    ${list_soluong_tp}
    Edit data to required field in Tab thong tin    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    Input data to minor field and attribute case no minmaxquant    ${list_mahh_chebien}    ${vi_tri}    ${trong_luong}    ${hinh_anh}    ${ten_thuoctinh}
    ...    ${list_giatri_thuoctinh}    ${mo_ta}    ${mau_note}
    FNB HH AddHH Tab ThanhPhan    True
    Input danh sach hang thanh phan va so luong    ${list_hang_tp}    ${list_soluong_tp}

Input data in Them hang hoa che bien form case don vi tinh all field
    [Arguments]    ${ma_hh_chebien}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${vi_tri}    ${gia_ban}    ${trong_luong}    ${hinh_anh}
    ...    ${don_vi_tinh}    ${mo_ta}    ${mau_note}    ${list_hang_tp}    ${list_soluong_tp}
    Edit data to required field in Tab thong tin    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB HH AddHH Textbox Ma HH    ${ma_hh_chebien}
    Input data to minor field and unit case no minmaxquant    ${vi_tri}    ${trong_luong}    ${hinh_anh}    ${don_vi_tinh}    ${mo_ta}    ${mau_note}
    FNB HH AddHH Tab ThanhPhan    True
    Input danh sach hang thanh phan va so luong    ${list_hang_tp}    ${list_soluong_tp}

Input data in Them hang hoa san xuat form case thuoc tinh all field
    [Arguments]    ${list_mahh_sanxuat}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${vi_tri}    ${gia_ban}    ${trong_luong}    ${hinh_anh}
    ...    ${ten_thuoctinh}    ${list_giatri_thuoctinh}    ${ton_NN}    ${ton_LN}    ${mo_ta}    ${mau_note}    ${list_hang_tp}    ${list_soluong_tp}
    Edit data to required field in Tab thong tin    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    Input data to minor field and attribute    ${list_mahh_sanxuat}    ${vi_tri}    ${trong_luong}    ${hinh_anh}    ${ten_thuoctinh}
    ...    ${list_giatri_thuoctinh}    ${ton_NN}    ${ton_LN}    ${mo_ta}    ${mau_note}
    FNB HH AddHH Tab ThanhPhan    True
    Input danh sach hang thanh phan va so luong    ${list_hang_tp}    ${list_soluong_tp}

Input data in Them hang hoa san xuat form case don vi tinh all field
    [Arguments]    ${ma_hh_sanxuat}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${vi_tri}    ${gia_ban}    ${trong_luong}    ${hinh_anh}
    ...    ${don_vi_tinh}    ${ton_NN}    ${ton_LN}    ${mo_ta}    ${mau_note}    ${list_hang_tp}    ${list_soluong_tp}
    Edit data to required field in Tab thong tin    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB HH AddHH Textbox Ma HH    ${ma_hh_sanxuat}
    Input data to minor field and unit    ${vi_tri}    ${trong_luong}    ${hinh_anh}    ${don_vi_tinh}    ${ton_NN}    ${ton_LN}    ${mo_ta}    ${mau_note}
    FNB HH AddHH Tab ThanhPhan    True
    Input danh sach hang thanh phan va so luong    ${list_hang_tp}    ${list_soluong_tp}

Input data in Them hang hoa dich vu form case thuoc tinh all field
    [Arguments]    ${list_mahh_dichvu}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_von}    ${gia_ban}    ${hinh_anh}
    ...    ${ten_thuoctinh}    ${list_giatri_thuoctinh}    ${mo_ta}    ${mau_note}
    FNB WaitVisible HH AddHH Text Them HH DichVu
    Edit data to required field in Tab thong tin    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB HH AddHH Textbox Gia Von    ${gia_von}
    Input data to minor field and attribute case no shelves weight    ${list_mahh_dichvu}    ${hinh_anh}    ${ten_thuoctinh}
    ...    ${list_giatri_thuoctinh}    ${mo_ta}    ${mau_note}

Input data in Them hang hoa dich vu form case don vi tinh all field
    [Arguments]    ${ma_hh_dichvu}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_von}    ${gia_ban}    ${hinh_anh}
    ...    ${don_vi_tinh}    ${mo_ta}    ${mau_note}
    FNB WaitVisible HH AddHH Text Them HH DichVu
    Edit data to required field in Tab thong tin    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB HH AddHH Textbox Ma HH    ${ma_hh_dichvu}
    FNB HH AddHH Textbox Gia Von    ${gia_von}
    Input data to minor field and unit case no shelves weight    ${hinh_anh}    ${don_vi_tinh}    ${mo_ta}    ${mau_note}

Input data in Them hang hoa tinh gio form case thuoc tinh all field
    [Arguments]    ${list_mahh_dichvu}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_von}    ${gia_ban}    ${hinh_anh}
    ...    ${ten_thuoctinh}    ${list_giatri_thuoctinh}    ${mo_ta}    ${mau_note}
    FNB WaitVisible HH AddHH Text Them HH DichVu
    Edit data to required field in Tab thong tin    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB HH AddHH Textbox Gia Von    ${gia_von}
    FNB HH AddHH Checkbox DichVu TinhGio
    Input data to minor field and attribute case no shelves weight    ${list_mahh_dichvu}    ${hinh_anh}    ${ten_thuoctinh}
    ...    ${list_giatri_thuoctinh}    ${mo_ta}    ${mau_note}

Input data in Them hang hoa tinh gio form case don vi tinh all field
    [Arguments]    ${ma_hh_dichvu}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_von}    ${gia_ban}    ${hinh_anh}
    ...    ${don_vi_tinh}    ${mo_ta}    ${mau_note}
    FNB WaitVisible HH AddHH Text Them HH DichVu
    Edit data to required field in Tab thong tin    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB HH AddHH Textbox Ma HH    ${ma_hh_dichvu}
    FNB HH AddHH Textbox Gia Von    ${gia_von}
    FNB HH AddHH Checkbox DichVu TinhGio
    Input data to minor field and unit case no shelves weight    ${hinh_anh}    ${don_vi_tinh}    ${mo_ta}    ${mau_note}

Input data in Them hang hoa che bien hoac san xuat cung loai and update atrribute value
    [Arguments]    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}    ${giatri_thuoctinh}    ${list_hang_tp}    ${list_soluong_tp}
    Input data to required field in Tab thong tin    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB HH EditHH Textbox Sua Gia Tri Thuoc Tinh    2    ${giatri_thuoctinh}
    FNB HH AddHH Tab ThanhPhan    True
    Edit danh sach hang thanh phan va so luong    ${list_hang_tp}    ${list_soluong_tp}

Input data in Them hang hoa dich vu cung loai and update atrribute value
    [Arguments]    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_von}    ${gia_ban}    ${giatri_thuoctinh}
    Input data to required field in Tab thong tin    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB HH AddHH Textbox Gia Von    ${gia_von}
    FNB HH EditHH Textbox Sua Gia Tri Thuoc Tinh    2    ${giatri_thuoctinh}

Input data in Them hang hoa tinh gio cung loai and update atrribute value
    [Arguments]    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_von}    ${gia_ban}    ${giatri_thuoctinh}
    Input data to required field in Tab thong tin    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB HH AddHH Textbox Gia Von    ${gia_von}
    # FNB HH AddHH Checkbox DichVu TinhGio    True
    FNB HH AddHH Checkbox DichVu TinhGio
    FNB HH EditHH Textbox Sua Gia Tri Thuoc Tinh    2    ${giatri_thuoctinh}

Input data in Cap nhat hang hoa che bien hoac san xuat form case required field
    [Arguments]    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}    ${list_hang_tp}    ${list_hang_tp2}    ${list_soluong_tp2}
    Edit data to required field in Tab thong tin    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB HH AddHH Tab ThanhPhan    True
    Delete danh sach hang thanh phan cu    ${list_hang_tp}
    Edit danh sach hang thanh phan va so luong    ${list_hang_tp2}    ${list_soluong_tp2}

Input data in Cap nhat hang hoa dich vu form case required field
    [Arguments]    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB WaitVisible HH EditHH Title Sua HangDichVu
    Edit data to required field in Tab thong tin    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}

Input data in Cap nhat hang hoa tinh gio form case required field
    [Arguments]    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB WaitVisible HH EditHH Title Sua HangDichVu
    Edit data to required field in Tab thong tin    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB HH AddHH Checkbox DichVu TinhGio

Input data in Cap nhat hang hoa dich vu form case co thuoc tinh
    [Arguments]    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB WaitVisible HH EditHH Title Sua HangDichVu
    Edit data to required field in Tab thong tin    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}

Input data in Cap nhat hang hoa tinh gio form case co thuoc tinh
    [Arguments]    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    FNB WaitVisible HH EditHH Title Sua HangDichVu
    Edit data to required field in Tab thong tin    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    # FNB HH AddHH Checkbox DichVu TinhGio    True
    FNB HH AddHH Checkbox DichVu TinhGio

Input ma cho hang cung loai in Tab thong tin
    [Arguments]    ${list_mahh_dichvu}    ${list_giatri_thuoctinh}
    #Input giá trị mã hàng tương ứng với từng hàng hóa cùng loại
    FOR    ${giatri_thuoctinh}    ${ma_hh_dichvu}    IN ZIP    ${list_giatri_thuoctinh}    ${list_mahh_dichvu}
        FNB HH AddHH Textbox Ma HH CungLoai    ${giatri_thuoctinh}    ${ma_hh_dichvu}
    END

Input data to required field in Tab thong tin
    [Arguments]    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    Set Selenium Speed    0.5
    Run Keyword If    '${ma_hh}' != '${EMPTY}'    FNB HH AddHH Textbox Ma HH    ${ma_hh}
    FNB HH AddHH Textbox Ten HH    ${ten_hh}
    ${loai_menu}    FNB GetLocator HH AddHH Cell Loai ThucDon    ${loai_thuc_don}
    Run Keyword If    '${loai_thuc_don}' != '${EMPTY}'    FNB HH AddHH Dropdown Loai ThucDon    ${loai_menu}
    Run Keyword If    '${nhom_hang}' != '${EMPTY}'    Tao nhom hang cap 1    ${nhom_hang}
    FNB HH AddHH Textbox Gia Ban    ${gia_ban}
    Set Selenium Speed    ${SELENIUM_SPEED}

Open edit product form
    [Arguments]    ${ma_hh}
    # 3. Nhập mã HH vào search box -> ENTER
    FNB HH Sidebar Textbox TimKiem HH    ${ma_hh}
    FNB WaitNotVisible Menu Loading Icon
    # 4. Click button [Cập nhật]
    FOR    ${i}   IN RANGE    0    5
        Run Keyword And Return Status    FNB HH ListHH Button CapNhat    True
        ${title_status}    Run Keyword And Return Status    FNB WaitVisible HH EditHH Title Sua HangHoa    wait_time_out=5s
        Exit For Loop If    '${title_status}'=='True'
    END

Edit data to required field in Tab thong tin
    [Arguments]    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${gia_ban}
    Set Selenium Speed    0.5
    FNB HH AddHH Textbox Ten HH    ${ten_hh}
    ${loai_menu}    FNB GetLocator HH AddHH Cell Loai ThucDon    ${loai_thuc_don}
    FNB HH AddHH Dropdown Loai ThucDon    ${loai_menu}
    Tao nhom hang cap 1    ${nhom_hang}
    FNB HH AddHH Textbox Gia Ban    ${gia_ban}
    Set Selenium Speed    ${SELENIUM_SPEED}

Input data to minor field and attribute
    [Arguments]    ${list_mahh_type}    ${vi_tri}    ${trong_luong}    ${hinh_anh}    ${ten_thuoctinh}    ${list_giatri_thuoctinh}    ${ton_NN}    ${ton_LN}
    ...    ${mo_ta}    ${mau_note}
    Input data to minor field and attribute case no minmaxquant    ${list_mahh_type}    ${vi_tri}    ${trong_luong}    ${hinh_anh}    ${ten_thuoctinh}
    ...    ${list_giatri_thuoctinh}    ${mo_ta}    ${mau_note}
    Input ton NN va ton LN    ${ton_NN}    ${ton_LN}

Input data to minor field and unit
    [Arguments]    ${vi_tri}    ${trong_luong}    ${hinh_anh}    ${don_vi_tinh}    ${ton_NN}    ${ton_LN}    ${mo_ta}    ${mau_note}
    Input data to minor field and unit case no minmaxquant    ${vi_tri}    ${trong_luong}    ${hinh_anh}    ${don_vi_tinh}    ${mo_ta}    ${mau_note}
    Input ton NN va ton LN    ${ton_NN}    ${ton_LN}

Input data to minor field and attribute case no minmaxquant
    [Arguments]    ${list_mahh_type}    ${vi_tri}    ${trong_luong}    ${hinh_anh}    ${ten_thuoctinh}    ${list_giatri_thuoctinh}    ${mo_ta}    ${mau_note}
    Them moi vi tri    ${vi_tri}
    FNB HH AddHH Textbox TrongLuong    ${trong_luong}
    Input data to minor field and attribute case no shelves weight    ${list_mahh_type}    ${hinh_anh}    ${ten_thuoctinh}    ${list_giatri_thuoctinh}
    ...    ${mo_ta}    ${mau_note}

Input data to minor field and unit case no minmaxquant
    [Arguments]    ${vi_tri}    ${trong_luong}    ${hinh_anh}    ${don_vi_tinh}    ${mo_ta}    ${mau_note}
    Them moi vi tri    ${vi_tri}
    FNB HH AddHH Textbox TrongLuong    ${trong_luong}
    Input data to minor field and unit case no shelves weight    ${hinh_anh}    ${don_vi_tinh}    ${mo_ta}    ${mau_note}

Input data to minor field and attribute case no shelves weight
    [Arguments]    ${list_mahh_type}    ${hinh_anh}    ${ten_thuoctinh}    ${list_giatri_thuoctinh}    ${mo_ta}    ${mau_note}
    FNB HH AddHH Upload HinhAnh    ${hinh_anh}
    Them moi thuoc tinh and input data    ${ten_thuoctinh}    ${list_giatri_thuoctinh}
    Input ma cho hang cung loai in Tab thong tin    ${list_mahh_type}    ${list_giatri_thuoctinh}
    FNB HH AddHH Tab MoTa ChiTiet    True
    Input mo ta va mau ghi chu    ${mo_ta}    ${mau_note}

Input data to minor field and unit case no shelves weight
    [Arguments]    ${hinh_anh}    ${don_vi_tinh}    ${mo_ta}    ${mau_note}
    FNB HH AddHH Upload HinhAnh    ${hinh_anh}
    Input don vi tinh co ban    ${don_vi_tinh}
    FNB HH AddHH Tab MoTa ChiTiet    True
    Input mo ta va mau ghi chu    ${mo_ta}    ${mau_note}

Input full thong tin tab Thong tin
    [Arguments]   ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${vitri}    ${giavon}    ${giaban}    ${tonkho}    ${trongluong}
    ...   ${ten_thuoctinh}    ${gia_tri_thuoc_tinh}    ${ten_dvt_coban}    ${ten_dvt_quydoi}    ${gia_tri_quy_doi}
    Input data to required field in Tab thong tin    ${ma_hh}    ${ten_hh}    ${loai_thuc_don}    ${nhom_hang}    ${giaban}
    Them moi vi tri    ${vitri}
    Run Keyword If    '${giavon}' != ''    FNB HH AddHH Textbox Gia Von    ${giavon}    ELSE    KV Log    Khong nhap gia von
    Run Keyword If    '${tonkho}' != ''    FNB HH AddHH Textbox TonKho    ${tonkho}    ELSE    KV Log    Khong nhap ton kho
    Run Keyword If    '${trongluong}' != ''    FNB HH AddHH Textbox TrongLuong    ${trongluong}    ELSE    KV Log    Khong nhap trong luong
    Run Keyword If    '${ten_thuoctinh}' != ''    Them moi thuoc tinh and input data    ${ten_thuoctinh}    ${gia_tri_thuoc_tinh}       ELSE    KV Log    Bo qua thuoc tinh
    Run Keyword If    '${ten_dvt_coban}' != ''    Input don vi tinh co ban va quy doi    ${ten_dvt_coban}    ${ten_dvt_quydoi}    ${gia_tri_quy_doi}

Input thong tin tab Mo ta
    [Arguments]   ${ton_NN}    ${ton_LN}    ${mota}    ${mau_ghichu}
    FNB HH AddHH Tab MoTa ChiTiet
    Input ton NN va ton LN    ${ton_NN}    ${ton_LN}
    Input mo ta va mau ghi chu    ${mota}    ${mau_ghichu}

Them moi vi tri
    [Arguments]   ${ten_vitri}
    FNB HH AddHH Button Them ViTri
    FNB WaitVisible HH AddHH Title Them Vitri Popup
    FNB HH AddHH Textbox Ten ViTri    ${ten_vitri}
    FNB HH AddHH Button Luu ViTri
    Update data success validation

# Thêm mới thuộc tính (thêm mới 1 thuộc tính và nhập list giá trị)
Them moi thuoc tinh and input data
    [Arguments]   ${ten_thuoc_tinh}    ${list_gia_tri_thuoc_tinh}
    FNB HH AddHH Row Thuoctinh
    FNB HH AddHH Button Them ThuocTinh
    ${cell_tao_thuoc_tinh}    FNB GetLocator HH AddHH Cell Tao ThuocTinh
    FNB HH AddHH Dropdown Chon ThuocTinh    ${cell_tao_thuoc_tinh}
    FNB HH AddHH Textbox Them Thuoctinh    ${ten_thuoctinh}
    FNB HH AddHH Button Luu Thuoctinh
    FOR   ${item}   IN    @{list_gia_tri_thuoc_tinh}
        FNB HH AddHH Textbox Giatri Thuoctinh    ${item}
        FNB WaitVisible HH AddHH Item GiaTri ThuocTinh    ${item}
    END

Input don vi tinh co ban
    [Arguments]   ${ten_dvt_coban}
    FNB HH AddHH Row DonVi Tinh
    FNB HH AddHH Textbox DonVi CoBan    ${ten_dvt_coban}

Input don vi tinh co ban va quy doi
    [Arguments]   ${ten_dvt_coban}    ${ten_dvt_quydoi}    ${gia_tri_quy_doi}
    FNB HH AddHH Row DonVi Tinh
    FNB HH AddHH Textbox DonVi CoBan    ${ten_dvt_coban}
    FNB HH AddHH Button Them DonVi
    FNB HH AddHH Textbox Ten DonVi    0    ${ten_dvt_quydoi}
    FNB HH AddHH Textbox GiaTri QuyDoi    ${gia_tri_quy_doi}

Input ton NN va ton LN
    [Arguments]   ${ton_NN}    ${ton_LN}
    Run Keyword If    '${ton_NN}' != ''    FNB HH AddHH Textbox Ton It Nhat    ${ton_NN}    ELSE    KV Log    Khong nhap Ton NN
    Run Keyword If    '${ton_LN}' != ''    FNB HH AddHH Textbox Ton Nhieu Nhat    ${ton_LN}    ELSE    KV Log    Khong nhap Ton LN

Input mo ta va mau ghi chu
    [Arguments]   ${mota}    ${mau_ghichu}
    ${iframe_locator}   FNB GetLocator HH AddHH IFrame MoTa
    Select Frame    ${iframe_locator}
    FNB HH AddHH Textarea Mota    ${mota}
    Unselect Frame
    FNB HH AddHH Textarea Mau GhiChu    ${mau_ghichu}

Input danh sach hang thanh phan va so luong
    [Arguments]    ${list_hang_TP}    ${list_SL}
    FOR   ${item_hang_TP}    ${item_SL}    IN ZIP    ${list_hang_TP}    ${list_SL}
        FNB HH AddHH Textbox Search Hang ThanhPhan    ${item_hang_TP}    is_wait_visible=True    is_autocomplete=True
        FNB HH AddHH Textbox SoLuong Hang ThanhPhan    ${item_hang_TP}    ${item_SL}
    END

Edit danh sach hang thanh phan va so luong
    [Arguments]    ${list_hang_TP}    ${list_SL}
    FOR   ${item_hang_TP}    ${item_SL}    IN ZIP    ${list_hang_TP}    ${list_SL}
        FNB HH EditHH Textbox Search Hang ThanhPhan    ${item_hang_TP}    is_wait_visible=True    is_autocomplete=True
        FNB HH AddHH Textbox SoLuong Hang ThanhPhan    ${item_hang_TP}    ${item_SL}
    END

Delete danh sach hang thanh phan cu
    [Arguments]    ${list_hang_TP}
    FOR   ${item_hang_TP}   IN ZIP    ${list_hang_TP}
        FNB HH AddHH Button Xoa Hang ThanhPhan    ${item_hang_TP}    True
        FNB HH EditHH Button Dongy Xoa ThanhPhan    True
        ${locator_delete}    FNB GetLocator HH AddHH Button Xoa Hang ThanhPhan    ${item_hang_TP}
        Wait Until Element Is Not Visible    ${locator_delete}
    END

Sua SL hang thanh phan
    [Arguments]   ${list_hang_TP}    ${list_SL}
    FOR    ${item_hang_TP}    ${item_SL}    IN ZIP    ${list_hang_TP}    ${list_SL}
        FNB HH AddHH Textbox SoLuong Hang ThanhPhan    ${item_hang_TP}    ${item_SL}
    END

# danh sách topping hoac ds hàng sử dụng topping sau khi xóa, thêm hàng.
Lay danh sach ma hang moi nhat sau khi thay doi
    [Arguments]   ${list_hang_ban_dau}    ${list_hang_xoa}    ${list_hang_them}
    FOR    ${item_hang_xoa}   IN    @{list_hang_xoa}
        Remove Values From List    ${list_hang_ban_dau}    ${item_hang_xoa}
        KV Log    ${list_hang_ban_dau}
    END
    ${list_hang_full}   Combine Lists    ${list_hang_ban_dau}    ${list_hang_them}
    Return From Keyword    ${list_hang_full}

# danh sach hang TP va SL sau khi thêm, sửa, xóa hàng TP
Lay danh sach ma hang va SL hang thanh phan sau khi thay doi
    [Arguments]   ${list_hang_ban_dau}    ${list_SL_ban_dau}    ${list_hang_xoa}    ${list_hang_them}    ${list_SL_them}    ${list_ma_TP_sua}    ${list_SL_TP_sua}
    ${dict_hang_TP_ban_dau}   Create Dictionary
    FOR    ${item_hang}    ${item_SL}    IN ZIP    ${list_hang_ban_dau}    ${list_SL_ban_dau}
          Set To Dictionary    ${dict_hang_TP_ban_dau}    ${item_hang}    ${item_SL}
    END
    FOR    ${iem_hang_xoa}   IN    @{list_hang_xoa}
        Remove From Dictionary    ${dict_hang_TP_ban_dau}    ${iem_hang_xoa}
    END
    ${list_hang_TP_after}   Get Dictionary Keys    ${dict_hang_TP_ban_dau}
    ${list_SL_after}    Get Dictionary Values    ${dict_hang_TP_ban_dau}
    ${list_hang_TP_result}    Combine Lists    ${list_hang_TP_after}    ${list_hang_them}
    ${list_SL_result}    Combine Lists    ${list_SL_after}    ${list_SL_them}
    FOR    ${item_ma_sua}    ${item_SL_sua}    IN ZIP    ${list_ma_TP_sua}    ${list_SL_TP_sua}
        ${list_SL_result}    Get list infor hang thanh phan sau khi thay doi so luong    ${item_ma_sua}    ${item_SL_sua}    ${list_hang_TP_result}    ${list_SL_result}
        KV Log    ${list_SL_result}
    END
    Return From Keyword    ${list_hang_TP_result}    ${list_SL_result}

Get list infor hang thanh phan sau khi thay doi so luong
    [Arguments]    ${item_ma_sua}    ${item_SL_sua}   ${list_hang_ban_dau}    ${list_SL_ban_dau}
    ${length}    Get Length    ${list_hang_ban_dau}
    FOR    ${index}    IN RANGE    ${length}
        ${item_ma_remove}    Run Keyword If    '${list_hang_ban_dau[${index}]}' == '${item_ma_sua}'    Set List Value    ${list_SL_ban_dau}    ${index}    ${item_SL_sua}
    END
    Return From Keyword    ${list_SL_ban_dau}

# Lay danh sách mã hàng cơ bản và mà hàng hóa liên quan hệ thống tự động sinh dựa trên mã hàng cơ bản
Get list ma hang auto
    [Arguments]   ${ma_hh}    ${count_HH}
    ${list_ma_hh}   Create List    ${ma_hh}
    ${number}   Set Variable    1
    FOR    ${item}    IN RANGE    ${count_HH}
        ${ma_hh_cung_loai}    Catenate    SEPARATOR=-   ${ma_hh}    ${number}
        Append To List    ${list_ma_hh}    ${ma_hh_cung_loai}
        ${number}    Evaluate    ${number}+1
        Exit For Loop If    ${number}==${count_HH}
    END
    Return From Keyword    ${list_ma_hh}

Get text tong hang hoa va tong ma hang
    [Arguments]
    ${get_text_tong_HH}    FNB HH ListHH Text Tong Hanghoa
    ${get_text_tong_ma_hang}    FNB HH ListHH Text Tong Mahang
    Return From Keyword    ${get_text_tong_HH}    ${get_text_tong_ma_hang}

Input danh sach mon them
    [Arguments]    ${list_monthem}
    FNB HH AddHH Tab MonThem    True
    FOR   ${item_monthem}   IN    @{list_monthem}
        FNB HH AddHH Textbox Search MonThem    ${item_monthem}    is_wait_visible=True    is_autocomplete=True
    END

Input danh sach hang su dung mon them
    [Arguments]    ${list_hang_sudung_monthem}
    FNB HH AddHH Tab SuDungMonThem    True
    FOR   ${item_hanghoa}   IN    @{list_hang_sudung_monthem}
        FNB HH AddHH Textbox Search HH SuDungMonThem    ${item_hanghoa}    is_wait_visible=True    is_autocomplete=True
    END

Delete list product use topping
    [Arguments]   ${list_ma_hang}
    FOR   ${item_ma_hang}   IN    @{list_ma_hang}
        FNB HH AddHH Button Xoa HH SuDungMonThem    ${item_ma_hang}
        FNB HH EditHH Button Dongy Xoa ThanhPhan   True
        ${locator_delete}    FNB GetLocator HH AddHH Button Xoa Hang ThanhPhan    ${item_ma_hang}
        Wait Until Element Is Not Visible    ${locator_delete}
    END

Delete list topping
    [Arguments]   ${list_ma_hang}
    FOR   ${item_ma_hang}   IN    @{list_ma_hang}
        FNB HH AddHH Button Xoa MonThem    ${item_ma_hang}
        FNB HH EditHH Button Dongy Xoa ThanhPhan   True
        ${locator_delete}    FNB GetLocator HH AddHH Button Xoa Hang ThanhPhan    ${item_ma_hang}
        Wait Until Element Is Not Visible    ${locator_delete}
    END

Tim kiem va click button Them hang cung loai trong list hang cung loai
    [Arguments]   ${ma_hh}
    Sleep    2s
    ${row_ma_hang}    FNB GetLocator HH ListHH Row MaHang    ${EMPTY}
    Wait Until Element Is Visible    ${row_ma_hang}
    ${count}    Get Element Count    ${row_ma_hang}
    ${hh_locator}    FNB GetLocator HH ListHH Row Product    ${ma_hh}
    ${loc_button}    FNB GetLocator HH ListHH Button Them Hang CungLoai
    FOR    ${i}    IN RANGE    ${count}
        ${row_index}=    Evaluate    ${i} + 1
        ${visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${hh_locator}    10s
        Run Keyword If    '${visible}' == 'False'   FNB HH ListHH Row MaHang    [${row_index}]
        FNB WaitNotVisible Menu Loading Icon    wait_time_out=5s    visible_time_out=5s
        ${visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${hh_locator}    10s
        Run Keyword If    '${visible}' == 'True'    Wait Until Element Is Enabled    ${loc_button}
        Run Keyword If    '${visible}' == 'True'    FNB HH ListHH Button Them Hang CungLoai   True
        ...    ELSE    FNB HH ListHH Row MaHang    [${row_index}]
        Exit For Loop If    '${visible}' == 'True'
    END
    Run Keyword And Return Status    FNB HH ListHH Button Them Hang CungLoai   True

# Tạo nhóm hàng cấp 1
Tao nhom hang cap 1
    [Arguments]    ${tennhom}
    FNB HH AddHH Button Them NhomHang
    FNB WaitVisible HH AddHH Title Them NhomHang Popup
    FNB HH AddHH Textbox Ten Nhom    ${tennhom}
    FNB HH AddHH Button Luu NhomHang

# Chuyển đổi đơn vị hàng hóa có đơn vị
Chuyen doi don vi hang hoa
    [Arguments]   ${ma_hh}   ${ten_don_vi}
    FNB HH ListHH Button Chuyen Don Vi   ${ma_hh}    True
    FNB HH ListHH Button Chon Don Vi Chuyen Doi   ${ma_hh}   ${ten_don_vi}   True

# Assert thông tin đơn vị chuyển đổi hiển thị trên UI
Assert thong tin chuyen doi don vi hang hoa
    [Arguments]   ${ma_hh}   ${ten_dvt_chuyen_doi}
    ${btn_chuyen_dvt}   FNB GetLocator HH ListHH Button Chuyen Don Vi  ${ma_hh}-1
    Wait Until Element Is Visible   ${btn_chuyen_dvt}   10 s
    ${ten_dvt_getUI}   Get Text   ${btn_chuyen_dvt}
    ${ten_dvt_getUI}   Remove String    ${ten_dvt_getUI}   -${Space}
    KV Should Be Equal As Strings    ${ten_dvt_getUI}    ${ten_dvt_chuyen_doi}    msg=đơn vị chuyển đổi không trùng khớp với đơn vị get trên UI
