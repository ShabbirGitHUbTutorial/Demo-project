public with sharing class SPEN_PremiseCommunicationFlowHandler {
    @AuraEnabled(cacheable=false)
    public static String getListViewFilterQuery(String filterId)
    {
        String query;
        HttpRequest req = new HttpRequest();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String endPoinURL = 'callout:GetSessionID_NC'+'/services/data/v56.0/sobjects/SPEN_Premise__c'+ '/listviews/'+filterId+'/describe';
        
        //system.debug('endPoinURL >>' +endPoinURL);
        req.setEndpoint(endPoinURL);
        req.setMethod('GET');
        string autho = 'Bearer {!$GetSessionID_NC.OAuthToken}';
        //system.debug('autho >>'+autho);
        req.setHeader('Authorization', autho);
        Http http = new Http();
        HttpResponse response = http.send(req);
        if( response.getStatusCode() == 200 ) {
            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            system.debug('tokenResponse >>' + tokenResponse);
            query = (String) tokenResponse.get('query');
            //System.debug('query-->'+query);
        }
        return query;
    }
    @AuraEnabled(cacheable=true)
    public static ListView getListViewDetails(String filterId)
    {
        ListView lstView = [SELECT Id, Name, DeveloperName, SobjectType
                            FROM ListView 
                            WHERE id =: filterId];
        return lstView;
    }
}