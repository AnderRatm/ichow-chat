package org.ichow.eelive.events
{
	import flash.events.Event;
	
	import org.igniterealtime.xiff.core.UnescapedJID;

	public class UserAccessEvent extends Event
	{
		
		public static const CONNECTED:String = "userConnected";
		public static const LOGIN:String = "userLogin";
		public static const LOGOUT:String = "userLogout";
		
		public var username:String;
		public var unescapedJID:UnescapedJID;
		
		public function UserAccessEvent(type:String, name:String, jid:UnescapedJID, bubbles:Boolean=false, cancelable:Boolean=false){
			
			super(type, bubbles, cancelable);
			
			username = name;
			unescapedJID = jid;
			
		}
		
	}
}