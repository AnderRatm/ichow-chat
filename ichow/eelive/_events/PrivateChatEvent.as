package org.ichow.eelive.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class PrivateChatEvent extends Event 
	{
		public static const ADD_PRIVATE_CHAT:String = "addPrivateChat";
		public static const REMOVE_PRIVATE_CHAT:String = "removePrivateChat";
		
		public var jid:String = "";
		public var displayName:String = "";
		public function PrivateChatEvent(type:String,jid:String="",displayName:String="", bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			this.jid = jid;
			this.displayName = displayName;
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new PrivateChatEvent(type, jid, displayName, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PrivateChatEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}