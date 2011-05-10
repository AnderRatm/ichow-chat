package org.ichow.eelive.view 
{
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.ichow.components.Panel;
	import org.ichow.components.PushButton;
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class ChatList extends BaseView 
	{
		private var _items:Array;
		private var _boder:Panel;
		private var _jids:Array;
		private var moveTimer:Timer;
		public function ChatList(	parent:DisplayObjectContainer = null, 
									xpos:Number = 0, 
									ypos:Number =  0,
									width:uint = 0,
									height:uint = 0,
									type:String = ""
									)  
		{
			super(parent, xpos, ypos, width, height, type);
		}
		protected override function init():void {
			super.init();
			setSize(_width, _height);
			moveTimer = new Timer(200, 0);
			moveTimer.addEventListener(TimerEvent.TIMER, onMoveTimer);
		}
		
		protected override function addChildren():void {
			super.addChildren();
			_items = [];
			_jids = [];
			_boder = new Panel(this, 0, 0);
			this.addEventListener(MouseEvent.ROLL_OVER, onListRollOver);
			this.addEventListener(MouseEvent.ROLL_OUT, onListRollOut);
		}

		public function getChild(jid:String,displayName:String=""):PushButton {
			if (_jids.indexOf(jid) != -1) {
				return _items[_jids.indexOf(jid)];
			}
			var b:PushButton = new PushButton(null, 0, 0, displayName, onListClick);
			b.name = jid;
			b.toggle = true;
			b.setSize(70, 22);
			_jids.push(jid);
			_items.push(b);
			return b;
		}
		
		private function onListClick(e:MouseEvent):void 
		{
			for (var i:uint = 0; i < _items.length; i++) {
				if (_items[i] is PushButton) {
					var b:PushButton = _items[i] as PushButton;
					b.toggle = b == e.currentTarget;
					b.selected = b == e.currentTarget;
					b.draw();
				}
			}
			_onListMouseClick(e);
		}
		
		private var _onListMouseClick:Function;
		public function set onListMouseClick(fct:Function):void {
			_onListMouseClick = fct;
		}
		
		public function addItem(child:DisplayObject):void
		{
			if (_boder.content.contains(child)) moveTo(child);
			else {
				_boder.addChild(child);
			}
			//(child as PushButton)
			update();
		}
		
		public function moveTo(child:DisplayObject):void 
		{
			
			if ((child.x + _boder.content.x) > (_boder.width - child.width)) {
				Tweener.addTween(_boder.content, { time:.3, x:(child.x + child.width - _boder.width) } );
			}else if ((child.x + _boder.content.x) < 0) {
				Tweener.addTween(_boder.content, { time:.3, x: -child.x } );
			}else {
				trace("moved");
			}
		}
		
		public function removeItem(child:DisplayObject):void {
			if (_boder.content.contains(child)) _boder.content.removeChild(child);
			update();
		}
		
		
		public function update():void 
		{
			var xpos:int = 5;
			for (var i:int = 0, len:int = _boder.content.numChildren; i < len; i++ ) {
				var b:PushButton = _boder.content.getChildAt(i) as PushButton;
				if (!b.visible) continue;
				b.x =  xpos;
				xpos = b.x + b.width;
				b.y = _height - b.height;
			}
		}
		
		public override function draw():void {
			super.draw();
			
			_boder.setSize(_width, _height);
			
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
			if (_boder.content.width <= _width) return;
			var dx:int = Math.floor((_width - _boder.content.width) * (this.mouseX / _width));
			Tweener.addTween(_boder.content, { time:.3, x:dx } );
		}
	}

}