package org.ichow.eelive.forms {
	import com.bit101.components.Component;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.bit101.components.ScrollPane;
	import com.hexagonstar.util.debug.Debug;
	import flash.display.DisplayObjectContainer;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import org.ichow.eelive.chats.SparkChat;
	import org.ichow.eelive.components.*;
	import org.ichow.eelive.events.ChatEvent;
	import org.ichow.eelive.managers.ChatManager;
	import org.ichow.eelive.managers.FormManager;
	import org.ichow.eelive.managers.SparkManager;
	/**
	 * ...
	 * @author ichow
	 */
	public class MainForm extends BaseForm {
		public static var FormsWidth:int;
		public static var FormsHeight:int;

		public static const MAIN:String = "main";

		protected var _xml:XML;

		private var btnList:Vector.<PushButton>;
		private var formsShow:ScrollPane;
		private var formsDic:Dictionary;
		private var chatsShow:Panel
		private var chatsDic:Dictionary;
		private var mainBG:Panel;
		private var headPanel:Panel;
		private var head:HeadItem;
		private var exitButton:PushButton;

		public function MainForm(xml:* = "", parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, type:String = ""){
			_xml = new XML(xml);
			super(parent, xpos, ypos, type);
		}

		override protected function addChildren():void {
			super.addChildren();
			composition.parseXML(_xml);

			headPanel = composition.getCompById("HeadIcon") as Panel;

			formsShow = composition.getCompById("FormsShow") as ScrollPane;
			chatsShow = composition.getCompById("chatBG") as Panel;
			mainBG = composition.getCompById("mainBG") as Panel;
			exitButton = composition.getCompById("ExitButton") as PushButton;

			//formsShow.horizontalScrollPolicy = "off";
			FormsWidth = formsShow.width;
			FormsHeight = formsShow.height;

			btnList = new Vector.<PushButton>();
			formsDic = new Dictionary();
			chatsDic = new Dictionary();
			var c:Component = composition.getCompById("HFormsList");
			for (var i:int = 0, len:int = c.numChildren; i < len; i++){
				btnList[i] = c.getChildAt(i) as PushButton;
			}

		}
		/**
		 * 關閉聊天框
		 * @param	e
		 */
		private function onChatEnded(e:ChatEvent):void {
			var chat:SparkChat = e.chat;
			chat.close();
			chatsShow.width = chatsShow.content.numChildren == 0 ? 1 : chatsShow.width;
		}
		/**
		 * 打開聊天框
		 * @param	evt
		 */
		private function onChatStarted(evt:ChatEvent):void {
			var chat:SparkChat = evt.chat;
			if (chat.ui == null){
				var form:ChatForm = new ChatForm(FormManager.xml.Chat, chatsShow.content, 0, 0, "chat");
				var h:HeadItem = new HeadItem(evt.jid, "loading..", chat.presence, null, "small", false);
				form.head = h;
				chat.ui = form;
				try {
					h.label = chat.displayName;
				} catch (e:Error) {
					h.label = "";
				};
				
			}

			if (!evt.activate)
				return;
			while (chatsShow.content.numChildren > 0){
				var old:ChatForm = chatsShow.content.getChildAt(0) as ChatForm;
				old.hide();
			}
			(chat.ui as ChatForm).show();
			chatsShow.width = stage.stageWidth - mainBG.width;
		}
		/**
		 * 更新
		 */
		public function update():void {
			head = new HeadItem(SparkManager.me.jid, SparkManager.me.displayName, "在线", "def", "big", false);
			head.isAvailable = true;
			if (headPanel.content.numChildren > 0)
				headPanel.content.removeChildAt(0);
			headPanel.addChild(head);
			if (formsShow.content.numChildren == 0){
				var ie:IEventDispatcher = btnList[0] as IEventDispatcher;
				ie.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
		}
		/**
		 * 退出按钮点击
		 * @param	e
		 */
		private function onExitMouseClick(e:MouseEvent):void {
			//logout
			SparkManager.logout();
			//clear all chat form
			removeEventListeners();
			for (var i:String in formsDic){
				formsDic[i] = null;
			}
			SparkManager.sharedGroupsManager.groups = null;
			ChatManager.sharedInstance.clear();
			if (formsShow.content.numChildren > 0)
				formsShow.content.removeChildAt(0);
			chatsShow.width = 1;
			//show login form
			FormManager.show();
		}
		/**
		 * 列表按钮点击
		 * @param	e
		 */
		private function onListsButtonMouseClick(e:MouseEvent):void {
			//hide 
			if (formsShow.content.numChildren > 0)
				formsShow.content.removeChildAt(0);
			//show
			var sign:String = e.target.name;
			if (formsDic[sign] == null)
				formsDic[sign] = getList(sign);
			formsShow.addChild(formsDic[sign]);
			formsShow.update();
		}
		GroupsList;
		RoomsList;
		/**
		 * 獲取列表
		 * @param	sign
		 * @return
		 */
		private function getList(sign:String):ItemsList {
			var _type:String = "org.ichow.eelive.components." + sign.replace("Button", "List");
			var _class:Class = getDefinitionByName(_type) as Class;
			if (_class)
				return new _class();
			return null;
		}
		/**
		 * 移除偵聽
		 */
		override protected function removeEventListeners():void {
			super.removeEventListeners();
			for each (var i:PushButton in btnList){
				if (i)
					i.removeEventListener(MouseEvent.CLICK, onListsButtonMouseClick);
			}
			exitButton.removeEventListener(MouseEvent.CLICK, onExitMouseClick);
			ChatManager.sharedInstance.removeEventListener(ChatEvent.CHAT_STARTED, onChatStarted);
			ChatManager.sharedInstance.removeEventListener(ChatEvent.CHAT_ENDED, onChatEnded);
		}
		/**
		 * 添加偵聽
		 */
		override protected function addEventListeners():void {
			super.addEventListeners();
			for each (var i:PushButton in btnList){
				if (i)
					i.addEventListener(MouseEvent.CLICK, onListsButtonMouseClick);
			}
			exitButton.addEventListener(MouseEvent.CLICK, onExitMouseClick);
			//獲取聊天框創建
			ChatManager.sharedInstance.addEventListener(ChatEvent.CHAT_STARTED, onChatStarted);
			ChatManager.sharedInstance.addEventListener(ChatEvent.CHAT_ENDED, onChatEnded);
		}
		/**
		 * 顯示
		 */
		override public function show():void {
			super.show();
			update();
		}
	}

}