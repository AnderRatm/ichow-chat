package org.ichow.eelive._view 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.ichow.components.InputText;
	import org.ichow.components.Label;
	import org.ichow.components.PushButton;
	import org.ichow.components.Window;
	import org.ichow.event.EventProxy;
	import org.ichow.settings.eeLiveSettings;
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class LoginView extends BaseView 
	{
		public static const LOGGING:String = "logging";
		
		public function LoginView(	parent:DisplayObjectContainer = null, 
									xpos:Number = 0, 
									ypos:Number =  0, 
									width:uint = 0,
									height:uint = 0,
									type:String = "view"
									)
		{
			super(parent, xpos, ypos, width, height, type);
		}
		
		private var logWin:Window;
		private var usn_lab:Label;
		private var usn_txt:InputText;
		private var psd_lab:Label;
		private var psw_txt:InputText;
		private var svi_lab:Label;
		private var svi_txt:InputText;
		private var loginBtn:PushButton;
		private var registerBtn:PushButton;
		
		override protected function addChildren():void
		{
			super.addChildren();
			
			logWin = new Window(this, 0, 0, "eeLive");
			logWin.setSize(170, 170);
			logWin.draggable = false;
			
			usn_lab = new Label(logWin, 10, 20, "  用户:");
			usn_txt = new InputText(logWin, 10, 20);
			usn_txt.x = logWin.width - usn_txt.width - 10;
			
			usn_txt.text = eeLiveSettings.flashvars.username != null?eeLiveSettings.flashvars.username:eeLiveSettings.USER_NAME;
			
			psd_lab = new Label(logWin, 10, 50, "  密码:");
			psw_txt = new InputText(logWin, 10, 50);
			psw_txt.x = logWin.width - psw_txt.width - 10;
			psw_txt.password = true;
			
			psw_txt.text = eeLiveSettings.flashvars.password != null?eeLiveSettings.flashvars.password:eeLiveSettings.PASS_WORD;
			
			svi_lab = new Label(logWin, 10, 80, "服务器:");
			svi_txt = new InputText(logWin, 10, 80);
			svi_txt.x = logWin.width - svi_txt.width - 10;
			svi_txt.text = eeLiveSettings.flashvars.server != null?eeLiveSettings.flashvars.server:eeLiveSettings.SERVER_IP;
			
			loginBtn = new PushButton(logWin, 10, 120, "登  陆", onLoginMouseClick);
			loginBtn.x = (logWin.width - loginBtn.width) / 2;
			loginBtn.width = 70;
			
			logWin.x = Math.floor((_width - logWin.width) * .5);
			logWin.y = Math.floor((_height - logWin.height) * .5);
			
			if (eeLiveSettings.flashvars.nickname != null) eeLiveSettings.NICK_NAME = eeLiveSettings.flashvars.nickname;
			
		}
		
		override public function draw():void
		{
			super.draw();
			
		}
		
		public function onLoginMouseClick(e:MouseEvent):void {
			eeLiveSettings.USER_NAME = usn_txt.text;
			eeLiveSettings.PASS_WORD = psw_txt.text;
			eeLiveSettings.SERVER_IP = svi_txt.text;
			EventProxy.broadcastEvent(new Event(LOGGING));
		}
		
	}

}