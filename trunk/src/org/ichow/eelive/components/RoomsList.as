package org.ichow.eelive.components 
{
	import flash.events.TimerEvent;
	import org.ichow.eelive.forms.MainForm;
	import org.ichow.eelive.managers.MUCManager;
	import org.ichow.eelive.managers.SparkManager;
	import org.igniterealtime.xiff.core.UnescapedJID;
	/**
	 * ...
	 * @author ichow
	 */
	public class RoomsList extends ItemsList 
	{
		public static const TYPE:String = "roomsList";
		private var roomJID:UnescapedJID;
		
		public function RoomsList() 
		{
			super();
		}
		
		override protected function getitems():void 
		{
			super.getitems();
			roomJID = new UnescapedJID("conference." + SparkManager.connectionManager.connection.domain);
			MUCManager.manager.getConferenceItems(roomJID, onRoom);
		}
		
		private function onRoom(jid:UnescapedJID,chats:Array):void 
		{
			var o:Object = { };
			o.label = "rooms";
			o.items = chats;
			if (chats.length == 0) return;
			init([o], MainForm.FormsWidth, MainForm.FormsHeight, HeadItem.SMALL);
		}
		
		
	}

}