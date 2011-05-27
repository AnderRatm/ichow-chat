package org.ichow.eelive.managers {
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.core.XMPPConnection;
	import org.igniterealtime.xiff.data.IQ;
	import org.igniterealtime.xiff.data.register.RegisterExtension;
		
	
	public class AccountManager {
		
		private var _connection:XMPPConnection;
		private var _callBackFunction:Function;
		
		public function AccountManager(con:XMPPConnection):void {
			this._connection = con;
		}
		
		public function createAccount(username:String, password:String, callBackFunction:Function):void 
		{
			var iq:IQ = new IQ(new EscapedJID(_connection.server), IQ.SET_TYPE);
			iq.callback = handleRegistration;
			
			var reg:RegisterExtension = new RegisterExtension();
			reg.username = username;
			reg.password = password;
			iq.addExtension(reg);
			
			_callBackFunction = callBackFunction;
			
			_connection.send(iq);
		}
		
		public function handleRegistration(iq:IQ):void {
			_callBackFunction.call(this, iq);
		}
	}
}