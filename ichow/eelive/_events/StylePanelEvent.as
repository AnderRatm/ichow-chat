package org.ichow.eelive.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class StylePanelEvent extends Event 
	{
		public static const FONT_NAME:String = "fontName";
		public static const FONT_SIZE:String = "fontSize";
		public static const FONT_WEIGHT:String = "fontWeight";
		public static const FONT_STYLE:String = "fontStyle";
		public static const FONT_COLOR:String = "fontColor";
		
		private var _sytle:*;
		public function StylePanelEvent(type:String, style:*, bubbles:Boolean = false, cancelabel:Boolean = false ) 
		{
			_sytle = style;
			super(type, bubbles, cancelabel);
		}
		
	}

}