package org.ichow.eelive.draw 
{
	import flash.display.DisplayObject;
	import org.ichow.eelive.forms.IShow;
	
	/**
	 * ...
	 * @author ichow
	 */
	internal interface IDraw
	{
		function bind(_board:DisplayObject):void;
		function clear():void;
		function active():void;
		function cancel():void;
	}
	
}