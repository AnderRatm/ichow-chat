package org.ichow.components 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import org.ichow.eelive.core.FaceByteArray;
	import org.ichow.eelive.core.FaceItem;
	import org.ichow.eelive.events.FaceEvent;
	import org.ichow.eelive.view.FlowPanel;
	import org.ichow.event.EventProxy;
	import org.ichow.settings.ToolsSettings;
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class FacePane extends Component 
	{
		public static const TOP:String = "top";
		public static const BOTTOM:String = "bottom";
		
		public var target:FlowPanel;
		
		protected var _items:Array;
		protected var _labelButton:PushButton;
		protected var _list:Panel;
		protected var _faces:VScrollPane;
		protected var _numVisibleItems:int = 5;
		protected var _open:Boolean = false;
		protected var _openPosition:String = BOTTOM;
		protected var _stage:Stage;
		
		private var _type:String;
		
		private var _listWidth:int;
		private var _listHeight:int;
		private var faceBorder:Shape;
		private var faceTimer:Timer;
		public function FacePane(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, type:String="")
		{
			this._type = type;
			_listWidth = ToolsSettings.STYLE_FACE_PANE_WIDTH;
			_listHeight = ToolsSettings.STYLE_FACE_PANE_HEIGHT;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			super(parent, xpos, ypos);
		}
		
		protected override function init():void
		{
			super.init();
			setSize(ToolsSettings.STYLE_ICON_SIDE, ToolsSettings.STYLE_ICON_SIDE);
		}
		
		protected override function addChildren():void
		{
			super.addChildren();
			
			_list = new Panel();
			_faces = new VScrollPane(_list);
			_faces.dragContent = false;
			_faces.isbg = false;
			
			_items = new Array();
			
			faceTimer = new Timer(500, 0);
			faceTimer.addEventListener(TimerEvent.TIMER, onFaceTimer);
			faceTimer.start();
			
			_labelButton = new PushButton(this, 0, 0, "", onDropDown, Style.FACE_BUTTON_SKIN);
			
		}
		
		private function onFaceTimer(e:TimerEvent):void 
		{
			if (FaceByteArray.isLoad) {
				faceTimer.stop();
				initFaceChildren();
			}
		}
		
		
		
		private function initFaceChildren():void 
		{
			_items = FaceByteArray.faces;
			for (var i:int = 0, len:int = _items.length; i < len; i++) {
				if (_items[i] == "") continue;
				var lod:Loader = new Loader();
				lod.loadBytes((_items[i] as FaceItem).data);
				
				lod.x = 2 + i % 5 * 30;
				lod.y = 2 + Math.floor(i / 5) * 30;
				lod.name = i + "";
				lod.addEventListener(MouseEvent.CLICK, onLoaderMouseClick);
				lod.addEventListener(MouseEvent.ROLL_OVER, onLoaderRollOver);
				lod.addEventListener(MouseEvent.ROLL_OUT, onLoaderRollOut);
				_faces.addChild(lod);
					
			}
			
			faceBorder = new Shape();
			faceBorder.graphics.lineStyle(1, 0x0000CC);
			faceBorder.graphics.drawRect(0, 0, 26, 26);
			faceBorder.visible = false;
			_faces.addChild(faceBorder);
			
			invalidate();
		}
		
		private function onLoaderMouseClick(e:MouseEvent):void 
		{
			_open = false;
			var id:int = int(e.target.name);
			var item:FaceItem = _items[id];
			//trace(e.target.name);
			var evt:FaceEvent = new FaceEvent(FaceEvent.ADD_FACE, item, target);
			EventProxy.broadcastEvent(evt);
			
			/*(if(stage != null && stage.contains(_list))
			{
				stage.removeChild(_list);
			}(*/
			removeList();
		}
		
		private function onLoaderRollOver(e:MouseEvent):void 
		{
			faceBorder.x = e.currentTarget.x-1;
			faceBorder.y = e.currentTarget.y-1;
			faceBorder.visible = true;
		}
		
		private function onLoaderRollOut(e:MouseEvent):void 
		{
			faceBorder.visible = false;
		}
		
		public override function draw():void
		{
			super.draw();
			
			_labelButton.setSize(_width, _height);
			_labelButton.draw();
			
			_list.setSize(_listWidth, _listHeight);
			_faces.setSize(_listWidth - 10, _listHeight - 10);
			_faces.move(5, 5);
		}
		
		protected function removeList():void
		{
			
			if(_stage.contains(_list)) _stage.removeChild(_list);
			_stage.removeEventListener(MouseEvent.CLICK, onStageClick);		
		}
		
		protected function onDropDown(event:MouseEvent):void
		{
			_open = !_open;
			if(_open)
			{
				var point:Point = new Point();
				if(_openPosition == BOTTOM)
				{
					point.y = _height+1;
				}
				else
				{
					point.y = -_listHeight - 1;
				}
				point = this.localToGlobal(point);
				_list.move(point.x, point.y);
				_stage.addChild(_list);
				_stage.addEventListener(MouseEvent.CLICK, onStageClick);
			}
			else
			{
				removeList();
			}
		}
		
		/**
		 * Called when the mouse is clicked somewhere outside of the combo box when the list is open. Closes the list.
		 */
		protected function onStageClick(event:MouseEvent):void
		{
			// ignore clicks within buttons or list
			if(event.target == _labelButton) return;
			if(new Rectangle(_list.x, _list.y, _list.width, _list.height).contains(event.stageX, event.stageY)) return;

			_open = false;
			removeList();
		}
		
		/**
		 * Called when the component is added to the stage.
		 */
		protected function onAddedToStage(event:Event):void
		{
			_stage = stage;
		}
		
		/**
		 * Called when the component is removed from the stage.
		 */
		protected function onRemovedFromStage(event:Event):void
		{
			removeList();
		}
		
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////
		
		/**
		 * Sets / gets the position the list will open on: top or bottom.
		 */
		public function set openPosition(value:String):void
		{
			_openPosition = value;
		}
		public function get openPosition():String
		{
			return _openPosition;
		}
		
		/**
		 * Gets whether or not the combo box is currently open.
		 */
		public function get isOpen():Boolean
		{
			return _open;
		}
	}

}