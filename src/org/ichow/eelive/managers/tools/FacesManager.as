package org.ichow.eelive.managers.tools {
	import com.bit101.components.ScrollPane;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import org.ichow.eelive.forms.IFace;
	import org.ichow.eelive.utils.ChatUtil;

	/**
	 * ...
	 * @author ichow
	 */
	public class FacesManager extends ItemsManager {
		public static const TOP:String = "top";
		public static const BOTTOM:String = "bottom";

		private var _side:int = 30;
		private var _horizontalNum:int = 5;
		private var _verticalNum:int = 3;
		private var _open:Boolean = false;
		private var _openPosition:String = BOTTOM;
		private var _scrollPane:ScrollPane;
		private var _faces:Vector.<Sprite>;
		private var _chat:IFace;
		private var _position:DisplayObject;
		private var _stage:Stage;

		public function FacesManager(){
			super();
		}

		/**
		 * 加载完成
		 */
		override protected function onComplete():void {
			super.onComplete();
			addChildren();
		}

		protected function addChildren():void {
			//set util.images
			var _dic:Dictionary = ChatUtil.images;
			for (var j:int = 0, len:int = _xml.item.length(); j < len; j++){
				var _code:String = _xml.item[j].@code;
				var _source:String = _xml.item[j].@source;
				_code = _code.toLowerCase();
				_source = _source.toLowerCase();
				_dic[_code] = _source;
				_dic[_source] = _code;
			}
			//表情列表
			_faces = new Vector.<Sprite>();
			//
			_scrollPane = new ScrollPane();
			_scrollPane.horizontalScrollPolicy = "off";
			_scrollPane.dragContent = false;
			_scrollPane.setSize(_horizontalNum * _side + 20, _verticalNum * _side + 4);
			_scrollPane.update();
			//add faces
			for (var i:int = 0; i < _max; i++){
				var s:Sprite = new Sprite();
				var code:String = _xml.item[i].@code;
				setItem(code, s, 2, 2);
				s.x = 4 + i % _horizontalNum * _side;
				s.y = 4 + Math.floor(i / _horizontalNum) * _side;
				s.name = code;
				_faces.push(s);
				_scrollPane.addChild(s);
			}
			//addEventListeners
			addEventListeners();
			//update
			setTimeout(function():void {
					_scrollPane.update();
				}, 100);
		}

		//////////////////////////// public method ////////////////////////////

		/**
		 * 绑定
		 * @param	chat		:	聊天框【IFace接口】
		 * @param	position	:	呼出按钮
		 */
		public function bind(chat:IFace, position:DisplayObject):void {
			_position = position;
			_chat = chat;
			_stage = _position.stage;
			show();
		}

		//////////////////////////// private method ////////////////////////////

		/**
		 * 添加侦听
		 */
		private function addEventListeners():void {
			//faces
			for each (var i:Sprite in _faces){
				i.addEventListener(MouseEvent.ROLL_OVER, onFaceMouseOver);
				i.addEventListener(MouseEvent.ROLL_OUT, onFaceMouseOut);
				i.addEventListener(MouseEvent.CLICK, onFaceMouseClick);
			}
		}

		/**
		 * 删除侦听
		 */
		private function removeEventListeners():void {
			//faces
			for each (var i:Sprite in _faces){
				i.removeEventListener(MouseEvent.ROLL_OVER, onFaceMouseOver);
				i.removeEventListener(MouseEvent.ROLL_OUT, onFaceMouseOut);
				i.removeEventListener(MouseEvent.CLICK, onFaceMouseClick);
			}
		}

		/**
		 * 表情点击
		 * @param	e
		 */
		private function onFaceMouseClick(e:MouseEvent):void {
			var code:String = e.currentTarget.name;
			_chat.addFace(ChatUtil.images[code]);
			_open = false;
			removeList();
		}

		/**
		 * 表情移出
		 * @param	e
		 */
		private function onFaceMouseOut(e:MouseEvent):void {
			var s:Sprite = e.currentTarget as Sprite;
			s.graphics.clear();
		}

		/**
		 * 表情移进
		 * @param	e
		 */
		private function onFaceMouseOver(e:MouseEvent):void {
			var s:Sprite = e.currentTarget as Sprite;
			s.graphics.beginFill(0xcccccc, .5);
			s.graphics.drawRect(0, 0, _side - 2, _side - 2);
			s.graphics.endFill();
		}

		/**
		 * 删除表情框
		 */
		private function removeList():void {
			if (_stage.contains(_scrollPane))
				_stage.removeChild(_scrollPane);
			_stage.removeEventListener(MouseEvent.CLICK, onStageClick);
			removeEventListeners();
		}

		/**
		 * 显示
		 */
		private function show():void {
			_open = !_open;
			if (_open){
				var point:Point = new Point();
				if (_openPosition == BOTTOM){
					point.y = _position.height + 1;
				} else {
					point.y = -_scrollPane.height - 1;
				}
				point = _position.localToGlobal(point);
				_scrollPane.move(point.x, point.y);
				_stage.addChild(_scrollPane);
				_stage.addEventListener(MouseEvent.CLICK, onStageClick);
				addEventListeners(); 
			} else {
				removeList();
			}
		}

		/**
		 * 舞台点击
		 * @param	e
		 */
		private function onStageClick(e:MouseEvent):void {
			if (e.target == _position)
				return;
			if (new Rectangle(_scrollPane.x, _scrollPane.y, _scrollPane.width, _scrollPane.height).contains(e.stageX, e.stageY))
				return;
			_open = false;
			removeList();
		}

		//////////////////////////// setter & getter ////////////////////////////

		public function get isOpen():Boolean {
			return _open;
		}

		public function get openPosition():String {
			return _openPosition;
		}

		public function set openPosition(value:String):void {
			_openPosition = value;
		}

	}

}