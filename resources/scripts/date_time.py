from datetime import date,datetime,timedelta
from simple_salesforce import Salesforce
import apiCommon as sfAttributes
import holidays
from dateutil.relativedelta import relativedelta
import copy


def getnewdate(orgName, yy=0, mm=0, dd=0, mon=False, api=False, qde=False, checkNonwd=False, weekEnd=False, setjanfirst=False):
    new_date = date.today() + relativedelta(years=yy)
    # Replace the month and day if the flag is set
    if setjanfirst:
        new_date = new_date.replace(month=1, day=1)
        # Apply additional relative adjustments if not setting to Jan 1
    else:
        new_date += relativedelta(months=mm, days=dd)
    print(f"******* orgName {orgName} ***********")
    new_date = dayChecker(inputDate=new_date,checkWeekday=checkNonwd,checkWeekEnd=weekEnd,yy=yy,mm=mm,dd=dd)
    checkHoliday = checkOrgHoliday(orgName=orgName, inputDate=str(new_date))
    if (checkHoliday==True and setjanfirst==False):
        print("========Generating First Date: {new_date} Falls On Org Holiday, Generating New date========")
        while(checkHoliday==True):
            dd += 1
            new_date = date.today() + relativedelta(years=yy, months=mm, days=dd)
            new_date = dayChecker(inputDate=new_date,checkWeekday=checkNonwd,checkWeekEnd=weekEnd,yy=yy,mm=mm,dd=dd)
            checkHoliday = checkOrgHoliday(orgName=orgName, inputDate=str(new_date))
    if (mon==False and api==False):
        if sfAttributes.osName == 'Windows':
            return(new_date.strftime("%#m/%#d/%Y"))
        else:
            return(new_date.strftime("%-m/%-d/%Y"))
    elif (mon==False and api==True):
        return new_date
    elif (mon==True and qde==True):
        if sfAttributes.osName == 'Windows':
            return(new_date.strftime("%b %#d, %Y"))
        else:
            return(new_date.strftime("%b %-d, %Y"))
    else:
        if sfAttributes.osName == 'Windows':
            return(new_date.strftime("%B/%#d/%Y").upper())
        else:
            return(new_date.strftime("%B/%-d/%Y").upper())
    return new_date

def dayChecker(inputDate,checkWeekday=False,checkWeekEnd=False,yy=0,mm=0,dd=0):
    if (checkWeekday==True and inputDate.weekday() in [5,6]): 
        inputDate = date.today() + relativedelta(years=yy, months=mm, days=dd+2)
    elif (checkWeekEnd==True and inputDate.weekday() not in [5,6]):
        for i in range(7):
            inputDate = date.today() + relativedelta(years=yy, months=mm, days=dd+i)
            if inputDate.weekday() in [5,6]:
                break
    return inputDate


def checkOrgHoliday(orgName, inputDate):
    try:
        sf = Salesforce(session_id=sfAttributes.sessionID, instance=sfAttributes.apiInstance, version=sfAttributes.apiVersion)
        accRecld = sf.query("SELECT Ultimate_Parent FROM Account WHERE Name = '" + orgName + "'")
        ultimateParentId = accRecld['records'][0]['Ultimate_Parent']
        year = str(inputDate)[0:4]
        # Below line is referring to NGC Company holiday list
        ngCompHoliday = [f'{year}-12-26', f'{year}-12-28', f'{year}-12-29', f'{year}-12-31']
        if accRecld['totalSize'] >= 1 and ultimateParentId != None:
            holidays = sf.query("SELECT cvab__SaturdayHolidayObservedOn__c,cvab_SundayHolidayObservedOn__c,cvab_HolidayName__c FROM cvab AbsenceHoliday__c WHERE cvab_OrganizationId__c = '" + ultimateParentId + "'")
        elif ultimateParentId == None:
            holidays = sf.query("SELECT cvab__SaturdayHolidayObservedOn__c,cvab_SundayHolidayObservedOn__c,cvab_HolidayName__c FROM cvab AbsenceHoliday__c WHERE cvab_Organization__c = '" + orgName + "'")
        else:
            return f"Record Not Found For {orgName}"
        if holidays["totalSize"] > 0:
            orgHolidays = {holiday["cvab_HolidayName__c"]: {'saturday': int(holiday["cvab__SaturdayHolidayObservedOn__c"]), 'sunday': int(holiday["cvab_SundayHolidayObservedOn__c"])} for holiday in holidays["records"]}
            tempOrgHoliday = {}
            print("******* Org Holidays From Salesforce ***********")
            print (orgHolidays)
            holidaysDict = getHolidays(int(year))
            print("Holidays Library")
            print(holidaysDict)
            # Updating the holiday library to match with org holiday
            holidaysDict, tempOrgHoliday, orgHolidays = updateHolidays(orgHolidays,tempOrgHoliday,holidaysDict)
            # Below loop will update the values in orgHolidays dictionary
            for old,new in tempOrgHoliday.items():
                if old == 'Independence Day (Observed)':
                    orgHolidays[old] = copy.deepcopy(tempOrgHoliday[old])
                else:
                    orgHolidays[new] = orgHolidays.pop(old)
            dates = [str(holidaysDict[day]) for day in orgHolidays.keys() if day in holidaysDict.keys() ]
            print("Holiday Dates")
            print(f"****Holiday Dates: {dates} *****")
            if inputDate in dates or inputDate in ngCompHoliday:
                return True
            else:
                return False
        else:
            return f'Holiday Record Not Found For {orgName}'
    except IndexError:
        return f'Holiday Record Not Found For {orgName}'

def addorsubtractdaymonthyear(date,addorsubtract="add",dd=0,mm=0,yy=0):
    try:
        date_obj = datetime.strptime(date, '%m/%d/%Y')
        if(addorsubtract=="add"):
            newDate=date_obj+relativedelta(years=yy, months=mm, days=dd)
        else:
            newDate=date_obj-relativedelta(years=yy, months=mm, days=dd)
        return newDate.strftime('%m/%d/%Y')
    except Exception as e:
        return e

def getHolidays(year):
    # This method returns US holidays in dictionary format
    holidaysDict = {}
    for date, name in sorted(holidays.US(years=year).items()):
        holidaysDict[name] = date
    return holidaysDict

def org_holiday_check(holidaysDict,saturday,sunday):
    # This method takes a date as input and increment/decrement the date from holidays library if it falls on Saturday/Sunday[5/6] 
    try:
        # Getting day[Saturday is referred as 5 and Sunday is referred as 6] from input date
        getDay = datetime.strptime(str(holidaysDict), '%Y-%m-%d').weekday()
        if getDay == 5:
            holidaysDict = holidaysDict + timedelta(days=saturday)
        elif getDay == 6:
            holidaysDict = holidaysDict + timedelta(days=sunday)
        return holidaysDict
    except Exception as e:
        return e

def updateHolidays(orgHolidays, tempOrgHoliday,holidaysDict):
    # This method is to update the holiday list in both orgHolidays from salesforce and holidays library
    try:
        for day in orgHolidays.keys():
            if day == "New Year's Day":
                holidaysDict[day] = org_holiday_check(holidaysDict[day],orgHolidays[day][0][' saturday'],orgHolidays[day][0][' sunday'])
            elif day == "Thanksgiving Day":
                #Thanksgiving Day in Org holiday is Referred as Thanksgiving in holiday library, so here assigning a value to temp dict and
                tempOrgHoliday[day] = "Thanksgiving Day"
                holidaysDict['Thanksgiving Day'] = org_holiday_check(holidaysDict['Thanksgiving Day'],orgHolidays[day][0]['saturday'],orgHolidays[day][0]['sunday'])
            elif day in ["Veteran's Day Observed", "Veterans Day (Observed)"]:
                if 'Veterans Day (Observed)' in holidaysDict:
                    tempOrgHoliday[day]= 'Veterans Day (Observed)'
                    holidaysDict['Veterans Day (Observed)'] = org_holiday_check(holidaysDict['Veterans Day (Observed)'],orgHolidays[day][0]['saturday'],orgHolidays[day][0]['sunday'])
                else:
                    tempOrgHoliday[day]= 'Veterans Day'
            elif day == "New Year's Eve":
                # New Year's Eve Is not available in holidays hence adding it
                holidaysDict[day] = f"{datetime.now().year}-12-31"
            elif day == "Thanksgiving Day (Friday)":
                holidaysDict [day] = holidaysDict["Thanksgiving Day"] + timedelta(days=1)
            elif day == "Friday After Thanksgiving":
                holidaysDict [day] = holidaysDict["Thanksgiving Day"] + timedelta(days=3)
            elif day =="Christmas Eve":
                # Christmas Eve Is not available in holidays library so below is to add it
                holidaysDict [day] = holidaysDict["Christmas Day"] + timedelta(days=-1)
                # Below is to compare the orgHolidayDay setup to get nearest holiday if date generated in above step falls on weekend
                holidaysDict [day] = org_holiday_check(holidaysDict[day],orgHolidays[day][0]['saturday'],orgHolidays[day][0]['sunday'])
            elif day == "Day after Independence Day":
                holidaysDict[day] = holidaysDict["Independence Day"] + timedelta(days=1)
            elif day == "Independence Day":
                tempOrgHoliday["Independence Day (Observed)"]= orgHolidays["Independence Day"]
            elif day == "Martin Luther King, Jr. Day": 
                tempOrgHoliday[day]= 'Martin Luther King Jr. Day' 
            elif day == "President's Day":
                tempOrgHoliday[day]= "Washington's Birthday"
            elif day == "Recharge Day":
                holidaysDict[day] = holidaysDict["Thanksgiving Day"] + timedelta(days=-1)
                holidaysDict[day] = org_holiday_check(holidaysDict[day],orgHolidays[day][0]['saturday'],orgHolidays[day][0]['sunday'])
            elif day == "Company holiday":
                holidaysDict [day] = holidaysDict["Christmas Day"] + timedelta(days=2)
            elif day =="Juneteenth":
                juneTeenthDate = f"{datetime.now.year}-06-19"
                holidaysDict [day] = datetime.strptime(juneTeenthDate, "%Y-%m-%d").date()
                holidaysDict [day] = org_holiday_check(holidaysDict[day],orgHolidays[day][0]['saturday'],orgHolidays[day][0]['sunday'])
            elif day == "Victory Day (Rhode Island Only)":
                holidaysDict[day] = f"{datetime.now().year}-08-14"
            else:
                holidaysDict[day] = holidaysDict[day]
        return holidaysDict, tempOrgHoliday, orgHolidays
    except Exception as e:
        return e