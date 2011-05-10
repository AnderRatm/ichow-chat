package org.ichow.eelive.view 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import org.ichow.components.Panel;
	import org.ichow.components.PushButton;
	import org.ichow.components.Window;
	import org.ichow.debug.eeDebug;
	import org.ichow.eelive.events.PrivateChatEvent;
	import org.ichow.event.EventProxy;
	import org.ichow.settings.eeLiveSettings;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.events.MessageEvent;
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class PrivateChatView extends BaseView 
	{
		private var _chats:Array;
		private var _parent:DisplayObjectContainer;
		private var _open:Boolean;
		public var _list:ChatList;
		private var _panel:Panel;
		private var _win:Window;
		//private var 
		public function PrivateChatView(parent:DisplayObjectContainer,
										xpos:Number = 0,
										ypos:Number = 0,
										width:Number = 0,
										height:Number = 0,
										type:String = ""
										) 
		{
			//save parent (main view)
			this._parent = parent;
			super(parent, xpos, ypos, width, height, type);
			
		}
		
		protected override function addChildren():void {
			super.addChildren();
			_chats = [];
			//win
			_win = new Window(this, 0, 0, "");
			_win.draggable = false;
			_win.titleBar.bg = "TitleWindow_Head_borderSkin";
			_win.titleBar.height = 30;
			_win.hasCloseButton = true;
			_win.addEventListener(Event.CLOSE, onChatClose);
			_list = new ChatList(this, 5, 30, _width-10, 30, "chatList");
			_list.onListMouseClick = onListMouseClick;
			
			//evnets
		}
		
		private function onChatClose(e:Event):void 
		{
			EventProxy.broadcastEvent(new PrivateChatEvent(PrivateChatEvent.REMOVE_PRIVATE_CHAT));
		}
		
		public override function draw():void {
			super.draw();
			_win.setSize(_width, _height);
		}
		/**
		 * 添加信息
		 * @param	message
		 */
		public function addMessageTo(message:Message):void {
			var c:Chat = hasChat(message.from.bareJID);
			if (c == null) {
				var b:PushButton = _list.getChild(message.from.bareJID, "");
				b.visible = false;
				c = addChat(message.from.bareJID);
				c.hide();
			}
			c.addMessage(message);
		}
		/**
		 * 添加聊天框
		 * @param	jid
		 */
		public function addChat(jid:String,displayName:String=""):Chat {
			//
			var chat:Chat = new Chat(this, 5, 60, _width - 10, _height - 70, "chat");
			chat.id = _chats.length;
			chat.jid = jid;
			
			chat.displayName = eeLiveSettings.PRESENCES[jid].displayName;
			
			_list.addItem(_list.getChild(jid,chat.displayName));
			_chats.push(chat);
			//update list
			return chat;
		}
		
		/**
		 * 返回有无聊天框
		 * @param	jid
		 * @return
		 */
		public function hasChat(jid:String):Chat {
			for (var i:int = 0, len:int=_chats.length; i < len; i++) {
				if (_chats[i].jid == jid) return _chats[i];
			}
			return null;
		}
		
		public function onListMouseClick(e:MouseEvent):void {
			//trace(e.target.name);
			for each(var i:Chat in _chats) {
				if (i.jid == e.target.name) {
					i.show();
				}else {
					i.hide();
				}
				
			}
		}
		
		//private function 
		
		public function removeChat(jid:String):void {
			//
			//if (_chats[jid] != null) Chat(_chats[jid]).hide();
			//_chats[jid] = null;
			//update list
		}
		
		
		public function set open(value:Boolean):void {
			_open = value;
		}
		public function get open():Boolean {
			return _open;
		}
		
		
	}

}
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import org.ichow.components.PushButton;
import org.ichow.debug.eeDebug;
import org.ichow.eelive.events.ChatMessageEvent;
import org.ichow.event.EventProxy;
import org.ichow.settings.eeLiveSettings;
import org.ichow.util.ChatStyle;
import org.igniterealtime.xiff.core.EscapedJID;
import org.igniterealtime.xiff.data.im.RosterItemVO;
import org.igniterealtime.xiff.data.Message;
import org.ichow.eelive.view.*;
/**
 * 聊天框
 */
class Chat extends BaseView implements IShow {
	
	
	public var jid:String;
	public var displayName:String;
	public var id:int;
	
	private var _show:FlowPanel;
	private var _input:FlowPanel;
	private var _style:StylePanel;
	private var _send:PushButton;
	private var _parent:DisplayObjectContainer;
	
	public function Chat(parent:DisplayObjectContainer,
						 xpos:Number = 0,
						 ypos:Number = 0,
						 width:Number = 0,
						 height:Number = 0,
						 type:String = ""
						 ) 
	{
		this._parent = parent;
		super(parent, xpos, ypos, width, height, type);
	}
	
	protected override function init():void {
		super.init();
		
	}
	
	protected override function addChildren():void {
		super.addChildren();
		_show = new FlowPanel(this, 0, 0, _width, _height * 3 / 5, FlowPanel.DYNAMIC);
		_style = new StylePanel(this, 0, _show.height, _width, 30, "style");
		_input = new FlowPanel(this, 0, _style.y + _style.height, _width, _height * 2 / 5 - 60, FlowPanel.INPUT);
		_style.changeTarget = _input;
		_style.borderTarget = _show;
		
		_send = new PushButton(this, 0, 0, "发  送", onSendMessage);
		
	}
	
	public override function draw():void {
		super.draw();
		
		_show.move(0, 0);
		_style.move(0, _show.height);
		_input.move(0, _style.y + _style.height);
		_send.move(_width - _send.width, _input.y + _input.height + 5);
		
	}
	
	private function onSendMessage(e:MouseEvent):void {
		//send message
		var message:Message = new Message(new EscapedJID(jid), null, _input.getMessage(), null, Message.TYPE_CHAT);
		
		var evt:ChatMessageEvent = new ChatMessageEvent(ChatMessageEvent.SEND_CHAT_MESSAGE, message);
		EventProxy.broadcastEvent(evt);
		
		var date:Date = new Date();
		var color:String = "2D6D55";
		var time:String = " " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds() + " ";
		var from:String = eeLiveSettings.NICK_NAME == ""?eeLiveSettings.USER_NAME:eeLiveSettings.NICK_NAME + "  ";
		var msg:String = '<p>' + ChatStyle.instance.color(color, from + time) + '</p>' + _input.getMessage();
		_show.addMessage(msg);
		_input.clear();
	}
	
	public function addMessage(message:Message):void {
		
		var date:Date = new Date();
		var color:String = "19148A";
		var time:String = " " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds() + " ";
		
		var from:String = displayName + "  ";
		var msg:String = '<p>' + ChatStyle.instance.color(color, from + time) + '</p>' + message.body;
		_show.addMessage(msg);
	}
	public function getMessage():String {
		return _input.getMessage();		
	}
	
	public function show():void {
		this.visible = true;
		this.mouseChildren = true;
		this.mouseEnabled = true;
	}
	public function hide():void {
		this.visible = false;
		this.mouseChildren = false;
		this.mouseEnabled = false;
	}
}