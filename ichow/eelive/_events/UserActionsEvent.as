package org.ichow.eelive.events
{
	import flash.events.Event;
	
	import org.igniterealtime.xiff.collections.ArrayCollection;
	import org.igniterealtime.xiff.data.im.RosterItemVO;

	public class UserActionsEvent extends Event
	{
		
		public static const USER_KICK:String 				= "userkick";
		public static const USER_BAN:String 				= "userban";
		
		public var username:String;
		
		public function UserActionsEvent(type:String, u:String = "", bubbles:Boolean=false, cancelable:Boolean=false){
			
			super(type, bubbles, cancelable);
			
			username = u;
			
		}
		
	}
}