package org.ichow.eelive.events
{
	import flash.events.Event;
	
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.im.RosterItemVO;

	public class FriendsInvitation extends Event
	{
		
		public static const FRIEND_ADD_NOT_SUPPORTED:String 		= "friendAddNotSupport";
		public static const FRIEND_REQUEST_INCOMING:String 			= "friendRequest";
		public static const FRIEND_REQUEST_DENIED:String 			= "friendDenied";
		public static const FRIEND_REQUEST_ACCETPED:String 			= "friendAdded";
		public static const FRIEND_LIST_REMOVED:String 				= "friendRemoved";
		
		public var jid:UnescapedJID;
		
		public function FriendsInvitation(type:String, id:UnescapedJID = null, bubbles:Boolean=false, cancelable:Boolean=false){
			
			super(type, bubbles, cancelable);
			
			jid = id;
			
		}
		
	}
}