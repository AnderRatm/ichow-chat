package org.ichow.eelive.managers 
{
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import org.ichow.eelive.chats.SparkChat;
	import org.ichow.eelive.forms.ChatForm;
	import org.ichow.eelive.forms.IFace;
	/**
	 * ...
	 * @author ichow
	 */
	public class BrowseManager 
	{
		private var file:FileReference;
		private var ff:FileFilter;
		private var chats:Object;
		private var _chat:IFace;
		
		private var uploadURL:String = "http://172.16.165.89/upload.php";
		private var uploadReq:URLRequest;
		
		public function BrowseManager() 
		{
			chats = { };
			uploadReq = new URLRequest(uploadURL);
			ff = new FileFilter("Images(*.jpg;*.png;*.gif)", "*.jpg;*.png;*.gif");
			file = new FileReference();
			file.addEventListener(Event.SELECT, onSelect);
			file.addEventListener(Event.CANCEL, onCancel);
		}
		
		public function bind(chat:IFace):void {
			_chat = chat;
			file.browse([ff]);
		}
		
		private function onCancel(e:Event):void 
		{
			_chat = null;
		}
		
		private function onSelect(e:Event):void 
		{
			if (_chat != null) {
				//chats[_chat.head.jid.bareJID] = _chat;
			}
			if ((file.size / 1000) > 200) return;
			file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUpLoadComplete);
			//upload
			file.upload(uploadReq);
		}
		
		private function onUpLoadComplete(e:DataEvent):void 
		{
			var xml:XML = new XML(e.data);
			_chat.addFace(xml);
		}
		
	}

}