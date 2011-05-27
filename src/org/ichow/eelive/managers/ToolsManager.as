package org.ichow.eelive.managers 
{
	/**
	 * ...
	 * @author ichow
	 */
	public class ToolsManager 
	{
		//表情
		private static var _facesManager:FacesManager;
		//字体样式
		private static var _fontStyleManager:FontStyleManager;
		//发送图片
		private static var _browseManager:BrowseManager;
		//历史记录
		private static var _historyManager:HistoryManager;
		//资料
		private static var _vcardManager:VCardManager;
		
		static public function get browseManager():BrowseManager 
		{
			if (!_browseManager) 
				_browseManager = new BrowseManager();
			return _browseManager;
		}
		
		static public function get fontStyleManager():FontStyleManager 
		{
			if (!_fontStyleManager) 
				_fontStyleManager = new FontStyleManager();
			return _fontStyleManager;
		}
		
		static public function get facesManager():FacesManager 
		{
			if (!_facesManager) 
				_facesManager = new FacesManager();
			return _facesManager;
		}
		
		static public function get historyManager():HistoryManager 
		{
			if (!_historyManager) 
				_historyManager = new HistoryManager();
			return _historyManager;
		}
		
		static public function get vcardManager():VCardManager 
		{
			if (!_vcardManager)
				_vcardManager = new VCardManager();
			return _vcardManager;
		}
		
	}

}