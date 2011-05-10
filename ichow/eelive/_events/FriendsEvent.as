package org.ichow.eelive.events
{
	import flash.events.Event;
	import org.igniterealtime.xiff.im.Roster;
	
	import org.igniterealtime.xiff.collections.ArrayCollection;
	import org.igniterealtime.xiff.data.im.RosterItemVO;

	public class FriendsEvent extends Event
	{
		
		
		public static const LIST_RECOVERED:String 				= "friendsListRecovered";
		public static const FRIEND_PRESENCE:String 				= "friendPresence";
		
		public var friendsList:Array;
		public var roster:Roster;
		
		public function FriendsEvent(type:String, friends:Array = null, friend:RosterItemVO = null, bubbles:Boolean=false, cancelable:Boolean=false,roster:Roster=null){
			
			super(type, bubbles, cancelable);
			
			friendsList = friends;
			if (roster != null) this.roster = roster;
		}
		
	}
}