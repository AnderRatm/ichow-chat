package org.ichow.eelive.events
{
	import flash.events.Event;
	
	import org.igniterealtime.xiff.conference.Room;
	import org.igniterealtime.xiff.data.im.RosterItemVO;

	
	public class RoomUsersEvent extends Event
		{
			
			public static const ROOM_JOINED:String   			= "roomJoined";
			public static const ROOM_LEFT:String     			= "roomLeft";
			public static const ROOM_KICKED:String   			= "userKicked";
			public static const USER_JOINED:String   			= "userJoined";
			public static const USER_LEFT:String   				= "userLeft";
	        public static const ROOM_PRESENCE:String 			= "roomPresenceChanged";
	        public static const ROSTER_PRESENCE:String 			= "rosterPresenceChanged";
	        public static const CONNECTION_PRESENCE:String 		= "connectionPresenceChanged";
	        public static const BANNED:String 					= "onBanned";
	
			public var usersList:Array;
	        public var userData:RosterItemVO;
	        public var roomData:Room;
			
			public function RoomUsersEvent(type:String, users:Array, room:Room, userInfo:RosterItemVO = null, bubbles:Boolean=false, cancelable:Boolean=false){
				
				super(type, bubbles, cancelable);
				
				usersList = users;
	            userData = userInfo;
	            roomData = room;
				
			}
			
			override public function clone():Event{
				
				return new RoomUsersEvent(type, usersList, roomData, userData);
				
			}
	
	    }
}