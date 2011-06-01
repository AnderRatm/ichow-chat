package org.ichow.eelive.managers.tools 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	import org.ichow.eelive.components.FaceItem;
	/**
	 * ...
	 * @author ichow
	 */
	public class ItemsManager extends EventDispatcher
	{
		//加载完成
		public static const ITEM_LOADED:String = "itemloaded";
		//数据列表XML
		protected var _xml:XML;
		//数组
		protected var _items:Vector.<FaceItem>;
		//遗漏数组
		protected var _will:Array;
		//总数
		protected var _max:int;
		//返回
		protected var _onLoadedCallBack:Function;
		
		/////////////////////////////// public method ///////////////////////////////
		
		/**
		 * 加载开始
		 */
		public function loadItems(xml:*= null):void {
			_xml = xml is String?new XML(xml):xml;
			_items = new Vector.<FaceItem>();
			_max = _xml.item.length();
			for (var i:int = 0; i < _max; i++) {
				var req:URLRequest = new URLRequest(_xml.item[i].@source);
				var item:FaceItem = new FaceItem();
				item.dataFormat = URLLoaderDataFormat.BINARY;
				
				item.id = int(_xml.item[i].@id);
				item.code = _xml.item[i].@code;
				item.source = _xml.item[i].@source;
				
				item.addEventListener(Event.COMPLETE, onHeadComplete);
				item.addEventListener(IOErrorEvent.IO_ERROR, onHeadError);
				item.load(req);
			}
		}
		/**
		 * 获取
		 * @param	code		:	标识
		 * @return	二进制
		 */
		public function getItemByte(code:String=null):ByteArray {
			for each(var i:FaceItem in _items)
			{
				if (i && i.code == code)
				{
					if(i.data)
						return i.data;
				}
			}
			return null;
		}
		/**
		 * 获取图片
		 * @param	value	:	二进制
		 * @return	Loader
		 */
		public function getLoader(value:ByteArray):Loader {
			var lod:Loader = new Loader()
			lod.loadBytes(value);
			return lod;
		}
		/**
		 * callback
		 */
		public function set onLoadedCallBack(fc:Function):void {
			_onLoadedCallBack = fc;
		}
		/**
		 * 设置
		 * @param	code
		 * @param	target
		 * @param	padding
		 */
		public function setItem(code:String = null, target:DisplayObjectContainer = null, padding:int = 2, pos:int = 0):void 
		{
			if (target)
			{
				var byte:ByteArray = getItemByte(code);
				if (byte) 
				{
					var lod:Loader = getLoader(byte);
					var side:int = target.width - 2 * padding;
					setTimeout(function():void {
						lod.width = lod.height = side;
						lod.x = lod.y = pos;
						target.addChild(lod);
					},50, target, lod, side, pos);
					return;
				}
			}
			if (!_will) _will = [];
			_will.push( { code:code, target:target, padding:padding } );
		}
		
		/////////////////////////////// protected method ///////////////////////////////
		
		/**
		 * 成功
		 * @param	e
		 */
		protected function onHeadComplete(e:Event):void 
		{
			_items.push(e.target);
			check(_items.length);
		}
		/**
		 * 错误
		 * @param	e
		 */
		protected function onHeadError(e:IOErrorEvent):void 
		{
			_items.push(null);
			check(_items.length);
		}
		/**
		 * 检查是否加载完
		 * @param	current
		 */
		protected function check(current:int):void 
		{
			if (current >= _max)
			{
				onComplete();
				dispatchEvent(new Event(ItemsManager.ITEM_LOADED));
				if (_onLoadedCallBack!=null)
					_onLoadedCallBack();
			}
		}
		/**
		 * 完成
		 */
		protected function onComplete():void 
		{
			if (_will)
			{
				for each(var i:Object in _will) {
					setItem(i.code, i.target, i.padding);
				}
				_will = null;
			}
		}
		
	}

}