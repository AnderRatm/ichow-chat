package org.ichow.eelive.connection
{
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.igniterealtime.xiff.events.MessageEvent;
	import org.igniterealtime.xiff.collections.ArrayCollection;
	import org.igniterealtime.xiff.conference.InviteListener;
	import org.igniterealtime.xiff.conference.Room;
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.core.XMPPConnection;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.data.Presence;
	import org.igniterealtime.xiff.data.im.RosterItemVO;
	import org.igniterealtime.xiff.events.InviteEvent;
	import org.igniterealtime.xiff.events.PresenceEvent;
	import org.igniterealtime.xiff.events.RoomEvent;
	import org.igniterealtime.xiff.events.RosterEvent;
	import org.igniterealtime.xiff.events.XIFFErrorEvent;
	import org.igniterealtime.xiff.im.Roster;

	
	import org.ichow.eelive.events.*;
	import org.ichow.event.EventProxy;
	import org.ichow.eelive.core.*;
	

	public class RoomManager
	{
		
		private const BYE_BYE:String = "organizer left the room";
		
		private var blockList:Array;
		
		private var _currentRoom:Room;
		

		
		private var _inviteListener:InviteListener;
		
		private var roomMonitor:Timer;
		
		private var roomsMonitorTable:HashTable;
		
		private var leftRoom:Room;
		
		private var unescapedJID:UnescapedJID;
		private var currentRoomID:String;
		private var _personalRoom:Room;
		
		private var _welcomeMessage:String;
		private const DEFAULT_WELCOME_MESSAGE:String = "Hi, I just joined in this chat...";
		private static var _instance:RoomManager;
		
		public function RoomManager(){
			
			roomsMonitorTable = new HashTable();
			
			blockList = [];
			
			roomMonitor = new Timer(600, 1);
			roomMonitor.addEventListener(TimerEvent.TIMER, onRoomMonitor);
						
		}
		
		private function onRoomMonitor(e:TimerEvent):void{
			
			var room:Room = roomsMonitorTable.find(currentRoomID);
			
			if(room){
				
				if(! room.isActive){
            	
            		room.leave();
            		room.join();
            		
            		roomMonitor.start();
            	
            	}else{
				
					room.sendMessage(_welcomeMessage || DEFAULT_WELCOME_MESSAGE);
	          	  	EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS, "*** > Sending welcome message " + roomMonitor.currentCount));
	          	  
	          	 }
					
				
			}
			
		}
		
		public function joinRoom(room:Room, jid:UnescapedJID,nick:String=""):void{
			
			unescapedJID = jid;
			
			if(!_inviteListener){
				
				setupInviteListener(room.connection);
				
			}
			
			
			setupRoom(room);
			
			if (nick != "") room.nickname = nick;
			
			if(roomMonitor){
				
				roomMonitor.stop();
				roomMonitor.start();
				
			}
			
			room.connection.addEventListener(PresenceEvent.PRESENCE, onConnectionPresence);
			
		}
		
		private function setupInviteListener(connection:XMPPConnection):void{
			
			_inviteListener = new InviteListener();
			_inviteListener.addEventListener( InviteEvent.INVITED, onUserInvited );
			_inviteListener.connection = connection;
			
		}
		
		private function onPresence(e:PresenceEvent):void 
		{
			EventProxy.broadcastEvent(e);
		}
		
		private function setupRoom(room:Room):void{
			
			// Joined room
			currentRoomID = room.roomJID.escaped.bareJID;
			//room.nickname
			roomsMonitorTable.insert(currentRoomID, room);
			
			room.addEventListener( RoomEvent.USER_KICKED, onUserKicked);
			room.addEventListener( RoomEvent.ROOM_JOIN, onRoomJoin );
			room.addEventListener( RoomEvent.USER_PRESENCE_CHANGE, onUserPresence);
			room.addEventListener( RoomEvent.USER_JOIN, onUserJoin );
			room.addEventListener( RoomEvent.GROUP_MESSAGE, onGroupMessage );
			room.addEventListener( RoomEvent.USER_DEPARTURE, onUserLeave );
			room.addEventListener( RoomEvent.ROOM_LEAVE, onUserLeave );
			room.addEventListener( RoomEvent.ROOM_DESTROYED, onDestroyed );
			//room.addEventListener( AdminEvent.CONTROL_PANEL, onControlPanelMessage);
			room.addEventListener( RoomEvent.ADMIN_ERROR, onAdminError );
			room.addEventListener( RoomEvent.CONFIGURE_ROOM, onConfigureRoom );
			room.addEventListener( RoomEvent.DECLINED, onDeclined );
			room.addEventListener( RoomEvent.PRIVATE_MESSAGE, onPrivateMessage );
			room.addEventListener( RoomEvent.USER_DEPARTURE, onUserDeparture );
			room.addEventListener( RoomEvent.USER_BANNED, onUserBanned);
			room.addEventListener( RoomEvent.BANNED_ERROR, onUserBanError);
			room.addEventListener( RoomEvent.AFFILIATIONS, onUserAffiliations);
			
			room.join();
			
		}
		
		private function resetRoom(room:Room):void {
			
			room.removeEventListener( RoomEvent.USER_KICKED, onUserKicked);
			room.removeEventListener( RoomEvent.ROOM_JOIN, onRoomJoin );
			room.addEventListener( RoomEvent.USER_PRESENCE_CHANGE, onUserPresence);
			room.removeEventListener( RoomEvent.USER_JOIN, onUserJoin );
			room.removeEventListener( RoomEvent.GROUP_MESSAGE, onGroupMessage );
			room.removeEventListener( RoomEvent.USER_DEPARTURE, onUserLeave );
			room.removeEventListener( RoomEvent.ROOM_LEAVE, onUserLeave );
			room.removeEventListener( RoomEvent.ROOM_DESTROYED, onDestroyed );
			//room.removeEventListener( AdminEvent.CONTROL_PANEL, onControlPanelMessage);
			room.removeEventListener( RoomEvent.ADMIN_ERROR, onAdminError );
			room.removeEventListener( RoomEvent.CONFIGURE_ROOM, onConfigureRoom );
			room.removeEventListener( RoomEvent.DECLINED, onDeclined );
			room.removeEventListener( RoomEvent.PRIVATE_MESSAGE, onPrivateMessage );
			room.removeEventListener( RoomEvent.USER_DEPARTURE, onUserDeparture );
			room.removeEventListener( RoomEvent.USER_BANNED, onUserBanned);
			room.removeEventListener( RoomEvent.BANNED_ERROR, onUserBanError);
			room.removeEventListener( RoomEvent.AFFILIATIONS, onUserAffiliations);
			
		}
		
		protected function onUserBanError(e:RoomEvent):void{
			
			var room:Room = e.currentTarget as Room;
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  "User banner error "));
			
			EventProxy.broadcastEvent(new RoomUsersEvent(RoomUsersEvent.BANNED, room.source, room));
			
		}
		
		protected function onUserAffiliations(e:RoomEvent):void{
			
			var room:Room = e.currentTarget as Room;
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  "User Affiliations Changed " + e.reason));
			
			EventProxy.broadcastEvent(new RoomUsersEvent(RoomUsersEvent.BANNED, room.source, room));
			
		}
		
		protected function onUserBanned(e:RoomEvent):void{
			
			var room:Room = e.currentTarget as Room;
			
			if(room.nickname == unescapedJID.node){
				
				EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  "Banned because " + e.reason));
				
				EventProxy.broadcastEvent(new RoomUsersEvent(RoomUsersEvent.BANNED, room.source, room));
				
			}else{
				
				EventProxy.broadcastEvent(new RoomUsersEvent(RoomUsersEvent.USER_JOINED, room.source, room));
				
			}
			
			
		}
		
		protected function onUserDeparture( event:RoomEvent ):void{
			
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  event.nickname + " left the room."));
		
		}
			
		
		protected function onPrivateMessage( event:RoomEvent ):void{
			
			var message:Message = event.data as Message;
			var jid:EscapedJID = message.from;
			var nick:String = jid.resource;
			
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  "Private message from " + nick + ": " + message.body));
			EventProxy.broadcastEvent(new ChatMessageEvent(ChatMessageEvent.PRIVATE_MESSAGE, message));
		
		}
		
		protected function onDeclined( event:RoomEvent ):void{
			
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  "onDeclined"));
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  "from: " + event.from ));
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  "reason: " + event.reason ));
			
		}
		
		protected function onConfigureRoom( event:RoomEvent ):void{
			
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  "onConfigureRoom"));
			var obj:Object = event.data as Object;
			var details:String = ""
			
			for( var i:String in obj ){
				
				details += i + " : " + obj[ i ] + "\n";
				
			}
			
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  "onConfigureRoom details " + details));
			
		}
		
		protected function onAdminError( event:RoomEvent ):void{
		
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  OpenFireErrorsEvent.ADMIN_ERROR + " " + event.errorMessage));
			EventProxy.broadcastEvent(new OpenFireErrorsEvent(OpenFireErrorsEvent.ADMIN_ERROR, event.errorCode, event.errorMessage));
			
		}
		
		
		protected function onUserInvited (e:InviteEvent):void{
			
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  ">>handle Invitation to room: " + e.room.roomJID.bareJID));
			
			var room:Room = e.room;
			var user:EscapedJID = e.from.escaped;
			
			EventProxy.broadcastEvent(new RoomInvitationEvent(RoomInvitationEvent.INVITED, room, user, e.reason));
			
		}
		
		/*private function onControlPanelMessage( e:AdminEvent ):void{
			
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  ">>Control panel message: " + e.body))
			EventProxy.broadcastEvent( new ControlPanelEvent(ControlPanelEvent.ADMIN_MESSAGE, e.body) );
			
		}*/
		
		private function onGroupMessage( e:RoomEvent ):void{
			
			var message:Message = e.data as Message;
			
			if( message.type == Message.TYPE_ERROR ){
				
				var xiffErrorEvent:XIFFErrorEvent = new XIFFErrorEvent();
				xiffErrorEvent.errorCode = message.errorCode;
				xiffErrorEvent.errorCondition = message.errorCondition;
				xiffErrorEvent.errorMessage = message.errorMessage;
				xiffErrorEvent.errorType = message.errorType;
				EventProxy.broadcastEvent( xiffErrorEvent );
				
			}else{
				
				var result:int = message.from.domain.indexOf(_roster.connection.server);
				
			//	trace(pattern.toString())
				
				if( result && !belongsToBlockList(message.from.resource)){
					
					EventProxy.broadcastEvent( new ChatMessageEvent(ChatMessageEvent.GROUP_MESSAGE, message) );
					
				}
				
				
				
			}
		}
		
		private function belongsToBlockList(userID:String):Boolean{
			
			var result:Boolean;
			
			var limit:int = blockList.length;
			
			for(var i:int = 0; i < limit; i++){
				
				if(userID == blockList[i]){
					
					result = true;
					break;
					
				}
				
			}
			
			return result;
			
		}
		
		/**
		 * Dispathced when the room is joined by the ANY user
		 */
		protected function onUserJoin(e:RoomEvent):void{
			
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  "USER JOIN " + unescapedJID + " | " + currentRoomID));
			
			var room:Room = e.currentTarget as Room;
			EventProxy.broadcastEvent(new RoomUsersEvent(RoomUsersEvent.USER_JOINED, room.source, room));
			
			if(!room.isActive){
				
				room.leave();
            	room.join();
				
			}
			
			
		}
		
		protected function onUserKicked(e:RoomEvent):void{
			
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  "KIKED OUT " + unescapedJID + " | " + currentRoomID));
			
			var room:Room = e.currentTarget as Room;			
			EventProxy.broadcastEvent(new RoomUsersEvent(RoomUsersEvent.ROOM_KICKED, room.source, room));
			
			dispose();
			
			
		}
		/**
		 * 加入房间
		 * @param	e
		 */
		protected function onRoomJoin(e:RoomEvent):void{
			
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  "ROOM JOIN " + unescapedJID + " | " + currentRoomID));
			
			var room:Room = e.currentTarget as Room;
			var presence:Presence = new Presence(null, unescapedJID.escaped, null, PRESENCE_VALUES[0].data, PRESENCE_VALUES[0].data, 1);
			
			
			if ( room.affiliation == "owner" && _personalRoom != room )
			{
				_personalRoom = room;
			}
			
			
			EventProxy.broadcastEvent(new RoomUsersEvent(RoomUsersEvent.ROOM_JOINED, room.source, room));
			
            room.connection.send(presence);
           
		
		}	
		/**
		 * 移除房间
		 * @param	e
		 */
		protected function onDestroyed(e:RoomEvent):void{
			
			var room:Room;
			
			if(!_personalRoom){
				
				room = roomsMonitorTable.find(currentRoomID);
				
			}else{
				
				room = _personalRoom;
				
			}
			 
			EventProxy.broadcastEvent(new PersonalRoomEvent(PersonalRoomEvent.ROOM_DESTROYED, room));
			EventProxy.broadcastEvent(new RoomUsersEvent(RoomUsersEvent.ROOM_LEFT, room.source, room));
			
			
		}
		/**
		 * 离开房间 
		 * 更新列表
		 * @param	e
		 */
		protected function onUserLeave(e:RoomEvent):void{
			
			var room:Room = e.currentTarget as Room;
			EventProxy.broadcastEvent(new RoomUsersEvent(RoomUsersEvent.USER_LEFT, room.source, room));
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  "*** Room has been left " + room.userJID + " | " + room.connection));
			
		}
		/**
		 * 更新状态
		 * @param	e
		 */
		protected function onRosterPresenceUpdated(e:RosterEvent):void{
			
			var room:Room = e.currentTarget as Room;
			
			EventProxy.broadcastEvent(new RoomUsersEvent(RoomUsersEvent.ROSTER_PRESENCE, e.target.source, room, e.data));
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  "Roster presence " + e.jid + " | " + e.data));
			
		}
		
		/**
		 * Update the user list just in case we found a way to setup the status over the connection
		 */		
		protected function onConnectionPresence(e:PresenceEvent):void{
			
			var room:Room;
			
			if(leftRoom){
				
				room = leftRoom;
				leftRoom = null;
								
			}else{
				
				room  = roomsMonitorTable.find(currentRoomID);
				
			}
			
			if(room){
				
				EventProxy.broadcastEvent(new RoomUsersEvent(RoomUsersEvent.CONNECTION_PRESENCE, room.source, room));
				EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  "Connection presence " + e.data));
				
			}
			
		}
		
		/**
		 * Hanlde the change of the presence over a room 
		 * @param e RoomEvent
		 */		
		protected function onUserPresence(e:RoomEvent):void{
			
			var room:Room = e.currentTarget as Room;
			
			EventProxy.broadcastEvent(new RoomUsersEvent(RoomUsersEvent.ROOM_PRESENCE, room.source, room));
			EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  "User presence " + e.from + " " + e.reason));
			
		}

		public function updatePresence(show:String, status:String):void{
			
            _roster.setPresence(show, status, 0);
            
            try{
            
           	 	var room:Room = roomsMonitorTable.find(currentRoomID);
           	 	updateRoomPresence(room, show, status);
           	 	
           	}catch(error:Error){
           		
           		EventProxy.broadcastEvent(new LogsEvent(LogsEvent.LOGS,  "PRESENCE UPDATE ERROR " + error.message));
           		
           	}
		
		}
		
		public function banUsers(room:Room, ids:Array, reason:String = ""):void{
			
			if(room){
				
				room.ban(ids);
				
				
			}else{
				
				var current:Room = roomsMonitorTable.find(currentRoomID) as Room;
				current.ban(ids);
				
			}
			
		}
		
		protected function updateRoomPresence(room:Room, show:String, status:String):void{
			
			var presence:Presence = new Presence(null, unescapedJID.escaped, null, status, show, 1);
			
            room.connection.send(presence);			            
			
		}
		
		
		public function blockUser(userID:String):void{
		
			blockList.push(userID);	
			
		}
		
        public function unblockUser(userID:String):void{
        	
        	var index:int = blockList.indexOf(userID);
        	
        	if(!isNaN(index)){
        		
        		blockList.splice(index, 1);
        		
        	}
        	
        }
		
		public function get blackList():Array {
			
			return blockList.slice();
			
		}
		
		public function get inviteListener():InviteListener{
			
			return _inviteListener
			
		}
		/**
		 * 获取当前房间
		 */
		public function get currentRoom():Room{
			
			return roomsMonitorTable.find(currentRoomID) as Room;
			
		}
		
		public function set friendsList(value:Array):void{
			
			throw new IllegalOperationError("friendsList is read only");
			
		}

		/**
		 * 发送房间消息
		 * @param	text : 文本
		 * @param	html : 超文本
		 */
		public function sendMessage(text:String = null, html:String = null):void{
			
			//var helper:StringHelper = new StringHelper();
			//var message:String = helper.trim(text, " ");
			var message:String = text;
			
			if(message.length == 0)return;
			
			var room:Room = roomsMonitorTable.find(currentRoomID);
			
			if(! room.isActive){
            	
            	room.leave();
            	room.join();
            		
            	roomMonitor.start();
            		
   			}else{
				//trace("send msg");
				room.sendMessage(message, html);
				
   			}
			
		}
		/**
		 * 发送私聊信息
		 * @param	text  : 信息
		 * @param	tojid : 对方JID
		 */
		public function sendMessageTo(text:String, tojid:EscapedJID):void{
			
			//var helper:StringHelper = new StringHelper();
			//var messageBody:String = helper.trim(text, " ");
			var messageBody:String = text;
			
			if(messageBody.length == 0)return;
			
			var room:Room = roomsMonitorTable.find(currentRoomID);
			var message:Message = new Message( tojid, null, null, null, Message.TYPE_CHAT, null );
			message.from = unescapedJID.escaped;
			message.body = messageBody;
			
			room.sendPrivateMessage(tojid.node, text);
			
		}
		/**
		 * 房间人员列表
		 * @param	roomID : 房间名
		 * @return  Array  : 用户列表
		 */
		public function connectedUsers(roomID:String = ""):Array{
			
			var id:String;
			
			roomID ? id = roomID : id = currentRoomID;
			
			var room:Room = roomsMonitorTable.find(id);
			
			var value:Array;
			
			if(room){
				
				value = room.source;
				
			}
			
			return value;
			
		}
		/**
		 * 离开房间
		 * @param	roomID : 房间名
		 */
		public function leave(roomID:String = ""):void{
			
			var id:String;
			
			roomID ? id = roomID : id = currentRoomID;
			
			leftRoom = roomsMonitorTable.find(id);
			
			resetRoom(leftRoom);
			
			leftRoom.leave();
			
			roomsMonitorTable.remove(id);
			
			if(roomsMonitorTable.isEmpty()){
				
				currentRoomID = null;
				
			}else{
				
				var data:Array = roomsMonitorTable.getKeys();
				var length:int = data.length;
				
				currentRoomID = data[length - 1];
				
			}
			
			var user:RosterItemVO = new RosterItemVO(unescapedJID);
			
			EventProxy.broadcastEvent(new RoomUsersEvent(RoomUsersEvent.ROOM_LEFT, [], leftRoom, user))
			
		}
		
		public function dispose():void{
			
			/*var components:ICollectionView = roomsMonitorTable.getICollectionView();
			var limit:int = components.length;
			
			for(var i:int = 0; i < limit; i++){
				
				roomsMonitorTable.remove((components[i] as HashItem).name);
				
			}*/
			
			
		}
		
		/**
		 * 创建私人房间
		 * @param	room : 房间Room
		 */
		public function createRoom(room:Room):void{
			
			if(_personalRoom){
				
				EventProxy.broadcastEvent(new PersonalRoomEvent(PersonalRoomEvent.ROOM_EXISTS, _personalRoom));
				
			}else{
				
				_personalRoom = room;
				_personalRoom.join();
				
				EventProxy.broadcastEvent(new PersonalRoomEvent(PersonalRoomEvent.ROOM_CREATED, room));
				
			}
			
		}
		/**
		 * 删除房间
		 * @param	room
		 * @param	reason
		 */
		public function destroyRoom(room:Room, reason:String = null):void{
			
			if(room != _personalRoom){
				
				_personalRoom.destroy(reason || BYE_BYE, unescapedJID);
				
			}
			
		}
		/**
		 * 获取私人房间
		 */
		public function get personalRoom():Room {
			
			return _personalRoom;
			
		}
		/**
		 * 欢迎信息
		 */
		public function set welcomeMessage(value:String):void{
			
			_welcomeMessage = value;
			
		}
		
		static public function get instance():RoomManager 
		{
			if (_instance == null) _instance = new RoomManager();
			return _instance;
		}
		/**
		 * 邀请
		 * @param	userId : 用户JID
		 * @param	roomID : 房间
		 * @param	message : 信息
		 */
		public function invite(userId:EscapedJID, roomID:String, message:String):void{
			
			
			if(_personalRoom){
				
				_personalRoom.invite(userId.unescaped, message);
				
			}
			
		}
		//
		public function getDisplayName(jid:String):void {
			//_roster.getPresence(
			//_roster.ge
		}
	}
}