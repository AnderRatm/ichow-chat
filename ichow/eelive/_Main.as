package org.ichow.eelive 
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import org.ichow.components.PushButton;
	import org.ichow.components.Style;
	import org.ichow.debug.eeDebug;
	import org.ichow.eelive.connection.ConnectManager;
	import org.ichow.eelive.connection.RoomManager;
	import org.ichow.eelive.connection.ServiceBrowser;
	import org.ichow.eelive.core.FaceByteArray;
	import org.ichow.eelive.core.OpenFireRoomEssentials;
	import org.ichow.eelive.core.User;
	import org.ichow.eelive.events.ChatMessageEvent;
	import org.ichow.eelive.events.OpenFireErrorsEvent;
	import org.ichow.eelive.events.PersonalRoomEvent;
	import org.ichow.eelive.events.UserAccessEvent;
	import org.ichow.eelive.view.LoginView;
	import org.ichow.eelive.view.MainView;
	import org.ichow.event.EventProxy;
	import org.ichow.settings.eeLiveSettings;
	import org.ichow.util.ChatUtil;
	import org.igniterealtime.xiff.bookmark.GroupChatBookmark;
	import org.igniterealtime.xiff.conference.Room;
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.data.disco.ItemDiscoExtension;
	import org.igniterealtime.xiff.data.forms.FormExtension;
	import org.igniterealtime.xiff.data.im.RosterExtension;
	import org.igniterealtime.xiff.data.im.RosterGroup;
	import org.igniterealtime.xiff.data.IQ;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.data.muc.MUCUserExtension;
	import org.igniterealtime.xiff.data.sharedgroups.SharedGroupsExtension;
	import org.igniterealtime.xiff.data.XMPPStanza;
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class Main extends Sprite 
	{
		
		
		private var _checkConnect:Timer;
		
		public function Main() 
		{
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		private var progressTf:TextField;
		
		private function init(e:Event=null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			//stage.showDefaultContextMenu = false;
			//get loadinfo
			if (stage.loaderInfo.parameters!=null) {
				var obj:Object = stage.loaderInfo.parameters;
				
				eeLiveSettings.flashvars = obj;
				
			}
			
			progressTf = new TextField();
			progressTf.width = 100, progressTf.height = 20;
			progressTf.text = "0%";
			progressTf.border = true;
			progressTf.x = Math.floor((eeLiveSettings.CHAT_MIN_WIDTH - progressTf.width) / 2);
			progressTf.y = Math.floor((eeLiveSettings.CHAT_MIN_HEIGHT - progressTf.height) / 2);
			addChild(progressTf);
			
			var assURL:String = eeLiveSettings.flashvars.netPath != null?eeLiveSettings.flashvars.netPath:"";
			
			var ass:Loader = new Loader();
			var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			ass.contentLoaderInfo.addEventListener(Event.COMPLETE, onAssetsComplete);
			ass.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onAssetsProgress);
			ass.load(new URLRequest(assURL+eeLiveSettings.ASSETS_URL), context);
			
			//表情xml
			var face:URLLoader = new URLLoader();
			face.addEventListener(Event.COMPLETE, onFaceComplete);
			face.load(new URLRequest(assURL+eeLiveSettings.FACE_URL));
			
			//头像xml
			var head:URLLoader = new URLLoader();
			head.addEventListener(Event.COMPLETE, onHeadComplete);
			head.load(new URLRequest(assURL+eeLiveSettings.HEAD_URL));
			
			//
			_checkConnect = new Timer(3 * 1000, 1) 
			_checkConnect.addEventListener(TimerEvent.TIMER_COMPLETE, reLogin);
			//trace(_checkConnect);
			
		}
		
		private function onAssetsProgress(e:ProgressEvent):void 
		{
			progressTf.text = Math.floor((e.bytesLoaded / e.bytesTotal) * 100) + "%";
		}
		/**
		 * 头像xml加载完成
		 * @param	e
		 */
		private function onHeadComplete(e:Event):void 
		{
			var xml:XML = new XML(e.target.data);
			FaceByteArray.loadHeads(xml);
			EventProxy.subscribeEvent(this, FaceByteArray.HEAD_LOADED, onHeadLoaded);
			e.target.removeEventListener(Event.COMPLETE, onHeadComplete);
		}
		
		private function onHeadLoaded(e:Event):void 
		{
			FaceByteArray.isHeaded = true;
			EventProxy.unsubscribeEvent(this, FaceByteArray.HEAD_LOADED, onHeadLoaded);
		}
		/**
		 * 表情xml加载完成
		 * @param	e
		 */
		private function onFaceComplete(e:Event):void 
		{
			var xml:XML=new XML(e.target.data);
			
			var images:Dictionary = new Dictionary();
			var code:String;
			var source:String;
			for (var i:int = 0, len:int = xml.item.length(); i < len; i++) {
				code = xml.item[i].@code;
				source = xml.item[i].@source;
				code = code.toLowerCase();
				source = source.toLowerCase();
				images[code] = source;
				images[source] = code;
			}
			Style.FACE_XML = xml
			EventProxy.subscribeEvent(this, FaceByteArray.FACE_LOADED, onFaceLoaded);
			FaceByteArray.loadFaces(xml);
			ChatUtil.images = images;
			e.target.removeEventListener(Event.COMPLETE, onFaceComplete);
		}
		
		private function onFaceLoaded(e:Event):void 
		{
			EventProxy.unsubscribeEvent(this, FaceByteArray.FACE_LOADED, onFaceLoaded);
			FaceByteArray.isLoad = true;
		}
		
		private var _width:int;
		private var _height:int;
		private var canvas:Sprite;
		
		private var _bg:DisplayObject;
		private function onAssetsComplete(e:Event):void 
		{
			removeChild(progressTf);
			_width = eeLiveSettings.CHAT_MIN_WIDTH;
			_height = eeLiveSettings.CHAT_MIN_HEIGHT;
			//add main back ground
			_bg = Style.getAssets(Style.MAIN_BACKGROUND_SKIN) as DisplayObject;
			_bg.width = eeLiveSettings.CHAT_MAX_WIDTH;
			_bg.height = eeLiveSettings.CHAT_MAX_HEIGHT;
			addChildAt(_bg, 0);
			//
			Style.enabled();
			//back ground
			//create canvas
			canvas = new Sprite();
			addChild(canvas);
			//listeners
			addEventListeners();
			//connetion
			initConnection();
			//forms
			initForms();
			status = eeLiveSettings.STATUS_LOGIN;
			
			if (eeLiveSettings.flashvars.autoLogin == "true" || eeLiveSettings.AUTO_LOGIN) {
				loginV.onLoginMouseClick(null);
			}
		}
		
		private function addEventListeners():void 
		{
			//尝试登入
			EventProxy.subscribeEvent(this, LoginView.LOGGING, onLoading);
			//登入
			EventProxy.subscribeEvent(this, UserAccessEvent.LOGIN, onLogin);
			//错误
			EventProxy.subscribeEvent(this, OpenFireErrorsEvent.CONNECTION_ERROR, onConnectionError);
			//登出
			EventProxy.subscribeEvent(this, UserAccessEvent.LOGOUT, onLogout);
			//发送消息
			EventProxy.subscribeEvent(this, ChatMessageEvent.SEND_GROUP_MESSAGE, onSendGroupMessage);
			//私聊
			EventProxy.subscribeEvent(this, ChatMessageEvent.SEND_CHAT_MESSAGE, onSendChatMessage);
			//
		}
		
		private function removeEventListeners():void {
			
		}
		
		private var loginV:LoginView;
		private var mainV:MainView;
		/**
		 * 初始化框体
		 */
		private function initForms():void 
		{
			mainV = new MainView(null, 0, 0, _width, _height, "mainView");
			loginV = new LoginView(null, 0, 0, _width, _height, "login");
		}
		
		private var connectManager:ConnectManager;
		private var roomManager:RoomManager;
		/**
		 * 初始化连接
		 */
		private function initConnection():void 
		{
			connectManager = new ConnectManager();
			if (eeLiveSettings.flashvars.port != null) {
				connectManager.init(eeLiveSettings.flashvars.port, "");
			}else {
				connectManager.init(eeLiveSettings.SERVER_PORT, eeLiveSettings.RESOURCE_NAME);
			}
			//room|group
			roomManager = new RoomManager();
			roomManager.welcomeMessage = "我来噜！！";
			
			
		}
		/**
		 * 发送私聊消息
		 * @param	e
		 */
		private function onSendChatMessage(e:ChatMessageEvent):void {
			if (connectManager.connection.isLoggedIn()) {
				connectManager.connection.send(e.lastMessage);
			}
		}
		/**
		 * 发送群消息
		 * @param	e
		 */
		private function onSendGroupMessage(e:ChatMessageEvent):void 
		{
			if (connectManager.connection.isLoggedIn()) {
				roomManager.sendMessage(e.lastPlainMessage);
			}
		}
		/**
		 * 错误
		 * @param	e
		 */
		private function onConnectionError(e:OpenFireErrorsEvent):void 
		{
			eeDebug.trace("onConnectionError. " + e.toString());
			eeDebug.trace("message. " + e.errorMessage);
		}
		/**
		 * 登出
		 * @param	e
		 */
		private function onLogout(e:UserAccessEvent):void 
		{
			eeDebug.trace("onLogout. " + e.toString());
			eeDebug.trace("name. " + e.username);
			status = eeLiveSettings.STATUS_LOGIN;
		}
		/**
		 * 登入
		 * @param	e
		 */
		private var browser:ServiceBrowser;
		private var roomsJID:EscapedJID;
		private function onLogin(e:UserAccessEvent):void 
		{
			//clear relogin timer
			_checkConnect.stop();
			//
			//eeLiveSettings.JID = new EscapedJID(e.unescapedJID.bareJID+"/"+eeLiveSettings;
			
			//start keep alive timer
			connectManager.keepAlive = true;
			//rooms server
			roomsJID = new EscapedJID("conference." + eeLiveSettings.CONFERENCE);
			//get the rooms list from rooms server
			browser = new ServiceBrowser(roomsJID, connectManager.connection);
			browser.currentChatRooms(roomsJID);
			//browser.
			//browser.
			//
			var id:String = eeLiveSettings.flashvars.roomID != null?eeLiveSettings.flashvars.roomID:eeLiveSettings.ROOM_ID;
			var conf:String = eeLiveSettings.flashvars.conference != null?eeLiveSettings.flashvars.conference:eeLiveSettings.CONFERENCE;
			var nick:String = eeLiveSettings.flashvars.nickname != null?eeLiveSettings.flashvars.nickname:eeLiveSettings.NICK_NAME;
			
			//create room
			var room:Room = new Room(connectManager.connection);
			room.roomJID = new EscapedJID(id + "@conference." + conf).unescaped;
			addRoomEvents();
			roomManager.createRoom(room);
			
			//change status to login
			status = eeLiveSettings.STATUS_ON;
			
		}
		/**
		 * 添加房间侦听
		 */
		private function addRoomEvents():void {
			EventProxy.subscribeEvent(this, PersonalRoomEvent.ROOM_EXISTS, onPersonalRoomExists);
			EventProxy.subscribeEvent(this, PersonalRoomEvent.ROOM_CREATED, onPersonalRoomCreated);
		}
		/**
		 * 移除房间侦听
		 */
		private function removeRoomEvents():void {
			EventProxy.unsubscribeEvent(this, PersonalRoomEvent.ROOM_CREATED, onPersonalRoomCreated);
			EventProxy.unsubscribeEvent(this, PersonalRoomEvent.ROOM_EXISTS, onPersonalRoomExists);
		}
		/**
		 * 房间已存在
		 * @param	e
		 */
		private function onPersonalRoomExists(e:PersonalRoomEvent):void 
		{
			trace(".onPersonalRoomExists: " + e.toString());
			trace(".currentRoom: " + e.currentRoom);
			removeRoomEvents();
			roomManager.joinRoom(e.currentRoom, connectManager.connection.jid, eeLiveSettings.NICK_NAME);
			
			
		}
		/**
		 * 创建成功
		 * @param	e
		 */
		private function onPersonalRoomCreated(e:PersonalRoomEvent):void 
		{
			trace(".onPersonalRoomCreated: " + e.toString());
			trace(".currentRoom: " + e.currentRoom);
			removeRoomEvents();
			var room:Room = e.currentRoom;
			room.join(true);
			var id:String = eeLiveSettings.flashvars.roomID != null?eeLiveSettings.flashvars.roomID:eeLiveSettings.ROOM_ID;
			var name:String = eeLiveSettings.flashvars.roomName != null?eeLiveSettings.flashvars.roomName:id;
			/**
            * 配置房间
            * muc#roomconfig_roomname 房间名称
            * muc#roomconfig_maxusers 房间最大人数 0 表示无人数上限
            * muc#roomconfig_persistentroom 是否为临时房间，临时房间当所有人退出房间时，该房间会删除
            * muc#roomconfig_roomdesc 房间描述
            **/
           	var roomConfig:Object={};
			roomConfig["muc#roomconfig_roomname"] = [name];
			roomConfig["muc#roomconfig_maxusers"] = [0];
			roomConfig["muc#roomconfig_persistentroom"] = [0];
			roomConfig["muc#roomconfig_roomdesc"] = [name];
            room.configure(roomConfig);
			//forbidden
			roomManager.joinRoom(e.currentRoom, connectManager.connection.jid, eeLiveSettings.NICK_NAME);
			
			
			var iq:IQ = new IQ(null, IQ.TYPE_GET, XMPPStanza.generateID("get_shared_groups_"), onIQCallBack);
			iq.addExtension(new RosterExtension())
			connectManager.connection.send(iq);
		}
		
		private function onIQCallBack(iq:IQ):void 
		{
			var extensions:Array = iq.getAllExtensions();
			trace(iq.type);
			for (var s:int = 0; s < extensions.length; ++s){
                var disco:RosterExtension = extensions[s];
                var items:Array = disco.getAllItems()
                
                trace(">> onIQCallBack. round " + s + ". items.length: " + items.length);
                
                for (var i:uint = 0; i < items.length; ++i){
                	
                    var obj:Object = items[i] as Object;
					eeDebug.traceObj(obj);
				}
			}
             
		}
		/**
		 * 更新狀態
		 * @param	s : 狀態
		 */
		public function updateStatus(s:int=0):void {
			switch(s) {
				case eeLiveSettings.STATUS_LOGIN:
					canvas.addChild(loginV);
					break;
				case eeLiveSettings.STATUS_LOGOUT:
					
					break;
				case eeLiveSettings.STATUS_ON:
					canvas.addChild(mainV);
					break;
				case eeLiveSettings.STATUS_OFF:
					
					break;
				case eeLiveSettings.STATUS_LOADING:
					//canvas.addChild(loadingV);
					break;
			}
		}
		/**
		 * 尝试登入
		 * @param	e
		 */
		
		private function onLoading(e:Event):void {
			status = eeLiveSettings.STATUS_LOADING;
			//user
			var user:User;
			
			user = new User(eeLiveSettings.USER_NAME, eeLiveSettings.PASS_WORD,eeLiveSettings.NICK_NAME);
			
			var anony:Boolean = eeLiveSettings.flashvars.anonymous != null?eeLiveSettings.flashvars.anonymous == "true"?true:false:eeLiveSettings.ANONYMOUS;
			
			connectManager.connect(eeLiveSettings.SERVER_IP, anony, user);
			//set 3 sec
			_checkConnect.start();
		}
		/**
		 * 重新登陆
		 * @param	e
		 */
		private function reLogin(e:TimerEvent):void 
		{
			status = eeLiveSettings.STATUS_LOGIN;
			if (_checkConnect.running) _checkConnect.reset();
		}
		
		private function onCancel():void {
			//
		}
		
		/**
		 * 設置狀態
		 */
		private var _preStatus:int;
		private var _status:int;
		public function set status(value:int):void {
			if (Math.abs(value) > 2) return;
			_preStatus = _status;
			_status = value;
			//remove all;
			while (canvas.numChildren > 0) {
				canvas.removeChildAt(0);
			}
			
			updateStatus(_status);
		}
		
	}

}