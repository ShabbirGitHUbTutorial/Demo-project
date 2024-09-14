trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert, before delete) {
    SPEN_ContentDocumentLinks ContentDocumentLinks = new SPEN_ContentDocumentLinks();
	if(Trigger.isInsert && Trigger.isAfter){
        ContentDocumentLinks.onAfterInsert(Trigger.new); 
        ContentDocumentLinks.beforeContentLinkInsert(Trigger.new);       
      }
  if(Trigger.isDelete && Trigger.isBefore){
        ContentDocumentLinks.beforeDeleteContentLinks(Trigger.old);       
    }
}