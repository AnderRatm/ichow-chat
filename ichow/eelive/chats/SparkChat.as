package org.ichow.eelive.chats
{
	
	import org.ichow.eelive.managers.*;
	import org.igniterealtime.xiff.events.PropertyChangeEvent;
	
	import flash.events.EventDispatcher;
	import flash.xml.XMLNode;
	
	//import mx.collections.ArrayCollection;
	//import mx.controls.*;
	//import mx.events.PropertyChangeEvent;
	
	import org.igniterealtime.xiff.collections.ArrayCollection;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.data.im.RosterItemVO;
	import org.igniterealtime.xiff.util.*;
	
	[Bindable]
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
			var rosterItem:RosterItemVO = RosterItemVO.get(j, true);
			
			_jid = rosterItem.jid;
			displayName = rosterItem.displayName;
			presence = rosterItem.show;
			//PropertyChangeEvent.CHANGE
			rosterItem.addEventListener(PropertyChangeEvent.CHANGE, function(evt:PropertyChangeEvent):void {
				if(evt.property == "show")
					presence = evt.newValue as String;
			});
		}
		
		//return value indicates whether the message did anything the user needs to be notified about, basically. probably less than ideal.
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
		
		[Bindable(event="occupantsChanged")]
		public function get occupants():ArrayCollection {
			return new ArrayCollection([{nick : myNickName}, {nick : displayName}]);
		}
		
		public function get jid():UnescapedJID {
			return _jid;
		}
		
		public function set displayName(nickname:String):void {
			_nickname = nickname;
		}
		
		public function get displayName():String {
			return _nickname;
		}
		
		//the user's nickname; this is because it may vary in groupchats
		public function get myNickName():String {
			return SparkManager.me.displayName;
		}

		public function insertMessage(message:SparkMessage):void 
		{		
			ui.addMessage(message);
		}
			
		public function set presence(presence:String):void {
			_presence = presence;
		}
		
		public function get presence():String {
			return _presence;
		}
		
		public function insertSystemMessage(body:String, time:Date = null):void {
			ui.addSystemMessage(body, time);
		}
		
		//actually does the sending to the connection
		public function transmitMessage(message:SparkMessage):void {
			SparkManager.connectionManager.sendMessage(jid, message.body);
		}
		
		public function init():void 
		{
		}
		
		public function close():void {
		}
	}
}