package org.ichow.eelive.events
{
	import flash.events.Event;

	public class AvailableServicesEvents extends Event
	{
		
		public static const SERVICES_RECOVERED:String = "onServiceRecovered";
		
		public var currentServices:Array;
		
		public function AvailableServicesEvents(services:Array, bubbles:Boolean=false, cancelable:Boolean=false){
			
			super(SERVICES_RECOVERED, bubbles, cancelable);
			
			currentServices = services;
			
			
		}
		
	}
}