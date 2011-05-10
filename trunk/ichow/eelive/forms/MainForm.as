package org.ichow.eelive.forms 
{
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.bit101.components.VBox;
	import com.hexagonstar.util.debug.Debug;
	import flash.display.DisplayObjectContainer;
	import org.ichow.eelive.managers.SparkManager;
	import org.igniterealtime.xiff.data.im.RosterItem;
	import org.igniterealtime.xiff.data.im.RosterItemVO;
	import org.igniterealtime.xiff.data.Presence;
	/**
	 * ...
	 * @author ichow
	 */
	public class MainForm extends BaseForm 
	{
		private var selfName:Label;
		private var selfInfo:Panel;
		
		
		public static const MAIN:String = "main";
		
		protected var _xml:XML;
		
		public function MainForm(
			xml:*= "",
			parent:DisplayObjectContainer = null,
			xpos:Number = 0,
			ypos:Number = 0,
			type:String = ""
			) 
		{
			_xml = new XML(xml);
			super(parent, xpos, ypos, type);
		}
		
		override protected function init():void 
		{
			super.init();
			
		}
		
		override protected function addChildren():void 
		{
			super.addChildren();
			composition.parseXML(_xml);
			
			
			
			selfName = composition.getCompById("SelfName") as Label;
			selfInfo = composition.getCompById("SelfInfo") as Panel
			
			//var l:VBox = composition.getCompById("CanvasList") as VBox;
			//trace(l.numChildren);
		}
		
		public function update():void {
			//Debug.traceObj(SparkManager.me);
			
			selfName.text = SparkManager.me.displayName;
			
			var vo:RosterItemVO = RosterItemVO.get(SparkManager.me.jid);
			Debug.traceObj(vo);
			
			updateStatus();
			
			//var p:Presence = SparkManager.roster.getPresence(vo.jid);
			/*trace("show: " + p.show);
			trace("status: " +p.status);
			trace("from: " + p.from.bareJID);
			trace("to:" +p.to.bareJID);*/
		}
		
		private function updateStatus():void {
			var _cls:Class = SparkManager.presenceManager.getIconFromRosterItem(SparkManager.me) as Class;
			while (selfInfo.content.numChildren > 0) {
				selfInfo.content.removeChildAt(0);
			}
			selfInfo.addChild(new _cls());
		}
		
		override protected function addEventListeners():void 
		{
			super.addEventListeners();
		}
		
		override protected function removeEventListeners():void 
		{
			super.removeEventListeners();
		}
		
		override public function show():void 
		{
			super.show();
			update();
		}
		
		override public function draw():void 
		{
			super.draw();
		}
		
		
		
	}

}