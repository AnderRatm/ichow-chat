package org.ichow.eelive.components 
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flashx.textLayout.formats.TextDecoration;
	import org.ichow.eelive.forms.BaseForm;
	import org.ichow.eelive.managers.FormManager;
	
	/**
	 * ...
	 * @author ichow
	 */
	public class TextFormatBar extends BaseForm
	{
		public static var FONT_ARRAY:Array;
		public static var SIZE_ARRAY:Array;
		
		private var _fontNameComboBox:ComboBox;
		private var _fontSizeComboBox:ComboBox;
		private var _boldPushButton:PushButton;
		private var _unLinePushButton:PushButton;
		private var _italicPushButton:PushButton;
		private var _chat:ITextLayoutFormat;
		private var _panel:Panel;
		private var _open:Boolean = false;
		
		/**
		 * 构造函数
		 * @param	chat		:	聊天框【ITextLayoutFormat接口】
		 * @param	parent		:	父級
		 * @param	xpos		:	x坐标
		 * @param	ypos		:	y坐标
		 * @param	type		:	类型
		 */
		public function TextFormatBar(chat:ITextLayoutFormat,parent:DisplayObjectContainer=null,xpos:Number=0,ypos:Number=0,type:String="textformat") 
		{
			super(parent, xpos, ypos, type);
			_chat = chat;
		}
		override protected function init():void 
		{
			super.init();
			setSize(_panel.width, _panel.height);
		}
		/**
		 * 创建
		 */
		override protected function addChildren():void 
		{
			super.addChildren();
			composition.parseXML(new XML(FormManager.xml.TextFormatBar));
			/*
			 */
			_fontNameComboBox = composition.getCompById("FontNameComboBox") as ComboBox;
			_fontSizeComboBox = composition.getCompById("FontSizeComboBox") as ComboBox;
			_boldPushButton = composition.getCompById("BoldPushButton") as PushButton;
			_unLinePushButton = composition.getCompById("UnLinePushButton") as PushButton;
			_italicPushButton = composition.getCompById("ItalicPushButton") as PushButton;
			_panel = composition.getCompById("TextFormatBar") as Panel;
			//
			_fontNameComboBox.items = FONT_ARRAY;
			_fontSizeComboBox.items = SIZE_ARRAY;
			//
		}
		/**
		 * 绘图
		 */
		override public function draw():void 
		{
			super.draw();
			
			_fontNameComboBox.draw();
			_fontSizeComboBox.draw();
		}
		/**
		 * 添加侦听
		 */
		override protected function addEventListeners():void 
		{
			super.addEventListeners();
			_fontNameComboBox.addEventListener(Event.SELECT, onFontSelect);
			_fontSizeComboBox.addEventListener(Event.SELECT, onSizeSelect);
			_boldPushButton.addEventListener(MouseEvent.MOUSE_DOWN, onBordMouseDown);
			_italicPushButton.addEventListener(MouseEvent.MOUSE_DOWN, onItalicMouseDown);
			_unLinePushButton.addEventListener(MouseEvent.MOUSE_DOWN, onUnLineMouseDown);
			
		}
		/**
		 * 删除侦听
		 */
		override protected function removeEventListeners():void 
		{
			super.removeEventListeners();
			_fontNameComboBox.removeEventListener(Event.SELECT, onFontSelect);
			_fontSizeComboBox.removeEventListener(Event.SELECT, onSizeSelect);
			_boldPushButton.removeEventListener(MouseEvent.MOUSE_DOWN, onBordMouseDown);
			_italicPushButton.removeEventListener(MouseEvent.MOUSE_DOWN, onItalicMouseDown);
			_unLinePushButton.removeEventListener(MouseEvent.MOUSE_DOWN, onUnLineMouseDown);
		}
		
		/* INTERFACE IShow */
		
		/**
		 * 显示
		 */
		override public function show():void 
		{
			//super.show();
			addEventListeners();
			open = true;
		}
		/**
		 * 隐藏
		 */
		override public function hide():void 
		{
			//super.hide();
			removeEventListeners();
			open = false;
		}
		
		/* Mouse Event Hander */
		
		/**
		 * 颜色
		 * @param	e
		 */
		private function onColorClose(e:Event):void 
		{
			//if (_chat != null) 
				//_chat.fontColor = color.selectedColor;
		}
		/**
		 * 斜体侦听
		 * @param	e
		 */
		private function onItalicMouseDown(e:MouseEvent):void 
		{
			if (_chat != null) 
				_chat.fontStyle = _italicPushButton.selected == false?FontPosture.ITALIC:FontPosture.NORMAL;
		}
		/**
		 * 下划线侦听
		 * @param	e
		 */
		private function onUnLineMouseDown(e:MouseEvent):void 
		{
			if (_chat != null) 
				_chat.textDecoration = _unLinePushButton.selected==false?TextDecoration.UNDERLINE:TextDecoration.NONE;
		}
		/**
		 * 加粗侦听
		 * @param	e
		 */
		private function onBordMouseDown(e:MouseEvent):void 
		{
			if (_chat != null) 
				_chat.fontWeight = _boldPushButton.selected == false?FontWeight.BOLD:FontWeight.NORMAL;
		}
		/**
		 * 字体大小侦听
		 * @param	e
		 */
		private function onSizeSelect(e:Event):void 
		{
			if (_chat != null) 
				_chat.fontSize = int(_fontSizeComboBox.selectedItem);
		}
		/**
		 * 字体类型侦听
		 * @param	e
		 */
		private function onFontSelect(e:Event):void 
		{
			if (_chat != null) 
				_chat.fontFamily = _fontNameComboBox.selectedItem.toString();
		}
		
		public function get open():Boolean 
		{
			return _open;
		}
		
		public function set open(value:Boolean):void 
		{
			_open = value;
		}
		

	}

}