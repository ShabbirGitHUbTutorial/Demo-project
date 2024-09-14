/*
  @Author:: Rajat Mishra
  @Date  :: 15/02/2024
  @Description:: Create job records through email as part of ESC-1413
*/
global class SPEN_LVClaimsEmailtoJobHandler implements Messaging.InboundEmailHandler {
  
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env) {
    
        return SPEN_EmailToJobCreationHelper.CreateJobfromEmailService(email, env, 'LVClaims');

    }

}