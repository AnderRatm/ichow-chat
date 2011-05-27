package org.ichow.eelive.managers 
{	
	import com.hexagonstar.util.debug.Debug;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.system.Security;
	import flash.utils.Timer;
	import org.igniterealtime.xiff.events.OutgoingDataEvent;
	
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.core.XMPPBOSHConnection;
	import org.igniterealtime.xiff.core.XMPPConnection;
	import org.igniterealtime.xiff.core.XMPPTLSConnection;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.data.Presence;
	import org.igniterealtime.xiff.data.events.MessageEventExtension;
	import org.igniterealtime.xiff.data.im.RosterItemVO;
	import org.igniterealtime.xiff.events.LoginEvent;
	
	
	/**
	 * Responsible for the delegation of messages and presences.
	 */
	public class ConnectionManager extends EventDispatcher 
	{
		private var con:XMPPConnection;
		private var keepAliveTimer:Timer;
		private var _lastSent:int = 0;
		
		/**
		 * Creates a new instance of the ConnectionManager.
		 */
		public function ConnectionManager():void 
		{
			var type:String = SparkManager.getConfigValueForKey("connectionType");
			switch(type)
			{
				case "http":
					con = new XMPPBOSHConnection(false);
					break;
				case "https":
					con = new XMPPBOSHConnection(true);
					break;
				case "socket":
				default:
					con = new XMPPConnection();
			}
			if(SparkManager.getConfigValueForKey("port") != null)
				con.port = Number(SparkManager.getConfigValueForKey("port"));
		}
		
		/**
		 * Log into server.
		 * @param username the username of the account.
		 * @param password the user password.
		 * @param domain the server domain.
		 * @param resource an optional resource to connect with
		 * @param server an optional specific server hostname to connect to (otherwise domain will be used for connection)
		 * @param port an optional specific port to connect to (otherwise default will be used, 5222 for tcp, 8080 for http binding, 8443 for https binding)
		 */
		public function login(username:String, password:String, domain:String, resource:String="sparkweb", server:String=null):void 
		{
			Security.loadPolicyFile("xmlsocket://" + domain + ":5299");
			
			con.username = username;
			con.password = password;
			con.domain = domain;
			con.resource = resource;
			if (server)
				con.server = server;
				
			con.removeEventListener(OutgoingDataEvent.OUTGOING_DATA, packetSent); 
			con.addEventListener(OutgoingDataEvent.OUTGOING_DATA, packetSent);
			
			con.connect(XMPPConnection.STREAM_TYPE_STANDARD);
			
			con.removeEventListener(LoginEvent.LOGIN, getMe);
			con.addEventListener(LoginEvent.LOGIN, getMe);
			
			if(keepAliveTimer)
				keepAliveTimer.stop();
			keepAliveTimer = new Timer(2 * 60 * 1000);
			keepAliveTimer.addEventListener(TimerEvent.TIMER, checkKeepAlive);
			//keepAliveTimer.start();
			
		}
		
		/**
		 * Logs out of the server.
		 */
		public function logout():void
		{
			Debug.trace("logout: ", Debug.LEVEL_WARN);
			keepAliveTimer.reset();
			keepAliveTimer.removeEventListener(TimerEvent.TIMER, checkKeepAlive);
			keepAliveTimer = null;
			// Send an unavilable presence
			var recipient:EscapedJID = new EscapedJID(connection.domain);
			var unavailablePresence:Presence = new Presence(recipient, null, Presence.TYPE_UNAVAILABLE, null, "登出");
			con.send(unavailablePresence);
			
			// Now disconnect
			con.disconnect();
		}
		
		private function getMe(evt:LoginEvent):void
		{
			SparkManager.me = RosterItemVO.get(con.jid, true);
			keepAliveTimer.start();
			
			dispatchEvent(new Event("login"));
		}
		
		/**
		 * Do a simple keep alive.
		 */
		public function checkKeepAlive(event:TimerEvent):void 
		{
			con.sendKeepAlive();
		}
		
		public function packetSent(event:Event):void {
			//trace("packetSent: " + event.toString());
		}
		
		
		/**
		 * Returns the XMPPConnection used for this session.
		 * @return the XMPPConnection.
		 */	
		public function get connection():XMPPConnection {
			return con;
		}
		
		/**
		 * Sends a single message to a user.
		 * @param jid the jid to send the message to.
		 * @param body the body of the message to send.
		 */
		public function sendMessage(jid:UnescapedJID, body:String):void 
		{
			if (!con.isLoggedIn()) return;
			var message:Message = new Message();
			message.addExtension(new MessageEventExtension());
			message.to = jid.escaped;
			message.body = body;
			message.type = Message.TYPE_CHAT;
			con.send(message);
			
		}
	}
}
