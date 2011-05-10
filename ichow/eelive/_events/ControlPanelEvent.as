package org.ichow.eelive.events
{
	import flash.events.Event;

	public class ControlPanelEvent extends Event
	{
		
		public static const ADMIN_MESSAGE:String 	= "onAdminMessage";
		
		public var messageBody:String;
		
		public function ControlPanelEvent(type:String, body:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			messageBody = body;
		}
		
	}
}