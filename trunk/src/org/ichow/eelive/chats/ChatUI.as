package org.ichow.eelive.chats
{
	public interface ChatUI
	{
		function get isTyping():Boolean;
		function set isTyping(flag:Boolean):void;
		
		function addMessage(message:SparkMessage):void;
		function addNotification(notification:String, color:String):void;
		function addSystemMessage(body:String, time:Date = null):void;
		
		function screen(msgID:String, obj:Object):void;
		function resume(msgID:String, obj:Object):void;
	}
}