public class SPEN_EmailMessage {
    
    public static void calculateAgentResponeTime(List<sObject> emailMessageNewList){
        List<EmailMessage> emailMessageList =(List<EmailMessage>)emailMessageNewList;
        List<EmailMessage> emailMsgListUpdate = new List<EmailMessage>();
        Map<Id, EmailMessage> mapParentMsgId2Msg = new Map<Id,EmailMessage>();
        Map<Id,List<EmailMessage>> mapCaseId2EmailMessage= new   Map<Id,List<EmailMessage>>();
        Set<Id> setReplyMsgId = new Set<Id>();
        Set<Id> setCaseId = new Set<Id>();
         Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();

        for(EmailMessage emailmsg :emailMessageList){
            
            if(emailmsg.Incoming==false && emailmsg.ReplyToEmailMessageId!=null && emailmsg.ParentId!= null) {
               setReplyMsgId.add(emailmsg.ReplyToEmailMessageId);
               setCaseId.add(emailmsg.ParentId);
            }
        }
        if(!setReplyMsgId.isEmpty())
        {
            mapParentMsgId2Msg = SPEN_EmailMessageSelector.getParentEmailMsg(setReplyMsgId);
            Map<Id,Case> caseMap = new Map<Id,Case>(SPEN_CaseSelector.getUncheckedSendToPowerOnCaseList(setCaseId));
            mapCaseId2EmailMessage = SPEN_EmailMessageSelector.getAllIncoming(setCaseId);
             List<EmailMessage> allIncoming;
            if(!mapParentMsgId2Msg.isempty())
            {
                for(EmailMessage emailmsg :emailMessageList){
                    if(caseMap.get(emailmsg.parentId).recordtypeid == recordTypeIdQuery &&
                     mapParentMsgId2Msg.containsKey(emailmsg.ReplyToEmailMessageId))
                    {
                        if(Trigger.isInsert){
            				if(Trigger.isBefore){
                                EmailMessage parentMsg = mapParentMsgId2Msg.get(emailmsg.ReplyToEmailMessageId);
                                 //if Parent Email is outgoing
                                if(parentMsg.Incoming ==false)
                                     emailmsg.SPEN_AgentResponseTime__c = parentMsg.SPEN_AgentResponseTime__c;
                                    
                                if(!mapCaseId2EmailMessage.isEmpty())
                                {
   									allIncoming = mapCaseId2EmailMessage.get(emailmsg.parentId);
                                     Date dt1 = System.today();
                                    //Date dt2 = Date.valueOf(parentMsg.createdDate);
                                    Date dt2 = Date.valueOf(allIncoming[0].createdDate);
                                    emailmsg.SPEN_AgentResponseTime__c = dt2.daysBetween(dt1);
                                }
                            }
                            if(Trigger.isAfter){
                                Date dt1 = System.today();
                                if(!mapCaseId2EmailMessage.isEmpty()){
                                    allIncoming = mapCaseId2EmailMessage.get(emailmsg.parentId);
                                    for(EmailMessage incomingEmail: allIncoming)
                                    {
                                        Date createdDate = Date.valueOf(incomingEmail.createdDate);
                                        incomingEmail.SPEN_AgentResponseTime__c = createdDate.daysBetween(dt1);
                                    }
                                    emailMsgListUpdate.addAll(allIncoming);
                                }
                                
                            }
                         }
					}
                }
            }
        }
        if(!emailMsgListUpdate.isEmpty())
        	update emailMsgListUpdate;
    }

    public static void changeStatusToOpenForIncomingMail(List<sObject> emailMessageNewList, List<sObject> emailMessageOldList)
    {
        List<EmailMessage> emailMessageList = (List<EmailMessage>)emailMessageNewList;
		
        List<Case> caseListToUpdate = new List<Case>();
        Set<Id> cseIds = New Set<Id>();
        
        Map<String, Id> queueDeveloperNameIdMap = new Map<String, Id>();
        Map<String, String> mailAndQueueNameMap = new Map<String, String>();
        Set<String> queueNameSet = new Set<String>();
        queueNameSet.add('SPEN_ThirdPartyDamageCasesSPD');
        queueNameSet.add('SPEN_Third_Party_Damage_Cases_SPM');
        queueNameSet.add('SPEN_North_Additionals');
        queueNameSet.add('SPEN_North_Additionals_2_Hour_Response');
        //queueNameSet.add('SPEN_North_Jointing_Complete');
        queueNameSet.add('SPEN_South_2_hour');
        queueNameSet.add('SPEN_South_Additionals');
        //queueNameSet.add('SPEN_South_Jointing_Complete');
        queueNameSet.add('NRSWA_SPD');
        queueNameSet.add('NRSWA_SPM');
        queueNameSet.add('SPEN_South_Jointing_Complete');
        queueNameSet.add('SPEN_North_Jointing_Complete');
        Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
        List<Group> queueList = [Select Id,DeveloperNAME from Group where Type = 'Queue' AND DeveloperNAME IN: queueNameSet];
        for(Group grp : queueList)
        {
            queueDeveloperNameIdMap.put(grp.DeveloperNAME, grp.Id);
        }
        String spdAddress = System.Label.SPEN_SPDQueueEmailAddress;
        String spmAddress = System.Label.SPEN_SPMQueueEmailAddress;
        String spmcrmAddress = System.Label.SPEN_SPMQueueCRMEmailAddress;
        String swspdAddressjoint = System.Label.SPEN_StreetworksJointingNorthAddress;
        String swspdAddressadd= System.Label.SPEN_SWNorthAddress;
        String swspmAddress = System.Label.SPEN_StreerworksAdditionalRequestSouthAddress;
        String swspmAddressjoint= System.Label.SPEN_StreetworksJointingSouthAddress;

        String nrswaspdAddress = System.Label.SPEN_NRSWANorthAddress; 
        String nrswaspmAddress = System.Label.SPEN_NRSWASouthAddress;
        /*-------------------------------------------------------------------------------*/
        String swspdjointingcrm = System.Label.SPEN_SWSPDJointingCRM;
        String swspdadditionalcrm = System.Label.SPEN_SWNorthAddressCRM;
        String swspmjointingcrm =  System.Label.SPEN_SWSPMJointingCRM;
        String swAdditionalRequest=System.Label.SPEN_StreerworksAdditionalRequestSouth;
        String swspmadditionalcrm = System.Label.SPEN_SWSouthhAddressCRM;
        
        /*---------------------------------SFAMS-892-------------------------------------------*/
		String thirdPartySouth = System.Label.SPEN_3PDSouthEmail;
		String occThirdParty = System.Label.SPEN_OCCThirdPartyEmail;
		mailAndQueueNameMap.put(occThirdParty, 'SPEN_ThirdPartyDamageCasesSPD');
        mailAndQueueNameMap.put(thirdPartySouth, 'SPEN_Third_Party_Damage_Cases_SPM');        
        /*---------------------------------SFAMS-892-------------------------------------------*/

        mailAndQueueNameMap.put(spdAddress, 'SPEN_ThirdPartyDamageCasesSPD');
        mailAndQueueNameMap.put(spmAddress, 'SPEN_Third_Party_Damage_Cases_SPM');
        mailAndQueueNameMap.put(swspdAddressadd, 'SPEN_North_Additionals');
        //mailAndQueueNameMap.put(swspdadditionalcrm, 'SPEN_North_Additionals');
        //mailAndQueueNameMap.put(swspdAddressadd, 'SPEN_North_2_hour');
        mailAndQueueNameMap.put(swspdAddressjoint, 'SPEN_North_Jointing_Complete');
        //mailAndQueueNameMap.put(swspdjointingcrm, 'SPEN_North_Jointing_Complete');
        //mailAndQueueNameMap.put(swspmAddress, 'SPEN_South_2_hour');
        mailAndQueueNameMap.put(swspmAddress, 'SPEN_South_Additionals');
        mailAndQueueNameMap.put(swspmAddressjoint, 'SPEN_South_Jointing_Complete');
        //mailAndQueueNameMap.put(nrswaspmAddress, 'NRSWA_Jointing_Complete_SPM');
        //mailAndQueueNameMap.put(nrswaspdAddress, 'NRSWA_Jointing_Complete_SPD');
        mailAndQueueNameMap.put(nrswaspdAddress, 'NRSWA_SPD');
        mailAndQueueNameMap.put(nrswaspmAddress, 'NRSWA_SPM');
        
      
        for(EmailMessage emailmsg :emailMessageList)
        {
            if(emailmsg != null && emailmsg.ParentId != null)
            {
                cseIds.add(emailmsg.ParentId);
            }
        }
        Map<Id,Case> caseMap = New Map<Id,Case>([Select Id,RecordTypeId,Status,SPEN_Type__c,OwnerId, SPEN_Email_WI_Queue_Routing_Outcome__c,SPEN_JointingComplete__c from Case WHERE Id IN:cseIds]);
        List<EmailMessage> emailMsgList = new List<EmailMessage>(); //CRMD - 9531
        if(!caseMap.isEmpty())
        {
            for(EmailMessage emailmsg :emailMessageList)
            {   
                if(emailmsg.ParentId != null &&  (emailmsg.ToAddress.containsIgnoreCase(nrswaspdAddress)||
                emailmsg.ToAddress.containsIgnoreCase(nrswaspmAddress)||emailmsg.ToAddress.containsIgnoreCase(spdAddress) || 
                emailmsg.ToAddress.containsIgnoreCase(spmAddress) || emailmsg.ToAddress.containsIgnoreCase(spmcrmAddress) ||
                emailmsg.ToAddress.containsIgnoreCase(swspdAddressjoint) || 
                emailmsg.ToAddress.containsIgnoreCase(swspdAddressadd) || emailmsg.ToAddress.containsIgnoreCase(swspmAddress) ||
                emailmsg.ToAddress.containsIgnoreCase(swspmAddressjoint) ||
                emailmsg.ToAddress.containsIgnoreCase(swAdditionalRequest) ||   emailmsg.ToAddress.containsIgnoreCase(swspdjointingcrm) ||
                emailmsg.ToAddress.containsIgnoreCase(swspdadditionalcrm) ||   emailmsg.ToAddress.containsIgnoreCase(swspmjointingcrm) ||
                emailmsg.ToAddress.containsIgnoreCase(swspmadditionalcrm) || emailmsg.ToAddress.containsIgnoreCase(thirdPartySouth) ||
                emailmsg.ToAddress.containsIgnoreCase(occThirdParty)))//SFAMS-892
                     
                {
                    Case cse = caseMap.get(emailmsg.ParentId);
					cse.Reassignment_Reason__c = 'Automation';
                    emailMsgList.add(emailmsg);//CRMD - 9531 

                    
                    if(emailmsg.ToAddress.containsIgnoreCase(spdAddress) ||emailmsg.ToAddress.containsIgnoreCase(spmAddress)||
                       emailmsg.ToAddress.containsIgnoreCase(spmcrmAddress) || emailmsg.ToAddress.containsIgnoreCase(thirdPartySouth) ||
                		emailmsg.ToAddress.containsIgnoreCase(occThirdParty) || 
                       ( emailmsg.ccaddress != Null && (emailmsg.ccaddress.containsIgnoreCase(spdAddress)
                      || emailmsg.ccaddress.containsIgnoreCase(spmAddress)||emailmsg.ccaddress.containsIgnoreCase(spmcrmAddress) || emailmsg.ccaddress.containsIgnoreCase(thirdPartySouth) ||
                		emailmsg.ccaddress.containsIgnoreCase(occThirdParty))) ||
                      (emailmsg.BccAddress != Null && (emailmsg.BccAddress.containsIgnoreCase(spdAddress) ||emailmsg.BccAddress.containsIgnoreCase(spmAddress)||
                       emailmsg.BccAddress=='3pdsouth@spenergynetworkscrm.co.uk' || emailmsg.BccAddress.containsIgnoreCase(thirdPartySouth) ||
                		emailmsg.BccAddress.containsIgnoreCase(occThirdParty))))
                       {
                        cse.SPEN_Type__c = 'Third Party Damage';
                       }
                    
                    
                    
                    if(cse.Status =='Closed' && !mailAndQueueNameMap.isEmpty() && !queueDeveloperNameIdMap.isEmpty() &&
                    (cse.SPEN_Type__c == 'Third Party Damage'|| cse.SPEN_Type__c == 'StreetWorks'||cse.SPEN_Type__c == 'NRSWA') && cse.RecordTypeId == recordTypeIdQuery )
                    {
                        cse.Status = 'Open';
                         cse.SPEN_QueryReopenedDate__c = system.now();
                        
                        // /commented - > CRMD - 9531
                        if((emailmsg.ToAddress.containsIgnoreCase(spdAddress) || emailmsg.ToAddress.containsIgnoreCase(occThirdParty)) && !mailAndQueueNameMap.isEmpty() && !queueDeveloperNameIdMap.isEmpty()) 
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(spdAddress));
                        }
                        else if((emailmsg.ToAddress.containsIgnoreCase(spmAddress)||emailmsg.ToAddress.containsIgnoreCase(spmcrmAddress) || emailmsg.ToAddress.containsIgnoreCase(thirdPartySouth)) && !mailAndQueueNameMap.isEmpty() && !queueDeveloperNameIdMap.isEmpty())
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(spmAddress));
                        }
                        // commented - > CRMD - 9531
                        //SW SPD
                        /*else if(emailmsg.ToAddress.containsIgnoreCase(swspdAddressjoint) || emailmsg.ToAddress.containsIgnoreCase(swspdjointingcrm)) 
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(swspdAddressjoint));
                        }
                        else if((emailmsg.ToAddress.containsIgnoreCase(swspdAddressadd) || emailmsg.ToAddress.containsIgnoreCase(swspdadditionalcrm)) && !cse.SPEN_Email_WI_Queue_Routing_Outcome__c.equalsIgnoreCase('30 Min SLA North'))
                        {
                            //9516 - Start
                            if(cse.SPEN_JointingComplete__c == 'Not Required')
                            {
                                cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(swspdAddressjoint));
                            }
                            else
                            {
                            //9516 - end
                            cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(swspdAddressadd));
                            }
                        }
                        else if((emailmsg.ToAddress.containsIgnoreCase(swspdAddressadd) || emailmsg.ToAddress.containsIgnoreCase(swspdadditionalcrm)) && cse.SPEN_Email_WI_Queue_Routing_Outcome__c.equalsIgnoreCase('30 Min SLA North'))
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get('SPEN_North_Additionals_2_Hour_Response');
                        }
                        //SW SPM
                        else if(emailmsg.ToAddress.containsIgnoreCase(swspmAddressjoint) || emailmsg.ToAddress.containsIgnoreCase(swspmjointingcrm))
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(swspmAddressjoint));
                        }
                        else if((emailmsg.ToAddress.containsIgnoreCase(swspmAddress) || emailmsg.ToAddress==swAdditionalRequest || emailmsg.ToAddress.containsIgnoreCase(swspmadditionalcrm)) 
                        && !cse.SPEN_Email_WI_Queue_Routing_Outcome__c.equalsIgnoreCase('30 Min SLA South'))
                        {
                            //9516 - Start
                           if(cse.SPEN_JointingComplete__c == 'Not Required')
                           {
                               cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(swspmAddressjoint));
                           }
                           else
                           {
                           //9516 - end
                            cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(swspmAddress));
                           }
                        }
                        else if((emailmsg.ToAddress.containsIgnoreCase(swspmAddress) || emailmsg.ToAddress==swAdditionalRequest || emailmsg.ToAddress.containsIgnoreCase(swspmadditionalcrm)) 
                         && cse.SPEN_Email_WI_Queue_Routing_Outcome__c.equalsIgnoreCase('30 Min SLA South'))
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get('SPEN_South_2_hour');
                        }
                        //NRSWA 4 Hr SLA North-Lowest	
                        else if(emailmsg.ToAddress.containsIgnoreCase(nrswaspdAddress) && !cse.SPEN_Email_WI_Queue_Routing_Outcome__c.equalsIgnoreCase('4 Hr SLA North-Lowest'))
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(nrswaspdAddress));
                        }
                        else if(emailmsg.ToAddress.containsIgnoreCase(nrswaspdAddress) && cse.SPEN_Email_WI_Queue_Routing_Outcome__c.equalsIgnoreCase('4 Hr SLA North-Lowest'))
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get('SPEN_North_Jointing_Complete');
                        }
                         else if(emailmsg.ToAddress.containsIgnoreCase(nrswaspmAddress) && !cse.SPEN_Email_WI_Queue_Routing_Outcome__c.equalsIgnoreCase('4 Hr SLA South-Lowest'))
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(nrswaspmAddress));
                        }
                        else if(emailmsg.ToAddress.containsIgnoreCase(nrswaspmAddress) && cse.SPEN_Email_WI_Queue_Routing_Outcome__c.equalsIgnoreCase('4 Hr SLA South-Lowest'))
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get('SPEN_South_Jointing_Complete');
                        }*/
                       
                    }
                    caseListToUpdate.add(cse);
                }
                 //cc address CRMD-9513 Start
                else if(emailmsg.ParentId != null && emailmsg.ccaddress != Null &&
                (emailmsg.ccaddress.containsIgnoreCase(nrswaspdAddress) ||
                emailmsg.ccaddress.containsIgnoreCase(nrswaspmAddress) || emailmsg.ccaddress.containsIgnoreCase(spdAddress) || 
                emailmsg.ccaddress.containsIgnoreCase(spmAddress) || emailmsg.ccaddress.containsIgnoreCase(spmcrmAddress) ||
                emailmsg.ccaddress.containsIgnoreCase(swspdAddressjoint) || 
                emailmsg.ccaddress.containsIgnoreCase(swspdAddressadd) || emailmsg.ccaddress.containsIgnoreCase(swspmAddress) ||
                emailmsg.ccaddress.containsIgnoreCase(swspmAddressjoint) ||
                emailmsg.ccaddress.containsIgnoreCase(swAdditionalRequest) || emailmsg.ccaddress.containsIgnoreCase(swspdjointingcrm) ||
                emailmsg.ccaddress.containsIgnoreCase(swspdadditionalcrm) || emailmsg.ccaddress.containsIgnoreCase(swspmjointingcrm) ||
                emailmsg.ccaddress.containsIgnoreCase(swspmadditionalcrm) || emailmsg.ccAddress.containsIgnoreCase(thirdPartySouth) ||
                emailmsg.ccAddress.containsIgnoreCase(occThirdParty)))//SFAMS-892
                {
                    Case cse = caseMap.get(emailmsg.ParentId);
					cse.Reassignment_Reason__c = 'Automation';
                    emailMsgList.add(emailmsg);//9531 //final - 9531
                    if(cse.Status =='Closed' && !mailAndQueueNameMap.isEmpty() && !queueDeveloperNameIdMap.isEmpty() &&
                    (cse.SPEN_Type__c == 'Third Party Damage'|| cse.SPEN_Type__c == 'StreetWorks'||cse.SPEN_Type__c == 'NRSWA') && cse.RecordTypeId == recordTypeIdQuery )
                    {
                        cse.Status = 'Open';
                         cse.SPEN_QueryReopenedDate__c = system.now();
                      
                        if((emailmsg.ccaddress.containsIgnoreCase(spdAddress) || emailmsg.ccaddress.containsIgnoreCase(occThirdParty)) && !mailAndQueueNameMap.isEmpty() && !queueDeveloperNameIdMap.isEmpty()) 
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(spdAddress));
                        }
                        else if((emailmsg.ccaddress.containsIgnoreCase(spmAddress)||emailmsg.ccaddress.containsIgnoreCase(spmcrmAddress) || emailmsg.ccaddress.containsIgnoreCase(thirdPartySouth)) && !mailAndQueueNameMap.isEmpty() && !queueDeveloperNameIdMap.isEmpty())
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(spmAddress));
                        }
                         //commented for CRMD-9531
                        //SW SPD
                        /*else if(emailmsg.ccaddress.containsIgnoreCase(swspdAddressjoint) || emailmsg.ccaddress.containsIgnoreCase(swspdjointingcrm)) 
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(swspdAddressjoint));
                        }
                        else if((emailmsg.ccaddress.containsIgnoreCase(swspdAddressadd) || emailmsg.ccaddress.containsIgnoreCase(swspdadditionalcrm)) && !cse.SPEN_Email_WI_Queue_Routing_Outcome__c.equalsIgnoreCase('30 Min SLA North'))
                        {
                            //9516 - Start
                            if(cse.SPEN_JointingComplete__c == 'Not Required')
                            {
                                cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(swspdAddressjoint));
                            }
                            else
                            {
                            //9516 - end
                            cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(swspdAddressadd));
                            }
                        }
                        else if((emailmsg.ccaddress.containsIgnoreCase(swspdAddressadd) || emailmsg.ccaddress.containsIgnoreCase(swspdadditionalcrm)) && cse.SPEN_Email_WI_Queue_Routing_Outcome__c.equalsIgnoreCase('30 Min SLA North'))
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get('SPEN_North_Additionals_2_Hour_Response');
                        }
                        //SW SPM
                        else if(emailmsg.ccaddress.containsIgnoreCase(swspmAddressjoint) || emailmsg.ccaddress.containsIgnoreCase(swspmjointingcrm))
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(swspmAddressjoint));
                        }
                        else if((emailmsg.ccaddress.containsIgnoreCase(swspmAddress) || emailmsg.ccaddress==swAdditionalRequest || emailmsg.ccaddress.containsIgnoreCase(swspmadditionalcrm)) 
                        && !cse.SPEN_Email_WI_Queue_Routing_Outcome__c.equalsIgnoreCase('30 Min SLA South'))
                        {
                            //9516 - Start
                           if(cse.SPEN_JointingComplete__c == 'Not Required')
                           {
                               cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(swspmAddressjoint));
                           }
                           else
                           {
                           //9516 - end
                            cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(swspmAddress));
                           }
                        }
                        else if((emailmsg.ccaddress.containsIgnoreCase(swspmAddress) || emailmsg.ccaddress==swAdditionalRequest || emailmsg.ccaddress.containsIgnoreCase(swspmadditionalcrm)) 
                         && cse.SPEN_Email_WI_Queue_Routing_Outcome__c.equalsIgnoreCase('30 Min SLA South'))
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get('SPEN_South_2_hour');
                        }
                        //NRSWA 4 Hr SLA North-Lowest	
                        else if(emailmsg.ccaddress.containsIgnoreCase(nrswaspdAddress) && !cse.SPEN_Email_WI_Queue_Routing_Outcome__c.equalsIgnoreCase('4 Hr SLA North-Lowest'))
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(nrswaspdAddress));
                        }
                        else if(emailmsg.ccaddress.containsIgnoreCase(nrswaspdAddress) && cse.SPEN_Email_WI_Queue_Routing_Outcome__c.equalsIgnoreCase('4 Hr SLA North-Lowest'))
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get('SPEN_North_Jointing_Complete');
                        }
                         else if(emailmsg.ccaddress.containsIgnoreCase(nrswaspmAddress) && !cse.SPEN_Email_WI_Queue_Routing_Outcome__c.equalsIgnoreCase('4 Hr SLA South-Lowest'))
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(nrswaspmAddress));
                        }
                        else if(emailmsg.ccaddress.containsIgnoreCase(nrswaspmAddress) && cse.SPEN_Email_WI_Queue_Routing_Outcome__c.equalsIgnoreCase('4 Hr SLA South-Lowest'))
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get('SPEN_South_Jointing_Complete');
                        }*/
                        //CRMD-9513 end
                        caseListToUpdate.add(cse);
                }
                }
                 //Bcc address SFAMS-639 Start
                else if(emailmsg.ParentId != null && emailmsg.BccAddress != Null && 
                (emailmsg.BccAddress.containsIgnoreCase(nrswaspdAddress) ||
                emailmsg.BccAddress.containsIgnoreCase(nrswaspmAddress) || emailmsg.BccAddress.containsIgnoreCase(spdAddress) || 
                emailmsg.BccAddress.containsIgnoreCase(spmAddress) || emailmsg.BccAddress.containsIgnoreCase(swspdAddressjoint) || 
                emailmsg.BccAddress.containsIgnoreCase(swspdAddressadd) || emailmsg.BccAddress.containsIgnoreCase(swspmAddress) ||
                emailmsg.BccAddress.containsIgnoreCase(swspmAddressjoint) ||
                emailmsg.BccAddress.containsIgnoreCase(swAdditionalRequest) || emailmsg.BccAddress.containsIgnoreCase(swspdjointingcrm) ||
                emailmsg.BccAddress.containsIgnoreCase(swspdadditionalcrm) ||   emailmsg.BccAddress.containsIgnoreCase(swspmjointingcrm) ||
                emailmsg.BccAddress.containsIgnoreCase(swspmadditionalcrm) || emailmsg.BccAddress.containsIgnoreCase(thirdPartySouth) ||
                emailmsg.BccAddress.containsIgnoreCase(occThirdParty)))//SFAMS-892
                {
                    Case cse = caseMap.get(emailmsg.ParentId);
					cse.Reassignment_Reason__c = 'Automation';
                    if(cse.Status =='Closed' && !mailAndQueueNameMap.isEmpty() && !queueDeveloperNameIdMap.isEmpty() &&
                    (cse.SPEN_Type__c == 'Third Party Damage'|| cse.SPEN_Type__c == 'StreetWorks'||cse.SPEN_Type__c == 'NRSWA') && cse.RecordTypeId == recordTypeIdQuery )
                    {
                        cse.Status = 'Open';
                         cse.SPEN_QueryReopenedDate__c = system.now();
                       
                        if((emailmsg.BccAddress.containsIgnoreCase(spdAddress) || emailmsg.BccAddress.containsIgnoreCase(occThirdParty)) && !mailAndQueueNameMap.isEmpty() && !queueDeveloperNameIdMap.isEmpty()) 
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(spdAddress));
                        }
                        else if((emailmsg.BccAddress.containsIgnoreCase(spmAddress)||emailmsg.BccAddress=='3pdsouth@spenergynetworkscrm.co.uk' || emailmsg.BccAddress.containsIgnoreCase(thirdPartySouth)) && !mailAndQueueNameMap.isEmpty() && !queueDeveloperNameIdMap.isEmpty())
                        {
                            cse.OwnerId = queueDeveloperNameIdMap.get(mailAndQueueNameMap.get(spmAddress));
                        }

                        caseListToUpdate.add(cse);
                }
                }
            }
            if(!caseListToUpdate.isEmpty())
            {

                update caseListToUpdate;
                SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList);//final - 9531
              
            }
        }
    }
}