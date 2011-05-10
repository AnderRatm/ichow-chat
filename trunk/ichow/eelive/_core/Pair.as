package org.ichow.eelive.core
{
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class Pair
	{
		public function Pair(n:String = null, v:* = null){
			_name = n;
			_value = v;
		}
		private var _name:String;
		
		public function get name():String { return _name; }
		public function set name(value:String):void { _name = value; }
		
		private var _value:*;
		
		public function get value():*{ return _value; }
		public function set value(v:*):void { _value = v; }
		
	}

}