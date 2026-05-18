from datetime import date
from simple_salesforce import Salesforce
import apiCommon as sfAttributes
from decimal import Decimal

def CreateContactInSalesforce(contactData):
    try:
        sf = Salesforce(session_id=sfAttributes.sessionID, instance=sfAttributes.apiInstance, version=sfAttributes.apiVersion)
        contact = sf.Contact.create(contactData)
        return contact['id']
    except Exception as e:
        return e

def addClassRel(contactId, ClassName):
    sf = Salesforce(session_id=sfAttributes.sessionID, instance=sfAttributes.apiInstance, version=sfAttributes.apiVersion)
    classId = sf.query("Select ID from cve_Class__c where name = '" + ClassName +"' order by createddate DESC limit 1")
    classId = classId['records'][0]['Id']
    classRelRecord = sf.cve_ClassRelationship__C.create({'cve_class__c': classId, 'cve_contact__c': contactId})
    return classRelRecord['id']

def addPolicyRel(contactId, policyName):
    sf = Salesforce(session_id=sfAttributes.sessionID, instance=sfAttributes.apiInstance, version=sfAttributes.apiVersion)
    policyId = sf.query("Select ID from cve_Class__c where name = '" + policyName +"' order by createddate DESC limit 1")
    policyId = policyId['records'][0]['Id']
    policyRelRecord = sf.cve_ClassRelationship__C.create({'cve_class__c': policyId, 'cve_contact__c': contactId})
    return policyRelRecord['id']

def updateContactField(id, fieldValuePairs):
    try:
        sf = Salesforce(session_id=sfAttributes.sessionID, instance=sfAttributes.apiInstance, version=sfAttributes.apiVersion)
        result = sf.Contact.update(id, fieldValuePairs)
        if result == 204:
            return 'Contact Updated'
        else:
            return 'Contact Update Failed'
    except Exception as e:
        return e

def getContactId(contactName):
    sf = Salesforce(session_id=sfAttributes.sessionID, instance=sfAttributes.apiInstance, version=sfAttributes.apiVersion)
    contactId = sf.query("Select ID from Contact where name = '" + contactName +"' order by createddate DESC limit 1")
    return contactId['records'][0]['Id']

def addcontIdTolist(contactId):
    try:
        global contactList
        contactList.append(contactId)
        return contactList
    except Exception as e:
        return e

def navigateToPortalBasedOnRole(contactName, profile, account, portalName, role):
    sf = Salesforce(session_id=sfAttributes.sessionID, instance=sfAttributes.apiInstance, version=sfAttributes.apiVersion)
    contactId = getContactId(contactName)
    if profile == 'PLADSUSER' and portalName == 'Claims Portal':
        #groupName = account + ' ' + portalName + ' ' + role
        result = sf.query("Select ID from Contact where name = '" + contactName +"' order by createddate DESC limit 1")
        if result in ['Hierarchy Group not created','Hierarchy Group not exist']:
            return result
        else:
            return 'True'
    else:
        return 'Portal navigation not required for this profile'