*** Settings ***
Library           SeleniumLibrary
Library           String

*** Variables ***
${mes_click}      document.evaluate("{0}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click()
${mes_sendkey}    document.evaluate("{0}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.send_keys('\n')
${mes_getvalue}    document.evaluate("{0}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.return()

*** Keywords ***
Click Element JS
    [Arguments]    ${xpath_element}
    [Timeout]    15 seconds
    ${xpath}    Format String    ${mes_click}    ${xpath_element}
    Execute Javascript    ${xpath}

Sendkey JS
    [Arguments]    ${xpath_element}
    ${xpath}    Format String    ${mes_sendkey}    ${xpath_element}
    Execute Javascript    ${xpath}

Get value JS
    [Arguments]    ${xpath_element}
    ${xpath}    Format String    ${mes_getvalue}    ${xpath_element}
    Execute Javascript    ${xpath}
