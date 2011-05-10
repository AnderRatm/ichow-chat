package org.ichow.eelive.connection 
{
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class RosterManager 
	{
		public static const PRESENCE_VALUES:Array =    [
                                                            { label:"Online", data: Presence.SHOW_CHAT },
                                                            { label:"Free To Chat", data: Presence.SHOW_CHAT },
                                                            { label:"Away", data: Presence.SHOW_AWAY },
                                                            { label:"Do Not Disturb", data: Presence.SHOW_DND },
                                                            { label:"Extended Away", data: Presence.SHOW_XA }
                                                        ];
		
		private const FRIENDS_GROUP:String = "Friends";
		private var _roster:Roster;
		
		public function RosterManager() 
		{
			
		}
		
		public function init():void {
			
			if(!_roster){
				
				setupRoster(room.connection);
				
			}
		}
		
		private function setupRoster(connection:XMPPConnection):void{
			
			_roster = new Roster();
			
			_roster.addEventListener( RosterEvent.USER_PRESENCE_UPDATED, onRosterPresenceUpdated );
			_roster.addEventListener( RosterEvent.ROSTER_LOADED, onRosterLoaded );
			_roster.addEventListener( RosterEvent.SUBSCRIPTION_DENIAL, onSubscriptionDenial );
			_roster.addEventListener( RosterEvent.SUBSCRIPTION_REQUEST, onSubscriptionRequest );
			_roster.addEventListener( RosterEvent.USER_SUBSCRIPTION_UPDATED, onUserAdded );
		 	_roster.addEventListener( RosterEvent.USER_REMOVED, onUserRemoved );
			
			/*
			_roster.addEventListener( RosterEvent.SUBSCRIPTION_REVOCATION, onSubscriptionRevocation );
			_roster.addEventListener( RosterEvent.USER_AVAILABLE, onUserAvailable ); */
			/* _roster.addEventListener( RosterEvent.USER_REMOVED, onUserRemoved );
			_roster.addEventListener( RosterEvent.USER_SUBSCRIPTION_UPDATED, onUserSubscriptionUpdated );
			_roster.addEventListener( RosterEvent.USER_UNAVAILABLE, onUserUnavailable ); */
			
			connection.addEventListener(MessageEvent.MESSAGE, onMessage);
			connection.addEventListener(PresenceEvent.PRESENCE, onPresence);
			_roster.connection = connection;
			//_roster.addItem(
			_roster.fetchRoster();
		
		}
		
		
		/**
		 * The list of friends of a specific user
		 */				
		protected function onRosterLoaded(e:RosterEvent):void{
			
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  "ROSTER LOADED " + unescapedJID + " | " + currentRoomID));
			EventProxy.broadcastEvent(new FriendsEvent(FriendsEvent.LIST_RECOVERED, ArrayCollection(e.target).source,null,false,false,_roster));
			
		}
		
		/**
		 * Roster Event forwarded throught the FriendsInvitation event
		 */	
		protected function onSubscriptionDenial(e:RosterEvent):void{
			
			EventProxy.broadcastEvent(new FriendsInvitation(FriendsInvitation.FRIEND_REQUEST_DENIED, e.jid));
			
		}
		
		/**
		 *  Roster Event forwarded throught the FriendsInvitation event
		 */	
		protected function onSubscriptionRequest(e:RosterEvent):void{
			
			if (_roster.getPresence(e.jid) != null) grantSubscription(e.jid, true);
			
			EventProxy.broadcastEvent(new FriendsInvitation(FriendsInvitation.FRIEND_REQUEST_INCOMING, e.jid));
			
		}
		

		/**
		 * Roster Event forwarded through the FriendsInvitation event,
		 * it also update the roster and notify the listeners registered
		 * for the driver
		 */	
		protected function onUserAdded(e:RosterEvent):void{
			
			EventProxy.broadcastEvent(new FriendsInvitation(FriendsInvitation.FRIEND_REQUEST_ACCETPED, e.jid));
			
			// Friends list is propagated
			EventProxy.broadcastEvent(new FriendsEvent(FriendsEvent.LIST_RECOVERED, ArrayCollection(e.target).source));
			
		}
		
		/**
		 * Roster Event forwarded through the FriendsInvitation event,
		 * it also update the roster and notify the listeners registered
		 * for the driver
		 */	
		protected function onUserRemoved(e:RosterEvent):void{
			
			EventProxy.broadcastEvent(new FriendsInvitation(FriendsInvitation.FRIEND_LIST_REMOVED, e.jid));
			
			// Friends list is propagated
			EventProxy.broadcastEvent(new FriendsEvent(FriendsEvent.LIST_RECOVERED, ArrayCollection(e.target).source));
			
		}
		
		public function grantSubscription(id:UnescapedJID, status:Boolean = true):void{
			
			_roster.grantSubscription(id, status);
			
		}
		
		public function denySubscription(id:UnescapedJID):void{
			
			_roster.denySubscription(id);
			
		}
		
		
		public function addFriend(user:UnescapedJID):void{
			
			if(user == null){
				
				EventProxy.broadcastEvent(new FriendsInvitation(FriendsInvitation.FRIEND_ADD_NOT_SUPPORTED));
				
			}else{	
				
				_roster.addContact(user, user.node, FRIENDS_GROUP, true);
				
			}
			
		}
		
		public function removeFriend(user:UnescapedJID):void{
			
			_roster.removeContact(new RosterItemVO(user));
			
		}
		/**
		 * 获取好友列表
		 */
		public function get friendsList():Array{
			return _roster.source;
		}
		
		/**
		 * 是否JID
		 * @param	jid
		 * @return
		 */
		public function isValidJID(jid:UnescapedJID):Boolean{
			
			var value:Boolean = false;
			var pattern:RegExp = new RegExp("(\\w|[_.\\-])+@(" + _roster.connection.server +"$|((\\w|-)+\\.)+\\w{2,4}$){1}");
			
			var result:Object = pattern.exec( jid.toString() );
			
			if( result ){
				
				value = true;
				
			}
			
			return value;
			
		}
	}

}