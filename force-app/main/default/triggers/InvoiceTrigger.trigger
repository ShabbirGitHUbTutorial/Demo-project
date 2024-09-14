trigger InvoiceTrigger on SPEN_Invoice__c (after insert) 
{
    if(Trigger.isAfter && Trigger.isInsert)
    {
        SPEN_InvoiceService.afterInvoiceInsert(Trigger.new);
    }
}