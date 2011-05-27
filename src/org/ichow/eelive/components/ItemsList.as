package org.ichow.eelive.components {
	import adobe.utils.CustomActions;
	import com.bit101.components.Panel;
	import com.bit101.components.VBox;
	import com.bit101.components.Window;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.ichow.eelive.components.HeadItem;
	import org.ichow.eelive.forms.MainForm;
	import org.ichow.eelive.managers.SparkManager;
	import org.igniterealtime.xiff.data.im.RosterItemVO;

	/**
	 * ...
	 * @author ichow
	 */
	public class ItemsList extends Sprite {
		protected var _items:*;
		protected var _width:Number;
		protected var _height:Number;
		protected var _headType:String;
		protected var _padding:int = 4;
		protected var vbox:VBox;
		protected var checkTimer:Timer;

		private var _bg:Shape;
		private static var _itemsList:Array;

		public function ItemsList(){
			_itemsList = new Array();
			checkTimer = new Timer(500, 0);
			checkTimer.addEventListener(TimerEvent.TIMER, onCheckTimer);
			getitems();
		}

		protected function getitems():void {
		}

		protected function onCheckTimer(e:TimerEvent):void {
		}

		protected function init(items:*, width:Number, height:Number, headType:String):void {
			this._items = items;
			this._width = width;
			this._height = height;
			this._headType = headType;

			clear(vbox);

			vbox = new VBox(this);
			vbox.spacing = 0;
			vbox.move(_padding, _padding);
			for each (var i:Object in _items){
				var o:Window = createList(i);
				if (o)
					vbox.addChild(o);
			}

		}

		private function clear(item:DisplayObjectContainer):void {
			if (item == null)
				return;
			while (item.numChildren > 0){
				clear(item.getChildAt(0) as DisplayObjectContainer);
				item.removeChildAt(0);
			}
		}

		protected function createList(i:Object):Window {
			if (i){
				var w:Window = new Window();
				w.draggable = false;
				w.hasMinimizeButton = true;
				w.shadow = false;
				w.backgroundAlpha = 0;
				w.titleBar.backgroundAlpha = 0;
				w.titleBar.shadow = false;
				w.color = 0xFFFFFF;
				if (i.label)
					w.title = i.label;
				_itemsList[_itemsList.length] = {};
				var v:VBox = new VBox(w);
				v.spacing = 0;
				if (i.items){
					for each (var j:Object in i.items){
						var h:HeadItem = new HeadItem(j.jid, j.displayName, j.status, "def", _headType);
						h.isAvailable = j.status == "在线" ? true : false;
						_itemsList[_itemsList.length - 1][j.jid] = h;
						v.addChild(h);
					}
				}
				w.setSize(_width - 2 * _padding, 30 + v.numChildren * h.height);
				return w;
			}
			return null;

		}

		public static function getItem(jid:*):Array {
			var heads:Array = new Array();
			for (var i:Object in _itemsList){
				for each (var j:HeadItem in _itemsList[i]){
					if (j.jid.bareJID == jid)
						heads.push(j);
				}
			}
			return heads;
		}
	}
}