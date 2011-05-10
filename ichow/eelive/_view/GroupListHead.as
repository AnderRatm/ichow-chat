package org.ichow.eelive.view 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import org.ichow.components.Label;
	import org.ichow.eelive.core.FaceItem;
	import org.ichow.eelive.events.PrivateChatEvent;
	import org.ichow.event.EventProxy;
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class GroupListHead extends BaseView 
	{
		
		private var _head:FaceItem;
		private var _jid:String;
		private var _displayName:String;
		private var _icon:Sprite;
		private var _label:Label;
		private var _over:Boolean;
		private var _selected:Boolean;
		private var moveTimer:Timer;
		//private var _empty:Shape;
		
		private var _click:Sprite;
		
		public function GroupListHead(	parent:DisplayObjectContainer,
										xpos:Number = 0, 
										ypos:Number =  0,
										width:Number = 0,
										height:Number = 0,
										type:String = "",
										jid:String = "",
										displayName:String=""
										)
		{
			this._jid = jid;
			this._displayName = displayName;
			
			super(parent, xpos, ypos, width, height, type);
		}
		
		protected override function init():void {
			super.init();
			
		}
		
		protected override function addChildren():void {
			super.addChildren();
			//head icon
			_icon = new Sprite();
			_icon.graphics.beginFill(0x3B9BD2, 1);
			_icon.graphics.drawRect(0, 0, _width, _height);
			_icon.graphics.beginFill(0xFFFFFF, 1);
			_icon.graphics.drawRect(1, 1, _width - 2, _height - 2);
			_icon.graphics.endFill();
			addChild(_icon);
			//
			/*var lod:Loader = new Loader();
			lod.loadBytes*/
			moveTimer = new Timer(300, 0);
			moveTimer.addEventListener(TimerEvent.TIMER, onMoveTimer);
			//name
			_label = new Label(this, 0, 0, this._displayName);
			//info
			
			//event
			this.addEventListener(MouseEvent.ROLL_OVER, onHeadRollOver);
			this.addEventListener(MouseEvent.ROLL_OUT, onHeadRollOut);
			this.addEventListener(MouseEvent.CLICK, onHeadMouseClick);
			
			_click = new Sprite();
			_click.graphics.beginFill(0, 0);
			_click.graphics.drawRect(0, 0, _width, _height);
			_click.graphics.endFill();
			addChild(_click);
			
			_click.doubleClickEnabled = true;
			_click.addEventListener(MouseEvent.DOUBLE_CLICK, onHeadDoubleClick);
		}
		
		public function set head(value:ByteArray):void {
			var lod:Loader = new Loader()
			lod.loadBytes(value);
			_icon.addChild(lod);
			lod.x = 1
			lod.y = 1
		}
		
		private function onHeadDoubleClick(e:MouseEvent):void 
		{
			var evt:PrivateChatEvent = new PrivateChatEvent(PrivateChatEvent.ADD_PRIVATE_CHAT, jid, displayName);
			EventProxy.broadcastEvent(evt);
		}
		
		private function onHeadMouseClick(e:MouseEvent):void 
		{
			//_selected = !_selected;
			//draw();
			
		}
		
		private function onHeadRollOut(e:MouseEvent):void 
		{
			_over = false;
			draw();
		}
		
		private function onHeadRollOver(e:MouseEvent):void 
		{
			_over = true;
			draw();
		}
		
		public override function draw():void {
			super.draw();
			
			_icon.x = 0, _icon.y = 0;
			_label.x = _icon.width + 5;
			
			this.graphics.clear();
			if (_selected) {
				this.graphics.beginFill(0x666666, .7);
			}else if (_over) {
				this.graphics.beginFill(0xCCCCCC, .6);
			}else {
				this.graphics.beginFill(0xFFFFFF, .2);
			}
			this.graphics.drawRect( -10, 0, 200, _height);
			this.graphics.endFill();
			
			//addChild(_empty);
		}
		
		public function get jid():String {
			return _jid;
		}
		public function get displayName():String {
			return _displayName;
		}
		private var _filter:ColorMatrixFilter=new ColorMatrixFilter([	.33, .33, .33, 0, 0,
																		.33, .33, .33, 0, 0,
																		.33, .33, .33, 0, 0,
																		0, 0, 0, 1, 0 ]);
		public function set isOn(value:Boolean):void {
			if (value) {
				_icon.filters = [];
			}else {
				_icon.filters = [_filter];
			}
		}
		
		public function onMoveTimer(e:TimerEvent):void {
			_icon.x = _icon.y = (Math.random() > .5?1: -1) * Math.random() * 1;
			//trace(_icon.x);
		}
		public function jump():void {
			moveTimer.start();
		}
		
		public function stop():void {
			moveTimer.stop();
			_icon.x = _icon.y = 0;
		}
		
	}

}