package org.ichow.eelive.events
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class HashTableEvent extends Event 
	{
		
		public static const DUPLICATE_ADDED:String = "duplicateAdded";
		public static const SIZE_INCREASED:String = "sizeIncreased";
		public static const KEY_FOUND_IN_DUPLICATES:String = "keyFoundInDuplicates";
		
		public var object:*;
		
		public function HashTableEvent(type:String, data:* = null, bubbles:Boolean=false, cancelable:Boolean=false){
			
			super(type, bubbles, cancelable);
			object = data;
			
		}
		
	}

}