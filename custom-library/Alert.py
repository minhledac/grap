import time

from selenium import webdriver
from robot.api import logger
from robot.api.deco import keyword
from selenium.webdriver import Chrome
from robot.libraries.BuiltIn import BuiltIn

class Alert():
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_EXIT_ON_FAILURE = True

    @keyword('Accept Alert')
    def accept_alert(self):
        driver = BuiltIn().get_library_instance('SeleniumLibrary').driver
        al = driver.switch_to.alert
        al.accept()
