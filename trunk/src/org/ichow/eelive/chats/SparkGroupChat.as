package org.ichow.eelive.chats {
	import com.hexagonstar.util.debug.Debug;

	import org.ichow.eelive.components.ItemsList;
	import org.ichow.eelive.components.RoomsList;
	import org.ichow.eelive.events.ChatEvent;
	import org.ichow.eelive.managers.ChatManager;
	import org.ichow.eelive.managers.MessageManager;
	import org.ichow.eelive.managers.MUCManager;

	import flash.events.Event;

	import org.igniterealtime.xiff.collections.ArrayCollection;
	import org.igniterealtime.xiff.collections.events.CollectionEvent
	import org.igniterealtime.xiff.conference.Room;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.muc.MUCItem;
	import org.igniterealtime.xiff.data.muc.MUCUserExtension;
	import org.igniterealtime.xiff.events.RoomEvent;
	import org.igniterealtime.xiff.data.Message;

	public class SparkGroupChat extends SparkChat {
		protected var _room:Room;
		private var roomPassword:String = null;
		private var recentlyChangedNicks:Object = null;

		public function SparkGroupChat(j:UnescapedJID){
			super(j);
		}

		public override function setup(j:UnescapedJID):void {
			room = MUCManager.manager.getRoom(j);
			displayName = room.roomJID.toString();

			if (roomPassword != null)
				room.password = roomPassword;

			// Handle possible errors on joining the room
			room.addEventListener(RoomEvent.PASSWORD_ERROR, handlePasswordError);
			room.addEventListener(RoomEvent.REGISTRATION_REQ_ERROR, handleRegistrationReqError);
			room.addEventListener(RoomEvent.BANNED_ERROR, handleBannedError);
			room.addEventListener(RoomEvent.NICK_CONFLICT, handleNickConflict);
			room.addEventListener(RoomEvent.MAX_USERS_ERROR, handleMaxUsersError);
			room.addEventListener(RoomEvent.LOCKED_ERROR, handleLockedError);

			if (!room.join()){
				dispatchEvent(new Event("joinFailed"));
				return;
			}

			room.addEventListener(CollectionEvent.COLLECTION_CHANGE, function(evt:CollectionEvent):void {
					dispatchEvent(new Event("occupantsChanged"));
					removeErrorEventListeners();
				});

			// Listen to common room events
			room.addEventListener(RoomEvent.USER_JOIN, handleUserJoin);
			room.addEventListener(RoomEvent.USER_DEPARTURE, handleUserDeparture);
			room.addEventListener(RoomEvent.USER_KICKED, handleUserKicked);
			room.addEventListener(RoomEvent.USER_BANNED, handleUserBanned);

		}

		public override function get jid():UnescapedJID {
			return room.roomJID;
		}

		[Bindable]
		public function get room():Room {
			return _room;
		}

		public override function close():void {
			removeCommonEventListeners();

			super.close();
			room.leave();
		}

		//the user's nickname; this is because it may vary in groupchats
		public override function get myNickName():String {
			return room.nickname;
		}

		public override function insertMessage(message:SparkMessage):void {
			if (room.isThisUser(message.from) && message.time == null)
				return;
			super.insertMessage(message);
		}

		public override function transmitMessage(message:SparkMessage):void {
			//room.sendMessage(message.body);
			MessageManager.instance.sendMessage(room.roomJID.escaped, message.body, null, Message.TYPE_GROUPCHAT);
		}

		public function set room(r:Room):void {
			_room = r;
		}

		public function set password(pw:String):void {
			roomPassword = pw;
		}

		public override function set displayName(name:String):void {
			if (name.indexOf('@') > -1)
				name = name.split('@')[0];
			super.displayName = name;
		}

		public override function get occupants():ArrayCollection {
			return room;
		}

		private function error(type:String, close:Boolean = true):void {
			var errEvt:ChatEvent = new ChatEvent(ChatEvent.CHAT_ERROR);
			errEvt.error = type;
			errEvt.chat = this;
			ChatManager.sharedInstance.dispatchEvent(errEvt);
			ChatManager.sharedInstance.closeChat(this);
			removeErrorEventListeners();
		}

		public function handlePasswordError(event:RoomEvent):void {
			error(ChatEvent.PASSWORD_ERROR);
		}

		public function handleRegistrationReqError(event:RoomEvent):void {
			error(ChatEvent.REGISTRATION_REQUIRED_ERROR);
		}

		public function handleBannedError(event:RoomEvent):void {
			error(ChatEvent.BANNED_ERROR);
		}

		public function handleNickConflict(event:RoomEvent):void {
			error(ChatEvent.NICK_CONFLICT_ERROR);
		}

		public function handleMaxUsersError(event:RoomEvent):void {
			error(ChatEvent.MAX_USERS_ERROR);
		}

		public function handleLockedError(event:RoomEvent):void {
			error(ChatEvent.ROOM_LOCKED_ERROR);
		}

		private function removeErrorEventListeners():void {
			room.removeEventListener(RoomEvent.PASSWORD_ERROR, handlePasswordError);
			room.removeEventListener(RoomEvent.REGISTRATION_REQ_ERROR, handleRegistrationReqError);
			room.removeEventListener(RoomEvent.BANNED_ERROR, handleBannedError);
			room.removeEventListener(RoomEvent.NICK_CONFLICT, handleNickConflict);
			room.removeEventListener(RoomEvent.MAX_USERS_ERROR, handleMaxUsersError);
			room.removeEventListener(RoomEvent.LOCKED_ERROR, handleLockedError);
		}

		public function handleUserJoin(event:RoomEvent):void {
			// Is this join a result of a recent nick change?
			if (recentlyChangedNicks != null){
				var nickChange:Array = recentlyChangedNicks[event.nickname];
				if (nickChange != null){
					insertSystemMessage(nickChange[0]);
					delete recentlyChangedNicks[event.nickname];
					return;
				}
			}

			if (event.nickname != myNickName){
				insertSystemMessage(event.nickname + " 进入了房间!");
				Debug.trace("user join: " + event.nickname);
			}

			trace("getItem: " + ItemsList.getItem(this.jid).jid);
		}

		public function handleUserDeparture(event:RoomEvent):void {
			// Was this a nick change?
			var userExt:MUCUserExtension = event.data.getAllExtensionsByNS(MUCUserExtension.NS)[0];
			if (userExt && userExt.hasStatusCode(303)){
				if (recentlyChangedNicks == null)
					recentlyChangedNicks = new Object();
				var userExtItem:MUCItem = userExt.getAllItems()[0];
				recentlyChangedNicks[userExtItem.nick] = [event.nickname, userExtItem.nick];
				return;
			}

			insertSystemMessage(event.nickname + " 退出了房间!");
			Debug.trace("user dep: " + event.nickname);
		}

		public function handleUserKicked(event:RoomEvent):void {
			if (event.nickname != myNickName)
				insertSystemMessage(event.nickname + " 被踢出房间！");
			else
				insertSystemMessage("你被踢出房间！");

		}

		public function handleUserBanned(event:RoomEvent):void {
			if (event.nickname != myNickName)
				insertSystemMessage(event.nickname + " 被禁止!");
			else
				insertSystemMessage("你被禁止！");
		}

		private function removeCommonEventListeners():void {
			room.removeEventListener(RoomEvent.USER_JOIN, handleUserJoin);
			room.removeEventListener(RoomEvent.USER_DEPARTURE, handleUserDeparture);
			room.removeEventListener(RoomEvent.USER_KICKED, handleUserKicked);
			room.removeEventListener(RoomEvent.USER_BANNED, handleUserBanned);
		}
	}
}