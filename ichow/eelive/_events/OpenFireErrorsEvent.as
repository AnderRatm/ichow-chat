package org.ichow.eelive.events
{
	import flash.events.Event;

	public class OpenFireErrorsEvent extends Event
	{
		public static const SERVER_ERROR:String = "onOpenFireError";
		public static const CONNECTION_ERROR:String = "onConnectionError";
		public static const ADMIN_ERROR:String = "onAdminError";
		
		public var errorCode:uint;
		public var errorMessage:String
		
		public function OpenFireErrorsEvent(type:String, code:int, message:String = "", bubbles:Boolean=false, cancelable:Boolean=false){
			
			super(type, bubbles, cancelable);
			
			errorCode = code;
			errorMessage = message;
			
		}
		
	}
}