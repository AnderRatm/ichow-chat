
package org.ichow.eelive.managers
{
	public class StringUtils {
    
    /**
     * Unescapes the String by converting HTML escape sequences back into normal
     * <p/>
     * characters.
     *
     * @param string the string to unescape.
     * @return the string with appropriate characters unescaped.
     */

   public static function unescapeHTML(string:String):String {
    	string = string.replace(/[\r\n]/g, "<br>");
    	string = string.replace(/\\\\/g, "\\")
    	string = string.replace(/&lt;/g, "<");
		string = string.replace(/&gt;/g, ">"); 
 		string = string.replace(/&quot;/g, '"');
		string = string.replace(/&amp;/g, "&");

        return string;

    }

    /**
     * Escapes the String by converting html to escaped string.
     * <p/>
     * characters.
     *
     * @param string the string to escape.
     * @return the string with appropriate characters escaped.
     */

	//if we use the literal regexp notation, flex gets confused and thinks the quote starts a string
	private static var quoteregex:RegExp = new RegExp('"', "g");
	
    public static function escapeHTML(string:String):String {
    	string = string.replace(/<br>/g, "\n");
    	string = string.replace(/&/g, "&amp;");
    	string = string.replace(/</g, "&lt;");
     	string = string.replace(/>/g, "&gt;");
   		string = string.replace(quoteregex, "&quot;");
   	//	string = string.replace(/\\/g, "\\\\");

        return string;

    }
    
    private static var alphabet:String = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXY';
    
    public static function randomString(length:int):String {
    	var result:String = "";
    	while(length--) {
    		result += alphabet.charAt(Math.floor(Math.random() * alphabet.length));
    	}
    	return result;
    }
	}
}