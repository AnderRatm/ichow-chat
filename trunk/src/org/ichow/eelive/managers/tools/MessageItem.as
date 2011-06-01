package org.ichow.eelive.managers.tools 
{
	import com.bit101.components.Label;
	import com.bit101.components.ListItem;
	import flash.display.DisplayObjectContainer;
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	/**
	 * ...
	 * @author ichow
	 */
	public class MessageItem extends ListItem 
	{
		private var _menu:ContextMenu;
		private var _del:ContextMenuItem;
		private var _resume:ContextMenuItem;
		protected var _content:Label;
		public function MessageItem(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, data:Object = null)
		{
			super(parent, xpos, ypos, data);
		}
		
		override protected function addChildren():void 
		{
			super.addChildren();
			_content = new Label(this, 5, 22);
			_content.draw();
			//add menu;
			addMenus();
		}
		
		protected function addMenus():void 
		{
			_menu = new ContextMenu();
			_menu.hideBuiltInItems();
			_del = new ContextMenuItem("禁止");
			_resume = new ContextMenuItem("恢复");
			_resume.visible = false;
			_menu.customItems.push(_del);
			_menu.customItems.push(_resume);
			_del.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onDeleteMenu);
			_resume.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onResumeMenu);
			this.contextMenu = _menu;
		}
		
		protected function onDeleteMenu(e:ContextMenuEvent):void 
		{
			if(data && data.id)
			{
				_resume.visible = true;
				_del.visible = false;
				this.alpha = .2;
				//HistoryManager.instance.screen(data.id);
			}
		}
		
		protected function onResumeMenu(e:ContextMenuEvent):void 
		{
			if(data && data.id)
			{
				_resume.visible = false;
				_del.visible = true;
				this.alpha = 1;
				//HistoryManager.instance.resume(data.id);
			}
		}
		
		override public function draw():void 
		{
			super.draw();
			_label.y = 2;
			if (_data == null) return;
			if(_data is String)
			{
                _content.text = _data as String;
			}
			else if(_data.hasOwnProperty("content") && _data.content is String)
			{
				_content.text = _data.content;
			}
			else
            {
				_content.text = _data.toString();
			}
		}
		
		
	}

}