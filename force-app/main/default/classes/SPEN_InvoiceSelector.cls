public with sharing class SPEN_InvoiceSelector 
{
    public static Map<Id,Case> getInvoicesRelatedToCases(Set<id> caseIds)
    {
        Map<Id,Case> caseWithInvoices = new Map<Id,Case>([SELECT Id, 
                                                        (SELECT Id, SPEN_InvoicedOutcome__c FROM Invoices__r WHERE SPEN_InvoicedOutcome__c IN :SPEN_ConstantData.INVOICE_OUTCOME_LIST)
                										FROM Case
                										WHERE Id IN :caseIds]);
        return caseWithInvoices;
    }
}