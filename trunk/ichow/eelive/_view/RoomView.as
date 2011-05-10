package org.ichow.eelive.view 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.ichow.components.InputText;
	import org.ichow.components.Label;
	import org.ichow.components.PushButton;
	import org.ichow.debug.eeDebug;
	import org.ichow.event.EventProxy;
	import org.ichow.eelive.events.*;
	import org.ichow.settings.eeLiveSettings;
	import org.ichow.util.ChatStyle;
	import org.igniterealtime.xiff.conference.Room;
	import org.igniterealtime.xiff.data.Message;
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class RoomView extends BaseView implements IShow
	{
		public static const SEND_MESSAGE:String = "sendMessage";
		
		private var _showFlow:FlowPanel;
		private var _inputFlow:FlowPanel;
		private var _stylePanel:StylePanel;
		private var _sendButton:PushButton;
		private var roomTitle:InputText;
		
		private var _titleHeight:uint = 30;
		private var _styleHeight:uint = 30;
		private var _inputHeight:uint = 100;
		
		public function RoomView(	parent:DisplayObjectContainer = null, 
									xpos:Number = 0, 
									ypos:Number =  0,
									width:uint = 0,
									height:uint = 0,
									type:String = ""
									) 
		{
			super(parent, xpos, ypos, width, height, type);
		}
		
		override protected function addChildren():void {
			super.addChildren();
			//title
			roomTitle = new InputText(this, 0, 0, "");
			roomTitle.setSize(_width, _titleHeight);
			roomTitle.enabled = false;
			//show
			_showFlow = new FlowPanel(this, 0, _titleHeight, _width, _height - _styleHeight*3 - _inputHeight, FlowPanel.DYNAMIC);
			//style
			_stylePanel = new StylePanel(this, 0, _titleHeight + _showFlow.height, _width, _styleHeight, "style");
			//input
			_inputFlow = new FlowPanel(this, 0, _stylePanel.y + _styleHeight, _width, _inputHeight, FlowPanel.INPUT);
			_stylePanel.changeTarget = _inputFlow;
			_stylePanel.borderTarget = _showFlow;
			//send button
			_sendButton = new PushButton(this, 0, _inputFlow.y + _inputHeight + 5, "发  送", onSendButtonMouseClick);
			_sendButton.x = _width - _sendButton.width - 5;
			//event listener
			addEventListeners();
		}
		
		private function addEventListeners():void 
		{
			//房间进出
			EventProxy.subscribeEvent(this, RoomUsersEvent.ROOM_LEFT, onRoomLeft);
			EventProxy.subscribeEvent(this, RoomUsersEvent.ROOM_JOINED, onRoomJoined);
			//用户进出
			EventProxy.subscribeEvent(this, RoomUsersEvent.USER_JOINED, onUserJoined);
			EventProxy.subscribeEvent(this, RoomUsersEvent.USER_LEFT, onRoomLeft);
			//登陆信息
			EventProxy.subscribeEvent(this, LogsEvent.LOGS, onLogs);
			//房间信息
			EventProxy.subscribeEvent(this, ChatMessageEvent.GROUP_MESSAGE, onGroupMessage);
			EventProxy.subscribeEvent(this, RoomView.SEND_MESSAGE, onSendMessage);
			//添加表情
			EventProxy.subscribeEvent(this, FaceEvent.ADD_FACE, onAddFace);
			EventProxy.subscribeEvent(this, AvailableRoomsEvent.ROOMS_RECOVERED, onAvailableRooms);
		}
		
		private function onAvailableRooms(e:AvailableRoomsEvent):void 
		{
			for each(var i in e.currentRooms) {
				//trace(i.jid);
				if (room == null) return;
				if (room.roomJID.bareJID == i.jid) {
					updateTitle(i.name, i.users);
				}
			}
		}
		
		override public function draw():void {
			super.draw();
		}
		/**
		 * 添加表情
		 * @param	e
		 */
		private function onAddFace(e:FaceEvent):void 
		{
			if (e.flow != null && e.face != null) e.flow.addFace(e.face.source);
		}
		/**
		 * 群聊
		 * @param	e
		 */
		private function onGroupMessage(e:ChatMessageEvent):void 
		{
			eeDebug.trace("onGroupMessage. " + e.from);
			eeDebug.trace("mssage: " + e.lastMessage);
			var date:Date = new Date();
			if (e.lastMessage.time != null) {
				date = e.lastMessage.time;
			}
			var color:String = "19148A";
			if (e.from.resource == null || room == null) {
				return;
				from = "系统  ";
				color = "CC3333";
			}
			var from:String = e.from.resource + "  ";
			if (room.nickname == e.from.resource) {
				color = "2D6D55";
				//from=
			}
			var time:String = " " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds() + " ";
			
			var message:String = '<p>' + ChatStyle.instance.color(color, from + time) + '</p>' + e.lastPlainMessage;
			
			_showFlow.addMessage(message);
		}
		/**
		 * 群私聊
		 * @param	e
		 */
		private function onPrivateMessage(e:ChatMessageEvent):void 
		{
			eeDebug.trace("onPrivateMessage. " + e.from);
			eeDebug.trace("message: " + e.lastPlainMessage);
			var date:Date = new Date();
			if (e.lastMessage.time != null) {
				date = e.lastMessage.time;
			}
			var time:String = "[" + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds() + "] ";
			var from:String = e.from + " > YOU: ";
			var body:String = e.lastPlainMessage + "\n";
			_showFlow.addMessage(time + from + body);
		}
		/**
		 * 登陆信息
		 * @param	e
		 */
		private function onLogs(e:LogsEvent):void 
		{
			//trace(e.logMessage);
		}
		/**
		 * 加入房间
		 * @param	e
		 */
		//private var _nickName:String;
		//private var _roomName:String;
		private var room:Room;
		private function onRoomJoined(e:RoomUsersEvent):void 
		{
			eeDebug.trace("onRoomJoin. " + e.toString());
			_showFlow.addMessage("Join (" + e.roomData.roomName + ")");
			//updateTitle(e.roomData.roomName, "");
			room = e.roomData;
			//_nickName = e.roomData.nickname;
			//_roomName = e.roomData.roomName;
			
		}
		/**
		 * 离开房间
		 * @param	e
		 */
		private function onRoomLeft(e:RoomUsersEvent):void 
		{
			eeDebug.trace("onRoomLeft. " + e.toString());
			_showFlow.addMessage("Left (" + e.roomData.roomName + ")");
		}
		/**
		 * 发送按钮点击
		 * @param	e
		 */
		private function onSendButtonMouseClick(e:MouseEvent):void {
			onSendMessage(null);
		}
		/**
		 * 发送消息
		 * @param	e
		 */
		private function onSendMessage(e:Event):void {
			trace("**>sending input message");
			var body:String = _inputFlow.getMessage();
			//trace(body);
			//if (body == "") return;
			var message:Message = new Message(null, null, null , null, Message.TYPE_GROUPCHAT);
			message.body = body;
			//message.from=
			var evt:ChatMessageEvent = new ChatMessageEvent(ChatMessageEvent.SEND_GROUP_MESSAGE, message);
			EventProxy.broadcastEvent(evt);
			_inputFlow.clear();
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
		
		private function updateTitle(name:String = "", num:String = ""):void {
			roomTitle.text = "房间: " + name + " [ " + num + " ]";
		}
		
		/////////////未开放功能////////////
		/**
		 * 离开房间
		 * 显示房间列表
		 */
		private function leaveRoom():void {
			//roomManager.leave();
			//rlist.show(this);
			//EventProxy.broadcastEvent(
		}
		/**
		 * 房间列表点击
		 * @param	jid : 房间JID
		 */
		private function onRoomMouse(jid:String):void {
			/*var roomJID:EscapedJID = new EscapedJID(jid);
			var room:Room = new Room(connection.connection);
			room.roomJID = roomJID.unescaped;
			var user:User = connection.user;
			var userJID:UnescapedJID = new UnescapedJID(user.username + "@" + connection.connection.domain);
			roomManager.joinRoom(room, userJID);*/
		}
		private function sendMessageTo():void {
			
		}
		private function onUserJoined(e:RoomUsersEvent):void 
		{
			trace(".onUserJoined: " +e.toString() );
		}
		private function onUserLeft(e:RoomUsersEvent):void 
		{
			trace(".onUserLeft: " +e.toString() );
		}
	}

}