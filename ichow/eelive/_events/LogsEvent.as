package org.ichow.eelive.events
{
	import flash.events.Event;

	public class LogsEvent extends Event
	{
		public static const LOGS:String = "onLogs";
		public static const WARNings:String = "onWarnings";
		
		public var logMessage:String;
		
		public function LogsEvent(type:String, message:String, bubbles:Boolean=false, cancelable:Boolean=false){
			
			super(type, bubbles, cancelable);
			
			var date:Date = new Date();
			
			logMessage = "@" +" [" + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds() + "] " + message + "\n";
			
		}
		
	}
}