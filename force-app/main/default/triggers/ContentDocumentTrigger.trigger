trigger ContentDocumentTrigger on ContentDocument (before delete) {
    
    SPEN_ContentDocuments contentDocs = new SPEN_ContentDocuments();
	if(Trigger.isDelete && Trigger.isBefore){
        contentDocs.beforeDeleteContents(Trigger.old);       
    }
}