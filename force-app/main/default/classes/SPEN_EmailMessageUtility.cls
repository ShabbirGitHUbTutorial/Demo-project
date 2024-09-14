public without sharing class SPEN_EmailMessageUtility {
    @TestVisible private static List<SPEN_EmailRoutingConfigurationSW__mdt> EmailSummaryMdt = new List<SPEN_EmailRoutingConfigurationSW__mdt>();   
    @InvocableMethod(label='Update case routing' description='Update case routing')
    public static void emailMessageAssignment(List<EmailMessage> emailMsg){
        Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
        List<Case> cases = SPEN_CaseSelector.getCaseNumber(emailMsg[0].ParentId);
        SPEN_EmailRoutingConfigurationSW__mdt erc=getRoutingOutcome(emailMsg[0]);
        Case oldCaseRec = new Case();
        if(erc!=null)
        {
            oldCaseRec.id = cases[0].id;
            oldCaseRec.SPEN_Email_WI_Queue_Routing_Outcome__c = cases[0].SPEN_Email_WI_Queue_Routing_Outcome__c;
            oldCaseRec.SPEN_SLADueDate__c = cases[0].SPEN_SLADueDate__c;

            cases[0].SPEN_Email_WI_Queue_Routing_Outcome__c=erc.SPEN_RoutingOutcome__c;
            Group queueTobeAssigned = new SPEN_GroupsSelector().selectByQueueName(erc.SPEN_QueueName__c);
            cases[0].ownerid=queueTobeAssigned.id;
            cases[0].SPEN_CaseAssignmentTime__c = system.now();
            //9516 - Start ///9531 null check added
            if(erc.SPEN_RoutingOutcome__c!=NULL && erc.SPEN_RoutingOutcome__c.containsIgnoreCase('72') && (erc.SPEN_ToAddress__c.containsIgnoreCase('additionalstreetworksew')||
                                                                       erc.SPEN_ToAddress__c.containsIgnoreCase('streetworks-e&w-additional-requests') ||
                                                                       erc.SPEN_ToAddress__c.containsIgnoreCase('streetworks-scotland-additional-requests')))
            {
                cases[0].SPEN_JointingComplete__c = 'Not Required';
            }
            //9516 - End
            Set<Id> setCaseId = new Set<Id>();
            setCaseId.add(cases[0].id);
           // System.enqueueJob(new SPEN_JourneySLAQueueable(setCaseId));
           //CRMD -9531 - Start
            if(erc.SPEN_RoutingOutcome__c!=NULL)
            {
            System.enqueueJob(new SPEN_JourneySLAQueueable(setCaseId),1);//CRMD - 9531 1min delay added
            }
            else
            {
                cases[0].SPEN_SLADueDate__c = NULL;
            }
            //CRMD -9531 -end
        }
        
        update cases[0];
        if(cases[0].recordtypeId == recordTypeIdQuery && (cases[0].SPEN_Type__c == 'StreetWorks' || cases[0].SPEN_Type__c == 'NRSWA' || cases[0].SPEN_Type__c == 'Third Party Damage'))
            SPEN_EmailMessageUtility.createCaseTracker(oldCaseRec,cases[0]);
    }
    public static void createCaseTracker(Case oldCaseRec, Case CaseRec){
        List<SPEN_Case_Tracker__c> listTracker = new List<SPEN_Case_Tracker__c>();
        
        //Routing outcome update
        SPEN_Case_Tracker__c ctRec = new SPEN_Case_Tracker__c();
        ctRec.SPEN_PreviousValue__c =  oldCaseRec.SPEN_Email_WI_Queue_Routing_Outcome__c != null ? oldCaseRec.SPEN_Email_WI_Queue_Routing_Outcome__c:null;
        ctRec.SPEN_NewValue__c =  caseRec.SPEN_Email_WI_Queue_Routing_Outcome__c; 
        ctRec.SPEN_StartTime__c = system.now();
        ctRec.SPEN_CaseOwner__c = UserInfo.getUserId();
        ctRec.Case_Tracker_Type__c = 'Case Routing Outcome Update';
        ctRec.SPEN_ParentCase__c = caseRec.id;
        listTracker.add(ctRec);

        //SLA = null entry
        if(oldCaseRec.SPEN_SLADueDate__c != null && caseRec.SPEN_SLADueDate__c == null){
		SPEN_Case_Tracker__c slaCT = new SPEN_Case_Tracker__c();
	        slaCT.SPEN_PreviousValue__c =oldCaseRec.SPEN_SLADueDate__c != null ? oldCaseRec.SPEN_SLADueDate__c.format('dd/MM/yyyy kk:mm'): null;
	        slaCT.SPEN_NewValue__c = caseRec.SPEN_SLADueDate__c != null ? caseRec.SPEN_SLADueDate__c.format('dd/MM/yyyy kk:mm') : null;
	        slaCT.SPEN_StartTime__c = system.now();
	        slaCT.SPEN_CaseOwner__c = UserInfo.getUserId();
	        slaCT.Case_Tracker_Type__c = 'Case SLA Update';
	        slaCT.SPEN_ParentCase__c = caseRec.id;
	        listTracker.add(slaCT);
	}
        if(!listTracker.isEmpty())
            insert listTracker;

    }
    private static SPEN_EmailRoutingConfigurationSW__mdt getRoutingOutcome(EmailMessage eMsgRec){
        SPEN_EmailRoutingConfigurationSW__mdt returRec;
        List<String> toAddressList = new List<String>();//prod
        String toAddressFinal;//prod
        Boolean jointing = false;
        Boolean nrswaAvailable = false;
        Boolean bothSPDSPM = false;
        Boolean nrswaNorthSouth = false;
        List<SPEN_EmailRoutingConfigurationSW__mdt> emailMdt=new List<SPEN_EmailRoutingConfigurationSW__mdt>();
        if(Test.isRunningTest()){
            emailMdt=EmailSummaryMdt;
        }
        else{
            emailMdt=SPEN_EmailRoutingConfigurationSW__mdt.getAll().values();
        }
        //prod - START
        if(eMsgRec.toAddress.contains(';'))
        {
            if(eMsgRec.toAddress.containsIgnoreCase('jointingcompletesouth')){
                toAddressFinal = 'jointingcompletesouth';                
            } else if(eMsgRec.toAddress.containsIgnoreCase('jointingcompletenorth')){
                toAddressFinal = 'jointingcompletenorth';
                
            } else if(eMsgRec.toAddress.containsIgnoreCase('opssthfaults')){
                toAddressFinal = 'opssthfaults';
                
            } else if(eMsgRec.toAddress.containsIgnoreCase('occnrswa')){
                toAddressFinal = 'occnrswa';
                
            } else if((eMsgRec.toAddress.containsIgnoreCase('additionalstreetworksew'))||(eMsgRec.toAddress.containsIgnoreCase('streetworks-e&w-additional-requests'))){
                toAddressFinal = 'additionalstreetworksew';
                
            } else if(eMsgRec.toAddress.containsIgnoreCase('streetworks-scotland-additional-requests')){
                toAddressFinal = 'streetworks-scotland-additional-requests';
            }
          //9513 - Start - CC Address check
            else if(eMsgRec.ccaddress!=NULL)
            {
                if(eMsgRec.ccaddress.containsIgnoreCase('jointingcompletesouth')){
                    toAddressFinal = 'jointingcompletesouth';                
                } else if(eMsgRec.ccaddress.containsIgnoreCase('jointingcompletenorth')){
                    toAddressFinal = 'jointingcompletenorth';
                    
                } else if(eMsgRec.ccaddress.containsIgnoreCase('opssthfaults')){
                    toAddressFinal = 'opssthfaults';
                    
                } else if(eMsgRec.ccaddress.containsIgnoreCase('occnrswa')){
                    toAddressFinal = 'occnrswa';
                    
                } else if((eMsgRec.ccaddress.containsIgnoreCase('additionalstreetworksew'))||(eMsgRec.toAddress.containsIgnoreCase('streetworks-e&w-additional-requests'))){
                    toAddressFinal = 'additionalstreetworksew';
                    
                } else if(eMsgRec.ccaddress.containsIgnoreCase('streetworks-scotland-additional-requests')){
                    toAddressFinal = 'streetworks-scotland-additional-requests';
                }
            }
            
            //9513 - End
           
        }
        else
        {
            if(eMsgRec.toAddress.containsIgnoreCase('jointingcompletesouth')){
                toAddressFinal = 'jointingcompletesouth';                
            } else if(eMsgRec.toAddress.containsIgnoreCase('jointingcompletenorth')){
                toAddressFinal = 'jointingcompletenorth';
                
            } else if(eMsgRec.toAddress.containsIgnoreCase('opssthfaults')){
                toAddressFinal = 'opssthfaults';
                
            } else if(eMsgRec.toAddress.containsIgnoreCase('occnrswa')){
                toAddressFinal = 'occnrswa';
                
            } else if((eMsgRec.toAddress.containsIgnoreCase('additionalstreetworksew'))||(eMsgRec.toAddress.containsIgnoreCase('streetworks-e&w-additional-requests'))){
                toAddressFinal = 'additionalstreetworksew';
                
            } else if(eMsgRec.toAddress.containsIgnoreCase('streetworks-scotland-additional-requests')){
                toAddressFinal = 'streetworks-scotland-additional-requests';
            }
            //9513 - Start - CC Address check
            else if(eMsgRec.ccaddress!=NULL)
            {
                if(eMsgRec.ccaddress.containsIgnoreCase('jointingcompletesouth')){
                    toAddressFinal = 'jointingcompletesouth';                
                } else if(eMsgRec.ccaddress.containsIgnoreCase('jointingcompletenorth')){
                    toAddressFinal = 'jointingcompletenorth';
                    
                } else if(eMsgRec.ccaddress.containsIgnoreCase('opssthfaults')){
                    toAddressFinal = 'opssthfaults';
                    
                } else if(eMsgRec.ccaddress.containsIgnoreCase('occnrswa')){
                    toAddressFinal = 'occnrswa';
                    
                } else if((eMsgRec.ccaddress.containsIgnoreCase('additionalstreetworksew'))||(eMsgRec.toAddress.containsIgnoreCase('streetworks-e&w-additional-requests'))){
                    toAddressFinal = 'additionalstreetworksew';
                    
                } else if(eMsgRec.ccaddress.containsIgnoreCase('streetworks-scotland-additional-requests')){
                    toAddressFinal = 'streetworks-scotland-additional-requests';
                }
                //SFAMS-970
                else{
                    toAddressFinal = eMsgRec.toAddress;
                }
            }
            //9513 - End
            else
            {
            toAddressFinal = eMsgRec.toAddress;
            }
        }
        //prod - END
        for(SPEN_EmailRoutingConfigurationSW__mdt erc:emailMdt){
            List<String> matchingValues=new List<String>();
            
            //prod - START
           // if(erc.Matcher_String__c!=null && eMsgRec.toAddress.contains(erc.SPEN_ToAddress__c)){
            //if(erc.Matcher_String__c!=null && erc.SPEN_ToAddress__c==eMsgRec.toAddress){
                if(erc.Matcher_String__c!=null && erc.SPEN_ToAddress__c.containsIgnoreCase(toAddressFinal)){
                
                //prod - END
                matchingValues.addAll(erc.Matcher_String__c.split(';'));
                if(String.isNotBlank(erc.Matcher_String_2__c)){
                    matchingValues.addAll(erc.Matcher_String_2__c.split(';'));
                }
                for(String s:matchingValues){
                    if(eMsgRec.Subject.containsIgnoreCase(s) && returRec==null){
                        returRec= erc;
                    }else if (eMsgRec.Subject.containsIgnoreCase(s) && returRec!=null && returRec.SPEN_Priority__c>erc.SPEN_Priority__c){
                        returRec= erc;  
                    }
                }
            }
        }
        if(returRec==null){
            for(SPEN_EmailRoutingConfigurationSW__mdt erc:SPEN_EmailRoutingConfigurationSW__mdt.getAll().values()){
                Set<String> matchValues = new Set<String>(); 
                if(String.isBlank(erc.Matcher_String__c) && erc.SPEN_ToAddress__c.containsIgnoreCase(toAddressFinal))
                {
                //if(String.isBlank(erc.Matcher_String__c) && erc.SPEN_ToAddress__c==eMsgRec.toAddress){
                    returRec=erc;
                }
            }
        }
        return returRec;
    }
    
}