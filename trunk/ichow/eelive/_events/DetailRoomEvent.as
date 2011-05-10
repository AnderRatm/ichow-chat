package org.ichow.eelive.events
{
	import org.ichow.eelive.core.OpenFireRoomEssentials
	import flash.events.Event;

	public class DetailRoomEvent extends Event
	{
		
		public static const ROOM_DETAILS:String = "onRoomDetails";
		
		public var details:OpenFireRoomEssentials;
		
		public function DetailRoomEvent(info:OpenFireRoomEssentials, bubbles:Boolean=false, cancelable:Boolean=false){
			
			super(ROOM_DETAILS, bubbles, cancelable);
			
			details = info;
			
			
		}
		
	}
}