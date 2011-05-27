package org.ichow.eelive.managers {
	import com.hexagonstar.util.debug.Debug;
	import com.hurlant.util.Base64;
	import flash.events.EventDispatcher;
	import org.ichow.eelive.chats.SparkChat;
	import org.ichow.eelive.chats.SparkMessage;
	import org.ichow.eelive.components.HeadItem;
	import org.ichow.eelive.components.ItemsList;
	import org.ichow.eelive.utils.ChatUtil;
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.data.im.RosterItemVO;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.data.Presence;
	import org.igniterealtime.xiff.events.MessageEvent;
	import org.igniterealtime.xiff.events.PresenceEvent;

	/**
	 * ...
	 * @author ichow
	 */
	public class MessageManager extends EventDispatcher {
		//代码
		public static const TYPE_CODE:String = "typeCode";

		private static var _instance:MessageManager;

		public function MessageManager(){
			SparkManager.connectionManager.connection.addEventListener(MessageEvent.MESSAGE, onMessage);
			SparkManager.connectionManager.connection.addEventListener(PresenceEvent.PRESENCE, onPresence);
		}

		/**
		 * 状态更新
		 * @param	e
		 */
		private function onPresence(e:PresenceEvent):void {
		/*Debug.trace("opPresence: " + e.toString());
		   for (var i:int = 0,len:int = e.data.length; i < len; ++i)
		   {
		   var presence:Presence = e.data[i] as Presence;
		   var heads:Array = ItemsList.getItem(presence.from.bareJID);
		   for (var j in heads) {
		   var h:HeadItem = heads[j];
		   if (!h || !presence) continue;
		   h.status = presence.status?presence.status:"Offline";
		   }
		 }*/
		}

		/**
		 * 信息处理
		 * @param	e
		 */
		private function onMessage(e:MessageEvent):void {
			var message:Message = e.data as Message;
			var chat:SparkChat;
			var body:String;
			try {
				//Debug.trace("onMessage: " + e.toString());
				Debug.trace("message: " + message.body);
				Debug.trace("id: " + message.id);
				Debug.trace("type: " + message.type);
				Debug.trace("to: " + message.to.toString());
				Debug.trace("from: " + message.from.toString());
			} catch (error:Error){
			};
			switch (message.type){
				case Message.TYPE_CHAT:
				case Message.TYPE_GROUPCHAT:
					//get group chat by from.jid
					if (message.from && message.body){
						var vo:RosterItemVO = RosterItemVO.get(message.from.unescaped);
						if (vo)
							chat = ChatManager.sharedInstance.getChat(vo.jid, true);
						else
							chat = ChatManager.sharedInstance.getChat(message.from.unescaped, true);
						if (!chat)
							return;
					} else {
						return;
					}
					//头像跳动
					if (!chat.activated){
						var heads:Array = ItemsList.getItem(message.from.unescaped.bareJID);
						for each (var i:HeadItem in heads){
							i.hasMessage = true;
						}
						heads = null;
					}
					//add to message show
					chat.ui.addMessage(SparkMessage.fromMessage(message, chat));
					break;
				case Message.TYPE_NORMAL:
					break;
				case TYPE_CODE:
					break;
				default:

			}
		}

		/**
		 * 信息发送
		 * @param	jid				:	接受者jid
		 * @param	body			:	内容
		 * @param	htmlBody		:	html
		 * @param	type			:	类型
		 */
		public function sendMessage(jid:EscapedJID, body:String = null, htmlBody:String = null, type:String = null):void {
			//创建【id】用于处理历史记录
			var id:String = ChatUtil.randomString(8);
			var message:Message = new Message(jid, id, body, htmlBody, type);
			SparkManager.connectionManager.connection.send(message);
		}

		public static function get instance():MessageManager {
			if (!_instance)
				_instance = new MessageManager();
			return _instance;
		}
	}

}