/*------------------------------------------------------------------------------------
DESCRIPTION	:	Wrapper class for SDIFGetAffectedPremisesResponse
LIBRARY		:	SPEN > API
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
------------------------------------------------------------------------------------*/
public with sharing class SPEN_AffectedPremisesResponseWrapper {
    public List<RequestBody> reqBody;

	public class RequestBody {
		public String APIName;
        public String incidentId;
        //public String estimatedRestotationDate;
        public String estimateRestorationDate;
        public String chunkCount;
        public String currentChunk;
        public List<premiseEnergisationState> premiseEnergisationState;	
	}
    public class premiseEnergisationState {
		public String pn;
        public String es;
	}
    public static void test(){
       //System.debug('testing');
       Boolean istest=true;
    }
}