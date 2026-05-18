from attrs import field
from simple_salesforce import Salesforce
import apiCommon as sfAttributes
from datetime import datetime


def get_account_field_values(accName, **fieldNames):
    try:
        sf = Salesforce(session_id=sfAttributes.sessionId, instance=sfAttributes.apiInstance, version=sfAttributes.apiVersion)
        # Input parameter **fieldNames is a dictionary so get the values and converting them to list
        fieldList = [value for key, value in fieldNames.items()]
        # In below Translate is used to remove the [] as we need to use the field name in SOQL.
        fieldName = str(fieldList).translate({ord(i): None for i in '[]'})
        fieldName = fieldName.replace(" ", "").replace("'", "")
        data = {'Error': 'None'}
        result = sf.query("SELECT " + fieldName + " FROM Account WHERE Name = '*" + accName + "*'")
        # Below is to handle input fieldnames as it may have r &_c if so parsing value out of it with below loop
        for field in fieldList:
            if '__r' in field and result['totalsize'] >= 1:
                fieldName = field.split(' .')
                if result['records'][0][fieldName[0]] is not None:
                    data[field] = result['records'][0][fieldName[0]][fieldName[1]]
                else:
                    data[field] = f"({accName}) record not exists"
            elif ('__c' in field and ',' in field) and result['totalsize']>1:
                fieldName = field.split('•')
                data[field] = result['records'][0][fieldName[1]]
            elif (('__r' not in field or '__c' not in field) and '.' in field) and result["totalsize"]>=1:
                fieldName = field.split('.')
                print (fieldName)
                data[field] = result['records'][0][fieldName[1]]
            elif ('__r' not in field and result['totalsize'] >= 1):
                data[field] = result['records'][0][field]
            else:
                data['Error'] = f"({accName}) record not exists"
        return data
    except Exception as e:
        return {'Error': str(e)}