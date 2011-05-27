package org.ichow.event{
	import flash.events.*;
	import flash.utils.*;

	public class EventProxy extends Object {
		private static var _eventSubscriberDic:Dictionary;
		public function EventProxy() {
		}
		public static function subscribeEvent(IEDic:IEventDispatcher, evt:String, fuc:Function):void {
			var ary:Array = null;
			
			if (_eventSubscriberDic==null) {
				_eventSubscriberDic = new Dictionary();
			}
			ary = _eventSubscriberDic[evt];

			if (ary == null) {
				ary = new Array();
				_eventSubscriberDic[evt] = ary;
			}
			
			if (ary.indexOf(IEDic)==-1) {
				ary.push(IEDic);
				IEDic.addEventListener(evt, fuc);
			} else {
				IEDic.addEventListener(evt, fuc);
			}
			
		}

		public static function unsubscribeEvent(IEDic:IEventDispatcher, evt:String, fuc:Function):void {
			var ary:Array=null;
			var no:int=0;
			if (_eventSubscriberDic==null) {
				return;
			}
			ary=_eventSubscriberDic[evt];
			if (ary) {
				no=ary.indexOf(IEDic);
				if (no!=-1) {
					IEDic.removeEventListener(evt, fuc);
					if (! IEDic.hasEventListener(evt)) {
						ary.splice(no, 1);
					}
				}
			}
			return;
		}

		public static function broadcastEvent(evt:Event):void {
			var ary:Array=null;
			var _ary:Array=null;
			var no:int=0;
			var dic:IEventDispatcher=null;
			if (_eventSubscriberDic==null) {
				return;
			}
			ary=_eventSubscriberDic[evt.type];
			_ary = new Array().concat(ary);
			if (ary) {
				no=0;
				while (no < _ary.length) {
					dic=_ary[no];
					dic.dispatchEvent(evt);
					no++;
				}
			}
			return;
		}
	}

}