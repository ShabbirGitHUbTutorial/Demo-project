/*-----------------------------------------------------------------------------
DESCRIPTION :   This class is written to create Test Data for test classes 
AUTHOR      :   Dhara Desai
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
OCT-12-2022     Dhara Desai         Initial version
Jun-20-2023     Shubhi V            Updated for PMD
Jun-27          Nitish              Added for deployment purpose 
-----------------------------------------------------------------------------*/
@IsTest
public with sharing class SPEN_TestDataFactory {
    private static User testgetUser;
    private static User testsetUser;
    private static Id profileid; 
/**********************************************************************************************
* @Author:      Dhara Desai
* @Date:        12/10/2022
* @Description: Method to specifically get Profile Id which is invoked from "settestUser" with parameter as "ProfileName".   
***********************************************************************************************/
public static Id getProfile(String profileName){
    id profileId;
    if(String.isNotBlank(profileName)){
        profileId=SPEN_TestdataSelector.getProfile(profileName).id;
    }
    return profileId;
}
//Persona: DevOpps
public static PermissionSetGroup getPSGroup(String psGroupName){
    PermissionSetGroup pg=new PermissionSetGroup();
    if(String.isNotBlank(psGroupName)){
        pg=SPEN_TestdataSelector.getPSGroup(psGroupName);
        //[SELECT Id,Status FROM PermissionSetGroup WHERE DeveloperName =:psGroupName LIMIT 1]; 
    }
    return pg;
    //return profileId;
}
/**********************************************************************************************
* @Author:      Dhara Desai
* @Date:        12/10/2022
* @Description: Method to specifically create Test User based on the Profile passed as parameter from test classes.   
***********************************************************************************************/
public static User settestUser(String profileName){
    User testUser=new  User();
    if(String.isNotBlank(profileName)){

        testUser= new User(FirstName= SPEN_TestDataFactoryConstants.FIRSTNAME,
                             LastName = SPEN_TestDataFactoryConstants.LASTNAME,
                             Email =SPEN_TestDataFactoryConstants.EMAIL,
                             Username = SPEN_TestDataFactoryConstants.LASTNAME+System.currentTimeMillis()+SPEN_TestDataFactoryConstants.DUMMYADD,
                             Alias = SPEN_TestDataFactoryConstants.ALIAS,
                             TimeZoneSidKey = SPEN_TestDataFactoryConstants.TIMEZONESIDKEY,
                             EmailEncodingKey = SPEN_TestDataFactoryConstants.EMAILENCODINGKEY,
                             LanguageLocaleKey = SPEN_TestDataFactoryConstants.LANGUAGELOCALEKEY,
                             profileId =  getProfile(profileName),
                             IsActive = SPEN_TestDataFactoryConstants.ISACTIVE,
                             LocaleSidKey = SPEN_TestDataFactoryConstants.LOCALESIDKEY);
    }
    return testUser;
}
/****************************************************************************************************************************
* @Author:      Dhara Desai
* @Date:        12/10/2022
* @Description: Method to specifically create Test Accounts based on parameter Integer recCount for bulk/single record from test classes.
*****************************************************************************************************************************/
public static List<Account> createAccounts(string accName,Integer recCount){
    List<Account> testAcc = new List<Account>();
    Account acc;
    Integer i=0;
    while(i< recCount){
        acc = new Account();
        acc.Name = accName+i;
        acc.Industry = 'Electronics';
        acc.Type = 'Others';
        testAcc.add(acc);
        i++;
    }
    return testAcc;
}
/****************************************************************************************************************************
* @Author:      Dhara Desai
* @Date:        12/10/2022
* @Description: Method to specifically create testContact based on parameter Integer recCount for bulk/single record from test classes.
*****************************************************************************************************************************/
public static Contact createContacts(Id accId,Integer recCount){
    Id contactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('SPEN_ContactConnectionsCRM').getRecordTypeId();
    Contact con;
    Integer i=0;
    while(i< recCount){
        con = new Contact();
        con.AccountId = accId;
        con.Salutation = 'Mr.';
        con.MobilePhone = '07123456789';
        con.FirstName = 'Aryan';
        con.LastName = 'Khanna';
        con.Phone = '01416140637';
        con.SPEN_CustomerID__c = 'SB__001';
        //con.SPEN_PreferredMethodofContact__c='Telephone';
        con.Suffix = 'AK';
        con.SPEN_RequireSynctoADQM__c=true;
        //testCon.add(con);
        con.recordtypeid = contactRecordType;
        i++;
    }
    return con;
}
/****************************************************************************************************************************
* @Author:      Debapriya Saha
* @Date:        14/10/2022
* @Description: Method to specifically create testIncident based on parameter Integer recCount for bulk/single record from test classes.
*****************************************************************************************************************************/
public static Incident createIncidents(Id cseId,Integer recCount){
    Incident incdnt;
    Integer i=0;
    while(i< recCount){
        incdnt = new Incident();
        incdnt.SEL_Case__c = cseId;
        incdnt.Subject = 'TestingIncident For CaseLifecycleStory';
        incdnt.SPEN_IncidentStatus__c = 'Awaiting';
        incdnt.SPEN_IncidentType__c='HV_S';
        incdnt.SPEN_IncidentID__c='INCTest00'+Integer.valueof((Math.random()*10))+Integer.valueOf(system.now().millisecond());
        i++;
    }
    return incdnt;
}
    
    /****************************************************************************************************************************
* @Author:      Smita Raikar
* @Date:        08/12/2022
* @Description: Method to specifically create list of testIncidents based on parameter Integer recCount for bulk/single record from test classes.
*****************************************************************************************************************************/
public static List<Incident> createListofIncidents(Integer recCount){
    List<Incident> incdntlist=new List<Incident>();
    Incident incdnt;
    SPEN_ConfigurableSettings__c getAffectedPremiseINCType = new SPEN_ConfigurableSettings__c(SPEN_Feature__c='Outbound Dialler',SPEN_Value__c='20',SPEN_Description__c='IC wants to confirm the impacted premise in powerOn and then GetAffectedPremise batch to be called so minutes to add a delay',Name='CreationBatchDelay');
    insert getAffectedPremiseINCType;
    Integer i=0;
    while(i<recCount){
        incdnt = new Incident();
        incdnt.Subject = 'Test HV Incident';
        incdnt.SPEN_IncidentType__c='HV_S';
        incdnt.SPEN_IncidentID__c='INCTest00'+(Integer.valueof((Math.random()*10)))+(Integer.valueOf(system.now().millisecond())*i);            
        incdntlist.add(incdnt);
        i++;
    }
    return incdntlist;
}
/****************************************************************************************************************************
* @Author:      Debapriya Saha
* @Date:        14/10/2022
* @Description: Method to specifically create testCases based on parameter Integer recCount for bulk/single record from test classes.
*****************************************************************************************************************************/
public static List<Case> createListOfCases(Integer recCount){
    Id recId;
    recId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unplanned - Fault').getRecordTypeId();
    List<Case> testCse = new List<Case>();
    Case cse;
    Integer i=0;
    while(i<recCount){
        cse = new Case();
        //cse.Name = accName+i;
        //cse.SPEN_Incident__c = IncdntID;
        cse.RecordTypeId = recId;
        cse.Status = 'Open';
        cse.Subject = 'TestCaseTestSubject'+i;
        testCse.add(cse);
        i++;
    }
    return testCse;
}
/****************************************************************************************************************************
* @Author:      Aakanksha
* @Date:        25/05/2023
* @Description: Method to specifically create referral testCases - both single or in bulk.
*****************************************************************************************************************************/
public static List<Case> createReferralCases(Integer recCount, Id premiseId, Id contactId){
    List<Case> testCse = new List<Case>();
    Case cse;
    Id recordTypeIdReferral = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_Referral).getRecordTypeId();
    Integer i=0;
    while(i<recCount){
        cse = new Case();
        cse.Status = CasesConstants.CREATED;
        cse.Subject = 'TestCaseTestSubject'+i;
        cse.SPEN_AddressPremise__c = premiseId;
        cse.ContactId = contactId;
        cse.recordTypeId = recordTypeIdReferral;
        testCse.add(cse);
        i++;
    }
    return testCse;
}
/****************************************************************************************************************************
* @Author:      Sumit Biswas
* @Date:        16/06/2023
* @Description: Method to specifically create referral testCases - both single or in bulk.
*****************************************************************************************************************************/
public static List<Case> createGSCSCases(Integer recCount, Id premiseId, Id contactId){
    List<Case> testCse = new List<Case>();
    
    Case cse;
    Id recordTypeIdGSCS = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_GS).getRecordTypeId();
    Integer i=0;
    while(i<recCount){
        cse = new Case();
        cse.Status = CasesConstants.CREATED;
        cse.Subject = 'TestCaseTestSubject'+i;
        cse.SPEN_AddressPremise__c = premiseId;
        cse.ContactId = contactId;
        cse.recordTypeId = recordTypeIdGSCS;
        testCse.add(cse);
        i++;
    }
    return testCse;
}
/****************************************************************************************************************************
* @Author:      Sumit Biswas
* @Date:        30/05/2023
* @Description: Method to specifically create Referral Service record on Cases_Test testCases - both single or in bulk.
*****************************************************************************************************************************/
    public static List<SPEN_ReferralService__c> createReferralServices(Integer recCount)
    {
        List<SPEN_ReferralService__c> refServiceList = new List<SPEN_ReferralService__c>();
        SPEN_ReferralService__c refServ;
        Integer i=0;
        while(i<recCount){
            refServ = new SPEN_ReferralService__c();
            refServ.SPEN_ServiceStatus__c = CasesConstants.STATUSCREATED;
            refServ.SPEN_Service__c = CasesConstants.POWERCUT;
            refServiceList.add(refServ);
            i++;
        }

       return refServiceList;
    }
    public static List<Account> createSpenAccount()
    {
        Id recordTypeIdPartner = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SPEN_Partner').getRecordTypeId();
        List<Account> accountList =new List<Account>(); 
            Account acc = new Account();
            acc.recordTypeId = recordTypeIdPartner;
            acc.SPEN_Status__c = 'Active';
            acc.Name = 'SPEN';
            acc.SPEN_Services__c = 'Help in a Power Cut';
            acc.SPEN_ServicedLocalAuthority__c = 'Liverpool';
            acc.SPEN_PartnerType__c = 'Referrals';
            accountList.add(acc);
            insert accountList;
        
        return accountList;
    }
/*-----------------------------------------------------------------------------------------
DESCRIPTION  :  Unit test method to create records to test Dynamic Wizard apex class SFBG_DynamicWizardService.
AUTHOR       :  Bhagyashree Mandlik
LIBRARY      :  Salesforce Enterprise Library 
VERSION      :  1.0
HISTORY      :
Date            Author                  Comment
OCT-18-2022     Bhagyashree Mandlik     Initial version
-----------------------------------------------------------------------------------------*/
public static List<List<SObject>> createBundleOfQuestionnaires(){

    List<List<SObject>> wizardDataSet = new  List<List<SObject>>();

    /* Create Questionnaires*/
    List<SFBG_Questionnaire__c> quesTestData = new List<SFBG_Questionnaire__c>();
    SFBG_Questionnaire__c quest = new SFBG_Questionnaire__c();
    quest.Name = 'Flood Damage';
    quest.SFBG_ExternalId__c = 'Flood Damage-V1';
    quest.SFBG_IsActive__c = true;
    //quest.SFBG_StartingQuestionId__r.SFBG_ExternalId__c = 
    quest.SFBG_Version__c = 1;
    quesTestData.add(quest);

    SFBG_Questionnaire__c quest1 = new SFBG_Questionnaire__c();
    quest1.Name = 'Damaged Equipment';
    quest1.SFBG_ExternalId__c = 'Damaged Equipment-V1';
    quest1.SFBG_IsActive__c = true;
    //quest.SFBG_StartingQuestionId__r.SFBG_ExternalId__c = 
    quest1.SFBG_Version__c = 1;

    quesTestData.add(quest1);
    wizardDataSet.add(quesTestData);
    /* Create Questions*/

    List<SFBG_Question__c> qstnTestData = new List<SFBG_Question__c>();
    SFBG_Question__c question = new SFBG_Question__c();
    question.Name = 'FloodDamage-V1-Q1';
    question.SFBG_ExternalId__c = 'FloodDamage-V1-Q1';
    //question.SFBG_QuestionnaireId__r.SFBG_ExternalId__c = quest.SFBG_ExternalId__c;
    //question.SFBG_QuestionnaireId__r.Name = quest.SFBG_ExternalId__r.Name;
    question.SFBG_IsActive__c = true;
    question.SFBG_Question__c = 'Is the water covering, or about to cover any Scottish Power Equipment?';
    question.SFBG_InformationCategory__c = '';
    question.RecordTypeId = Schema.SObjectType.SFBG_Question__c.getRecordTypeInfosByDeveloperName().get('Radio').getRecordTypeId();
    question.SPEN_CallOutcome__c = '';
    //question.SFBG_QuestionToDisplayId__r.SFBG_ExternalId__c
    qstnTestData.add(question);

    SFBG_Question__c question1 = new SFBG_Question__c();
    question1.Name = 'FloodDamage-V1-Q2';
    question1.SFBG_ExternalId__c = 'FloodDamage-V1-Q2';
    //question1.SFBG_QuestionnaireId__r.SFBG_ExternalId__c = quest.SFBG_ExternalId__c;
    //question1.SFBG_QuestionnaireId__r.Name = quest.SFBG_ExternalId__r.Name;
    question1.SFBG_IsActive__c = true;
    question1.SFBG_Question__c = 'I will arrange for an engineer to investigate a soon as possible – Please switch off your supply at the main switch - ONLY IF IT IS SAFE TO DO SO WITHOUT STANDING IN WATER';
    question1.SFBG_InformationCategory__c = 'Warning';
    question1.RecordTypeId = Schema.SObjectType.SFBG_Question__c.getRecordTypeInfosByDeveloperName().get('Information').getRecordTypeId();
    question1.SPEN_CallOutcome__c = 'ESF4';
    //question1.SFBG_QuestionToDisplayId__r.SFBG_ExternalId__c
    qstnTestData.add(question1);
    
    SFBG_Question__c question2 = new SFBG_Question__c();
    question2.Name = 'FloodDamage-V1-Q3';
    question2.SFBG_ExternalId__c = 'FloodDamage-V1-Q3';
    //question2.SFBG_QuestionnaireId__r.SFBG_ExternalId__c = quest.SFBG_ExternalId__c;
    //question2.SFBG_QuestionnaireId__r.Name = quest.SFBG_ExternalId__r.Name;
    question2.SFBG_IsActive__c = true;
    question2.SFBG_Question__c = 'Please switch off your supply at the main switch - ONLY IF SAFE TO DO SO WITHOUT STANDING IN WATER';
    question2.SFBG_InformationCategory__c = 'Warning';
    question2.RecordTypeId = Schema.SObjectType.SFBG_Question__c.getRecordTypeInfosByDeveloperName().get('Information').getRecordTypeId();
    question2.SPEN_CallOutcome__c = '';
    //question2.SFBG_QuestionToDisplayId__r.SFBG_ExternalId__c
    qstnTestData.add(question2);

    SFBG_Question__c question3 = new SFBG_Question__c();
    question3.Name = 'FloodDamage-V1-Q4';
    question3.SFBG_ExternalId__c = 'FloodDamage-V1-Q4';
    //question3.SFBG_QuestionnaireId__r.SFBG_ExternalId__c = quest.SFBG_ExternalId__c;
    //question3.SFBG_QuestionnaireId__r.Name = quest.SFBG_ExternalId__r.Name;
    question3.SFBG_IsActive__c = true;
    question3.SFBG_Question__c = 'Is your premises';
    question3.SFBG_InformationCategory__c = '';
    question3.RecordTypeId = Schema.SObjectType.SFBG_Question__c.getRecordTypeInfosByDeveloperName().get('Radio').getRecordTypeId();
    question3.SPEN_CallOutcome__c = '';
    //question3.SFBG_QuestionToDisplayId__r.SFBG_ExternalId__c
    qstnTestData.add(question3);

    SFBG_Question__c question4 = new SFBG_Question__c();
    question4.Name = 'FloodDamage-V1-Q5';
    question4.SFBG_ExternalId__c = 'FloodDamage-V1-Q5';
    //question4.SFBG_QuestionnaireId__r.SFBG_ExternalId__c = quest.SFBG_ExternalId__c;
    //question4.SFBG_QuestionnaireId__r.Name = quest.SFBG_ExternalId__r.Name;
    question4.SFBG_IsActive__c = true;
    question4.SFBG_Question__c = 'Contact your landlord';
    question4.SFBG_InformationCategory__c = 'Information';
    question4.RecordTypeId = Schema.SObjectType.SFBG_Question__c.getRecordTypeInfosByDeveloperName().get('Information').getRecordTypeId();
    question4.SPEN_CallOutcome__c = '';
    //question4.SFBG_QuestionToDisplayId__r.SFBG_ExternalId__c
    qstnTestData.add(question4);

    SFBG_Question__c question5 = new SFBG_Question__c();
    question5.Name = 'FloodDamage-V1-Q6';
    question5.SFBG_ExternalId__c = 'FloodDamage-V1-Q6';
    //question5.SFBG_QuestionnaireId__r.SFBG_ExternalId__c = quest.SFBG_ExternalId__c;
    //question5.SFBG_QuestionnaireId__r.Name = quest.SFBG_ExternalId__r.Name;
    question5.SFBG_IsActive__c = true;
    question5.SFBG_InformationCategory__c = 'Information';
    question5.RecordTypeId = Schema.SObjectType.SFBG_Question__c.getRecordTypeInfosByDeveloperName().get('Information').getRecordTypeId();
    question5.SPEN_CallOutcome__c = '';
    //question5.SFBG_QuestionToDisplayId__r.SFBG_ExternalId__c
    qstnTestData.add(question5);

    SFBG_Question__c question6 = new SFBG_Question__c();
    question6.Name = 'FloodDamage-V1-Q7';
    question6.SFBG_ExternalId__c = 'FloodDamage-V1-Q7';
    //question6.SFBG_QuestionnaireId__r.SFBG_ExternalId__c = quest.SFBG_ExternalId__c;
    //question6.SFBG_QuestionnaireId__r.Name = quest.SFBG_ExternalId__r.Name;
    question6.SFBG_IsActive__c = true;
    question6.SFBG_Question__c = 'Local Authority/Housing Assoc - contact your Local Authority or Housing Assoc';
    question6.SFBG_InformationCategory__c = 'Information';
    question6.RecordTypeId = Schema.SObjectType.SFBG_Question__c.getRecordTypeInfosByDeveloperName().get('Information').getRecordTypeId();
    question6.SPEN_CallOutcome__c = '';
    //question6.SFBG_QuestionToDisplayId__r.SFBG_ExternalId__c
    qstnTestData.add(question6);

    SFBG_Question__c question7 = new SFBG_Question__c();
    question7.Name = 'DamagedEquipment-V1-Q1';
    question7.SFBG_ExternalId__c = 'DamagedEquipment-V1-Q1';
    //question7.SFBG_QuestionnaireId__r.SFBG_ExternalId__c = quest1.SFBG_ExternalId__c;
    //question7.SFBG_QuestionnaireId__r.Name = quest1.SFBG_ExternalId__r.Name;
    question7.SFBG_IsActive__c = true;
    question7.SFBG_Question__c = 'Can you give me the exact location and cause of the damage?';
    question7.SFBG_InformationCategory__c = '';
    question7.RecordTypeId = Schema.SObjectType.SFBG_Question__c.getRecordTypeInfosByDeveloperName().get('Radio').getRecordTypeId();
    question7.SPEN_CallOutcome__c = '';
    //question7.SFBG_QuestionToDisplayId__r.SFBG_ExternalId__c = 
    qstnTestData.add(question7);
    
    SFBG_Question__c question8 = new SFBG_Question__c();
    question8.Name = 'DamagedEquipment-V1-Q2';
    question8.SFBG_ExternalId__c = 'DamagedEquipment-V1-Q2';
    //question8.SFBG_QuestionnaireId__r.SFBG_ExternalId__c = quest1.SFBG_ExternalId__c;
    //question8.SFBG_QuestionnaireId__r.Name = quest1.SFBG_ExternalId__r.Name;
    question8.SFBG_IsActive__c = true;
    question8.SFBG_Question__c = 'I need more information -an address or location before I can send someone out to you. Can you get some more information and call us back please.';
    question8.SFBG_InformationCategory__c = 'Information';
    question8.RecordTypeId = Schema.SObjectType.SFBG_Question__c.getRecordTypeInfosByDeveloperName().get('Information').getRecordTypeId();
    question8.SPEN_CallOutcome__c = '';
    //question8.SFBG_QuestionToDisplayId__r.SFBG_ExternalId__c = 
    qstnTestData.add(question8);
    
    SFBG_Question__c question9 = new SFBG_Question__c();
    question9.Name = 'DamagedEquipment-V1-Q3';
    question9.SFBG_ExternalId__c = 'DamagedEquipment-V1-Q3';
    //question9.SFBG_QuestionnaireId__r.SFBG_ExternalId__c = quest1.SFBG_ExternalId__c;
    //question9.SFBG_QuestionnaireId__r.Name = quest1.SFBG_ExternalId__r.Name;
    question9.SFBG_IsActive__c = true;
    question9.SFBG_Question__c = 'I will arrange for and engineer to attend as soon as possible. Could you please ensure people are kept away from the damage until our engineers arrive on site. Log a Call, capturing details in the Critical Information Field. Agent: Please include details of any injuries on site? Are supplies affected? SP cable plans on site.';
    question9.SFBG_InformationCategory__c = 'Information';
    question9.RecordTypeId = Schema.SObjectType.SFBG_Question__c.getRecordTypeInfosByDeveloperName().get('Information').getRecordTypeId();
    question9.SPEN_CallOutcome__c = 'FDAM';
    //question9.SFBG_QuestionToDisplayId__r.SFBG_ExternalId__c = 

    qstnTestData.add(question9);
    wizardDataSet.add(qstnTestData);
    
    /* Create Answers*/

    List<SFBG_Answer__c> ansTestData = new List<SFBG_Answer__c>();  
    SFBG_Answer__c ans = new SFBG_Answer__c();
    ans.Name = 'FloodDamage-V1-Q1-No';
    ans.SFBG_ExternalId__c = 'FloodDamage-V1-Q1-No';
    ans.SFBG_IsActive__c = True;
    ans.SFBG_Answer__c = 'No';
    ans.SFBG_Order__c = 200;
    ans.SFBG_Value__c = 'No';
    ansTestData.add(ans);

    SFBG_Answer__c ans1 = new SFBG_Answer__c();
    ans1.Name = 'FloodDamage-V1-Q1-Yes';
    ans1.SFBG_ExternalId__c = 'FloodDamage-V1-Q1-Yes';
    ans1.SFBG_IsActive__c = True;
    ans1.SFBG_Answer__c = 'Yes';
    ans1.SFBG_Order__c = 100;
    ans1.SFBG_Value__c = 'Yes';
    ansTestData.add(ans1);
    
    SFBG_Answer__c ans2 = new SFBG_Answer__c();
    ans2.Name = 'FloodDamage-V1-Q4-LocalAuthorityOrHousingAssoc';
    ans2.SFBG_ExternalId__c = 'FloodDamage-V1-Q4-LocalAuthorityOrHousingAssoc';
    ans2.SFBG_IsActive__c = True;
    ans2.SFBG_Answer__c = 'Local Authority/Housing Assoc';
    ans2.SFBG_Order__c = 300;
    ans2.SFBG_Value__c = 'Local Authority/Housing Assoc';
    ansTestData.add(ans2);
    
    SFBG_Answer__c ans3 = new SFBG_Answer__c();
    ans3.Name = 'FloodDamage-V1-Q4-PrivatelyOwned';
    ans3.SFBG_ExternalId__c = 'FloodDamage-V1-Q4-PrivatelyOwned';
    ans3.SFBG_IsActive__c = True;
    ans3.SFBG_Answer__c = 'Privately Owned';
    ans3.SFBG_Order__c = 200;
    ans3.SFBG_Value__c = 'Privately Owned';
    ansTestData.add(ans3);  
    
    SFBG_Answer__c ans4 = new SFBG_Answer__c();
    ans4.Name = 'FloodDamage-V1-Q4-PrivatelyRented';
    ans4.SFBG_ExternalId__c = 'FloodDamage-V1-Q4-PrivatelyRented';
    ans4.SFBG_IsActive__c = True;
    ans4.SFBG_Answer__c = 'Privately Rented';
    ans4.SFBG_Order__c = 100;
    ans4.SFBG_Value__c = 'Privately Rented';
    ansTestData.add(ans4);  
    
    SFBG_Answer__c ans5 = new SFBG_Answer__c();
    ans5.Name = 'DamagedEquipment-V1-Q1-No';
    ans5.SFBG_ExternalId__c = 'DamagedEquipment-V1-Q1-No';
    ans5.SFBG_IsActive__c = True;
    ans5.SFBG_Answer__c = 'No';
    ans5.SFBG_Order__c = 200;
    ans5.SFBG_Value__c = 'No';
    ansTestData.add(ans5);

    SFBG_Answer__c ans6 = new SFBG_Answer__c();
    ans6.Name = 'DamagedEquipment-V1-Q1-Yes';
    ans6.SFBG_ExternalId__c = 'DamagedEquipment-V1-Q1-Yes';
    ans6.SFBG_IsActive__c = True;
    ans6.SFBG_Answer__c = 'Yes';
    ans6.SFBG_Order__c = 100;
    ans6.SFBG_Value__c = 'Yes';
    ansTestData.add(ans6);
    
    wizardDataSet.add(ansTestData);
    return wizardDataSet;

 }

 /****************************************************************************************************************************
* @Author:      Bhagyashree Mandlik
* @Date:        14/10/2022
* @Description: Method to specifically create Test Premises based on parameter Integer recCount for bulk/single record from test classes.
*****************************************************************************************************************************/
public static List<SPEN_Premise__c> createListOfPremise(Integer recCount){
    List<SPEN_Premise__c> testCse = new List<SPEN_Premise__c>();
    SPEN_Premise__c cse;
    Integer i=0;
    while(i<recCount){
            cse = new SPEN_Premise__c();
           cse.SPEN_PremiseName__c = 'Premise '+ i;
            cse.SPEN_PostCode__c = 'L129';
            cse.SPEN_PremiseNumber__c = '123';
            cse.SPEN_FlatNumber__c='112';
            cse.SPEN_OperatingZone__c = 'EHV South';
            cse.SPEN_PremiseID__c = 'OX123'+ i;
            testCse.add(cse);
            i++;
        }
        return testCse;
    }

 /****************************************************************************************************************************
* @Author:      Smita Raikar
* @Date:        03/11/2022
* @Description: Method to specifically create Test Contact Premises based on parameter Integer recCount for bulk/single record from test classes.
*****************************************************************************************************************************/
public static SPEN_ContactPremise__c createContactPremises(Integer recCount,Id conId,Id premiseId){
    
    SPEN_ContactPremise__c cp;
    Integer i=0;
    while(i<recCount){
        cp = new SPEN_ContactPremise__c();
        cp.SPEN_RelationshipWithPremise__c = 'Landlord ';
        cp.SPEN_RelatedContact__c = conId;
        cp.SPEN_Premise__c = premiseId;
        i++;   
    }
    return cp;
}
    
    
 /****************************************************************************************************************************
* @Author:      Smita Raikar
* @Date:        08/12/2022
* @Description: Method to specifically create Test Configurable setting based on parameter Integer recCount for bulk/single record from test classes.
*****************************************************************************************************************************/
public static SPEN_ConfigurableSettings__c createConfigSetting(Integer recCount,String settingName){
    
    SPEN_ConfigurableSettings__c cs;
    Integer i=0;
    while(i<recCount){
            cs = new SPEN_ConfigurableSettings__c();
            cs.Name = settingName;
            cs.SPEN_Value__c = (settingName == 'MessagingTaskType') ? ('HV_N,HV_S,LV') : '2';
            cs.SPEN_Description__c = 'Monitoring systems on our network have alerted us to an unexpected fault affecting a number of customers over a wide area.';
            i++;  
        }
        return cs;
    }
/****************************************************************************************************************************
* @Author:      Dhara Desai
* @Date:        01/11/2022
* @Description: Method to specifically create test MPAN records for MockAPI
*****************************************************************************************************************************/
public static SPEN_MPAN__c createMPANRecords(Integer recCount){
    SPEN_MPAN__c mpan;
    //Integer i=0;
    //while(i<recCount){
        mpan = new SPEN_MPAN__c();
        mpan.SPEN_AccountNumberMPAN__c = '676372';
        mpan.SPEN_PingResult__c = 'Energized';
        mpan.ExternalId__c = '123445';
        //i++;
    //}
    return mpan;
}

/****************************************************************************************************************************
* @Author:      Ayush Mittal
* @Date:        02/11/2022
* @Description: Method to specifically create PSR and Vulnerability Type data for test classes
*****************************************************************************************************************************/
public static List<SPEN_PSRVulnerabilityType__c> createPSRVulnerabilityRecords(){
    List<SPEN_PSRVulnerabilityType__c> psrVulList = new List<SPEN_PSRVulnerabilityType__c>();

    SPEN_PSRVulnerabilityType__c psrVul = new SPEN_PSRVulnerabilityType__c();
    psrVul.Name = '1-Nebuliser and apnoea monitor';
    psrVul.SPEN_Code__c = '1';
    psrVul.SPEN_Description__c = 'Nebuliser and apnoea monitor';
    psrVul.SPEN_SpecificVulnerability__c = True;
    psrVul.SPEN_Priority__c = True;
    psrVul.SPEN_Active__c = True;
    psrVulList.add(psrVul);

    SPEN_PSRVulnerabilityType__c psrVul1 = new SPEN_PSRVulnerabilityType__c();
    psrVul1.Name = '2-Heart, lung & ventilator';
    psrVul1.SPEN_Code__c = '2';
    psrVul1.SPEN_Description__c = 'Heart, lung & ventilator';
    psrVul1.SPEN_SpecificVulnerability__c = True;
    psrVul1.SPEN_Priority__c = True;
    psrVul1.SPEN_Active__c = True;
    psrVulList.add(psrVul1);
    
    SPEN_PSRVulnerabilityType__c psrVul2 = new SPEN_PSRVulnerabilityType__c();
    psrVul2.Name = '9-Partially sighted';
    psrVul2.SPEN_Code__c = '9';
    psrVul2.SPEN_Description__c = 'Partially sighted';
    psrVul2.SPEN_SpecificVulnerability__c = False;
    psrVul2.SPEN_Priority__c = False;
    psrVul2.SPEN_Active__c = True;
    psrVulList.add(psrVul2);

    return psrVulList;
}
/****************************************************************************************************************************
* @Author:      Sumit Biswas
* @Date:        7/11/2022
* @Description: Method to specifically create testCases based on Origin Web and Phone for CaseCallouts class.
*****************************************************************************************************************************/
 public static Map<Id, Case> createWebCase(){
    Id recId;
    recId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unplanned - Fault').getRecordTypeId();
     Map<id, Case> testCse = new Map<id, Case>();
     Case cse = new Case(
     Status = 'Open',
     Origin = 'Web',
     SPEN_SendtoPowerOn__c = TRUE,
     SPEN_CriticalInformation__c = 'Test Critical Information',
     RecordTypeId = recId);
     insert cse;
     testCse.put(cse.Id, cse);
     return testCse;
 }
public static List<Case> createFaultCase(){
    List<Case> newTestCse = new List<Case>();
    Id recId;
    recId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unplanned - Fault').getRecordTypeId();
    Case newCase = new Case();
    newCase.RecordTypeId = recId;
    //newCase.Id = '5003H0000076VyfQAE';
    newCase.Status = 'Open';
    newCase.Origin = 'Web';
    newCase.SPEN_SendtoPowerOn__c = TRUE;
    newCase.SPEN_CriticalInformation__c = 'Test Critical Information';
    insert newCase;
    //String caseId = newCase.Id;
    newTestCse.add(newCase);
    Case cse = new Case(
            Status = 'Open',
            Origin = 'Phone',
            //SPEN_SendtoPowerOn__c = TRUE,
            SPEN_CriticalInformation__c = 'Test Critical Information',
            RecordTypeId = recId
        );
    insert cse;
    newTestCse.add(cse);
    return newTestCse;
}
public static List<Case> createUnPlannedFaultCase(Id premiseId){
    List<Case> newTestCse = new List<Case>();
    Id recId;
    recId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unplanned - Fault').getRecordTypeId();
    
    Case cse = new Case(
            Status = 'Open',
            Origin = 'Phone',
        	SPEN_AddressPremise__c=premiseId,
            SPEN_SendtoPowerOn__c = TRUE,
            SPEN_CriticalInformation__c = 'Test Critical Information',
            RecordTypeId = recId
        );
    insert cse;
    newTestCse.add(cse);
    return newTestCse;
}
public static List<Case> cancelCallCase(){
    Id recId;
    recId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unplanned - Fault').getRecordTypeId();
    List<Case> newTestCse = new List<Case>();
    Case newCase = new Case();
    //newCase.Id = '5003H0000076VyfQAE';
    newCase.Status = 'Cancelled';
    newCase.SPEN_Incident__c = NULL;
    newCase.RecordTypeId = recId;
    //newCase.Origin = 'Web';
    //newCase.SPEN_SendtoPowerOn__c = TRUE;
    //newCase.SPEN_CriticalInformation__c = 'Test Critical Information';
    insert newCase;
    newTestCse.add(newCase);
    return newTestCse;
}
/****************************************************************************************************************************
* @Author:      Sumit Biswas
* @Date:        7/11/2022
* @Description: Method to specifically create testCases based on MPAN AccountNumber and LastGasp for SPEN_SyncMPANDetails class.
*****************************************************************************************************************************/
    public static List<SPEN_MPAN__c> updateLastGaspTest(Integer mpanCount){
        List<SPEN_MPAN__c> testLastGasp = new List<SPEN_MPAN__c>();
        Integer i=0;
        while(i<mpanCount){
            String lastGaspDate = '2022-11-02T02:32:23.0000000+01:00';
            SPEN_MPAN__c mpanRecord = new SPEN_MPAN__c();
            mpanRecord.SPEN_AccountNumberMPAN__c = '1300256734879';
            mpanRecord.SPEN_LastGasp__c = Datetime.valueOfGmt(lastGaspDate.replace('T', ' '));
            testLastGasp.add(mpanRecord);
            i++;
        }
        if(!testLastGasp.isEmpty()){
            insert testLastGasp;
        }
        return testLastGasp;   
  }
    
/****************************************************************************************************************************
* @Author:      Debapriya Saha
* @Date:        11/11/2022
*****************************************************************************************************************************/
public static SPEN_IntegrationRequest__c createProcessingIntegrationReq(){
    SPEN_IntegrationRequest__c intReq = new SPEN_IntegrationRequest__c();
        intReq.SPEN_Status__c = 'Processing';
        intReq.SPEN_IntegrationRequestServiceClass__c = 'SPEN_MeterPingService';
        return intReq;
    }
    public static SPEN_IntegrationRequest__c createFailedIntegrationReq(){
    SPEN_IntegrationRequest__c intFailedReq = new SPEN_IntegrationRequest__c();
        intFailedReq.SPEN_Status__c = 'Failed';
        intFailedReq.SPEN_IntegrationRequestServiceClass__c = 'SPEN_MeterPingService';
        insert intFailedReq;
        return intFailedReq;
    }

    public static SPEN_IntegrationRequest__c createIntegrationReqforIVRMsg(){
    SPEN_IntegrationRequest__c intReq = new SPEN_IntegrationRequest__c();
        intReq.SPEN_Status__c = 'Processing';
        intReq.SPEN_IntegrationRequestServiceClass__c = 'SPEN_IVRMessageService';
        return intReq;
    }
    
    public static SPEN_IntegrationRequest__c createFailedIntegrationReqforIVRMsg(){
    SPEN_IntegrationRequest__c intFailedReq = new SPEN_IntegrationRequest__c();
        intFailedReq.SPEN_Status__c = 'Failed';
        intFailedReq.SPEN_IntegrationRequestServiceClass__c = 'SPEN_IVRMessageService';
        insert intFailedReq;
        return intFailedReq;
    }
    /****************************************************************************************************************************
* @Author:      Smita Raikar
* @Date:        20/03/2023
* @Description: Method to specifically create test data for SPEN_IntegrationRequestSelector class
*****************************************************************************************************************************/
public static List<SPEN_IntegrationRequest__c> createSentIntegrationReq (Integer reccount){
    List<SPEN_IntegrationRequest__c> intList = new List <SPEN_IntegrationRequest__c>();
    Integer i=0;
    while(i<recCount){
        SPEN_IntegrationRequest__c inte=new SPEN_IntegrationRequest__c();
        inte.Name='Test request';
        inte.SPEN_RequestedBy__c = UserInfo.getUserId();
        inte.SPEN_Status__c = 'Sent';
        intList.add(inte);
        i++;
    }
    return intList;
    }
    
/*********************************************************************************************************************
 * @Author: Rohit Chowdhury
 * @Date: 15/11/2022
 * @Description: Method to specifically create testCases for SPEN_VoiceCallService class.
**********************************************************************************************************************/

public static VoiceCall createVoiceCall(Integer count){
    //VoiceCall voice;
    Datetime myDate1 = Datetime.newInstance(2022, 11, 10, 13, 30, 30);
    Datetime myDate2 = Datetime.newInstance(2008, 11, 10, 13, 30, 58);
    //for(integer i=0;i<    count;i++){
        VoiceCall voice = new VoiceCall();
        voice.CallStartDateTime = myDate1;
        voice.CallEndDateTime = myDate2;
        voice.FromPhoneNumber='+448081649518';
        voice.ToPhoneNumber = '+442038300600';
        voice.CallType = 'Inbound';
    //  }
    return voice;   
        
}
/*********************************************************************************************************************
 * @Author: Rohit Chowdhury
 * @Date: 16/11/2022
 * @Description: Methods to specifically create testCases for SPEN_MessagingSessionService class.
**********************************************************************************************************************/
    public static MessagingEndUser createMessagingUser(Integer count){
        MessagingEndUser enduser;
        //for(integer i=0;i<count;i++)
        //{
            enduser=new MessagingEndUser();
            enduser.MessagingPlatformKey = '+448081895294';
            enduser.MessageType = 'Voice';
            enduser.Name = '+448081895294';
        //}
        return enduser;
    }
    
    public static MessagingSession createMessagingSession(Integer count){
        MessagingSession message;
        Datetime myDate1 = Datetime.newInstance(2022, 11, 10, 13, 30, 30);
        Datetime myDate2 = Datetime.newInstance(2008, 11, 10, 13, 30, 58);
        //for(integer i=0;i<count;i++){
            message=new MessagingSession();
            message.StartTime=myDate1;
            message.EndTime=myDate2;
            message.Origin='InboundInitiated';
            message.Status='Ended';
        //}
        return message;
     }

/*********************************************************************************************************************
 * @Author: Rohit Chowdhury
 * @Date: 21/11/2022
 * @Description: Methods to specifically create testCases for SPEN_ZoneConfigurationService class.
**********************************************************************************************************************/
public static SPEN_IVRMessage__c createIVRMessage(Integer recCount)
{
    //SPEN_IVRMessage__c message;
    String iVRMessageTemplateExtName = 'Case-Creation-';
    Id msgRecordTypeId = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();
    //for(integer i=0;i< recCount;i++){
        SPEN_IVRMessage__c message=new SPEN_IVRMessage__c();
        message.Name='Test IVR';
        message.SPEN_IVRMessage__c='The following information is for customers.';
        message.RecordTypeId=msgRecordTypeId;
        //message.SPEN_Purpose__c='Storm';
        message.SPEN_Purpose__c = 'MPAS Inquiry';
        message.SPEN_ExternalId__c = iVRMessageTemplateExtName+recCount;    
    //}
    return message;
}
      
       
    public static SPEN_Zone__c createZoneRegionRecords(Id messageId)
    {
        SPEN_Zone__c zoneRegion = new SPEN_Zone__c();
        zoneRegion.Name='Test_Region';
        zoneRegion.SPEN_BroadcastMessage__c= 'The following information is for customers';
        zoneRegion.SPEN_IVRMessageTemplate__c=messageId;
        zoneRegion.SPEN_Type__c='Region';
        zoneRegion.SPEN_OverwriteToChild__c=true;
        return zoneRegion;
    }
    public static SPEN_Zone__c createZoneDistrictRecords(Id messageId)
    {
        SPEN_Zone__c zoneDistrict = new SPEN_Zone__c();
        zoneDistrict.Name='Test__District';
        zoneDistrict.SPEN_BroadcastMessage__c= 'The following information is for customers';
        zoneDistrict.SPEN_IVRMessageTemplate__c=messageId;
        zoneDistrict.SPEN_Type__c='District';
        zoneDistrict.SPEN_OverwriteToChild__c=true;
        return zoneDistrict;
    }
    public static SPEN_Zone__c createZoneRecords(Id messageId)
    {
        SPEN_Zone__c zone = new SPEN_Zone__c();
        zone.Name='Test_Zone';
        zone.SPEN_BroadcastMessage__c= 'The following information is for customers';
        zone.SPEN_IVRMessageTemplate__c=messageId;
        zone.SPEN_Type__c='Zone';
        zone.SPEN_OverwriteToChild__c=true;
        return zone;
    }
   
/****************************************************************************************************************************
* @Author:      Ayush Mittal
* @Date:        21/11/2022
* @Description: Method to specifically create test MPAN records for MockAPI
*****************************************************************************************************************************/
public static List<SPEN_MPAN__c> createMPANList(Integer recCount){
    List<SPEN_MPAN__c> mpanList = new List<SPEN_MPAN__c>();
    Integer i=0;
    while(i<recCount){
        SPEN_MPAN__c mpan = new SPEN_MPAN__c();
        mpan.SPEN_AccountNumberMPAN__c = '676372'+i;
        mpan.SPEN_PingResult__c = 'Energized';
        mpan.ExternalId__c = '123445'+i;
        mpanList.add(mpan);
        i++;
    }
    return mpanList;
}
/****************************************************************************************************************************
* @Author:      Sheker Kulkacherla
* @Date:        25/11/2022
* @Description: Method to specifically create test Push Topic record for SPEN_PushTopicController.apxc
*****************************************************************************************************************************/
public static PushTopic createPushTopicRecord(){
    PushTopic topic = new PushTopic();
        topic.Name = 'Validation';
        topic.Query = 'SELECT id,SPEN_IVRAlarm__c FROM Incident';
        topic.ApiVersion = 56.0;
        topic.NotifyForOperationCreate = true;
        topic.NotifyForOperationUpdate = true;
        topic.NotifyForFields = 'Referenced';
        insert topic;
        return topic;
    }
/****************************************************************************************************************************
* @Author:      Rohit Chowdhury
* @Date:        06/12/2022
* @Description: Method to specifically create test data for Dynamic Call Wizard Selector class
*****************************************************************************************************************************/

    public static List<SFBG_Questionnaire__c> prepareQuestionnaireData(String questionnairename, Integer count){

        List<SFBG_Questionnaire__c> questionnaireList = new List<SFBG_Questionnaire__c>();
        Integer i=0;
        while(i<count){
            SFBG_Questionnaire__c quest = new SFBG_Questionnaire__c();
            quest.Name = questionnairename+i;
            quest.SFBG_ExternalId__c = questionnairename+i;
            quest.SFBG_IsActive__c = true;
            //quest.SFBG_StartingQuestionId__r.SFBG_ExternalId__c =
            quest.SFBG_Version__c = 1;
            questionnaireList.add(quest);
            i++;
        }
        return questionnaireList;
    }
    public static List<SFBG_Question__c> prepareQuestionData(String questionname, Id questionnaireId, Integer count){

        List<SFBG_Question__c> questionList = new List<SFBG_Question__c>();
        Integer i=0;
        while(i<count){
            SFBG_Question__c question = new SFBG_Question__c();
            question.Name = questionname+i;
            question.SFBG_QuestionnaireId__c=questionnaireId;
            question.SFBG_ExternalId__c = questionname+i;
            //question.SFBG_QuestionnaireId__r.SFBG_ExternalId__c = quest.SFBG_ExternalId__c;
            //question.SFBG_QuestionnaireId__r.Name = quest.SFBG_ExternalId__r.Name;
            question.SFBG_IsActive__c = true;
            question.SFBG_Question__c = 'Is the water covering, or about to cover any Scottish Power Equipment?';
            question.SFBG_InformationCategory__c = '';
            question.RecordTypeId = Schema.SObjectType.SFBG_Question__c.getRecordTypeInfosByDeveloperName().get('Radio').getRecordTypeId();
            question.SPEN_CallOutcome__c = '';
            //question.SFBG_QuestionToDisplayId__r.SFBG_ExternalId__c
            questionList.add(question);
            i++;
        }
        return questionList;

    }
    public static List<SFBG_Answer__c> prepareAnswerData(String answername, Id questionId, Integer count){

        List<SFBG_Answer__c> answerList = new List<SFBG_Answer__c>();
        Integer i=0;
        while(i<count){
            SFBG_Answer__c ans=new SFBG_Answer__c();
            ans.SFBG_QuestionId__c=questionId;
            ans.Name = answername+i;
            ans.SFBG_ExternalId__c = answername+i;
            ans.SFBG_IsActive__c = True;
            ans.SFBG_Answer__c = 'No';
            ans.SFBG_Order__c = 200;
            ans.SFBG_Value__c = 'No';
            answerList.add(ans);
            i++;
        }
        return answerList;
    }
    public static List<SFBG_Question__c> preparePrevQuestionData(String questionname,Id parentquestionId, Id questionnaireId, Integer count){

        List<SFBG_Question__c> questionList = new List<SFBG_Question__c>();
        Integer i=0;
        while(i<count){
            SFBG_Question__c question = new SFBG_Question__c();
            question.Name = questionname+i;
            question.SFBG_QuestionnaireId__c=questionnaireId;
            question.SFBG_ExternalId__c = questionname+i;
            question.SFBG_QuestionToDisplayId__c=parentquestionId;
            //question.SFBG_QuestionnaireId__r.SFBG_ExternalId__c = quest.SFBG_ExternalId__c;
            //question.SFBG_QuestionnaireId__r.Name = quest.SFBG_ExternalId__r.Name;
            question.SFBG_IsActive__c = true;
            question.SFBG_Question__c = 'Is the water covering, or about to cover any Scottish Power Equipment?';
            question.SFBG_InformationCategory__c = '';
            question.RecordTypeId = Schema.SObjectType.SFBG_Question__c.getRecordTypeInfosByDeveloperName().get('Radio').getRecordTypeId();
            question.SPEN_CallOutcome__c = '';
            //question.SFBG_QuestionToDisplayId__r.SFBG_ExternalId__c
            questionList.add(question);
            i++;
        }
        return questionList;
    }
/****************************************************************************************************************************
* @Author:      Rohit Chowdhury
* @Date:        09/12/2022
* @Description: Method to specifically create test data for SPEN_IntegrationRequestSelector class
*****************************************************************************************************************************/
public static List<SPEN_IntegrationRequest__c> createIntegrationReq (Integer count){
    List<SPEN_IntegrationRequest__c> intList = new List <SPEN_IntegrationRequest__c>();
    Integer i=0;
    while(i<count){
        SPEN_IntegrationRequest__c inte=new SPEN_IntegrationRequest__c();
        inte.Name='Test request';
        inte.SPEN_IntegrationRequestServiceClass__c = 'SPEN_GetAffectedPremiseService' ;
        inte.SPEN_Status__c = 'Processing';
        intList.add(inte);
        i++;
    }
    return intList;

}
/****************************************************************************************************************************
* @Author:      Rohit Chowdhury
* @Date:        10/12/2022
* @Description: Method to specifically create Test Premises record based on parameter Integer recCount for bulk/single record from test classes.
*****************************************************************************************************************************/
public static List<SPEN_Premise__c> createPremiseRecord(String name, String premise, Integer count){
    List<SPEN_Premise__c> testCse = new List<SPEN_Premise__c>();
    SPEN_Premise__c cse;
    Integer i=0;
    while(i<count){
        cse = new SPEN_Premise__c();
        cse.SPEN_PremiseName__c = 'Premise '+ i;
        cse.SPEN_ExternalId__c  =name+i;
        cse.SPEN_PostCode__c = 'L129';
        cse.SPEN_PremiseNumber__c = '123';
        cse.SPEN_OperatingZone__c = 'EHV South';
        cse.SPEN_PremiseID__c =premise+i;
        testCse.add(cse);
        i++;
    }
    return testCse;
}
/****************************************************************************************************************************
* @Author:      Rohit Chowdhury
* @Date:        20/12/2022
* @Description: Method to specifically create Test record for SPEN_SyncContactsBatch
*****************************************************************************************************************************/
public static List<SPEN_ContactStaging__c> createContactStagingrecord (Integer count){
    List<SPEN_ContactStaging__c> con=new List<SPEN_ContactStaging__c>();
    SPEN_ContactStaging__c cse;
    //Datetime myDate1 = Datetime.newInstance(2022, 11, 10, 13, 30, 30);
    Integer i=0;
    while(i<count){        
        cse=new SPEN_ContactStaging__c();
        cse.SPEN_AdqmAction__c='New';
        cse.SPEN_AdqmSource__c='Customer';
        cse.SPEN_FirstName__c='John';
        cse.SPEN_LastName__c='Doe';
        cse.SPEN_SyncStatus__c='Not Started';
        //cse.SPEN_OtherContactId__c='SB__001';
        //cse.SPEN_AdqmLastModifiedDateTime__c=myDate1;
        con.add(cse);
        i++;
    }
    return con;
}
/****************************************************************************************************************************
* @Author:      Rohit Chowdhury
* @Date:        23/12/2022
* @Description: Method to specifically create Test record for SPEN_SyncPSRBatch
*****************************************************************************************************************************/
public static List<SPEN_PSRStaging__c> createPSRStagingrecord (Integer count)
{
    List<SPEN_PSRStaging__c> psrList=new List<SPEN_PSRStaging__c>();
    SPEN_PSRStaging__c psr;
    Integer i=0;
    while(i<count){
        psr=new SPEN_PSRStaging__c();
        psr.SPEN_ADQMAction__c='New';
        psr.SPEN_SyncStatus__c='New';
        psr.SPEN_PremiseID__c='P000'+i;
        psr.SPEN_PsrVulnerabilityTypeId__c='PSRV000'+i;
        psrList.add(psr);
        i++;
    }
    return psrList;
}

/****************************************************************************************************************************
* @Author:      Rohit Chowdhury
* @Date:        26/12/2022
* @Description: Method to specifically create Test record for Voice Alert
*****************************************************************************************************************************/
public static List<SPEN_VoiceAlert__c> createVoiceAlertrecord (Integer count){
    List<SPEN_VoiceAlert__c> alertList=new List<SPEN_VoiceAlert__c>();
    SPEN_VoiceAlert__c voiceal;
    Integer i=0;
    while(i<count){
        voiceal=new SPEN_VoiceAlert__c();
        voiceal.Name='Sample Voice Alert';
        alertList.add(voiceal);
        i++;
    }
    return alertList;
}
/****************************************************************************************************************************
* @Author:      Rohit Chowdhury
* @Date:        26/12/2022
* @Description: Method to specifically create Test record for PSR
*****************************************************************************************************************************/
public static List<SPEN_PSR__c> createPSRrecord (Integer count){
    List<SPEN_PSR__c> psrList=new List<SPEN_PSR__c>();
    SPEN_PSR__c psr;
    Integer i=0;
    while(i<count){
        psr=new SPEN_PSR__c();
        psr.SPEN_IsCustomerHappy__c='Yes';
        psr.SPEN_SourceofPSRUpdate__c='Inbound Call';
        psr.SPEN_IsPSRDetailsValidated__c='Yes';
        psrList.add(psr);
        i++;
    }
    return psrlist;
}
/****************************************************************************************************************************
* @Author:      Rohit Chowdhury
* @Date:        28/12/2022
* @Description: Method to specifically create Test record for Supplier Details
*****************************************************************************************************************************/
public static List<SPEN_SupplierDetails__c> createSupplierDetailsrecord (Integer count){
    List<SPEN_SupplierDetails__c> supplyList=new List<SPEN_SupplierDetails__c>();
    SPEN_SupplierDetails__c sD;
    Integer i=0;
    while(i<count){
        sD=new SPEN_SupplierDetails__c();
        sD.Name = 'TEST Supplier';
        sD.SPEN_SupplierMPID__c = 'TST';
        sD.SPEN_SupplierPhoneNumber__c = '12345' ;
        supplyList.add(sD);
        i++;
    }
    return supplyList;
}
/****************************************************************************************************************************
* @Author:      Rohit Chowdhury
* @Date:        28/12/2022
* @Description: Method to specifically create Test record for IVR Operating Hours
*****************************************************************************************************************************/
public static List<SPEN_IVROperatingHours__c> createIVROperatingHoursrecord (Integer count, Id ivr, Id ivrmessage){
    List<SPEN_IVROperatingHours__c> ivrList=new List<SPEN_IVROperatingHours__c>();
    SPEN_IVROperatingHours__c ivrhours;
    Integer i=0;
    while(i<count){
        ivrhours=new SPEN_IVROperatingHours__c();
        ivrhours.Name='Sample IVR';
        ivrhours.SPEN_IVRMessage__c=ivrmessage;
        ivrhours.SPEN_IVR__c=ivr;
        ivrList.add(ivrhours);
        i++;
    }
    return ivrList;
}
/****************************************************************************************************************************
* @Author:      Rohit Chowdhury
* @Date:        28/12/2022
* @Description: Method to specifically create Test record for IVR 
*****************************************************************************************************************************/
public static List<SPEN_IVR__c> createIVRrecord (Integer count){
    List<SPEN_IVR__c> ivrrecList=new List<SPEN_IVR__c>();
    SPEN_IVR__c ivrrec;
    Integer i=0;
    while(i<count){
        ivrrec=new SPEN_IVR__c();
        ivrrec.Name='Sample IVR';
        ivrrecList.add(ivrrec);
        i++;
    }
    return ivrrecList;
}
/****************************************************************************************************************************
* @Author:      Rohit Chowdhury
* @Date:        04/01/2023
* @Description: Method to specifically create Test record for Impacted Premise 
*****************************************************************************************************************************/
public static List<SPEN_ImpactedPremise__c> createImpactedPremiserecord (Integer count)
{
    List<SPEN_ImpactedPremise__c> imppreList=new List<SPEN_ImpactedPremise__c>();
    SPEN_ImpactedPremise__c imprec;
    Integer i=0;
    while(i<count){
        imprec=new SPEN_ImpactedPremise__c();
        imprec.SPEN_ExternalId__c='1234'+i;
        imprec.SPEN_PremiseId__c = '121'+i;
        imprec.SPEN_MedicallyDependent__c = true;
        imprec.SPEN_IncidentType__c = 'HV_S';
        imprec.SPEN_Status__c='Not Restored';
        imppreList.add(imprec);
        i++;   
    }
    return imppreList;
}

/****************************************************************************************************************************
* @Author:      Rohit Chowdhury
* @Date:        09/12/2022
* @Description: Method to specifically create test data for SPEN_IntegrationRequestSelector class
*****************************************************************************************************************************/ 
public static List<SPEN_IntegrationRequest__c> completeIntegrationReq (Integer count){
    List<SPEN_IntegrationRequest__c> intList = new List <SPEN_IntegrationRequest__c>();
    Integer i=0;
    while(i<count){
        SPEN_IntegrationRequest__c inte=new SPEN_IntegrationRequest__c();
        inte.Name='Test request';
        inte.SPEN_IntegrationRequestServiceClass__c = 'SPEN_GetAffectedPremiseService' ;
        inte.SPEN_Status__c = 'Completed';
        intList.add(inte);
        i++;
    }
    return intList;
}
/****************************************************************************************************************************
    * @Author:      Rohit Chowdhury
    * @Date:        03/02/2023
    * @Description: Method to specifically create Test record for Messaging Task 
    *****************************************************************************************************************************/    
    public static List<SPEN_MessagingTask__c> createMessagingTask (Integer count){
        List<SPEN_MessagingTask__c> taskList=new List<SPEN_MessagingTask__c>();
        SPEN_MessagingTask__c task;
        Integer i=0;
        while(i<count){
            task=new SPEN_MessagingTask__c();
            task.SPEN_Status__c='New';
            task.SPEN_Event__c='3-Hour Comfort Call';
            taskList.add(task);
            i++;
        }
        return taskList;

    }
    /****************************************************************************************************************************
    * @Author:      Smita Raikar
    * @Date:        09/05/2023
    * @Description: Method to specifically create Test record for group 
    *****************************************************************************************************************************/    
    public static Group createtestGroup (Integer recCount,Id userId )
    {
    	Group msgTaskQueue= new Group();
        msgTaskQueue.type='Queue';
        msgTaskQueue.Name='MessagingTaskSPM';
        msgTaskQueue.DeveloperName='Messaging_Task_SPM'+userId;
        
        
        return msgTaskQueue;

    }
    /****************************************************************************************************************************
    * @Author:      Smita Raikar
    * @Date:        09/05/2023
    * @Description: Method to specifically create Test record for Messaging Task 
    *****************************************************************************************************************************/    
    public static List<SPEN_MessagingTask__c> createMessagingTaskforIncCreated (Integer recCount)
    {
    	
        List<SPEN_MessagingTask__c> taskList=new List<SPEN_MessagingTask__c>();
        SPEN_MessagingTask__c task;
        for(integer i=0;i<recCount;i++)
        {
            task=new SPEN_MessagingTask__c();
            task.SPEN_Status__c='New';
            task.SPEN_Event__c='Incident Created';
            
            taskList.add(task);
        }
        return taskList;

    }
    
    /****************************************************************************************************************************
    * @Author:      Rohit Chowdhury
    * @Date:        20/01/2023
    * @Description: Method to specifically create Test record for SMS Config Setting 
    *****************************************************************************************************************************/
public static List<SPEN_ConfigurableSettings__c> createConfigSettingforSMSConfig(Integer count)
{

    List<SPEN_ConfigurableSettings__c> csList = new List<SPEN_ConfigurableSettings__c>();
    
    Integer i=0;
    while(i<count)
    {
        SPEN_ConfigurableSettings__c cs = New SPEN_ConfigurableSettings__c();
        cs.Name = 'SMS Config';
        cs.SPEN_Value__c = 'Phone';
        cs.SPEN_Feature__c = 'ENS1';
        cs.SPEN_Description__c = 'No Supply (Single Premise)';
        csList.add(cs);  
        i++;   

    }
    return csList;
}
/****************************************************************************************************************************
    * @Author:      Rohit Chowdhury
    * @Date:        20/01/2023
    * @Description: Method to specifically create Test record for Communication Scheduler 
    *****************************************************************************************************************************/
    public static List<SPEN_CommunicationScheduler__c > createCommunicationSchedulerRecord (Integer count){
        List<SPEN_CommunicationScheduler__c> lstCommSche = new List<SPEN_CommunicationScheduler__c>();
        SPEN_CommunicationScheduler__c objCommSche;
        Integer i=0;
        while(i<count){
            objCommSche = new SPEN_CommunicationScheduler__c();
            objCommSche.SPEN_District__c = 'ZW11';
            objCommSche.SPEN_Event__c = 'Incident Created';
            objCommSche.SPEN_Message__c = 'hello';
            objCommSche.SPEN_NonPSRMessage__c  = 'Non-PSR Message';
            lstCommSche.add(objCommSche);  
            i++; 
        }
        return lstCommSche;
    }
/****************************************************************************************************************************
    * @Author:      Sumit Biswas
    * @Date:        22/02/2023
    * @Description: Method to specifically create Test record for ListView 
*****************************************************************************************************************************/
public static List<ListView> getListViews(){
    return SPEN_TestdataSelector.getListViews('SPEN_Premise__c');
    //[SELECT Id, Name FROM ListView WHERE SobjectType = 'SPEN_Premise__c' order by Name];
}

/****************************************************************************************************************************
* @Author:      Rajat Verma
* @Date:        30/06/2023
* @Description: Method to specifically create Test record for Impacted Premise 
*****************************************************************************************************************************/
public static List<SPEN_Plot__c> createPlotRecords (Integer reccount)
{
    List<SPEN_Plot__c> plotList=new List<SPEN_Plot__c>();
    SPEN_Plot__c sp;
    for(Integer i=0;i<reccount;i++)
        {
            sp = new SPEN_Plot__c();
            sp.SPEN_PlotNumber__c = 'Plot' + ' ' + i;
            sp.SPEN_BuildingCode__c = 'Test'+i ;
            sp.SPEN_PropertyType__c = '0000000001' ;
            sp.SPEN_BusinessType__c = '01' ;
            sp.SPEN_BusinessTypeOther__c = 'Other' ;
            sp.SPEN_NoofBedrooms__c = '01' ;
            sp.SPEN_EVChargingType__c = '02' ;
            sp.SPEN_EVChargerQuantity__c = 10 ;
            sp.SPEN_EVtoGrid__c = '01' ;
            sp.SPEN_DisturbingLoadSummary__c = 'Load' ;
            sp.SPEN_DisturbinglLoadkw__c = 10 ;
            sp.SPEN_TechnologyType__c = 'Photovoltaic' ;
            sp.SPEN_EnergySource__c = 'Biomass' ;
            sp.SPEN_GenerationRatingkW__c = 10 ;
            sp.SPEN_CombinedHeatandPower__c = '02' ;
            sp.SPEN_StreetName__c = 'Test Street' +i;
            sp.SPEN_TownCity__c = 'Test Town' +i ;
            sp.SPEN_County__c = '53' ;
            sp.SPEN_PostCode__c = 'SS13 1JH' ;
            sp.SPEN_MaxPowerkVA__c = 10 ;
            sp.SPEN_MPClass__c = 'UPUNTSUM' ;
            sp.SPEN_MPProfile__c = 'UPS00002' ;
            sp.SPEN_Phase__c = '02' ;
            sp.SPEN_Earth__c = '04' ;
            sp.SPEN_HeatingMethod__c = '3' ;
            sp.SPEN_HeatingTypeDescription__c = '01' ;
            sp.SPEN_FirstinRange__c = 1 ;
            sp.SPEN_LastinRange__c =  10;
            plotList.add(sp);
        }
        return plotList;
    }

/****************************************************************************************************************************
    * @Author:      Ayush 
    * @Date:        18/07/2023
    * @Description: Method to specifically create Test record for Invoice record 
*****************************************************************************************************************************/
public static List<SPEN_Invoice__c> createInvoices(Id caseId,Integer recCount)
{
    Id thirdPartyDamageRTId = Schema.SObjectType.SPEN_Invoice__c.getRecordTypeInfosByDeveloperName().get('SPEN_ThirdPartyDamage').getRecordTypeId();
    List<SPEN_Invoice__c> testInvoice = new List<SPEN_Invoice__c>();
    SPEN_Invoice__c inv;
    Integer i=0;
    while(i< recCount){
        inv = new SPEN_Invoice__c();
        inv.RecordTypeId = thirdPartyDamageRTId;
        inv.SPEN_Case__c = caseId;
        inv.SPEN_InvoiceNumber__c = 'Test';
        inv.SPEN_InvoiceValue__c = 1000+i;
        inv.SPEN_InvoicedOutcome__c = 'Issued';
        testInvoice.add(inv);
        i++;
    }
    return testInvoice;
}  
/****************************************************************************************************************************
* @Author:      Akshay Pandit
* @Date:        28/07/2023
* @Description: Method to specifically create Test record for Physical Information 
*****************************************************************************************************************************/
public static List<SPEN_PhysicalInformation__c> createPhysInfoRecords (Integer reccount)
{
    List<SPEN_PhysicalInformation__c> phyInfoList=new List<SPEN_PhysicalInformation__c>();
    SPEN_PhysicalInformation__c physInfo;
    for(Integer i=0;i<reccount;i++)
        {
            physInfo = new SPEN_PhysicalInformation__c();
            physInfo.SPEN_ItemClass__c = 'IT-UITEM';
            physInfo.SPEN_ItemID__c = '09'+i+(Integer.valueOf(math.random()*100));
            physInfo.SPEN_ItemProfile__c = 'UIT00003';
            physInfo.SPEN_ItemRequestedDate__c = system.now();
            physInfo.SPEN_ItemRequestRemark__c = 'Test Relocation Drawing';
            phyInfoList.add(physInfo);
        }
        return phyInfoList;
    }
/****************************************************************************************************************************
    * @Author:      Swaathi 
    * @Date:        04/08/2023
    * @Description: Method to specifically create Test record for Responsible Party record 
*****************************************************************************************************************************/  
     public static List<SPEN_ResponsibleParty__c> createRespPartyRecordsForSameCase(Integer recCount)
    {
        List<SPEN_ResponsibleParty__c> respPartyList = new List<SPEN_ResponsibleParty__c>();
        SPEN_ResponsibleParty__c respParty = new SPEN_ResponsibleParty__c();
        Integer i=0;
        while(i < recCount)
        { 
            respParty.SPEN_Type__c = 'Person';
            respParty.First_Name__c = 'Fname';
            respParty.Last_Name__c = 'Lname';
            respPartyList.add(respParty);
            i++;
        }
        return respPartyList;
    }
/****************************************************************************************************************************
    * @Author:      Ayush 
    * @Date:        03/08/2023
    * @Description: Method to specifically create Test record for EmailMessage record 
*****************************************************************************************************************************/
public static List<EmailMessage> createEmailMessageRecords(Integer recCount)
{
    List<EmailMessage> emailMsgList = new List<EmailMessage>();
    EmailMessage emailMsg = new EmailMessage();
    Integer i=0;
    while(i < recCount)
    {
        emailMsg.Subject = 'TEST';
        emailMsg.HtmlBody = 'TEST Email';
        emailMsg.Incoming = true;
        emailMsg.ToAddress = System.Label.SPEN_SPMQueueEmailAddress;
        emailMsgList.add(emailMsg);
        i++;
    }
    return emailMsgList;
} 
/****************************************************************************************************************************
    * @Author:      Akshitha 
    * @Date:        07/08/2023
    * @Description: Method to create case records
*****************************************************************************************************************************/
public static List<Case> createCaseRecords(Integer recCount,Id recordId)
{
    List<Case> caseList = new List<Case>();
    Case cs = new Case();
    Integer i=0;
    while(i < recCount)
    {
        cs.recordtypeId = recordId;
        caseList.add(cs);
        i++;
    }
    return caseList;
}    
    /****************************************************************************************************************************
    * @Author:      Shubhi 
    * @Date:        30/08/2023
    * @Description: Method to create employee records
    *****************************************************************************************************************************/
    public static List<SPEN_Employee__c> createEmployeeRecords(Integer recCount){
        List<SPEN_Employee__c> empList = new List<SPEN_Employee__c>();
        Integer i=0;
        while(i < recCount)
        {
            i++;
            SPEN_Employee__c emp = new SPEN_Employee__c();
            emp.SPEN_EmailAddress__c = 'test'+i+'@test.com';
            empList.add(emp);
        }
        return empList;
    }
    /****************************************************************************************************************************
    * @Author:      Shubhi 
    * @Date:        30/08/2023
    * @Description: Method to create employee records 
    *****************************************************************************************************************************/
    public static SPEN_CaseInformation__c createCaseInformationRecords(Id caseId,Id recordtypeId){
        List<SPEN_CaseInformation__c> ciList = new List<SPEN_CaseInformation__c>();
        SPEN_CaseInformation__c caseinfo = new SPEN_CaseInformation__c();
        caseinfo.SPEN_Case__c = caseId;
        caseinfo.recordtypeId=recordtypeId;
        return caseinfo;
    }

    public static List<SPEN_EmailRoutingConfigurationSW__mdt> getEmailRouting_mdt (){
        
        SPEN_EmailRoutingConfigurationSW__mdt  emailMetadata= new SPEN_EmailRoutingConfigurationSW__mdt ( 
            Label = 'NRSWA North 2hr SLA',
            Matcher_String__c = 'Road Opening Notice;SCOPE;',
            Matcher_String_2__c = 'Coordinates;Notice;Co-ordinates;',
            SPEN_RoutingOutcome__c ='2 Hr SLA North	',
            SPEN_ToAddress__c = '3pdqueriessouth@spenergynetworks.co.uk',
            SPEN_QueueName__c='NRSWA_SPD'
			);
        List<SPEN_EmailRoutingConfigurationSW__mdt> listEmailMetadata=new List<SPEN_EmailRoutingConfigurationSW__mdt>();
        listEmailMetadata.add(emailMetadata);
        return listEmailMetadata;
        
    }

    /**********************************************************************************************
    * @Author:      Rajat Kumar Mishra
    * @Date:        08/11/2023
    * @Description: Method to specifically to insert userRole record.
    ***********************************************************************************************/
    public static UserRole createExternalUserRole(String DeveloperName, String Name){
     	
        UserRole externalRole = new UserRole();
        externalRole.DeveloperName = DeveloperName;
        externalRole.Name = Name;
        insert externalRole;
        return externalRole;
	}
    public static List<EmailMessage> createEmailMessageRecordsCCAddress(Integer recCount,String CCAddress)
    {
        List<EmailMessage> emailMsgList = new List<EmailMessage>();
        EmailMessage emailMsg = new EmailMessage();
        Integer i=0;
        while(i < recCount)
        {
            emailMsg.Subject = 'TEST';
            emailMsg.HtmlBody = 'TEST Email';
            emailMsg.Incoming = true;
            emailMsg.ToAddress = CCAddress;
            emailMsg.ccaddress = CCAddress;
            emailMsgList.add(emailMsg);
            i++;
        }
        return emailMsgList;
    }
    
    public static List<EmailMessage> createEmailMessageRecords(Integer recCount,String email)
    {
        List<EmailMessage> emailMsgList = new List<EmailMessage>();
        EmailMessage emailMsg = new EmailMessage();
        Integer i=0;
        while(i < recCount)
        {
            emailMsg.Subject = 'TEST';
            emailMsg.HtmlBody = 'TEST Email';
            emailMsg.Incoming = true;
            emailMsg.ToAddress = email;
            emailMsgList.add(emailMsg);
            i++;
        }
        return emailMsgList;
    }
    /**********************************************************************************************
    * @Author:      Anindita Guin
    * @Date:        04/03/2024
    * @Description: Method to create Email Message Records for BCC Address
    ***********************************************************************************************/ 
    public static List<EmailMessage> createEmailMessageRecordsBCCAddress(Integer recCount,String BccAddress)
    {
        List<EmailMessage> emailMsgList = new List<EmailMessage>();
        EmailMessage emailMsg = new EmailMessage();
        Integer i=0;
        while(i < recCount)
        {
            emailMsg.Subject = 'TEST';
            emailMsg.HtmlBody = 'TEST Email';
            emailMsg.Incoming = true;
            emailMsg.ToAddress = BccAddress;
	    emailMsg.ccaddress = BccAddress;
            emailMsg.BccAddress = BccAddress;
            emailMsgList.add(emailMsg);
            i++;
        }
        return emailMsgList;
    }
    public static List<case> createGECase(Integer recCount)
    {
        List<case> caseList = new List<case>();
        case cse = new case();
        Integer i=0;
         Id recordTypeIdGE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_GeneralEnquiries').getRecordTypeId();
	
        while(i < recCount)
        {
            Case caseGE = new Case();
            caseGE.status='Created';
            caseGE.origin='Email';
            caseGE.SPEN_Category__c='GE - Trees';
            caseGE.RecordTypeId = recordTypeIdGE;
            caseList.add(caseGE);
            i++;
        }
        return caseList;
    } 
}