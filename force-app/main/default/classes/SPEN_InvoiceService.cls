/*-----------------------------------------------------------------------------
DESCRIPTION :   Service Class for Invoice Trigger
LIBRARY     :   Salesforce Enterprise Library (SEL) - Core
VERSION     :   1.0
Date        :   JULY-17-2023:  
-----------------------------------------------------------------------------*/
public with sharing class SPEN_InvoiceService
{
    public static void afterInvoiceInsert(List<sObject> invoiceNewList)
    {
        List<SPEN_Invoice__c> invList = invoiceNewList;
        Set<Id> caseIds = new Set<Id>();
        Id thirdPartyDamageRTId = Schema.SObjectType.SPEN_Invoice__c.getRecordTypeInfosByDeveloperName().get('SPEN_ThirdPartyDamage').getRecordTypeId();
        Map<Id, Case> casesWithNonCancelledInvoices = New Map<Id, Case>();
        
        for(SPEN_Invoice__c inv : invList) 
        {
            if(inv.RecordTypeId == thirdPartyDamageRTId && inv.SPEN_InvoicedOutcome__c != 'Cancelled')
            {
                caseIds.add(inv.SPEN_Case__c);
            }
        }
        
        if(!caseIds.isEmpty())
        {
            //Quering related case with non cancelled invoices
            casesWithNonCancelledInvoices = SPEN_InvoiceSelector.getInvoicesRelatedToCases(caseIds);

            //Collect the invoices to cancel
            List<SPEN_Invoice__c> invoiceListToCancel = new List<SPEN_Invoice__c>();
            
            //Iterate over new Invoices and associated cases
            if(!casesWithNonCancelledInvoices.isEmpty())
            {
                for(SPEN_Invoice__c inv : invList)
                {
                    Case relCase = casesWithNonCancelledInvoices.get(inv.SPEN_Case__c);
                    if(relCase!=null && !relCase.Invoices__r.isEmpty())
                    {    
                        for(SPEN_Invoice__c relInvoice : relCase.Invoices__r)
                        {
                            if(relInvoice.SPEN_InvoicedOutcome__c != 'Cancelled' && relInvoice.id !=inv.Id)
                            {
                                relInvoice.SPEN_InvoicedOutcome__c = 'Cancelled';
                                invoiceListToCancel.add(relInvoice);
                            }
                        }
                    }
                }
            
                //Cancel the Non-Cancelled Invoices
                if (!invoiceListToCancel.isEmpty())
                {
                    update invoiceListToCancel;
                }
        	}
   		}
	}
}