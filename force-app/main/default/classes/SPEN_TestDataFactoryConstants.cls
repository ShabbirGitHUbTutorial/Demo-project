/*-----------------------------------------------------------------------------
DESCRIPTION :   Test Data Constant Class for constants, static, hard-coded and non-dynamic variables 
AUTHOR      :   Dhara Desai
LIBRARY     :   Salesforce Enterprise Library (SEL) - Core
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
OCT-12-2022     Dhara Desai         Initial version
-----------------------------------------------------------------------------*/
public with sharing class SPEN_TestDataFactoryConstants {
    //constants to set a user for testing
    public static final String FIRSTNAME= 'TESTFIRSTNAME';
    public static final String LASTNAME= 'TESTLASTNAME';
    public static final String EMAIL= 'test@gmail.com';
    public static final String USERNAME= 'TestUser'+ System.currentTimeMillis()+'@dummyinsuu.com';
    public static final String DUMMYADD = '@dummyinsuu.com';
    public static final String TITLE= 'Mr'; 
    public static final String ALIAS= 'TESTNAME';
    public static final String TIMEZONESIDKEY = 'America/Los_Angeles';
    public static final String TIMELITERAL = '00:00:00';
    public static final String EMAILENCODINGKEY= 'UTF-8';
    public static final String LANGUAGELOCALEKEY= 'en_US';
    public static final Boolean ISACTIVE= TRUE;
    public static final String LOCALESIDKEY= 'en_US';
    public static final String PROFILENAME = 'System Administrator';
    public static final String PROFILENAMESPENAGENT = 'SPEN Agent';
    public static final String PROFILENAMELNPUSER = 'SPEN LnP';
    //constants to create test account
    public static final Integer SINGLE_REC = 1;
    public static final String ACCNAME= 'TESTAccount';
    public static final String MESSAGINGTASK_RECORDTYPE = 'Incident';

}