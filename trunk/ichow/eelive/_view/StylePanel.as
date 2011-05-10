package org.ichow.eelive.view 
{
	import caurina.transitions.Tweener;
	import fl.controls.ColorPicker;
	import fl.events.ColorPickerEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flash.text.FontStyle;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.formats.TextDecoration;
	import org.ichow.components.FacePane;
	
	import org.ichow.components.ComboBox;
	import org.ichow.components.Component;
	import org.ichow.components.Panel;
	import org.ichow.components.PushButton;
	import org.ichow.components.Style;
	import org.ichow.components.VScrollPane;
	import org.ichow.eelive.core.FaceByteArray;
	import org.ichow.eelive.events.FaceEvent;
	import org.ichow.event.EventProxy;
	import org.ichow.settings.eeLiveSettings;
	import org.ichow.util.ChatUtil;
	
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class StylePanel extends BaseView 
	{
		
		public function StylePanel(	parent:DisplayObjectContainer = null, 
									xpos:Number = 0, 
									ypos:Number =  0,
									width:uint = 0,
									height:uint = 0,
									type:String = ""
									)
		{
			super(parent, xpos, ypos, width, height, type);
		}
		
		override protected function init():void {
			super.init();
		}
		private var face:FacePane;
		//private var facePane:VScrollPane;
		//private var facePaneHeight:int = 120;
		//private var faceBorder:Shape;
		
		private var font:PushButton;
		private var fontPanel:Panel;
		private var comboFont:ComboBox;
		private var comboSize:ComboBox;
		
		private var bord:PushButton;
		private var tip:PushButton;
		private var line:PushButton;
		private var color:ColorPicker;
		
		
		private var styleButtonHeight:int = 20;
		private var styleButtonWidth:int = 20;
		
		private var styleToolHeight:int = 24;
		
		override protected function addChildren():void {
			super.addChildren();
			/**
			 * 新表情按钮	v1.0
			 */
			face = new FacePane(this, 5, 3, "facePane");
			face.openPosition = FacePane.TOP;
			
			//font
			font = new PushButton(this, 40, 3, "", null, Style.FONT_BUTTON_SKIN);
			font.setSize(styleToolHeight, styleToolHeight);
			font.addEventListener(MouseEvent.MOUSE_DOWN, onFontMouseDown);
			font.toggle = true;
			
			fontPanel = new Panel(this, 0, 0);
			
			fontPanel.width = _width;
			comboFont = new ComboBox(fontPanel, 5, 2, Style.fontName, Style.FONT_NAME_LIST);
			comboFont.addEventListener(Event.SELECT, onFontSelect);
			comboFont.setSize(80, styleButtonHeight);
			comboFont.defaultLabel = Style.fontName;
			
			comboSize = new ComboBox(fontPanel, 90, 2, String(Style.fontSize), Style.FONT_SIZE_LIST);
			comboSize.addEventListener(Event.SELECT, onSizeSelect);
			comboSize.setSize(50, styleButtonHeight);
			comboSize.defaultLabel = Style.fontSize.toString();
			
			fontPanel.height = 30;
			fontPanel.y = -fontPanel.height-1;
			fontPanel.visible = false;
			//
			bord = new PushButton(fontPanel, 0, 0, "", null, Style.STYLE_FONT_WEIGHT_BUTTON_SKIN);
			tip = new PushButton(fontPanel, 0, 0, "", null, Style.STYLE_FONT_STYLE_BUTTON_SKIN);
			line = new PushButton(fontPanel, 0, 0, "", null, Style.STYLE_FONT_DECORATION_BUTTON_SKIN);
			//color = new PushButton(fontPanel, 0, 0, "", null, Style.STYLE_FONT_COLOR_BUTTON_SKIN);
			color = Style.getAssets("fl.controls.ColorPicker") as ColorPicker;
			fontPanel.addChild(color);
			
			//var obj:Object = ;
			
			bord.toggle = true;
			tip.toggle = true;
			line.toggle = true;
			//color.toggle = true;
			
			bord.setSize(styleButtonHeight, styleButtonHeight);
			tip.setSize(styleButtonHeight, styleButtonHeight);
			line.setSize(styleButtonHeight, styleButtonHeight);
			color.setSize(styleButtonHeight, styleButtonHeight);
			
			bord.addEventListener(MouseEvent.MOUSE_DOWN, onBordMouseDown);
			tip.addEventListener(MouseEvent.MOUSE_DOWN, onTipMouseDown);
			line.addEventListener(MouseEvent.MOUSE_DOWN, onLineMouseDown);
			color.addEventListener(Event.CLOSE, onColorClose);
			
		}
		/**
		 * 颜色
		 * @param	e
		 */
		private function onColorClose(e:Event):void 
		{
			//trace(e.target);
			if (_changeTarget != null) {
				(_changeTarget as IStyle).fontColor = color.selectedColor;
			}
		}
		/**
		 * 斜体侦听
		 * @param	e
		 */
		private function onTipMouseDown(e:MouseEvent):void 
		{
			if (_changeTarget != null) {
				(_changeTarget as IStyle).fontStyle = tip.selected == false?FontPosture.ITALIC:FontPosture.NORMAL;
			}
		}
		/**
		 * 下划线侦听
		 * @param	e
		 */
		private function onLineMouseDown(e:MouseEvent):void 
		{
			if (_changeTarget != null) {
				(_changeTarget as IStyle).textDecoration = line.selected==false?TextDecoration.UNDERLINE:TextDecoration.NONE;
				
			}
		}
		/**
		 * 加粗侦听
		 * @param	e
		 */
		private function onBordMouseDown(e:MouseEvent):void 
		{
			
			if (_changeTarget != null) {
				(_changeTarget as IStyle).fontWeight = bord.selected==false?FontWeight.BOLD:FontWeight.NORMAL;
			}
		}
		/**
		 * 字体大小侦听
		 * @param	e
		 */
		private function onSizeSelect(e:Event):void 
		{
			if (_changeTarget != null) {
				(_changeTarget as IStyle).fontSize = int(comboSize.selectedItem);
			}
		}
		/**
		 * 字体类型侦听
		 * @param	e
		 */
		private function onFontSelect(e:Event):void 
		{
			if (_changeTarget != null) {
				(_changeTarget as IStyle).fontFamily = comboFont.selectedItem.toString();
			}
		}
		/**
		 * 修改样式目标
		 * 实现IStyle 接口
		 */
		private var _changeTarget:*;
		public function set changeTarget(value:*):void {
			_changeTarget = value;
			face.target = value as FlowPanel;
		}
		private var _borderTarget:*;
		public function set borderTarget(value:*):void {
			_borderTarget = value;
		}
		
		/**
		 * 显示字体样式框
		 * @param	e
		 */
		private function onFontMouseDown(e:MouseEvent):void 
		{
			fontPanel.visible = !fontPanel.visible;
		}
		
		/**
		 * 加载表情xml
		 */
		private function loadXML():void 
		{
			var uld:URLLoader = new URLLoader();
			uld.addEventListener(Event.COMPLETE, onFaceComplete);
			uld.load(new URLRequest(eeLiveSettings.FACE_URL));
		}
		/**
		 * 加载完成
		 * @param	e
		 */
		private function onFaceComplete(e:Event):void 
		{
			Style.FACE_XML = new XML(e.target.data);
		}
		
		override public function draw():void {
			super.draw();
			
			var xpos:int=0;
			var ypos:int=0;
			for (var i:int = 0, len:int = fontPanel.content.numChildren; i < len; i++) {
				var ui:DisplayObject = fontPanel.content.getChildAt(i) as DisplayObject;
				ui.x = 5 + xpos;
				ui.y = 2 + ypos;
				xpos = ui.x + ui.width + 5;
				if ((xpos + 30) >= _width) {
					xpos = 0;
					ypos += 30;
				}
			}
			//trace("pre fontPanel Height:" + fontPanel.height, ypos);
			fontPanel.height = fontPanel.content.height + 5;
			
			comboFont.draw();
			comboSize.draw();
			fontPanel.draw();
			fontPanel.y = -fontPanel.height - 2;
			
		}
	}

}