package org.ichow.eelive.components 
{
	
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public interface ITextLayoutFormat 
	{
		function set fontFamily(font:*):void
		function get fontFamily():*;
		
		function set fontSize(value:*):void;
		function get fontSize():*;
		
		function set fontWeight(type:*):void;
		function get fontWeight():*;
		
		function set fontColor(color:*):void;
		function get fontColor():*;
		
		function set fontStyle(style:*):void;
		function get fontStyle():*;
		
		function set textDecoration(value:*):void;
		function get textDecoration():*;
	}
	
}