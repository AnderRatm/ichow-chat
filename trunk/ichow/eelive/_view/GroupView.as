package org.ichow.eelive.view 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import org.ichow.components.Panel;
	import org.ichow.components.VScrollPane;
	import org.ichow.eelive.events.FriendsEvent;
	import org.ichow.eelive.events.PrivateChatEvent;
	import org.ichow.event.EventProxy;
	import org.ichow.settings.eeLiveSettings;
	import org.igniterealtime.xiff.data.im.RosterItemVO;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.data.Presence;
	import org.igniterealtime.xiff.events.MessageEvent;
	import org.igniterealtime.xiff.events.PresenceEvent;
	import org.igniterealtime.xiff.im.Roster;
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class GroupView extends BaseView implements IShow
	{
		/**
		 * 私聊框 v1.0
		 */
		private var _chats:PrivateChatView;
		
		private var _isChat:Boolean;
		
		private var _stage:Stage;
		private var _people:Dictionary;
		private var _groupList:GroupList;
		private var _parent:DisplayObjectContainer;
		/**
		 * 构造
		 * @param	parent
		 * @param	xpos
		 * @param	ypos
		 * @param	width
		 * @param	height
		 * @param	type
		 */
		public function GroupView(	parent:DisplayObjectContainer = null, 
									xpos:Number = 0, 
									ypos:Number =  0,
									width:uint = 0,
									height:uint = 0,
									type:String = ""
									) 
		{
			this._parent = parent;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			super(parent, xpos, ypos, width, height, type);
		}
		
		private function onRemovedFromStage(e:Event):void 
		{
			//removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			if (_stage.contains(_chats)) _stage.removeChild(_chats);
		}
		
		private function onAddedToStage(e:Event):void 
		{
			//removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_stage = stage;
		}
		
		override protected function addChildren():void {
			super.addChildren();

			_people = new Dictionary();
			_isChat = false;
			
			_chats = new PrivateChatView(_stage, 0, 0, eeLiveSettings.CHAT_MAX_WIDTH - eeLiveSettings.CHAT_MIN_WIDTH, eeLiveSettings.CHAT_MAX_HEIGHT, "chats");
			_groupList = new GroupList(this, 0, 0, _width, _height, "groupList");
			addEventListeners();
		}
		
		private function addEventListeners():void 
		{
			/*EventProxy.subscribeEvent(this, MessageEvent.MESSAGE, onMessage);
			
			EventProxy.subscribeEvent(this, RoomUsersEvent.ROSTER_PRESENCE, onRosterPresence);
			*/
			EventProxy.subscribeEvent(this, FriendsEvent.LIST_RECOVERED, onFriendListRecovered);
			EventProxy.subscribeEvent(this, PresenceEvent.PRESENCE, onPresence);
			EventProxy.subscribeEvent(this, MessageEvent.MESSAGE, onMessage);
			EventProxy.subscribeEvent(this, PrivateChatEvent.ADD_PRIVATE_CHAT, onAddPrivateChat);
			EventProxy.subscribeEvent(this, PrivateChatEvent.REMOVE_PRIVATE_CHAT, onRemovePrivateChat);
			
		}
		
		private function onMessage(e:MessageEvent):void 
		{
			var message:Message = e.data as Message;
			if (message.type== Message.TYPE_CHAT) {
				//message.from
				if (_chats.hasChat(message.from.bareJID) == null || !_chats.open) _groupList.hasMessage(message);
				//create chat
				_chats.addMessageTo(message);
			}
		}
		
		private function onAddPrivateChat(e:PrivateChatEvent):void 
		{
			//
			if (!_stage.contains(_chats)) {
				EventProxy.broadcastEvent(new Event(MainView.ZOOM_IN));
				_chats.open = true;
				_stage.addChild(_chats);
			}
			//
			if (_chats.hasChat(e.jid) == null) _chats.addChat(e.jid, e.displayName);
			else {
				//_chats.hasChat(e.jid).show();
				_chats._list.getChild(e.jid).label = e.displayName;
				_chats._list.getChild(e.jid).visible = true;
				_chats._list.getChild(e.jid).dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				_chats._list.update();
			}
			_groupList.noMessage(e.jid);
			//call main view to move canvas
		}
		
		private function onRemovePrivateChat(e:PrivateChatEvent):void {
			//check
			_stage.removeChild(_chats);
			//call main view to move canvas
			_chats.open = false;
			EventProxy.broadcastEvent(new Event(MainView.ZOOM_OUT));
		}
		
		private function onFriendListRecovered(e:FriendsEvent):void 
		{
			for (var i:int = 0,len:int=e.friendsList.length; i < len; i++) {
				var vo:RosterItemVO = e.friendsList[i] as RosterItemVO;
				if (!_people[vo.jid.bareJID] && _people[vo.jid.bareJID] != "Online") {
					_people[vo.jid.bareJID] = "Offline";
				}
			}
			
			buildRosterContent(e.friendsList, e.roster);
		}
		private var _presences:Dictionary=new Dictionary();
		private function onPresence(e:PresenceEvent):void 
		{
			
            for (var i:int = 0,len:int = e.data.length; i < len; ++i)
            {
                var presence:Presence = e.data[i] as Presence;
                if (presence.from != null)
                {
					if (presence.show != null || presence.status != null) {
						_people[presence.from.bareJID] = "Online";
					}
					
					if (presence.type == Presence.TYPE_UNAVAILABLE) {
						_people[presence.from.bareJID] = "Offline";
					}
                }
				
            }
            draw();
		}
		
		private function buildRosterContent(friends:Array,roster:Roster):void 
		{
			var peoples:Array = new Array();
			var groups:Dictionary = new Dictionary();
			for (var i:uint = 0; i < friends.length; i++) {
				
				var ros:RosterItemVO = friends[i] as RosterItemVO;
				//ros.displayName
				eeLiveSettings.PRESENCES[ros.jid.bareJID] = ros;
				
				var gs:Array = roster.getContainingGroups(ros);
				for (var a in gs) {
					groups[gs[a].label] = gs[a].items;
				}
			}
			i = 0;
			for (var gss:String in groups) {
				peoples[i] = { label:gss, data:groups[gss].source, id:i };
				i++;
			}
			
			//trace(roster.getPresence(eeLiveSettings.JID.unescaped));
			
			_groupList.items = peoples;
			
            draw();
		}
		
		
		
		override public function draw():void {
			super.draw();
			
			if(_groupList!=null) _groupList.updateStatus(_people);
		}
		
		public function show():void {
			this.visible = true;
			this.mouseChildren = true;
		}
		
		public function hide():void {
			this.visible = false;
			this.mouseChildren = false;
			this.mouseEnabled = false;
		}
		
	}

}