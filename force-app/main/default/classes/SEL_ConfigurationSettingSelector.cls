/*-----------------------------------------------------------------------------
DESCRIPTION :   Selector class of the Configurable setting Queries.
LIBRARY     :   Salesforce Enterprise Library - Configurable setting Queries
VERSION     :   1.0

HISTORY     :
Date            Author                      Comment
14-Oct-2022     Bhagyashree Mandlik         Initial version
-----------------------------------------------------------------------------*/
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class SEL_ConfigurationSettingSelector {
    public static SPEN_ConfigurableSettings__c getETRConfig(String outcome){
        SPEN_ConfigurableSettings__c config = new SPEN_ConfigurableSettings__c();
        if(outcome != null){
            config = [SELECT  Id, Name,SPEN_Value__c 
                      FROM SPEN_ConfigurableSettings__c
                      WHERE Name =: outcome ];
        }
        return config;     
    }
    
    /**************************************************
@Author: Smita Raikar
@Date: 05th DEC 22
@purpose: Method to get Config setings record
***************************************************/
    public static SPEN_ConfigurableSettings__c getconfigSetting() 
    {
        SPEN_ConfigurableSettings__c settingRec= new SPEN_ConfigurableSettings__c();
        if(SPEN_ConstantData.IncidentMessage != null){
            settingRec=[SELECT Id,Name,SPEN_Value__c,SPEN_Description__c 
                        FROM SPEN_ConfigurableSettings__c
                        WHERE Name=:SPEN_ConstantData.IncidentMessage ];
        }
        return settingRec;
    }
     /**************************************************
    @Author: Smita Raikar
    @Date: 06th SEP 23
    @purpose: Method to get Config setings record for HV incident message
    ***************************************************/
    public static SPEN_ConfigurableSettings__c getHVconfigSetting() 
    {
    	SPEN_ConfigurableSettings__c settingRec= new SPEN_ConfigurableSettings__c();
        if(SPEN_ConstantData.HVESOIncidentMessage != null)
        	settingRec=[SELECT Id,Name,SPEN_Value__c,SPEN_Description__c FROM SPEN_ConfigurableSettings__c where Name=:SPEN_ConstantData.HVESOIncidentMessage];
        return settingRec;
    }
    public static Map<string,SPEN_ConfigurableSettings__c> getSMSConfig(string outcome){
        outcome = outcome +'%';
        Map<string,SPEN_ConfigurableSettings__c> config = new Map<string,SPEN_ConfigurableSettings__c>();
        if(outcome != null){
            for(SPEN_ConfigurableSettings__c conf :[SELECT SPEN_Feature__c,SPEN_Value__c 
                                                    FROM SPEN_ConfigurableSettings__c 
                                                    WHERE Name like :outcome ]){
                                                        config.put(conf.SPEN_Feature__c,conf);
                                                    }
        }
        return config;     
    }
    /*****************************************************************************
@Author: Sheker Kulkacherla
@Date: 10th July 2023
@purpose: Method to get the Configurable setings record - MessagingTaskType
******************************************************************************/
    public static SPEN_ConfigurableSettings__c getMsgTaskType() 
    {
        SPEN_ConfigurableSettings__c configMsgTaskType;
        configMsgTaskType=[SELECT Id,Name,SPEN_Value__c,SPEN_Description__c 
                           FROM SPEN_ConfigurableSettings__c
                           WHERE Name = 'MessagingTaskType'];
        return configMsgTaskType;
    }
    /*****************************************************************************
@Author: Sheker Kulkacherla
@Date: 10th July 2023
@purpose: Method to get the Configurable setings record - CreationBatchDelay
******************************************************************************/
    public static SPEN_ConfigurableSettings__c getBatchDelay() 
    {
        SPEN_ConfigurableSettings__c configBatchDelay;
        configBatchDelay = [SELECT Id,Name,SPEN_Value__c,SPEN_Description__c 
                            FROM SPEN_ConfigurableSettings__c
                            WHERE Name = 'CreationBatchDelay'  LIMIT 1];
        return configBatchDelay;
    }
}