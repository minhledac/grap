import uuid
import urllib.parse
from robot.api.deco import keyword

__author__ = 'Ha Viet Hai'

class UtilityLibrary():
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_EXIT_ON_FAILURE = True

    @keyword('Generate Random UUID')
    def get_a_uuid(self):
        return str(uuid.uuid4())

    @keyword('URL Encoding Query String')
    def url_encoding_string(self, query):
        result= urllib.parse.quote_plus(query)
        return str(result)
