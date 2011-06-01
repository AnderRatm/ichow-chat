package org.ichow.eelive.managers.tools {
	import com.bit101.components.Panel;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.Font;
	import org.ichow.eelive.components.ITextLayoutFormat;
	import org.ichow.eelive.components.TextFormatBar;

	/**
	 * ...
	 * @author ichow
	 */
	public class FontStyleManager {
		private var _position:DisplayObjectContainer;
		private var _stage:Stage;
		private var _panel:Panel;
		private var _jid:String;
		private var _bars:Object;
		private var _chat:ITextLayoutFormat;
		private var _currentBar:TextFormatBar;

		public function FontStyleManager(){
			_bars = {};
			//设置字体大小
			TextFormatBar.SIZE_ARRAY = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22];
			//设置字体
			var arr:Array = Font.enumerateFonts(true);
			var resut:Array = [];
			for (var i:int = 0, len:int = arr.length; i < len; i++){
				var child:Font = arr[i] as Font;
				resut.push(child.fontName);
			}
			TextFormatBar.FONT_ARRAY = resut;
		}

		//////////////////////////// public method ////////////////////////////

		/**
		 * 绑定
		 * @param	chat		:	聊天框【IStyle接口】
		 * @param	position	:	呼出按钮
		 */
		public function bind(jid:String, chat:ITextLayoutFormat, position:DisplayObjectContainer):void {
			_chat = chat;
			_jid = jid;
			_position = position;
			_stage = _position.stage;
			//get bar
			var bar:TextFormatBar = getBar(jid);
			show(bar);
		}

		/**
		 * 显示样式工具
		 * @param	bar
		 */
		private function show(bar:TextFormatBar = null):void {
			if (!bar)
				return;
			_currentBar = bar;
			if (!_currentBar.open){
				var point:Point = new Point(-_position.x - 4, -35);
				point = _position.localToGlobal(point);
				bar.move(point.x, point.y);
				_stage.addChild(_currentBar);
				_position.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
				bar.show();
			} else {
				removeBar();
			}
		}
		
		/**
		 * 移除
		 * @param	e
		 */
		private function onRemoveFromStage(e:Event):void {
			removeBar();
		}
		
		/**
		 * 移除
		 */
		private function removeBar():void {
			if (_stage.contains(_currentBar)){
				_currentBar.hide();
				_stage.removeChild(_currentBar);
				_currentBar = null;
			}
			_position.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}

		/**
		 * 获取样式工具条
		 * @param	jid
		 * @return
		 */
		private function getBar(jid:String):TextFormatBar {
			var bar:TextFormatBar = _bars[jid];
			if (!bar){
				bar = new TextFormatBar(_chat);
				_bars[jid] = bar;
			}
			return _bars[jid];
		}
	}
}