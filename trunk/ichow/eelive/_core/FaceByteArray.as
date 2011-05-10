package org.ichow.eelive.core 
{
	import adobe.utils.CustomActions;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.xml.XMLNode;
	import org.ichow.event.EventProxy;
	import org.ichow.util.ChatUtil;
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class FaceByteArray 
	{
		public static const FACE_LOADED:String = "faceLoaded";
		public static const HEAD_LOADED:String = "headLoaded";
		//表情
		public static var faces:Array;
		public static var isLoad:Boolean = false;
		public static var faceXML:XML;
		//头像
		public static var heads:Array
		public static var isHeaded:Boolean=false;
		public static var headXML:XML;
		
		public static function loadHeads(xml:XML):void {
			headXML = xml;
			if (heads == null) heads = [];
			for (var i:int = 0, len:int = xml.item.length(); i < len; i++) {
				var req:URLRequest = new URLRequest(xml.item[i].@source);
				var item:FaceItem = new FaceItem();
				item.dataFormat = URLLoaderDataFormat.BINARY;
				
				item.id = int(xml.item[i].@id);
				item.code = xml.item[i].@code;
				item.source = xml.item[i].@source;
				//item.group = xml.item[i].@group;
				//item.des = xml.item[i].@des;
				
				item.addEventListener(Event.COMPLETE, onHeadComplete);
				item.addEventListener(IOErrorEvent.IO_ERROR, onHeadError);
				item.load(req);
			}
		}
		
		static private function onHeadComplete(e:Event):void 
		{
			heads.push(e.target);
			check(heads.length, headXML.item.length(), HEAD_LOADED);
		}
		
		static private function onHeadError(e:IOErrorEvent):void 
		{
			heads.push("");
			check(heads.length, headXML.item.length(), HEAD_LOADED);
		}
		
		
		public static function loadFaces(xml:XML):void {
			faceXML = xml;
			faces = new Array();
			var len:int = faceXML.item.length();
			for (var i:int = 0; i < len; i++) {
				var req:URLRequest = new URLRequest(faceXML.item[i].@source);
				var item:FaceItem = new FaceItem();
				item.dataFormat = URLLoaderDataFormat.BINARY;
				
				item.id = int(faceXML.item[i].@id);
				item.code = faceXML.item[i].@code;
				item.source = faceXML.item[i].@source;
				item.group = faceXML.item[i].@group;
				item.des = faceXML.item[i].@des;
				
				item.addEventListener(Event.COMPLETE, onComplete);
				item.addEventListener(IOErrorEvent.IO_ERROR, onError);
				item.load(req);
			}
		}
		
		static private function onError(e:IOErrorEvent):void 
		{
			faces.push("");
			check(faces.length, faceXML.item.length(), FACE_LOADED);
		}
		
		static private function onComplete(e:Event):void 
		{
			faces.push(e.target);
			check(faces.length, faceXML.item.length(), FACE_LOADED);
		}
		
		static private function check(min:int,max:int,evt:String):void 
		{
			//if (faces.length >= faceXML.item.length()) EventProxy.broadcastEvent(new Event(FACE_LOADED));
			if (min >= max) EventProxy.broadcastEvent(new Event(evt));
		}
		
	}
}