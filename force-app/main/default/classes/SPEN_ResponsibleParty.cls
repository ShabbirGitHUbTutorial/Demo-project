/*************************************************************************
@Author: Swaathi KR
@Date: 04/08/23
@User Story: CRMD-7367
@purpose: Before Insert - first 'Responsible party' the primary checkbox defaults to true.
Subsequent responsible parties, default to false.
*************************************************************************************/
public class SPEN_ResponsibleParty {
public static void defaultPrimaryResponsibleParty(List<sObject> respPartyList)
{
    List<SPEN_ResponsibleParty__c> respPartyNewList = (List<SPEN_ResponsibleParty__c>)respPartyList;
    Set<Id> caseIdSet = new Set<ID>();
    for(SPEN_ResponsibleParty__c respParty : respPartyNewList)
    {
		caseIdSet.add(respParty.SPEN_Case__c);
    }
    Map<Id,Case> casesWithRespMap = new Map<Id,Case>([Select Id,(Select Id,SPEN_Primary__c from SPEN_CaseResponsibilityParty__r),RecordType.DeveloperName from Case where Id IN:caseIdSet]);
    for(SPEN_ResponsibleParty__c newResp : respPartyNewList)
    {
        if(casesWithRespMap.containskey(newResp.SPEN_Case__c) && casesWithRespMap.get(newResp.SPEN_Case__c).RecordType.DeveloperName == 'SPEN_ThirdPartyDamage')
        {
            Case cs = casesWithRespMap.get(newResp.SPEN_Case__c);
            if(cs.SPEN_CaseResponsibilityParty__r.isEmpty())
            {
                newResp.SPEN_Primary__c = true;
            }
            else
            {
                newResp.SPEN_Primary__c = false;

            }
        }
    }
}
}