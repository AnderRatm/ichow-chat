package org.ichow.eelive.managers 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import org.ichow.eelive.forms.BaseForm;
	import org.ichow.eelive.forms.LoginForm;
	import org.ichow.eelive.forms.MainForm;
	/**
	 * ...
	 * @author ichow
	 */
	public class FormManager extends EventDispatcher 
	{
		public static const LOGIN:String = "login";
		public static const MAIN:String = "main";
		public static const LOADING:String = "loading";
		
		private static var _loginForm:LoginForm;
		private static var _mainForm:MainForm;
		private static var _canvas:DisplayObjectContainer;
		private static var _xml:XML;
		private static var _forms:Vector.<BaseForm>
		
		
		public function FormManager() 
		{
		}
		
		public static function init(canvas:DisplayObjectContainer, xml:XML):void {
			_canvas = canvas;
			_xml = xml;
			if (!_xml) return;
			_forms = new Vector.<BaseForm>();
			//login
			_loginForm = new LoginForm(_xml.Login, _canvas, 0, 0, FormManager.LOGIN);
			
			//main
			_mainForm = new MainForm(_xml.Main, _canvas, 0, 0, FormManager.MAIN);
			
			_forms.push(_loginForm);
			_forms.push(_mainForm);
			//show
			show();
		}
		
		
		public static function show(status:String="login"):void {
			for (var i:int = 0, len:int = _forms.length; i < len; i++) {
				if (_forms[i].type == status) (_forms[i] as BaseForm).show();
				else (_forms[i] as BaseForm).hide();
			}
		}
		
		static public function get xml():XML 
		{
			return _xml;
		}
		
	}

}