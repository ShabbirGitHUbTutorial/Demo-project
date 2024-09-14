public with sharing class SPEN_SyncIncidentDetailsWrapper {

  public List<RequestBody> reqBody;

  public class RequestBody {
    public List<SDIFIncidentCreated> sdifIncidentCreated;
    public List<SDIFIncidentDetailsChanged> SDIFIncidentDetailsChanged;
    public List<SDIFIncidentDelogged> sdifIncidentDelogged;
    public List<SDIFIncidentCompleted> sdifIncidentCompleted;
    public List<SDIFIncidentCancelled> sdifIncidentCancelled;
    public List<SDIFResourceDispatched> sdifResourceDispatched;
    public List<SDIFResourceCancelled> sdifResourceCancelled;  
    public List<SDIFResourceOnSite> sdifResourceOnSite;
    public List<SDIFIncidentScopeChanged> sdifIncidentScopeChanged;
    public List<SDIFIncidentLogCreated> sdifIncidentLogCreated;
    //public List<SDIFIncidentLogCreated> sDIFIncidentLogCreated;
  }

    /*Incident Details Scope Changed Wrapper Start*/
    public class SDIFIncidentScopeChanged
    {
        public List<IncidentScopeChangedStc> incidentScopeChangedStc;
    }
    public class IncidentScopeChangedStc 
    {
        public List<Calls> calls;
        public String incidentID;
        public String incidentReference;
    }
    public class Calls
    {
        public String callID;
        public String callReference;
    }  
    /*Incident Details Changed Wrapper Start*/
  public class SDIFIncidentDetailsChanged {
    public List<IncidentDetailsChangedStc> incidentDetailsChangedStc;
  }
    public class IncidentDetailsChangedStc{   
        public String componentDescription;
        public String deadDeviceAlias;
		public string mainMessage;
    public String estimatedRestorationDate;
    public String eta;
    public String description;

        public String incidentID;
        public String incidentRef;
        public String secondaryAlias;
        public String secondaryName;
        public Integer status;
        public String category;
        public String incidentCategoryDescription;
        public String type;
        public Integer priority;
        public String supplementaryMessage;  //updated for SFAMS-559

    }
    /*Incident Details Changed Wrapper End*/

  
    /*Incident Completed Wrapper Start*/
  public class SDIFIncidentCompleted {
    public List<IncidentCompletedStc> incidentCompletedStc;
  }
  public class IncidentCompletedStc{  

    //public List<ResourceNotifications> resourceNotifications;  
    public Integer automaticIncident;
    public String category;
    public String creationDate;
    public String description;
    public String groupID;
    public String groupName;
    public String incidentID;
    public String incidentReference;
    public String operatingZone;
    public String receivedDate;
    public Integer restoredCount;
    public String incTime;
    }    
    /*Incident Completed Wrapper End*/

  
    /*Incident Delogged Wrapper Start*/  
  public class SDIFIncidentDelogged {    
    public List<IncidentDeloggedStc> incidentDeloggedStc;
  }
  public class IncidentDeloggedStc{   
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
    public String receivedDate;
    public String secondaryAlias;
    public String secondaryFeeder;
    public String secondaryName;
        public String type;  
 
    }  
    /*Incident Delogged Wrapper End*/

    /*Incident Cancelled Wrapper Start*/
  public class SDIFIncidentCancelled {
    public List<IncidentCancelledStc> incidentCancelledStc;
  }
  public class IncidentCancelledStc {
    public String incTime;
    public String incidentReference;
    public String incidentID;
  }  
    /*Incident Cancelled Wrapper End*/

    
    /*Incident Created Wrapper Start*/
  public class SDIFIncidentCreated {
    public List<IncidentCreatedStc> incidentCreatedStc;
  }
  public class IncidentCreatedStc {      
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
  }
    /*Incident Created Wrapper End*/


    /*Resource Dispatched Wrapper Start*/
  public class SDIFResourceDispatched {
    public List<ResourceDispatchedStc> resourceDispatchedStc;
  }
  public class ResourceDispatchedStc {    
    public List<Dispatches> dispatches;
  }  
  public class Dispatches {
    public List<Notifications> notifications;
      
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
  }
    /*Resource Dispatched Wrapper End*/

    /*Resource Cancelled Wrapper Start*/
  public class SDIFResourceCancelled {
    public List<ResourceCancelledStc> resourceCancelledStc;
  }
  public class ResourceCancelledStc {    
    public List<Cancellations> cancellations;
  }  


  public class Cancellations {
    public List<Notifications> notifications;
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
  }
    /*Resource Cancelled Wrapper End*/
  public class SDIFResourceOnSite {
    public List<ResourceOnSiteStc> resourceOnSiteStc;
  }
  public class ResourceOnSiteStc {
    public List<Notifications> notifications;
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
  }
    /*Resource On Site Wrapper Start*/  



  /*Resource On Site Wrapper End*/  

  public class Notifications {
    public String notificationDetails;
    public String notificationMethod;
  }
  public class SDIFIncidentLogCreated{
    public List<IncidentLogCreatedStc> incidentLogCreatedStc;
  }
  public class IncidentLogCreatedStc{
    public DateTime actualTime;//9429
    public String incidentID;
    public String incidentReference;
    public Integer logCategoryID;
    public String logComment;
    public String loggedTime; 
	public Integer logSubCategoryID; 
	public String operator; 
  }
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public static void test(){
        //System.debug('testing');
    }
}