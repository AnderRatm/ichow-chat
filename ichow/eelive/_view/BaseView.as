package org.ichow.eelive._view 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import org.ichow.components.Component;
	
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class BaseView extends Component
	{
		protected var _type:String;
		protected var _empty:Sprite;
		protected var _canvas:Sprite;
		
		public function BaseView(	parent:DisplayObjectContainer = null, 
									xpos:Number = 0, 
									ypos:Number =  0,
									width:Number = 0,
									height:Number = 0,
									type:String = ""
									) 
		{
			this._type = type;
			this._width = width;
			this._height = height;
			super(parent, xpos, ypos);
		}
		
		
		override protected function init():void
		{
			super.init();
			setSize(_width, _height);
		}

		override protected function addChildren():void
		{
			_empty = new Sprite();
			addChild(_empty);
			
			_canvas = new Sprite();
			addChild(_canvas);
			
		}
		
		override public function draw():void
		{
			super.draw();
			
			_empty.graphics.clear();
			_empty.graphics.beginFill(0, 0);
			_empty.graphics.drawRect(0, 0, _width, _height);
			_empty.graphics.endFill();
			
			
		}
		
		
		public function get type():String {
			return _type;
		}
		public function set type(value:String):void {
			new Error("form's type is read only!!");
		}
		
		
	}

}