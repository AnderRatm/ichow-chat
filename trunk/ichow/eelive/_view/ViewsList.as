package org.ichow.eelive.view 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import caurina.transitions.Tweener;
	import org.ichow.components.PushButton;
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class ViewsList extends BaseView 
	{
		private var moveTimer:Timer;
		
		
		public function ViewsList(	items:Dictionary,
									parent:DisplayObjectContainer = null, 
									xpos:Number = 0, 
									ypos:Number =  0,
									width:uint = 0,
									height:uint = 0,
									type:String = ""
									)  
		{
			this._items = items;
			super(parent, xpos, ypos, width, height, type);
		}
		
		override protected function init():void {
			super.init();
			moveTimer = new Timer(200, 0);
			moveTimer.addEventListener(TimerEvent.TIMER, onMoveTimer);
		}
		
		private var _items:Dictionary;
		override protected function addChildren():void {
			super.addChildren();
			
			for (var i:String in _items) {
				addItem(i);
			}
			
			if(_canvas.numChildren>0) (_canvas.getChildAt(0) as PushButton).dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			
			this.addEventListener(MouseEvent.ROLL_OVER, onListRollOver);
			this.addEventListener(MouseEvent.ROLL_OUT, onListRollOut);
		}
		
		
		
		private function addItem(i:String):void 
		{
			var _pb:PushButton = new PushButton(_canvas, 0, 0, i, onListMouseClick);
			_pb.width = 80;
		}
		
		override public function draw():void {
			super.draw();
			for (var i:uint = 0; i < _canvas.numChildren; i++) {
				var pb:PushButton = _canvas.getChildAt(i) as PushButton;
				pb.x = i * (pb.width + 5)+5;
				pb.y = (_height - pb.height) / 2;
			}
			
		}
		
		private function onListMouseClick(e:MouseEvent):void {
			for (var i:uint = 0; i < _canvas.numChildren; i++) {
				if (_canvas.getChildAt(i) is PushButton) {
					var b:PushButton = _canvas.getChildAt(i) as PushButton;
					b.toggle = b == e.currentTarget;
					b.selected = b == e.currentTarget;
					b.draw();
				}
			}
			showItem(_items[(e.currentTarget as PushButton).label]);
			
		}
		
		public function showItem(view:IShow):void {
			for each(var i:IShow in _items) {
				if (i == view) i.show();
				else i.hide();
			}
		}
		
		private function onListRollOver(e:MouseEvent):void 
		{
			moveTimer.start();
		}
		
		private function onListRollOut(e:MouseEvent):void 
		{
			if (moveTimer.running) moveTimer.reset();
		}
		
		private function onMoveTimer(e:TimerEvent):void 
		{
			if (_canvas.width <= _width) return;
			var dx:int = Math.floor((_width - _canvas.width) * (this.mouseX / _width));
			Tweener.addTween(_canvas, { time:.3, x:dx } );
		}
		
	}

}