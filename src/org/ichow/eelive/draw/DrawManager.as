package org.ichow.eelive.draw 
{
	/**
	 * ...
	 * @author ichow
	 */
	public class DrawManager 
	{
		private static var _pencil:Pencil;
		private static var _eraser:Eraser;
		private static var _lastActive:String;
		
		public function DrawManager() 
		{
		}
		
		static public function get pencil():Pencil 
		{
			if (!_pencil) _pencil = new Pencil();
			return _pencil;
		}
		
		static public function get eraser():Eraser 
		{
			if (!_eraser) _eraser = new Eraser();
			return _eraser;
		}
		
		public static function cancel(type:String):void {
			if(this[type] is IDraw)
				(this[type] as IDraw).cancel();
				check(
		}
		
		public static function active(type:String):IDraw {
			if (this[type] is IDraw) {
				if (_lastActive)
					cancel(_lastActive);
				(this[type] as IDraw).active();
				_lastActive = type;
			}
		}
		
		private static function check(_tool:Object):IDraw {
			if (_tool is IDraw)
				return _tool as IDraw;
			else
				return null;
		}
	}

}