package org.ichow.eelive 
{
	import com.bit101.components.Label;
	import com.bit101.components.ProgressBar;
	import com.bit101.components.Style;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.CSSLoader;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.display.ContentDisplay;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.XMLLoader;
	import com.greensock.loading.SWFLoader;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.text.StyleSheet;
	import flash.utils.getDefinitionByName;
	import org.ichow.eelive.managers.FormManager;
	import org.ichow.eelive.managers.MessageManager;
	import org.ichow.eelive.managers.SparkManager;
	import org.ichow.eelive.utils.XMLUtils;
	import org.ichow.eelive.forms.*;
	/**
	 * ...
	 * @author ...
	 */
	[SWF(width = "200", height = "600")]
	public class Main extends Sprite 
	{
		private static var _config:Object;
		
		private static var def_config:Object = {
			autoLogin: false,
			 password: "admin",
			 username: "admin",
			   server: "localhost",
			   domain: "LBDZ-20110506RL",
			     port: "5222",
			 location: "",
	  useExternalAuth: false,
	   connectionType: "eelive",
	   			  red: "1",
	   			 blue: "1",
	   			green: "1",
	   		 resource: "eelive"
		};
		
		private var _forms:Object;
		
		private var _xml:XML;
		private var _skin:SWFLoader;
		private var _css:StyleSheet;
		
		private var canvas:Sprite;
		private var _progress:ProgressBar;
		private var _percent:Label;
		
		public function Main() 
		{
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event=null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			//get parameters
			if (stage.loaderInfo.parameters!=null) {
				var obj:Object = stage.loaderInfo.parameters;
				Main._config = obj;
			}
			
			//load config xml
			LoaderMax.activate([CSSLoader, SWFLoader, XMLLoader]);
			
			canvas = new Sprite();
			addChild(canvas);
			
			_progress = new ProgressBar(canvas);
			_progress.move(_progress.width / -2, _progress.height / -2);
			_progress.value = 0;
			_percent = new Label(canvas);
			_percent.move(_percent.width / -2, _progress.height);
			_percent.text = "0%";
			
			var url:String = "assets/xml/config.xml";
			var l:XMLLoader = new XMLLoader(url, { name:"config", onComplete:onConfigComplete, onProgress:onConfigProgress } );
			l.load(true);
			
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		private function onResize(e:Event=null):void 
		{
			var w:int = Math.floor(stage.stageWidth);
			var h:int = Math.floor(stage.stageHeight);
			canvas.graphics.clear();
			canvas.graphics.beginFill(0xFFFFFF, .2);
			canvas.graphics.drawRect(w / -2, h / -2, w, h);
			canvas.graphics.endFill();
			canvas.x = w / 2;
			canvas.y = h / 2;
		}
		
		/**
		 * config progress
		 * @param	e
		 */
		private function onConfigProgress(e:LoaderEvent):void 
		{
			var l:DataLoader = e.target as DataLoader;
			_progress.value = l.progress;
			var s:String = l.progress * 100 + "";
			_percent.text = s.substr(0, 2) + "%";
			
		}
		/**
		 * 初始化窗口
		 */
		private function initForms():void 
		{
			canvas.removeChild(_progress);
			canvas.removeChild(_percent);
			
			//Style.embedFonts = false;
			
			_forms = new Object();
			
			SparkManager.configProvider = _configProvider;
			MessageManager.init();
			
			FormManager.init(canvas, _xml);
		}
		
		/**
		 * config xml complete
		 * @param	e
		 */
		private function onConfigComplete(e:LoaderEvent):void 
		{
			//composition
			_xml = new XML(LoaderMax.getContent("config").composition);
			//trace(_xml);
			//skin swf
			_skin = LoaderMax.getLoader("skinSWF");
			//skin css
			_css = LoaderMax.getContent("skinCSS");
			
			initForms();
		}
		
		/**
		 * get parametrs
		 * @param	key
		 * @return
		 */
		private function _configProvider(key:String):String
		{
			return _config[key] != null?_config[key]:def_config[key];
		}
		
		/**
		 * 
		 */
		LoginForm;
		
	}

}