package org.ichow.eelive.draw 
{
	import com.adobe.images.PNGEncoder;
	import com.bit101.components.HBox;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.bit101.utils.MinimalConfigurator;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author ichow
	 */
	public class Draw extends Sprite 
	{
		private var active:String;
		
		private var _board:Sprite;
		private var _toolsPanel:Sprite;
		
		private var _pencilButton:PushButton;
		private var _eraserButton:PushButton;
		private var _clearButton:PushButton;
		private var _textButton:PushButton;
		
		private var _rect:Rectangle;
		private var toolsPanelHeight:int = 60;
		
		private var _minimal:MinimalConfigurator;
		
		private var _config:XML = <draw>
									<HBox>
										<PushButton id="pencil" togger="true" width="24" height="24"/>
										<PushButton id="eraser" togger="true" width="24" height="24"/>
									</HBox>
								  </draw>
		
		public function Draw(rect:Rectangle=null) 
		{
			_rect = rect;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			init();
		}
		
		protected function init():void 
		{
			addChildren();
		}
		
		protected function addChildren():void 
		{
			//convertToBMD();
			_toolsPanel = new Sprite();
			_toolsPanel.graphics.beginFill(0xDFDFDF);
			_toolsPanel.graphics.drawRect(0, 0, _rect.width, toolsPanelHeight);
			_toolsPanel.graphics.endFill();
			addChild(_toolsPanel);
			//
			_board = new Sprite();
			_board.graphics.beginFill(0xFFFFFF);
			_board.graphics.drawRect(0, 0, _rect.width, _rect.height - toolsPanelHeight);
			_board.graphics.endFill();
			_board.y = _toolsPanel.height;
			addChild(_board);
			//
			_minimal = new MinimalConfigurator(_toolsPanel);
			
			_pencilButton = _minimal.getCompById("pencil") as PushButton;
			_pencilButton.addEventListener(MouseEvent.CLICK, onToolsMouseClick);
			
		}
		
		private function onToolsMouseClick(e:MouseEvent):void 
		{
			
		}
		
		/**
		 * 清除
		 * @param	e
		 */
		private function clearBoard(e:MouseEvent):void
		{
		}

		/**
		 * 取消功能
		 */
		private function quitActiveTool():void
		{
			switch (active)
			{
				case "Pencil" :
				case "Eraser" :
				case "Text" :
				default :
			}
			
		}

		/**
		 * 侦听
		 */
		private function addListeners():void
		{
			
		}
		
		private function removeListeners():void
		{
			
		}
		
		private function onAddedToStage(e:Event):void 
		{
			addListeners();
		}
		
		private function onRemovedFromStage(e:Event):void 
		{
			removeListeners();
		}
		
	}

}