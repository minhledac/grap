*** Settings ***
Suite Setup       Setup API Event Test Suite
Test Setup        Setup API Event Test Case
Test Teardown     Teardown API Event Test Case
Suite Teardown    Teardown API Event Test Suite
Resource          ../../config/envi.robot
Resource          ../../core/API/GET/giao-dich/api_order.robot
Resource          ../../core/API/POST/event/post_event_newfnb.robot
Library           Collections
Library           ExcelLibrary
Library           String

*** Variables ***

*** Test Cases ***
DEL_MHTN
    [Documentation]
    [Tags]    DEL_MHTN
    [Template]    PP delete don order man hinh thu ngan
    ${EMPTY}

*** Keywords ***
PP delete don order man hinh thu ngan
    [Arguments]    ${EMPTY}
    ${list_order_Uuid}    Get list order uuid by order code
    ${length}    Get Length    ${list_order_Uuid}
    FOR    ${order_uuid}    IN ZIP    ${list_order_Uuid}
        Exit For Loop If    '${order_uuid}'=='0'
        Post Event Sync Cancel Order for prepare-data    ${order_uuid}
    END
