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
* @date 2014
* @description Class that generates mock HTTP responses for address validation/
* normalization tests.
*/
@isTest
public with sharing class ADDR_MockHttpRespGenerator_TEST implements HttpCalloutMock {

    String singleAddressResponse = 
        '['+
        '   {'+
        '       \"input_index\": 0,'+
        '       \"candidate_index\": 0,'+
        '       \"delivery_line_1\": \"1 Infinite Loop\",'+
        '       \"last_line\": \"Cupertino CA 95014-2083\",'+
        '       \"delivery_point_barcode\": \"950142083017\",'+
        '       \"components\": {'+
        '           \"primary_number\": \"1\",'+
        '           \"street_name\": \"Infinite\",'+
        '           \"street_suffix\": \"Loop\",'+
        '           \"city_name\": \"Cupertino\",'+
        '           \"state_abbreviation\": \"CA\",'+
        '           \"zipcode\": \"95014\",'+
        '           \"plus4_code\": \"2083\",'+
        '           \"delivery_point\": \"01\",'+
        '           \"delivery_point_check_digit\": \"7\"'+
        '       },'+
        '       \"metadata\": {'+
        '           \"record_type\": \"S\",'+
        '           \"county_fips\": \"06085\",'+
        '           \"county_name\": \"Santa Clara\",'+
        '           \"carrier_route\": \"C067\",'+
        '           \"congressional_district\": \"15\",'+
        '           \"rdi\": \"Commercial\",'+
        '           \"latitude\": 37.33118,'+
        '           \"longitude\": -122.03062,'+
        '           \"precision\": \"Zip9\"'+
        '       },'+
        '       \"analysis\": {'+
        '           \"dpv_match_code\": \"Y\",'+
        '           \"dpv_footnotes\": \"AABB\",'+
        '           \"dpv_cmra\": \"N\",'+
        '           \"dpv_vacant\": \"N\",'+
        '           \"active\": \"Y\"'+
        '       }'+
        '   }' + 
        ']';
        
    String multipleAddressResponse = 
        '['+
        '   {'+
        '       \"input_index\": 0,'+
        '       \"candidate_index\": 0,'+
        '       \"delivery_line_1\": \"1 Infinite Loop\",'+
        '       \"last_line\": \"Cupertino CA 95014-2083\",'+
        '       \"delivery_point_barcode\": \"950142083017\",'+
        '       \"components\": {'+
        '           \"primary_number\": \"1\",'+
        '           \"street_name\": \"Infinite\",'+
        '           \"street_suffix\": \"Loop\",'+
        '           \"city_name\": \"Cupertino\",'+
        '           \"state_abbreviation\": \"CA\",'+
        '           \"zipcode\": \"95014\",'+
        '           \"plus4_code\": \"2083\",'+
        '           \"delivery_point\": \"01\",'+
        '           \"delivery_point_check_digit\": \"7\"'+
        '       },'+
        '       \"metadata\": {'+
        '           \"record_type\": \"S\",'+
        '           \"county_fips\": \"06085\",'+
        '           \"county_name\": \"Santa Clara\",'+
        '           \"carrier_route\": \"C067\",'+
        '           \"congressional_district\": \"15\",'+
        '           \"rdi\": \"Commercial\",'+
        '           \"latitude\": 37.33118,'+
        '           \"longitude\": -122.03062,'+
        '           \"precision\": \"Zip9\"'+
        '       },'+
        '       \"analysis\": {'+
        '           \"dpv_match_code\": \"Y\",'+
        '           \"dpv_footnotes\": \"AABB\",'+
        '           \"dpv_cmra\": \"N\",'+
        '           \"dpv_vacant\": \"N\",'+
        '           \"active\": \"Y\"'+
        '       }'+
        '   }'
        + 
        '   ,{'+
        '       \"input_index\": 1,'+
        '       \"candidate_index\": 0,'+
        '       \"delivery_line_1\": \"2 Infinite Loop\",'+
        '       \"last_line\": \"Cupertino CA 95014-2083\",'+
        '       \"delivery_point_barcode\": \"950142083017\",'+
        '       \"components\": {'+
        '           \"primary_number\": \"2\",'+
        '           \"street_name\": \"Infinite\",'+
        '           \"street_suffix\": \"Loop\",'+
        '           \"city_name\": \"Cupertino\",'+
        '           \"state_abbreviation\": \"CA\",'+
        '           \"zipcode\": \"95014\",'+
        '           \"plus4_code\": \"2083\",'+
        '           \"delivery_point\": \"01\",'+
        '           \"delivery_point_check_digit\": \"7\"'+
        '       },'+
        '       \"metadata\": {'+
        '           \"record_type\": \"S\",'+
        '           \"county_fips\": \"06085\",'+
        '           \"county_name\": \"Santa Clara\",'+
        '           \"carrier_route\": \"C067\",'+
        '           \"congressional_district\": \"15\",'+
        '           \"rdi\": \"Commercial\",'+
        '           \"latitude\": 37.33118,'+
        '           \"longitude\": -122.03062,'+
        '           \"precision\": \"Zip9\"'+
        '       },'+
        '       \"analysis\": {'+
        '           \"dpv_match_code\": \"Y\",'+
        '           \"dpv_footnotes\": \"AABB\",'+
        '           \"dpv_cmra\": \"N\",'+
        '           \"dpv_vacant\": \"N\",'+
        '           \"active\": \"Y\"'+
        '       }'+
        '   }'+ 
        ']';

    String zipResponse = 
        '[{\"city_states\":[{\"city\":\"Clinton\",\"state_abbreviation\":\"WA\",\"state\":\"Washington\"},{\"city\":\"Maxwelton\",\"state_abbreviation\":\"WA\",\"state\":\"Washington\"},{\"city\":\"POSSESSION\",\"state_abbreviation\":\"WA\",\"state\":\"Washington\"}],\"zipcodes\":[{\"zipcode\":\"98236\",\"latitude\":47.957763,\"longitude\":-122.401269}]}]';

    String ambiguousResponse = 
        '[{"input_index":0,"candidate_index":0,"delivery_line_1":"1 N Rosedale St","last_line":"Baltimore MD 21229-3737","delivery_point_barcode":"212293737013","components":{"primary_number":"1","street_predirection":"N","street_name":"Rosedale","street_suffix":"St","city_name":"Baltimore","state_abbreviation":"MD","zipcode":"21229","plus4_code":"3737","delivery_point":"01","delivery_point_check_digit":"3"},"metadata":{"record_type":"S","county_fips":"24510","county_name":"Baltimore City","carrier_route":"C047","congressional_district":"07","rdi":"Residential","elot_sequence":"0059","elot_sort":"A","latitude":39.28661,"longitude":-76.66901,"precision":"Zip9"},"analysis":{"dpv_match_code":"Y","dpv_footnotes":"AABB","dpv_cmra":"N","dpv_vacant":"N","active":"Y"}},' +
         '{"input_index":0,"candidate_index":1,"delivery_line_1":"1 S Rosedale St","last_line":"Baltimore MD 21229-3739","delivery_point_barcode":"212293739011","components":{"primary_number":"1","street_predirection":"S","street_name":"Rosedale","street_suffix":"St","city_name":"Baltimore","state_abbreviation":"MD","zipcode":"21229","plus4_code":"3739","delivery_point":"01","delivery_point_check_digit":"1"},"metadata":{"record_type":"S","county_fips":"24510","county_name":"Baltimore City","carrier_route":"C047","congressional_district":"07","rdi":"Residential","elot_sequence":"0064","elot_sort":"A","latitude":39.28543,"longitude":-76.66896,"precision":"Zip9"},"analysis":{"dpv_match_code":"Y","dpv_footnotes":"AABB","dpv_cmra":"N","dpv_vacant":"N","active":"Y"}}]';

    String addrNotFoundResponse = '[]';

    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {

         // Create a believable response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if (req.getEndpoint().contains('bad-authentication-for-test')) {
            res.setStatusCode(401);
            res.setStatus('Not authenticated.');
        } else {
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody(
                (req.getBody().contains('bogus-address-for-test')) ? addrNotFoundResponse :
                (req.getBody().contains('ambiguous-address-for-test')) ? ambiguousResponse :
                (req.getBody().contains('single-address-response')) ? singleAddressResponse : 
                (req.getEndpoint().contains('street-address')) ? multipleAddressResponse : zipResponse);
        }
        return res;
    }
}