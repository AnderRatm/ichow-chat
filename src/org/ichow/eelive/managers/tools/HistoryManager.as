package org.ichow.eelive.managers.tools {
	import com.bit101.components.List;
	import com.bit101.components.Window;
	import com.hexagonstar.util.debug.Debug;
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
	import org.ichow.eelive.chats.SparkMessage;
	import org.ichow.eelive.components.MessageItem;
	import org.ichow.eelive.managers.ChatManager;
	import org.igniterealtime.xiff.core.UnescapedJID;

	/**
	 * ...
	 * @author ichow
	 */
	public class HistoryManager {
		private var _msgsObj:Object;
		private var _defTextFormat:TextFormat
		private var _historyList:Sprite;
		private var _historyObj:Object;
		private var _closeCallBack:Function

		/**
		 * 历史信息管理
		 */
		public function HistoryManager(){
			_msgsObj = {};
			_historyObj = {};
			_defTextFormat = new TextFormat("宋体", 12);
			_closeCallBack = new Function();
		}

		/**
		 * 保存
		 * @param	msg		:	信息
		 */
		public function save(msg:SparkMessage):void {
			if (!msg.from || !msg.from.bareJID)
				return;
			var _msgs:Array = _msgsObj[msg.from.bareJID];
			if (!_msgs)
				_msgs = new Array();
			_msgs.push(msg);
			_msgsObj[msg.from.bareJID] = _msgs;
			//update
			getHistory(msg.from);
		}

		/**
		 * 屏蔽
		 * @param	jid
		 * @param	msgID
		 */
		public function screen(jid:String, msgID:String):void {
			var msg:SparkMessage = getHistoryAt(jid, msgID);
			var chat:SparkChat = ChatManager.sharedInstance.getChat(new UnescapedJID(jid));
			chat.ui.screen(msgID, {label: msg.nick, content: "**此信息已被屏蔽**"});
			Debug.trace("屏蔽: " + jid + " id: " + msgID);
		}

		/**
		 * 恢复
		 * @param	jid
		 * @param	msgID
		 */
		public function resume(jid:String, msgID:String):void {
			var msg:SparkMessage = getHistoryAt(jid, msgID);
			var chat:SparkChat = ChatManager.sharedInstance.getChat(new UnescapedJID(jid));
			chat.ui.resume(msgID, {label: msg.nick, content: msg.body});
			Debug.trace("恢复: " + jid + " id: " + msgID);
		}

		/**
		 * 获取单条保存的信息
		 * @param	jid
		 * @param	msgID
		 * @return
		 */
		public function getHistoryAt(jid:String, msgID:String):SparkMessage {
			var messages:Array = _msgsObj[jid];
			for each (var i:SparkMessage in messages){
				if (i.id == msgID)
					return i;
			}
			return null;
		}

		/**
		 * 获取历史信息列表
		 * @param	jid
		 * @param	w
		 * @param	h
		 * @return
		 */
		public function getHistory(jid:UnescapedJID, w:Number = 100, h:Number = 600):DisplayObject {
			if (!jid)
				return null;
			var win:Window = _historyObj[jid.bareJID];
			if (!win){
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
			if (messages){
				list = win.content.getChildByName("items") as List;
				for (var i:int = list.items.length, len:int = messages.length; i < len; i++){
					var item:SparkMessage = messages[i];
					//add message history list item
					list.addItem({label: item.nick, content: item.body, id: item.id, jid: item.from.bareJID});
				}
				list.draw();
			}
			_historyObj[jid.bareJID] = list;
			return _historyObj[jid.bareJID];
		}

		/**
		 * 关闭
		 * @param	e
		 */
		private function onWinClose(e:Event):void {
			_closeCallBack(e);
		}

		public function set closeCallBack(f:Function):void {
			_closeCallBack = f;
		}

		/**
		 * 清除所有信息
		 */
		public function clearAll():void {
			for each (var i:Object in _msgsObj){
				i = null;
			}
			_msgsObj = {};
		}
	}
}