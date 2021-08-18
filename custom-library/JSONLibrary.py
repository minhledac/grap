# -*- coding: utf-8 -*-
import json
import os.path
import re
from robot.api import logger
from robot.api.deco import keyword
from jsonpath_rw import Index, Fields
from jsonpath_rw_ext import parse

__author__ = 'Traitanit Huangsri'
__email__ = 'traitanit.hua@gmail.com'
__modifier__ = 'sonzqn@gmail.com'


class JSONLibrary():
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_EXIT_ON_FAILURE = True

    @keyword('Load JSON From File')
    def load_json_from_file(self, file_name):
        """Load JSON from file.

        Return json as a dictionary object.

        Arguments:
            - file_name: absolute json file name

        Return json object (list or dictionary)

        Examples:
        | ${result}=  |  Load Json From File  | /path/to/file.json |
        """
        logger.debug("Check if file exists")
        if os.path.isfile(file_name) is False:
            # logger.error("JSON file: " + file_name + " not found")
            raise IOError
        with open(file_name) as json_file:
            data = json.load(json_file)
        return data

    @keyword('Add Object To Json')
    def add_object_to_json(self, json_object, json_path, object_to_add):
        """Add an dictionary or list object to json object using json_path

            Arguments:
                - json_object: json as a dictionary object.
                - json_path: jsonpath expression
                - object_to_add: dictionary or list object to add to json_object which is matched by json_path

            Return new json object.

            Examples:
            | ${dict}=  | Create Dictionary    | latitude=13.1234 | longitude=130.1234 |
            | ${json}=  |  Add Object To Json  | ${json}          | $..address         |  ${dict} |
            """
        json_path_expr = parse(json_path)
        for match in json_path_expr.find(json_object):
            if type(match.value) is dict:
                match.value.update(object_to_add)
            if type(match.value) is list:
                match.value.append(object_to_add)

        return json_object

    @keyword('Get Value From Json')
    def get_value_from_json(self, json_object, json_path):
        """Get Value From JSON using JSONPath

        Arguments:
            - json_object: json as a dictionary object.
            - json_path: jsonpath expression

        Return array of values

        Examples:
        | ${values}=  |  Get Value From Json  | ${json} |  $..phone_number |
        """
        json_path_expr = parse(json_path)
        return [match.value for match in json_path_expr.find(json_object)]

    @keyword('Get Dict From List Json')
    def get_dict_from_list_json(self, json_object, list_json_path):
        """Get Dict From JSON using JSONPath

        Arguments:
            - json_object: json as a dictionary object.
            - list_json_path: list jsonpath expression

        Return dict of values

        Examples:
        | ${values}=  |  Get Dict From Json  | ${json} |  $..phone_number |
        """
        dict = {}
        index_json = 0
        for json_path in list_json_path:
            index_json+=1
            one_json_paths = ""
            two_json_paths = ""
            if json_path.endswith(']'):
                one_json_paths = json_path.rsplit('.[',1)
                two_json_paths = json_path.rsplit('..[',1)
            else:
                one_json_paths = json_path.rsplit('.',1)
                two_json_paths = json_path.rsplit('..',1)

            if one_json_paths[-1]==two_json_paths[-1]:
                json_paths=two_json_paths
                if json_paths[0].endswith(']') and json_paths[0].find("].")>0:
                    pre_json_paths = json_paths[0].rsplit('].',1)
                    json_paths[0] = pre_json_paths[0] + "]"
                    prefix_sub_json_path = "$." + pre_json_paths[1] + ".."
                else:
                    prefix_sub_json_path = "$.."
            else:
                json_paths=one_json_paths
                if json_paths[0].endswith(']') and json_paths[0].find("].")>0:
                    pre_json_paths = json_paths[0].rsplit('].',1)
                    json_paths[0] = pre_json_paths[0] + "]"
                    prefix_sub_json_path = "$." + pre_json_paths[1] + "."
                else:
                    prefix_sub_json_path = "$."
            #logger.error("json_paths 0: " + json_paths[0] + " json_paths 1: "+json_paths[1] + " prefix_sub_json_path: " + prefix_sub_json_path)

            json_path_expr = parse(json_paths[0])

            list_key = json_paths[1].split(',')
            length = len(list_key)

            if len(prefix_sub_json_path)>3:
                #logger.error(prefix_sub_json_path+'['+json_paths[1])
                list = []
                for match in json_path_expr.find(json_object):
                    result = JSONLibrary.get_dict_from_list_json(self, match.value, [prefix_sub_json_path+'['+json_paths[1]])
                    list.append(result)
                if len(list)<1:
                    list.append({})
                key = pre_json_paths[1].rsplit('.',1)[-1].rsplit('[',1)[-2]
                #logger.error(key)
                if key in dict.keys():
                    dict[str(key)+str(index_json)] = list
                else:
                    dict[str(key)] = list
            else:
                for index in range(length):
                    list_key[index] = re.sub('\[|\]|\'|\"', '', list_key[index]).strip()
                    list = []
                    for match in json_path_expr.find(json_object):
                        json_path_sub_expr = parse(prefix_sub_json_path+list_key[index])
                        found = False
                        #logger.error(prefix_sub_json_path+list_key[index])
                        for match_sub in json_path_sub_expr.find(match.value):
                            found = True
                            list.append(match_sub.value)
                        if found == False:
                            list.append(0)
                    if len(list)<1:
                        list.append(0)
                    key = list_key[index].rsplit('.',1)[-1]
                    if key in dict.keys():
                        dict[str(key)+str(index_json)] = list
                    else:
                        dict[str(key)] = list
        # logger.error(dict)
        return dict

    @keyword('Update Value To Json')
    def update_value_to_json(self, json_object, json_path, new_value):
        """Update value to JSON using JSONPath

        Arguments:
            - json_object: json as a dictionary object.
            - json_path: jsonpath expression
            - new_value: value to update

        Return new json_object

        Examples:
        | ${json_object}=  |  Update Value To Json | ${json} |  $..address.streetAddress  |  Ratchadapisek Road |
        """
        json_path_expr = parse(json_path)
        for match in json_path_expr.find(json_object):
            path = match.path
            if isinstance(path, Index):
                match.context.value[match.path.index] = new_value
            elif isinstance(path, Fields):
                match.context.value[match.path.fields[0]] = new_value
        return json_object

    @keyword('Delete Object From Json')
    def delete_object_from_json(self, json_object, json_path):
        """Delete Object From JSON using json_path

        Arguments:
            - json_object: json as a dictionary object.
            - json_path: jsonpath expression

        Return new json_object

        Examples:
        | ${json_object}=  |  Delete Object From Json | ${json} |  $..address.streetAddress  |
        """
        json_path_expr = parse(json_path)
        for match in json_path_expr.find(json_object):
            path = match.path
            if isinstance(path, Index):
                del(match.context.value[match.path.index])
            elif isinstance(path, Fields):
                del(match.context.value[match.path.fields[0]])
        return json_object

    @keyword('Convert JSON To String')
    def convert_json_to_string(self, json_object):
        """Convert JSON object to string

        Arguments:
            - json_object: json as a dictionary object.

        Return new json_string

        Examples:
        | ${json_str}=  |  Convert JSON To String | ${json_obj} |
        """
        return json.dumps(json_object)

    @keyword('Convert String to JSON')
    def convert_string_to_json(self, json_string):
        """Convert String to JSON object

        Arguments:
            - json_string: JSON string

        Return new json_object

        Examples:
        | ${json_object}=  |  Convert String to JSON | ${json_string} |
        """
        return json.loads(json_string)
