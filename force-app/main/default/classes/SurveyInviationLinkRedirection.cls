public class SurveyInviationLinkRedirection {

 
	public static PageReference surveyUrlRedirection() {
 		
		String surveyUUID = Apexpages.currentPage().getParameters().get('UUID');
        PageReference page;
		if(String.isNotBlank(surveyUUId) ){
			String url = '';
 			
			List<SurveyInvitation> sInv = new List<SurveyInvitation>();
 
			sInv = [SELECT Id, InvitationLink from SurveyInvitation where uuid = :surveyUUID];
			if(!sInv.isEmpty()){
 
			url = sInv[0].InvitationLink;
 
		    page = new PageReference(url);
 
			page.setRedirect(true);
			}
		else {
			page = Apexpages.currentPage();	
			page.setRedirect(true);			
			}
		}
          return page;
 
    }
 
}