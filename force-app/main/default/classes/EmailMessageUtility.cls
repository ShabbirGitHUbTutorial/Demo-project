/*-----------------------------------------------------------------------------
DESCRIPTION :   Handler for EmailMessage Trigger
AUTHOR      :   Amrita Sarkar
LIBRARY     :   Salesforce Enterprise Library (SEL) - Core
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
Nov-13-2023     Amrita Sarkar         Initial version
-----------------------------------------------------------------------------*/
public class EmailMessageUtility {
    public static void afterCaseInsert(List<EmailMessage> newCreatedEmailList){
        Set<Id> caseIds = new Set<Id>();
        Set<String> recordTypeSet = new Set<String>{'SPEN_FormalConnectionEnquiry','SPEN_BudgetConnectionEnquiry','SPEN_ConnectionReadOnlyCase',
            'SPEN_CaseTransmission','SPEN_CasePreApplication','SPEN_GeneralEnquiries'};
            for(EmailMessage emailRec : newCreatedEmailList)
        {
            caseIds.add(emailRec.ParentID);
        }
        Map<id,Case> caseMap = new Map<id,Case>([SELECT iD,RecordType.DeveloperName FROM Case WHERE 
                                                 RecordType.DeveloperName IN : recordTypeSet and id IN :caseIds ]);
        for(EmailMessage emailNewRec : newCreatedEmailList)
        {
            if(emailNewRec.Incoming != true && caseMap.containsKey(emailNewRec.ParentId) && emailNewRec.ValidatedFromAddress == UserInfo.getUserEmail()){
                emailNewRec.addError('You cannot use personal email');
            }     
        }
    }
 
}