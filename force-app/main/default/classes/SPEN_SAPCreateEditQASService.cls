/*-----------------------------------------------------------------------------
DESCRIPTION :   This is Service class used to generate "Create Edit QAS" xml request
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
06-Jun-2023     Rohit Sharma        Initial version
-----------------------------------------------------------------------------*/
public class SPEN_SAPCreateEditQASService {
    public static string generateCreateEditRequest(String operation, Case caseRef)
    {
        String xmlstring = '';	
        try
        {
            
            List<Case>	caseList = new List<Case>();
            caseList = SPEN_CaseSelector.getCaseDetailsForSAPCallout(caseRef.Id); //WHERE id =: caseId LIMIT 1]; TBC : case id will be passed to this method
            
            List<SPEN_Plot__c>	plotList = new List<SPEN_Plot__c>();
            plotList = 	SPEN_PlotSelector.getPlotsFromCase(caseRef.Id);	// TBC : where SPEN_CaseRecord__c=: 

            List<SPEN_PhysicalInformation__c>	physicalInfoList = new List<SPEN_PhysicalInformation__c>();
            physicalInfoList = 	SPEN_PhysicalInformationSelector.getPhysicalInfoFromCase(caseRef.Id);	//Added by Akshay
            
            List<User>	loggedInUser = new List<User>();
            loggedInUser = SPEN_UserInfoSelector.getLoggedInUsersInfo(); //TBC : if no value default System.Label.DefaultSAPUser
            //Time format values
            String dateValueHeader = system.now().format('yyyyMMdd');
            String dateValue = system.now().format('yyyyMMdd');
            String timeValue = system.now().format('HHmmss');
            String userDetail=(!String.isEmpty(loggedInUser[0].SPEN_SAPId__c) ? loggedInUser[0].SPEN_SAPId__c : System.Label.DefaultSAPUser);
            //String userDetail='700262';          
                                 
            //control tags logic
            String customerControlTag=((!String.isEmpty(caseList[0].SPEN_UKC1ID__c) || !String.isEmpty(caseList[0].SPEN_UKC2ID__c)|| !String.isEmpty(caseList[0].SPEN_CCCompanyName__c)) ? 'Y' : 'N'); // Y if Zjews01customer have any value
            String siteContentControlTag=((!String.isEmpty(caseList[0].SPEN_SiteContactFirstName__c) || !String.isEmpty(caseList[0].SPEN_SiteContactLastName__c)|| !String.isEmpty(caseList[0].SPEN_SiteContactPhone__c) || !String.isEmpty(caseList[0].SPEN_SiteContactMobile__c) || !String.isEmpty(caseList[0].SPEN_SiteContactEmail__c) ) ? 'Y' : 'N'); //Site Content- Y if Zjews01sitecont have any value else N
            String plotControlTag=((plotList.size() > 0)? 'Y' : 'N');//Plot - Y if Zjews01plots have any value
            String phyInfoControlTag=((physicalInfoList.size() > 0) ? 'Y' : 'N');//Physical Info - Y if case have any PhyInfo Akshay
            
            //Plot supporting details            
            String plotOperation='';
            String plotIdentifier=(!String.isEmpty(caseList[0].SPEN_Plots__c) ? caseList[0].SPEN_Plots__c : 'N');// to be used in Zindps of Zjews01qashead 
            String zidpropertyStr='';
            //Integer activePlots=getActivePlots(plotList);

            //Physical Information supporting details Akshay
            String physicalInfoOperation='';
            String ztexti1Str='';
            
            //Competent supporting details
            //CRMD-6888 : Rajat : Convert Date into Datetime for Competent Date
            //Datetime zfechinireDateTime = (caseList[0].SPEN_CaseTransferredDateTimeInSAP__c != null ? caseList[0].SPEN_CaseTransferredDateTimeInSAP__c.addDays(1) : null); //Made competent date + 1 Day (Required Start Date)
            //Datetime zfechfinreDateTime = (caseList[0].SPEN_CaseTransferredDateTimeInSAP__c != null ? caseList[0].SPEN_CaseTransferredDateTimeInSAP__c.addMonths(6) : null); //Made competent date + 6 Month (Required End Date)
            //String zfechinireDate = system.now().addDays(1).format('yyyyMMdd');//Current date + 1 Day (Required Start Date)
            BusinessHours bh =SPEN_BusinessHourSelector.getConBusinessHrs();
            
            
            //CRMD-9440 
            Datetime zfechaaltaprDateTime = (caseList[0].SPEN_ContactReceivedDate__c != null ? caseList[0].SPEN_ContactReceivedDate__c : null); // Contact Received Date 
            String zfechaaltaprDateValue = (zfechaaltaprDateTime != null ? zfechaaltaprDateTime.format('yyyyMMdd') : ''); // Contact Received Date (CR Raised Date)
            String zhoraaltaprTimeValue = (zfechaaltaprDateTime != null ? zfechaaltaprDateTime.format('HHmmss') : ''); // Contact Received time (the Hours)
            String zttqsdateValue = (caseList[0].SPEN_TTQStartDate__c != null ? (String.valueOf(caseList[0].SPEN_TTQStartDate__c).mid(0,4) + String.valueOf(caseList[0].SPEN_TTQStartDate__c).mid(5,2) + String.valueOf(caseList[0].SPEN_TTQStartDate__c).mid(8,2)) : ''); // TTQ Date 
            String zttqstimeValue = (caseList[0].SPEN_TTQ_Start_Time__c != null ? (String.valueOf(caseList[0].SPEN_TTQ_Start_Time__c).mid(0,2) + String.valueOf(caseList[0].SPEN_TTQ_Start_Time__c).mid(3,2) + String.valueOf(caseList[0].SPEN_TTQ_Start_Time__c).mid(6,2)) : ''); // TTQ Time
            
            //Datetime zfechaaltaDateTime = (caseList[0].SPEN_CaseTransferredDateTimeInSAP__c != null ? caseList[0].SPEN_CaseTransferredDateTimeInSAP__c : null); // Made Competent DateTime 
            //String zfechaaltaDateValue = (zfechaaltaDateTime != null ? zfechaaltaDateTime.format('yyyyMMdd') : ''); // Made Competent Date (CR Transfer Date)
            //String zhoraaltaTimeValue = (zfechaaltaDateTime != null ? zfechaaltaDateTime.format('HHmmss') : ''); // Made Competent time (the Hours)
            String zfechaaltaDateValue;
            String zhoraaltaTimeValue;
            String zfechinireDate;
            String zfechfinreDate;
            if(caseList[0].SPEN_IsCaseCompetentInSAP__c){
                zfechaaltaDateValue = caseList[0].SPEN_CaseTransferredDateTimeInSAP__c.format('yyyyMMdd'); // Current Date when making competent (CR Transfer Date)
                zhoraaltaTimeValue = caseList[0].SPEN_CaseTransferredDateTimeInSAP__c.format('HHmmss'); // Current Time when making competent (the Hours)
                zfechinireDate = Cases.getWorkingDays(bh.Id, caseList[0].SPEN_CaseTransferredDateTimeInSAP__c, Long.valueOf('1')).format('yyyyMMdd');//Current date + 1 Day (Required Start Date)
                zfechfinreDate = caseList[0].SPEN_CaseTransferredDateTimeInSAP__c.addMonths(6).format('yyyyMMdd');//Current date + 6 Month (Required End Date)
            }
            else{
                zfechaaltaDateValue = system.now().format('yyyyMMdd'); // Current Date when making competent (CR Transfer Date)
                zhoraaltaTimeValue = system.now().format('HHmmss'); // Current Time when making competent (the Hours)
                zfechinireDate = Cases.getWorkingDays(bh.Id, system.now(), Long.valueOf('1')).format('yyyyMMdd');//Current date + 1 Day (Required Start Date)
                zfechfinreDate = system.now().addMonths(6).format('yyyyMMdd');//Current date + 6 Month (Required End Date)
            }
            
            String zrdofferdateValue = (caseList[0].SPEN_CompetentDate__c != null ? (String.valueOf(caseList[0].SPEN_CompetentDate__c).mid(0,4) + String.valueOf(caseList[0].SPEN_CompetentDate__c).mid(5,2) + String.valueOf(caseList[0].SPEN_CompetentDate__c).mid(8,2)) : ''); // Competent Date (Offer requested Date)
            String zrhoffertimeValue = (caseList[0].SPEN_Competent_Time__c != null ? (String.valueOf(caseList[0].SPEN_Competent_Time__c).mid(0,2) + String.valueOf(caseList[0].SPEN_Competent_Time__c).mid(3,2) + String.valueOf(caseList[0].SPEN_Competent_Time__c).mid(6,2)) : ''); // Competent Time
            //End
            // zjews01control tag values logic for each tag
            
            String zjews01controlQasTagStr;
            String zjews01controlCusTagStr;
            String zjews01controlCcoTagStr;
            String zjews01controlDevTagStr;
            String zjews01controlGderTagStr;
            String zjews01controlPldTagStr;
            String zjews01controlScoTagStr;
            String zjews01controlPhyTagStr;
            String zjews01controlAdiTagStr;
            String zjews01controlCancelTagStr;
            String zjews01controlLetterTagStr;
            String zjews01controlQasModTagStr;
            String zjews01controlCusModTagStr;
            String zjews01controlCcoModTagStr;
            String zjews01controlDevModTagStr;
            String zjews01controlGderModTagStr;
            String zjews01controlScoModTagStr;

            if(operation=='CREATE_QAS')
            {
                zjews01controlQasTagStr='Y'; //Y for create, N for Modify 
                zjews01controlCusTagStr=customerControlTag; // Y if Zjews01customer have any value
                zjews01controlCcoTagStr='N'; //customer corp- Always N. Out of Scope
                zjews01controlDevTagStr='N'; // Always N. Out of Scope
                zjews01controlGderTagStr='Y'; //Header -Always Y
                zjews01controlPldTagStr=plotControlTag; //Plot - Y if Zjews01plots have any value
                    //zjews01plotsZimbStr='I'; //Insert Plot
                zjews01controlScoTagStr=siteContentControlTag; //Site Content- Y if Zjews01sitecont have any value else N
                zjews01controlPhyTagStr=phyInfoControlTag; //Pending-Information - Planned for sprint 4 Akshay
                zjews01controlAdiTagStr='N'; //Additional Notes- Always N
                zjews01controlCancelTagStr='N'; //If cancel Y else N
                zjews01controlLetterTagStr='N'; //Always N . Out of scope
                zjews01controlQasModTagStr='N'; //Always N for Create 
                zjews01controlCusModTagStr='N'; //Always N for Create
                zjews01controlCcoModTagStr='N'; //Always N for Create
                zjews01controlDevModTagStr='N'; //Always N for Create
                zjews01controlGderModTagStr='N'; //Always N for Create
                zjews01controlScoModTagStr='N'; //Always N for Create

            }else if(operation=='MODIFY_QAS')
            {
                zjews01controlQasTagStr='N'; //Always N for Modify 
                zjews01controlCusTagStr='N'; //Always N for Modify 
                zjews01controlCcoTagStr='N'; //Always N for Modify 
                zjews01controlDevTagStr='N'; //Always N for Modify 
                zjews01controlGderTagStr='Y'; //Header -Always Y
                zjews01controlPldTagStr=plotControlTag; //Plot - Y if Zjews01plots have any value
                    //zjews01plotsZimbStr='U'; //Update Plot
                zjews01controlScoTagStr=siteContentControlTag; //Site Content- Y if Zjews01sitecont have any value else N
                zjews01controlPhyTagStr=phyInfoControlTag; //Pending-Information - Planned for sprint 4 Akshay
                zjews01controlAdiTagStr='N'; //Additional Notes- Always N
                zjews01controlCancelTagStr='N'; //If cancel Y else N
                zjews01controlLetterTagStr='N'; //Always N . Out of scope
                zjews01controlQasModTagStr='Y'; // Always Y for Modify. N for create
                zjews01controlCusModTagStr='Y'; // Always Y for Modify. N for create
                zjews01controlCcoModTagStr='N'; // Always N. Out of Scope
                zjews01controlDevModTagStr='N'; // Always N. Out of Scope
                zjews01controlGderModTagStr='Y'; // Always Y for Modify. N for create
                zjews01controlScoModTagStr='Y'; // Always Y for Modify. N for create - //N	//Y
            }
            else if(operation=='TRANSFER_QAS')
            {
                zjews01controlQasTagStr='N'; 
                zjews01controlCusTagStr='N'; 
                zjews01controlCcoTagStr='N';  
                zjews01controlDevTagStr='N'; 
                zjews01controlGderTagStr='Y'; 
                zjews01controlPldTagStr=plotControlTag; 
                zjews01controlScoTagStr=siteContentControlTag; 
                zjews01controlPhyTagStr='N'; 
                zjews01controlAdiTagStr='N'; 
                zjews01controlCancelTagStr='N'; 
                zjews01controlLetterTagStr='N'; 
                zjews01controlQasModTagStr='Y'; 
                zjews01controlCusModTagStr='Y'; 
                zjews01controlCcoModTagStr='N'; 
                zjews01controlDevModTagStr='N'; 
                zjews01controlGderModTagStr='Y'; 
                zjews01controlScoModTagStr='Y'; 
            }
            else if(operation=='CANCEL_QAS')
            {
                zjews01controlQasTagStr='N'; 
                zjews01controlCusTagStr='N'; 
                zjews01controlCcoTagStr='N';  
                zjews01controlDevTagStr='N'; 
                zjews01controlGderTagStr='Y'; 
                zjews01controlPldTagStr=plotControlTag; 
                zjews01controlScoTagStr=siteContentControlTag; 
                zjews01controlPhyTagStr=phyInfoControlTag; 
                zjews01controlAdiTagStr='N'; 
                zjews01controlCancelTagStr='Y'; 
                zjews01controlLetterTagStr='N'; 
                zjews01controlQasModTagStr='Y'; 
                zjews01controlCusModTagStr='Y'; 
                zjews01controlCcoModTagStr='N'; 
                zjews01controlDevModTagStr='N'; 
                zjews01controlGderModTagStr='Y'; 
                zjews01controlScoModTagStr='Y';
            }
            
            DOM.Document doc = new DOM.Document();
            String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
            String xsi = 'urn:sap-com:document:sap:soap:functions:mc-style';
            dom.XmlNode rootTag = doc.createRootElement('Envelope', soapNS, 'soapenv');
            rootTag.setNamespace('urn', xsi);
            dom.XmlNode headerTag = rootTag.addChildElement('soapenv:Header', null, null);
            dom.XmlNode bodyTag = rootTag.addChildElement('soapenv:Body', null, null);
            dom.XmlNode zJws001SapcreateeditqasTag = bodyTag.addChildElement('urn:ZJws001Sapcreateeditqas', null, null);
            
            //ZJws001Sapcreateeditqas
            dom.XmlNode iNotifiw51Tag = prepareChildTag(zJws001SapcreateeditqasTag,'INotifiw51',null);
            //dom.XmlNode zjews00headerTag = prepareChildTag(zJws001SapcreateeditqasTag,'Zjews00header');
            dom.XmlNode zjews00headerTag = zJws001SapcreateeditqasTag.addChildElement('Zjews00header', null, null);
            dom.XmlNode zjews00messageTag = zJws001SapcreateeditqasTag.addChildElement('Zjews00message', null, null);
            dom.XmlNode zjews01cancelTag = zJws001SapcreateeditqasTag.addChildElement('Zjews01cancel', null, null);
            dom.XmlNode zjews01controlTag = zJws001SapcreateeditqasTag.addChildElement('Zjews01control', null, null);
            dom.XmlNode zjews01customerTag = zJws001SapcreateeditqasTag.addChildElement('Zjews01customer', null, null);
            dom.XmlNode zjews01encletTag = zJws001SapcreateeditqasTag.addChildElement('Zjews01enclet', null, null);
            dom.XmlNode zjews01letterTag = zJws001SapcreateeditqasTag.addChildElement('Zjews01letter', null, null);
            dom.XmlNode zjews01noteTag = zJws001SapcreateeditqasTag.addChildElement('Zjews01note', null, null);
            dom.XmlNode zjews01pendinfTag = zJws001SapcreateeditqasTag.addChildElement('Zjews01pendinf', null, null);
            dom.XmlNode zjews01plotsTag = zJws001SapcreateeditqasTag.addChildElement('Zjews01plots', null, null);
            dom.XmlNode zjews01qasTag = zJws001SapcreateeditqasTag.addChildElement('Zjews01qas', null, null);
            dom.XmlNode zjews01qasheadTag = zJws001SapcreateeditqasTag.addChildElement('Zjews01qashead', null, null);       
            dom.XmlNode zjews01sitecontTag = zJws001SapcreateeditqasTag.addChildElement('Zjews01sitecont', null, null);
            dom.XmlNode zjews02custcorpTag = zJws001SapcreateeditqasTag.addChildElement('Zjews02custcorp', null, null);
            dom.XmlNode zjews02developerTag = zJws001SapcreateeditqasTag.addChildElement('Zjews02developer', null, null);
            dom.XmlNode zjtegendetTag = zJws001SapcreateeditqasTag.addChildElement('Zjtegendet', null, null);
            dom.XmlNode zjtplogendtTag = zJws001SapcreateeditqasTag.addChildElement('Zjtplogendt', null, null);
            
            //zjews00headerTag                
            dom.XmlNode zjews00headerLangTag = prepareChildTag(zjews00headerTag,'Language','E'); //Mapping - Should be hard code
            dom.XmlNode zjews00headerUserTag = prepareChildTag(zjews00headerTag,'User',userDetail); //Mapping - Sap Id //U334219 
            dom.XmlNode zjews00headerTimeTag = prepareChildTag(zjews00headerTag,'Time',dateValueHeader); //Mapping - current date in format ddmmyyyy
            dom.XmlNode zjews00headerHourTag = prepareChildTag(zjews00headerTag,'Hour',timeValue); //Mapping - current time
                
            //zjews00messageTag
            dom.XmlNode zjews00headerItemTag = zjews00messageTag.addChildElement('item', null, null);
            dom.XmlNode zjews00headerItemTypeTag = prepareChildTag(zjews00headerItemTag,'Type',null);	
            dom.XmlNode zjews00headerItemLangTag = prepareChildTag(zjews00headerItemTag,'Language',null);	
            dom.XmlNode zjews00headerItemIdTag = prepareChildTag(zjews00headerItemTag,'Id',null);	
            dom.XmlNode zjews00headerItemNumTag = prepareChildTag(zjews00headerItemTag,'Number',null);	
            dom.XmlNode zjews00headerItemMsgTag = prepareChildTag(zjews00headerItemTag,'Message',null);
            
            
			//CRMD-6038 : Rajat
			//zjews01cancel
            if('CANCEL_QAS'.equalsIgnoreCase(operation)){
				dom.XmlNode zjews01cancelZidcanreasqasTag = prepareChildTag(zjews01cancelTag,'Zidcanreasqas',(String.isNotBlank(caseList[0].SPEN_CancellationReason__c) ? caseList[0].SPEN_CancellationReason__c :'')); 
				dom.XmlNode zjews01cancelFecanusuTag = prepareChildTag(zjews01cancelTag,'Fecanusu',dateValue);
				dom.XmlNode zjews01cancelZtextcanTag = prepareChildTag(zjews01cancelTag,'Ztextcan',(String.isNotBlank(caseList[0].SPEN_CancellationNote__c) ? caseList[0].SPEN_CancellationNote__c :''));
			}else{
				dom.XmlNode zjews01cancelZidcanreasqasTag = prepareChildTag(zjews01cancelTag,'Zidcanreasqas',null); 
				dom.XmlNode zjews01cancelFecanusuTag = prepareChildTag(zjews01cancelTag,'Fecanusu',null);
				dom.XmlNode zjews01cancelZtextcanTag = prepareChildTag(zjews01cancelTag,'Ztextcan',null);
			}
            //END
            //zjews01control        ,
            dom.XmlNode zjews01controlZproTag = prepareChildTag(zjews01controlTag,'Zprocent',operation);	//CREATE_QAS,MODIFY_QAS,CANCEL_QAS,TRANSFER_QAS
            dom.XmlNode zjews01controlQasTag = prepareChildTag(zjews01controlTag,'Qas',zjews01controlQasTagStr); //Y for create, N for Modify 
            dom.XmlNode zjews01controlCusTag = prepareChildTag(zjews01controlTag,'Cus',zjews01controlCusTagStr); // Y if Zjews01customer have any value
            dom.XmlNode zjews01controlCcoTag = prepareChildTag(zjews01controlTag,'Cco',zjews01controlCcoTagStr); //customer corp- Always N. Out of Scope
            dom.XmlNode zjews01controlDevTag = prepareChildTag(zjews01controlTag,'Dev',zjews01controlDevTagStr); // Always N. Out of Scope
            dom.XmlNode zjews01controlGderTag = prepareChildTag(zjews01controlTag,'Gder',zjews01controlGderTagStr);	//Header -Always Y
            dom.XmlNode zjews01controlPldTag = prepareChildTag(zjews01controlTag,'Pld',zjews01controlPldTagStr); //Plot - Y if Zjews01plots have any value
            dom.XmlNode zjews01controlScoTag = prepareChildTag(zjews01controlTag,'Sco',zjews01controlScoTagStr); //Site Content- Y if Zjews01sitecont have any value
            dom.XmlNode zjews01controlPhyTag = prepareChildTag(zjews01controlTag,'Phy',zjews01controlPhyTagStr); //Pending-Information - Planned for sprint 4
            dom.XmlNode zjews01controlAdiTag = prepareChildTag(zjews01controlTag,'Adi',zjews01controlAdiTagStr); //Additional Notes- Always N
            dom.XmlNode zjews01controlCancelTag = prepareChildTag(zjews01controlTag,'Cancel',zjews01controlCancelTagStr); //If cancel operation Y else N
            dom.XmlNode zjews01controlLetterTag = prepareChildTag(zjews01controlTag,'Letter',zjews01controlLetterTagStr); //Always N . Out of scope
            dom.XmlNode zjews01controlQasModTag = prepareChildTag(zjews01controlTag,'QasMod',zjews01controlQasModTagStr); // Always Y for Modify. N for create
            dom.XmlNode zjews01controlCusModTag = prepareChildTag(zjews01controlTag,'CusMod',zjews01controlCusModTagStr); // Always Y for Modify. N for create
            dom.XmlNode zjews01controlCcoModTag = prepareChildTag(zjews01controlTag,'CcoMod',zjews01controlCcoModTagStr); // Always N. Out of Scope
            dom.XmlNode zjews01controlDevModTag = prepareChildTag(zjews01controlTag,'DevMod',zjews01controlDevModTagStr); // Always N. Out of Scope
            dom.XmlNode zjews01controlGderModTag = prepareChildTag(zjews01controlTag,'GderMod',zjews01controlGderModTagStr); // Always Y for Modify. N for create
            dom.XmlNode zjews01controlScoModTag = prepareChildTag(zjews01controlTag,'ScoMod',zjews01controlScoModTagStr);	// Always Y for Modify. N for create - //N	//Y
            dom.XmlNode zjews01controlZcodqasTag = prepareChildTag(zjews01controlTag,'Zcodqas',(!String.isEmpty(caseList[0].SPEN_SAPReference__c) ? caseList[0].SPEN_SAPReference__c : ''));	//N	//null
            
            //zjews01customer
            dom.XmlNode zjews01customerKunnrTag = prepareChildTag(zjews01customerTag,'Kunnr',(!String.isEmpty(caseList[0].SPEN_UKC1ID__c) ? caseList[0].SPEN_UKC1ID__c : '')); //824801 //0000020794 
            dom.XmlNode zjews01customerKunreTag = prepareChildTag(zjews01customerTag,'Kunre',(!String.isEmpty(caseList[0].SPEN_UKC2ID__c) ? caseList[0].SPEN_UKC2ID__c : ''));		//null	 //0000020794
            dom.XmlNode zjews01customerTitleTag = prepareChildTag(zjews01customerTag,'Title',null);
            dom.XmlNode zjews01customerZcompanameTag = prepareChildTag(zjews01customerTag,'Zcompaname',(!String.isEmpty(caseList[0].SPEN_CCCompanyName__c) ? caseList[0].SPEN_CCCompanyName__c : ''));
            dom.XmlNode zjews01customerZname1Tag = prepareChildTag(zjews01customerTag,'Zname1',null);
            dom.XmlNode zjews01customerZsurname11Tag = prepareChildTag(zjews01customerTag,'Zsurname11',null);
            dom.XmlNode zjews01customerZnumCasa1Tag = prepareChildTag(zjews01customerTag,'ZnumCasa1',null);
            dom.XmlNode zjews01customerZnumEdi1Tag = prepareChildTag(zjews01customerTag,'ZnumEdi1',null);
            dom.XmlNode zjews01customerZbuilding1Tag = prepareChildTag(zjews01customerTag,'Zbuilding1',null);
            dom.XmlNode zjews01customerZcalle1Tag = prepareChildTag(zjews01customerTag,'Zcalle1',null);
            dom.XmlNode zjews01customerZbarrio1Tag = prepareChildTag(zjews01customerTag,'Zbarrio1',null);
            dom.XmlNode zjews01customerZcity1Tag = prepareChildTag(zjews01customerTag,'Zcity1',null);
            dom.XmlNode zjews01customerZcodpais1Tag = prepareChildTag(zjews01customerTag,'Zcodpais1',null);
            dom.XmlNode zjews01customerZcodprov1Tag = prepareChildTag(zjews01customerTag,'Zcodprov1',null);
            dom.XmlNode zjews01customerZcodpostal1Tag = prepareChildTag(zjews01customerTag,'Zcodpostal1',null);
            dom.XmlNode zjews01customerZtelefono1Tag = prepareChildTag(zjews01customerTag,'Ztelefono1',null);
            dom.XmlNode zjews01customerZmobile1Tag = prepareChildTag(zjews01customerTag,'Zmobile1',null);
            dom.XmlNode zjews01customerZfaxtn1Tag = prepareChildTag(zjews01customerTag,'Zfaxtn1',null);
            dom.XmlNode zjews01customerZemail1Tag = prepareChildTag(zjews01customerTag,'Zemail1',null);
            dom.XmlNode zjews01customerCIncEncTag = prepareChildTag(zjews01customerTag,'CIncEnc',(!String.isEmpty(caseList[0].SPEN_AddInCustomerSatisfactionSurvey__c) ? caseList[0].SPEN_AddInCustomerSatisfactionSurvey__c : ''));	//null	//Y
            
            //zjews01enclet        
            dom.XmlNode zjews01encletItemTag = zjews01encletTag.addChildElement('item', null, null);
            dom.XmlNode zjews01encletItemTemplTag = prepareChildTag(zjews01encletItemTag,'Zlettertemple',null);	
            dom.XmlNode zjews01encletItemClosTag = prepareChildTag(zjews01encletItemTag,'Zenclosure',null);	
            dom.XmlNode zjews01encletItemSeqTag = prepareChildTag(zjews01encletItemTag,'Sequence',null);        
            
            //zjews01letter        
            dom.XmlNode zjews01letterItemTag = zjews01letterTag.addChildElement('item', null, null);
            dom.XmlNode zjews01letterItemTemplTag = prepareChildTag(zjews01letterItemTag,'Zlettertemple',null);	
            dom.XmlNode zjews01letterItemZFieldTag = prepareChildTag(zjews01letterItemTag,'Zfield',null);	
            dom.XmlNode zjews01letterItemTxtTag = prepareChildTag(zjews01letterItemTag,'Text',null);
            
            //zjews01note        
            dom.XmlNode zjews01noteItemTag = zjews01noteTag.addChildElement('item', null, null);
            dom.XmlNode zjews01noteItemZimbTag = prepareChildTag(zjews01noteItemTag,'Zimb',null);	
            dom.XmlNode zjews01noteItemZidTag = prepareChildTag(zjews01noteItemTag,'Zidobserva',null);	
            dom.XmlNode zjews01noteItemZentityTag = prepareChildTag(zjews01noteItemTag,'Zentity',null);
            dom.XmlNode zjews01noteItemZfilTag = prepareChildTag(zjews01noteItemTag,'Zperfilobser',null);	
            dom.XmlNode zjews01noteItemZob1Tag = prepareChildTag(zjews01noteItemTag,'Zob1',null);	
            dom.XmlNode zjews01noteItemZtxtTag = prepareChildTag(zjews01noteItemTag,'Ztexto1',null);
            dom.XmlNode zjews01noteItemTdfdateTag = prepareChildTag(zjews01noteItemTag,'Tdfdate',null);	
            dom.XmlNode zjews01noteItemTdftimeTag = prepareChildTag(zjews01noteItemTag,'Tdftime',null);	
            dom.XmlNode zjews01noteItemTdfuserTag = prepareChildTag(zjews01noteItemTag,'Tdfuser',null);
            
            //zjews01pendinf
            //logic to handle multiple Physical Information in one request Akshay
            if(!physicalInfoList.isEmpty() && zjews01controlPhyTagStr=='Y')
            {
                system.debug('size of physical information list is '+ physicalInfoList.size());
                for(SPEN_PhysicalInformation__c physicalInfoRef : physicalInfoList)
                {
                    if(physicalInfoRef.SPEN_ItemID__c!=null)
                        {
                            physicalInfoOperation='M'; //Update plot// should be M and not U
                            ztexti1Str = (!String.isEmpty(physicalInfoRef.SPEN_ItemRequestRemark__c) ? physicalInfoRef.SPEN_ItemRequestRemark__c : '');
                        }
                    else
                        {
                            physicalInfoOperation='I'; //Insert Plot
                            ztexti1Str = physicalInfoRef.SPEN_ItemRequestRemark__c+' {Ref:'+physicalInfoRef.Id+'}';
                        }
                    
                    dom.XmlNode zjews01pendinfItemTag = zjews01pendinfTag.addChildElement('item', null, null);
                    dom.XmlNode zjews01pendinfZimbItemTag = prepareChildTag(zjews01pendinfItemTag,'Zimb',physicalInfoOperation);
                    dom.XmlNode zjews01pendinfZidiItemTag = prepareChildTag(zjews01pendinfItemTag,'Ziditem',(!String.isEmpty(physicalInfoRef.SPEN_ItemID__c) ? physicalInfoRef.SPEN_ItemID__c : ''));
                    dom.XmlNode zjews01pendinfZClassItemTag = prepareChildTag(zjews01pendinfItemTag,'Zclaseitem',(!String.isEmpty(physicalInfoRef.SPEN_ItemClass__c) ? physicalInfoRef.SPEN_ItemClass__c : ''));	
                    dom.XmlNode zjews01pendinfZperFiliItemTag = prepareChildTag(zjews01pendinfItemTag,'Zperfilitem',(!String.isEmpty(physicalInfoRef.SPEN_ItemProfile__c) ? physicalInfoRef.SPEN_ItemProfile__c : ''));	
                    dom.XmlNode zjews01pendinfZit1ItemTag = prepareChildTag(zjews01pendinfItemTag,'Zit1','Y');	
                    dom.XmlNode zjews01pendinfZZtxt1ItemTag = prepareChildTag(zjews01pendinfItemTag,'Ztexti1',ztexti1Str);	
                    dom.XmlNode zjews01pendinfZfetchItemTag = prepareChildTag(zjews01pendinfItemTag,'Zfecharecitem',(!String.isEmpty(string.ValueOf(physicalInfoRef.SPEN_ItemReceivedOn__c)) ? ((physicalInfoRef.SPEN_ItemReceivedOn__c).format('yyyyMMdd')) : ''));	
                    dom.XmlNode zjews01pendinfZhoracItemTag = prepareChildTag(zjews01pendinfItemTag,'Zhorarecitem',(!String.isEmpty(string.ValueOf(physicalInfoRef.SPEN_ItemReceivedOn__c)) ? ((physicalInfoRef.SPEN_ItemReceivedOn__c).format('HHmmss')) : ''));	
                    dom.XmlNode zjews01pendinfZit2ItemTag = prepareChildTag(zjews01pendinfItemTag,'Zit2','Y');	
                    dom.XmlNode zjews01pendinfZtxt2ItemTag = prepareChildTag(zjews01pendinfItemTag,'Ztexti2',(!String.isEmpty(physicalInfoRef.SPEN_ItemReceivedRemark__c) ? physicalInfoRef.SPEN_ItemReceivedRemark__c : ''));	
                    dom.XmlNode zjews01pendinfZfechaItemTag = prepareChildTag(zjews01pendinfItemTag,'Zfechasolitem',(!String.isEmpty(string.ValueOf(physicalInfoRef.SPEN_ItemRequestedDate__c)) ? ((physicalInfoRef.SPEN_ItemRequestedDate__c).format('yyyyMMdd')) : ''));	
                    dom.XmlNode zjews01pendinfZhorasItemTag = prepareChildTag(zjews01pendinfItemTag,'Zhorasolitem',(!String.isEmpty(string.ValueOf(physicalInfoRef.SPEN_ItemRequestedDate__c)) ? ((physicalInfoRef.SPEN_ItemRequestedDate__c).format('HHmmss')) : ''));
                }
            }
            String plotXml = '';
            //zjews01plots
            //logic to handle multiple plots in one request
            if(!plotList.isEmpty())
            {
                system.debug('size of plot list is '+ plotList.size());
                for(SPEN_Plot__c plotRef : plotList)
                {
                    
                    if(!(plotRef.SPEN_Status__c=='To be delete' && String.isBlank(plotRef.SPEN_SupplyPointCode__c)))
                    {
                        if(plotIdentifier=='Y')
                        {
                            if(plotRef.SPEN_Status__c == 'To be delete')
                            {
                                plotOperation='B'; //Delete plot// should be B and not D
                                zidpropertyStr=(!String.isEmpty(plotRef.SPEN_PropertyID__c) ? plotRef.SPEN_PropertyID__c : '');
                            }
                            else                        
                            {
                                if(plotRef.SPEN_SupplyPointCode__c!=null)
                                {
                                    plotOperation='M'; //Update plot// should be M and not U
                                    zidpropertyStr=(!String.isEmpty(plotRef.SPEN_PropertyID__c) ? plotRef.SPEN_PropertyID__c : '');
                                }
                                else
                                {
                                    plotOperation='I'; //Insert Plot
                                    zidpropertyStr=(!String.isEmpty(plotRef.SPEN_PropertyID_Formula__c) ? plotRef.SPEN_PropertyID_Formula__c : '');
                                }
                            }
                        }
                        else if(plotIdentifier=='N' && plotRef.SPEN_SupplyPointCode__c!=null)
                        {
                            plotOperation='B'; // As plot identfier is N on case so all the plots will be send as delete.
                        }           
                         plotXml += '<item>';
                        plotXml += '<Zimb>' + (!String.isEmpty(plotOperation) ? plotOperation : '') + '</Zimb>';
                        plotXml += '<Zcodps>' + (!String.isEmpty(plotRef.SPEN_SupplyPointCode__c) ? plotRef.SPEN_SupplyPointCode__c : '') + '</Zcodps>';
                        plotXml += '<Zplotid>' + (!String.isEmpty(string.valueOf(plotRef.SPEN_PlotNumber__c)) ? string.valueOf(plotRef.SPEN_PlotNumber__c) : '') + '</Zplotid>';
                        plotXml += '<Zclaseps>' + (!String.isEmpty(plotRef.SPEN_MeteringPointClass__c) ? plotRef.SPEN_MeteringPointClass__c : '') + '</Zclaseps>';
                        plotXml += '<Zperfilps>' + (!String.isEmpty(plotRef.SPEN_MeteringPointProfile__c) ? plotRef.SPEN_MeteringPointProfile__c : '') + '</Zperfilps>';
                        plotXml += '<Zpotensoli>' + (!String.isEmpty(string.valueOf(plotRef.SPEN_MaxPowerkVA__c)) ? string.valueOf(plotRef.SPEN_MaxPowerkVA__c) : '') + '</Zpotensoli>';
                        plotXml += '<Zupoten>' + (!String.isEmpty(plotRef.SPEN_UNIT__c) ? plotRef.SPEN_UNIT__c : '') + '</Zupoten>';
                        plotXml += '<Zfutphase>' + (!String.isEmpty(plotRef.SPEN_Phase__c) ? plotRef.SPEN_Phase__c : '') + '</Zfutphase>';
                        plotXml += '<Ztipsuelo>' + (!String.isEmpty(plotRef.SPEN_FutureEarthType__c) ? plotRef.SPEN_FutureEarthType__c : '') + '</Ztipsuelo>';
                        plotXml += '<Ztipprop>' + (!String.isEmpty(plotRef.SPEN_PropertyType__c) ? plotRef.SPEN_PropertyType__c : '') + '</Ztipprop>';
                        plotXml += '<Zidproperty>' + (!String.isEmpty(zidpropertyStr) ? zidpropertyStr : '') + '</Zidproperty>';
                        plotXml += '<Zheatmt>' + (!String.isEmpty(plotRef.SPEN_HeatingMethod__c) ? plotRef.SPEN_HeatingMethod__c : '') + '</Zheatmt>';
                        plotXml += '<Zheatyp>' + (String.isNotBlank(plotRef.SPEN_HeatingTypeDescription__c) ?  plotRef.SPEN_HeatingTypeDescription__c : '') + '</Zheatyp>';
                        plotXml += '<Zdiscon>' + ((!String.isEmpty(plotRef.SPEN_IDREQTOBEDISCON__c) && plotRef.SPEN_IDREQTOBEDISCON__c!='Null') ? plotRef.SPEN_IDREQTOBEDISCON__c : '') + '</Zdiscon>';
                        plotXml += '<Zdiscondate>' + (!String.isEmpty(string.valueOf(plotRef.SPEN_DISCONNECT__c)) ? string.valueOf(plotRef.SPEN_DISCONNECT__c) : '') + '</Zdiscondate>';
                        plotXml += '<Zindtrataps>' + (!String.isEmpty(plotRef.SPEN_NOUSED__c) ? plotRef.SPEN_NOUSED__c : '') + '</Zindtrataps>';
                        plotXml += '<Zmpan1>' + (!String.isEmpty(plotRef.SPEN_MPAN1__c) ? plotRef.SPEN_MPAN1__c : '') + '</Zmpan1>';
                        plotXml += '<Zmpan2>' + (!String.isEmpty(plotRef.SPEN_MPAN2__c) ? plotRef.SPEN_MPAN2__c : '') + '</Zmpan2>';
                        plotXml += '<Zsupplier>' + (!String.isEmpty(plotRef.SPEN_Supplier__c) ? plotRef.SPEN_Supplier__c : '') + '</Zsupplier>';
                        plotXml += '<Zcablivsch>' + (!String.isEmpty(string.valueOf(plotRef.SPEN_CableHeadLive__c)) ? string.valueOf(plotRef.SPEN_CableHeadLive__c) : '') + '</Zcablivsch>';
                        plotXml += '<Zcablivact>' + (!String.isEmpty(string.valueOf(plotRef.SPEN_CableheadLiveScheduled__c)) ? string.valueOf(plotRef.SPEN_CableheadLiveScheduled__c) : '') + '</Zcablivact>';
                        plotXml += '<Zcodfinca>' + (!String.isEmpty(plotRef.SPEN_BuildingCode__c) ? plotRef.SPEN_BuildingCode__c : '') + '</Zcodfinca>';
                        plotXml += '<ZnumCasa>' + (!String.isEmpty(plotRef.SPEN_FlatNumber__c) ? plotRef.SPEN_FlatNumber__c : '') + '</ZnumCasa>';
                        plotXml += '<ZnumEdi>' + (!String.isEmpty(plotRef.SPEN_HouseNumber__c) ? plotRef.SPEN_HouseNumber__c : '') + '</ZnumEdi>';
                        plotXml += '<Zbuilding>' + (!String.isEmpty(plotRef.SPEN_BuildingName__c) ? plotRef.SPEN_BuildingName__c : '') + '</Zbuilding>';
                        plotXml += '<Zcalle>' + (!String.isEmpty(plotRef.SPEN_StreetName__c) ? plotRef.SPEN_StreetName__c : '') + '</Zcalle>';
                        plotXml += '<Zbarrio>' + (!String.isEmpty(plotRef.SPEN_Locality__c) ? plotRef.SPEN_Locality__c : '') + '</Zbarrio>';
                        plotXml += '<Zcity>' + (!String.isEmpty(plotRef.SPEN_TownCity__c) ? plotRef.SPEN_TownCity__c : '') + '</Zcity>';
                        plotXml += '<Zcodpais>' + (!String.isEmpty(plotRef.SPEN_Country__c) ? plotRef.SPEN_Country__c : '') + '</Zcodpais>';
                        plotXml += '<Zcodprov>' + (!String.isEmpty(plotRef.SPEN_County__c) ? plotRef.SPEN_County__c : '') + '</Zcodprov>';
                        plotXml += '<Zcodpostal>' + (!String.isEmpty(plotRef.SPEN_PostCode__c) ? plotRef.SPEN_PostCode__c : '') + '</Zcodpostal>';
                        plotXml += '<Zuprn>' + '' + '</Zuprn>';
                        plotXml += '<Zconnected>' + '' + '</Zconnected>';
                        plotXml += '<Zvoltagemet>' + '' + '</Zvoltagemet>';
                        plotXml += '<Numbed>' + (!String.isEmpty(plotRef.SPEN_NoofBedrooms__c) ? plotRef.SPEN_NoofBedrooms__c : '') + '</Numbed>';
                        plotXml += '<Evcharg>' + (!String.isEmpty(plotRef.SPEN_EVChargingType__c) ? plotRef.SPEN_EVChargingType__c : '') + '</Evcharg>';
                        plotXml += '<Evquan>' + (!String.isEmpty(string.valueOf(plotRef.SPEN_EVChargerQuantity__c)) ? string.valueOf(plotRef.SPEN_EVChargerQuantity__c) : '') + '</Evquan>';
                        plotXml += '<Evgrid>' + (!String.isEmpty(plotRef.SPEN_EVtoGrid__c) ? plotRef.SPEN_EVtoGrid__c : '') + '</Evgrid>';
                        plotXml += '<Zdistload>' + (!String.isEmpty(string.valueOf(plotRef.SPEN_DisturbinglLoadkw__c)) ? string.valueOf(plotRef.SPEN_DisturbinglLoadkw__c) : '') + '</Zdistload>';
                        plotXml += '<Zdistloadd>' + (!String.isEmpty(plotRef.SPEN_DisturbingLoadSummary__c) ? plotRef.SPEN_DisturbingLoadSummary__c : '') + '</Zdistloadd>';
                        plotXml += '<Zcommty>' + '' + '</Zcommty>';
                        plotXml += '<Zcomoth>' + '' + '</Zcomoth>';
                        plotXml += '</item>';
                        
                        /*dom.XmlNode zjews01plotsItemTag = zjews01plotsTag.addChildElement('item', null, null);
                        dom.XmlNode zjews01plotsZimbItemTag = prepareChildTag(zjews01plotsItemTag,'Zimb',plotOperation);
                        dom.XmlNode zjews01plotsZcodpsItemTag = prepareChildTag(zjews01plotsItemTag,'Zcodps',(!String.isEmpty(plotRef.SPEN_SupplyPointCode__c) ? plotRef.SPEN_SupplyPointCode__c : '')); //null
                        dom.XmlNode zjews01plotsZplotidItemTag = prepareChildTag(zjews01plotsItemTag,'Zplotid',(!String.isEmpty(string.valueOf(plotRef.SPEN_PlotNumber__c)) ? string.valueOf(plotRef.SPEN_PlotNumber__c) : ''));//(!String.isEmpty(string.valueOf(plotRef.SPEN_PlotNumber__c)) ? string.valueOf(plotRef.SPEN_PlotNumber__c) : '') 
                        dom.XmlNode zjews01plotsZclasepsItemTag = prepareChildTag(zjews01plotsItemTag,'Zclaseps',(!String.isEmpty(plotRef.SPEN_MeteringPointClass__c) ? plotRef.SPEN_MeteringPointClass__c : ''));
                        dom.XmlNode zjews01plotsZperfilpsItemTag = prepareChildTag(zjews01plotsItemTag,'Zperfilps',(!String.isEmpty(plotRef.SPEN_MeteringPointProfile__c) ? plotRef.SPEN_MeteringPointProfile__c : ''));
                        dom.XmlNode zjews01plotsZpotensoliItemTag = prepareChildTag(zjews01plotsItemTag,'Zpotensoli',(!String.isEmpty(string.valueOf(plotRef.SPEN_MaxPowerkVA__c)) ? string.valueOf(plotRef.SPEN_MaxPowerkVA__c) : ''));
                        dom.XmlNode zjews01plotsZupotenItemTag = prepareChildTag(zjews01plotsItemTag,'Zupoten',(!String.isEmpty(plotRef.SPEN_UNIT__c) ? plotRef.SPEN_UNIT__c : ''));
                        dom.XmlNode zjews01plotsZfutphaseItemTag = prepareChildTag(zjews01plotsItemTag,'Zfutphase',(!String.isEmpty(plotRef.SPEN_Phase__c) ? plotRef.SPEN_Phase__c : ''));
                        dom.XmlNode zjews01plotsZtipsueloItemTag = prepareChildTag(zjews01plotsItemTag,'Ztipsuelo',(!String.isEmpty(plotRef.SPEN_FutureEarthType__c) ? plotRef.SPEN_FutureEarthType__c : '')); //null
                        dom.XmlNode zjews01plotsZtippropItemTag = prepareChildTag(zjews01plotsItemTag,'Ztipprop',(!String.isEmpty(plotRef.SPEN_PropertyType__c) ? plotRef.SPEN_PropertyType__c : ''));
                        dom.XmlNode zjews01plotsZidpropertyItemTag = prepareChildTag(zjews01plotsItemTag,'Zidproperty',zidpropertyStr);//SPEN_PropertyID__c (For Modify & Delete) or SPEN_PropertyID_Formula__c (for Insert)
                        dom.XmlNode zjews01plotsZheatmtItemTag = prepareChildTag(zjews01plotsItemTag,'Zheatmt',(!String.isEmpty(plotRef.SPEN_HeatingMethod__c) ? plotRef.SPEN_HeatingMethod__c : ''));
                        dom.XmlNode zjews01plotsZheatypItemTag = prepareChildTag(zjews01plotsItemTag,'Zheatyp',(String.isNotBlank(plotRef.SPEN_HeatingTypeDescription__c) ?  plotRef.SPEN_HeatingTypeDescription__c : '')); //CRMD-7375
                        dom.XmlNode zjews01plotsZdisconItemTag = prepareChildTag(zjews01plotsItemTag,'Zdiscon',((!String.isEmpty(plotRef.SPEN_IDREQTOBEDISCON__c) && plotRef.SPEN_IDREQTOBEDISCON__c!='Null') ? plotRef.SPEN_IDREQTOBEDISCON__c : ''));
                        dom.XmlNode zjews01plotsZdiscondateItemTag = prepareChildTag(zjews01plotsItemTag,'Zdiscondate',(!String.isEmpty(string.valueOf(plotRef.SPEN_DISCONNECT__c)) ? string.valueOf(plotRef.SPEN_DISCONNECT__c) : ''));
                        dom.XmlNode zjews01plotsZindtratapsItemTag = prepareChildTag(zjews01plotsItemTag,'Zindtrataps',(!String.isEmpty(plotRef.SPEN_NOUSED__c) ? plotRef.SPEN_NOUSED__c : ''));
                        dom.XmlNode zjews01plotsZmpan1ItemTag = prepareChildTag(zjews01plotsItemTag,'Zmpan1',(!String.isEmpty(plotRef.SPEN_MPAN1__c) ? plotRef.SPEN_MPAN1__c : ''));
                        dom.XmlNode zjews01plotsZmpan2ItemTag = prepareChildTag(zjews01plotsItemTag,'Zmpan2',(!String.isEmpty(plotRef.SPEN_MPAN2__c) ? plotRef.SPEN_MPAN2__c : ''));
                        dom.XmlNode zjews01plotsZsupplierItemTag = prepareChildTag(zjews01plotsItemTag,'Zsupplier',(!String.isEmpty(plotRef.SPEN_Supplier__c) ? plotRef.SPEN_Supplier__c : ''));
                        dom.XmlNode zjews01plotsZcablivschItemTag = prepareChildTag(zjews01plotsItemTag,'Zcablivsch',(!String.isEmpty(string.valueOf(plotRef.SPEN_CableHeadLive__c)) ? string.valueOf(plotRef.SPEN_CableHeadLive__c) : ''));
                        dom.XmlNode zjews01plotsZcablivactItemTag = prepareChildTag(zjews01plotsItemTag,'Zcablivact',(!String.isEmpty(string.valueOf(plotRef.SPEN_CableheadLiveScheduled__c)) ? string.valueOf(plotRef.SPEN_CableheadLiveScheduled__c) : ''));
                        dom.XmlNode zjews01plotsZcodfincaItemTag = prepareChildTag(zjews01plotsItemTag,'Zcodfinca',(!String.isEmpty(plotRef.SPEN_BuildingCode__c) ? plotRef.SPEN_BuildingCode__c : ''));
                        dom.XmlNode zjews01plotsZnumCasaItemTag = prepareChildTag(zjews01plotsItemTag,'ZnumCasa',(!String.isEmpty(plotRef.SPEN_FlatNumber__c) ? plotRef.SPEN_FlatNumber__c : ''));
                        dom.XmlNode zjews01plotsZnumEdiItemTag = prepareChildTag(zjews01plotsItemTag,'ZnumEdi',(!String.isEmpty(plotRef.SPEN_HouseNumber__c) ? plotRef.SPEN_HouseNumber__c : ''));
                        dom.XmlNode zjews01plotsZbuildingItemTag = prepareChildTag(zjews01plotsItemTag,'Zbuilding',(!String.isEmpty(plotRef.SPEN_BuildingName__c) ? plotRef.SPEN_BuildingName__c : ''));
                        dom.XmlNode zjews01plotsZcalleItemTag = prepareChildTag(zjews01plotsItemTag,'Zcalle',(!String.isEmpty(plotRef.SPEN_StreetName__c) ? plotRef.SPEN_StreetName__c : ''));
                        dom.XmlNode zjews01plotsZbarrioItemTag = prepareChildTag(zjews01plotsItemTag,'Zbarrio',(!String.isEmpty(plotRef.SPEN_Locality__c) ? plotRef.SPEN_Locality__c : ''));
                        dom.XmlNode zjews01plotsZcityItemTag = prepareChildTag(zjews01plotsItemTag,'Zcity',(!String.isEmpty(plotRef.SPEN_TownCity__c) ? plotRef.SPEN_TownCity__c : ''));
                        dom.XmlNode zjews01plotsZcodpaisItemTag = prepareChildTag(zjews01plotsItemTag,'Zcodpais',(!String.isEmpty(plotRef.SPEN_Country__c) ? plotRef.SPEN_Country__c : ''));
                        dom.XmlNode zjews01plotsZcodprovItemTag = prepareChildTag(zjews01plotsItemTag,'Zcodprov',(!String.isEmpty(plotRef.SPEN_County__c) ? plotRef.SPEN_County__c : ''));
                        dom.XmlNode zjews01plotsZcodpostalItemTag = prepareChildTag(zjews01plotsItemTag,'Zcodpostal',(!String.isEmpty(plotRef.SPEN_PostCode__c) ? plotRef.SPEN_PostCode__c : ''));
                        dom.XmlNode zjews01plotsZuprnItemTag = prepareChildTag(zjews01plotsItemTag,'Zuprn',null);//(!String.isEmpty(plotRef.SPEN_UPRN__c) ? plotRef.SPEN_UPRN__c : '')
                        dom.XmlNode zjews01plotsZconnectedItemTag = prepareChildTag(zjews01plotsItemTag,'Zconnected',null);
                        dom.XmlNode zjews01plotsZvoltagemetItemTag = prepareChildTag(zjews01plotsItemTag,'Zvoltagemet',null);
                        dom.XmlNode zjews01plotsNumbedItemTag = prepareChildTag(zjews01plotsItemTag,'Numbed',(!String.isEmpty(plotRef.SPEN_NoofBedrooms__c) ? plotRef.SPEN_NoofBedrooms__c : ''));
                        dom.XmlNode zjews01plotsEvchargItemTag = prepareChildTag(zjews01plotsItemTag,'Evcharg',(!String.isEmpty(plotRef.SPEN_EVChargingType__c) ? plotRef.SPEN_EVChargingType__c : ''));
                        dom.XmlNode zjews01plotsEvquanItemTag = prepareChildTag(zjews01plotsItemTag,'Evquan',(!String.isEmpty(string.valueOf(plotRef.SPEN_EVChargerQuantity__c)) ? string.valueOf(plotRef.SPEN_EVChargerQuantity__c) : ''));
                        dom.XmlNode zjews01plotsEvgridItemTag = prepareChildTag(zjews01plotsItemTag,'Evgrid',(!String.isEmpty(plotRef.SPEN_EVtoGrid__c) ? plotRef.SPEN_EVtoGrid__c : ''));
                        dom.XmlNode zjews01plotsZdistloadItemTag = prepareChildTag(zjews01plotsItemTag,'Zdistload',(!String.isEmpty(string.valueOf(plotRef.SPEN_DisturbinglLoadkw__c)) ? string.valueOf(plotRef.SPEN_DisturbinglLoadkw__c) : ''));
                        dom.XmlNode zjews01plotsZdistloaddItemTag = prepareChildTag(zjews01plotsItemTag,'Zdistloadd',(!String.isEmpty(plotRef.SPEN_DisturbingLoadSummary__c) ? plotRef.SPEN_DisturbingLoadSummary__c : ''));
                        dom.XmlNode zjews01plotsZcommtyItemTag = prepareChildTag(zjews01plotsItemTag,'Zcommty',null);
                        dom.XmlNode zjews01plotsZcomothItemTag = prepareChildTag(zjews01plotsItemTag,'Zcomoth',null);*/
                    }                    
                }
                
            }
            dom.XmlNode zjews01plotsItemTag = zjews01plotsTag.addChildElement(plotXml, null, null);
            //zjews01qas
            dom.XmlNode zjews01qasZusuarioTag = prepareChildTag(zjews01qasTag,'Zusuario',userDetail);  //U334219
            dom.XmlNode zjews01qasZidtabletTag = prepareChildTag(zjews01qasTag,'Zidtablet',null);
            dom.XmlNode zjews01qasZcentrorespTag = prepareChildTag(zjews01qasTag,'Zcentroresp',null);
            
            //zjews01qashead
            dom.XmlNode zjews01qasheadBukrsTag = prepareChildTag(zjews01qasheadTag,'Bukrs','8300');
            dom.XmlNode zjews01qasheadZdescpcTag = prepareChildTag(zjews01qasheadTag,'Zdescpc',(!String.isEmpty(caseList[0].SPEN_CaseDescription__c) ? caseList[0].SPEN_CaseDescription__c : ''));//New Connection(s)
            dom.XmlNode zjews01qasheadZindcompanycTag = prepareChildTag(zjews01qasheadTag,'Zindcompany',(!String.isEmpty(caseList[0].SPEN_CompanyID__c) ? caseList[0].SPEN_CompanyID__c : ''));//SPD
            dom.XmlNode zjews01qasheadZlocalizTag = prepareChildTag(zjews01qasheadTag,'Zlocaliz',(!String.isEmpty(caseList[0].SPEN_SiteName__c) ? caseList[0].SPEN_SiteName__c : ''));
            dom.XmlNode zjews01qasheadZlocalizadicTag = prepareChildTag(zjews01qasheadTag,'Zlocalizadic',(!String.isEmpty(caseList[0].SPEN_ApplicantSiteIdentifier__c) ? caseList[0].SPEN_ApplicantSiteIdentifier__c : ''));
            dom.XmlNode zjews01qasheadZnumCasaTag = prepareChildTag(zjews01qasheadTag,'ZnumCasa',(!String.isEmpty(caseList[0].SPEN_SiteContactFlatNumber__c) ? caseList[0].SPEN_SiteContactFlatNumber__c : ''));
            dom.XmlNode zjews01qasheadZnumEdiTag = prepareChildTag(zjews01qasheadTag,'ZnumEdi',(!String.isEmpty(caseList[0].SPEN_SiteContactHouseNo__c) ? caseList[0].SPEN_SiteContactHouseNo__c : ''));
            dom.XmlNode zjews01qasheadZbuildingTag = prepareChildTag(zjews01qasheadTag,'Zbuilding',(!String.isEmpty(caseList[0].SPEN_SiteContactBuildingName__c) ? caseList[0].SPEN_SiteContactBuildingName__c : ''));
            dom.XmlNode zjews01qasheadZcalleTag = prepareChildTag(zjews01qasheadTag,'Zcalle',(!String.isEmpty(caseList[0].SPEN_SiteContactStreet__c) ? caseList[0].SPEN_SiteContactStreet__c : ''));
            dom.XmlNode zjews01qasheadZbarrioTag = prepareChildTag(zjews01qasheadTag,'Zbarrio',(!String.isEmpty(caseList[0].SPEN_SiteContactLocality__c) ? caseList[0].SPEN_SiteContactLocality__c : ''));
            dom.XmlNode zjews01qasheadZcityTag = prepareChildTag(zjews01qasheadTag,'Zcity',(!String.isEmpty(caseList[0].SPEN_SiteContactTownCity__c) ? caseList[0].SPEN_SiteContactTownCity__c : ''));
            dom.XmlNode zjews01qasheadZcodpaisTag = prepareChildTag(zjews01qasheadTag,'Zcodpais',(!String.isEmpty(caseList[0].SPEN_SiteContactCountry__c) ? caseList[0].SPEN_SiteContactCountry__c : ''));
            dom.XmlNode zjews01qasheadZcodprovTag = prepareChildTag(zjews01qasheadTag,'Zcodprov',(!String.isEmpty(caseList[0].SPEN_SiteContactCounty__c) ? caseList[0].SPEN_SiteContactCounty__c : ''));
            dom.XmlNode zjews01qasheadZcodpostalTag = prepareChildTag(zjews01qasheadTag,'Zcodpostal',(!String.isEmpty(caseList[0].SPEN_SiteContactPostCode__c) ? caseList[0].SPEN_SiteContactPostCode__c : ''));
            dom.XmlNode zjews01qasheadZcoodtutmxTag = prepareChildTag(zjews01qasheadTag,'Zcoodtutmx',(!String.isEmpty(caseList[0].SPEN_XCoOrdinate__c) ? caseList[0].SPEN_XCoOrdinate__c : ''));
            dom.XmlNode zjews01qasheadZcoodtutmyTag = prepareChildTag(zjews01qasheadTag,'Zcoodtutmy',(!String.isEmpty(caseList[0].SPEN_YCoOrdinate__c) ? caseList[0].SPEN_YCoOrdinate__c : ''));
            dom.XmlNode zjews01qasheadZcurenbTag = prepareChildTag(zjews01qasheadTag,'Zcurenb',(!String.isEmpty(caseList[0].SPEN_CustomerRef__c) ? caseList[0].SPEN_CustomerRef__c : ''));
            dom.XmlNode zjews01qasheadZpuornbTag = prepareChildTag(zjews01qasheadTag,'Zpuornb',(!String.isEmpty(caseList[0].SPEN_PONumber__c) ? caseList[0].SPEN_PONumber__c : ''));
            dom.XmlNode zjews01qasheadZcicnumTag = prepareChildTag(zjews01qasheadTag,'Zcicnum',(!String.isEmpty(caseList[0].SPEN_RaDaR__c) ? caseList[0].SPEN_RaDaR__c : ''));
            dom.XmlNode zjews01qasheadZreforigenTag = prepareChildTag(zjews01qasheadTag,'Zreforigen',null);
            dom.XmlNode zjews01qasheadZcodqascopTag = prepareChildTag(zjews01qasheadTag,'Zcodqascop',null);
            dom.XmlNode zjews01qasheadZpaymentTag = prepareChildTag(zjews01qasheadTag,'Zpayment',(!String.isEmpty(caseList[0].SPEN_PaymentDecision__c) ? caseList[0].SPEN_PaymentDecision__c : ''));
            dom.XmlNode zjews01qasheadZporciniTag = prepareChildTag(zjews01qasheadTag,'Zporcini',(!String.isEmpty(string.valueOf(caseList[0].SPEN_RequestedtoRelease__c)) ? string.valueOf(caseList[0].SPEN_RequestedtoRelease__c) : ''));
            dom.XmlNode zjews01qasheadZcommumediumTag = prepareChildTag(zjews01qasheadTag,'Zcommumedium','01');
            dom.XmlNode zjews01qasheadZenquitypeTag = prepareChildTag(zjews01qasheadTag,'Zenquitype','01');
            //CRMD-6888 : Rajat
            if('TRANSFER_QAS'.equalsIgnoreCase(operation)){
                dom.XmlNode zjews01qasheadZfechinireTag = prepareChildTag(zjews01qasheadTag,'Zfechinire',(String.isNotBlank(zfechinireDate) ? zfechinireDate : '' ));
                dom.XmlNode zjews01qasheadZfechfinreTag = prepareChildTag(zjews01qasheadTag,'Zfechfinre',(String.isNotBlank(zfechfinreDate) ? zfechfinreDate : '' ));
                dom.XmlNode zjews01qasheadZfechaaltaTag = prepareChildTag(zjews01qasheadTag,'Zfechaalta',(String.isNotBlank(zfechaaltaDateValue) ? zfechaaltaDateValue : '')); // Current Date - CR Transfer Date
                dom.XmlNode zjews01qasheadZhoraaltaTag = prepareChildTag(zjews01qasheadTag,'Zhoraalta',(String.isNotBlank(zhoraaltaTimeValue) ? zhoraaltaTimeValue : '')); // Time
                
            }else{
                dom.XmlNode zjews01qasheadZfechinireTag = prepareChildTag(zjews01qasheadTag,'Zfechinire',null);
                dom.XmlNode zjews01qasheadZfechfinreTag = prepareChildTag(zjews01qasheadTag,'Zfechfinre',null);
                dom.XmlNode zjews01qasheadZfechaaltaTag = prepareChildTag(zjews01qasheadTag,'Zfechaalta',null);
                dom.XmlNode zjews01qasheadZhoraaltaTag = prepareChildTag(zjews01qasheadTag,'Zhoraalta',null);
            }
             
            dom.XmlNode zjews01qasheadZfechaaltaprTag = prepareChildTag(zjews01qasheadTag,'Zfechaaltapr',zfechaaltaprDateValue);	// Mapping - Contact Recieved Date - CR Raised Date
            dom.XmlNode zjews01qasheadZhoraaltaprTag = prepareChildTag(zjews01qasheadTag,'Zhoraaltapr',zhoraaltaprTimeValue);	//151413	// Mapping - Contact Recieved Date time 
            dom.XmlNode zjews01qasheadZmutexclnumTag = prepareChildTag(zjews01qasheadTag,'Zmutexclnum',(!String.isEmpty(caseList[0].SPEN_MutuallyExclusiveQuoteRef__c) ? caseList[0].SPEN_MutuallyExclusiveQuoteRef__c : ''));
            dom.XmlNode zjews01qasheadZinteractnumTag = prepareChildTag(zjews01qasheadTag,'Zinteractnum',(!String.isEmpty(caseList[0].SPEN_InteractiveQuoteRef__c) ? caseList[0].SPEN_InteractiveQuoteRef__c : ''));
            dom.XmlNode zjews01qasheadVkorgTag = prepareChildTag(zjews01qasheadTag,'Vkorg',null);
            dom.XmlNode zjews01qasheadVtwegTag = prepareChildTag(zjews01qasheadTag,'Vtweg',null);
            dom.XmlNode zjews01qasheadSpartTag = prepareChildTag(zjews01qasheadTag,'Spart',null); 
            dom.XmlNode zjews01qasheadZclaseqasTag = prepareChildTag(zjews01qasheadTag,'Zclaseqas','E8-UENQAS');	//Mapping - Hardcoded
            dom.XmlNode zjews01qasheadZtipoqasTag = prepareChildTag(zjews01qasheadTag,'Ztipoqas','UQAS0001');	//Mapping - Hardcoded
            dom.XmlNode zjews01qasheadZcrgrupoTag = prepareChildTag(zjews01qasheadTag,'Zcrgrupo',(!String.isEmpty(caseList[0].SPEN_ConnectionType__c) ? caseList[0].SPEN_ConnectionType__c : ''));
            dom.XmlNode zjews01qasheadZtipsumTag = prepareChildTag(zjews01qasheadTag,'Ztipsum',(!String.isEmpty(caseList[0].SPEN_CustomerClass__c) ? caseList[0].SPEN_CustomerClass__c : ''));
            dom.XmlNode zjews01qasheadZclaseTag = prepareChildTag(zjews01qasheadTag,'Zclase',(!String.isEmpty(caseList[0].SPEN_CustomerRequestClass__c) ? caseList[0].SPEN_CustomerRequestClass__c : ''));//Customer Request Class Mapping
            dom.XmlNode zjews01qasheadZtipoTag = prepareChildTag(zjews01qasheadTag,'Ztipo',(!String.isEmpty(caseList[0].SPEN_JobType__c) ? caseList[0].SPEN_JobType__c : ''));
            dom.XmlNode zjews01qasheadZtipcrgrupoTag = prepareChildTag(zjews01qasheadTag,'Ztipcrgrupo',(!String.isEmpty(caseList[0].SPEN_DesignType__c) ? caseList[0].SPEN_DesignType__c : ''));
            dom.XmlNode zjews01qasheadZindpsTag = prepareChildTag(zjews01qasheadTag,'Zindps',plotIdentifier);//(!String.isEmpty(caseList[0].SPEN_Plots__c) ? caseList[0].SPEN_Plots__c : ''))
            dom.XmlNode zjews01qasheadZnumconTag = prepareChildTag(zjews01qasheadTag,'Znumcon',null);
            dom.XmlNode zjews01qasheadZoffertypeTag = prepareChildTag(zjews01qasheadTag,'Zoffertype',(!String.isEmpty(caseList[0].SPEN_QuotationType__c) ? caseList[0].SPEN_QuotationType__c : ''));	//null	//E2-UQUOTE
            dom.XmlNode zjews01qasheadZrdofferTag = prepareChildTag(zjews01qasheadTag,'Zrdoffer',zrdofferdateValue);	//06062023	// Mapping - Competent date (Offer Requested Date)
            dom.XmlNode zjews01qasheadZrhofferTag = prepareChildTag(zjews01qasheadTag,'Zrhoffer',zrhoffertimeValue);	//151543	//Mapping - Competent Time (hours)
            dom.XmlNode zjews01qasheadZpartyworkTag = prepareChildTag(zjews01qasheadTag,'Zpartywork',null);
            dom.XmlNode zjews01qasheadZphysicalinfTag = prepareChildTag(zjews01qasheadTag,'Zphysicalinf',zjews01controlPhyTagStr);	//null	//N	//TBC : Mapping or logic Akshay
            dom.XmlNode zjews01qasheadZpotenactTag = prepareChildTag(zjews01qasheadTag,'Zpotenact',(!String.isEmpty(string.valueOf(caseList[0].SPEN_ActualPower__c)) ? string.valueOf(caseList[0].SPEN_ActualPower__c) : ''));//01
            dom.XmlNode zjews01qasheadZupotenactTag = prepareChildTag(zjews01qasheadTag,'Zupotenact','KVA');	//null	//KVA
            dom.XmlNode zjews01qasheadZactphaseTag = prepareChildTag(zjews01qasheadTag,'Zactphase',(!String.isEmpty(caseList[0].SPEN_ActualPhase__c) ? caseList[0].SPEN_ActualPhase__c : ''));
            dom.XmlNode zjews01qasheadZtipsueloactTag = prepareChildTag(zjews01qasheadTag,'Ztipsueloact',(!String.isEmpty(caseList[0].SPEN_ActualEarth__c) ? caseList[0].SPEN_ActualEarth__c : ''));
            dom.XmlNode zjews01qasheadZconnecloadTag = prepareChildTag(zjews01qasheadTag,'Zconnecload',(!String.isEmpty(string.valueOf(caseList[0].SPEN_ConnectedLoadkVA__c)) ? string.valueOf(caseList[0].SPEN_ConnectedLoadkVA__c) : ''));
            dom.XmlNode zjews01qasheadZuconnecloadTag = prepareChildTag(zjews01qasheadTag,'Zuconnecload',null);
            dom.XmlNode zjews01qasheadZgenertypeTag = prepareChildTag(zjews01qasheadTag,'Zgenertype',(!String.isEmpty(caseList[0].SPEN_LegacyGenerationType__c) ? caseList[0].SPEN_LegacyGenerationType__c : ''));
            dom.XmlNode zjews01qasheadZpotensoliTag = prepareChildTag(zjews01qasheadTag,'Zpotensoli',(!String.isEmpty(String.valueOf(caseList[0].SPEN_RequiredPower__c)) ? String.valueOf(caseList[0].SPEN_RequiredPower__c) : ''));
            dom.XmlNode zjews01qasheadZupotenTag = prepareChildTag(zjews01qasheadTag,'Zupoten',null);
            dom.XmlNode zjews01qasheadZfutphaseTag = prepareChildTag(zjews01qasheadTag,'Zfutphase',(!String.isEmpty(caseList[0].SPEN_RequiredPhase__c) ? caseList[0].SPEN_RequiredPhase__c : ''));
            dom.XmlNode zjews01qasheadZtipsueloTag = prepareChildTag(zjews01qasheadTag,'Ztipsuelo',(!String.isEmpty(caseList[0].SPEN_RequiredEarth__C) ? caseList[0].SPEN_RequiredEarth__c : ''));
            dom.XmlNode zjews01qasheadZpotendlqlTag = prepareChildTag(zjews01qasheadTag,'Zpotendlql',(!String.isEmpty(String.valueOf(caseList[0].SPEN_Diversity__c)) ? String.valueOf(caseList[0].SPEN_Diversity__c) : ''));
            dom.XmlNode zjews01qasheadZupotendlqlTag = prepareChildTag(zjews01qasheadTag,'Zupotendlql','KVA'); //01	//KVA //TBC : Mapping
            dom.XmlNode zjews01qasheadZvoltagepocTag = prepareChildTag(zjews01qasheadTag,'Zvoltagepoc',(!String.isEmpty(caseList[0].SPEN_POCVoltage__c) ? caseList[0].SPEN_POCVoltage__c : ''));
            dom.XmlNode zjews01qasheadZvoltagemetTag = prepareChildTag(zjews01qasheadTag,'Zvoltagemet',(!String.isEmpty(caseList[0].SPEN_MeteringVoltage__c) ? caseList[0].SPEN_MeteringVoltage__c : ''));
            dom.XmlNode zjews01qasheadZmarsegbusTag = prepareChildTag(zjews01qasheadTag,'Zmarsegbus',(String.isNotBlank(caseList[0].SPEN_BusinessMarketSegment__c) ? caseList[0].SPEN_BusinessMarketSegment__c : '')); //CRMD-6888
            dom.XmlNode zjews01qasheadZmarketsegmTag = prepareChildTag(zjews01qasheadTag,'Zmarketsegm',(String.isNotBlank(caseList[0].SPEN_OfgemMarketSegment__c) ? caseList[0].SPEN_OfgemMarketSegment__c : '')); //CRMD-6888
            dom.XmlNode zjews01qasheadZnumcolTag = prepareChildTag(zjews01qasheadTag,'Znumcol',null);
            dom.XmlNode zjews01qasheadZcantidquaTag = prepareChildTag(zjews01qasheadTag,'Zcantidqua',null);
            dom.XmlNode zjews01qasheadZttqsdateTag = prepareChildTag(zjews01qasheadTag,'Zttqsdate',zttqsdateValue);	//TTQ Start Date
            dom.XmlNode zjews01qasheadZttqstimeTag = prepareChildTag(zjews01qasheadTag,'Zttqstime',zttqstimeValue);	//TTQ Start Time
            dom.XmlNode zjews01qasheadZintercoTag = prepareChildTag(zjews01qasheadTag,'Zinterco',null);
            dom.XmlNode zjews01qasheadZpormargenTag = prepareChildTag(zjews01qasheadTag,'Zpormargen',null);
            dom.XmlNode zjews01qasheadZmotreperiTag = prepareChildTag(zjews01qasheadTag,'Zmotreperi',null);
            dom.XmlNode zjews01qasheadZcancagentTag = prepareChildTag(zjews01qasheadTag,'Zcancagent',null);
            dom.XmlNode zjews01qasheadZcantimeTag = prepareChildTag(zjews01qasheadTag,'Zcantime',null);
            dom.XmlNode zjews01qasheadTaxk1Tag = prepareChildTag(zjews01qasheadTag,'Taxk1',null);
            dom.XmlNode zjews01qasheadZmotivaTag = prepareChildTag(zjews01qasheadTag,'Zmotiva',null);
            dom.XmlNode zjews01qasheadNumbedTag = prepareChildTag(zjews01qasheadTag,'Numbed',null);
            dom.XmlNode zjews01qasheadEvchargTag = prepareChildTag(zjews01qasheadTag,'Evcharg',(!String.isEmpty(caseList[0].SPEN_EVChargingCapabilities__c	) ? caseList[0].SPEN_EVChargingCapabilities__c : ''));
            dom.XmlNode zjews01qasheadEvquanTag = prepareChildTag(zjews01qasheadTag,'Evquan',(!String.isEmpty(caseList[0].SPEN_EVChargeQuantity__c	) ? caseList[0].SPEN_EVChargeQuantity__c : ''));
            dom.XmlNode zjews01qasheadEvgridTag = prepareChildTag(zjews01qasheadTag,'Evgrid',(!String.isEmpty(caseList[0].SPEN_EVtoGrid__c	) ? caseList[0].SPEN_EVtoGrid__c : ''));
            dom.XmlNode zjews01qasheadZheatmtTag = prepareChildTag(zjews01qasheadTag,'Zheatmt',(!String.isEmpty(caseList[0].SPEN_HeatingMethod__c) ? caseList[0].SPEN_HeatingMethod__c : ''));
            dom.XmlNode zjews01qasheadZheatypTag = prepareChildTag(zjews01qasheadTag,'Zheatyp',(!String.isEmpty(caseList[0].SPEN_HeatingType__c) ? caseList[0].SPEN_HeatingType__c : ''));
            dom.XmlNode zjews01qasheadZdistloadTag = prepareChildTag(zjews01qasheadTag,'Zdistload',(!String.isEmpty(caseList[0].SPEN_DisturbingLoadkw__c) ? caseList[0].SPEN_DisturbingLoadkw__c : ''));
            dom.XmlNode zjews01qasheadZdistloaddTag = prepareChildTag(zjews01qasheadTag,'Zdistloadd',(!String.isEmpty(caseList[0].SPEN_DisturbingLoadSummary__c) ? caseList[0].SPEN_DisturbingLoadSummary__c : ''));
            dom.XmlNode zjews01qasheadZcommtyTag = prepareChildTag(zjews01qasheadTag,'Zcommty',null);
            dom.XmlNode zjews01qasheadZcomothTag = prepareChildTag(zjews01qasheadTag,'Zcomoth',null);
            
            //zjews01sitecont
            dom.XmlNode zjews01sitecontZname1Tag = prepareChildTag(zjews01sitecontTag,'Zname1',(!String.isEmpty(caseList[0].SPEN_SiteContactFirstName__c) ? caseList[0].SPEN_SiteContactFirstName__c : ''));//Graeme
            dom.XmlNode zjews01sitecontZsurname11Tag = prepareChildTag(zjews01sitecontTag,'Zsurname11',(!String.isEmpty(caseList[0].SPEN_SiteContactLastName__c) ? caseList[0].SPEN_SiteContactLastName__c : ''));//'Lang'
            dom.XmlNode zjews01sitecontZtelefono1Tag = prepareChildTag(zjews01sitecontTag,'Ztelefono1',(!String.isEmpty(caseList[0].SPEN_SiteContactPhone__c) ? caseList[0].SPEN_SiteContactPhone__c : ''));//'01355111111'
            dom.XmlNode zjews01sitecontZmobile1Tag = prepareChildTag(zjews01sitecontTag,'Zmobile1',(!String.isEmpty(caseList[0].SPEN_SiteContactMobile__c) ? caseList[0].SPEN_SiteContactMobile__c : ''));//'08708111111'
            dom.XmlNode zjews01sitecontZemail1Tag = prepareChildTag(zjews01sitecontTag,'Zemail1',(!String.isEmpty(caseList[0].SPEN_SiteContactEmail__c) ? caseList[0].SPEN_SiteContactEmail__c : ''));//'jean.lang@spenergynetworks.co.uk'
            
            //zjews02custcorp
            dom.XmlNode zjews02custcorpKunnrTag = prepareChildTag(zjews02custcorpTag,'Kunnr',null);
            dom.XmlNode zjews02custcorpZname1Tag = prepareChildTag(zjews02custcorpTag,'Zname1',null);
            dom.XmlNode zjews02custcorpZposition2Tag = prepareChildTag(zjews02custcorpTag,'Zposition2',null);
            dom.XmlNode zjews02custcorpZsurname11Tag = prepareChildTag(zjews02custcorpTag,'Zsurname11',null);
            dom.XmlNode zjews02custcorpZnumCasa1Tag = prepareChildTag(zjews02custcorpTag,'ZnumCasa1',null);
            dom.XmlNode zjews02custcorpZnumEdi1Tag = prepareChildTag(zjews02custcorpTag,'ZnumEdi1',null);
            dom.XmlNode zjews02custcorpZbuilding1Tag = prepareChildTag(zjews02custcorpTag,'Zbuilding1',null);
            dom.XmlNode zjews02custcorpZcalle1Tag = prepareChildTag(zjews02custcorpTag,'Zcalle1',null);
            dom.XmlNode zjews02custcorpZbarrio1Tag = prepareChildTag(zjews02custcorpTag,'Zbarrio1',null);
            dom.XmlNode zjews02custcorpZcity1Tag = prepareChildTag(zjews02custcorpTag,'Zcity1',null);
            dom.XmlNode zjews02custcorpZcodpais1Tag = prepareChildTag(zjews02custcorpTag,'Zcodpais1',null);
            dom.XmlNode zjews02custcorpZcodprov1Tag = prepareChildTag(zjews02custcorpTag,'Zcodprov1',null);
            dom.XmlNode zjews02custcorpZcodpostal1Tag = prepareChildTag(zjews02custcorpTag,'Zcodpostal1',null);
            dom.XmlNode zjews02custcorpZregcompa2Tag = prepareChildTag(zjews02custcorpTag,'Zregcompa2',null);
            dom.XmlNode zjews02custcorpZtelefono1Tag = prepareChildTag(zjews02custcorpTag,'Ztelefono1',null);
            dom.XmlNode zjews02custcorpZmobile1Tag = prepareChildTag(zjews02custcorpTag,'Zmobile1',null);
            dom.XmlNode zjews02custcorpZfaxtn1Tag = prepareChildTag(zjews02custcorpTag,'Zfaxtn1',null);
            dom.XmlNode zjews02custcorpZemail1Tag = prepareChildTag(zjews02custcorpTag,'Zemail1',null);
            
            //zjews02developer
            dom.XmlNode zjews02developerKunnrTag = prepareChildTag(zjews02developerTag,'Kunnr',null);
            dom.XmlNode zjews02developerZname1Tag = prepareChildTag(zjews02developerTag,'Zname1',null);
            dom.XmlNode zjews02developerZposition2Tag = prepareChildTag(zjews02developerTag,'Zposition2',null);
            dom.XmlNode zjews02developerZsurname11Tag = prepareChildTag(zjews02developerTag,'Zsurname11',null);
            dom.XmlNode zjews02developerZnumCasa1Tag = prepareChildTag(zjews02developerTag,'ZnumCasa1',null);
            dom.XmlNode zjews02developerZnumEdi1Tag = prepareChildTag(zjews02developerTag,'ZnumEdi1',null);
            dom.XmlNode zjews02developerZbuilding1Tag = prepareChildTag(zjews02developerTag,'Zbuilding1',null);
            dom.XmlNode zjews02developerZcalle1Tag = prepareChildTag(zjews02developerTag,'Zcalle1',null);
            dom.XmlNode zjews02developerZbarrio1Tag = prepareChildTag(zjews02developerTag,'Zbarrio1',null);
            dom.XmlNode zjews02developerZcity1Tag = prepareChildTag(zjews02developerTag,'Zcity1',null);
            dom.XmlNode zjews02developerZcodpais1Tag = prepareChildTag(zjews02developerTag,'Zcodpais1',null);
            dom.XmlNode zjews02developerZcodprov1Tag = prepareChildTag(zjews02developerTag,'Zcodprov1',null);
            dom.XmlNode zjews02developerZcodpostal1Tag = prepareChildTag(zjews02developerTag,'Zcodpostal1',null);
            dom.XmlNode zjews02developerZregcompa2Tag = prepareChildTag(zjews02developerTag,'Zregcompa3',null);
            dom.XmlNode zjews02developerZtelefono1Tag = prepareChildTag(zjews02developerTag,'Ztelefono1',null);
            dom.XmlNode zjews02developerZmobile1Tag = prepareChildTag(zjews02developerTag,'Zmobile1',null);
            dom.XmlNode zjews02developerZfaxtn1Tag = prepareChildTag(zjews02developerTag,'Zfaxtn1',null);
            dom.XmlNode zjews02developerZemail1Tag = prepareChildTag(zjews02developerTag,'Zemail1',null);
            
            //zjtegendet        
            dom.XmlNode zjtegendetItemTag = zjtegendetTag.addChildElement('item', null, null);
            dom.XmlNode zjtegendetItemMandtTag = prepareChildTag(zjtegendetItemTag,'Mandt',null);
            dom.XmlNode zjtegendetItemZcodqasTag = prepareChildTag(zjtegendetItemTag,'Zcodqas',null);
            dom.XmlNode zjtegendetItemZcontTag = prepareChildTag(zjtegendetItemTag,'Zcont',null);
            dom.XmlNode zjtegendetItemZtechTag = prepareChildTag(zjtegendetItemTag,'Ztech',null);
            dom.XmlNode zjtegendetItemZfuelTag = prepareChildTag(zjtegendetItemTag,'Zfuel',null);
            dom.XmlNode zjtegendetItemZratinTag = prepareChildTag(zjtegendetItemTag,'Zratin',null);
            dom.XmlNode zjtegendetItemZcombTag = prepareChildTag(zjtegendetItemTag,'Zcomb',null);
            
            //zjtplogendt        
            dom.XmlNode zjtplogendtItemTag = zjtplogendtTag.addChildElement('item', null, null);
            dom.XmlNode zjtplogendtItemMandtTag = prepareChildTag(zjtplogendtItemTag,'Mandt',null);
            dom.XmlNode zjtplogendtItemZcodqasTag = prepareChildTag(zjtplogendtItemTag,'Zcodqas',null);
            dom.XmlNode zjtplogendtItemZcodpsTag = prepareChildTag(zjtplogendtItemTag,'Zcodps',null);
            dom.XmlNode zjtplogendtItemZplotidTag = prepareChildTag(zjtplogendtItemTag,'Zplotid',null);
            dom.XmlNode zjtplogendtItemZcontTag = prepareChildTag(zjtplogendtItemTag,'Zcont',null);
            dom.XmlNode zjtplogendtItemZtechTag = prepareChildTag(zjtplogendtItemTag,'Ztech',null);
            dom.XmlNode zjtplogendtItemZfuelTag = prepareChildTag(zjtplogendtItemTag,'Zfuel',null);
            dom.XmlNode zjtplogendtItemZZratinTag = prepareChildTag(zjtplogendtItemTag,'Zratin',null);
            dom.XmlNode zjtplogendtItemZcombTag = prepareChildTag(zjtplogendtItemTag,'Zcomb',null);
            
            
            xmlstring = doc.toXmlString();
            xmlstring =  xmlstring.replace('<Zjews01plots><','<Zjews01plots>');
            xmlstring = xmlstring.replace('/></Zjews01plots>','</Zjews01plots>');
            System.debug('xmlstring==> ' + xmlstring);
            
        }catch(Exception ex){
            System.debug('In class SPEN_SAPQASCallout : exception block='+ex.getMessage());
            SEL_LoggingService.log(ex);
        }
        return xmlstring;
    }
    
    
    
    public static dom.XmlNode prepareChildTag(dom.XmlNode parentNode, string tagName)
    {
        dom.XmlNode xmlNodeVar;
        parentNode.addChildElement(tagName, null, null);
        return xmlNodeVar;
    }
    public static dom.XmlNode prepareChildTag(dom.XmlNode parentNode, string tagName, String tagValue)
    {
        dom.XmlNode xmlNodeVar;
        parentNode.addChildElement(tagName, null, null).addTextNode(!String.isEmpty(tagValue) ? tagValue : '');
        return xmlNodeVar;
    }
    public static Integer getActivePlots(List<SPEN_Plot__c> plotList)
    {
        Integer activePlotCount=0;
        for(SPEN_Plot__C plotRef:plotList)
        {
            if(plotRef.SPEN_Status__c=='Active')
            {
               activePlotCount++;
            }
        }
        return activePlotCount;
    }
    
    
    
    //Akshay added below for Physical Information API
    public static string generatePhysInfoRequest(String phyInfoRef)
    {	
        String xmlstring = '';
        try
        {
            SPEN_PhysicalInformation__c physicalInfo = 	SPEN_PhysicalInformationSelector.getPhysicalInfoFromPhyInfoStrId(phyInfoRef);	//Added by Akshay
            
            List<User>	loggedInUser = new List<User>();
            loggedInUser = SPEN_UserInfoSelector.getLoggedInUsersInfo(); //TBC : if no value default System.Label.DefaultSAPUser
            //Time format values
            String dateValueHeader = system.now().format('yyyyMMdd');
            String dateValue = system.now().format('yyyyMMdd');
            String timeValue = system.now().format('HHmmss');
            String userDetail=(!String.isEmpty(loggedInUser[0].SPEN_SAPId__c) ? loggedInUser[0].SPEN_SAPId__c : System.Label.DefaultSAPUser);
            //String userDetail='700262';    
            
            //Physical Information supporting details Akshay
            String physicalInfoOperation='';
            String zit2Str='';
            String ztexti2Str='';
            String zfecharecitemStr='';
            String zhorarecitemStr='';
            
            
            DOM.Document doc = new DOM.Document();
            String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
            String xsi = 'urn:sap-com:document:sap:soap:functions:mc-style';
            dom.XmlNode rootTag = doc.createRootElement('Envelope', soapNS, 'soapenv');
            rootTag.setNamespace('urn', xsi);
            dom.XmlNode headerTag = rootTag.addChildElement('soapenv:Header', null, null);
            dom.XmlNode bodyTag = rootTag.addChildElement('soapenv:Body', null, null);
            dom.XmlNode zJws005SapcrcreatephysiNamsTag = bodyTag.addChildElement('urn:ZJws005SapcrcreatephysiNams', null, null);
            
            //ZJws001Sapcreateeditqas  //ZJws005SapcrcreatephysiNams 
            //dom.XmlNode iNotifiw51Tag = prepareChildTag(zJws001SapcreateeditqasTag,'INotifiw51',null);
            //dom.XmlNode zjews00headerTag = prepareChildTag(zJws001SapcreateeditqasTag,'Zjews00header');
            dom.XmlNode zcodqasTag = prepareChildTag(zJws005SapcrcreatephysiNamsTag,'Zcodqas',(!String.isEmpty(physicalInfo.SPEN_Case__r.SPEN_SAPReference__c) ? physicalInfo.SPEN_Case__r.SPEN_SAPReference__c : ''));
            
            dom.XmlNode zjews00headerTag = ZJws005SapcrcreatephysiNamsTag.addChildElement('Zjews00header', null, null);
            dom.XmlNode zjews00messageTag = ZJws005SapcrcreatephysiNamsTag.addChildElement('Zjews00message', null, null);
            dom.XmlNode zjews05letterTag = zJws005SapcrcreatephysiNamsTag.addChildElement('Zjews05letter', null, null);
            dom.XmlNode zjews05pendinfTag = zJws005SapcrcreatephysiNamsTag.addChildElement('Zjews05pendinf', null, null);
            dom.XmlNode zletterTag = prepareChildTag(zJws005SapcrcreatephysiNamsTag,'Zletter','N');//Always 'N' for physicalinf(Competent) API 
            
            //zjews00headerTag                
            dom.XmlNode zjews00headerLangTag = prepareChildTag(zjews00headerTag,'Language','E'); //Mapping - Should be hard code
            dom.XmlNode zjews00headerUserTag = prepareChildTag(zjews00headerTag,'User',userDetail); //Mapping - Sap Id //U334219 
            dom.XmlNode zjews00headerTimeTag = prepareChildTag(zjews00headerTag,'Time',dateValueHeader); //Mapping - current date in format ddmmyyyy
            dom.XmlNode zjews00headerHourTag = prepareChildTag(zjews00headerTag,'Hour',timeValue); //Mapping - current time
            
            //zjews00messageTag
            dom.XmlNode Zjews00messageItemTag = zjews00messageTag.addChildElement('item', null, null);
            dom.XmlNode Zjews00messageItemTypeTag = prepareChildTag(Zjews00messageItemTag,'Type',null);	
            dom.XmlNode Zjews00messageItemLangTag = prepareChildTag(Zjews00messageItemTag,'Language',null);	
            dom.XmlNode Zjews00messageItemIdTag = prepareChildTag(Zjews00messageItemTag,'Id',null);	
            dom.XmlNode Zjews00messageItemNumTag = prepareChildTag(Zjews00messageItemTag,'Number',null);	
            dom.XmlNode Zjews00messageItemMsgTag = prepareChildTag(Zjews00messageItemTag,'Message',null);
            
            //zjews01letter        //zjews05letter
            dom.XmlNode zjews05letterItemTag = zjews05letterTag.addChildElement('item', null, null);
            dom.XmlNode zjews05letterItemTemplTag = prepareChildTag(zjews05letterItemTag,'Zlettertemple',null);	
            dom.XmlNode zjews05letterItemZFieldTag = prepareChildTag(zjews05letterItemTag,'Zfield',null);	
            dom.XmlNode zjews05letterItemTxtTag = prepareChildTag(zjews05letterItemTag,'Text',null);
            
            //zjews01pendinf     //Zjews05pendinf
            //logic to handle multiple Physical Information in one request Akshay
            
            system.debug('physical information  is>>>> '+ physicalInfo);
            if(physicalInfo.SPEN_ItemID__c!=null)
            {
                physicalInfoOperation='M'; //Update Physical Information// should be M and not U
                zit2Str=(!String.isEmpty(physicalInfo.SPEN_ItemReceivedRemark__c) ? 'Y' : 'N');
                ztexti2Str=(!String.isEmpty(physicalInfo.SPEN_ItemReceivedRemark__c) ? physicalInfo.SPEN_ItemReceivedRemark__c : '');
                zfecharecitemStr=(!String.isEmpty(string.ValueOf(physicalInfo.SPEN_ItemReceivedOn__c)) ? ((physicalInfo.SPEN_ItemReceivedOn__c).format('yyyyMMdd')) : '');
                zhorarecitemStr=(!String.isEmpty(string.ValueOf(physicalInfo.SPEN_ItemReceivedOn__c)) ? ((physicalInfo.SPEN_ItemReceivedOn__c).format('HHmmss')) : '');
                //ztexti1Str = (!String.isEmpty(physicalInfo.SPEN_ItemRequestRemark__c) ? physicalInfo.SPEN_ItemRequestRemark__c : '');
            }
            else
            {
                physicalInfoOperation='I'; //Insert Physical Information
                zit2Str='N';
                ztexti2Str='';
                zfecharecitemStr='';
                zhorarecitemStr='';
                //ztexti1Str = physicalInfo.SPEN_ItemRequestRemark__c+' {Ref:'+physicalInfo.Id+'}';
            }
            
            //dom.XmlNode zjews05pendinfItemTag = zjews05pendinfTag.addChildElement('item', null, null);
            dom.XmlNode zjews05pendinfZimbItemTag = prepareChildTag(zjews05pendinfTag,'Zimb',physicalInfoOperation);
            dom.XmlNode zjews05pendinfZidiItemTag = prepareChildTag(zjews05pendinfTag,'Ziditem',(!String.isEmpty(physicalInfo.SPEN_ItemID__c) ? physicalInfo.SPEN_ItemID__c : ''));
            dom.XmlNode zjews05pendinfZClassItemTag = prepareChildTag(zjews05pendinfTag,'Zclaseitem',(!String.isEmpty(physicalInfo.SPEN_ItemClass__c) ? physicalInfo.SPEN_ItemClass__c : ''));	
            dom.XmlNode zjews05pendinfZperFiliItemTag = prepareChildTag(zjews05pendinfTag,'Zperfilitem',(!String.isEmpty(physicalInfo.SPEN_ItemProfile__c) ? physicalInfo.SPEN_ItemProfile__c : ''));	
            dom.XmlNode zjews05pendinfZit1ItemTag = prepareChildTag(zjews05pendinfTag,'Zit1','Y');	
            dom.XmlNode zjews05pendinfZZtxt1ItemTag = prepareChildTag(zjews05pendinfTag,'Ztexti1',(!String.isEmpty(physicalInfo.SPEN_ItemRequestRemark__c) ? physicalInfo.SPEN_ItemRequestRemark__c : ''));	
            dom.XmlNode zjews05pendinfZfetchItemTag = prepareChildTag(zjews05pendinfTag,'Zfecharecitem',zfecharecitemStr);	
            dom.XmlNode zjews05pendinfZhoracItemTag = prepareChildTag(zjews05pendinfTag,'Zhorarecitem',zhorarecitemStr);	
            dom.XmlNode zjews05pendinfZit2ItemTag = prepareChildTag(zjews05pendinfTag,'Zit2',zit2Str);	
            dom.XmlNode zjews05pendinfZtxt2ItemTag = prepareChildTag(zjews05pendinfTag,'Ztexti2',ztexti2Str);	
            dom.XmlNode zjews05pendinfZfechaItemTag = prepareChildTag(zjews05pendinfTag,'Zfechasolitem',(!String.isEmpty(string.ValueOf(physicalInfo.SPEN_ItemRequestedDate__c)) ? ((physicalInfo.SPEN_ItemRequestedDate__c).format('yyyyMMdd')) :''));	
            dom.XmlNode zjews05pendinfZhorasItemTag = prepareChildTag(zjews05pendinfTag,'Zhorasolitem',(!String.isEmpty(string.ValueOf(physicalInfo.SPEN_ItemRequestedDate__c)) ? ((physicalInfo.SPEN_ItemRequestedDate__c).format('HHmmss')) : ''));
            
            xmlstring = doc.toXmlString();
            System.debug('xmlstring==> ' + xmlstring);    
        }
        catch(Exception ex){
            System.debug('In class SPEN_SAPCreateEditQASService method generatePhysInfoRequest: exception block='+ex.getMessage()+ex.getLineNumber()+ex.getCause()+ex.getStackTraceString());
            SEL_LoggingService.log(ex);
        }
        return xmlstring;
    }
    
}