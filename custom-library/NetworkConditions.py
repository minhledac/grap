from robot.api import logger
from robot.api.deco import keyword
from selenium.webdriver import Chrome
from robot.libraries.BuiltIn import BuiltIn
import selenium.webdriver.chrome.webdriver

__author__ = 'Son Nguyen Duc'
__email__ = 'sonzqn@gmail.com'


class NetworkConditions():
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_EXIT_ON_FAILURE = True

    @keyword('Set Network Conditions')
    def set_network_conditions(self, is_offline=False, latency_value = 5, throughput_value = 500):
        driver = BuiltIn().get_library_instance('SeleniumLibrary').driver
        if not hasattr(driver, 'set_network_conditions'):
            logger.error("Remote Webdriver không hỗ trợ thay đổi network condition!")
        driver.set_network_conditions(offline=is_offline, latency=latency_value, throughput=throughput_value * 1024)
        conditions = driver.get_network_conditions()