package org.ichow.eelive.core 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class FaceItem extends EventDispatcher
	{
		
		private var _dataFormat:String;
		private var _urlLoader:URLLoader;
		
		public var id:int;
		public var code:String;
		public var source:String;
		public var group:String;
		public var des:String;
		public var data:ByteArray;
		
		public function FaceItem() 
		{
			_urlLoader = new URLLoader();
			_urlLoader.addEventListener(Event.COMPLETE, onComplete);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
		}
		
		private function onComplete(e:Event):void 
		{
			data = e.target.data as ByteArray;
			dispatchEvent(e);
			removeListeners();
		}
		
		private function onError(e:IOErrorEvent):void 
		{
			dispatchEvent(e);
			removeListeners();
		}
		
		private function removeListeners():void 
		{
			_urlLoader.removeEventListener(Event.COMPLETE, onComplete);
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
		}
		
		public function set dataFormat(value:String):void {
			_dataFormat = value;
			_urlLoader.dataFormat = value;
		}
		public function get dataFormat():String {
			return _dataFormat;
		}
		
		public function load(request:URLRequest):void {
			_urlLoader.load(request);
		}
		
		
	}

}