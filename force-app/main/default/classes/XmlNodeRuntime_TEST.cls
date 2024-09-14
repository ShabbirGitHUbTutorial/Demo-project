/**
* MIT License
*
* Copyright (c) 2019 Piotr Kożuchowski
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
@IsTest(IsParallel=true)
public with sharing class XmlNodeRuntime_TEST 
{
	public class ExampleClass {
    }

	@IsTest
	static void getTypeForCustomClass() 
	{
		ExampleClass instance = new ExampleClass();
		System.assertEquals(ExampleClass.class, XmlNodeRuntime.getType(instance), 'The type must be ExampleClass');
	}

	@IsTest
	static void getTypeForDate() 
	{
		Date instance = Date.today();
		System.assertEquals(Date.class, XmlNodeRuntime.getType(instance), 'The type must be a DATE class.');
	}

	@IsTest
	static void getListItemType() 
	{
		System.assertEquals(Account.class, XmlNodeRuntime.getListItemType(new List<Account>()), 'The list type must be List<Account>');

		List<SObject> records = new List<Opportunity>();
		System.assertEquals(Opportunity.class, XmlNodeRuntime.getListItemType(records), 'The list type must be List<Opportunity>');
	}
}