package org.ichow.eelive._view 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.engine.BreakOpportunity;
	import flash.text.engine.ElementFormat;
	import flash.text.FontStyle;
	import flash.text.FontType;
	import flash.text.TextFieldType;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.ISelectionManager;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.DivElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.events.CompositionCompleteEvent;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.formats.TextDecoration;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flash.text.engine.FontWeight
	
	import org.ichow.components.VScrollPane;
	import org.ichow.event.EventProxy;
	import org.ichow.components.Style;
	import org.ichow.components.VScrollBar;
	import org.ichow.util.ChatUtil;
	//import fl.controls.ColorPicker;
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class FlowPanel extends BaseView implements IStyle,IBorder
	{
		public static const INPUT:String = "input";
		public static const DYNAMIC:String = "dynamic";
		
		private var _flow:TextFlow;
		private var _controller:ContainerController;
		private var _scroll:VScrollPane;
		private var _manager:ISelectionManager;
		
		
		public function FlowPanel(	parent:DisplayObjectContainer = null, 
									xpos:Number = 0, 
									ypos:Number =  0,
									width:uint = 0,
									height:uint = 0,
									type:String = ""
									)
		{
			super(parent, xpos, ypos, width, height, type);
		}
		/**
		 * 
		 */
		private var padding:uint = 10;
		override protected function addChildren():void {
			super.addChildren();
			
			_flow = new TextFlow();
			_flow.fontFamily = Style.fontName;
			_flow.fontSize = Style.fontSize;
			_flow.lineHeight = "120%";
			
			if (_type == INPUT) {
				_manager = new EditManager();
				initKeyboard();
			}else if (_type == DYNAMIC) {
				
				_manager = new SelectionManager();
			}
			autoSize = true;
			_controller = new ContainerController(_canvas, _width - padding, _height - padding-1);
			
			_controller.verticalScrollPolicy = ScrollPolicy.ON
			_controller.horizontalScrollPolicy = ScrollPolicy.AUTO;
			
			_flow.flowComposer.addController(_controller);
			
			_flow.breakOpportunity = BreakOpportunity.NONE;
			_flow.interactionManager = _manager;
			
			updateFlow();
			
			_flow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, graphicStatusChangeEvent);
			_flow.addEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, composeListener);
			
			initScroll();
			
		}
		
		private function composeListener(e:CompositionCompleteEvent):void 
		{
			_controller.setCompositionSize((_controller.getContentBounds().height > (_height - padding))?(_width-padding-15):(_width-padding), (_controller.getContentBounds().height > (_height - padding))?autoSize ? NaN : (_height - padding) : (_height - padding -1));
			updateFlow();
			updateScroll();
		}
		
		public function updateScroll():void 
		{
			_scroll.update();
		}
		
		private var _autoSize:Boolean;
		public function get autoSize():Boolean {
			return _autoSize;
		}
		public function set autoSize(value:Boolean):void {
			_autoSize = value;
		}
		
		private function graphicStatusChangeEvent(e:StatusChangeEvent):void 
		{
			updateFlow();
			updateScroll();
		}
		
		private function initScroll():void 
		{
			_scroll = new VScrollPane(this, 0, 0);
			_scroll.autoHideScrollBar = true;
			_scroll.addChild(_canvas);
			_scroll.setSize(_width, _height);
			_scroll.autoScroll = true;
			_scroll.update();
		}
		
		/**
		 * initialize keyboard event
		 */
		private function initKeyboard():void 
		{
			//this.addEventListener(KeyboardEvent.KEY_DOWN, onKeyBoardDown, true);
		}
		/**
		 * keyboard listener
		 * if push the ctrl & enter then send message
		 * @param	e
		 */
		private function onKeyBoardDown(e:KeyboardEvent):void 
		{
			if (e.keyCode == 13) {
				EventProxy.broadcastEvent(new Event(RoomView.SEND_MESSAGE));
			}
		}
		/**
		 * 
		 */
		override public function draw():void {
			super.draw();
			
			_canvas.x = _canvas.y = padding / 2;
			if (type == INPUT) clear();
		}
		/**
		 * add elments to flowtext
		 * @param	message		: String
		 */
		public function addMessage(message:String):void {
			var div:DivElement = getElement(ChatUtil.unescapeImg(message));
			_flow.addChild(div);
			updateFlow();
		}
		/**
		 * change html string to elements and return
		 * @param	message		: String
		 * @return	DivElement
		 */
		private function getElement(message:String):DivElement {
			var tf:TextFlow = TextConverter.importToFlow(message, TextConverter.TEXT_FIELD_HTML_FORMAT);
			var div:DivElement = new DivElement();
			var len:uint = tf.numChildren;
			for (var i:uint = 0; i < len; i++) {
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
			return ChatUtil.escapeImg(html);
		}
		//表情大小
		private var faceSize:uint = 24;
		/**
		 * add a face image 
		 * @param	url		: url
		 */
		public function addFace(url:String):void {
			(_manager as EditManager).insertInlineGraphic(url, "auto", "auto");
			updateFlow()
			_manager.setFocus();
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
			updateFlow()
		}
		/**
		 * update flow text
		 */
		public function updateFlow():void {
			_flow.flowComposer.updateAllControllers();
			//if (type == INPUT) setFocus();
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
		public function get fontFamily():* { return _flow.fontFamily; }
		
		/**
		 * 大小
		 * @param	value	: 大小int
		 */
		public function set fontSize(value:*):void {
			_flow.fontSize = value;
			updateFlow();
			updateScroll();
		}
		public function get fontSize():* { return _flow.fontSize; }
		
		/**
		 * 加粗
		 * @param	type	: FontWeight.BOLD||FontWeight.NORMAL
		 */
		public function set fontWeight(type:*):void {
			_flow.fontWeight = type;
			updateFlow();
		}
		public function get fontWeight():* { return _flow.fontWeight; }
		
		/**
		 * 颜色
		 * @param	color	: 
		 */
		public function set fontColor(color:*):void {
			_flow.color = color;
			updateFlow();
		}
		public function get fontColor():* { return _flow.color; }
		
		/**
		 * 样式
		 * @param	style	: FontStyle.BOLD||FontStyle.ITALIC||FontStyle.REGULAR
		 */
		public function set fontStyle(style:*):void {
			_flow.fontStyle = style;
			updateFlow();
		}
		public function get fontStyle():* { return _flow.fontStyle; }
		
		public function set textDecoration(value:*):void {
			_flow.textDecoration = value;
			updateFlow();
		}
		public function get textDecoration():*{
			return _flow.textDecoration;
		}
		
		//////////////////////////////////////////////////////
		//IBorder	:	set flowtext width & height
		//////////////////////////////////////////////////////
		public function updateBorder(w:int, h:int):void {
			
			_controller.setCompositionSize((_controller.getContentBounds().height > (_height - padding+w))?(_width-padding+w-15):(_width-padding), (_controller.getContentBounds().height > (_height - padding))?autoSize ? NaN : (_height - padding+h) : (_height - padding+h -1));
			
			_scroll.setSize(_scroll.width + w, _scroll.height + h);
			
			updateFlow();
			updateScroll();
		}
	}

}