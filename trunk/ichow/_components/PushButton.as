package org.ichow.components
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Dictionary;

	public class PushButton extends Component
	{
		protected var _back:Sprite;
		protected var _face:Sprite;
		protected var _label:Label;
		protected var _labelText:String = "";
		protected var _over:Boolean = false;
		protected var _down:Boolean = false;
		protected var _selected:Boolean = false;
		protected var _toggle:Boolean = false;
		
		
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this PushButton.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param label The string to use for the initial label of this component.
 		 * @param defaultHandler The event handling function to handle the default event for this component (click in this case).
		 */
		public function PushButton( parent:DisplayObjectContainer = null, 
									xpos:Number = 0, 
									ypos:Number =  0, 
									label:String = "label", 
									defaultHandler:Function = null,
									skins:Dictionary=null
									)
		{
			_skins = skins == null?Style.PUSH_BUTTON_SKIN:skins;
			super(parent, xpos, ypos);
			if(defaultHandler != null)
			{
				addEventListener(MouseEvent.CLICK, defaultHandler);
			}
			this.label = label;
		}
		
		/**
		 * Initializes the component.
		 */
		override protected function init():void
		{
			super.init();
			buttonMode = true;
			useHandCursor = true;
			setSize(100, 20);
		}
		
		/**
		 * Creates and adds the child display objects of this component.
		 */
		override protected function addChildren():void
		{
			
			_face = new Sprite();
			_face.mouseEnabled = false;
			
			addChild(_face);
			
			_label = new Label();
			addChild(_label);
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseGoDown);
			addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
		}
		
		/**
		 * Draws the face of the button, color based on state.
		 */
		protected function drawFace():void
		{
			_face.graphics.clear();
			
			if (!_enabled) {
				_face.graphics.beginBitmapFill(Style.getSkin(_width, _height, _skins["disabled"])||Style.getSkin(_width, _height, _skins["up"]));
			}
			else if(_down)
			{
				_face.graphics.beginBitmapFill(Style.getSkin(_width, _height, _skins["down"])||Style.getSkin(_width, _height, _skins["up"]));
			}
			else if (_over)
			{
				_face.graphics.beginBitmapFill(Style.getSkin(_width, _height, _skins["over"])||Style.getSkin(_width, _height, _skins["up"]));
			}
			else
			{
				_face.graphics.beginBitmapFill(Style.getSkin(_width, _height, _skins["up"]));
			}
			
			_face.graphics.drawRect(0, 0, _width, _height);
			_face.graphics.endFill();
		}
		
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		/**
		 * Draws the visual ui of the component.
		 */
		override public function draw():void
		{
			super.draw();
			
			drawFace();
			
			_label.text = _labelText;
			_label.autoSize = true;
			_label.draw();
			if(_label.width > _width - 4)
			{
				_label.autoSize = false;
				_label.width = _width - 4;
			}
			else
			{
				_label.autoSize = true;
			}
			_label.draw();
			if (_labelAutoSize == "left") {
				_label.move(2, _height / 2 - _label.height / 2);
			}else if (_labelAutoSize == "right") {
				_label.move(_width - _label.width - 2, _height / 2 - _label.height / 2);
			}else {
				_label.move(_width / 2 - _label.width / 2, _height / 2 - _label.height / 2);
			}
			//TextFieldAutoSize
		}
		private var _labelAutoSize:String;
		public function set labelAutoSize(value:String):void {
			_labelAutoSize = value;
		}
		
		
		
		///////////////////////////////////
		// event handlers
		///////////////////////////////////
		
		/**
		 * Internal mouseOver handler.
		 * @param event The MouseEvent passed by the system.
		 */
		protected function onMouseOver(event:MouseEvent):void
		{
			_over = true;
			drawFace();
			addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		}
		
		/**
		 * Internal mouseOut handler.
		 * @param event The MouseEvent passed by the system.
		 */
		protected function onMouseOut(event:MouseEvent):void
		{
			_over = false;
			if(!_down)
			{
				//_face.filters = [getShadow(1)];
			}
			drawFace();
			removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		}
		
		/**
		 * Internal mouseOut handler.
		 * @param event The MouseEvent passed by the system.
		 */
		protected function onMouseGoDown(event:MouseEvent):void
		{
			_down = true;
			drawFace();
			_face.filters = [getShadow(1, true)];
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
		}
		
		/**
		 * Internal mouseUp handler.
		 * @param event The MouseEvent passed by the system.
		 */
		protected function onMouseGoUp(event:MouseEvent):void
		{
			if(_toggle  && _over)
			{
				_selected = !_selected;
			}
			_down = _selected;
			drawFace();
			_face.filters = [getShadow(1, _selected)];
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
		}
		
		
		
		
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////
		
		/**
		 * Sets / gets the label text shown on this Pushbutton.
		 */
		public function set label(str:String):void
		{
			_labelText = str;
			draw();
		}
		public function get label():String
		{
			return _labelText;
		}
		
		public function set selected(value:Boolean):void
		{
			if(!_toggle)
			{
				value = false;
			}
			
			_selected = value;
			_down = _selected;
			_face.filters = [getShadow(1, _selected)];
		}
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function set toggle(value:Boolean):void
		{
			_toggle = value;
		}
		public function get toggle():Boolean
		{
			return _toggle;
		}
		
		public function get bLabel():Label {
			return _label;
		}
		
		
	}
}