package org.ichow.components 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class Style 
	{
		public static var TEXT_BACKGROUND:uint = 0xFFFFFF;
		public static var BACKGROUND:uint = 0xCCCCCC;
		public static var BUTTON_FACE:uint = 0xFFFFFF;
		public static var BUTTON_DOWN:uint = 0xEEEEEE;
		public static var INPUT_TEXT:uint = 0x333333;
		public static var LABEL_TEXT:uint = 0x666666;
		public static var DROPSHADOW:uint = 0x000000;
		public static var PANEL:uint = 0xF3F3F3;
		public static var PROGRESS_BAR:uint = 0xFFFFFF;
		public static var LIST_DEFAULT:uint = 0xFFFFFF;
		public static var LIST_ALTERNATE:uint = 0xF3F3F3;
		public static var LIST_SELECTED:uint = 0xCCCCCC;
		public static var LIST_ROLLOVER:uint = 0XDDDDDD;
		
		public static var embedFonts:Boolean = false;
		public static var fontName:String = "宋体";
		public static var fontSize:Number = 12;
		
		public static var FACE_XML:XML;
		
		public static const FONT_NAME_LIST:Array = ["宋体", "幼圆", "微软雅黑", "新宋体", "黑体", "Arial", "Verdana"];
		public static const FONT_SIZE_LIST:Array = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22];
		
		
		
		public static const MAIN_BACKGROUND_SKIN:String = "Main_backGroundSkin";
		public static const PANEL_BORDER_SKIN:String = "Panel_borderSkin";
		public static var PUSH_BUTTON_SKIN:Dictionary;
		public static var INPUT_TEXT_SKIN:Dictionary;
		public static var FACE_BUTTON_SKIN:Dictionary;
		public static var FONT_BUTTON_SKIN:Dictionary;
		
		public static var STYLE_FONT_WEIGHT_BUTTON_SKIN:Dictionary;
		public static var STYLE_FONT_STYLE_BUTTON_SKIN:Dictionary;
		public static var STYLE_FONT_DECORATION_BUTTON_SKIN:Dictionary;
		public static var STYLE_FONT_COLOR_BUTTON_SKIN:Dictionary;
		
		private static var SCROLL_VERTICAL_SLIDER_SKIN:Dictionary;
		private static var SCROLL_VERTICAL_THUMB:Dictionary;
		private static var SCROLL_VERTICAL_BACKGROUND:Dictionary;
		private static var SCROLL_VERTICAL_UP_BUTTON:Dictionary;
		private static var SCROLL_VERTICAL_DOWN_BUTTON:Dictionary;
		public static var VERTICAL_SCROLL_BAR_SKIN:Dictionary;
		
		public static var COMBOBOX_LABEL_SKIN:Dictionary;
		public static var skins:Dictionary;
		public static function enabled():void {
			/////////////////////////////
			//Base Button Skin
			/////////////////////////////
			PUSH_BUTTON_SKIN = new Dictionary();
			PUSH_BUTTON_SKIN["up"] = "Button_upSkin";
			PUSH_BUTTON_SKIN["over"] = "Button_overSkin";
			PUSH_BUTTON_SKIN["down"] = "Button_downSkin";
			PUSH_BUTTON_SKIN["disabled"] = "Button_disabledSkin";
			//
			FACE_BUTTON_SKIN = new Dictionary();
			FACE_BUTTON_SKIN["up"] = "FaceButton_upSkin";
			FACE_BUTTON_SKIN["over"] = "FaceButton_overSkin";
			FACE_BUTTON_SKIN["down"] = "FaceButton_downSkin";
			FACE_BUTTON_SKIN["disabled"] = "FaceButton_disabledSkin";
			///////////////////////////////////////////////////////////
			//样式工具按钮
			//////////////////////////////////////////////////////////
			FONT_BUTTON_SKIN = new Dictionary();
			FONT_BUTTON_SKIN["up"] = "ChatRoom_FontButton_upSkin";
			FONT_BUTTON_SKIN["over"] = "ChatRoom_FontButton_selectedSkin";
			FONT_BUTTON_SKIN["down"] = "ChatRoom_FontButton_selectedSkin";
			FONT_BUTTON_SKIN["disabled"] = "ChatRoom_FontButton_upSkin";
			//加粗
			STYLE_FONT_WEIGHT_BUTTON_SKIN = new Dictionary();
			STYLE_FONT_WEIGHT_BUTTON_SKIN["up"] = "ChatRoom_FontWeightButton_upSkin";
			STYLE_FONT_WEIGHT_BUTTON_SKIN["over"] = "ChatRoom_FontWeightButton_downSkin";
			STYLE_FONT_WEIGHT_BUTTON_SKIN["down"] = "ChatRoom_FontWeightButton_downSkin";
			STYLE_FONT_WEIGHT_BUTTON_SKIN["disabled"] = "ChatRoom_FontWeightButton_upSkin";
			//倾斜
			STYLE_FONT_STYLE_BUTTON_SKIN = new Dictionary();
			STYLE_FONT_STYLE_BUTTON_SKIN["up"] = "ChatRoom_FontStyleButton_upSkin";
			STYLE_FONT_STYLE_BUTTON_SKIN["over"] = "ChatRoom_FontStyleButton_downSkin";
			STYLE_FONT_STYLE_BUTTON_SKIN["down"] = "ChatRoom_FontStyleButton_downSkin";
			STYLE_FONT_STYLE_BUTTON_SKIN["disabled"] = "ChatRoom_FontStyleButton_upSkin";
			//下划线
			STYLE_FONT_DECORATION_BUTTON_SKIN = new Dictionary();
			STYLE_FONT_DECORATION_BUTTON_SKIN["up"] = "ChatRoom_TextDecorationButton_upSkin";
			STYLE_FONT_DECORATION_BUTTON_SKIN["over"] = "ChatRoom_TextDecorationButton_downSkin";
			STYLE_FONT_DECORATION_BUTTON_SKIN["down"] = "ChatRoom_TextDecorationButton_downSkin";
			STYLE_FONT_DECORATION_BUTTON_SKIN["disabled"] = "ChatRoom_TextDecorationButton_upSkin";
			//颜色
			STYLE_FONT_COLOR_BUTTON_SKIN = new Dictionary();
			STYLE_FONT_COLOR_BUTTON_SKIN["up"] = "ChatRoom_FontColorButton_upSkin";
			STYLE_FONT_COLOR_BUTTON_SKIN["over"] = "ChatRoom_FontColorButton_downSkin";
			STYLE_FONT_COLOR_BUTTON_SKIN["down"] = "ChatRoom_FontColorButton_downSkin";
			STYLE_FONT_COLOR_BUTTON_SKIN["disabled"] = "ChatRoom_FontColorButton_upSkin";
			
			/////////////////////////////
			//Input Text Skin
			/////////////////////////////
			INPUT_TEXT_SKIN = new Dictionary();
			INPUT_TEXT_SKIN["up"] = "TextInput_upSkin";
			INPUT_TEXT_SKIN["disabled"] = "TextInput_disabledSkin";
			/////////////////////////////
			//Vertical Scroll Bar Skin
			/////////////////////////////
			SCROLL_VERTICAL_THUMB = new Dictionary();
			SCROLL_VERTICAL_THUMB["up"] = "ScrollThumb_upSkin";
			SCROLL_VERTICAL_THUMB["over"] = "ScrollThumb_overSkin";
			SCROLL_VERTICAL_THUMB["down"] = "ScrollThumb_downSkin";
			//
			SCROLL_VERTICAL_SLIDER_SKIN = new Dictionary();
			SCROLL_VERTICAL_SLIDER_SKIN["vertical_Thumb"] = SCROLL_VERTICAL_THUMB;
			SCROLL_VERTICAL_SLIDER_SKIN["vertical_BackGround"] = "ScrollTrack_skin";
			//
			SCROLL_VERTICAL_UP_BUTTON = new Dictionary();
			SCROLL_VERTICAL_UP_BUTTON["up"] = "ScrollArrowUp_upSkin";
			SCROLL_VERTICAL_UP_BUTTON["over"] = "ScrollArrowUp_overSkin";
			SCROLL_VERTICAL_UP_BUTTON["down"] = "ScrollArrowUp_downSkin";
			SCROLL_VERTICAL_UP_BUTTON["disabled"] = "ScrollArrowUp_disabledSkin";
			//
			SCROLL_VERTICAL_DOWN_BUTTON = new Dictionary();
			SCROLL_VERTICAL_DOWN_BUTTON["up"] = "ScrollArrowDown_upSkin";
			SCROLL_VERTICAL_DOWN_BUTTON["over"] = "ScrollArrowDown_overSkin";
			SCROLL_VERTICAL_DOWN_BUTTON["down"] = "ScrollArrowDown_downSkin";
			SCROLL_VERTICAL_DOWN_BUTTON["disabled"] = "ScrollArrowDown_disabledSkin";
			//
			VERTICAL_SCROLL_BAR_SKIN = new Dictionary();
			VERTICAL_SCROLL_BAR_SKIN["vertical_up"] = SCROLL_VERTICAL_UP_BUTTON;
			VERTICAL_SCROLL_BAR_SKIN["vertical_down"] = SCROLL_VERTICAL_DOWN_BUTTON;
			VERTICAL_SCROLL_BAR_SKIN["vertical_slider"] = SCROLL_VERTICAL_SLIDER_SKIN;
			
			//
			COMBOBOX_LABEL_SKIN = new Dictionary();
			COMBOBOX_LABEL_SKIN["up"] = "ComboBox_upSkin";
			COMBOBOX_LABEL_SKIN["over"] = "ComboBox_overSkin";
			COMBOBOX_LABEL_SKIN["down"] = "ComboBox_downSkin";
			COMBOBOX_LABEL_SKIN["disabled"] = "ComboBox_disabledSkin";
			
		}
		
		public static var skinList:Dictionary = new Dictionary();
		
		public static function getSkin(w:uint = 0, h:uint = 0, skin:String = ""):BitmapData {
			
			var size:String= String(w) + "*" + String(h);
			if (!skinList[skin + size] || skinList[skin + size] == null) {
				var _class:Class = getDefinitionByName(skin) as Class;
				var mc:DisplayObject = new _class() as DisplayObject;
				mc.width = w;
				mc.height = h;
				var tmp:Sprite = new Sprite();
				tmp.addChild(mc);
				var bmd:BitmapData = new BitmapData(mc.width,mc.height,true,0x000000);
				bmd.draw(tmp);
				skinList[skin+size] = bmd;
			}
			return skinList[skin+size];
		}
		
		public static function getAssets(value:String):DisplayObject {
			var _class:Class = getDefinitionByName(value) as Class;
			if (_class) return new _class();
			return null;
		}
	}

}