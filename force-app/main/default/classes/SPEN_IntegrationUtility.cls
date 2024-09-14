public with sharing class SPEN_IntegrationUtility {

    public Static HttpRequest prepareRequestsWithBearerToken(List<Map<String, String>> lstMapIntValuesBrTkn, HttpRequest request){
    if(lstMapIntValuesBrTkn.isEmpty()) return null;
    for ( Map<String, String> mapIntValueInstanceBrTkn : lstMapIntValuesBrTkn){
            if(mapIntValueInstanceBrTkn.containsKey(SEL_IntegrationConstants.AUTHORIZATION) && mapIntValueInstanceBrTkn.get(SEL_IntegrationConstants.AUTHORIZATION)!=null){
                request.setHeader(SEL_IntegrationConstants.AUTHORIZATION, mapIntValueInstanceBrTkn.get(SEL_IntegrationConstants.AUTHORIZATION));
            }
            if(mapIntValueInstanceBrTkn.containsKey(SEL_IntegrationConstants.CONTENT_TYPE) && mapIntValueInstanceBrTkn.get(SEL_IntegrationConstants.CONTENT_TYPE)!=null){
                request.setHeader(SEL_IntegrationConstants.CONTENT_TYPE, mapIntValueInstanceBrTkn.get(SEL_IntegrationConstants.CONTENT_TYPE));
            }
            if(mapIntValueInstanceBrTkn.containsKey(SEL_IntegrationConstants.ENDPOINT) && mapIntValueInstanceBrTkn.get(SEL_IntegrationConstants.ENDPOINT)!=null){
                request.setEndpoint(mapIntValueInstanceBrTkn.get(SEL_IntegrationConstants.ENDPOINT));
            }
        }
        return request;
  }

  public Static HttpRequest prepareRequestsForAPICallout(List<Map<String, String>> lstMapIntValues, HttpRequest request, Map<String, Object> authMap){
    if(lstMapIntValues.isEmpty()) return null;
    for ( Map<String, String> mapIntValueInstance : lstMapIntValues){
            if(mapIntValueInstance.containsKey(SEL_IntegrationConstants.SOAP_ACTION) && mapIntValueInstance.get(SEL_IntegrationConstants.SOAP_ACTION)!=null){
                request.setHeader(SEL_IntegrationConstants.SOAP_ACTION, mapIntValueInstance.get(SEL_IntegrationConstants.SOAP_ACTION));
            }
            if(mapIntValueInstance.containsKey(SEL_IntegrationConstants.AUTHORIZATION) && mapIntValueInstance.get(SEL_IntegrationConstants.AUTHORIZATION)!=null){
                request.setHeader(SEL_IntegrationConstants.AUTHORIZATION, mapIntValueInstance.get(SEL_IntegrationConstants.AUTHORIZATION)+ ' ' +authMap.get('access_token'));
            }
            if(mapIntValueInstance.containsKey(SEL_IntegrationConstants.CONTENT_TYPE) && mapIntValueInstance.get(SEL_IntegrationConstants.CONTENT_TYPE)!=null){
                request.setHeader(SEL_IntegrationConstants.CONTENT_TYPE, mapIntValueInstance.get(SEL_IntegrationConstants.CONTENT_TYPE));
            }
            if(mapIntValueInstance.containsKey(SEL_IntegrationConstants.ENDPOINT) && mapIntValueInstance.get(SEL_IntegrationConstants.ENDPOINT)!=null){
                request.setEndpoint(mapIntValueInstance.get(SEL_IntegrationConstants.ENDPOINT));
            }
        }
        return request;
  }


}