import calendar
from robot.api.deco import keyword
from datetime import datetime, timedelta
from calendar import monthrange

__author__ = 'Loan Nguyen Thi'
__enamil__='loan.nt@citigo.com.vn'

class TimeRangeHandle():
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_EXIT_ON_FAILURE = True

    # Tra ve start - end date cua tuan tuong ung voi thoi gian truyen vao
    @keyword('KV Get This Week Range')
    def kv_get_this_week_range(self,str_date):
        #  convert string to datetime
        input_date = datetime.strptime(str_date, '%Y/%m/%d')
        start = input_date - timedelta(days=input_date.weekday())
        end = start + timedelta(days=7)
        return start,end

    # Tra ve start - end date cua thang tuong ung voi thoi gian truyen vao
    @keyword('KV Get This Month Range')
    def kv_get_this_month_range(self,str_date):
        #  convert string to datetime
        input_date  = datetime.strptime(str_date, '%Y/%m/%d')
        input_month = input_date.month
        input_year  = input_date.year
        startDate = input_date.replace(day=1)
        length   = calendar.monthrange(input_year,input_month)
        endDate = startDate + timedelta(days=length[1])
        return startDate, endDate
