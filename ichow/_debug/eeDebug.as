package org.ichow.debug 
{
	import com.hexagonstar.util.debug.Debug;
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class eeDebug 
	{
		public static var isDebug:Boolean = true;
		
		public static function trace(...args):void {
			if (isDebug) {
				Debug.trace(args);
			}
		}
		public static function traceObj(obj:Object, depth:int = 64, level:int = 1):void {
			if (isDebug) {
				Debug.traceObj(obj, depth, level);
			}
		}
		public static function inspect(obj:Object):void {
			if (isDebug) {
				Debug.inspect(obj);
			}
		}
	}

}