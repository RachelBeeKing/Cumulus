public with sharing class ADDR_Validator {

    // store the current update set so we don't update recursively
    public static set<id> nowUpdating = new set<id>();
    private static Address_Verification_Settings__c settings = Address_Verification_Settings__c.getInstance();

    /* FUTURE METHOD FOR TRIGGERS */
    @future(callout=true)
    public static void verifyRecords(set<id> recordIds) {
        System.debug('****Retrieving data records');
        //query for all the indicated verification records
        list<Address__c> avList = [ select Id, Name, CreatedDate, LastModifiedDate, 
            MailingStreet__c, MailingCity__c, MailingCountry__c, MailingState__C, MailingPostalCode__c, 
            Verified__c, API_Response__c
            //Geolocation__Latitude__s, Geolocation__Longitude__s, Congressional_District__c, Date_Verified__c,
            //County__c, Address_Field_Type__c, Carrier_Route__c 
            from Address__c where id in : recordIds];

        if (!avList.isEmpty()) {
            System.debug('****Verifying records');
            verifyRecords(avList);
        }
    }   

    // verify a list of custom object records - split them up into those we are
    // sending for address and those for zip only - max of 100 at a time for each
    public static void verifyRecords( list<Address__c> avList ) {
        list<Address__c> shortList = new list<Address__c>();
        list<Address__c> shortListZipOnly = new list<Address__c>();
        for (Address__c av : avList) {
            if ( av.MailingStreet__c == null && (av.MailingPostalCode__c != null || 
                (av.MailingCity__c != null && av.MailingState__c != null))) {

                // has no address, but can be verified and geocoded by the zipcode api
                shortListZipOnly.add( av );
                if (shortListZipOnly.size() == 100) {
                    verifyZipRecords100( shortListZipOnly );
                    shortListZipOnly = new list<Address__c>();
                }
            } else if ( av.MailingStreet__c != null ) {
                shortList.add( av );
                if (shortList.size() == 100) {
                    verifyRecords100( shortList );
                    shortList = new list<Address__c>();
                }
            }
        }
        if (!shortListZipOnly.isEmpty())
            verifyZipRecords100( shortListZipOnly );
        if (!shortList.isEmpty())
            verifyRecords100( shortList );
    }

    public static void verifyRecords100( list<Address__c> avList ) {
        integer recs = 0;
        list<ADDR_Validation_Gateway.Request> srList = new list<ADDR_Validation_Gateway.Request>();
        
        for (Address__c av : avList) {
            ADDR_Validation_Gateway.Request sr = new ADDR_Validation_Gateway.Request();
            sr.street = av.MailingStreet__c;
            // sr.street2 =     // SHOULD WE SPLIT STREET WHEN MULTILINE??
            sr.city = av.MailingCity__c;
            sr.state = av.MailingState__c;
            sr.zipcode = av.MailingPostalCode__c;

            // request a few candidates to determine if the address is unique
            sr.candidates = (settings.Reject_Ambiguous_Addresses__c) ? 3 : 1;   
            srList.add(sr);         
        }   

        try {
            ADDR_Validation_Gateway la = new ADDR_Validation_Gateway();
            list<ADDR_Validation_Gateway.Response> responses = la.verifyAddresses( srList );
            System.debug('****Gateway responses: ' + JSON.serializePretty(responses));
            if (responses != null) {
                list<ADDR_Validation_Gateway.Response> responseGroup;
                for (ADDR_Validation_Gateway.Response sr : responses) {         
                    Address__c av = avList[ sr.input_index ];              
                    if (sr.candidate_index == 0) {
                        responseGroup = new list<ADDR_Validation_Gateway.Response>{ sr };
                        System.debug('****Flagging address as verified. Address ID: ' + av.Id);
                        av.Verified__c = true;
                        av.MailingStreet__c = sr.delivery_line_1 + 
                            ((sr.delivery_line_2 != null && sr.delivery_line_2 != '') ? ('\n' + sr.delivery_line_2) : '');
                        av.MailingCity__c = sr.components.city_name;
                        av.MailingState__c = sr.components.state_abbreviation;
                        av.MailingPostalCode__c = (sr.components.zipcode == null) ? null : (sr.components.zipcode +
                            ((sr.components.plus4_code != null && sr.components.plus4_code != '') ? ('-' + sr.components.plus4_code) : ''));
                    } else {
                        // more than one candidate means should mark as ambiguous
                        System.debug('****Flagging address as NOT verified. Flagging it as ambiguous. Address ID: ' + av.Id);
                        av.Verified__c = false; 
                        av.Ambiguous__c = true;
                        responseGroup.add( sr );
                    }
                    av.API_Response__c = JSON.serializePretty( responseGroup );
                }
            }
            for (Address__c av : avList) {             
                if (av.API_Response__c == null) {   
                    av.API_Response__c = 'Address not found.';
                }
            }
        } catch (Exception ex) {
            for (Address__c av : avList) {
            	System.debug('****Flagging address as NOT verified Address ID: ' + av.Id 
            	               + ' - Exception in verifyRecords100: ' + ex.getMessage() 
            	               + '\n' + ex.getStackTraceString());
                av.Verified__c = false;
                av.API_Response__c = 'MESSAGE: ' + ex.getMessage() + '\nSTACKTRACE:\n' + ex.getStackTraceString();
            }
        }
        upsert avList;
    }

    public static void verifyZipRecords100( list<Address__c> avList ) {
        integer recs = 0;
        list<ADDR_Zipcode_Validation_Gateway.Request> zrList = new list<ADDR_Zipcode_Validation_Gateway.Request>();
        
        for (Address__c av : avList) {
            zrList.add( new ADDR_Zipcode_Validation_Gateway.Request(
                av.MailingCity__c,
                av.MailingState__c,
                av.MailingPostalCode__c
            ));
        }   

        try {
            ADDR_Zipcode_Validation_Gateway la = new ADDR_Zipcode_Validation_Gateway();
            list<ADDR_Zipcode_Validation_Gateway.Response> responses = la.verifyZips( zrList );
            System.debug('****Gateway responses: ' + JSON.serializePretty(responses));
            if (responses != null && !responses.isEmpty()) {
                if(responses.size() == avList.size()) {
	                for (integer i = 0; i < responses.size(); i++) {
	                    ADDR_Zipcode_Validation_Gateway.Response sr = responses[i];
	                    Address__c av = avList[i];             
	
	                    // look for an error
	                    if (sr.status != null && sr.reason != null) {
	                    	System.debug('****Error found. Reason: ' + sr.reason);
	                        av.API_Response__c = sr.reason;
	                    // if there is any response, serialize it and fill in location with first location value
	                    } else if (sr.zipcodes != null) {
	                    	System.debug('****No error. Populating raw response field.');
	                        //av.MailingCountry__c = av.Original_Country__c;
	                        av.API_Response__c = JSON.serializePretty( sr );
	                        
	                        // if there is at least one city/state, fill in city state
	                        if (sr.city_states != null && sr.city_states.size() > 0) {
	                        	System.debug('****Populating city and estate.');
	                            av.MailingCity__c = sr.city_states[0].city;
	                            av.MailingState__c = sr.city_states[0].state_abbreviation;
	                        }
	
	                        // if there is exactly one zip, fill in zip
	                        if (sr.zipcodes.size() == 1)
	                            av.MailingPostalCode__c = sr.zipcodes[0].zipcode;
	                    }
	                }
                } else {
                	System.debug('****Responses did not match number of verifications.');
                }
            }
            for (Address__c av : avList) {             
                if (av.API_Response__c == null) {   
                    av.API_Response__c = 'Zip not found.';
                }
            }
        } catch (Exception ex) {
            for (Address__c av : avList) {
            	System.debug('****Flagging address as NOT verified Address ID: ' + av.Id 
            	            + ' - Exception in verifyZipRecords100: ' + ex.getMessage()
                            + '\n' + ex.getStackTraceString());
                av.Verified__c = false;
                av.API_Response__c = 'MESSAGE: ' + ex.getMessage() + '\nSTACKTRACE:\n' + ex.getStackTraceString();
            }
        }
        upsert avList;
    }
}