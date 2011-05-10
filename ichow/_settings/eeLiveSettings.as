package org.ichow.settings 
{
	import flash.utils.Dictionary;
	import org.igniterealtime.xiff.core.EscapedJID;
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class eeLiveSettings 
	{
		public static var flashvars:Object = { };
		
		public static var JID:EscapedJID;
		
		public static var PRESENCES:Dictionary=new Dictionary();
		
		public static const CHECK_POLICY:Boolean = true;
		public static const SERVER_PORT:int = 5222;
		
		public static var CHAT_NAME:String = "eeLiveDiv";
		public static var CHAT_MIN_WIDTH:int = 198;
		public static var CHAT_MIN_HEIGHT:int = 600;
		
		public static var CHAT_MAX_WIDTH:int = 504;
		public static var CHAT_MAX_HEIGHT:int = 600;
		
		public static var SERVER_IP:String = "openfire.tt.gzedu.com";
		public static var CONFERENCE:String = "openfire.tt.gzedu.com";
		public static var RESOURCE_NAME:String = "eelive's resource";
		
		public static var USER_NAME:String = "iccc";
		public static var NICK_NAME:String = "团长";
		public static var PASS_WORD:String = "iccc";
		public static var ROOM_ID:String = "祖阿曼";
		
		public static var AUTO_LOGIN:Boolean = false;
		public static var ANONYMOUS:Boolean = false;
		
		public static var ASSETS_URL:String = "assets/skin.swf";
		public static var FACE_URL:String = "assets/face.xml";
		public static var HEAD_URL:String = "assets/head.xml";
		public static var SKIN_URL:String = "assets/skins.xml";
		
		public static const STATUS_LOGIN:int = 2;
		public static const STATUS_LOGOUT:int = -2;
		
		public static const STATUS_LOADING:int = 0;
		
		public static const STATUS_ON:int = 1;
		public static const STATUS_OFF:int = -1;
		
		public function eeLiveSettings() 
		{
			
		}
		
	}

}