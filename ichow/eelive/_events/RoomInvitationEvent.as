package org.ichow.eelive.events
{
	import flash.events.Event;
	
	import org.igniterealtime.xiff.conference.Room;
	import org.igniterealtime.xiff.core.EscapedJID;

	public class RoomInvitationEvent extends Event
	{
		public static const INVITED:String 					= "onUserInvited";
		
		public var roomData:Room;
		public var fromUser:EscapedJID;
		public var invitationMessage:String
		
		public function RoomInvitationEvent(type:String, room:Room, from:EscapedJID, message:String, bubbles:Boolean=false, cancelable:Boolean=false){
			
			super(type, bubbles, cancelable);
			
			roomData = room;
			fromUser = from;
			invitationMessage = message;
			
		}
		
	}
}