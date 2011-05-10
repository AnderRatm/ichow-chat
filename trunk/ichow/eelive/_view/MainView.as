package org.ichow.eelive.view 
{
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import org.ichow.components.Label;
	import org.ichow.components.Style;
	import org.ichow.components.Window;
	import org.ichow.event.EventProxy;
	import org.ichow.settings.eeLiveSettings;
	import flash.external.ExternalInterface
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class MainView extends BaseView implements IShow
	{
		
		public static const ZOOM_IN:String = "zoomin";
		public static const ZOOM_OUT:String = "zoomout";
		
		public function MainView(	parent:DisplayObjectContainer = null, 
									xpos:Number = 0, 
									ypos:Number =  0,
									width:uint = 0,
									height:uint = 0,
									type:String = ""
									)  
		{
			super(parent, xpos, ypos, width, height, type);
		}
		
		private var _views:Dictionary;
		private var _roomV:RoomView;
		private var _groupV:GroupView;
		//...
		private var borderWin:Window;
		private var xPos:uint = 5;
		private var yPos:uint = 30;
		
		private var viewsList:ViewsList;
		private var _bg:DisplayObject;
		private var _title:TextField
		override protected function addChildren():void {
			super.addChildren();
			_views = new Dictionary();
			//main panel background skin
			_bg = Style.getAssets(Style.PANEL_BORDER_SKIN) as DisplayObject;
			_bg.width = _width;
			_bg.height = _height;
			addChildAt(_bg, 0);
			//main panel title label
			_title = new TextField();
			_title.defaultTextFormat = new TextFormat("宋体", 12, 0xFFFFFF, true);
			_title.autoSize = TextFieldAutoSize.LEFT;
			_title.filters = [new GlowFilter(0xCCCCCC, 1, 3, 3, 1)];
			_title.text = "在线交流 eeLive";
			_title.selectable = false;
			_title.x = _title.y = 7;
			addChild(_title);
			
			//create views
			_roomV = new RoomView(_canvas, xPos, yPos, _width - xPos * 2, _height - yPos * 2, "roomView");
			
			_views["房间"] = _roomV;
			
			if (eeLiveSettings.flashvars.hidePrivateChat != "true") {
				_groupV = new GroupView(_canvas, xPos, yPos, _width - xPos * 2, _height - yPos * 2, "groupView");
				_views["好友"] = _groupV;
			}
			//views list
			viewsList = new ViewsList(_views, this, 0, _height - yPos, _width, yPos, "viewsList");
			
			addChild(_canvas);
			
			//
			EventProxy.subscribeEvent(this, ZOOM_IN, onZoomIn);
			EventProxy.subscribeEvent(this, ZOOM_OUT, onZoomOut);
		}
		
		private function onZoomIn(e:Event):void 
		{
			trace("Zoom In");
			
			Tweener.addTween(this, { time:.3, x:eeLiveSettings.CHAT_MAX_WIDTH - _width } );
			onCall("zoom", "max");
		}
		
		private function onZoomOut(e:Event):void 
		{
			trace("Zoom Out");
			
			Tweener.addTween(this, { time:.3, x:0 } );
			onCall("zoom", "min");
		}
		private function onCall(act:String, data:String="",error:String=""):void {
			var obj:Object = { };
			obj.act = act;
			if (data != "") obj.data = data;
			if (error != "") obj.errorCode = error;
			if (eeLiveSettings.flashvars.netPath != null) ExternalInterface.call("eeLiveAction", obj);
		}
		
		override public function draw():void
		{
			super.draw();
			
			viewsList.graphics.clear();
			viewsList.graphics.beginFill(0x666666, .5);
			viewsList.graphics.drawRect(0, 0, _width, yPos);
			viewsList.graphics.endFill();
			
			EventProxy.broadcastEvent(new Event(ZOOM_OUT));
		}
		
		public function show():void {
			this.visible = true;
			this.mouseChildren = true;
			
			
		}
		
		public function hide():void {
			this.visible = false;
			this.mouseChildren = false;
			this.mouseEnabled = false;
		}
		
		
		
	}

}