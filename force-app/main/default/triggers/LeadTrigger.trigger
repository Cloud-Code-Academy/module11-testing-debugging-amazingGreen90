/*
 * The `LeadTrigger` is designed to automate certain processes around the Lead object in Salesforce. 
 * This trigger invokes various methods from the `LeadTriggerHandler` class based on different trigger 
 * events like insert and update.
 * 
 * Here's a brief rundown of the operations:
 * 1. BEFORE INSERT and BEFORE UPDATE:
 *    - Normalize the Lead's title for consistency using `handleTitleNormalization` method.
 *    - Score leads based on certain criteria using the `handleAutoLeadScoring` method.
 * 2. AFTER INSERT and AFTER UPDATE:
 *    - Check if the Lead can be auto-converted using the `handleLeadAutoConvert` method.
 *
 * Students should note:
 * - This trigger contains intentional errors that need to be identified and corrected.
 * - It's essential to test the trigger thoroughly after making any changes to ensure its correct functionality.
 * - Debugging skills will be tested, so students should look out for discrepancies between the expected and actual behavior.
 */
trigger LeadTrigger on Lead (before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
		//BEFORE INSERT
        if (Trigger.isInsert) {
            LeadTriggerHandler.handleTitleNormalization(Trigger.new);//covered in test class
            LeadTriggerHandler.handleAutoLeadScoring(Trigger.new);//coverted in test class
        }
		//BEFORE UPDATE
        else if (Trigger.isUpdate) {
            LeadTriggerHandler.handleTitleNormalization(Trigger.new);//covered in test class
            LeadTriggerHandler.handleAutoLeadScoring(Trigger.new);//covered in test class
        }
    }
    else if (Trigger.isAfter) {
		//AFTER INSERT
        if (Trigger.isInsert) {
            LeadTriggerHandler.handleLeadAutoConvert(Trigger.new);//covered in test class
        }
		//AFTER UPDATE
        else if (Trigger.isUpdate) {
            LeadTriggerHandler.handleLeadAutoConvert(Trigger.new);
        }
    }
}