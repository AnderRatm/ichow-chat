package org.ichow._util 
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class ChatUtil 
	{
		private static var imgReg:RegExp =/<(i|I)(m|M)(g|G).*?\/>/;
		private static var srcReg:RegExp =/(s|S)(r|R)(c|C)*=*('|")?(\w|\\|\/|\.)+('|"| *|>)?/g;
		private static var htmlReg:RegExp =/<\/?(html|body)>/ig;
		
		private static var faceReg:RegExp =/\[\/.*?\]/;
		private static var facesReg:RegExp =/\[\/.*?\]/g;
		//图片对象数组 [{source:'',code:''},{...}]
		public static var images:Dictionary;
		
		/**
		 * 转换到发送格式
		 * @param	html	: html字符串  <html><body>...
		 * @return  string  : 发送格式 <p>..[/face]..</p>
		 */
		public static function escapeImg(html:String):String {
			//trace("send pre:" + html);
			if (!images) return "";
			var str:String = html.replace(htmlReg, "");
			var srcList:Array = str.match(srcReg);
			for each(var i in srcList) {
				var sign:String = i.indexOf("'") == -1?'"':'"';
				var url:String = i.substring(i.indexOf(sign) + 1, i.lastIndexOf(sign));
				//全部改小写..
				url = url.toLowerCase();
				str = str.replace(imgReg, images[url]);
			}
			//trace("send: " + str);
			return str;
		}
		/**
		 * 转换到html格式
		 * @param	str 	: 字符<p>xxxx[/face]xxx</p>
		 * @return  string 	: html格式  <html>...<img../>..</html>
		 */
		public static function unescapeImg(str:String):String {
			if (!images) return "";
			var html:String = "<html><body>" + str + "</body></html>";
			var faceList:Array = html.match(facesReg);
			for each(var i in faceList) {
				html = html.replace(faceReg, '<img src="' + images[i] + '" />');
			}
			//trace("get: " + html);
			return html;
		}
		
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