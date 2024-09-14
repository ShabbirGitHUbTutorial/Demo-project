/*-----------------------------------------------------------------------------
DESCRIPTION	:	Service class to check Agent's Avialability.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
FEB-07-2023		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
@SuppressWarnings('PMD.CognitiveComplexity')
public with sharing class SPEN_AgentsAvailabilityService 
{
	/**
	 * @description UNIT TEST VARIABLES
	 */
	@TestVisible
	private Boolean bypassAvailabilityCheck = false;
	@TestVisible
	private Boolean executeOpenedWorkItemCheck = true;

	/**
	 * @description Check if any agent within a queue is available to pick up any work
	 * @return		TRUE if there is any available queue member; FALSE otherwise.
	 */
	@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
	public Boolean checkAvailabilityByQueueDeveloperName(String queueDeveloperName)
	{
		Boolean isAvailable = false;

		if(String.isNotBlank(queueDeveloperName))
		{
			// RULE 1. 
			// If the queue does not exist, return FALSE
			Group queue = new SPEN_GroupsSelector().selectByQueueName(queueDeveloperName);
			if(queue.isSet('Id'))
			{
				// RULE 2.
				// If the queue does not have any members, return FALSE
				List<GroupMember> members = new SPEN_GroupMembersSelector().selectByQueueId(queue.Id);
				if(!members.isEmpty())
				{
					Set<Id> groupMemberUserIds = new Set<Id>();
					for(GroupMember member : members)
					{
						// SUPPORT REMINDER
						// Only consider user members; Exclude Group members
						// Provide instructions not to add groups inside a queue
						if(String.valueOf(member.UserOrGroupId).startswith('005'))
						{
							groupMemberUserIds.add(member.UserOrGroupId);
						}
					}

					if(groupMemberUserIds.size() > 0)
					{
						// RULE 3.
						// If the queue members are NOT login to omni-channel, return FALSE
						List<UserServicePresence> presence = new SPEN_UserServicePresencesSelector().selectByUserIdsByState(groupMemberUserIds, true);
						if(!presence.isEmpty() || this.bypassAvailabilityCheck)
						{
							// CHECK 1.
							// Get all presence status containing the keywork 'AVAILABLE'
							List<ServicePresenceStatus> availablePresenceStatuses = new SPEN_ServicePresenceStatusSelector().selectByMasterLabel('Available');
							Map<Id, ServicePresenceStatus> availablePresenceStatusesIds = new Map<Id, ServicePresenceStatus>(availablePresenceStatuses);
							
							// CHECK 2.
							// Get all agents showing Available presence status
							Set<Id> agentsWithAvailablePresenceStatus = new Set<Id>();
							for(UserServicePresence p : presence)
							{
								if(availablePresenceStatusesIds.containsKey(p.ServicePresenceStatusId))
								{
									agentsWithAvailablePresenceStatus.add(p.UserId);
								}
							}

							// RULE 4.
							// If queue members are logged in to Omni-Channel but none are showing as available, return FALSE
							if(agentsWithAvailablePresenceStatus.size() > 0 && this.executeOpenedWorkItemCheck)
							{
								Set<Id> agentsWithActiveWorkItem = new Set<Id>();
								List<AgentWork> workitems = new SPEN_AgentWorksSelector().selectByUserIdsByStatuses(agentsWithAvailablePresenceStatus, new Set<String> { 'Opened' });
								for(AgentWork w : workitems)
								{
									agentsWithActiveWorkItem.add(w.UserId);
								}

								// RULE 5.
								// If the number of Agents with Presence status have all Opened work items, return FALSE
								if(agentsWithActiveWorkItem.size() < agentsWithAvailablePresenceStatus.size())
								{
									isAvailable = true;
								}
							}
						}
					}
				}
			}
		}

		return isAvailable;
	}
}