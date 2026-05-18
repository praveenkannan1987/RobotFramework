from simple_salesforce import Salesforce,SalesforceLogin
from CryptoLibrary import CryptoUtility
import requests
import platform

sessionID = apiInstance = apiVersion = osName = 0

def getsfAttributes(username,pwd,token):
    global sessionID,apiInstance,apiVersion,osName
    sessionID,apiInstance = SalesforceLogin(username,pwd,token,domain='test')
    response = requests.get('https://{}/services/data'.format(apiInstance))
    data = response.json()
    apiVersion = max([data[i]['version'] for i in range(0,len(data))])
    osName = platform.system()
    crypto = CryptoUtility()
    encrypt_text = crypto.encrypt_text(sessionID)
    return encrypt_text,apiInstance,apiVersion,osName

def getHierarchyGroupId(groupname):
    try:
        sf = Salesforce(session_id=sessionID, instance=apiInstance, version=apiVersion)
        id = sf.query("Select Id FROM ZA_hierarchy_Group__C Where Name = '"+groupname+"'")
        if len(id['records']) > 0:
            return id['records'][0]['Id']
        else:
            return "Record not Found"
    except Exception as e:
        return e

def addContIdToList(ContactId):
    try:
        global contactList
        contactList.append(ContactId)
    except Exception as e:
        return e

def addtohrhierarchygroup(groupname, contactid, inputrole):
    try:
        sf = Salesforce(session_id=sessionID, instance=apiInstance, version=apiVersion)
        groupId = getHierarchyGroupId(groupname)
        hgId = getHierarchyGroupId(groupname)
        if hgId != 'Record not Found':
            result = sf.ZA_hierarchy_Group_Member__c.create({'ZA_hierarchy_Group__c': hgId,'Contact__c': contactid,'Role__c': inputrole})
            if result['success'] == True:
                return result['id']
            else:
                return 'Hierarchy Group not created'
        else:
            return 'Hierarchy Group not exist'
    except Exception as e:
        return e
    
def runcleanup(withLastName, LastName, createdByUser):
    try:
        sf = Salesforce(session_id=sessionID, instance=apiInstance, version=apiVersion)
        if withLastName == True:
            contacts = sf.query("Select ID from Contact where LastName = '" + LastName + "' and CreatedBy.Username = '" + createdByUser + "'")
        else:
            contacts = sf.query("Select ID from Contact where CreatedBy.Username = '" + createdByUser + "'")
        for contact in contacts['records']:
            sf.Contact.delete(contact['Id'])
        return 'True'
    except Exception as e:
        return e