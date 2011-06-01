package org.ichow.eelive.managers.tools 
{
	import com.bit101.components.List;
	import com.bit101.components.Window;
	import com.hurlant.util.Base64;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import org.ichow.eelive.chats.SparkChat;
	import org.ichow.eelive.managers.ChatManager;
	import org.ichow.event.EventProxy;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.Message;
	/**
	 * ...
	 * @author ichow
	 */
	public class HistoryManager 
	{
		private var _msgsObj:Object;
		private var _defTextFormat:TextFormat
		private var _historyList:Sprite;
		private var _historyObj:Object;
		
		public function HistoryManager() 
		{
			_msgsObj = { };
			_historyObj = { };
			_defTextFormat = new TextFormat("宋体", 12);
		}
		
		public function save(jid:UnescapedJID, msg:Object):void {
			if (!jid || !jid.bareJID) return;
			var _msgs:Array;
			_msgs = _msgsObj[jid.bareJID];
			if (!_msgs) _msgs = new Array();
			_msgs.push(msg);
			_msgsObj[jid.bareJID] = _msgs;
			getHistory(jid);
		}
		
		public function screen(data:String):void {
			var ids:Array = data.split("");
			var jid:String = ids[0];
			var msgID:String = ids[1];
			var obj:Object = getHistoryAt(jid, msgID);
			var chat:SparkChat = ChatManager.sharedInstance.getChat(new UnescapedJID(jid));
			chat.ui.screen(msgID, { label:obj.label, content:"**此信息已被屏蔽**"  } );
		}
		
		public function resume(data:String):void {
			var ids:Array = data.split("");
			var jid:String = ids[0];
			var msgID:String = ids[1];
			var obj:Object = getHistoryAt(jid, msgID);
			var chat:SparkChat = ChatManager.sharedInstance.getChat(new UnescapedJID(jid));
			chat.ui.resume(msgID, getHistoryAt(jid, msgID));
		}
		
		public function getHistoryAt(jid:String, msgID:String):Object {
			var messages:Array = _msgsObj[jid];
			for (var i:Object in messages) {
				if (messages[i].id == msgID)
					return messages[i];
			}
			return null;
		}
		
		public function getHistory(jid:UnescapedJID,w:Number = 100,h:Number = 600):DisplayObject {
			if (!jid) return null;
			var win:Window = _historyObj[jid.bareJID];
			if (!win)
			{
				win = new Window();
				win.draggable = false;
				win.setSize(w, h);
				win.hasCloseButton = true;
				win.name = jid.bareJID;
				win.addEventListener(Event.CLOSE, onWinClose);
				var list:List = new List(win, 2, 2);
				list.name = "items";
				list.listItemClass = MessageItem;
				list.listItemHeight = 50;
				list.setSize(win.width - 4, win.height - 4);
				win.title = "历史记录: " + jid.bareJID.substr(0, jid.bareJID.indexOf("@"));
			}
			var messages:Array = _msgsObj[jid.bareJID];
			if (messages)
			{
				list = win.content.getChildByName("items") as List;
				for (var i:int = list.items.length, len:int = messages.length; i < len; i++) {
					var item:Object = messages[i];
					list.addItem( { label:item.label, content:item.content, id:item.id } );
				}
				list.draw();
			}
			_historyObj[jid.bareJID] = list;
			return _historyObj[jid.bareJID];
		}
		
		private function onWinClose(e:Event):void 
		{
			//EventProxy.broadcastEvent(new Event("historyclose"));
		}
		
		public function clearAll():void {
			for each(var i:Object in _msgsObj) {
				i = null;
			}
			_msgsObj = { };
		}
		
	}

}