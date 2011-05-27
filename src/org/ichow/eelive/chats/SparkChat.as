package org.ichow.eelive.chats
{
	
	import org.ichow.eelive.forms.IShow;
	import org.ichow.eelive.managers.*;
	import org.igniterealtime.xiff.events.PropertyChangeEvent;
	
	import flash.events.EventDispatcher;
	import flash.xml.XMLNode;
	
	import org.igniterealtime.xiff.collections.ArrayCollection;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.data.im.RosterItemVO;
	import org.igniterealtime.xiff.util.*;
	
	public class SparkChat extends EventDispatcher
	{
		private var _ui:ChatUI
		protected var _jid:UnescapedJID;
		protected var _nickname:String;
		protected var windowID:String;
		
		protected var _presence:String;
		protected var _activated:Boolean;
		protected var _isReady:Boolean = false;
				
		public function SparkChat(j:UnescapedJID)
		{
			_jid = j;
		}
		
		public function get ui():ChatUI
		{
			return _ui;
		}
		
		public function set ui(view:ChatUI):void
		{
			_ui = view;
			setup(_jid);
		}
		
		public function setup(j:UnescapedJID):void
		{
			var rosterItem:RosterItemVO = RosterItemVO.get(j,true);
			
			_jid = rosterItem.jid;
			displayName = rosterItem.displayName;
			presence = rosterItem.show;
			rosterItem.addEventListener(PropertyChangeEvent.CHANGE, onRosterItemChange);
		}
		
		private function onRosterItemChange(e:PropertyChangeEvent):void 
		{
			if(e.name == "show")
				presence = e.newValue as String;
		}
		
		public function handleMessage(msg:Message):Boolean
		{
			if(!msg.body)
			{
			    var childNode:XMLNode = msg.getNode().firstChild;
				if(!childNode || childNode.namespaceURI != 'jabber:x:event')
					return false;
				ui.isTyping = childNode.childNodes.some(
					function(node:XMLNode, index:int, arr:Array):Boolean { return node.nodeName == 'composing'; }
				);
				return false;			    
			}
			insertMessage(SparkMessage.fromMessage(msg, this));
			return true;
		}
		
		public function get occupants():ArrayCollection {
			return new ArrayCollection([{nick : myNickName}, {nick : displayName}]);
		}
		
		public function get jid():UnescapedJID { return _jid; }
		/**
		 * 當前顯示名
		 */
		public function get displayName():String {
			if (_nickname == null && jid!=null) {
				var vo:RosterItemVO = RosterItemVO.get(jid);
				if (vo) 
					_nickname = vo.displayName;
			}
			return _nickname;
		}
		public function set displayName(nickname:String):void {	_nickname = nickname; }
		/**
		 * 獲取連接用戶顯示名
		 */
		public function get myNickName():String { return SparkManager.me.displayName; }
		/**
		 * 出席
		 */
		public function set presence(presence:String):void { _presence = presence; }
		public function get presence():String { return _presence; }
		/**
		 * 是否启动
		 */
		public function get activated():Boolean { return _activated; }
		public function set activated(value:Boolean):void { _activated = value; }
		/**
		 * 添加消息
		 * @param	message
		 */
		public function insertMessage(message:SparkMessage):void 
		{
			if (message.nick == myNickName) return;
			ui.addMessage(message);
		}
		/**
		 * 添加系统消息
		 * @param	body
		 * @param	time
		 */
		public function insertSystemMessage(body:String, time:Date = null):void {
			ui.addSystemMessage(body, time);
		}
		/**
		 * 发送消息
		 * @param	message
		 */
		public function transmitMessage(message:SparkMessage):void {
			MessageManager.instance.sendMessage(jid.escaped, message.body, null, Message.TYPE_CHAT);
		}
		
		public function init():void 
		{
		}
		
		public function close():void {
			if (ui is IShow)
				(ui as IShow).hide();
		}
	}
}