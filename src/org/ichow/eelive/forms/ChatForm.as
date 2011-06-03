package org.ichow.eelive.forms 
{
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.hexagonstar.util.debug.Debug;
	import com.hurlant.util.Base64;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import org.ichow.eelive.chats.ChatUI;
	import org.ichow.eelive.chats.SparkChat;
	import org.ichow.eelive.chats.SparkMessage;
	import org.ichow.eelive.components.HeadItem;
	import org.ichow.eelive.components.TextFlowPanel;
	import org.ichow.eelive.managers.ChatManager;
	import org.ichow.eelive.managers.SparkManager;
	import org.ichow.eelive.managers.tools.ToolsManager;
	import org.ichow.eelive.utils.ChatStyle;
	import org.ichow.eelive.utils.ChatUtil;
	import org.ichow.eelive.utils.DateUtil;
	import org.igniterealtime.xiff.data.Message;
	
	/**
	 * ...
	 * @author ichow
	 */
	public class ChatForm extends BaseForm implements ChatUI,IFace
	{
		private var _isTyping:Boolean;
		private var _xml:XML;
		private var _headPanel:Panel;
		private var _head:HeadItem;
		
		private var _messageShow:Panel;
		private var _messageInput:Panel;
		private var _flowShow:TextFlowPanel;
		private var _flowInput:TextFlowPanel;
		
		private var _sendImageButton:PushButton;
		private var _closeButton:PushButton;
		private var _sendFacesButton:PushButton;
		private var _fontStyleButton:PushButton;
		private var _drawButton:PushButton;
		private var _sendMessage:PushButton;
		
		private var _styleBar:Panel;
		
		public function ChatForm(
			xml:*= "",
			parent:DisplayObjectContainer = null,
			xpos:Number = 0,
			ypos:Number = 0,
			type:String = ""
			)  
		{
			_xml = new XML(xml);
			super(parent, xpos, ypos, type);
		}
		
		override protected function addChildren():void 
		{
			super.addChildren();
			composition.parseXML(_xml);
			
			_headPanel = composition.getCompById("HeadIcon") as Panel;
			_messageShow = composition.getCompById("MessageShow") as Panel;
			_messageInput = composition.getCompById("MessageInput") as Panel;
			_styleBar = composition.getCompById("StyleBar") as Panel;
			
			_flowShow = new TextFlowPanel(_messageShow, _messageShow.width, _messageShow.height, 5, TextFlowPanel.DYNAMIC);
			_flowInput = new TextFlowPanel(_messageInput, _messageInput.width, _messageInput.height, 5, TextFlowPanel.INPUT);
			_flowInput.autoSize = true;
			_flowShow.autoSize = true;
			//
			//表情
			_sendFacesButton = composition.getCompById("SendFacesButton") as PushButton;
			//字体
			_fontStyleButton = composition.getCompById("FontStyleButton") as PushButton;
			//发图片
			_sendImageButton = composition.getCompById("SendImageButton") as PushButton;
			//画图
			_drawButton = composition.getCompById("DrawButton") as PushButton;
			//发消息
			_sendMessage = composition.getCompById("SendMessageButton") as PushButton;
			//关闭
			_closeButton = composition.getCompById("CloseButton") as PushButton;
		}
		/**
		 * 添加偵聽
		 */
		override protected function addEventListeners():void 
		{
			super.addEventListeners();
			_sendFacesButton.addEventListener(MouseEvent.CLICK, onSendFacesMouseClick);
			_fontStyleButton.addEventListener(MouseEvent.CLICK, onFontStyleMouseClick);
			_sendImageButton.addEventListener(MouseEvent.CLICK, onSendImageMouseClick);
			_sendMessage.addEventListener(MouseEvent.CLICK, onSendMessageMouseClick);
			_closeButton.addEventListener(MouseEvent.CLICK, onCloseMouseClick);
			_drawButton.addEventListener(MouseEvent.CLICK, onDrawMouseClick);
		}
		/**
		 * 刪除偵聽
		 */
		override protected function removeEventListeners():void 
		{
			super.removeEventListeners();
			_sendFacesButton.removeEventListener(MouseEvent.CLICK, onSendFacesMouseClick);
			_fontStyleButton.removeEventListener(MouseEvent.CLICK, onFontStyleMouseClick);
			_sendImageButton.removeEventListener(MouseEvent.CLICK, onSendImageMouseClick);
			_sendMessage.removeEventListener(MouseEvent.CLICK, onSendMessageMouseClick);
			_closeButton.removeEventListener(MouseEvent.CLICK, onCloseMouseClick);
			_drawButton.removeEventListener(MouseEvent.CLICK, onDrawMouseClick);
		}
		/**
		 * 画图
		 * @param	e
		 */
		private function onDrawMouseClick(e:MouseEvent):void 
		{
			//var rect:Rectangle = _flowInput.getBounds(this);
			//ToolsManager.drawManager.bind(rect, this, _drawButton);
		}
		/**
		 * 表情
		 * @param	e
		 */
		private function onSendFacesMouseClick(e:MouseEvent):void 
		{
			ToolsManager.facesManager.bind(this, _sendFacesButton);
		}
		/**
		 * 字体样式
		 * @param	e
		 */
		private function onFontStyleMouseClick(e:MouseEvent):void 
		{
			ToolsManager.fontStyleManager.bind(head.jid.bareJID, _flowInput, _fontStyleButton);
		}
		/**
		 * 发送图片事件
		 * @param	e
		 */
		private function onSendImageMouseClick(e:MouseEvent):void 
		{
			ToolsManager.browseManager.bind(this);
		}
		/**
		 * 关闭
		 * @param	e
		 */
		private function onCloseMouseClick(e:MouseEvent):void 
		{
			var chat:SparkChat = ChatManager.sharedInstance.getChat(this.head.jid);
			ChatManager.sharedInstance.closeChat(chat);
		}
		/**
		 * 发送信息
		 * @param	e
		 */
		private function onSendMessageMouseClick(e:MouseEvent):void 
		{
			//get text
			var body:String = _flowInput.getMessage();
			//send message
			var chat:SparkChat = ChatManager.sharedInstance.getChat(this.head.jid);
			
			if (!chat) return;
			var message:Message = new Message();
			message.to = chat.jid.escaped;
			message.from = SparkManager.me.jid.escaped;
			message.body = Base64.encode(ChatUtil.escapeImg(body));
			message.time = new Date();
			var sm:SparkMessage = SparkMessage.fromMessage(message, chat);
			
			chat.transmitMessage(sm);
			if (chat.jid.toString().indexOf("conference") == -1)
				addMessage(sm);
			
			_flowInput.clear();
			Debug.trace("sendMessage: " + message.body, Debug.LEVEL_DEBUG);
			
		}
		/**
		 * 設置頭像
		 */
		public function set head(value:HeadItem):void {
			if (_headPanel)
			{
				_headPanel.addChild(value);
				_head = value;
			}
		}
		public function get head():HeadItem { return _head; }
		
		/* INTERFACE IShow */
		
		/**
		 * 隐藏
		 */
		override public function hide():void 
		{
			super.hide();
			var chat:SparkChat = ChatManager.sharedInstance.getChat(head.jid);
			chat.activated = false;
		}
		
		/* INTERFACE IFace */
		
		/**
		 * 添加表情
		 * @param	url
		 */
		public function addFace(url:*):void {
			if (url is String) {
				//add face
				_flowInput.addFace(url);
			}
			else if(url is XML)
			{
				//save info
				var l:String = url.local.@url;
				l = l.toLowerCase();
				ChatUtil.images[l] = ChatUtil.buildImgURL(url.net.@url);
				_flowInput.addFace(l);
			}
		}
		
		/* INTERFACE org.ichow.eelive.chats.ChatUI */
		
		/**
		 * 输入状态
		 */
		public function get isTyping():Boolean { return _isTyping; }
		public function set isTyping(value:Boolean):void { _isTyping = value; }
		/**
		 * 添加信息
		 * @param	message
		 */
		public function addMessage(message:SparkMessage):void 
		{
			var nick:String = message.nick;
			var content:String = ChatUtil.unescapeImg(Base64.decode(message.body));
			_flowShow.addMessage(ChatStyle.instance.addRecord("chat", { self:nick, content:content, time:DateUtil.getDate() } ));
			//ToolsManager.historyManager.save(message.from, { label:nick, content:content, id:message.id, jid:message.from.bareJID } );
		}
		/**
		 * 通知
		 * @param	notification
		 * @param	color
		 */
		public function addNotification(notification:String, color:String):void 
		{
			
		}
		/**
		 * 系统信息
		 * @param	body
		 * @param	time
		 */
		public function addSystemMessage(body:String, time:Date = null):void 
		{
			_flowShow.addMessage(ChatStyle.instance.addRecord("system", { content:body } ));
		}
		/**
		 * 恢复
		 * @param	msgID
		 * @param	obj
		 */
		public function resume(msgID:String, obj:Object):void {
			_flowShow.replace(msgID, obj);
		}
		/**
		 * 屏蔽
		 * @param	msgID
		 * @param	obj
		 */
		public function screen(msgID:String, obj:Object):void {
			_flowShow.replace(msgID, obj);
		}
		
	}

}