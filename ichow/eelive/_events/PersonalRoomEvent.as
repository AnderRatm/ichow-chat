package org.ichow.eelive.events
{
	import flash.events.Event;
	
	import org.igniterealtime.xiff.conference.Room;

	public class PersonalRoomEvent extends Event
	{
		
		public static const ROOM_CREATED:String = "onRoomCreated";
		public static const ROOM_EXISTS:String = "onRoomAlreadyExists";
		public static const ROOM_DESTROYED:String = "onRoomDestroyed";
		
		public var currentRoom:Room;
		
		public function PersonalRoomEvent(type:String, room:Room, bubbles:Boolean=false, cancelable:Boolean=false){
			
			super(type, bubbles, cancelable);
			
			currentRoom = room;
			
			
		}
		
	}
}