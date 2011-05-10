package org.ichow.eelive.events
{
	import flash.events.Event;

	public class AvailableRoomsEvent extends Event
	{
		
		public static const ROOMS_RECOVERED:String = "onRoomsRecovered";
		
		public var currentRooms:Array;
		
		public function AvailableRoomsEvent(rooms:Array, bubbles:Boolean=false, cancelable:Boolean=false){
			
			super(ROOMS_RECOVERED, bubbles, cancelable);
			
			currentRooms = rooms;
			
			
		}
		
	}
}