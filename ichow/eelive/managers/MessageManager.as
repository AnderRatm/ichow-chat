package org.ichow.eelive.managers 
{
	import flash.events.EventDispatcher;
	import org.igniterealtime.xiff.events.MessageEvent;
	
	/**
	 * ...
	 * @author ichow
	 */
	public class MessageManager extends EventDispatcher 
	{
		
		public function MessageManager() 
		{
			
		}
		
		public static function init():void {
			SparkManager.connectionManager.connection.addEventListener(MessageEvent.MESSAGE, onMessage);
		}
		
		static private function onMessage(e:MessageEvent):void 
		{
			trace(".onMessage: " + e.toString());
		}
	}

}