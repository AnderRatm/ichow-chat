package org.ichow.eelive.managers
{
	import com.hexagonstar.util.debug.Debug;
	import flash.events.Event;
	import org.igniterealtime.xiff.bookmark.BookmarkManager;
	import org.igniterealtime.xiff.collections.ArrayCollection;
	import org.igniterealtime.xiff.conference.InviteListener
	import org.igniterealtime.xiff.data.im.RosterItemVO
	import org.igniterealtime.xiff.data.Presence;
	import org.igniterealtime.xiff.events.PropertyChangeEvent;
	import org.igniterealtime.xiff.events.RosterEvent;
	import org.igniterealtime.xiff.im.Roster;
	import org.igniterealtime.xiff.privatedata.PrivateDataManager;
	/**
	 * SparkManager is the core manager used within SparkWeb to access other managers, such as 
	 * Connection or Presence Managers.
	 */
	public class SparkManager {
		private static var _presenceManager:PresenceManager;
		private static var _connectionManager:ConnectionManager;
		private static var _privateDataManager:PrivateDataManager;
		private static var _bookmarkManager:BookmarkManager;
		private static var _sharedGroupsManager:SharedGroupsManager;
		private static var _inviteListener:InviteListener;
		
		private static var _config:Object = {
			autoLogin: false,
			 password: "",
			 username: "",
			   server: "ichow.org",
			 location: "",
	  useExternalAuth: false,
	   connectionType: "socket",
	   			  red: "1",
	   			 blue: "1",
	   			green: "1",
	   		 resource: "ichow"
		};
		
		protected static var _errorHandler:Function;
		protected static var _configProvider:Function;
		
  		private static var _roster:Roster;
		
		//[Bindable]
		private static var _me:RosterItemVO;
		
		public static function get roster():Roster
		{
			if(!_roster)
			{
				_roster = new Roster(connectionManager.connection);
				roster.addEventListener(RosterEvent.ROSTER_LOADED, onRosterLoaded);
			}
			return _roster;
		}
		
		/**
		 * users loaded
		 * @param	e
		 */
		private static function onRosterLoaded(e:RosterEvent):void {
			var items:ArrayCollection = e.target as ArrayCollection;
			//er......save.. i guest
			for each(var i:Object in items) {
				var vo:RosterItemVO = RosterItemVO.get(i.jid, true);
			}
			//update groups
			sharedGroupsManager.retrieveSharedGroups();
			//
			SparkManager.presenceManager.changePresence(Presence.SHOW_CHAT, "在线");
			//get vo
			//var vo:RosterItemVO = RosterItemVO.get(connectionManager.connection.jid);
			//Debug.traceObj(vo);
		}
		
		/**
		 * Returns the PresenceManager initialized for this session.
		 * @return the PresenceManager.
		 */
		public static function get presenceManager():PresenceManager {
			if(!_presenceManager)
				_presenceManager = new PresenceManager();
			
			return _presenceManager;
		}
		
		/**
		 * Returns the ConnectionManager initialized for this session.
		 * @return the ConnectionManager.
		 */
		public static function get connectionManager():ConnectionManager {
			if(!_connectionManager)
				_connectionManager = new ConnectionManager();
			
			return _connectionManager;
		}
		
		public static function get privateDataManager():PrivateDataManager {
			if(!_privateDataManager)
				_privateDataManager = new PrivateDataManager(connectionManager.connection);

			return _privateDataManager;
		}
		
		public static function get bookmarkManager():BookmarkManager {
			if(!_bookmarkManager) 
				_bookmarkManager = new BookmarkManager(privateDataManager);
			
			return _bookmarkManager;
		}
		
		/**
		 * Returns the SharedGroupsManager for this instance
		 * @return the SharedGroupsManager
		 */
		public static function get sharedGroupsManager():SharedGroupsManager {
			if(!_sharedGroupsManager)
				_sharedGroupsManager = new SharedGroupsManager(connectionManager.connection);
			
			return _sharedGroupsManager;
		}
		
		/**
		 * Returns the InviteListener for this instance
		 * @return the InviteListener
		 */
		public static function get inviteListener():InviteListener {
			if(!_inviteListener)
				_inviteListener = new InviteListener(connectionManager.connection);
			
			return _inviteListener;
		}
		
		public static function get errorHandler():Function
		{
			return _errorHandler;
		}
		
		//handler should be a function that takes a String for the error name, a String for the error message, and a boolean indicating whether the error is fatal or not
		public static function set errorHandler(handler:Function):void
		{
			_errorHandler = handler;
		}
		
		public static function displayError(name:String, message:String, fatal:Boolean = false):void
		{
			errorHandler(name, message, fatal);
		}
		
		//provider should be a function that takes a String and returns a String, allowing lookup by key
		public static function set configProvider(provider:Function):void
		{
			_configProvider = provider;
		}
		
		static public function get me():RosterItemVO 
		{
			return _me;
		}
		
		static public function set me(value:RosterItemVO):void 
		{
			_me = value;
		}
		
		
		
		public static function getConfigValueForKey(key:String):String
		{
			key = key.toLowerCase();
			var result:String;
			if(_configProvider != null)
			{
				result = _configProvider(key);
			}
			//trace(key +" : " + result);
			return result ? result : _config[key];
		}
		
		public static function logout():void
		{
			// We may want to implement a way to logout without restarting the entire application (especially for SparkAir). SW-73
			// All of the managers would deinitialize and unregister their event listeners. Then SparkWeb would show its login dialog.
			connectionManager.logout();
			_roster.removeEventListener(RosterEvent.ROSTER_LOADED, onRosterLoaded);
			_roster = null;
			_connectionManager = null;
			_sharedGroupsManager = null;
		}
	}
}
