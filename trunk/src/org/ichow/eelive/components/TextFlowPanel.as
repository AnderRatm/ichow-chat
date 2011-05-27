package org.ichow.eelive.components {
	import com.bit101.components.Style;
	import com.bit101.components.ScrollPane;
	import com.hexagonstar.util.debug.Debug;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.engine.BreakOpportunity;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.ISelectionManager;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.DivElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.CompositionCompleteEvent;
	import flashx.textLayout.events.StatusChangeEvent;

	/**
	 * ...
	 * @author ichow
	 */
	public class TextFlowPanel extends Sprite implements ITextLayoutFormat {
		public static const INPUT:String = "input";
		public static const DYNAMIC:String = "dynamic";

		private var _flow:TextFlow;
		private var _controller:ContainerController;
		private var _scroll:ScrollPane;
		private var _manager:ISelectionManager;


		private var _width:Number;
		private var _height:Number;
		private var _type:String;

		private var __padding:uint;
		private var _canvas:Sprite;
		private var _autoSize:Boolean;
		private var _scrollWidth:int = 10;

		public function TextFlowPanel(parent:DisplayObjectContainer = null, width:Number = 0, height:Number = 0, pandding:Number = 5, type:String = ""){
			this._width = width;
			this._height = height;
			this.__padding = pandding;
			this._type = type;
			if (parent != null){
				parent.addChild(this);
			}
			init();
		}

		protected function init():void {
			addChildren();
			draw();
		}

		private function addChildren():void {
			_canvas = new Sprite();
			_controller = new ContainerController(_canvas, _width - 2 * __padding, _height - 2 * __padding - 1);
			_controller.verticalScrollPolicy = ScrollPolicy.ON
			_controller.horizontalScrollPolicy = ScrollPolicy.AUTO;

			_flow = new TextFlow();
			_flow.fontFamily = Style.fontName;
			_flow.fontSize = Style.fontSize;
			_flow.lineHeight = "120%";
			_flow.breakOpportunity = BreakOpportunity.NONE;
			_flow.flowComposer.addController(_controller);
			if (_type == INPUT)
				_manager = new EditManager();
			else if (_type == DYNAMIC)
				_manager = new SelectionManager();
			_flow.interactionManager = _manager;
			updateFlow();
			_canvas.x = _canvas.y = __padding;

			_scroll = new ScrollPane(this, 0, 0);
			_scroll.verticalScrollPolicy = "auto";
			_scroll.horizontalScrollPolicy = "off";
			_scroll.autoHideScrollBar = true;
			_scroll.addChild(_canvas);
			_scroll.setSize(_width, _height);
			_scroll.dragContent = false;
			_scroll.autoVScroll = true;
			_scroll.update();

			addEventListeners();

			draw();
		}

		private function initKeyboard():void {
		}

		private function addEventListeners():void {
			_flow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, graphicStatusChangeEvent);
			_flow.addEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, composeListener);
		}


		private function graphicStatusChangeEvent(e:StatusChangeEvent):void {
			updateFlow();
			updateScroll();
		}

		private function composeListener(e:CompositionCompleteEvent):void {
			draw();
		}

		/**
		 * add elments to flowtext
		 * @param	message		: String
		 */
		public function addMessage(message:String):void {
			trace("addMessage: " + message);
			var div:DivElement = getElement(message);
			_flow.addChild(div);
			updateFlow();
		}

		/**
		 * change html string to elements and return
		 * @param	message		: String
		 * @return	DivElement
		 */
		private function getElement(message:String):DivElement {
			//trace("getElement: " + message);
			var tf:TextFlow = TextConverter.importToFlow(message, TextConverter.TEXT_FIELD_HTML_FORMAT);
			var div:DivElement = new DivElement();
			var len:uint = tf.numChildren;
			for (var i:uint = 0; i < len; i++){
				div.addChild(tf.getChildAt(0));
			}
			return div;
		}

		/**
		 * get flow's text after escapeImg
		 * @return	获取HTML(处理图片)
		 */
		public function getMessage():String {
			var html:String = TextConverter.export(_flow, TextConverter.TEXT_FIELD_HTML_FORMAT, ConversionType.STRING_TYPE) as String;
			return html;
		}

		/**
		 * add a face image
		 * @param	url		: url
		 */
		public function addFace(url:String):void {
			(_manager as EditManager).insertInlineGraphic(url, "auto", "auto");
			updateFlow()
			setFocus();
		}

		/**
		 * set focus to flow text
		 */
		public function setFocus():void {
			_manager.setFocus();
		}

		/**
		 * clear all text
		 */
		public function clear():void {
			_manager.setFocus();
			_manager.selectAll();
			(_manager as EditManager).insertText("");
			updateFlow();
		}

		/**
		 * update flow text
		 */
		public function updateFlow():void {
			_flow.flowComposer.updateAllControllers();
			//Debug.trace("_controller: " + _controller.compositionWidth + " - " + _controller.compositionHeight, 4);
			//if (_scroll)
			//Debug.trace("_scroll: " + _scroll.width + " - " + _scroll.height, 4);
		}

		public function draw():void {

			var rect:Rectangle = _controller.getContentBounds();
			_controller.setCompositionSize((rect.height > (_height - 2 * __padding)) ? (_width - 2 * __padding - _scrollWidth) : (_width - 2 * __padding), (rect.height > (_height - 2 * __padding)) ? _autoSize ? NaN : (_height - 2 * __padding) : (_height - 2 * __padding - 1));
			updateFlow();
			updateScroll();
		}


		public function updateScroll():void {
			_scroll.update();
		}

		public function get autoSize():Boolean {
			return _autoSize;
		}

		public function set autoSize(value:Boolean):void {
			_autoSize = value;
		}


		///////////////////////////////////////////////////
		//IStyle	:	set font style method
		///////////////////////////////////////////////////
		
		/**
		 * 字体
		 * @param	font	: 字体名称
		 */
		public function set fontFamily(font:*):void {
			_flow.fontFamily = font;
			updateFlow();
			updateScroll();
		}

		public function get fontFamily():* {
			return _flow.fontFamily;
		}

		/**
		 * 大小
		 * @param	value	: 大小int
		 */
		public function set fontSize(value:*):void {
			_flow.fontSize = value;
			updateFlow();
			updateScroll();
		}

		public function get fontSize():* {
			return _flow.fontSize;
		}

		/**
		 * 加粗
		 * @param	type	: FontWeight.BOLD||FontWeight.NORMAL
		 */
		public function set fontWeight(type:*):void {
			_flow.fontWeight = type;
			updateFlow();
		}

		public function get fontWeight():* {
			return _flow.fontWeight;
		}

		/**
		 * 颜色
		 * @param	color	:
		 */
		public function set fontColor(color:*):void {
			_flow.color = color;
			updateFlow();
		}

		public function get fontColor():* {
			return _flow.color;
		}

		/**
		 * 斜体
		 * @param	style	:
		 */
		public function set fontStyle(style:*):void {
			_flow.fontStyle = style;
			updateFlow();
		}

		public function get fontStyle():* {
			return _flow.fontStyle;
		}

		/**
		 * 下劃線
		 * @param	value	:
		 */
		public function set textDecoration(value:*):void {
			_flow.textDecoration = value;
			updateFlow();
		}

		public function get textDecoration():* {
			return _flow.textDecoration;
		}

	}

}