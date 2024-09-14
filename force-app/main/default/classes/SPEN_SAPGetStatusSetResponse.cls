/* File Name: SPEN_SAPGetStatusSetResponse
 * Description: This class will have structure DOM for get contract Status call response
 * Author: ajay.chandraferi
 * Version: 1.0
 * History:
 * Date            Author              Comment
 * Mar-26-2024     Ajay Chandraferi    Initial version
 *
 */
public class SPEN_SAPGetStatusSetResponse {
	public SPEN_SAPStatusSet d;  
    
    public class SPEN_SAPStatusSet{        
        public List<SPEN_SAPStatus> results;
        public  SPEN_SAPStatusSet(){
            results = new List<SPEN_SAPStatus>();
        }       
    }  
    public class SPEN_SAPStatus{        
        public String ContractNumber;
        public String Licensearea;
        public String Sapnumber;
        public String Status;
        public String Cpudt;
        public String Msgid;
        public String Msgno;
        public String Msgtxt;
        public SPEN_SAPStatusMetaData metadata;        
    } 
    public class SPEN_SAPStatusMetaData{
        public String id;
        public String uri;
        public String type;
    }
}