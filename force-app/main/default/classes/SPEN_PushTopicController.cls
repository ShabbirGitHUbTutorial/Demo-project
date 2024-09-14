public with sharing class SPEN_PushTopicController {
    @AuraEnabled(Cacheable=true)
    public static List <PushTopic> getPushTopics() {
        return [SELECT Id, Name, Query, ApiVersion, NotifyForOperationCreate, NotifyForOperationUpdate, NotifyForFields FROM PushTopic WITH SECURITY_ENFORCED];// WHERE CreatedDate = TODAY WITH SECURITY_ENFORCED];
    }
}