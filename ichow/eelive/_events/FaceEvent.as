package org.ichow.eelive.events
{
	import flash.events.Event;
	import org.ichow.eelive.view.FlowPanel;
	
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class FaceEvent extends Event 
	{
		public static const ADD_FACE:String = "addFace";
		
		public var face:Object;
		public var flow:FlowPanel;
		
		public function FaceEvent(type:String, face:Object = null,flow:FlowPanel=null, bubbles:Boolean = false, cancelable:Boolean = false) {
			
			super(type, bubbles, cancelable);
			this.flow = flow;
			this.face = face;
			
		}
		
	}

}