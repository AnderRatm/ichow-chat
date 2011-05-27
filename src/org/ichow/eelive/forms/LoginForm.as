package org.ichow.eelive.forms {
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.hexagonstar.util.debug.Debug;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import org.ichow.eelive.managers.FormManager;
	import org.ichow.eelive.managers.MessageManager;
	import org.ichow.eelive.managers.SparkManager;
	import org.igniterealtime.xiff.data.Presence;

	/**
	 * ...
	 * @author ichow
	 */
	public class LoginForm extends BaseForm {

		private var loginButton:PushButton;
		private var usernameIT:InputText;
		private var passwordIT:InputText;
		private var infoLabel:Label;

		private var loginTimer:Timer;
		protected var _xml:XML;
		private var _defLabel:String;

		public function LoginForm(xml:* = "", parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, type:String = ""){
			_xml = new XML(xml);
			super(parent, xpos, ypos, type);
		}

		protected override function init():void {
			super.init();
			loginTimer = new Timer(1100, 5);
		}

		protected override function addChildren():void {
			super.addChildren();
			composition.parseXML(_xml);

			usernameIT = composition.getCompById("usernameIT") as InputText;
			passwordIT = composition.getCompById("passwordIT") as InputText;
			passwordIT.password = true;
			usernameIT.restrict = passwordIT.restrict = "^ ";
			usernameIT.text = SparkManager.getConfigValueForKey("username");
			passwordIT.text = SparkManager.getConfigValueForKey("password");
			//
			infoLabel = composition.getCompById("loginInfo") as Label;
			//login button
			loginButton = composition.getCompById("loginButton") as PushButton;
			_defLabel = loginButton.label;
			//check auto login
			setTimeout(function():void{
					if (SparkManager.getConfigValueForKey("autoLogin") == "true"){
						onLoginMouseClick(null);
					}
				}, 100);
		}

		override protected function addEventListeners():void {
			super.addEventListeners();
			loginTimer.addEventListener(TimerEvent.TIMER, onTimer);
			loginTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			SparkManager.connectionManager.addEventListener(FormManager.LOGIN, onLogin);
			loginButton.addEventListener(MouseEvent.CLICK, onLoginMouseClick);
		}

		override protected function removeEventListeners():void {
			super.removeEventListeners();
			loginTimer.removeEventListener(TimerEvent.TIMER, onTimer);
			loginTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			SparkManager.connectionManager.removeEventListener(FormManager.LOGIN, onLogin);
			loginButton.removeEventListener(MouseEvent.CLICK, onLoginMouseClick);
		}

		private function onTimer(e:TimerEvent):void {
			loginButton.label += ".";
		}

		private function onTimerComplete(e:TimerEvent):void {
			loginTimer.reset();
			loginButton.label = _defLabel;
			loginButton.enabled = true;
		}

		private function onLogin(e:Event):void {
			removeEventListeners();
			loginTimer.reset();
			loginButton.label = _defLabel;
			loginButton.enabled = true;
			
			MessageManager.instance;
			//SparkManager.presenceManager.changePresence(Presence.SHOW_CHAT, "available");
			FormManager.show(FormManager.MAIN);
		}

		private function onLoginMouseClick(e:MouseEvent):void {
			if (usernameIT.text == "" || passwordIT.text == ""){
				infoLabel.text = "input again";
				return;
			}

			loginButton.enabled = false;
			loginButton.label = _defLabel;
			loginTimer.start();

			var d:String = SparkManager.getConfigValueForKey("domain");
			var r:String = SparkManager.getConfigValueForKey("resource");
			var s:String = SparkManager.getConfigValueForKey("server");
			SparkManager.connectionManager.login(usernameIT.text, passwordIT.text, d, r, s);
		}

	}

}