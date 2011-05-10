package org.ichow.eelive.view 
{
	import com.hurlant.util.der.Integer;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import org.ichow.components.Panel;
	import org.ichow.components.VScrollPane;
	import org.ichow.components.Window;
	import org.ichow.debug.eeDebug;
	import org.ichow.eelive.core.FaceByteArray;
	import org.igniterealtime.xiff.data.im.RosterItemVO;
	import org.igniterealtime.xiff.data.Message;
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class GroupList extends BaseView 
	{
		
		private var _item:Array;
		private var _wins:Array;
		
		private var _border:Panel;
		private var _scrollPane:VScrollPane;
		
		private var _headTimer:Timer;
		
		private var _heads:Array;
		
		public function GroupList(	parent:DisplayObjectContainer,
									xpos:Number = 0, 
									ypos:Number =  0,
									width:Number = 0,
									height:Number = 0,
									type:String = "",
									item:Array=null
									) 
		{
			this._item = item;
			super(parent, xpos, ypos, width, height, type);
		}
		
		protected override function init():void {
			super.init();
			
		}
		
		protected override function addChildren():void {
			super.addChildren();
			
			_wins = new Array();
			_heads = new Array();
			
			_border = new Panel(this, 0, 0);
			_scrollPane = new VScrollPane(_border, 0, 0);
			_scrollPane.autoHideScrollBar = true;
			_scrollPane.dragContent = false;
			_scrollPane.isbg = false;
			
			
			_headTimer = new Timer(1000, 0);
			_headTimer.addEventListener(TimerEvent.TIMER, onHeadTimer);
			
			if(_item!=null) update();
		}
		
		public function set items(value:Array):void {
			this._item = value;
			update();
		}
		
		private function update():void {
			clear();
			for (var i:int = 0, len:int = _item.length; i < len; i++) {
				addGroup(_item[i].label, _item[i].data, i);
			}
			_headTimer.start();
			draw();
		}
		
		public function clear():void {
			while(_scrollPane.content.numChildren>0){
				_scrollPane.content.removeChildAt(0);
			}
		}
		
		private function onHeadTimer(e:TimerEvent):void 
		{
			if (FaceByteArray.isHeaded) {
				_headTimer.stop();
				initHeads();
			}
		}
		/**
		 * 头像
		 */
		private function initHeads():void 
		{
			var len:int = FaceByteArray.heads.length;
			for each(var i in _wins) {
				for (var j:int = 0, jlen:int = (i as Window).content.numChildren; j < jlen; j++) {
					GroupListHead((i as Window).content.getChildAt(j)).head=FaceByteArray.heads[Math.floor(Math.random() * len)].data;
				}
			}
		}
		
		public function addGroup(label:String, data:Array, id:int):void {
			
			var _win:Window = new Window(_scrollPane, 0, 0, label);
			_win.minimized = true;
			_win.draggable = false;
			_win.hasMinimizeButton = true;
			_win.isbg = false;
			_win.width = _width;
			_win.filters = [];
			_win.addEventListener(Event.RESIZE, onResize);
			
			for (var i:int = 0; i < data.length; i++) {
				var ros:RosterItemVO = data[i] as RosterItemVO;
				var h:GroupListHead = new GroupListHead(_win, 0, 0, 50, 50, "head", ros.jid.bareJID, ros.displayName);
				h.x = 10;
				h.y = 5 + i * 52;
				_heads.push(h);
			}
			_win.setSize(_width - 10, _win.content.numChildren * 52 + 30);
			_wins.push(_win);
		}
		
		public function updateStatus(dic:Dictionary):void {
			for (var i:int = 0, len:int = _heads.length; i < len; i++) {
				var h:GroupListHead = _heads[i];
				
				if (dic[h.jid] == "Online") h.isOn = true;
				else h.isOn = false;
			}
		}
		
		public function hasMessage(message:Message):void {
			var from:String = message.from.bareJID;
			//trace(message.from);
			for each(var i:GroupListHead in _heads) {
				if (i.jid == from) {
					//trace(i.jid);
					i.jump();
				}
			}
		}
		public function noMessage(jid:String):void {
			for each(var i:GroupListHead in _heads) {
				if (i.jid == jid) {
					i.stop();
				}
			}
		}
		
		private function onResize(e:Event):void 
		{
			draw();
			
		}
		
		public override function draw():void {
			super.draw();
			
			var xpos:int = 0, ypos:int = 0;
			for (var i:int = 0, len:int = _wins.length; i < len; i++) {
				var _win:Window = _wins[i];
				_win.move(xpos, ypos);
				xpos = 0;
				ypos = _win.height + _win.y;
			}
			
			_border.setSize(_width, _height);
			_scrollPane.move(5, 5);
			_scrollPane.setSize(_width - 10, _height - 10);
			_scrollPane.update();
		}
		
	}

}