package org.ichow.eelive.forms 
{
	import com.bit101.utils.MinimalConfigurator;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author ichow
	 */
	public class BaseForm extends Sprite implements IShow
	{
		protected var _width:int;
		protected var _height:int;
		protected var _enabled:Boolean = true;
		protected var _type:String;
		protected var _parent:DisplayObjectContainer
		
		protected var canvas:Sprite;
		protected var composition:MinimalConfigurator;
		
		protected var _invaliTimer:Timer;
		public function BaseForm(
			parent:DisplayObjectContainer = null,
			xpos:Number = 0,
			ypos:Number = 0,
			type:String = "") 
		{
			this._type = type;
			this._parent = parent;
			move(xpos, ypos);
			init();
		}
		
		protected function init():void
		{
			_invaliTimer = new Timer(10, 0);
			
			addChildren();
			invalidate();
		}
		
		protected function addChildren():void 
		{
			canvas = new Sprite();
			addChild(canvas);
			composition = new MinimalConfigurator(canvas);
		}
		
		private function onInvaliTimer(e:TimerEvent):void 
		{
			if (_invaliTimer.running) _invaliTimer.reset();
			draw();
		}
		
		protected function invalidate():void
		{
			if (_invaliTimer.running) _invaliTimer.reset();
			_invaliTimer.start();
		}
		
		protected function disEnabled():void
		{
			
		}
		
		protected function addEventListeners():void {
			_invaliTimer.addEventListener(TimerEvent.TIMER, onInvaliTimer);
		}
		
		protected function removeEventListeners():void {
			_invaliTimer.removeEventListener(TimerEvent.TIMER, onInvaliTimer);
		}
		
		public function draw():void {
			canvas.x = Math.floor(canvas.width / -2);
			canvas.y = Math.floor(canvas.height / -2);
			dispatchEvent(new Event("draw"));
		}
		
		public function move(xpos:Number, ypos:Number):void
		{
			x = Math.round(xpos);
			y = Math.round(ypos);
		}
		
		public function setSize(w:Number, h:Number):void
		{
			_width = w;
			_height = h;
			dispatchEvent(new Event(Event.RESIZE));
			invalidate();
		}
		
		public function show():void 
		{
			//trace(this.type + " : show");
			addEventListeners();
			if (_parent) _parent.addChild(this);
		}
		
		public function hide():void
		{
			//trace(this.type + " : hide");
			removeEventListeners();
			if (_parent && _parent.contains(this)) _parent.removeChild(this);
		}
		
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////
		
		/**
		 * Sets/gets the width of the component.
		 */
		override public function set width(w:Number):void
		{
			_width = w;
			invalidate();
			dispatchEvent(new Event(Event.RESIZE));
		}
		override public function get width():Number
		{
			return _width;
		}
		
		/**
		 * Sets/gets the height of the component.
		 */
		override public function set height(h:Number):void
		{
			_height = h;
			invalidate();
			dispatchEvent(new Event(Event.RESIZE));
		}
		override public function get height():Number
		{
			return _height;
		}
		
/**
		 * Overrides the setter for x to always place the component on a whole pixel.
		 */
		override public function set x(value:Number):void
		{
			super.x = Math.round(value);
		}
		
		/**
		 * Overrides the setter for y to always place the component on a whole pixel.
		 */
		override public function set y(value:Number):void
		{
			super.y = Math.round(value);
		}

		/**
		 * Sets/gets whether this component is enabled or not.
		 */
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			mouseEnabled = mouseChildren = _enabled;
            tabEnabled = value;
			//alpha = _enabled ? 1.0 : 0.5;
			if (!_enabled) disEnabled();
			draw();
		}
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function get type():String 
		{
			return _type;
		}
		
	}

}