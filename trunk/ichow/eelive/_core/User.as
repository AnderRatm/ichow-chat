package org.ichow.eelive.core
{
	public class User
	{
		public var username:String;
		public var password:String;
		public var nickname:String;
		/**
		 * Note that the username should include @ and the server (which
		 * might not be the same as the one where connection is made)
		 * @param	username
		 * @param	password
		 */
		public function User( username:String=null, password:String=null,nickname:String=null)
		{
			this.username = username;
			this.password = password;
			this.nickname = nickname;
		}
		
	}
}
