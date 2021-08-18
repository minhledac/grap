import os

from AppiumLibrary.keywords import *
from AppiumLibrary.version import VERSION
from robot.version import get_version
from appium.webdriver.common.touch_action import TouchAction
from robot.libraries.BuiltIn import BuiltIn
from robot.api.deco import keyword

__version__ = VERSION

class DoubleClick():
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_VERSION = VERSION

    @keyword('Double Click')
    def double_click(self, element):
        appiumlib = BuiltIn().get_library_instance('AppiumLibrary')
        driver = appiumlib._current_application()
        driver = appiumdriver
        actions = TouchAction(driver)
        actions.double_tap(element)
        actions.perform()
