/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class for UsersSelector.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Common

Time (MS)       Method
125             getById
18              getCurrentUser
-----------------------------------------------------------------------------*/
@IsTest
public without sharing class SEL_UsersSelector_TEST {
  // CONSTANTS
  private static final String SYSTEM_ADMINISTRATOR = 'System Administrator';

  @IsTest
  @SuppressWarnings(
    'PMD.CodeBestPracticesAvoidEmptyQueries, PMD.SOQLSelectorPattern, PMD.AvoidhardcodingId'
  )
  private static void selectById() {
    Test.startTest();

    // NORMAL SCENARIO
    User admin = [
      SELECT Id
      FROM User
      WHERE Profile.Name = :SYSTEM_ADMINISTRATOR AND IsActive = TRUE
      LIMIT 1
    ];
    System.runAs(admin) {
      Assert.isTrue(
        new SEL_UsersSelector().selectById(UserInfo.getUserId()).Profile.Name ==
        SYSTEM_ADMINISTRATOR,
        'The profile must be ' + SYSTEM_ADMINISTRATOR
      );
    }

    // ERROR SCENARIO
    Assert.isTrue(
      new SEL_UsersSelector().selectById(null).isSet('Id') == false,
      'Null parameter will return false'
    );

    // EXCEPTION SCENARIO
    // Pass an ID that does not exist in the ORG; The value might have to be changedring
    String dummy='0053T000003DEbMQAW'; 
    Assert.isTrue(
      new SEL_UsersSelector()
        .selectById(Id.valueOf(dummy))
        .isSet('Id') == false,
      'A Query Exception should return false'
    ); 

    Test.stopTest();
  }

  @IsTest
  private static void getCurrentUser() {
    Test.startTest();

    // NORMAL SCENARIO
    Assert.isTrue(
      SEL_UsersSelector.getCurrentUser().Id == UserInfo.getUserId(),
      'Returned user ID must be equal to the getUserId from UserInfo'
    );

    // LIMIT TEST
    User currentUser = SEL_UsersSelector.getCurrentUser();
    Assert.isTrue(
      System.Limits.getQueries() == 1,
      'Multiple calls to getCurrentUser should consume a single SOQL query only'
    );

    Test.stopTest();
  }
}