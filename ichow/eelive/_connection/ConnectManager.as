package org.ichow.eelive.connection
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.system.Security;
	import org.ichow.debug.eeDebug;
	import org.ichow.eelive.core.User;
	import org.ichow.settings.eeLiveSettings;
	import org.ichow.event.EventProxy;
	import org.ichow.eelive.events.*;
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.core.XMPPConnection;
	import org.igniterealtime.xiff.data.IQ;
	import org.igniterealtime.xiff.data.muc.MUC;
	import org.igniterealtime.xiff.data.Presence;
	import org.igniterealtime.xiff.events.ConnectionSuccessEvent;
	import org.igniterealtime.xiff.events.DisconnectionEvent;
	import org.igniterealtime.xiff.events.LoginEvent;
	import org.igniterealtime.xiff.events.RegistrationSuccessEvent;
	import org.igniterealtime.xiff.events.XIFFErrorEvent;
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class ConnectManager
	{
        private const METHOD:uint = XMPPConnection.STREAM_TYPE_STANDARD
		
		private var port:int;
		private var resource:String;
		
		private var keppAliveTimer:Timer;
		
		private var _connection:XMPPConnection;
		
		private static var _instance:XMPPConnection;
		/**
		 * 构造
		 */
		public function ConnectManager() 
		{
			keppAliveTimer = new Timer(2 * 60 * 1000);
			keppAliveTimer.addEventListener(TimerEvent.TIMER, onKeepAlive);
		}
		/**
		 * 初始化
		 * @param	port : 端口
		 * @param	resource 
		 */
		public function init(port:int, resource:String=""):void {
			this.port = port;
			this.resource = resource;
		}
		/**
		 * 连接设置
		 * @param	domain : 域名
		 * @param	anonymous : 游客
		 * @param	user : 用户
		 */
		public function connect(domain:String, anonymous:Boolean = true, user:User = null):void {
			
			if (eeLiveSettings.CHECK_POLICY) Security.loadPolicyFile("xmlsocket://" + domain + ":5299");
			
			if (!_connection) _connection = new XMPPConnection();
			else _connection.disconnect();
			
			if (!domain) domain = eeLiveSettings.SERVER_IP;
			
			initListeners();
			
			_connection.domain = domain;
			_connection.port = port;
			_connection.resource = resource;
			
			if (anonymous) anonymousConnection();
			else registeredConnection(user);
		}
		/**
		 * 游客登陆
		 */
		private function anonymousConnection():void {
			_connection.useAnonymousLogin = true;
			makeConnection();
		}
		/**
		 * 设置用户
		 * @param	user
		 */
		private function registeredConnection(user:User):void {
			_connection.useAnonymousLogin = false;
			//_connection.username = user.username;
			//_connection.password = user.password;
			_user = user;
			makeConnection();
		}
		/**
		 * 开始连接
		 */
		private function makeConnection():void {
			_connection.connect(METHOD);
			
			MUC.enable();
		}
		/**
		 * 初始化侦听
		 */
		private function initListeners():void {
			
			connection.addEventListener(ConnectionSuccessEvent.CONNECT_SUCCESS, onConnectionSuccess);
			connection.addEventListener(LoginEvent.LOGIN, onLogin);
			connection.addEventListener(XIFFErrorEvent.XIFF_ERROR, onXiffError);
			connection.addEventListener(DisconnectionEvent.DISCONNECT, onDisconnect);
			
		}
		private function onConnectionSuccess(e:ConnectionSuccessEvent ):void{
			//EventProxy.broadcastEvent(new UserAccessEvent(UserAccessEvent.CONNECTED, e.target.username, e.target.jid));
			//连接成功 注册
			register(_user);
			connection.removeEventListener(ConnectionSuccessEvent.CONNECT_SUCCESS, onConnectionSuccess);
    	}
		
	    private function onLogin(e:LoginEvent ):void {
			var p:Presence = new Presence(null, _connection.jid.escaped, null, Presence.SHOW_CHAT, Presence.SHOW_CHAT, 1);
			_connection.send(p);
			
			EventProxy.broadcastEvent(new UserAccessEvent(UserAccessEvent.LOGIN, e.target.username, e.target.jid));
	    }
		
		private function onXiffError(e:XIFFErrorEvent):void{
		 	EventProxy.broadcastEvent(new OpenFireErrorsEvent(OpenFireErrorsEvent.CONNECTION_ERROR, e.errorCode, e.errorMessage));
			//冲突
			if (e.errorMessage == "conflict") {
				//login
				trace("用户存在 登陆...");
				_connection.username = user.username;
				_connection.password = user.password;
				makeConnection();
			}

    	}

	    private function onDisconnect(e:DisconnectionEvent):void{
	    	EventProxy.broadcastEvent(new UserAccessEvent(UserAccessEvent.LOGOUT, e.target.username, e.target.jid));
	    	
	    }
		/**
		 * 保持连接 2min
		 * @param	e
		 */
		private function onKeepAlive(e:TimerEvent):void {
			if (_connection.isLoggedIn()) {
				_connection.sendKeepAlive();
			}
		}
		/**
		 * 断开连接
		 */
		public function disconnect():void {
			connection.disconnect();
		}
		/**
		 * 设置是否保持连接
		 */
		public function set keepAlive(isAlive:Boolean):void {
			if (isAlive) keppAliveTimer.start();
			else keppAliveTimer.stop();
		}
		/**
		 * 注册
		 * @param	username : 用户
		 * @param	password : 密码
		 */
		public function register(_user:User):void {
			var obj:Object = { };
			obj.username = _user.username;
			obj.password = _user.password;
			obj.name = _user.nickname;
			_connection.sendRegistrationFields(obj, null);
			_connection.addEventListener(RegistrationSuccessEvent.REGISTRATION_SUCCESS, onRegistrationSuccess);
			
		}
		
		private function onRegistrationSuccess(e:RegistrationSuccessEvent):void 
		{
			eeDebug.trace("onRegistrationSuccess: " + e.toString());
			_connection.removeEventListener(RegistrationSuccessEvent.REGISTRATION_SUCCESS, onRegistrationSuccess);
			_connection.username = user.username;
			_connection.password = user.password;
			makeConnection();
		}
		/**
		 * 连接数
		 */
		public function get connectedusers():int { 
			return XMPPConnection.openConnections.length; 
		}
		
		public function get connection():XMPPConnection { return _connection; }
		/**
		 * 登陆用户
		 */
		private var _user:User;
		public function get user():User { return _user; }
		
		public static function get instance():XMPPConnection 
		{
			if (_instance == null) _instance = new XMPPConnection();
			return _instance;
		}
		
	}
}