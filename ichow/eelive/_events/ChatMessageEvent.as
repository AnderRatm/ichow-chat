package org.ichow.eelive.events
{
	import flash.events.Event;
	
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.data.Message;

	public class ChatMessageEvent extends Event
	{
		
		public static const GROUP_MESSAGE:String 	= "onGroupMessage";
		public static const PRIVATE_MESSAGE:String 	= "onPrivateMessage";
		public static const SEND_GROUP_MESSAGE:String = "sendGroupMessage";
		public static const SEND_CHAT_MESSAGE:String = "sendChatMessage";
		
		public var lastMessage:Message;
		public var lastPlainMessage:String;
		public var lastHtmlMessage:String;
		public var from:EscapedJID
		
		public function ChatMessageEvent(type:String, message:Message, bubbles:Boolean=false, cancelable:Boolean=false){
			
			super(type, bubbles, cancelable);
			
			lastMessage = message;
			
			lastPlainMessage = lastMessage.body;
	//		lastHtmlMessage = lastMessage.htmlBody;
			
			if (message.from != null) from = (message.from as EscapedJID);
			 
			
		}
		
	}
}