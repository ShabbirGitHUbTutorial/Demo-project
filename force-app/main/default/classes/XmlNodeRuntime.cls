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

/**
 * Utility class with methods related to dynamic/reflection aspect of Apex language
 * @see RuntimeTest
 */
public with sharing class XmlNodeRuntime 
{
	/**
	 * @return Running type of object passed in parameter.
	 * This method returns null if type is not accessible - when class is private
	 * or when it's part of anonymous script. In that case, getRunningTypeName() should be used instead.
	 */
	public static Type getType(Object o) 
	{
		return getType(o, 'Invalid conversion from runtime type ', ' to Date');
	}

	private static Type getType(Object o, String open, String close) 
	{
		return Type.forName(getTypeName(o, open, close));
	}

	@SuppressWarnings('PMD.CodeBestPracticesReturnStatements')
	private static String getTypeName(Object o, String open, String close) 
	{
		if (o == null) { throw new NullPointerException(); }

		try 
		{
			Date d = (Date) o;
			return 'Date';
		} 
		catch (Exception ex) 
		{
			return ex.getMessage().substringBetween(open, close);
		}
	}

	/**
	 * @return returns Type of given list single element
	 * */
	public static Type getListItemType(List<Object> o) 
	{
		return getType(o, 'List<', '>');
	}
}