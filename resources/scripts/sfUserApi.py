from datetime import date
from simple_salesforce import Salesforce
import apiCommon as sfAttributes


def handleReminders(username):
    try:
        sf = Salesforce(session_id=sfAttributes.sessionId, instance=sfAttributes.apiInstance, version=sfAttributes.apiVersion)
        reminderStatus = sf.query("Select Id, UserPreferencesActivityRemindersPopup, UserPreferencesEventRemindersCheckboxDefault, UserPreferencesTaskRemindersCheckboxDefault from User where username = '" + username + "'")
        if reminderStatus['totalSize'] == 1:
            activityReminder = reminderStatus['records'][0]['UserPreferencesActivityRemindersPopup']
            eventReminder = reminderStatus['records'][0]['UserPreferencesEventRemindersCheckboxDefault']
            taskReminder = reminderStatus['records'][0]['UserPreferencesTaskRemindersCheckboxDefault']
            userId = reminderStatus['records'][0]['Id']
            if ((activityReminder== False) and (eventReminder == False) and (taskReminder == False)):
                return ('Reminders already disabled')
            else:
                print('At least one reminder enabled')
                updateUserPref = sf.user.update(userId, {'UserPreferencesActivityRemindersPopup': False,
                                                        'UserPreferencesEventRemindersCheckboxDefault': False,
                                                        'UserPreferencesTaskRemindersCheckboxDefault': False})
                if updateUserPref == 204:
                    return 'Reminders Disabled'
                else:
                    return 'Error returned while disabling reminders'
        elif reminderStatus ['totalSize'] > 1:
            return ('Multiple users returned with that username, please ensure the username is unique')
        else:
            return ('No users found for the provided username')
    except Exception as e:
        return e