/*
 *This file is part of SparkWeb.
 *
 *SparkWeb is free software: you can redistribute it and/or modify
 *it under the terms of the GNU Lesser General Public License as published by
 *the Free Software Foundation, either version 3 of the License, or
 *(at your option) any later version.
 *
 *SparkWeb is distributed in the hope that it will be useful,
 *but WITHOUT ANY WARRANTY; without even the implied warranty of
 *MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *GNU Lesser General Public License for more details.
 *
 *You should have received a copy of the GNU Lesser General Public License
 *along with SparkWeb.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.ichow.eelive.managers
{
	import com.hexagonstar.util.debug.Debug;
	import org.igniterealtime.xiff.conference.Room;
	import org.igniterealtime.xiff.core.Browser;
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.IQ;
	import org.igniterealtime.xiff.data.disco.InfoDiscoExtension;
	import org.igniterealtime.xiff.data.disco.ItemDiscoExtension;
	import org.igniterealtime.xiff.data.muc.MUCExtension;
	import org.igniterealtime.xiff.events.RoomEvent;
	
	public class MUCManager
	{
		private var observers:Object = { };
		private var serviceJIDsToServerJIDs:Object = {};
		private var rooms:Object = {};
		
		private static var sharedInstance:MUCManager = null;
		
		private static var broswer:Browser;
		
		public static function get manager():MUCManager
		{
			if(!sharedInstance)
				sharedInstance = new MUCManager();
			return sharedInstance;
		}
		
		public function MUCManager()
		{
			super();
			broswer = new Browser(SparkManager.connectionManager.connection);
		}
		
		public function getRoom(roomJID:UnescapedJID, name:String=null):Room
		{
			var room:Room = rooms[roomJID.bareJID];
			if(!room)
			{
				room = new Room(SparkManager.connectionManager.connection);
				room.roomJID = roomJID;
				room.addEventListener(RoomEvent.ROOM_LEAVE, function(evt:RoomEvent):void {
					rooms[roomJID.bareJID] = null;
				});
				if(name)
					room.roomName = name;
				rooms[roomJID.bareJID] = room;
			}
			return room;
		}
		
		public function findConferenceService(server:UnescapedJID, callback:Function):void
		{
			if(!observers[server.toString()])
			{
				observers[server.toString()] = [];
			}
			observers[server.toString()].push(callback);
			broswer.getServiceInfo(server.escaped, handleSpeculativeInfoReply);
		}
		
		public function handleSpeculativeInfoReply(iq:IQ):void
		{
			var extensions:Array = iq.getAllExtensionsByNS(InfoDiscoExtension.NS);
			if (!extensions || extensions.length < 1)
				return;
				
			for each(var feature:String in extensions[0].features)
			{
				if (feature == MUCExtension.NS)
				{
					
					for each(var callback:Function in observers[iq.from.unescaped.toString()])
					{
						callback(iq.from.bareJID);
						serviceInfoCall(iq);
					}
					return;
				}
			}
			//if it wasn't a conference server, we need to get the list of services on this server
			new Browser(SparkManager.connectionManager.connection).getServiceItems(iq.from, handleServiceList);
		}
		
		public function handleServiceList(iq:IQ):void
		{
			var extensions:Array = iq.getAllExtensionsByNS(ItemDiscoExtension.NS);
			if (!extensions || extensions.length < 1) 
				return;
				
			var extension:ItemDiscoExtension = extensions[0];
			
			var server:UnescapedJID = iq.from.unescaped;
			for each(var item:Object in extension.items) 
			{
				serviceJIDsToServerJIDs[item.jid] = server;
				new Browser(SparkManager.connectionManager.connection).getServiceInfo(new EscapedJID(item.jid), handleInfoReply);
			}
		}
		
		public function handleInfoReply(iq:IQ):void
		{
			var extensions:Array = iq.getAllExtensionsByNS(InfoDiscoExtension.NS);
			if (!extensions || extensions.length < 1)
				return;
			
			for each(var feature:String in extensions[0].features)
			{
				if (feature == MUCExtension.NS)
				{
					var server:UnescapedJID = serviceJIDsToServerJIDs[iq.from.toString()];
					for each(var callback:Function in observers[server.toString()])
					{
						callback(iq.from.unescaped);
					}
					return;
				}
			}
		}
		/**
		 * get server items and callback
		 * ichow
		 * 2011-05-10
		 * @param	server			:	conference.server
		 * @param	callback		:	callback function(jid,array)
		 */
		private var itemsServer:UnescapedJID;
		private var itemsCallback:Function;
		
		public function getConferenceItems(server:UnescapedJID, callback:Function):void {
			itemsServer = server;
			itemsCallback = callback;
			broswer.getServiceItems(server.escaped, serviceChatsCall);
		}
		public function getConferenceServices(server:UnescapedJID, callback:Function):void {
			
		}
		/**
		 * Browser serviceInfoCall callback
		 * @param	iq
		 */
		public function serviceInfoCall(iq:IQ):void {
			var infos:Array = [];
            var extensions:Array = iq.getAllExtensions();
            trace("serviceInfoCall. " + iq);
            for (var s:int = 0; s < extensions.length; ++s){
                var disco:InfoDiscoExtension = extensions[s];
                var identities:Array = disco.identities;
                trace(">> serviceInfoCall. round " + s + ". identities.length: " + identities.length);
                for (var i:uint = 0; i < identities.length; ++i) {
					trace("** serviceInfoCall. name: " +  identities[i].name + ", type: " +  identities[i].type + ", category: " + identities[i].category);
					infos.push(identities[i])
                }
            }
        }
		/**
		 * Broswer getServiceItems callback
		 * @param	iq
		 */
		public function serviceChatsCall(iq:IQ):void{
			var chats:Array = [];
            var extensions:Array = iq.getAllExtensions();
           // trace("serviceChatsCall. " + iq);
            for (var s:int = 0; s < extensions.length; ++s){
                var disco:ItemDiscoExtension = extensions[s];
                var items:Array = disco.items;
				for (var i:uint = 0; i < items.length; ++i) {
					var obj:Object = { };
					trace("jid: " +items[i].jid + "->" + items[i].jid as UnescapedJID);
					obj.jid = new UnescapedJID(items[i].jid.toString());
					obj.displayName = items[i].name;
					var room:Room = new Room()
					obj.status = "[0]";
					chats.push(obj)
                }
            }
			if (itemsCallback != null) itemsCallback(itemsServer, chats);
		}
	}
}