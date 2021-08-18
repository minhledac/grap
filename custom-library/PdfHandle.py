import pdfplumber
import os.path
import urllib.parse
from selenium import webdriver
from robot.api import logger
from robot.api.deco import keyword
from selenium.webdriver import Chrome

__author__ = 'Loan Nguyen Thi'
__enamil__='loan.nt@citigo.com.vn'

class PdfHandle():
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_EXIT_ON_FAILURE = True

    @keyword('Extra Text From PDF')
    def extra_text_from_pdf(self,file_name):
        if os.path.isfile(file_name) is False:
            logger.error("File does not exit")
        with pdfplumber.open(file_name) as pdf:
            first_page = pdf.pages[0]
            data = first_page.extract_text()
        return data
