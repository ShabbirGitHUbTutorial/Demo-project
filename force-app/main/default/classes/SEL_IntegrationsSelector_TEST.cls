/*-----------------------------------------------------------------------------
DESCRIPTION :   Test class of the SEL_IntegrationsSelector selector class.
AUTHOR      :   Macjules Sevilla
LIBRARY     :   Salesforce Enterprise Library (SEL) - Integration Frameworks

Time (MS)       Method
73              selectByDeveloperName
-----------------------------------------------------------------------------*/
@IsTest
public without sharing class SEL_IntegrationsSelector_TEST 
{
    @IsTest
    private static void selectByDeveloperName() 
    {
        Test.startTest();

        SEL_IntegrationsSelector selector = new SEL_IntegrationsSelector();

        // SCENARIO 1 
        // Pass blank parameter
        System.assert(selector.selectByDeveloperName(null).get('SEL_IsActive__c') == null, 'Passing a null or blank parameter must return an empty record');
        
        // SCENARIO 2 
        // Pass a non-existent developer name
        selector.bypassParameterCheck = true;
        System.assert(selector.selectByDeveloperName('test').get('SEL_IsActive__c') == null, 'Passing a non-existent parameter must return an empty record');

        Test.stopTest();
    }
}