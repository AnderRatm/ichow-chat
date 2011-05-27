package org.ichow.eelive.managers
{
	import adobe.utils.CustomActions;
	import com.hexagonstar.util.debug.Debug;
	import flash.xml.XMLNode;
	import org.igniterealtime.xiff.data.muc.MUCAdminExtension;
	import org.igniterealtime.xiff.data.Presence;
	import org.igniterealtime.xiff.collections.ArrayCollection;
	import org.igniterealtime.xiff.core.XMPPConnection;
	import org.igniterealtime.xiff.data.IQ;
	import org.igniterealtime.xiff.data.XMPPStanza;
	import org.igniterealtime.xiff.data.im.RosterGroup;
	import org.igniterealtime.xiff.data.sharedgroups.SharedGroupsExtension;
	
	/**
	 * Retrieves from the server and manages locally, a list of shared groups.
	 */
	public class SharedGroupsManager
	{
		private var sharedGroups:ArrayCollection;
		private var connection:XMPPConnection;
		

		public function SharedGroupsManager(connection:XMPPConnection):void
		{
			sharedGroups = new ArrayCollection();
			this.connection = connection;
		}
		
		/**
		 * Sends an IQ to the server to retrieve the current list of shared
		 * groups.
		 */
		public function retrieveSharedGroups():void
		{
			var iq:IQ = new IQ(null, IQ.TYPE_GET, XMPPStanza.generateID("get_shared_groups_"), _receivedSharedGroups);
			iq.addExtension(new SharedGroupsExtension());
			connection.send(iq);
		}
		
		public function _receivedSharedGroups(resultIQ:IQ):void
		{
			var iqNode:XMLNode = resultIQ.getNode();
			if (!iqNode)
				return;
			
			var sharedgroupNode:XMLNode = iqNode.firstChild;
			if (!sharedgroupNode)
				return;
			
			// Store the shared groups we received from the server
			for each(var groupNode:XMLNode in sharedgroupNode.childNodes)
			{
				if (groupNode.firstChild != null)
				{
					if (!sharedGroups.contains(groupNode.firstChild.nodeValue))
					{
						sharedGroups.addItem(groupNode.firstChild.nodeValue);
					}
				}
			}
			//trace("sharedGroups: "+sharedGroups);
			updateLocalGroups();
		}
		/**
		 * Updates the collection of our locally cached groups, setting their
		 * 'shared' flag to indicate if they are shared groups or not. 
		 */
		public function updateLocalGroups():void
		{
			_groups = new Vector.<RosterGroup>();
			for each(var sharedGroupName:String in sharedGroups)
			{
				
				var rosterGroup:RosterGroup = SparkManager.roster.getGroup(sharedGroupName);
				if (rosterGroup) {
					rosterGroup.shared = true;
					_groups.push(rosterGroup);
					Debug.trace(rosterGroup.label + " : " + rosterGroup.items);
				}
			}
		}
		/**
		 * get groups array
		 * ichow
		 * 2011-05-10
		 */
		private var _groups:Vector.<RosterGroup>;
		public function get groups():Vector.<RosterGroup>
		{
			return _groups;
		}
		
		public function set groups(value:Vector.<RosterGroup>):void 
		{
			_groups = value;
		}
		
		
	}
}
