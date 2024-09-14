public with sharing class SPEN_IntegrationXMLNodes {

	@SuppressWarnings('PMD.CodeBestPracticesUseNamedCredentials')
	private final static String NAMESPACE = 'SDIF';
	private final static String PREFIX = '';
	
	public class SoapBodyNode extends XmlNode.XmlRootNode{
	
		public List<SDIFIncidentCancelledNode> SDIFIncidentCancelled = new List<SDIFIncidentCancelledNode>();
		public List<SDIFIncidentCreatedNode> sdifIncidentCreated = new List<SDIFIncidentCreatedNode>();
		public List<SDIFIncidentDetailsChangedNode> SDIFIncidentDetailsChanged = new List<SDIFIncidentDetailsChangedNode>();
		public List<SDIFIncidentDeloggedNode> SDIFIncidentDelogged = new List<SDIFIncidentDeloggedNode>();
		public List<SDIFIncidentCompletedNode> SDIFIncidentCompleted = new List<SDIFIncidentCompletedNode>();
		
		public List<SDIFResourceCancelledNode> sdifResourceCancelled = new List<SDIFResourceCancelledNode>();
		public List<SDIFResourceDispatchedNode> sdifResourceDispatched = new List<SDIFResourceDispatchedNode>();
		public List<SDIFIncidentScopeChangedNode> sdifIncidentScopeChanged = new List<SDIFIncidentScopeChangedNode>();
		public List<SDIFIncidentLogCreatedNode> SDIFIncidentLogCreated = new List<SDIFIncidentLogCreatedNode>();
        public List<SDIFResourceOnSiteNode> sdifResourceOnSite = new List<SDIFResourceOnSiteNode>();
		
		protected override void registerXML() 
		{	
			//System.debug('IN SoapBodyNode');
			
			registerChildren(sdifIncidentCreated, 'SDIFIncidentCreated', NAMESPACE, PREFIX);
			registerChildren(SDIFIncidentDetailsChanged, 'SDIFIncidentDetailsChanged', NAMESPACE, PREFIX);
			registerChildren(SDIFIncidentDelogged, 'SDIFIncidentDelogged', NAMESPACE, PREFIX);
			registerChildren(SDIFIncidentCompleted, 'SDIFIncidentCompleted', NAMESPACE, PREFIX);
			registerChildren(SDIFIncidentCancelled, 'SDIFIncidentCancelled', NAMESPACE, PREFIX);
			registerChildren(sdifResourceCancelled, 'SDIFResourceCancelled', NAMESPACE, PREFIX);
			//System.debug('IN SoapBodyNode');
			registerChildren(sdifResourceDispatched, 'SDIFResourceDispatched', NAMESPACE, PREFIX);
			registerChildren(sdifIncidentScopeChanged, 'SDIFIncidentScopeChanged', NAMESPACE, PREFIX);
			registerChildren(SDIFIncidentLogCreated, 'SDIFIncidentLogCreated', NAMESPACE, PREFIX);
            registerChildren(sdifResourceOnSite, 'SDIFResourceOnSite', NAMESPACE, PREFIX);
		}
	}
	/*public class SoapHeaderNode extends XmlNode {
		
		public String headerTime;
		public Id id;
		public Integer age;
		public Integer txnSource;
		public Id entityId;
		public String endPoint;
		public Integer sequence;
		public String transport;
		public String funtion;
	
		protected override void registerXML() 
		{
			System.debug('IN SoapHeaderNode');
			this.age = (Integer) registerTextNode(Integer.class, 'Age', NAMESPACE, PREFIX, age);
			this.headerTime = (String) registerTextNode(String.class, 'Time', NAMESPACE, PREFIX, headerTime);
			this.id = (Id) registerTextNode(Id.class, 'Id', NAMESPACE, PREFIX, id);
			this.txnSource = (Integer) registerTextNode(Integer.class, 'TxnSource', NAMESPACE, PREFIX, txnSource);
			this.entityId = (Id) registerTextNode(Id.class, 'EntityID', NAMESPACE, PREFIX, entityId);
			this.endPoint = (String) registerTextNode(String.class, 'Endpoint', NAMESPACE, PREFIX, endPoint);
			this.sequence = (Integer) registerTextNode(Integer.class, 'Sequence', NAMESPACE, PREFIX, sequence);
			this.transport = (String) registerTextNode(String.class, 'Transport', NAMESPACE, PREFIX, transport);
			this.funtion = (String) registerTextNode(String.class, 'Funtion', NAMESPACE, PREFIX, funtion);
		}  
	}
	public class SoapEnvelopeNode extends XmlNode.XmlRootNode {
		public List<SoapHeaderNode> header = new List<SoapHeaderNode>();
		public List<SoapBodyNode> body = new List<SoapBodyNode>();
		protected override void registerXML() 	
		{
			registerChildren(header,'Header', NAMESPACE, PREFIX);
			registerChildren(body, 'Body', NAMESPACE, PREFIX);
		}
	}*/
	
	
	public class SDIFIncidentCancelledNode extends XmlNode {
		public List<IncidentCancelledStcNode> incidentCancelledStc = new List<IncidentCancelledStcNode>();
	
		protected override void registerXML() 
		{			
			//System.debug('After incidentCancelledStc');
			registerChildren(incidentCancelledStc, 'IncidentCancelledStc', NAMESPACE, PREFIX);
		}
	}
	public class IncidentCancelledStcNode extends XmlNode { 
	
		public String incidentID;
		public String incidentReference;
		public String incTime;    //doubt
	
		protected override void registerXML() 
		{
			//System.debug('After registerTextNode');
			this.incTime = (String) registerTextNode(String.class, 'Time', NAMESPACE, PREFIX, incTime);
			this.incidentID = (String) registerTextNode(String.class, 'IncidentID', NAMESPACE, PREFIX, incidentID);
			this.incidentReference = (String) registerTextNode(String.class, 'IncidentReference', NAMESPACE, PREFIX, incidentReference);
			
			//System.debug('After this.incidentReference');
		}
	}
	
	
	public class SDIFIncidentCreatedNode extends XmlNode {
		public List<IncidentCreatedStcNode> incidentCreatedStc = new List<IncidentCreatedStcNode>();
		protected override void registerXML() 
		{
			registerChildren(incidentCreatedStc, 'IncidentCreatedStc', NAMESPACE, PREFIX);
		}
	}
	public class IncidentCreatedStcNode extends XmlNode {
	
		public String componentDescription;
		public String creationDate;
		public Integer dangerFlag;
		public String deadDeviceAlias;
		public String estimatedRestorationDate;
		public String groupID;
		public String groupName;
		public String incidentCategory;
		public String incidentCategoryDescription;
		public String incidentDescription;
		public String incidentID;
		public Integer incidentPriority;
		public String incidentReference;
		public String incidentStatus;
		public String incidentType;
		public String ivrMessageFlag;
		public String mainMessage;
		public String operatingZone;
		public String operatingZoneId;
		public String plannedDate;
		public String primaryAlias;
		public String primaryFeeder;
		public String primaryName;
		public String receivedDate;
		public String secondaryAlias;
		public String secondaryFeeder;
		public String secondaryName;
		public String supplementaryMessage;  
	
		protected override void registerXML() 
		{
			this.componentDescription = (String) registerTextNode(String.class, 'ComponentDescription', NAMESPACE, PREFIX, componentDescription);
			this.creationDate = (String) registerTextNode(String.class, 'CreationDate', NAMESPACE, PREFIX, creationDate);
			this.dangerFlag = (Integer) registerTextNode(Integer.class, 'DangerFlag', NAMESPACE, PREFIX, dangerFlag);
			this.deadDeviceAlias = (String) registerTextNode(String.class, 'DeadDeviceAlias', NAMESPACE, PREFIX, deadDeviceAlias);
			this.estimatedRestorationDate = (String) registerTextNode(String.class, 'EstimatedRestorationDate', NAMESPACE, PREFIX, estimatedRestorationDate);
			this.groupID = (String) registerTextNode(String.class, 'GroupID', NAMESPACE, PREFIX, groupID);
			this.groupName = (String) registerTextNode(String.class, 'GroupName', NAMESPACE, PREFIX, groupName);
			this.incidentCategory = (String) registerTextNode(String.class, 'IncidentCategory', NAMESPACE, PREFIX, incidentCategory);
			this.incidentCategoryDescription = (String) registerTextNode(String.class, 'IncidentCategoryDescription', NAMESPACE, PREFIX, incidentCategoryDescription);
			this.incidentDescription = (String) registerTextNode(String.class, 'IncidentDescription', NAMESPACE, PREFIX, incidentDescription);
			this.incidentID = (String) registerTextNode(String.class, 'IncidentID', NAMESPACE, PREFIX, incidentID);
			this.incidentPriority = (Integer) registerTextNode(Integer.class, 'incidentPriority', NAMESPACE, PREFIX, incidentPriority);
			this.incidentReference = (String) registerTextNode(String.class, 'IncidentReference', NAMESPACE, PREFIX, incidentReference);
			this.incidentStatus = (String) registerTextNode(String.class, 'IncidentStatus', NAMESPACE, PREFIX, incidentStatus);
			this.incidentType = (String) registerTextNode(String.class, 'IncidentType', NAMESPACE, PREFIX, incidentType);
			this.ivrMessageFlag = (String) registerTextNode(String.class, 'IvrMessageFlag', NAMESPACE, PREFIX, ivrMessageFlag);
			this.mainMessage = (String) registerTextNode(String.class, 'MainMessage', NAMESPACE, PREFIX, mainMessage);
			this.operatingZone = (String) registerTextNode(String.class, 'OperatingZone', NAMESPACE, PREFIX, operatingZone);
			this.operatingZoneId = (String) registerTextNode(String.class, 'OperatingZoneId', NAMESPACE, PREFIX, operatingZoneId);
			this.plannedDate = (String) registerTextNode(String.class, 'PlannedDate', 'true', 'xsi', plannedDate);
			this.primaryAlias = (String) registerTextNode(String.class, 'PrimaryAlias', NAMESPACE, PREFIX, primaryAlias);
			this.primaryFeeder = (String) registerTextNode(String.class, 'PrimaryFeeder', NAMESPACE, PREFIX, primaryFeeder);
			this.primaryName = (String) registerTextNode(String.class, 'PrimaryName', NAMESPACE, PREFIX, primaryName);
			this.receivedDate = (String) registerTextNode(String.class, 'ReceivedDate', NAMESPACE, PREFIX, receivedDate);
			this.secondaryAlias = (String) registerTextNode(String.class, 'SecondaryAlias', NAMESPACE, PREFIX, secondaryAlias);
			this.secondaryFeeder = (String) registerTextNode(String.class, 'SecondaryFeeder', NAMESPACE, PREFIX, secondaryFeeder);
			this.secondaryName = (String) registerTextNode(String.class, 'SecondaryName', NAMESPACE, PREFIX, secondaryName);
			this.supplementaryMessage = (String) registerTextNode(String.class, 'SupplementaryMessage', NAMESPACE, PREFIX, supplementaryMessage); //updated for SFAMS-559		
		}    
	}
	
	
	public class SDIFIncidentDetailsChangedNode extends XmlNode {
	
		public List<IncidentDetailsChangedStcNode> incidentDetailsChangedStc = new List<IncidentDetailsChangedStcNode>();
	
		protected override void registerXML() 
		{
			registerChildren(incidentDetailsChangedStc, 'IncidentDetailsChangedStc', NAMESPACE, PREFIX);
		}
	}
	public class IncidentDetailsChangedStcNode extends XmlNode {
	
		public String componentDescription;
		public String deadDeviceAlias;
		public String estimatedRestorationDate;
		public String eta;
		public String incidentID;
		public String incidentRef;
		public String secondaryAlias;
		public String secondaryName;
		public Integer status;
        public String mainMessage;
		public String category;
		public String incidentCategoryDescription;
		public String type;
		public Integer priority;
		public String supplementaryMessage;  //updated for SFAMS-559
	
		protected override void registerXML() 
		{
			this.componentDescription = (String) registerTextNode(String.class, 'ComponentDescription', NAMESPACE, PREFIX, componentDescription);
			this.deadDeviceAlias = (String) registerTextNode(String.class, 'DeadDeviceAlias', NAMESPACE, PREFIX, deadDeviceAlias);
			this.estimatedRestorationDate = (String) registerTextNode(String.class, 'EstimatedRestorationDate', NAMESPACE, PREFIX, estimatedRestorationDate);
			this.eta = (String) registerTextNode(String.class, 'Eta', NAMESPACE, PREFIX, eta);
			this.incidentID = (String) registerTextNode(String.class, 'IncidentID', NAMESPACE, PREFIX, incidentID);
			this.incidentRef = (String) registerTextNode(String.class, 'IncidentRef', NAMESPACE, PREFIX, incidentRef);
			this.secondaryAlias = (String) registerTextNode(String.class, 'SecondaryAlias', NAMESPACE, PREFIX, secondaryAlias);
			this.secondaryName = (String) registerTextNode(String.class, 'SecondaryName', NAMESPACE, PREFIX, secondaryName);
			this.status = (Integer) registerTextNode(Integer.class, 'Status', NAMESPACE, PREFIX, status);
			this.mainMessage = (String) registerTextNode(String.class, 'MainMessage', NAMESPACE, PREFIX, mainMessage);
			this.category = (String) registerTextNode(String.class, 'Category', NAMESPACE, PREFIX, category);
			this.incidentCategoryDescription = (String) registerTextNode(String.class, 'IncidentCategoryDescription', NAMESPACE, PREFIX, incidentCategoryDescription);
			this.type = (String) registerTextNode(String.class, 'Type', NAMESPACE, PREFIX, type);
			this.priority = (Integer) registerTextNode(Integer.class, 'Priority', NAMESPACE, PREFIX, priority);
			this.supplementaryMessage = (String) registerTextNode(String.class, 'SupplementaryMessage', NAMESPACE, PREFIX, supplementaryMessage);		//updated for SFAMS-559
		}
	}
	
	
	public class SDIFIncidentDeloggedNode extends XmlNode {
	
		public List<IncidentDeloggedStcNode> incidentDeloggedStc = new List<IncidentDeloggedStcNode>();
	
		protected override void registerXML() 
		{
			registerChildren(incidentDeloggedStc, 'IncidentDeloggedStc', NAMESPACE, PREFIX);
		}
	}
	public class IncidentDeloggedStcNode extends XmlNode {
	
		public Integer automaticIncident;
		public String callID;
		public String callReference;
		public String category;
		public String componentDescription;
		public String creationDate;
		public String description;
		public String groupID;
		public String groupName;
		public String incidentID;
		public String incidentReference;
		public String mainMessage;
		public String operatingZone;
		public String operatingZoneId;
		public String primaryAlias;
		public String primaryFeeder;
		public String primaryName;
		public Integer restoredCount;
		public String restoredDate;
		public String secondaryAlias;
		public String secondaryFeeder;
		public String secondaryName;
		public String type;  
	
		protected override void registerXML() 
		{
			this.automaticIncident = (Integer) registerTextNode(Integer.class, 'AutomaticIncident', NAMESPACE, PREFIX, automaticIncident);
			this.callID = (String) registerTextNode(String.class, 'CallID', NAMESPACE, PREFIX, callID);
			this.callReference = (String) registerTextNode(String.class, 'CallReference', NAMESPACE, PREFIX, callReference);
			this.category = (String) registerTextNode(String.class, 'Category', NAMESPACE, PREFIX, category);            
			this.componentDescription = (String) registerTextNode(String.class, 'ComponentDescription', NAMESPACE, PREFIX, componentDescription);
			this.creationDate = (String) registerTextNode(String.class, 'CreationDate', NAMESPACE, PREFIX, creationDate);
			this.description = (String) registerTextNode(String.class, 'Description', NAMESPACE, PREFIX, description);
			this.groupID = (String) registerTextNode(String.class, 'GroupID', NAMESPACE, PREFIX, groupID);
			this.groupName = (String) registerTextNode(String.class, 'GroupName', NAMESPACE, PREFIX, groupName);
			this.incidentID = (String) registerTextNode(String.class, 'IncidentID', NAMESPACE, PREFIX, incidentID);
			this.incidentReference = (String) registerTextNode(String.class, 'IncidentReference', NAMESPACE, PREFIX, incidentReference);
			this.operatingZone = (String) registerTextNode(String.class, 'OperatingZone', NAMESPACE, PREFIX, operatingZone);
			this.operatingZoneId = (String) registerTextNode(String.class, 'OperatingZoneId', NAMESPACE, PREFIX, operatingZoneId);
			this.primaryAlias = (String) registerTextNode(String.class, 'PrimaryAlias', NAMESPACE, PREFIX, primaryAlias);
			this.primaryFeeder = (String) registerTextNode(String.class, 'PrimaryFeeder', NAMESPACE, PREFIX, primaryFeeder);
			this.primaryName = (String) registerTextNode(String.class, 'PrimaryName', NAMESPACE, PREFIX, primaryName);
			this.restoredCount = (Integer) registerTextNode(Integer.class, 'RestoredCount', NAMESPACE, PREFIX, restoredCount);
			this.restoredDate = (String) registerTextNode(String.class, 'RestoredDate', NAMESPACE, PREFIX, restoredDate);
			this.secondaryAlias = (String) registerTextNode(String.class, 'SecondaryAlias', NAMESPACE, PREFIX, secondaryAlias);
			this.secondaryFeeder = (String) registerTextNode(String.class, 'SecondaryFeeder', NAMESPACE, PREFIX, secondaryFeeder);
			this.secondaryName = (String) registerTextNode(String.class, 'SecondaryName', NAMESPACE, PREFIX, secondaryName);
			this.type = (String) registerTextNode(String.class, 'Type', NAMESPACE, PREFIX, type);
		}
	}
	
	
	public class SDIFIncidentCompletedNode extends XmlNode{
		
		public List<IncidentCompletedStcNode> incidentCompletedStc = new List<IncidentCompletedStcNode>();
	
		protected override void registerXML() 
		{
			registerChildren(incidentCompletedStc, 'IncidentCompletedStc', NAMESPACE, PREFIX);
		}
	}
	public class IncidentCompletedStcNode extends XmlNode{
	
		public Integer automaticIncident;
		public String category;
		public String creationDate;
		public String description;
		public String groupID;
		public String groupName;
		public String incidentID;
		//public List<ResourceDispatchedNotification> resourceDispatchedNotification = new List<ResourceDispatchedNotification>();
		public String incidentReference;
		public String operatingZone;
		public String receivedDate;
		public Integer restoredCount;
		public String incTime;
	
		protected override void registerXML() 
		{
			this.automaticIncident = (Integer) registerTextNode(Integer.class, 'AutomaticIncident', NAMESPACE, PREFIX, automaticIncident);
			this.category = (String) registerTextNode(String.class, 'Category', NAMESPACE, PREFIX, category);
			this.creationDate = (String) registerTextNode(String.class, 'CreationDate', NAMESPACE, PREFIX, creationDate);
			this.description = (String) registerTextNode(String.class, 'Description', NAMESPACE, PREFIX, description);
			this.groupID = (String) registerTextNode(String.class, 'GroupID', NAMESPACE, PREFIX, groupID);
			this.groupName = (String) registerTextNode(String.class, 'GroupName', NAMESPACE, PREFIX, groupName);
			this.incidentID = (String) registerTextNode(String.class, 'IncidentID', NAMESPACE, PREFIX, incidentID);
			this.incidentReference = (String) registerTextNode(String.class, 'IncidentReference', NAMESPACE, PREFIX, incidentReference);
			this.operatingZone = (String) registerTextNode(String.class, 'OperatingZone', NAMESPACE, PREFIX, operatingZone);
			this.receivedDate = (String) registerTextNode(String.class, 'ReceivedDate', NAMESPACE, PREFIX, receivedDate);
			this.restoredCount = (Integer) registerTextNode(Integer.class, 'RestoredCount', NAMESPACE, PREFIX, restoredCount);
			this.incTime = (String) registerTextNode(String.class, 'Time', NAMESPACE, PREFIX, incTime);
			//registerChildren(resourceDispatchedNotification, 'Notification', NAMESPACE, PREFIX);	
		}
	}
	
	
	public class SDIFResourceCancelledNode extends XmlNode {
		public List<ResourceCancelledStcNode> resourceCancelledStc = new List<ResourceCancelledStcNode>();
	
		protected override void registerXML() 
		{			
			registerChildren(resourceCancelledStc, 'ResourceCancelledStc', NAMESPACE, PREFIX);
		}
	}
	public class Cancellations extends XmlNode { 
	
		public String cancelledDate;
		public String componentDescription;
		public String creationDate;
		public String deadDeviceAlias;
		public String dispatchedDate;
		public String estimatedRestorationDate;
		public String incidentCategory;
		public String incidentCategoryDescription;
		public String incidentComment;
		public String incidentDescription;
		public String incidentEasting;
		public String incidentID;
		public String incidentNorthing;		
		public String incidentReference;
		public String incidentStatus;
		public String incidentType;
		public List<ResourceDispatchedNotification> resourceDispatchedNotification = new List<ResourceDispatchedNotification>();
		public String operatingZone;
		public String plannedDate;
		public String primaryAlias;
		public String primaryFeeder;
		public String primaryName;
		public String resourceForename;
		public String resourceID;
		public String resourceReference;
		public String resourceSurname;
		public String secondaryAlias;
		public String secondaryFeeder;
		public String secondaryName;
	
		protected override void registerXML() 
		{
			this.componentDescription = (String) registerTextNode(String.class, 'ComponentDescription', NAMESPACE, PREFIX, componentDescription);
			this.creationDate = (String) registerTextNode(String.class, 'CreationDate', NAMESPACE, PREFIX, creationDate);
			this.deadDeviceAlias = (String) registerTextNode(String.class, 'DeadDeviceAlias', NAMESPACE, PREFIX, deadDeviceAlias);
			this.dispatchedDate = (String) registerTextNode(String.class, 'DispatchedDate', NAMESPACE, PREFIX, dispatchedDate);
			this.estimatedRestorationDate = (String) registerTextNode(String.class, 'EstimatedRestorationDate', NAMESPACE, PREFIX, estimatedRestorationDate);
			this.cancelledDate = (String) registerTextNode(String.class, 'CancelledDate', NAMESPACE, PREFIX, cancelledDate);
			this.incidentCategory = (String) registerTextNode(String.class, 'IncidentCategory', NAMESPACE, PREFIX, incidentCategory);
			this.incidentCategoryDescription = (String) registerTextNode(String.class, 'IncidentCategoryDescription', NAMESPACE, PREFIX, incidentCategoryDescription);
			this.incidentComment = (String) registerTextNode(String.class, 'IncidentComment', NAMESPACE, PREFIX, incidentComment);
			this.incidentDescription = (String) registerTextNode(String.class, 'IncidentDescription', NAMESPACE, PREFIX, incidentDescription);
			this.incidentEasting = (String) registerTextNode(String.class, 'IncidentEasting', NAMESPACE, PREFIX, incidentEasting);
			this.incidentID = (String) registerTextNode(String.class, 'IncidentID', NAMESPACE, PREFIX, incidentID);
			this.incidentNorthing = (String) registerTextNode(String.class, 'IncidentNorthing', NAMESPACE, PREFIX, incidentNorthing);            
			this.incidentReference = (String) registerTextNode(String.class, 'IncidentReference', NAMESPACE, PREFIX, incidentReference);
			this.incidentStatus = (String) registerTextNode(String.class, 'IncidentStatus', NAMESPACE, PREFIX, incidentStatus);
			this.incidentType = (String) registerTextNode(String.class, 'IncidentType', NAMESPACE, PREFIX, incidentType);
			this.operatingZone = (String) registerTextNode(String.class, 'OperatingZone', NAMESPACE, PREFIX, operatingZone);
			this.plannedDate = (String) registerTextNode(String.class, 'PlannedDate', NAMESPACE, PREFIX,  plannedDate);
			this.primaryAlias = (String) registerTextNode(String.class, 'PrimaryAlias', NAMESPACE, PREFIX, primaryAlias);
			this.primaryFeeder = (String) registerTextNode(String.class, 'PrimaryFeeder', NAMESPACE, PREFIX, primaryFeeder);
			this.primaryName = (String) registerTextNode(String.class, 'PrimaryName', NAMESPACE, PREFIX, primaryName);
			this.resourceForename = (String) registerTextNode(String.class, 'ResourceForename', NAMESPACE, PREFIX, primaryAlias);
			this.resourceID = (String) registerTextNode(String.class, 'ResourceID', NAMESPACE, PREFIX, primaryAlias);
			this.resourceSurname = (String) registerTextNode(String.class, 'ResourceSurname', NAMESPACE, PREFIX, resourceSurname);
			this.resourceReference = (String) registerTextNode(String.class, 'ResourceReference', NAMESPACE, PREFIX, resourceReference);
			this.secondaryAlias = (String) registerTextNode(String.class, 'SecondaryAlias', NAMESPACE, PREFIX, secondaryAlias);
			this.secondaryFeeder = (String) registerTextNode(String.class, 'SecondaryFeeder', NAMESPACE, PREFIX, secondaryFeeder);
			this.secondaryName = (String) registerTextNode(String.class, 'SecondaryName', NAMESPACE, PREFIX, secondaryName);
			registerChildren(resourceDispatchedNotification, 'Notification', NAMESPACE, PREFIX);			
			
		}
	}
	
	
	public class SDIFResourceDispatchedNode extends XmlNode {
		public List<ResourceDispatchedStcNode> resourceDispatchedStc = new List<ResourceDispatchedStcNode>();
	
		protected override void registerXML() 
		{	
			//System.debug('IN SDIFResourceDispatchedNode');		
			registerChildren(resourceDispatchedStc, 'ResourceDispatchedStc', NAMESPACE, PREFIX);
		}
	}
	public class Dispatches extends XmlNode { 
	
		
		public String componentDescription;
		public String creationDate;
		public String deadDeviceAlias;
		public String dispatchedDate;
		public String estimatedRestorationDate;
		public String eta;
		public String incidentCategory;
		public String incidentCategoryDescription;
		public String incidentComment;
		public String incidentDescription;
		public String incidentEasting;
		public String incidentID;
		public String incidentNorthing;		
		public String incidentReference;
		public String incidentStatus;
		public String incidentType;
		public List<ResourceDispatchedNotification> resourceDispatchedNotification = new List<ResourceDispatchedNotification>();
		public String operatingZone;
		public String plannedDate;
		public String primaryAlias;
		public String primaryFeeder;
		public String primaryName;
		public String resourceForename;
		public String resourceID;
		public String resourceReference;
		public String resourceSurname;
		public String secondaryAlias;
		public String secondaryFeeder;
		public String secondaryName;
	
		protected override void registerXML() 
		{
			this.componentDescription = (String) registerTextNode(String.class, 'ComponentDescription', NAMESPACE, PREFIX, componentDescription);
			this.creationDate = (String) registerTextNode(String.class, 'CreationDate', NAMESPACE, PREFIX, creationDate);
			this.deadDeviceAlias = (String) registerTextNode(String.class, 'DeadDeviceAlias', NAMESPACE, PREFIX, deadDeviceAlias);
			this.dispatchedDate = (String) registerTextNode(String.class, 'DispatchedDate', NAMESPACE, PREFIX, dispatchedDate);
			this.estimatedRestorationDate = (String) registerTextNode(String.class, 'EstimatedRestorationDate', NAMESPACE, PREFIX, estimatedRestorationDate);
			this.eta = (String) registerTextNode(String.class, 'Eta', NAMESPACE, PREFIX, eta);
			this.incidentCategory = (String) registerTextNode(String.class, 'IncidentCategory', NAMESPACE, PREFIX, incidentCategory);
			this.incidentCategoryDescription = (String) registerTextNode(String.class, 'IncidentCategoryDescription', NAMESPACE, PREFIX, incidentCategoryDescription);
			this.incidentComment = (String) registerTextNode(String.class, 'IncidentComment', NAMESPACE, PREFIX, incidentComment);
			this.incidentDescription = (String) registerTextNode(String.class, 'IncidentDescription', NAMESPACE, PREFIX, incidentDescription);
			this.incidentEasting = (String) registerTextNode(String.class, 'IncidentEasting', NAMESPACE, PREFIX, incidentEasting);
			this.incidentID = (String) registerTextNode(String.class, 'IncidentID', NAMESPACE, PREFIX, incidentID);
			this.incidentNorthing = (String) registerTextNode(String.class, 'IncidentNorthing', NAMESPACE, PREFIX, incidentNorthing);            
			this.incidentReference = (String) registerTextNode(String.class, 'IncidentReference', NAMESPACE, PREFIX, incidentReference);
			this.incidentStatus = (String) registerTextNode(String.class, 'IncidentStatus', NAMESPACE, PREFIX, incidentStatus);
			this.incidentType = (String) registerTextNode(String.class, 'IncidentType', NAMESPACE, PREFIX, incidentType);
			this.operatingZone = (String) registerTextNode(String.class, 'OperatingZone', NAMESPACE, PREFIX, operatingZone);
			this.plannedDate = (String) registerTextNode(String.class, 'PlannedDate', NAMESPACE, PREFIX,  plannedDate);
			this.primaryAlias = (String) registerTextNode(String.class, 'PrimaryAlias', NAMESPACE, PREFIX, primaryAlias);
			this.primaryFeeder = (String) registerTextNode(String.class, 'PrimaryFeeder', NAMESPACE, PREFIX, primaryFeeder);
			this.primaryName = (String) registerTextNode(String.class, 'PrimaryName', NAMESPACE, PREFIX, primaryName);
			this.resourceForename = (String) registerTextNode(String.class, 'ResourceForename', NAMESPACE, PREFIX, primaryAlias);
			this.resourceID = (String) registerTextNode(String.class, 'ResourceID', NAMESPACE, PREFIX, primaryAlias);
			this.resourceSurname = (String) registerTextNode(String.class, 'ResourceSurname', NAMESPACE, PREFIX, resourceSurname);
			this.resourceReference = (String) registerTextNode(String.class, 'ResourceReference', NAMESPACE, PREFIX, resourceReference);
			this.secondaryAlias = (String) registerTextNode(String.class, 'SecondaryAlias', NAMESPACE, PREFIX, secondaryAlias);
			this.secondaryFeeder = (String) registerTextNode(String.class, 'SecondaryFeeder', NAMESPACE, PREFIX, secondaryFeeder);
			this.secondaryName = (String) registerTextNode(String.class, 'SecondaryName', NAMESPACE, PREFIX, secondaryName);
			registerChildren(resourceDispatchedNotification, 'Notification', NAMESPACE, PREFIX);			
			
		}
	}
	public class SDIFIncidentScopeChangedNode extends XmlNode
	{
		public List<IncidentScopeChangedStcNode> incidentScopeChangedStc = new List<IncidentScopeChangedStcNode>();
		protected override void registerXML()
		{			
			registerChildren(incidentScopeChangedStc, 'incidentScopeChangedStc', NAMESPACE, PREFIX);
		}
	}
	
	public class IncidentScopeChangedStcNode extends XmlNode
	{
		public List<CallsNode> calls = new List<CallsNode>();
		public String incidentID;
		public String incidentReference;        
		protected override void registerXML()
		{			
			registerChildren(calls, 'calls', NAMESPACE, PREFIX);
			this.incidentID = (String) registerTextNode(String.class, 'IncidentID', NAMESPACE, PREFIX, IncidentID);
			this.incidentReference = (String) registerTextNode(String.class, 'IncidentReference', NAMESPACE, PREFIX, IncidentReference);
		}
	}
	
	public class CallsNode extends XmlNode
	{
		public String callID;
		public String callReference;
		protected override void registerXML()
		{
			this.callID = (String) registerTextNode(String.class, 'CallID', NAMESPACE, PREFIX, CallID);
			this.callReference = (String) registerTextNode(String.class, 'CallReference', NAMESPACE, PREFIX, CallReference);
		}  
	}
	
	public class ResourceDispatchedNotification extends XmlNode {        
		public String notificationDetails;
		public String notificationMethod;
				
		protected override void registerXML() 
		{			            
			this.notificationDetails = (String) registerTextNode(String.class, 'NotificationDetails', NAMESPACE, PREFIX, notificationDetails);
			this.notificationMethod = (String) registerTextNode(String.class, 'NotificationMethod', NAMESPACE, PREFIX, notificationMethod);	
		}
	}
	
	public class ResourceCancelledStcNode extends XmlNode {                  
		public List<Cancellations> cancellations = new List<Cancellations>();
		protected override void registerXML() 
		{			
			registerChildren(cancellations, 'Cancellations', NAMESPACE, PREFIX);
		}
	}
	
	public class ResourceDispatchedStcNode extends XmlNode {        
		public List<Dispatches> dispatches = new List<Dispatches>();
		protected override void registerXML() 
		{			
			registerChildren(dispatches, 'Dispatches', NAMESPACE, PREFIX);
		}
	}
	public class SDIFIncidentLogCreatedNode extends XmlNode{
		public List<IncidentLogCreatedStcNode> IncidentLogCreatedStc = new List<IncidentLogCreatedStcNode>();
		protected override void registerXML(){
            //System.debug('==inside SDIFIncidentLogCreatedNode==');
			registerChildren(incidentLogCreatedStc, 'IncidentLogCreatedStc', NAMESPACE, PREFIX);
		}
	}
	public class IncidentLogCreatedStcNode extends XmlNode{
		public String actualTime;
		public String incidentID;
		public String incidentReference;
		public Integer logCategoryID;
		public String logComment;
		public String loggedTime; 
		public Integer logSubCategoryID;
		public String operator;
		protected override void registerXML(){
            //System.debug('==inside IncidentLogCreatedStcNode==');
			this.actualTime = (String) registerTextNode(String.class, 'ActualTime', NAMESPACE, PREFIX, actualTime);
			this.incidentID = (String) registerTextNode(String.class, 'IncidentID', NAMESPACE, PREFIX, incidentID);
			this.incidentReference = (String) registerTextNode(String.class, 'IncidentReference', NAMESPACE, PREFIX, incidentReference);
			this.logCategoryID = (Integer) registerTextNode(Integer.class, 'LogCategoryID', NAMESPACE, PREFIX, logCategoryID); 
			this.logComment = (String) registerTextNode(String.class, 'LogComment', NAMESPACE, PREFIX, logComment);
			this.loggedTime = (String) registerTextNode(String.class, 'LoggedTime', NAMESPACE, PREFIX, loggedTime);
			this.logSubCategoryID = (Integer) registerTextNode(Integer.class, 'LogSubCategoryID', NAMESPACE, PREFIX, logSubCategoryID);
			this.operator = (String) registerTextNode(String.class, 'Operator', NAMESPACE, PREFIX, operator);
		}
	}
    
    public class SDIFResourceOnSiteNode extends xmlNode{
	public List<ResourceOnSiteStcNode> resourceOnSiteStc = new List<ResourceOnSiteStcNode>();
	protected override void registerXML() 
	{			
		registerChildren(resourceOnSiteStc, 'ResourceOnSiteStc', NAMESPACE, PREFIX);
	}
}
public class ResourceOnSiteStcNode extends xmlNode{
    public String arrivalDate;
    public String componentDescription;
    public String creationDate;
    public String deadDeviceAlias;
    public String dispatchedDate;
    public String estimatedRestorationDate;
    public String incidentCategory;
    public String incidentCategoryDescription;
    public String incidentComment;
    public String incidentDescription;
    public String incidentEasting;
    public String incidentID;
    public String incidentNorthing;  
    public Integer incidentPriority;  
    public String incidentReference;
    public String incidentStatus;
    public String incidentType;
    public String operatingZone;
    public String plannedDate;
    public String primaryAlias;
    public String primaryFeeder;
    public String primaryName;
    public String resourceForename;
    public String resourceID;
    public String resourceReference;
    public String resourceSurname;
    public String secondaryAlias;
    public String secondaryFeeder;
    public String secondaryName;
	protected override void registerXML(){
		this.arrivalDate = (String) registerTextNode(String.class, 'ArrivalDate', NAMESPACE, PREFIX, arrivalDate);
		this.componentDescription = (String) registerTextNode(String.class, 'ComponentDescription', NAMESPACE, PREFIX, componentDescription);
		this.creationDate = (String) registerTextNode(String.class, 'CreationDate', NAMESPACE, PREFIX, creationDate);
		this.deadDeviceAlias = (String) registerTextNode(String.class, 'DeadDeviceAlias', NAMESPACE, PREFIX, deadDeviceAlias);
		this.dispatchedDate = (String) registerTextNode(String.class, 'DispatchedDate', NAMESPACE, PREFIX, dispatchedDate);
		this.estimatedRestorationDate = (String) registerTextNode(String.class, 'EstimatedRestorationDate', NAMESPACE, PREFIX, estimatedRestorationDate);
		this.incidentCategory = (String) registerTextNode(String.class, 'IncidentCategory', NAMESPACE, PREFIX, incidentCategory);
		this.incidentCategoryDescription = (String) registerTextNode(String.class, 'IncidentCategoryDescription', NAMESPACE, PREFIX, incidentCategoryDescription);
		this.incidentComment = (String) registerTextNode(String.class, 'IncidentComment', NAMESPACE, PREFIX, incidentComment);
		this.incidentDescription = (String) registerTextNode(String.class, 'IncidentDescription', NAMESPACE, PREFIX, incidentDescription);
		this.incidentEasting = (String) registerTextNode(String.class, 'IncidentEasting', NAMESPACE, PREFIX, incidentEasting);
		this.incidentID = (String) registerTextNode(String.class, 'IncidentID', NAMESPACE, PREFIX, incidentID);
		this.incidentNorthing = (String) registerTextNode(String.class, 'IncidentNorthing', NAMESPACE, PREFIX, incidentNorthing);
		this.incidentPriority = (Integer) registerTextNode(Integer.class, 'IncidentPriority', NAMESPACE, PREFIX, incidentPriority);
		this.incidentReference = (String) registerTextNode(String.class, 'IncidentReference', NAMESPACE, PREFIX, incidentReference);
		this.incidentStatus = (String) registerTextNode(String.class, 'incidentStatus', NAMESPACE, PREFIX, incidentStatus);
		this.incidentType = (String) registerTextNode(String.class, 'incidentType', NAMESPACE, PREFIX, incidentType);
		this.operatingZone = (String) registerTextNode(String.class, 'OperatingZone', NAMESPACE, PREFIX, operatingZone);
		this.plannedDate = (String) registerTextNode(String.class, 'PlannedDate', NAMESPACE, PREFIX, plannedDate);
		this.primaryAlias = (String) registerTextNode(String.class, 'PrimaryAlias', NAMESPACE, PREFIX, primaryAlias);
		this.primaryFeeder = (String) registerTextNode(String.class, 'PrimaryFeeder', NAMESPACE, PREFIX, primaryFeeder);
		this.primaryName = (String) registerTextNode(String.class, 'PrimaryName', NAMESPACE, PREFIX, primaryName);
		this.resourceForename = (String) registerTextNode(String.class, 'ResourceForename', NAMESPACE, PREFIX, resourceForename);
		this.resourceID = (String) registerTextNode(String.class, 'ResourceID', NAMESPACE, PREFIX, resourceID);
		this.resourceReference = (String) registerTextNode(String.class, 'ResourceReference', NAMESPACE, PREFIX, resourceReference);
		this.resourceSurname = (String) registerTextNode(String.class, 'ResourceSurname', NAMESPACE, PREFIX, resourceSurname);
		this.secondaryAlias = (String) registerTextNode(String.class, 'SecondaryAlias', NAMESPACE, PREFIX, secondaryAlias);
		this.secondaryFeeder = (String) registerTextNode(String.class, 'SecondaryFeeder', NAMESPACE, PREFIX, secondaryFeeder);
		this.secondaryName = (String) registerTextNode(String.class, 'SecondaryName', NAMESPACE, PREFIX, secondaryName);
	}
}
}