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
* @date 2013
* @description Tests for the ADDR_Validator class. 
*/
@isTest
public with sharing class ADDR_Validator_TEST {

    // if you only want to run one test in this class, fill in its name here.
    // if you want to run all tests, then use '*'
    private static string strTestOnly = '*';
    
    public static void createDefaultSettings() {
        // use the household account model
        CAO_Constants.getContactsSettingsForTests(
            new npe01__Contacts_and_Orgs_Settings__c (npe01__Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR));

        // create the basic api settings
        Address_Verification_Settings__c settings = Address_Verification_Settings__c.getOrgDefaults();
        settings.Auth_ID__c = 'hey';
        settings.Auth_Token__c = 'there';
        settings.Address_Verification_Endpoint__c = 'https://api.smartystreets.com/street-address';
        settings.Zipcode_Verification_Endpoint__c = 'https://api.smartystreets.com/zipcode';
        settings.Class__c = 'ADDR_SmartyStreets_Validator';
        settings.Enable_Automatic_Verification__c = true;
        settings.Reject_Ambiguous_Addresses__c = true;
        insert settings;
    }
    
    static testMethod void testContactAddress() {
    	if (strTestOnly != '*' && strTestOnly != 'testContactAddress') return;
    	
        createDefaultSettings();
        Test.setMock(HttpCalloutMock.class, new ADDR_MockHttpRespGenerator_TEST());
              
        Contact contact = new contact(firstname='Test', lastname='Person'); 
        insert contact;
        
        //check household got created for contact
        contact = [select Account.Id from Contact where Id = :contact.Id];
        Id accountId = contact.Account.Id;
        System.assertNotEquals(null, accountId);
         
        // update contact with address to get the Address__c record created
        contact.MailingStreet = 'single-address-response';
        contact.MailingCity = 'Cupertino';
        contact.MailingState = 'ca';
        contact.MailingPostalCode = '95014';
        Test.StartTest();
        update contact;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.StopTest();
        
        Address__c[] av = [select MailingStreet__c, MailingState__c, MailingPostalCode__c, Verified__c 
                from Address__c where Household_Account__c = :accountId];
        System.assertEquals(1, av.size());
        System.assertEquals('1 Infinite Loop', av[0].MailingStreet__c);
        System.assertEquals('CA', av[0].MailingState__c);
        System.assertEquals('95014-2083', av[0].MailingPostalCode__c);
        System.assertEquals(true, av[0].Verified__c);
        
        contact = [select id, MailingStreet, MailingCity, MailingPostalCode, MailingState
                         from contact where id = :contact.id];
        System.assertEquals('1 Infinite Loop', contact.MailingStreet);
        System.assertEquals('Cupertino', contact.MailingCity);
        System.assertEquals('95014-2083', contact.MailingPostalCode);
        System.assertEquals('CA', contact.MailingState);
    }

    static testMethod void testContactBadAddress() {
    	if (strTestOnly != '*' && strTestOnly != 'testContactBadAddress') return;
    	
        createDefaultSettings();
        Test.setMock(HttpCalloutMock.class, new ADDR_MockHttpRespGenerator_TEST());
              
        Contact contact = new contact(firstname='Test', lastname='Person'); 
        insert contact;
        
        //check household got created for contact
        contact = [select Account.Id from Contact where Id = :contact.Id];
        Id accountId = contact.Account.Id;
        System.assertNotEquals(null, accountId);
         
        // update contact with address to get the Address__c record created
        contact.MailingStreet = 'bogus-address-for-test';
        contact.MailingCity = 'chicago';
        contact.MailingState = 'il';
        contact.MailingPostalCode = '60606';
        Test.StartTest();
        update contact;
        Test.StopTest();

        Address__c[] av = [select Verified__c from Address__c where Household_Account__c = :contact.AccountId];       
        System.assertEquals(1, av.size());
        System.assertEquals(false, av[0].Verified__c);
    }
    
    static testMethod void testContactAmbiguousAddress() {
        if (strTestOnly != '*' && strTestOnly != 'testContactAmbiguousAddress') return;
        
        createDefaultSettings();
        Test.setMock(HttpCalloutMock.class, new ADDR_MockHttpRespGenerator_TEST());
              
        Contact contact = new contact(firstname='Test', lastname='Person'); 
        insert contact;
        
        //check household got created for contact
        contact = [select Account.Id from Contact where Id = :contact.Id];
        Id accountId = contact.Account.Id;
        System.assertNotEquals(null, accountId);
         
        // update contact with address to get the Address__c record created
        contact.MailingStreet = 'ambiguous-address-for-test';
        contact.MailingCity = 'chicago';
        contact.MailingState = 'il';
        contact.MailingPostalCode = '60606';
        Test.StartTest();
        update contact;
        Test.StopTest();

        Address__c[] av = [select Verified__c, Ambiguous__c from Address__c 
                            where Household_Account__c = :accountId];       
        System.assertEquals(1, av.size());
        System.assertEquals(false, av[0].Verified__c);
        System.assertEquals(true, av[0].Ambiguous__c);
    }

    static testMethod void testContactZipOnly() {
    	if (strTestOnly != '*' && strTestOnly != 'testContactZipOnly') return;
    	
    	createDefaultSettings();
        Test.setMock(HttpCalloutMock.class, new ADDR_MockHttpRespGenerator_TEST());
        
        Contact contact = new contact(firstname='Test', lastname='Person'); 
        insert contact;
        
        //check household got created for contact
        contact = [select Account.Id from Contact where Id = :contact.Id];
        Id accountId = contact.Account.Id;
        System.assertNotEquals(null, accountId);
         
        // update contact with postal code to get the Address__c record created
        contact.MailingPostalCode = '60606';
        Test.StartTest();
        update contact;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.StopTest();
                        
        Address__c[] av = [select MailingCity__c, MailingPostalCode__c, Verified__c 
                            from Address__c where Household_Account__c = :accountId];      
        System.assertEquals('98236', av[0].MailingPostalCode__c);
        System.assertEquals('Clinton', av[0].MailingCity__c);
        
        contact[] c1 = [select id, MailingStreet, MailingCity, MailingPostalCode from contact where id = :contact.id];
        System.assertEquals(null, c1[0].MailingStreet);
        System.assertEquals('Clinton', c1[0].MailingCity);
        System.assertEquals('98236', c1[0].MailingPostalCode); 
    }

    static testMethod void testContactCityAndStateOnly() {
    	if (strTestOnly != '*' && strTestOnly != 'testContactCityAndStateOnly') return;
    	
        createDefaultSettings();
        Test.setMock(HttpCalloutMock.class, new ADDR_MockHttpRespGenerator_TEST());
        
        Contact contact = new contact(firstname='Test', lastname='Person'); 
        insert contact;
        
        //check household got created for contact
        contact = [select Account.Id from Contact where Id = :contact.Id];
        Id accountId = contact.Account.Id;
        System.assertNotEquals(null, accountId);
         
        // update contact with to get the Address__c record created
        contact.MailingCity = 'Clinton';
        contact.MailingState = 'WA';
        Test.StartTest();
        update contact;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.StopTest();

        Address__c[] av = [select id, MailingCity__c, MailingPostalCode__c from Address__c 
                            where Household_Account__c = :contact.AccountId];        
        System.assertEquals('98236', av[0].MailingPostalCode__c);
        System.assertEquals('Clinton', av[0].MailingCity__c);
        
        contact[] c1 = [select id, MailingStreet, MailingCity, MailingPostalCode from contact where id = :contact.id];
        System.assertEquals(null, c1[0].MailingStreet);
        System.assertEquals('Clinton', c1[0].MailingCity);
        System.assertEquals('98236', c1[0].MailingPostalCode);
    }

    static testMethod void testBatch() {
    	if (strTestOnly != '*' && strTestOnly != 'testBatch') return;
    	
        createDefaultSettings();
        //Turn off automatic verification to avoid getting the address verified as we create the contact. 
        //We want the batch process to do it.
        Address_Verification_Settings__c settings = Address_Verification_Settings__c.getOrgDefaults();
        settings.Enable_Automatic_Verification__c = false;
        update settings;
        
        Test.setMock(HttpCalloutMock.class, new ADDR_MockHttpRespGenerator_TEST());
        
         Contact contact = new contact(firstname='Test', lastname='Person', MailingStreet = 'single-address-response', 
                                    MailingCity = 'Cupertino', MailingState = 'ca', MailingPostalCode = '95014'); 
        insert contact;
        
        //check household got created for contact
        contact = [select Account.Id from Contact where Id = :contact.Id];
        Id accountId = contact.Account.Id;
        System.assertNotEquals(null, accountId);
        
        Address__c[] av = [select MailingStreet__c, MailingState__c, MailingPostalCode__c, Verified__c 
                from Address__c where Household_Account__c = :accountId];
        System.assertEquals(1, av.size());
        System.assertEquals('single-address-response', av[0].MailingStreet__c);
        System.assertEquals('ca', av[0].MailingState__c);
        System.assertEquals('95014', av[0].MailingPostalCode__c);
        System.assertEquals(false, av[0].Verified__c);
        
        Test.StartTest();
        ADDR_VAlidator_Batch b = new ADDR_VAlidator_Batch(true);
        Database.executeBatch(b);
        Test.StopTest();
        
        av = [select MailingStreet__c, MailingState__c, MailingPostalCode__c, Verified__c 
                from Address__c where Household_Account__c = :accountId];
        System.assertEquals(1, av.size());
        System.assertEquals('1 Infinite Loop', av[0].MailingStreet__c);
        System.assertEquals('CA', av[0].MailingState__c);
        System.assertEquals('95014-2083', av[0].MailingPostalCode__c);
        System.assertEquals(true, av[0].Verified__c);
    }

    static testMethod void testController() {
    	if (strTestOnly != '*' && strTestOnly != 'testController') return;
    	
        STG_PanelADDRVerification_CTRL sc = new STG_PanelADDRVerification_CTRL();
        
        sc.settings.HTML_Key__c = 'skldjflsdkfj';
        sc.settings.Class__c = 'ADDR_SmartyStreets_Validator';
        sc.saveSettings();
        System.assertEquals('Saved.\n', sc.apiSettingsSaveMessage);

        sc.apiTestEntry = '98236';
        sc.testApi();
        system.assertNotEquals(null, sc.apiTestResult);

        Test.startTest();
        sc.bulkVerify();
        Test.stopTest();
        
        //The batch has its own test. This basically tests that no exception was thrown
        //since it got to set the status variable.
        System.assertEquals(true, sc.nowVerifying);
    }
    
    static testMethod void testControllerMissingSetting() {
        if (strTestOnly != '*' && strTestOnly != 'testControllerMissingSetting') return;
        
        STG_PanelADDRVerification_CTRL sc = new STG_PanelADDRVerification_CTRL();
        
        sc.settings.HTML_Key__c = 'skldjflsdkfj';
        
        Test.startTest();
        sc.saveSettings();
        Test.stopTest();
        
        System.assert(sc.apiSettingsErrorMessage.contains('Required fields are missing'));
    }
}