package {
	import com.bit101.components.Style;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.CSSLoader;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.SWFLoader;
	import com.greensock.loading.XMLLoader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security;
	import flash.text.StyleSheet;
	import flash.utils.setTimeout;
	import org.ichow.eelive.managers.FormManager;
	import org.ichow.eelive.managers.SparkManager;
	import org.ichow.eelive.managers.ToolsManager;
	import org.ichow.eelive.managers.VCardManager;
	import org.ichow.eelive.utils.ChatStyle;

	/**
	 * ...
	 * @author ichow
	 */
	[Frame(factoryClass="Preloader")]
	[SWF(width="500",height="600")]
	public class Main extends Sprite {
		public static const VERSION:String = "2.012.2";
		//默认配置
		private static var def_config:Object = {
				  autologin	: "false", 
				   password	: "iccc", 
				   username	: "iccc", 
					 server	: "172.16.165.89", 
					 domain	: "ichow", 
					   port	: "5222", 
				   location	: "", 
			useexternalauth	: false, 
			 connectiontype	: "def", 
				   resource	: "eelive"};

		private static var _config:Object;
		
		private var _forms:Object;
		private var _xml:XML;
		private var _headXML:XML;
		private var _facesXML:XML;
		private var _skin:SWFLoader;
		private var _css:StyleSheet;
		private var canvas:Sprite;

		public function Main():void {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			//get parameters
			if (stage.loaderInfo.parameters != null){
				var obj:Object = stage.loaderInfo.parameters;
				Main._config = obj;
			}

			//load config xml
			LoaderMax.activate([CSSLoader, SWFLoader, XMLLoader, ImageLoader]);

			canvas = new Sprite();
			addChild(canvas);
			var url:String = "assets/xml/config.xml";
			var l:XMLLoader = new XMLLoader(url, {name: "config", onComplete: onConfigComplete, onProgress: onConfigProgress});
			l.load(true);

			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}

		/**
		 * 屏幕变化
		 * @param	e
		 */
		private function onResize(e:Event = null):void {
			var w:int = Math.floor(stage.stageWidth);
			var h:int = Math.floor(stage.stageHeight);
			canvas.graphics.clear();
			canvas.graphics.beginFill(0xFFFFFF, .2);
			canvas.graphics.drawRect(w / -2, h / -2, w, h);
			canvas.graphics.endFill();
		}

		/**
		 * 加载条
		 * @param	e
		 */
		private function onConfigProgress(e:LoaderEvent):void {
			//var l:DataLoader = e.target as DataLoader;
			//_progress.value = l.progress;
			//var s:String = l.progress * 100 + "";
			//_percent.text = s.substr(0, 2) + "%";
		}

		/**
		 * 初始化窗口
		 */
		private function initForms():void {
			_forms = new Object();
			SparkManager.configProvider = _configProvider;
			FormManager.init(canvas, _xml);
		}

		/**
		 * 素材加载完成
		 * @param	e
		 */
		private function onConfigComplete(e:LoaderEvent):void {
			//获取素材
			_xml = new XML(LoaderMax.getContent("config").composition);
			_skin = LoaderMax.getLoader("skinSWF");
			_css = LoaderMax.getContent("skinCSS");
			_headXML = new XML(LoaderMax.getContent("head"));
			_facesXML = new XML(LoaderMax.getContent("faces"));
			//图标
			ToolsManager.vcardManager.loadItems(_headXML);
			ToolsManager.facesManager.loadItems(_facesXML);
			//样式
			ChatStyle.instance.setFormat("system", {text: "$content", head: "【系统】"});
			ChatStyle.instance.setFormat("chat", {text: "$self  $time $content", head: ""});
			//设置素材
			Style.cssStyle = _css;
			Style.skinSwf = _skin;
			//初始框架
			initForms();
		}

		/**
		 * 获取配置属性
		 * @param	key
		 * @return
		 */
		private function _configProvider(key:String):String {
			return _config[key] != null ? _config[key] : def_config[key];
		}
	}

}