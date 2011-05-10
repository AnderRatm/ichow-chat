package org.ichow.eelive.connection
{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import org.ichow.eelive.core.OpenFireRoomEssentials;
	import org.ichow.eelive.core.ServiceDetails;
	
	import org.igniterealtime.xiff.core.Browser;
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.core.XMPPConnection;
	import org.igniterealtime.xiff.data.IQ;
	import org.igniterealtime.xiff.data.disco.InfoDiscoExtension;
	import org.igniterealtime.xiff.data.disco.ItemDiscoExtension;
	import org.ichow.event.EventProxy;
	import org.ichow.eelive.events.*;
	public class ServiceBrowser
	{
		
		private var roomsChecker:Timer;
		
		private var serverJID:EscapedJID;
		private var connection:XMPPConnection;
		
		private var currentService:EscapedJID;
		
		private var browser:Browser;
		
		private var servicesLookUp:Dictionary;
		
		private var roomNotifierID:int;
		
		private const CHAT_SERVICE_NAME:String = "Public Chatrooms";
		
		private static var _instance:ServiceBrowser;
		
		
		public function ServiceBrowser(){
			
		}
		
		public function init(server:EscapedJID, conn:XMPPConnection):void {
			serverJID = server;
			connection = conn;
			
			browser = new Browser(connection);
			
			roomsChecker = new Timer(2000);
			roomsChecker.addEventListener(TimerEvent.TIMER, onRoomsChecker);
			
			servicesLookUp = new Dictionary(true);
		}
		
		protected function onRoomsChecker(e:TimerEvent):void{
			
			browser.getServiceItems(currentService, serviceChatsCall);
			
		}
		
		private function roomPartecipantsChecker():void {
			
			var list:Array = servicesLookUp[currentService] as Array;
			
			for each ( var room:Object in list ) {
				
				browser.getNodeItems(new EscapedJID(room.jid), null, nodeItemsCall);
				
			}
			
		}
		/**
		 * 当前服务器房间列表
		 * @param	jid
		 */
		public function currentChatRooms(jid:EscapedJID):void{
			
			browser.getServiceItems(jid, serviceChatsCall);
			
			currentService = jid;
			roomsChecker.start();
		}
		/**
		 * 获取房间详细资料
		 * @param	jid
		 */
		public function roomDetails(jid:EscapedJID):void{
			
			browser.getServiceInfo(jid, roomDetailsHandler);
			
		}
		
		public function currentServices():void{
			
			browser.getServiceItems(serverJID, serviceItemsCall);
		//	browser.getServiceInfo(serverJID, "serviceInfoCall", this);
			
			
		}
		
		/**
		 * @private
		 */
		public function nodeItemsCall(iq:IQ):void {
			
			var toSend:Boolean;
			
			var extensions:Array = iq.getAllExtensions();
			
			var chats:Array = servicesLookUp[currentService] as Array;
			
			for (var s:int = 0; s < extensions.length; ++s){
				
				var disco:ItemDiscoExtension = extensions[s];
				var items:Array = disco.items;
				
				for each (var room:Object in chats) {
					
					if ( room.jid == disco.service.bareJID ) {
						
						if ( room.users != items.length ) {
							
							room.users = items.length;
							toSend = true;
							
						}
						break;
						
					}
					
				}
				
			}
			
			if(toSend){
				clearTimeout(roomNotifierID);
				setTimeout(function() {
					EventProxy.broadcastEvent(new AvailableRoomsEvent(chats));
					}, 250);
			}
			
		}
		
		/**
		 * @private
		 */		
		public function serviceChatsCall(iq:IQ):void{
			
			var chats:Array = [];
			
            var extensions:Array = iq.getAllExtensions();
            //trace("onServeiceItems. " + iq);
            for (var s:int = 0; s < extensions.length; ++s){
            	
                var disco:ItemDiscoExtension = extensions[s];
                var items:Array = disco.items;
                //trace(">> serviceItemsCall. round " + s + ". items.length: " + items.length);
                for (var i:uint = 0; i < items.length; ++i){
                	
                	chats.push(items[i])
                	
                }
                
            }
            
            var toSend:Boolean;
            
            if(servicesLookUp[currentService]){
            	
            	var sett:* = servicesLookUp[currentService];
            	var neww:* = chats;
            	
            	if(checkItems(chats, servicesLookUp[currentService])){
            		
            		servicesLookUp[currentService] = chats;
            		toSend = true;
            		
            	}
            	
            }else{
            	
            	servicesLookUp[currentService] = chats;
            	toSend = true;
            	
            }
            
			// retrieve nodes for each room
			roomPartecipantsChecker();
            if(toSend){
            	            
				//clearTimeout(roomNotifierID);
				setTimeout(function() { 
					EventProxy.broadcastEvent(new AvailableRoomsEvent(chats));
					}, 250);
            }
			//if (roomsChecker.running) roomsChecker.reset();
		}
		
		private function checkItems(start:Array, compare:Array):Boolean{
			
			var status:Boolean;
			
			if(start.length != compare.length){
				
				return true;
				
			}
			
			for(var i:int = 0; i < start.length; i++){
				
				if(start[i].jid != compare[i].jid || start[i].name != compare[i].name){
					
					status = true;
					break;
					
				} 
				
			}
			
			
			return status;
			
		}
		
		/**
		 * @private
		 */
		public function serviceItemsCall(iq:IQ):void{
			
			var services:Array = [];
			
            var extensions:Array = iq.getAllExtensions();
            
            for (var s:int = 0; s < extensions.length; ++s){
            	
                var disco:ItemDiscoExtension = extensions[s];
                var items:Array = disco.items;
                
                trace(">> serviceItemsCall. round " + s + ". items.length: " + items.length);
                
                for (var i:uint = 0; i < items.length; ++i){
                	
                    var obj:Object = items[i] as Object;
               
                    trace(">> name: " + obj.name + ", jid: " + obj.jid + ", node: " + obj.node + ", action: " + obj.action);
                    if(obj.name == CHAT_SERVICE_NAME){
                    	 
                    	services.push(obj);
                    	
                    }
                    
                }
                
            }
			
			EventProxy.broadcastEvent(new AvailableServicesEvents(services)); 
            
		}
		
		public function roomDetailsHandler(iq:IQ):void{
			
			var essentialsInfo:OpenFireRoomEssentials = new OpenFireRoomEssentials();
			
            var extensions:Array = iq.getAllExtensions();
            
            for (var s:int = 0; s < extensions.length; ++s) {
            	
            	var details:ServiceDetails = new ServiceDetails();
            	
            	details.bareJID =  extensions[s].service.bareJID;
            	details.domain =  extensions[s].service.domain;
            	details.unescapedJID =  extensions[s].service.unescaped;
            	
            	essentialsInfo.details = details;
            	
                var disco:InfoDiscoExtension = extensions[s];
                var features:Array = disco.features;
                
                var identities:Array = disco.identities;
                
                for (var i:int = 0; i < identities.length; ++i){
                	
                    essentialsInfo.name = identities[i].name;
                    essentialsInfo.type = identities[i].type;
                    essentialsInfo.category = identities[i].category;
                    
                    trace("** serviceInfoCall. name: " +  essentialsInfo.name + ", type: " +  essentialsInfo.type + ", category: " + essentialsInfo.category);
                    
                }
                
                if(features.length == 1){
                	
                	essentialsInfo.isPublic = false;
                	break;
                	
                }else{
                	
                	essentialsInfo.isPublic = true;
                	
                }
                
                for (var r:int = 0; r < features.length; ++r){
                	
                	essentialsInfo.isMembersOnly = features[2] == "muc_membersonly";
                	
                	essentialsInfo.isModerated = features[3] == "muc_moderated";
                	
                	essentialsInfo.isPersistent = features[6] == "muc_persistent";
                	
                    trace("** serviceInfoCall. " + r + " [" + features[r] + "]");
                    
                }
                
                
            }
            EventProxy.broadcastEvent(new DetailRoomEvent(essentialsInfo));
            
        }
		
		static public function get instance():ServiceBrowser 
		{
			if (_instance == null) _instance = new ServiceBrowser();
			return _instance;
		}
        
	}
}