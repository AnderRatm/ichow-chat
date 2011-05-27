package org.ichow.eelive.draw 
{
	import com.bit101.components.ColorChooser;
	import com.bit101.components.ComboBox;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author ichow
	 */
	public class Pencil extends BaseDraw
	{
		private var _size:ComboBox;
		private var _color:ColorChooser;
		public static const UI_TYPE:String = "pencil";
		
		protected var _config:XML = <property>
										<HBox id='propertyBar'>
											<ComboBox id='size' width='50' />
											<ColorChooser id='color' usePopup='true' />
										</HBox>
									</property>
		
		public function Pencil()
		{
			super(UI_TYPE);
		}
		
		override protected function addChildren():void 
		{
			super.addChildren();
			//
			_minimal.parseXML(_config);
			//
			_size = _minimal.getCompById("size") as ComboBox;
			_size.defaultLabel = 1;
			_size.items = [1, 2, 3, 4, 5, 6, 7];
			//
			_color = _minimal.getCompById("color") as ColorChooser;
			_color.value = 0x000000;
			//
			
		}
		
		override protected function onBoardMouseDown(e:MouseEvent):void 
		{
			super.onBoardMouseDown(e);
			//get
			_draw = new Shape();
			_board.addChild(_draw);

			_draw.graphics.moveTo(_board.mouseX, _board.mouseY);
			_draw.graphics.lineStyle(Number(_size.selectedItem), _color.value);
		}
		
		override protected function onBoardMouseMove(e:MouseEvent):void 
		{
			super.onBoardMouseMove(e);
			_draw.graphics.lineTo(_board.mouseX, _board.mouseY);
		}
		
		override protected function addListeners():void 
		{
			super.addListeners();
			
		}
		
		override protected function removeListeners():void 
		{
			super.removeListeners();
		}
		
		override public function active():void 
		{
			super.active();
			//add property
			if (_board.parent) 
				_board.parent.addChild(_property);
		}
		
		override public function cancel():void 
		{
			super.cancel();
			//remove property
			if (_board.parent)
				_board.parent.removeChild(_property);
		}
		
	}

}