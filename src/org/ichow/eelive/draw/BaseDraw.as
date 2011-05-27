package org.ichow.eelive.draw {
	import com.bit101.components.PushButton;
	import com.bit101.utils.MinimalConfigurator;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * ...
	 * @author ichow
	 */
	public class BaseDraw extends Sprite implements IDraw {
		
		protected var _propertyIconHeight:int = 24;
		protected var _propertyColor:uint;
		protected var _propertyHeight:int = 30;
		protected var _board:Sprite;
		protected var _active:Boolean;
		protected var _type:String;
		protected var _shapes:Array;
		protected var _draw:Shape;
		protected var _property:Sprite;
		protected var _minimal:MinimalConfigurator;
		/**
		 * 
		 * @param	type
		 */
		public function BaseDraw(type:String = "draw"){
			_type = type;
			init();
		}

		/**
		 * 
		 */
		protected function init():void {
			_shapes = [];
			addChildren();
		}

		/**
		 * 
		 */
		protected function addChildren():void {
			//darw back ground
			_property = new Sprite();
			_minimal = new MinimalConfigurator(_property);
		}

		/**
		 * 
		 * @param	e
		 */
		protected function onMouseClick(e:MouseEvent):void {
			/*if (_button.selected)
				active();
			else
				cancel();*/
		}

		/**
		 * 
		 */
		protected function addListeners():void {
			_board.addEventListener(MouseEvent.MOUSE_DOWN, onBoardMouseDown);
			_board.addEventListener(MouseEvent.MOUSE_UP, onBoardMouseUp);
		}

		/**
		 * 
		 * @param	e
		 */
		protected function onBoardMouseDown(e:MouseEvent):void {
			_board.addEventListener(MouseEvent.MOUSE_MOVE, onBoardMouseMove);
		}

		/**
		 * 
		 * @param	e
		 */
		protected function onBoardMouseUp(e:MouseEvent):void {
			_board.removeEventListener(MouseEvent.MOUSE_MOVE, onBoardMouseMove);
		}

		/**
		 * 
		 * @param	e
		 */
		protected function onBoardMouseMove(e:MouseEvent):void {
		}

		/**
		 * 
		 */
		protected function removeListeners():void {
			_board.removeEventListener(MouseEvent.MOUSE_DOWN, onBoardMouseDown);
			_board.removeEventListener(MouseEvent.MOUSE_UP, onBoardMouseUp);
			_board.removeEventListener(MouseEvent.MOUSE_MOVE, onBoardMouseMove);
		}
		
		///////////////////////////////// Interface IDraw /////////////////////////////////

		/**
		 * 
		 * @param	board
		 */
		public function bind(board:Sprite):void {
			_board = board;
			_property.x = _board.x;
			_property.y = _board.y - propertyHeight;
		}

		/**
		 * 
		 */
		public function clear():void {
			for each (var i:Object in _shapes){
				i.graphics.clear();
				i = null;
			}
			_shapes = [];
		}

		/**
		 * 
		 */
		public function active():void {
			addListeners();
			_active = true;
		}

		/**
		 * 
		 */
		public function cancel():void {
			removeListeners();
			_active = false;
		}

		///////////////////////////////// getter && setter /////////////////////////////////
		
		public function get type():String {
			return _type;
		}

		public function get isActive():Boolean {
			return _active;
		}
		
		public function set propertyHeight(value:int):void {
			_propertyHeight = value;
		}

		public function get propertyHeight():int {
			return _propertyHeight;
		}

	}

}