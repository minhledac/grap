*** Settings ***
Library           String
Library           SeleniumLibrary
Library           Collections
Library           OperatingSystem
Library           pabot.PabotLib
Library           ArchiveLibrary
Library           RequestsLibrary
Library           ../custom-library/NetworkConditions.py
Resource          ../core/API/api_access.robot
Resource          ../core/_common_keywords/common_menu_screen.robot
Resource          ../core/_common_keywords/common_Cashier_screen.robot
Resource          ../core/actions/login/login_action.robot
Resource          ../core/actions/hang-hoa/hang_hoa_navigation.robot
Resource          ../core/actions/giao-dich/giao_dich_navigation.robot
Resource          ../core/actions/doi-tac/doi_tac_navigation.robot
Resource          ../core/actions/thu-ngan/thu_ngan_action.robot

*** Variables ***
&{DICT_URL}    loan02=https://fnb.kiotviet.vn/loan02    autofnb=https://fnb.kiotviet.vn/autofnb    autofnb2=https://fnb.kiotviet.vn/autofnb2
...    autofnbtest15=https://fnb.kiotviet.vn/autofnbtest15    autofnbtest19=https://fnb.kiotviet.vn/autofnbtest19    autofnbtest6=https://fnb.kiotviet.vn/autofnbtest6
...    autofnbtest1=https://fnb.kiotviet.vn/autofnbtest1    autofnbtest2=https://fnb.kiotviet.vn/autofnbtest2    autofnbtest3=https://fnb.kiotviet.vn/autofnbtest3
...    autofnbtest4=https://fnb.kiotviet.vn/autofnbtest4    autofnbtest5=https://fnb.kiotviet.vn/autofnbtest5    autofnbz271=https://fnb.kiotviet.vn/autofnbz271
...    autofnbz272=https://fnb.kiotviet.vn/autofnbz272    autofnbz273=https://fnb.kiotviet.vn/autofnbz273    autofnbz274=https://fnb.kiotviet.vn/autofnbz274
...    autofnbz275=https://fnb.kiotviet.vn/autofnbz275    release1=https://fnb.kvpos.com:59550/release1    release2=https://fnb.kvpos.com:59550/release2
...    release3=https://fnb.kvpos.com:59550/release3    release4=https://fnb.kvpos.com:59550/release4    release5=https://fnb.kvpos.com:59550/release5
...    release6=https://fnb.kvpos.com:59550/release6    release7=https://fnb.kvpos.com:59550/release7    auto18=https://fnb.kvpos.com:59531/auto18
...    auto19=https://fnb.kvpos.com:59531/auto19    auto20=https://fnb.kvpos.com:59531/auto20    auto21=https://fnb.kvpos.com:59531/auto21
...    auto17=https://fnb.kvpos.com:59531/auto17    autonewfnb=https://fnb.kvpos.com:59531/autonewfnb    auto22=https://fnb.kvpos.com:59531/auto22
...    auto23=https://fnb.kvpos.com:59531/auto23     auto24=https://fnb.kvpos.com:59531/auto24

...    anna52=https://fnb.kvpos.com:59534/anna52

...    autofnbdev1=https://fnb.kvpos.com:59548/autofnbdev1
...    autofnbdev2=https://fnb.kvpos.com:59548/autofnbdev2    autofnbdev3=https://fnb.kvpos.com:59548/autofnbdev3    autofnbdev4=https://fnb.kvpos.com:59548/autofnbdev4
...    autofnbdev5=https://fnb.kvpos.com:59548/autofnbdev5    autofnbz7a=https://fnb.kiotviet.vn/autofnbz7a    autofnbz7b=https://fnb.kiotviet.vn/autofnbz7b
...    autofnbz7c=https://fnb.kiotviet.vn/autofnbz7c    autofnbz7d=https://fnb.kiotviet.vn/autofnbz7d    autofnbz7e=https://fnb.kiotviet.vn/autofnbz7e
...    autofnbz15a=https://fnb.kiotviet.vn/autofnbz15a    autofnbz15b=https://fnb.kiotviet.vn/autofnbz15b    autofnbz15c=https://fnb.kiotviet.vn/autofnbz15c
...    autofnbz15d=https://fnb.kiotviet.vn/autofnbz15d    autofnbz15e=https://fnb.kiotviet.vn/autofnbz15e    autofnbz16a=https://fnb.kiotviet.vn/autofnbz16a
...    autofnbz16b=https://fnb.kiotviet.vn/autofnbz16b    autofnbz16c=https://fnb.kiotviet.vn/autofnbz16c    autofnbz16d=https://fnb.kiotviet.vn/autofnbz16d
...    autofnbz16e=https://fnb.kiotviet.vn/autofnbz16e

...    autofnbz33a=https://fnb.kiotviet.vn/autofnbz33a    autofnbz33b=https://fnb.kiotviet.vn/autofnbz33b    autofnbz33c=https://fnb.kiotviet.vn/autofnbz33c
...    autofnbz33d=https://fnb.kiotviet.vn/autofnbz33d    autofnbz33e=https://fnb.kiotviet.vn/autofnbz33e    autofnbz33f=https://fnb.kiotviet.vn/autofnbz33f

...    autofnbz34a=https://fnb.kiotviet.vn/autofnbz34a    autofnbz34b=https://fnb.kiotviet.vn/autofnbz34b    autofnbz34c=https://fnb.kiotviet.vn/autofnbz34c
...    autofnbz34d=https://fnb.kiotviet.vn/autofnbz34d    autofnbz34e=https://fnb.kiotviet.vn/autofnbz34e    autofnbz34f=https://fnb.kiotviet.vn/autofnbz34f

&{DICT_PROFILE}    loan02=Profile 1    autofnb=Profile 2    autofnb2=Profile 3    autofnbtest15=Profile 4    autofnbtest19=Profile 5    autofnbtest6=Profile 6
...    autofnbtest1=Profile 7    autofnbtest2=Profile 8    autofnbtest3=Profile 9    autofnbtest4=Profile 10    autofnbtest5=Profile 11    autofnbz271=Profile 12
...    autofnbz272=Profile 13    autofnbz273=Profile 14    autofnbz274=Profile 15    autofnbz275=Profile 16    release1=Profile 17    release2=Profile 18
...    release3=Profile 19    release4=Profile 20    release5=Profile 21    release6=Profile 22    release7=Profile 23    auto18=Profile 24    auto19=Profile 25
...    auto20=Profile 26    auto21=Profile 27    auto17=Profile 28    autonewfnb=Profile 29    auto22=Profile 30    auto23=Profile 31    auto24=Profile 32
...    autofnbdev1=Profile 33    autofnbdev2=Profile 34    autofnbdev3=Profile 35    autofnbdev4=Profile 36    autofnbdev5=Profile 37    autofnbz7a=Profile 38
...    autofnbz7b=Profile 39    autofnbz7c=Profile 40    autofnbz7d=Profile 41    autofnbz7e=Profile 42    autofnbz15a=Profile 42    autofnbz15b=Profile 41
...    autofnbz15c=Profile 42    autofnbz15d=Profile 43    autofnbz15e=Profile 44     autofnbz16a=Profile 45    autofnbz16b=Profile 46    autofnbz16c=Profile 47
...    autofnbz16d=Profile 48    autofnbz16e=Profile 49

...    anna52=Profile68

...    autofnbz33a=Profile 50    autofnbz33b=Profile 51    autofnbz33c=Profile 52    autofnbz33d=Profile 53    autofnbz33e=Profile 54    autofnbz33f=Profile 55

...    autofnbz15e=Profile 56     autofnbz16a=Profile 57    autofnbz16b=Profile 58    autofnbz16c=Profile 59    autofnbz16d=Profile 60    autofnbz16e=Profile 61
...    autofnbz34a=Profile 62    autofnbz34b=Profile 63    autofnbz34c=Profile 64    autofnbz34d=Profile 65    autofnbz34e=Profile 66    autofnbz34f=Profile 67

&{DICT_USER_NAME}    loan02=admin    autofnb=admin    autofnb2=admin    autofnbtest15=admin    autofnbtest19=admin    autofnbtest6=admin    autofnbtest1=admin
...    autofnbtest2=admin    autofnbtest3=admin    autofnbtest4=admin    autofnbtest5=admin    autofnbz271=admin    autofnbz272=admin    autofnbz273=admin
...    autofnbz274=admin    autofnbz275=admin    release1=admin    release2=admin    release3=admin    release4=admin    release5=admin    release6=admin    release7=admin
...    auto18=admin    auto19=admin    auto20=admin    auto21=admin    auto17=admin    autonewfnb=admin    auto22=admin    auto23=admin    auto24=admin
...    autofnbdev1=admin    autofnbdev2=admin    autofnbdev3=admin
...    autofnbdev4=admin    autofnbdev5=admin    autofnbz7a=admin    autofnbz7b=admin    autofnbz7c=admin    autofnbz7d=admin    autofnbz7e=admin    autofnbz15a=admin
...    autofnbz15b=admin    autofnbz15c=admin    autofnbz15d=admin    autofnbz15e=admin    autofnbz16a=admin    autofnbz16b=admin    autofnbz16c=admin    autofnbz16d=admin
...    autofnbz16e=admin

...    anna52=admin

...    autofnbz33a=admin    autofnbz33b=admin    autofnbz33c=admin    autofnbz33d=admin    autofnbz33e=admin    autofnbz33f=admin
...    autofnbz34a=admin    autofnbz34b=admin    autofnbz343c=admin    autofnbz34d=admin    autofnbz34e=admin    autofnbz34f=admin

...    autofnbz15e=admin     autofnbz16a=admin    autofnbz16b=admin    autofnbz16c=admin    autofnbz16d=admin    autofnbz16e=admin

&{DICT_PASSWORD}    loan02=123    autofnb=123    autofnb2=123    autofnbtest15=123    autofnbtest19=123    autofnbtest6=123    autofnbtest1=123    autofnbtest2=123
...    autofnbtest3=123    autofnbtest4=123    autofnbtest5=123    autofnbz271=123    autofnbz272=123    autofnbz273=123    autofnbz274=123    autofnbz275=123
...    release1=123    release2=123    release3=123    release4=123    release5=123    release6=123    release7=123    auto18=123    auto19=123    auto20=123
...    auto21=123    auto17=123    auto22=123    auto23=123    auto24=123
...    autofnbdev1=123    autofnbdev2=123    autofnbdev3=123    autofnbdev4=123    autofnbdev5=123    autofnbz7a=123
...    autofnbz7b=123    autofnbz7c=123    autofnbz7d=123    autofnbz7e=123    autofnbz15a=123    autofnbz15b=123    autofnbz15c=123    autofnbz15d=123    autofnbz15e=123
...    autofnbz16a=123    autofnbz16b=123    autofnbz16c=123    autofnbz16d=123    autofnbz16e=123

...    anna52=123

...    autofnbz33a=123    autofnbz33b=123    autofnbz33c=123    autofnbz33d=123    autofnbz33e=123    autofnbz33f=123
...    autofnbz34a=123    autofnbz34b=123    autofnbz34c=123    autofnbz34d=123    autofnbz34e=123    autofnbz34f=123

...    autofnbz15e=123     autofnbz16a=123    autofnbz16b=123    autofnbz16c=123    autofnbz16d=123    autofnbz16e=123

# ${page_open_basic}    //form[@id='loginForm']//header[contains(@class,'txtC')]//span
${page_open_basic}    //a[contains(@class,'logo')]/span
${page_open_pos}      //div[contains(@class,'header-login')]/a/span

*** Keywords ***
Fill Environment Variables
    [Arguments]    ${download_dir}
    #======================================================Check variable exits======================================================
    ${variable_exist}    Run Keyword And Return Status    Variable Should Exist    \${remote}
    ${remote}    Run Keyword If    not ${variable_exist}    Set Variable    False    ELSE    Set Variable    ${remote}
    ${variable_exist}    Run Keyword And Return Status    Variable Should Exist    \${browser}
    ${browser}    Run Keyword If    not ${variable_exist}    Set Variable    Chrome    ELSE    Set Variable    ${browser}
    ${variable_exist}    Run Keyword And Return Status    Variable Should Exist    \${speed}
    ${speed}    Run Keyword If    not ${variable_exist}    Set Variable    0    ELSE    Set Variable    ${speed}
    ${variable_exist}    Run Keyword And Return Status    Variable Should Exist    \${headless_browser}
    ${headless_browser}    Run Keyword If    not ${variable_exist}    Set Variable    False    ELSE    Set Variable    ${headless_browser}
    ${variable_exist}    Run Keyword And Return Status    Variable Should Exist    \${use_profile}
    ${use_profile}    Run Keyword If    not ${variable_exist}    Set Variable    False    ELSE    Set Variable    ${use_profile}
    ${variable_exist}    Run Keyword And Return Status    Variable Should Exist    \${enable_log}
    ${enable_log}    Run Keyword If    not ${variable_exist}    Set Variable    True    ELSE    Set Variable    ${enable_log}
    ${variable_exist}    Run Keyword And Return Status    Variable Should Exist    \${username}
    ${username}    Run Keyword If    not ${variable_exist}    Set Variable    ${EMPTY}    ELSE    Set Variable    ${username}
    #====================================================End Check variable exits====================================================

    ${URL}    Get From Dictionary    ${DICT_URL}    ${retailer}
    ${PROFILE}     Get From Dictionary    ${DICT_PROFILE}    ${retailer}
    ${USER_NAME}   Run Keyword If    '${username}'=='${EMPTY}'    Get From Dictionary    ${DICT_USER_NAME}    ${retailer}    ELSE    Set Variable    ${username}
    ${PASSWORD}    Get From Dictionary    ${DICT_PASSWORD}    ${retailer}
    ${str_right}   Split String From Right    ${URL}    separator=/    max_split=1
    ${URL_FNB}     Set Variable    ${str_right[0]}
    ${API_URL}     Set Variable    ${URL_FNB}/api
    ${REPORT_API_URL}    Set Variable    ${URL_FNB}/reportapi
    ${KM_API_URL}     Run Keyword If    '${URL_FNB}'=='https://fnb.kiotviet.vn'    Set Variable    https://fnbpromotion.kiotapi.com/api
    ...    ELSE IF    '${URL_FNB}'=='https://fnb.kvpos.com:59550'    Set Variable    https://kvpos.com:53250/api
    ...    ELSE IF    '${URL_FNB}'=='https://fnb.kvpos.com:59534'    Set Variable    https://kvpos.com:53234/api
    ${EVE_URL}     Run Keyword If    '${URL_FNB}'=='https://fnb.kiotviet.vn'    Set Variable    https://fnb-ordering.kiotviet.vn/events
    ...    ELSE IF    '${URL_FNB}'=='https://fnb.kvpos.com:59534'    Set Variable    https://kvpos.com:55134/events
    ...    ELSE    Set Variable    https://kvpos.com:55131/events
    ${PREFIX_CODE_URL}    Run Keyword If    '${URL_FNB}'=='https://fnb.kiotviet.vn'    Set Variable    https://fnb-ordering.kiotviet.vn
    ...    ELSE IF    '${URL_FNB}'=='https://fnb.kvpos.com:59534'    Set Variable    https://kvpos.com:55134
    ...    ELSE    Set Variable    https://kvpos.com:55131
    ${MOBILE_URL}    Run Keyword If    '${URL_FNB}'=='https://fnb.kiotviet.vn'    Set Variable    https://fnbmobile.kiotapi.com
    ...    ELSE IF    '${URL_FNB}'=='https://fnb.kvpos.com:59550'    Set Variable    https://kvpos.com:59150
    ...    ELSE IF    '${URL_FNB}'=='https://fnb.kvpos.com:59548'    Set Variable    https://kvpos.com:59148
    ...    ELSE IF    '${URL_FNB}'=='https://fnb.kvpos.com:59531'    Set Variable    https://kvpos.com:59131
    ...    ELSE IF    '${URL_FNB}'=='https://fnb.kvpos.com:59517'    Set Variable    https://kvpos.com:59117
    ${global_download_dir}    Run Keyword If    '${download_dir}'!='${EMPTY}'    Set Variable    C:\\Automation\\profiles\\chrome\\${PROFILE}\\downloads\\${download_dir}
    ...    ELSE    Set Variable    C:\\Automation\\profiles\\chrome\\${PROFILE}\\FNB

    Set Global Variable    ${BROWSER}    ${browser}
    Set Global Variable    ${API_URL}    ${API_URL}
    Set Global Variable    ${MOBILE_URL}    ${MOBILE_URL}
    Set Global Variable    ${REPORT_API_URL}    ${REPORT_API_URL}
    Set Global Variable    ${KM_API_URL}    ${KM_API_URL}
    Set Global Variable    ${PREFIX_CODE_URL}   ${PREFIX_CODE_URL}
    Set Global Variable    ${URL_FNB}    ${URL_FNB}
    Set Global Variable    ${URL}    ${URL}
    Set Global Variable    ${POS_URL}      ${URL}/pos/#/login
    Set Global Variable    ${EVE_URL}      ${EVE_URL}
    Set Global Variable    ${kv_version}    67fa255f109dbd5d3729692de7644867
    Set Global Variable    ${USER_NAME}    ${USER_NAME}
    Set Global Variable    ${PASSWORD}    ${PASSWORD}
    Set Global Variable    ${RETAILER}    ${retailer}
    Set Global Variable    ${REMOTE_URL}    ${remote}
    Set Global Variable    ${SELENIUM_SPEED}    ${speed}
    Set Global Variable    ${ENABLE_LOG}    ${enable_log}
    Set Global Variable    ${language}    Vi
    Set Global Variable    ${xpath_prefix}    //body/div[not(contains(@style,'display: none'))]
    Set Global Variable    ${global_download_dir}    ${global_download_dir}
    Set Global Variable    ${excel_prepare_dir}    ${EXECDIR}\\prepare-data\\excel-files
    Set Global Variable    ${template_event_dir}    ${EXECDIR}\\api-data\\test_event
    Set Global Variable    ${default_error_msg}    Lỗi hai dữ liệu khác nhau
    Set Selenium Speed     ${SELENIUM_SPEED}
    Set Global Variable    ${IS_HEADLESS_BROWSER}    ${headless_browser}
    Set Global Variable    ${USE_PROFILE}    ${use_profile}

    ${json_settings} =    Set Variable    {"recentDestinations": [{"id": "Save as PDF", "origin": "local", "account": ""}], "selectedDestinationId": "Save as PDF", "version": 2}
    ${setting_print} =    Evaluate    json.dumps(${json_settings})    json
    ${prefs} =    Create Dictionary    download.default_directory=${global_download_dir}    printing.print_preview_sticky_settings.appState=${setting_print}    savefile.default_directory=${global_download_dir}
    ${chrome_options}    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome_options}    add_experimental_option    prefs    ${prefs}
    # Call Method    ${chrome_options}    add_argument    --disable-notifications
    Call Method    ${chrome_options}    add_argument    --kiosk-printing
    Run Keyword If    '${IS_HEADLESS_BROWSER}'=='True'    Call Method    ${chrome_options}   add_argument    headless
    Run Keyword If    '${IS_HEADLESS_BROWSER}'=='True'    Call Method    ${chrome_options}   add_argument    disable-gpu

    #Create Profile & download folder
    KV Prepare Profile Folder    ${download_dir}
    Run Keyword If    '${USE_PROFILE}'=='True'    Call Method    ${chrome_options}   add_argument    user-data-dir\=C:\\Automation\\profiles\\chrome\\${PROFILE}
    Set Global Variable    ${chrome_options}    ${chrome_options}

KV Prepare Profile Folder
    [Arguments]    ${download_dir}
    FOR    ${key}    IN    @{DICT_PROFILE}
        ${is_exist_profile_folder}    Run Keyword And Return Status    Directory Should Exist    C:\\Automation\\profiles\\chrome\\${DICT_PROFILE["${key}"]}
        Run Keyword If    '${is_exist_profile_folder}'=='False'    Extract Zip File    ${EXECDIR}\\drivers\\Profile-Template.zip    C:\\Automation\\profiles\\chrome\\${DICT_PROFILE["${key}"]}
        ${is_exist_profile_download_folder}    Run Keyword And Return Status    Directory Should Exist    C:\\Automation\\profiles\\chrome\\${DICT_PROFILE["${key}"]}\\downloads\\${download_dir}
        Run Keyword If    '${is_exist_profile_download_folder}'=='False'    Create Directory    C:\\Automation\\profiles\\chrome\\${DICT_PROFILE["${key}"]}\\downloads\\${download_dir}
        ${is_exist_common_download_folder}    Run Keyword And Return Status    Directory Should Exist    C:\\Automation\\profiles\\chrome\\${DICT_PROFILE["${key}"]}\\FNB
        Run Keyword If    '${is_exist_common_download_folder}'=='False'    Create Directory    C:\\Automation\\profiles\\chrome\\${DICT_PROFILE["${key}"]}\\FNB
    END

KV Check And Run Keyword
    [Arguments]    ${keyword}
    ${is_kw_exist}    Run Keyword And Return Status    Keyword Should Exist    ${keyword}
    Run Keyword If    '${is_kw_exist}'=='True'    ${keyword}
    KV Log    ${keyword} is_kw_exist = ${is_kw_exist}

KV Get All Keywords Setup & Teardown Testcase
    ${template_str}    Get File    ${SUITE SOURCE}
    @{lines}    Split To Lines    ${template_str}
    ${setup_tc_keywords}    Create List
    ${teardown_tc_keywords}    Create List
    FOR    ${line}    IN    @{lines}
        ${find_setup}    Evaluate    $line.find("_SetupTC")
        ${find_teardown}    Evaluate    $line.find("_TeardownTC")
        Run Keyword If    ${find_setup}==0    Append To List    ${setup_tc_keywords}    ${line}
        ...    ELSE IF    ${find_teardown}==0    Append To List    ${teardown_tc_keywords}    ${line}
    END
    Set Suite Variable    ${setup_tc_keywords}    ${setup_tc_keywords}
    Set Suite Variable    ${teardown_tc_keywords}    ${teardown_tc_keywords}

KV Get Keyword Setup|Teardown Testcase
    [Arguments]    ${keywords}
    #Tìm trong list Setup|Teardown test case keyword, nếu có trong list thì run kw
    ${find_test_name}    Set Variable    ${-1}
    ${keyword}    Set Variable    ${EMPTY}
    FOR    ${tc_keyword}    IN    @{keywords}
        ${find_test_name}    Evaluate    $tc_keyword.find(" ${TEST NAME}")
        ${keyword}    Set Variable If    ${find_test_name}>=0    ${tc_keyword}    ${keyword}
        Run Keyword If    ${find_test_name}>=0    Exit For Loop
    END
    [Return]    ${keyword}

Init Test Environment
    [Arguments]    ${download_dir}=${EMPTY}
    Fill Environment Variables    ${download_dir}
    ${token_value}    ${resp.cookies}    API Get BearerToken&Cookies
    Set Global Variable    ${bearertoken}    ${token_value}
    Set Global Variable    ${resp.cookies}    ${resp.cookies}
    Create Session    session_api          ${API_URL}           cookies=${resp.cookies}    verify=True    disable_warnings=1    debug=1
    Create Session    session_reportapi    ${REPORT_API_URL}    cookies=${resp.cookies}    verify=True    disable_warnings=1    debug=1
    Create Session    session_mobileapi    ${MOBILE_URL}        cookies=${resp.cookies}    verify=True    disable_warnings=1    debug=1
    Create Session    session_kmapi        ${KM_API_URL}        cookies=${resp.cookies}    verify=True    disable_warnings=1    debug=1
    Create Session    session_getPrefix    ${PREFIX_CODE_URL}   cookies=${resp.cookies}    verify=True    disable_warnings=1    debug=1
    Append To Environment Variable    PATH    ${EXECDIR}${/}drivers
    Set Screenshot Directory    ${EXECDIR}${/}..${/}out${/}failures
    ${retailer_id}    ${user_id}    ${current_branch_id}    ${current_branch_name}    KV Get RetailerId And UserId And BranchId
    Set Global Variable    ${BRANCH_ID}      ${current_branch_id}
    Set Global Variable    ${RETAILER_ID}    ${retailer_id}
    Set Global Variable    ${USER_ID}        ${user_id}
    Set Global Variable    ${BRANCH_NAME}    ${current_branch_name}
    Set Global Variable    ${LATESTBRANCH}    LatestBranch_${retailer_id}_${user_id}


Setup API Event Test Suite
    [Arguments]    @{keywords}
    Log To Console    StatusLogger____${SUITE NAME}____START____    #Must be on top! Do not remove!
    Import Resource    ${EXECDIR}/core/share/utils.robot
    Init Test Environment
    Create Session    event_sync    ${EVE_URL}    cookies=${resp.cookies}    verify=True    disable_warnings=1    debug=1
    Set Suite Variable    @{setup_suite_keywords}    @{keywords}
    Run Keywords    @{setup_suite_keywords}
    ${result_dict}    API Call From Template    api-access/prefixCode.txt    json_path=$..prefixCode    session_alias=session_getPrefix
    ${prfixCode}    Set Variable Return From Dict    ${result_dict.prefixCode[0]}
    Set Suite Variable   ${PrefixCode}    ${prfixCode}
    Set Suite Variable    ${Prefix_ver}   0
    KV Get All Keywords Setup & Teardown Testcase
    Set Suite Variable    ${version}    9000000000000
    KV Check And Run Keyword    _SetupS

Setup API Event Test Case
    Log To Console    StatusLogger____${SUITE NAME}____${TEST NAME}____START____    #Must be on top! Do not remove!
    Set Test Variable    @{LIST_ERROR}    @{EMPTY}
    ${uuid1}    Generate Random UUID
    ${uuid2}    Generate Random UUID
    Set Test Variable    ${replica_id}        WebApp-${uuid1}
    Set Test Variable    ${firebase_token}    kiotviet_fnb_${uuid2}
    Set Test Variable    ${event_ver}    0
    #Tìm trong list setup test case keyword, nếu có trong list thì run kw
    Set Selenium Speed   0.3
    ${setup_keyword}    KV Get Keyword Setup|Teardown Testcase    ${setup_tc_keywords}
    Run Keyword If    '${setup_keyword}'!='${EMPTY}'    ${setup_keyword}
    Set Selenium Speed    ${SELENIUM_SPEED}

Setup Test Suite
    [Arguments]    @{keywords}
    Log To Console    StatusLogger____${SUITE NAME}____START____    #Must be on top! Do not remove!
    Import Resource    ${EXECDIR}/core/share/utils.robot
    Import Resource    ${EXECDIR}/core/actions/menu/header_menu_action.robot
    ${length}    Get Length    ${keywords}
    Set Suite Variable    ${length_keyword}    ${length}
    ${download_dir}    Run Keyword If    ${length} > 1    Set Variable    ${keywords[-1]}
    ...    ELSE    Set Variable    ${EMPTY}
    Run Keyword If    ${length} > 1    Remove From List    ${keywords}    -1
    Init Test Environment    ${download_dir}
    Create Session    event_sync    ${EVE_URL}    cookies=${resp.cookies}    verify=True    disable_warnings=1    debug=1
    Set Selenium Speed    0.3
    Set Suite Variable    @{setup_suite_keywords}    @{keywords}
    ${result_dict}    API Call From Template    api-access/prefixCode.txt    json_path=$..prefixCode    session_alias=session_getPrefix
    ${prfixCode}    Set Variable Return From Dict    ${result_dict.prefixCode[0]}
    Set Suite Variable   ${PrefixCode}    ${prfixCode}
    Set Suite Variable    ${Prefix_ver}   0
    Run Keywords    @{setup_suite_keywords}
    KV Get All Keywords Setup & Teardown Testcase
    Set Suite Variable    ${version}    9000000000000
    Set Suite Variable    ${prefix_hh_prepare}    HHPrepare
    Set Suite Variable    ${prefix_hh_testcase}    HHTestcase
    # tạo pool mã hh prepare
    ${pool_mahh_pp}    Create List
    # tạo pool mã hh testcase
    ${pool_mahh_tc}    Create List
    Set Suite Variable    @{refresh_keyword}    Reload Page
    KV Check And Run Keyword    _SetupS
    # tạo sẵn 10 mã theo định dạng prefix + [index+1]
    FOR    ${index}    IN RANGE    10
        ${zfill_index}    Evaluate    str(${index}+1).zfill(3)
        Append to list   ${pool_mahh_pp}   ${prefix_hh_prepare}${zfill_index}
        Append to list   ${pool_mahh_tc}   ${prefix_hh_testcase}${zfill_index}
    END
    Set Suite Variable    ${pool_mahh_pp}    ${pool_mahh_pp}
    Set Suite Variable    ${pool_mahh_tc}    ${pool_mahh_tc}
    Set Selenium Speed    ${SELENIUM_SPEED}

Setup Test Case
    Log To Console    StatusLogger____${SUITE NAME}____${TEST NAME}____START____    #Must be on top! Do not remove!
    Set Test Variable    @{LIST_ERROR}    @{EMPTY}
    ${is_WebDriverException}    Evaluate    "WebDriverException: Message: java.net.ConnectException: Connection refused: connect" in """${PREV TEST MESSAGE}"""
    Run Keyword If    '${is_WebDriverException}'=='True'    Run Keywords    Close All Browsers    @{setup_suite_keywords}
    #reload page if previous test fail
    Run Keyword If    '${PREV TEST STATUS}'=='FAIL' and '${is_WebDriverException}'=='False'    Reload Page
    Set Test Variable    ${count_hh_cungloai}    ${0}
    Set Test Variable    ${so_ma_hh_pp}    ${0}
    Set Test Variable    ${so_ma_hh_chinh}    ${0}
    ${uuid1}    Generate Random UUID
    ${uuid2}    Generate Random UUID
    Set Test Variable    ${replica_id}        WebApp-${uuid1}
    Set Test Variable    ${firebase_token}    kiotviet_fnb_${uuid2}
    Set Test Variable    ${event_ver}    0
    #Tìm trong list setup test case keyword, nếu có trong list thì run kw
    Set Selenium Speed   0.3
    ${setup_keyword}    KV Get Keyword Setup|Teardown Testcase    ${setup_tc_keywords}
    Run Keyword If    '${setup_keyword}'!='${EMPTY}'    ${setup_keyword}
    ${browser_alias}    Get Browser Aliases
    ${length_alias}    Get Length    ${browser_alias}
    ${browser_exist}    Run Keyword If    '${length_alias}'>'0'    Set Variable    True    ELSE    Set Variable    False
    #get fresh data
    ${status}    Run Keyword And Return Status    Run Keyword    @{refresh_keyword}
    Run Keyword If    '${status}'=='False' and '${browser_exist}'=='True'    Reload Page
    Set Selenium Speed    ${SELENIUM_SPEED}

Setup MHTN Test Suite
    [Arguments]    @{keywords}
    Log To Console    StatusLogger____${SUITE NAME}____START____    #Must be on top! Do not remove!
    Import Resource    ${EXECDIR}/core/share/utils.robot
    Import Resource    ${EXECDIR}/core/actions/menu/MHTN_menu_bar_action.robot
    ${length}    Get Length    ${keywords}
    ${download_dir}    Run Keyword If    ${length} > 1    Set Variable    ${keywords[-1]}
    ...    ELSE    Set Variable    ${EMPTY}
    Run Keyword If    ${length} > 1    Remove From List    ${keywords}    -1
    Init Test Environment    ${download_dir}
    Create Session    event_sync    ${EVE_URL}    cookies=${resp.cookies}    verify=True    disable_warnings=1    debug=1
    Set Selenium Speed    0.3
    Set Suite Variable    @{setup_suite_keywords}    @{keywords}
    ${result_dict}    API Call From Template    api-access/prefixCode.txt    json_path=$..prefixCode    session_alias=session_getPrefix
    ${prfixCode}    Set Variable Return From Dict    ${result_dict.prefixCode[0]}
    Set Suite Variable   ${PrefixCode}    ${prfixCode}
    Set Suite Variable    ${Prefix_ver}   0
    Run Keywords    @{setup_suite_keywords}
    KV Get All Keywords Setup & Teardown Testcase
    Set Suite Variable    @{refresh_keyword}    KV Reload Page MHTN
    Set Suite Variable    ${version}    9000000000000
    KV Check And Run Keyword    _SetupS
    Run Keyword If    ${length} >= 1    OFF tu dong in hoa don
    Set Selenium Speed    ${SELENIUM_SPEED}
    Run Keyword If    ${length} >0    FNB WaitVisible MHTN Header Text Title Phong Ban

Setup MHTN Test Case
    Log To Console    StatusLogger____${SUITE NAME}____${TEST NAME}____START____    #Must be on top! Do not remove!
    Set Test Variable    @{LIST_ERROR}    @{EMPTY}
    ${is_WebDriverException}    Evaluate    "WebDriverException: Message: java.net.ConnectException: Connection refused: connect" in """${PREV TEST MESSAGE}"""
    Run Keyword If    '${is_WebDriverException}'=='True'    Run Keywords    Close All Browsers    @{setup_suite_keywords}
    #Set giá trị uuid
    ${uuid1}    Generate Random UUID
    ${uuid2}    Generate Random UUID
    Set Test Variable    ${replica_id}        WebApp-${uuid1}
    Set Test Variable    ${firebase_token}    kiotviet_fnb_${uuid2}
    Set Test Variable    ${event_ver}    0
    #reload page if previous test fail
    Run Keyword If    '${PREV TEST STATUS}'=='FAIL' and '${is_WebDriverException}'=='False'    KV Reload Page MHTN
    #Tìm trong list setup test case keyword, nếu có trong list thì run kw
    Set Selenium Speed   0.3
    ${setup_keyword}    KV Get Keyword Setup|Teardown Testcase    ${setup_tc_keywords}
    Run Keyword If    '${setup_keyword}'!='${EMPTY}'    ${setup_keyword}
    ${browser_alias}    Get Browser Aliases
    ${length_alias}    Get Length    ${browser_alias}
    ${browser_exist}    Run Keyword If    '${length_alias}'>'0'    Set Variable    True    ELSE    Set Variable    False
    Run Keyword If    '${PREV TEST STATUS}'=='False' and '${browser_exist}'=='True'    KV Reload Page MHTN
    Set Selenium Speed    ${SELENIUM_SPEED}
    FNB WaitNotVisible MHTN Header Loading Icon    wait_time_out=1 min

Setup MHTN Android Test Case
    Log To Console    StatusLogger____${SUITE NAME}____${TEST NAME}____START____    #Must be on top! Do not remove!
    Set Test Variable    @{LIST_ERROR}    @{EMPTY}
    ${is_WebDriverException}    Evaluate    "WebDriverException: Message: java.net.ConnectException: Connection refused: connect" in """${PREV TEST MESSAGE}"""
    Run Keyword If    '${is_WebDriverException}'=='True'    Run Keywords    Close All Browsers    @{setup_suite_keywords}
    #Set giá trị uuid
    ${uuid1}    Generate Random UUID
    ${uuid2}    Generate Random UUID
    Set Test Variable    ${replica_id}        WebApp-${uuid1}
    Set Test Variable    ${firebase_token}    kiotviet_fnb_${uuid2}
    Set Test Variable    ${event_ver}    0
    Run Keyword If    '${PREV TEST STATUS}'=='FAIL' and '${is_WebDriverException}'=='False'    KV Reload Page MHTN
    #Tìm trong list setup test case keyword, nếu có trong list thì run kw
    Set Selenium Speed   0.3
    ${setup_keyword}    KV Get Keyword Setup|Teardown Testcase    ${setup_tc_keywords}
    Run Keyword If    '${setup_keyword}'!='${EMPTY}'    ${setup_keyword}
    ${browser_alias}    Get Browser Aliases
    ${length_alias}    Get Length    ${browser_alias}
    ${browser_exist}    Run Keyword If    '${length_alias}'>'0'    Set Variable    True    ELSE    Set Variable    False
    Run Keyword If    '${PREV TEST STATUS}'=='False' and '${browser_exist}'=='True'    KV Reload Page MHTN
    Set Selenium Speed    ${SELENIUM_SPEED}
    FNB WaitNotVisible MHTN Header Loading Icon    wait_time_out=1 min

KV Set Network Offline
    Set Network Conditions    is_offline=True

KV Set Network Online
    Set Network Conditions    is_offline=False

Before Test Login POS
    Open Browser    ${POS_URL}    ${BROWSER}    remote_url=${REMOTE_URL}    alias=${USER_NAME}    options=${chrome_options}
    Wait Until Element Contains    ${page_open_pos}    Đăng nhập hệ thống    timeout=1 minute
    Run Keyword If    '${IS_HEADLESS_BROWSER}'=='True'    Set Window Size    1920    1080    ELSE    Maximize Browser Window

Before Test Login
    Open Browser    ${URL}    ${BROWSER}    remote_url=${REMOTE_URL}    alias=${USER_NAME}    options=${chrome_options}
    Wait Until Element Contains    ${page_open_basic}    Đăng nhập hệ thống
    Run Keyword If    '${IS_HEADLESS_BROWSER}'=='True'    Set Window Size    1920    1080    ELSE    Maximize Browser Window

Before Test Quan ly
    [Arguments]    ${retailer}=${RETAILER}    ${username}=${USER_NAME}    ${password}=${PASSWORD}    ${alias}=browser00    ${options}=${chrome_options}
    Open Browser    ${URL}    ${BROWSER}    remote_url=${REMOTE_URL}    alias=${alias}    options=${chrome_options}
    Run Keyword If    '${IS_HEADLESS_BROWSER}'=='True'    Set Window Size    1920    1080    ELSE    Maximize Browser Window
    Login Quan Ly successfully    ${retailer}    ${username}    ${password}

Before Test Thu Ngan
    [Arguments]    ${retailer}=${RETAILER}    ${username}=${USER_NAME}    ${password}=${PASSWORD}    ${alias}=browser99    ${options}=${chrome_options}
    Open Browser    ${URL}    ${BROWSER}    remote_url=${REMOTE_URL}    alias=${alias}    options=${chrome_options}
    Run Keyword If    '${IS_HEADLESS_BROWSER}'=='True'    Set Window Size    1920    1080    ELSE    Maximize Browser Window
    Login Thu Ngan successfully    ${retailer}    ${username}    ${password}


Teardown API Event Test Suite
    KV Check And Run Keyword    _TeardownS
    Log To Console    StatusLogger____${SUITE NAME}____${SUITE STATUS}____    #Must be at bottom! Do not remove!

Teardown API Event Test Case
    # Tìm trong list teardown test case keyword, nếu có trong list thì run kw
    ${teardown_keyword}    KV Get Keyword Setup|Teardown Testcase    ${teardown_tc_keywords}
    Run Keyword If    '${teardown_keyword}'!='${EMPTY}'    ${teardown_keyword}
    Log To Console    StatusLogger____${SUITE NAME}____${TEST NAME}____${TEST STATUS}____    #Must be at bottom! Do not remove!

Teardown Test Suite
    KV Check And Run Keyword    _TeardownS
    Close All Browsers
    Log To Console    StatusLogger____${SUITE NAME}____${SUITE STATUS}____    #Must be at bottom! Do not remove!

Teardown Test Case
    #xóa hh testcase hàng cùng loại tự sinh
    FOR    ${index}    IN RANGE   ${count_hh_cungloai}
        ${zfill_index}    Evaluate    str(${index}+1).zfill(2)
        Delete hang hoa    ${prefix_hh_cungloai}${zfill_index}
    END
    #xóa hh testcase theo mã lấy từ pool
    FOR    ${index}    IN RANGE   ${so_ma_hh_chinh}
        Delete hang hoa    ${pool_mahh_tc[${index}]}
    END
    #xóa hh prepare theo mã lấy từ pool
    FOR    ${index}    IN RANGE   ${so_ma_hh_pp}
        Delete hang hoa    ${pool_mahh_pp[${index}]}
    END
    # Xóa file excel export sau khi download
    Run Keyword If    ${length_keyword}>1    Run Keyword And Ignore Error    Empty Directory    ${global_download_dir}
    Run Keyword If    ${length_keyword}>1    Run Keyword And Ignore Error    FNB Menu Icon Close NotiBoard    is_wait_visible=True    wait_time_out=5s
    #Tìm trong list teardown test case keyword, nếu có trong list thì run kw
    ${teardown_keyword}    KV Get Keyword Setup|Teardown Testcase    ${teardown_tc_keywords}
    Run Keyword If    '${teardown_keyword}'!='${EMPTY}'    ${teardown_keyword}
    Log To Console    StatusLogger____${SUITE NAME}____${TEST NAME}____${TEST STATUS}____    #Must be at bottom! Do not remove!

Teardown MHTN Test Case
    # Xóa file excel export sau khi download
    Run Keyword And Ignore Error    Empty Directory    ${global_download_dir}
    #Tìm trong list teardown test case keyword, nếu có trong list thì run kw
    ${teardown_keyword}    KV Get Keyword Setup|Teardown Testcase    ${teardown_tc_keywords}
    Run Keyword If    '${teardown_keyword}'!='${EMPTY}'    ${teardown_keyword}
    Log To Console    StatusLogger____${SUITE NAME}____${TEST NAME}____${TEST STATUS}____    #Must be at bottom! Do not remove!
