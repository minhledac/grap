import os

from robot.api.deco import keyword
from AppiumLibrary.version import VERSION
from robot.version import get_version
# from selenium.webdriver.remote.command import Command
from appium.webdriver.common.touch_action import TouchAction
from robot.libraries.BuiltIn import BuiltIn

__version__ = VERSION

class DoubleClick():
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_EXIT_ON_FAILURE = True

    @keyword('Double Click')
    def double_click(self, element):
        appiumlib = BuiltIn().get_library_instance('AppiumLibrary')
        driver = appiumlib._current_application()
        # self._actions = []
        # self._actions.append(lambda: self.driver.execute(
        #     Command.DOUBLE_TAP, {'element': element}))
        # actions = TouchAction(driver).double_tap(element).perform()
        # action0 = TouchAction().tap(element)
        # action1 = TouchAction().tap(element)
        # MultiAction().add(action0).add(action1).perform()
