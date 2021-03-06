/*
    Copyright (c) 2014, Salesforce.com Foundation
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
 
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.com Foundation
* @date 2011 (1.x)
* @description Constants and helper methods used for common settings in npe01: account model, default contact role, etc. 
*/
public with sharing class CAO_Constants {
    //One-to-One value for system processor field
    public static final String ONE_TO_ONE_PROCESSOR = 'One-to-One';
    //One-to-One org type value
    public static final String ONE_TO_ONE_ORGANIZATION_TYPE = 'One-to-One Individual';

    //Bucket value for system processor field
    public static final String BUCKET_PROCESSOR = 'Individual';
    //Buck org type value
    public static final String BUCKET_ORGANIZATION_TYPE = 'Bucket Individual';
    //Bucket Account name
    public static  String BUCKET_ACCOUNT_NAME = 'Individual';

    //HH_Account value for system processor field
    public static final String HH_ACCOUNT_PROCESSOR = 'Household Account';
    //HH_Account type value
    public static final String HH_ACCOUNT_TYPE = 'Household Account';

    public static npe01__Contacts_And_Orgs_Settings__c ContactsSettings;

    public static  string CONTACT_FIRSTNAME_FOR_TESTS = 'test';
    public static  string CONTACT_LASTNAME_FOR_TESTS = 'Contact_forTests';

    public static  string CONTACT_EMAIL_FOR_TESTS = 'junk@test.net';
    public static  string CONTACT_PREFERRED_EMAIL_FOR_TESTS = 'Work';
    public static  string CONTACT_PHONE_FOR_TESTS = '206-777-8888';
    public static  string CONTACT_PREFERRED_PHONE_FOR_TESTS = 'Work';
    
    public static  string INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS = 'IndividualAccountNameForTests';

    //get the settings. handles the case where the managed value doesn't exist yet
    public static npe01__Contacts_and_Orgs_Settings__c getContactsSettings() {
        ContactsSettings = UTIL_CustomSettingsFacade.getContactsSettings(ContactsSettings, HH_ACCOUNT_PROCESSOR);
        return ContactsSettings;
    }

    public static npe01__Contacts_and_Orgs_Settings__c getContactsSettingsForTests(npe01__Contacts_and_Orgs_Settings__c mySettings) {

        //clear out whatever settings exist
        delete [select id from npe01__Contacts_and_Orgs_Settings__c];

        //create our own based on what's passed in from the test 
        ContactsSettings = new npe01__Contacts_and_Orgs_Settings__c (
            npe01__One_to_One_RecordTypeID__c = mySettings.npe01__One_to_One_RecordTypeID__c, 
            npe01__HH_Account_RecordTypeID__c = mySettings.npe01__HH_Account_RecordTypeID__c,
            npe01__Account_Processor__c = mySettings.npe01__Account_Processor__c,
            npe01__Enable_Opportunity_Contact_Role_Trigger__c = mySettings.npe01__Enable_Opportunity_Contact_Role_Trigger__c,
            npe01__Opportunity_Contact_Role_Default_role__c = mySettings.npe01__Opportunity_Contact_Role_Default_role__c,
            npe01__Disable_Account_Model_Trigger__c = mySettings.npe01__Disable_Account_Model_Trigger__c,
            npe01__Payments_Enabled__c = mySettings.npe01__Payments_Enabled__c
            );
        insert ContactsSettings;
        return ContactsSettings;
    }

    public static boolean isOneToOne() {
        //if no settings exist, create defaults
        if (CAO_Constants.getContactsSettings().npe01__Account_Processor__c==ONE_TO_ONE_PROCESSOR) {
            return true;
        } else {
            return false;
        }
    }

    public static boolean isBucketModel() {
        return (CAO_Constants.getContactsSettings().npe01__Account_Processor__c == BUCKET_PROCESSOR);
    }

    public static boolean isHHAccountModel() {
        return (CAO_Constants.getContactsSettings().npe01__Account_Processor__c == HH_ACCOUNT_PROCESSOR);
    }
    
    /// <name> triggerAction </name>
    /// <summary> contains possible actions for a trigger </summary>
    public enum triggerAction {beforeInsert, beforeUpdate, beforeDelete, afterInsert, afterUpdate, afterDelete, afterUndelete}

    public static Id IndividualAccountId;

    //variable for Account Name
    private static String IndividualAccountName = CAO_Constants.BUCKET_ACCOUNT_NAME;

    public static id getIndividualAccountId () {
    
        // look up the ID if we haven't already done it
        if ( IndividualAccountId == null ) {
            List<Account> acct = [select id,npe01__SYSTEMISINDIVIDUAL__c,npe01__SYSTEM_AccountType__c from account where Name =:IndividualAccountName LIMIT 1];
            if(acct.size()>0){
                if(acct[0].npe01__SYSTEMISINDIVIDUAL__c==false || acct[0].npe01__SYSTEM_AccountType__c<>CAO_Constants.BUCKET_ORGANIZATION_TYPE){
                    acct[0].npe01__SYSTEMISINDIVIDUAL__c = true;
                    acct[0].npe01__SYSTEM_AccountType__c = CAO_Constants.BUCKET_ORGANIZATION_TYPE;
                    update acct[0];
                }
                IndividualAccountId = acct[0].id;
            }
        }
        return IndividualAccountId;
    }

    public static Id setIndividualAccountForTests(String accountName) {
        //create a fake Individual Account for tests

        Account individualAccountForTests = new Account(
            Name=accountName,
            npe01__SYSTEMISINDIVIDUAL__c = true,
            npe01__SYSTEM_AccountType__c = CAO_Constants.BUCKET_ORGANIZATION_TYPE
        );
        
        insert individualAccountForTests;

        CAO_Constants.BUCKET_ACCOUNT_NAME = accountName;
        IndividualAccountName = accountName;

        return individualAccountForTests.id;
    }
}