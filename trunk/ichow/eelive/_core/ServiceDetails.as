package org.ichow.eelive.core
{
	import org.igniterealtime.xiff.core.UnescapedJID;
	
	public class ServiceDetails
	{
		
		private var _bareJID:String;
		
		public function get bareJID():String{
			
			return _bareJID;
			
		}
		
		public function set bareJID(value:String):void{
			
			_bareJID = value;
			
		}
		
		private var _domain:String;
		
		public function get domain():String{
			
			return _domain;
			
		}
		
		public function set domain(value:String):void{
			
			_domain = value;
			
		}
		
		private var _unescapedJID:UnescapedJID;
		
		public function get unescapedJID():UnescapedJID{
			
			return _unescapedJID;
			
		}
		
		public function set unescapedJID(value:UnescapedJID):void{
			
			_unescapedJID = value;
			
		}
		

	}
}

