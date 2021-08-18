*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Library           BuiltIn
Resource          ../../api_access.robot
Resource          ../../../share/utils.robot
Resource          ../../../share/list_dictionary.robot
Resource          ../../../../config/envi.robot
Resource          ../../GET/thiet-lap/api_chi_phi_nhap_hang.robot
Resource          ../../GET/thiet-lap/api_khuyen_mai.robot



*** Keywords ***
Them moi chuong trinh khuyen mai
    [Documentation]    ApplyDates, ApplyMonths là thời gian áp dụng theo ngày và theo tháng của chương trình, truyền theo ${index} tương ứng với ngày và tháng tăng dần
    ...    autoApplyPromotion false là không áp dụng tự động khuyến mại khi tạo đơn
    [Arguments]    ${code}    ${name_promotion}    ${list_discount}    ${list_value}    ${start_date}    ${end_date}
    ...    ${list_code_pr_purchase}=${EMPTY}    ${list_pr_code_sale}=${EMPTY}     ${type}=0    ${promotionType}=1    ${condition}=0
    ...    ${IsActive}=true    ${autoApplyPromotion}=false    ${type_pr}=3    ${ApplyMonths}=${EMPTY}
    ...    ${ApplyDates}=${EMPTY}   ${list_branch_id}=${BRANCH_ID}     ${retailerid}=${RETAILER_ID}

    ${find_id}    Get promotion id by promotion code    ${code}
    Return From Keyword If    ${find_id}!=0    HH da ton tai

    ${Type_branch_id}    Evaluate    type($list_branch_id).__name__
    ${list_branch_id}    Run Keyword If    '${Type_branch_id}'=='list'    Set variable    ${list_branch_id}    ELSE    Create List    ${list_branch_id}
    ${list_branch_id}    Evaluate    ",".join($list_branch_id)

    ${start_date}    Convert Date    ${start_date}    date_format=%d/%m/%Y %H:%M    exclude_millis=True
    ${end_date}      Convert Date    ${end_date}      date_format=%d/%m/%Y %H:%M    exclude_millis=True

    ${data_promotions}    Run Keyword If     '${type}'=='0' and '${promotionType}'=='1'   Set khuyen mai theo don hang theo hinh thuc giam gia don hang    ${list_discount}
    ...    ${list_value}    ${type}    ${promotionType}    ${condition}    ${retailerid}   ELSE    Set khuyen mai theo hang hoa theo hinh thuc mua hang khuyen mai hang    ${type_pr}   ${list_pr__purchase}    ${list_code_pr_purchase}    ${list_pr_sale}    ${list_pr_code_sale}
    Log   ${data_promotions}
    ${input_dict}    Create Dictionary    name_promotion=${name_promotion}    start_date=${start_date}    end_date=${end_date}    IsActive=${IsActive}
    ...    ApplyMonths=${ApplyMonths}    ApplyDates=${ApplyDates}    retailer_id=${retailerid}    code=${code}    type=${type}    promotionType=${promotionType}
    ...    SalePromotions=${data_promotions}    list_branch_id=${list_branch_id}    autoApplyPromotion=${autoApplyPromotion}
    ${result_dict}  API Call From Template    /khuyen-mai/add_khuyen_mai.txt    ${input_dict}   json_path=$.Id   session_alias=session_kmapi
    Return From Keyword  ${result_dict.Id[0]}

#.....................................
Set khuyen mai theo don hang theo hinh thuc giam gia don hang
    [Documentation]    Nếu discount< 100 giảm giá theo % và lớn hơn 100 sẽ giảm giá theo VND
    ...    invoiceValue là giá trị tiền hàng từ bao nhiêu sẽ bắt đầu khuyến mại
    ...    NumberCustomer là số lượng khách từ bao nhiêu sẽ bắt đầu khuyến mại
    ...    condition=0 tính theo tổng tiền hàng, 1 tính theo số lượng khách
    ...    Type=0 khuyến mại theo đơn hàng. 1 khuyến mại theo hàng hóa
    ...    PromotionType=1 hình thức giảm giá đơn hàng, 2 tặng món/quà, 4 Tặng điểm, 5 mua hàng khuyến mãi hàng
    [Arguments]    ${list_discount}    ${list_value}    ${type}=0    ${promotionType}=1    ${condition}=0    ${retailerid}=${RETAILER_ID}
    ${data_promotions}    Create List

    ${Type_discount}    Evaluate    type($list_discount).__name__
    ${list_discount}    Run Keyword If    '${Type_discount}'=='list'    Set variable    ${list_discount}    ELSE    Create List    ${list_discount}
    ${length}    Get Length    ${list_discount}
    ${Type_value}    Evaluate    type($list_value).__name__
    ${list_value}    Run Keyword If    '${Type_value}'=='list'    Set variable    ${list_value}    ELSE    Create List    ${list_value}

    FOR   ${index}    IN RANGE   0    ${length}
        ${uuid}    Generate Random String    15    0123456789
        ${discountType}   Run Keyword If   0<=${list_discount[${index}]}<=100    Set Variable    %    ELSE IF    ${list_discount[${index}]} > 100     Set Variable    VND

        ${discountRatio}     Run Keyword If   0<=${list_discount[${index}]}<=100    Set Variable    ${list_discount[${index}]}
        ...    ELSE    Set Variable    null
        Log    ratio: ${discountRatio}
        ${discount}     Run Keyword If   0<=${list_discount[${index}]}<=100    Set Variable    null
        ...    ELSE    Set Variable     ${list_discount[${index}]}
        Log    ratio: ${discountRatio}
        ${invoicevalue}    Run Keyword If    '${condition}'=='0'    Set Variable    ${list_value[${index}]}
        ...    ELSE    Set Variable    null
        ${numbercustomer}    Run Keyword If    '${condition}'=='1'    Set Variable    ${list_value[${index}]}
        ...    ELSE    Set Variable    null

        Append To List    ${data_promotions}    {"Uuid": "${uuid}","Type": ${type},"PromotionType": ${promotionType},"InvoiceValue": ${invoicevalue},"PrereqProductId": null,"PrereqCategoryId": null,"PrereqQuantity": null,"PrereqApplySameKind": false,"Discount": ${discount},"DiscountRatio": ${discountRatio},"DiscountType": "${discountType}","ReceivedProductId": null,"ReceivedCategoryId": null,"ReceivedQuantity": null,"ReceivedApplySameKind": false,"ProductDiscount": null,"ProductDiscountRatio": null,"ProductDiscountType": "%","RetailerId": ${retailerid},"NumberCustomer": ${numbercustomer},"InvoiceValueType": 1}
    END
    ${data_promotions}    Convert List to String    ${data_promotions}    ,
    Return From Keyword    ${data_promotions}

Set khuyen mai theo hang hoa theo hinh thuc mua hang khuyen mai hang
    [Documentation]    type=3 là giảm giá hàng hóa. type=4 là giảm giá nhóm hàng
    [Arguments]   ${list_pr__purchase}    ${list_code_pr_purchase}    ${list_pr_sale}    ${list_pr_code_sale}   ${type_pr}=3
    ${data_km_hang}    Create List

    ${data_pr}    Run Keyword If    "${type_pr}"=="3"     Set giam gia hang hoa    ${type_pr}   ${list_pr__purchase}    ${list_code_pr_purchase}    ${list_pr_sale}    ${list_pr_code_sale}
    Append To List    ${data_km_hang}    {"Uuid": "16039571057781536","Type": 1,"PromotionType": 5,"InvoiceValue": 0,"PrereqProductId": 1900348,"PrereqCategoryId": null,"PrereqQuantity": 1,"PrereqApplySameKind": false,"Discount": null,"DiscountRatio": null,"DiscountType": "%","ReceivedProductId": 1900462,"ReceivedCategoryId": null,"ReceivedQuantity": 1,"ReceivedApplySameKind": false,"ProductDiscount": null,"ProductDiscountRatio": 10,"ProductDiscountType": "%","RetailerId": 744094,"InvoiceValueType": 1,"PrereqProductCode": "HTPKK0101","PrereqProductIds": "1900348","PrereqCategoryIds": null,"PrereqEntity": ${data_pr}}
    Return From Keyword    ${data_pr}

Set giam gia hang hoa
    [Documentation]
    [Arguments]    ${list_pr__purchase}    ${list_code_pr_purchase}    ${list_pr_sale}    ${list_pr_code_sale}    ${type_pr}
    ${data_pr}    Create List
    Append To List    ${data_pr}     "PrereqEntity": {"__type": "KiotViet.Web.Api.ProductAndGroup, KiotViet.Web.Api","Id": ,"Name": " ","Code": "","Type": ${type_pr},"Price": ,"MasterProductId": ,"CategoryId": ,"Unit": "","IsRewardPoint": false,"HasVariants": false,"CurrentProductSelected": 1900388,"ProductIds": "${list_pr__purchase}","HasRelated": false,"MasterProductIds": [${list_pr__purchase}],"ProductCodes": "${list_code_pr_purchase}","ApplySameKind": false,"CategoryIds": ""},"PrereqProductCodes": "${list_code_pr_purchase}","MasterProductIds": [${list_pr__purchase}],"CategoryIds": "","ReceivedProductCode": "","ReceivedProductIds": "${list_pr_sale}","ReceivedCategoryIds": null,"ReceivedEntity": {"__type": "KiotViet.Web.Api.ProductAndGroup, KiotViet.Web.Api","Id": ,"Name": "","Code": " ","Type": 3,"Price": ,"MasterProductId": ,"CategoryId": ,"Unit": "","IsRewardPoint": false,"HasVariants": false,"CurrentProductSelected": ,"ProductIds": "${list_pr_sale}","HasRelated": false,"MasterProductIds": [${list_pr_sale}],"ProductCodes": "${list_pr_code_sale}","ApplySameKind": false,"CategoryIds": ""},"ReceivedProductCodes": "${list_pr_code_sale}"
    Return From Keyword    ${data_pr}

Set giam gia nhom hang
   [Documentation]
   [Arguments]    ${list_pr__purchase}    ${list_code_pr_purchase}    ${list_pr_sale}    ${list_pr_code_sale}    ${type_pr}
   ${data_pr}    Create List
   Append To List    ${data_pr}     "PrereqEntity": {"__type": "KiotViet.Web.Api.ProductAndGroup, KiotViet.Web.Api","Id": ,"Name": " ","Code": "","Type": ${type_pr},"Price": ,"MasterProductId": ,"CategoryId": ,"Unit": "","IsRewardPoint": false,"HasVariants": false,"CurrentProductSelected": 1900388,"ProductIds": "${list_pr__purchase}","HasRelated": false,"MasterProductIds": [${list_pr__purchase}],"ProductCodes": "${list_code_pr_purchase}","ApplySameKind": false,"CategoryIds": ""},"PrereqProductCodes": "${list_code_pr_purchase}","MasterProductIds": [${list_pr__purchase}],"CategoryIds": "","ReceivedProductCode": "","ReceivedProductIds": "${list_pr_sale}","ReceivedCategoryIds": null,"ReceivedEntity": {"__type": "KiotViet.Web.Api.ProductAndGroup, KiotViet.Web.Api","Id": ,"Name": "","Code": " ","Type": 3,"Price": ,"MasterProductId": ,"CategoryId": ,"Unit": "","IsRewardPoint": false,"HasVariants": false,"CurrentProductSelected": ,"ProductIds": "${list_pr_sale}","HasRelated": false,"MasterProductIds": [${list_pr_sale}],"ProductCodes": "${list_pr_code_sale}","ApplySameKind": false,"CategoryIds": ""},"ReceivedProductCodes": "${list_pr_code_sale}"
   Return From Keyword    ${data_pr}

Delete khuyen mai
   [Documentation]
   [Arguments]    ${id_KM}
   ${input_dict}    Create Dictionary   id_KM=${id_KM}
   API Call From Template   /khuyen-mai/delete_KM.txt   ${input_dict}   session_alias=session_kmapi
