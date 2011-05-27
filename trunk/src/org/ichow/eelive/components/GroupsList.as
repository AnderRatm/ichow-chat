package org.ichow.eelive.components 
{
	import com.hexagonstar.util.debug.Debug;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.ichow.eelive.forms.MainForm;
	import org.ichow.eelive.managers.SparkManager;
	import org.ichow.eelive.managers.UserSearchManager;
	import org.igniterealtime.xiff.data.im.RosterExtension;
	import org.igniterealtime.xiff.data.im.RosterItem;
	import org.igniterealtime.xiff.data.im.RosterItemVO;
	import org.igniterealtime.xiff.data.IQ;
	import org.igniterealtime.xiff.events.RosterEvent;
	import org.igniterealtime.xiff.im.Roster;
	/**
	 * ...
	 * @author ichow
	 */
	public class GroupsList extends ItemsList 
	{
		private var _roster:Roster;
		public static const TYPE:String = "groupsList";
		
		public function GroupsList() 
		{
			super();
			setupRoster();
		}
		/**
		 * 设置列表
		 */
		private function setupRoster():void 
		{
			_roster = SparkManager.roster;
			clearRoster();
			_roster.addEventListener(RosterEvent.USER_PRESENCE_UPDATED, onRosterPresenceUpdated);
			_roster.addEventListener(RosterEvent.USER_SUBSCRIPTION_UPDATED, onRosterSubscriptionUpdated);
			_roster.addEventListener(RosterEvent.USER_REMOVED, onRoster);
			_roster.addEventListener(RosterEvent.USER_AVAILABLE, onRoster);
			_roster.addEventListener(RosterEvent.SUBSCRIPTION_DENIAL, onRoster);
			_roster.addEventListener(RosterEvent.SUBSCRIPTION_REQUEST, onRoster);
		}
		/**
		 * 移除事件
		 */
		private function clearRoster():void {
			if (!_roster) return;
			_roster.removeEventListener(RosterEvent.USER_PRESENCE_UPDATED, onRosterPresenceUpdated);
			_roster.removeEventListener(RosterEvent.USER_SUBSCRIPTION_UPDATED, onRosterSubscriptionUpdated);
			_roster.removeEventListener(RosterEvent.USER_REMOVED, onRoster);
			_roster.removeEventListener(RosterEvent.USER_AVAILABLE, onRoster);
			_roster.removeEventListener(RosterEvent.SUBSCRIPTION_DENIAL, onRoster);
			_roster.removeEventListener(RosterEvent.SUBSCRIPTION_REQUEST, onRoster);
		}
		/**
		 * 
		 * @param	e
		 */
		private function onRoster(e:RosterEvent):void 
		{
			Debug.trace("onRoster: " + e.toString());
			Debug.trace("data: " + e.data);
		}
		/**
		 * 更新列表
		 * @param	e
		 */
		private function onRosterSubscriptionUpdated(e:RosterEvent):void 
		{
			Debug.trace("onRosterSubscriptionUpdated: " + e.toString());
			Debug.trace("type: "+e.type);
			Debug.trace("data: " + e.data);
			Debug.trace("jid: " + e.jid);
			SparkManager.sharedGroupsManager.groups = null;
			getitems();
		}
		/**
		 * 更新用户信息
		 * @param	e
		 */
		private function onRosterPresenceUpdated(e:RosterEvent):void 
		{
			Debug.trace("onRosterPresenceUpdated: " + e.toString());
			var vo:RosterItemVO = e.data as RosterItemVO;
			if (!vo.jid) return;
			Debug.traceObj(vo);
			var ary:Array = ItemsList.getItem(vo.jid.escaped.bareJID);
			for (var i:Object in ary) {
				var head:HeadItem = ary[i];
				if (!head || !vo) continue;
				head.status = vo.status;
				head.isAvailable = vo.online;
				Debug.trace(vo.displayName + ": " + vo.status + " " + vo.online, 5);
			}
		}
		/**
		 * 获取列表
		 */
		override protected function getitems():void 
		{
			super.getitems();
			SparkManager.roster.fetchRoster();
			checkTimer.start();
		}
		
		override protected function onCheckTimer(e:TimerEvent):void 
		{
			super.onCheckTimer(e);
			if (SparkManager.sharedGroupsManager.groups) 
			{
				if (checkTimer.running) checkTimer.reset();
				init(SparkManager.sharedGroupsManager.groups, MainForm.FormsWidth, MainForm.FormsHeight, HeadItem.BIG);
				
			}
		}
		
	}

}