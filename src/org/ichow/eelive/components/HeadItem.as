package org.ichow.eelive.components {
	import com.bit101.components.Style;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import org.ichow.eelive.managers.ChatManager;
	import org.ichow.eelive.managers.tools.ToolsManager;
	import org.igniterealtime.xiff.core.UnescapedJID;

	/**
	 * ...
	 * @author ichow
	 */
	public class HeadItem extends Sprite {
		public static const SMALL:String = "small";
		public static const BIG:String = "big";
		public static const NAME:uint = 0x333333;
		public static const STATUS:uint = 0xCCCCCC;
		public static const BACK_GROUND_COLOR:uint = 0xE5F2FB;

		private static var filter:ColorMatrixFilter = new ColorMatrixFilter([.33, .33, .33, 0, 0, .33, .33, .33, 0, 0, .33, .33, .33, 0, 0, 0, 0, 0, 1, 0]);

		private var _x:Number;
		private var _y:Number;
		private var _width:Number;
		private var _height:Number;
		private var _type:String;
		private var _jid:UnescapedJID;
		private var _label:String;
		private var _status:String;
		private var _headID:String;
		private var _head:Sprite;

		private var _name:TextField;
		private var _info:TextField;
		private var _padding:int = 5;
		private var _side:Number;
		private var _empty:Sprite;
		private var _moveTimer:Timer = new Timer(200, 0);


		public function HeadItem(jid:UnescapedJID, label:String = null, status:String = null, head:String = null, type:String = "big", mouseEffect:Boolean = true){
			super();
			this._jid = jid
			this._label = label;
			this._status = status;
			this._headID = head;
			this._type = type;
			_head = new Sprite();
			//
			if (label)
				_name = getTf(label, HeadItem.NAME);
			if (status)
				_info = getTf(status, HeadItem.STATUS);
			//
			update();
			if (mouseEffect){
				_empty = new Sprite();
				_empty.graphics.beginFill(0x000000, 0);
				_empty.graphics.drawRect(0, 0, 200, _side + 2 * _padding);
				_empty.graphics.endFill();
				this.addChild(_empty);
				addEventListeners();
			}
		}

		/**
		 * 添加侦听
		 */
		private function addEventListeners():void {
			this.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			this.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			_empty.doubleClickEnabled = true;
			_empty.addEventListener(MouseEvent.DOUBLE_CLICK, onMouseDoubleClick);
			_moveTimer.addEventListener(TimerEvent.TIMER, onMoveTimer);
		}

		/**
		 * 双击
		 * @param	e
		 */
		private function onMouseDoubleClick(e:MouseEvent):void {
			if (this.jid.toString().indexOf("conference") != -1){
				ChatManager.sharedInstance.joinGroupChat(this.jid);
			} else {
				ChatManager.sharedInstance.startChat(this.jid);
			}
			var heads:Array = ItemsList.getItem(this.jid.bareJID);
			for each (var i:HeadItem in heads){
				i.hasMessage = false;
			}
			heads = null;
		}

		private function onRollOut(e:MouseEvent):void {
			this.graphics.clear();
		}

		private function onRollOver(e:MouseEvent):void {
			draw(BACK_GROUND_COLOR);
		}

		/**
		 * 背景
		 * @param	color
		 */
		private function draw(color:uint):void {
			this.graphics.clear();
			this.graphics.beginFill(color, .8);
			this.graphics.drawRect(0, 0, 200, _side + 2 * _padding);
			this.graphics.endFill();
		}

		/**
		 * 获取文本
		 * @param	text
		 * @param	color
		 * @return
		 */
		private function getTf(text:String, color:uint):TextField {
			var _tf:TextField = new TextField();
			_tf.defaultTextFormat = new TextFormat(Style.fontName, 12, color);
			_tf.tabEnabled = false;
			_tf.selectable = false;
			_tf.autoSize = TextFieldAutoSize.LEFT;
			_tf.text = text;
			return _tf;
		}

		/**
		 * 设置图像
		 * @param	head
		 */
		private function loadHead(head:*):void {
			while (_head.numChildren > 0){
				_head.removeChildAt(0);
			}
			ToolsManager.vcardManager.setItem(head, _head, 2, 0);
		}

		public function update():void {
			//head
			//var _side:int = 0;
			if (type == SMALL)
				_side = 20;
			else if (type == BIG)
				_side = 40;
			else if (Number(type) > 0)
				_side = Number(type);
			else
				_side = 0;

			this.addChild(_head);

			_head.x = _head.y = _padding;
			//draw line
			_head.graphics.beginFill(0x999999, 1);
			_head.graphics.drawRect(-2, -2, _side + 4, _side + 4);
			_head.graphics.beginFill(0xFFFFFF, 1);
			_head.graphics.drawRect(-1, -1, _side + 2, _side + 2);
			_head.graphics.endFill();

			if (_headID)
				loadHead(_headID);

			if (_name){
				this.addChild(_name);
				_name.x = _side + _padding * 2;
				_name.y = _padding;
			}
			if (_info){
				this.addChild(_info);
				_info.x = type == BIG ? _name.x : (_name.x + _name.width + _padding);
				_info.y = type == BIG ? (_name.height + _padding + 2) : _padding;
			}

			isAvailable = false;
		}

		public function set hasMessage(v:Boolean):void {
			if (v){
				if (_moveTimer.running)
					_moveTimer.reset();
				_moveTimer.start();
			} else {
				_moveTimer.stop();
				_head.x = _head.y = _padding;
			}
		}

		private function onMoveTimer(e:TimerEvent):void {
			_head.x = _head.y = _padding + (Math.random() > .5 ? 1 : -1) * Math.random() * 1;
		}

		public function set isAvailable(v:Boolean):void {
			_head.filters = v ? [] : [HeadItem.filter];
		}

		///////////////////////////// getter & setter /////////////////////////////

		public function get label():String {
			return _label;
		}

		public function set label(value:String):void {
			_label = value;
			_name.text = value;
		}

		public function get jid():UnescapedJID {
			return _jid;
		}

		public function set jid(value:UnescapedJID):void {
			_jid = value;
		}

		public function get status():String {
			return _status;
		}

		public function set status(value:String):void {
			_status = value;
			_info.text = value;
		}

		public function get type():String {
			return _type;
		}

		public function set type(value:String):void {
			_type = value;
		}

	}

}