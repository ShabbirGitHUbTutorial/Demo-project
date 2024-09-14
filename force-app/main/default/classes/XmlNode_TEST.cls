/**
* MIT License
*
* Copyright (c) 2018 Piotr Kożuchowski
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/
@IsTest
@SuppressWarnings('PMD.ExcessivePublicCount')
private class XmlNode_TEST 
{
	@SuppressWarnings('PMD.CodeBestPracticesUseNamedCredentials')
	private final static String
			NAMESPACE = 'http://soap.sforce.com/2006/04/metadata',
			PREFIX = '',
			PROFILE_XML = ''
					+ '<?xml version="1.0" encoding="UTF-8"?>'
					+ '<Profile xmlns="http://soap.sforce.com/2006/04/metadata">'
					+ '    <classAccesses>'
					+ '        <apexClass>AccountSelector</apexClass>'
					+ '        <enabled>true</enabled>'
					+ '    </classAccesses>'
					+ '    <classAccesses>'
					+ '        <apexClass>AccountTriggerHandler</apexClass>'
					+ '        <enabled>true</enabled>'
					+ '    </classAccesses>'
					+ '    <custom>false</custom>'
					+ '    <fieldPermissions>'
					+ '        <editable>false</editable>'
					+ '        <field>Log__c.ApexClass__c</field>'
					+ '        <readable>false</readable>'
					+ '    </fieldPermissions>'
					+ '    <fieldPermissions>'
					+ '        <editable>false</editable>'
					+ '        <field>Log__c.LoggingLevel__c</field>'
					+ '        <readable>false</readable>'
					+ '    </fieldPermissions>'
					+ '    <layoutAssignments>'
					+ '        <layout>Account-Account Layout</layout>'
					+ '    </layoutAssignments>'
					+ '    <layoutAssignments>'
					+ '        <layout>LogRetention__mdt-Logging Setting Layout</layout>'
					+ '    </layoutAssignments>'
					+ '    <objectPermissions>'
					+ '        <allowCreate>true</allowCreate>'
					+ '        <allowDelete>true</allowDelete>'
					+ '        <allowEdit>true</allowEdit>'
					+ '        <allowRead>true</allowRead>'
					+ '        <modifyAllRecords>true</modifyAllRecords>'
					+ '        <object>Log__c</object>'
					+ '        <viewAllRecords>true</viewAllRecords>'
					+ '    </objectPermissions>'
					+ '    <objectPermissions>'
					+ '        <allowCreate>true</allowCreate>'
					+ '        <allowDelete>true</allowDelete>'
					+ '        <allowEdit>true</allowEdit>'
					+ '        <allowRead>true</allowRead>'
					+ '        <modifyAllRecords>true</modifyAllRecords>'
					+ '        <object>LoggingEvent__e</object>'
					+ '        <viewAllRecords>true</viewAllRecords>'
					+ '    </objectPermissions>'
					+ '    <pageAccesses>'
					+ '        <apexPage>TestPage</apexPage>'
					+ '        <enabled>true</enabled>'
					+ '    </pageAccesses>'
					+ '    <tabVisibilities>'
					+ '        <tab>Log__c</tab>'
					+ '        <visibility>DefaultOn</visibility>'
					+ '    </tabVisibilities>'
					+ '    <tabVisibilities>'
					+ '        <tab>Test</tab>'
					+ '        <visibility>DefaultOn</visibility>'
					+ '    </tabVisibilities>'
					+ '    <userLicense>Salesforce</userLicense>'
					+ '    <userPermissions>'
					+ '        <enabled>true</enabled>'
					+ '        <name>ActivateContract</name>'
					+ '    </userPermissions>'
					+ '    <userPermissions>'
					+ '        <enabled>true</enabled>'
					+ '        <name>ActivateOrder</name>'
					+ '    </userPermissions>'
					+ '    <userPermissions>'
					+ '        <enabled>true</enabled>'
					+ '        <name>ActivitiesAccess</name>'
					+ '    </userPermissions>'
					+ '    <uumacjules>'
					+ '        <test1>'
					+ '            <test2>'
					+ '                <valtest>mac</valtest>'
					+ '            </test2>'
					+ '        </test1>'
					+ '    </uumacjules>'
					+ '</Profile>';

	/*Root Element must extend XmlRootNode*/
	public class ProfileNode extends XmlNode.XmlRootNode 
	{
		public Boolean custom;
		public String userLicense;
		public List<ClassAccessNode> classAccesses = new List<ClassAccessNode>();
		public List<FieldPermissionNode> fieldPermissions = new List<FieldPermissionNode>();
		public List<ObjectPermissionNode> objectPermissions = new List<ObjectPermissionNode>();
		public List<TabVisibilityNode> tabVisibilities = new List<TabVisibilityNode>();
		public List<LayoutAssignmentNode> layoutAssignments = new List<LayoutAssignmentNode>();
		public List<PageAccessNode> pageAccesses = new List<PageAccessNode>();
		public List<UserPermissionNode> userPermissions = new List<UserPermissionNode>();
		public List<Uumacjules> uumacjules = new List<Uumacjules>();

		protected override void registerXML() 
		{
			registerChildren(classAccesses, 'classAccesses', NAMESPACE, PREFIX);
			this.custom = (Boolean) registerTextNode(Boolean.class, 'custom', NAMESPACE, PREFIX, custom);
			registerChildren(fieldPermissions, 'fieldPermissions', NAMESPACE, PREFIX);
			registerChildren(layoutAssignments, 'layoutAssignments', NAMESPACE, PREFIX);
			registerChildren(objectPermissions, 'objectPermissions', NAMESPACE, PREFIX);
			registerChildren(pageAccesses, 'pageAccesses', NAMESPACE, PREFIX);
			registerChildren(tabVisibilities, 'tabVisibilities', NAMESPACE, PREFIX);
			this.userLicense = (String) registerTextNode(String.class, 'userLicense', NAMESPACE, PREFIX, userLicense);
			registerChildren(userPermissions, 'userPermissions', NAMESPACE, PREFIX);
			registerChildren(uumacjules, 'uumacjules', NAMESPACE, PREFIX);
		}
	}

	public class ClassAccessNode extends XmlNode 
	{
		public String apexClass;
		public Boolean enabled;

		protected override void registerXML() 
		{
			this.apexClass = (String) registerTextNode(String.class, 'apexClass', NAMESPACE, PREFIX, apexClass);
			this.enabled = (Boolean) registerTextNode(Boolean.class, 'enabled', NAMESPACE, PREFIX, enabled);
		}
	}

	public class FieldPermissionNode extends XmlNode 
	{
		public String field;
		public Boolean editable;
		public Boolean readable;

		protected override void registerXML() 
		{
			this.editable = (Boolean) registerTextNode(Boolean.class, 'editable', NAMESPACE, PREFIX, editable);
			this.field = (String) registerTextNode(String.class, 'field', NAMESPACE, PREFIX, field);
			this.readable = (Boolean) registerTextNode(Boolean.class, 'readable', NAMESPACE, PREFIX, readable);
		}
	}

	public class ObjectPermissionNode extends XmlNode 
	{
		public String objectX;
		public Boolean allowCreate;
		public Boolean allowDelete;
		public Boolean allowEdit;
		public Boolean allowRead;
		public Boolean modifyAllRecords;
		public Boolean viewAllRecords;

		protected override void registerXML() 
		{
			this.allowCreate = (Boolean) registerTextNode(Boolean.class, 'allowCreate', NAMESPACE, PREFIX, allowCreate);
			this.allowDelete = (Boolean) registerTextNode(Boolean.class, 'allowDelete', NAMESPACE, PREFIX, allowDelete);
			this.allowEdit = (Boolean) registerTextNode(Boolean.class, 'allowEdit', NAMESPACE, PREFIX, allowEdit);
			this.allowRead = (Boolean) registerTextNode(Boolean.class, 'allowRead', NAMESPACE, PREFIX, allowRead);
			this.modifyAllRecords = (Boolean) registerTextNode(Boolean.class, 'modifyAllRecords', NAMESPACE, PREFIX, modifyAllRecords);
			this.objectX = (String) registerTextNode(String.class, 'object', NAMESPACE, PREFIX, objectX);
			this.viewAllRecords = (Boolean) registerTextNode(Boolean.class, 'viewAllRecords', NAMESPACE, PREFIX, viewAllRecords);
		}
	}

	public class PageAccessNode extends XmlNode 
	{
		public String apexPage;
		public Boolean enabled;

		protected override void registerXML() 
		{
			this.apexPage = (String) registerTextNode(String.class, 'apexPage', NAMESPACE, PREFIX, apexPage);
			this.enabled = (Boolean) registerTextNode(Boolean.class, 'enabled', NAMESPACE, PREFIX, enabled);
		}
	}

	public class TabVisibilityNode extends XmlNode 
	{
		public String tab;
		public String visibility;

		protected override void registerXML() 
		{
			this.tab = (String) registerTextNode(String.class, 'tab', NAMESPACE, PREFIX, tab);
			this.visibility = (String) registerTextNode(String.class, 'visibility', NAMESPACE, PREFIX, visibility);
		}
	}

	public class LayoutAssignmentNode extends XmlNode 
	{
		public String layout;

		protected override void registerXML() 
		{
			this.layout = (String) registerTextNode(String.class, 'layout', NAMESPACE, PREFIX, layout);
		}
	}

	public class UserPermissionNode extends XmlNode 
	{
		public Boolean enabled;
		public String name;

		protected override void registerXML() 
		{
			this.enabled = (Boolean) registerTextNode(Boolean.class, 'enabled', NAMESPACE, PREFIX, enabled);
			this.name = (String) registerTextNode(String.class, 'name', NAMESPACE, PREFIX, name);
		}
	}

	public class Uumacjules extends XmlNode 
	{
		public List<Test1> test1 = new List<Test1>();

		protected override void registerXML() 
		{
			registerChildren(test1, 'test1', NAMESPACE, PREFIX);
		}
	}

	public class Test1 extends XmlNode 
	{
		public List<Test2> test2 = new List<Test2>();

		protected override void registerXML() 
		{
			registerChildren(test2, 'test2', NAMESPACE, PREFIX);
		}
	}

	public class Test2 extends XmlNode 
	{
		public String valtest;

		protected override void registerXML() 
		{
			this.valtest = (String) registerTextNode(String.class, 'valtest', NAMESPACE, PREFIX, valtest);
		}
	}

	/**
	 * @description
	 * XML string is deserialized to ProfileNode class.
	 */
	@IsTest
	static void testDeserializationToProfileNodeClass() 
	{
		ProfileNode profileNode = new ProfileNode();
		profileNode.load(PROFILE_XML);
		//System.debug(JSON.serialize(profileNode));
		System.assertEquals('{' +
				'"uumacjules":[{"test1":[{"test2":[{"valtest":"mac"}]}]}],' +
				'"userPermissions":[' +
				'{"name":"ActivateContract","enabled":true},' +
				'{"name":"ActivateOrder","enabled":true},' +
				'{"name":"ActivitiesAccess","enabled":true}],' +

				'"userLicense":"Salesforce",' +

				'"tabVisibilities":[' +
				'{"visibility":"DefaultOn","tab":"Log__c"},' +
				'{"visibility":"DefaultOn","tab":"Test"}],' +

				'"pageAccesses":[' +
				'{"enabled":true,"apexPage":"TestPage"}],' +

				'"objectPermissions":[' +
				'{"viewAllRecords":true,"objectX":"Log__c","modifyAllRecords":true,"allowRead":true,"allowEdit":true,"allowDelete":true,"allowCreate":true},' +
				'{"viewAllRecords":true,"objectX":"LoggingEvent__e","modifyAllRecords":true,"allowRead":true,"allowEdit":true,"allowDelete":true,"allowCreate":true}],' +

				'"layoutAssignments":[' +
				'{"layout":"Account-Account Layout"},' +
				'{"layout":"LogRetention__mdt-Logging Setting Layout"}],' +

				'"fieldPermissions":[' +
				'{"readable":false,"field":"Log__c.ApexClass__c","editable":false},' +
				'{"readable":false,"field":"Log__c.LoggingLevel__c","editable":false}],' +

				'"custom":false,' +

				'"classAccesses":[' +
				'{"enabled":true,"apexClass":"AccountSelector"},' +
				'{"enabled":true,"apexClass":"AccountTriggerHandler"}]' +

				'}',
				JSON.serialize(profileNode),
				'The object must match the projected JSON structure/data'
		);
	}
}