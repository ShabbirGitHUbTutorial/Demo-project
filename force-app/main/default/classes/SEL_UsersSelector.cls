/*----------------------------------------------------------------------------------------------------
DESCRIPTION	:	Selector class for USER object.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Common

HISTORY		:
Date			Author				Comment
JAN-16-2021		Macjules Sevilla	Initial version
JAN-23-2021		Macjules Sevilla	Changed implementation of getCurrentUser for efficiency.
----------------------------------------------------------------------------------------------------*/
public inherited sharing class SEL_UsersSelector 
{
	private static User currentUser;

	// DESCRIPTION
	// Returns the USER record of the current user
	public static User getCurrentUser() 
	{
		if (currentUser == null) {
			currentUser = new SEL_UsersSelector().selectById(UserInfo.getUserId());
		}
		return currentUser;
	}

	// DESCRIPTION
	// Returns the USER record that matches the ID parameter
	public User selectById(Id userId) 
	{
		List<User> results = new List<User>();

		if (userId != null) 
		{
			results = [
				SELECT Id, Name, Profile.Name, UserRole.Name
				FROM User
				WHERE Id = :userId
				WITH SECURITY_ENFORCED
			];
		}

		return results.size() == 0 ? new User() : results[0];
	}
}