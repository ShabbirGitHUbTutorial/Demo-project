/*
	@Author:: Rajat Mishra
	@Date  :: 20/11/2023
	@Description:: Create job records through email as part of ESC-39, Updated the logic as part of ESC-976
*/
global class SPEN_LandSouthEmailtoJobHandler implements Messaging.InboundEmailHandler {
	
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env) {
		
        return SPEN_EmailToJobCreationHelper.CreateJobfromEmailService(email, env, 'LandSouth');

    }

}